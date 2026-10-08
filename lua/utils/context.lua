local M = {}

---Lines shown above and below a selection
local SURROUNDING_LINES = 40
---Give up on slow language servers and use what has arrived
local DEFINITION_TIMEOUT_MS = 3000
local MAX_SYMBOLS = 60
---enough for an alias plus what it points at, without one overloaded name
---using up the whole budget
local MAX_DEFINITIONS_PER_NAME = 2
local MAX_DEFINITION_LINES = 60
---budgeted in lines rather than count, so one-line aliases cost next to nothing
local MAX_DEFINITION_TOTAL_LINES = 200

local function quote_path(file)
	return file:find(' ') and ('"' .. file .. '"') or file
end

---Path of the current buffer, relative to cwd
---@return string
function M.rel_file()
	local file = vim.fn.fnamemodify(vim.fn.expand('%:p'), ':.')

	return file ~= '' and file or '[No Name]'
end

---Human readable line range, e.g. `5L` or `2L-7L`
---@param start_line number
---@param end_line number
---@return string
function M.line_label(start_line, end_line)
	return start_line == end_line and (start_line .. 'L')
		or (start_line .. 'L-' .. end_line .. 'L')
end

---@class Selection
---@field start_line number
---@field end_line number
---@field mode string charwise `v`, linewise `V` or blockwise `<c-v>`
---@field start_pos number[] `getpos()` mark, for `selection_text`
---@field end_pos number[] `getpos()` mark, for `selection_text`

---Leave visual mode and return the selection it covered, or nil when the
---editor was not in visual mode
---@return Selection|nil
function M.get_visual()
	local mode = vim.fn.mode()

	if mode ~= 'v' and mode ~= 'V' and mode ~= '\22' then
		return nil
	end

	vim.cmd([[execute "normal! \<esc>"]])

	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")

	return {
		start_pos = start_pos,
		end_pos = end_pos,
		start_line = start_pos[2],
		end_line = end_pos[2],
		mode = mode,
	}
end

---Text a selection covers, read on demand so callers that only want the line
---range never pay for it
---@param selection Selection
---@return string
function M.selection_text(selection)
	return table.concat(
		vim.fn.getregion(
			selection.start_pos,
			selection.end_pos,
			{ type = selection.mode }
		),
		'\n'
	)
end

---Whether a 0-indexed row and byte column falls inside the selection
---@param selection Selection
---@param row number
---@param col number
---@return boolean
local function contains(selection, row, col)
	local lnum, vcol = row + 1, col + 1

	if lnum < selection.start_line or lnum > selection.end_line then
		return false
	end

	if selection.mode == 'V' then
		return true
	end

	local start_col, end_col = selection.start_pos[3], selection.end_pos[3]

	if selection.mode == 'v' then
		return (lnum > selection.start_line or vcol >= start_col)
			and (lnum < selection.end_line or vcol <= end_col)
	end

	return vcol >= math.min(start_col, end_col)
		and vcol <= math.max(start_col, end_col)
end

---@class Symbol
---@field name string
---@field row number 0-indexed
---@field col number 0-indexed byte column

---Names the selection references, first occurrence of each. With a parser,
---keywords, strings and comments are skipped; without one every word counts
---@param bufnr number
---@param selection Selection
---@return Symbol[]
local function selection_symbols(bufnr, selection)
	local symbols, seen = {}, {}
	local first, last = selection.start_line - 1, selection.end_line - 1

	local function add(name, row, col)
		if
			#symbols >= MAX_SYMBOLS
			or seen[name]
			or not name:match('^[%a_]')
			or not contains(selection, row, col)
		then
			return
		end

		seen[name] = true
		table.insert(symbols, { name = name, row = row, col = col })
	end

	local parser = vim.treesitter.get_parser(bufnr, nil, { error = false })

	if not parser then
		local lines = vim.api.nvim_buf_get_lines(bufnr, first, last + 1, false)

		for i, line in ipairs(lines) do
			for col, name in line:gmatch('()([%a_][%w_]*)') do
				add(name, first + i - 1, col - 1)
			end
		end

		return symbols
	end

	local function walk(node)
		local start_row, _, end_row = node:range()
		local type = node:type()

		if
			end_row < first
			or start_row > last
			or type:find('comment')
			or type:find('string')
		then
			return
		end

		if node:named_child_count() == 0 then
			local row, col = node:start()
			add(vim.treesitter.get_node_text(node, bufnr), row, col)
			return
		end

		for _, child in ipairs(node:named_children()) do
			walk(child)
		end
	end

	walk(parser:parse()[1]:root())

	return symbols
end

---Contents of a file, unsaved changes included when it is open
---@param path string
---@return string[]|nil
local function read_lines(path)
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if
			vim.api.nvim_buf_is_loaded(buf)
			and vim.api.nvim_buf_get_name(buf) == path
		then
			return vim.api.nvim_buf_get_lines(buf, 0, -1, false)
		end
	end

	local ok, lines = pcall(vim.fn.readfile, path)
	return ok and lines or nil
end

---0-indexed rows of the declaration at a position, grown to the outermost node
---starting on that row, e.g. a function name grows to the whole function
---@param path string
---@param lines string[]
---@param row number
---@param col number 0-indexed byte column
---@return number start_row, number end_row
local function declaration_rows(path, lines, row, col)
	local ok, start_row, end_row = pcall(function()
		local ft = vim.filetype.match({ filename = path, contents = lines })
		local lang = ft and vim.treesitter.language.get_lang(ft)

		if not lang then
			return row, row
		end

		local source = table.concat(lines, '\n')
		local root =
			vim.treesitter.get_string_parser(source, lang):parse()[1]:root()
		local node = root:named_descendant_for_range(row, col, row, col)

		if not node or not node:parent() then
			return row, row
		end

		local parent = node:parent()

		while parent and parent:parent() and parent:start() == row do
			node, parent = parent, parent:parent()
		end

		local _, _, last_row, last_col = node:range()

		---the end is exclusive, so a node ending in a newline stops a row early
		if last_col == 0 and last_row > row then
			last_row = last_row - 1
		end

		return row, last_row
	end)

	if not ok then
		return row, row
	end

	return start_row, end_row
end

---@class Definition
---@field name string symbol the selection references
---@field path string relative to cwd
---@field start_line number
---@field end_line number
---@field text string
---@field in_project boolean under cwd, ranked before library code

---@class LineRange
---@field start_line number
---@field end_line number

---Turn raw `textDocument/definition` responses into deduplicated definitions,
---project files first, leaving out those already inside `shown` and those
---past the line budget
---@param bufnr number
---@param shown LineRange lines of `bufnr` the caller already shows
---@param symbols Symbol[]
---@param responses table<number, table<number, { result: any }>>
---@return Definition[]
local function to_definitions(bufnr, shown, symbols, responses)
	local definitions, seen, per_name = {}, {}, {}
	local buf_path = vim.api.nvim_buf_get_name(bufnr)
	local cwd = vim.fn.getcwd() .. '/'

	for i, symbol in ipairs(symbols) do
		for client_id, response in pairs(responses[i] or {}) do
			local client = vim.lsp.get_client_by_id(client_id)
			local result = response.result

			---a single Location is allowed in place of a list
			if result and (result.uri or result.targetUri) then
				result = { result }
			end

			for _, location in ipairs(result or {}) do
				local path = vim.uri_to_fname(location.targetUri or location.uri)
				local range = location.targetRange or location.range
				local name_range = location.targetSelectionRange or location.range
				local lines = read_lines(path)

				if lines and client then
					local start_row, end_row = range.start.line, range['end'].line

					if start_row == end_row then
						local name_row = name_range.start.line
						local col = vim.str_byteindex(
							lines[name_row + 1] or '',
							client.offset_encoding,
							name_range.start.character,
							false
						)
						start_row, end_row = declaration_rows(path, lines, name_row, col)
					end

					local start_line = start_row + 1
					local end_line = math.min(end_row + 1, #lines)
					local key = path .. ':' .. start_line
					local is_shown = path == buf_path
						and start_line >= shown.start_line
						and end_line <= shown.end_line

					local count = per_name[symbol.name] or 0

					if
						not seen[key]
						and not is_shown
						and count < MAX_DEFINITIONS_PER_NAME
					then
						seen[key] = true
						per_name[symbol.name] = count + 1

						local truncated = end_line - start_line + 1 > MAX_DEFINITION_LINES

						if truncated then
							end_line = start_line + MAX_DEFINITION_LINES - 1
						end

						local text =
							table.concat(vim.list_slice(lines, start_line, end_line), '\n')

						table.insert(definitions, {
							name = symbol.name,
							path = vim.fn.fnamemodify(path, ':.'),
							start_line = start_line,
							end_line = end_line,
							text = truncated and (text .. '\n...') or text,
							in_project = vim.startswith(path, cwd),
						})
					end
				end
			end
		end
	end

	---stable, so each group keeps the order names appear in the selection
	local ranked = vim.list_extend(
		vim.tbl_filter(function(d)
			return d.in_project
		end, definitions),
		vim.tbl_filter(function(d)
			return not d.in_project
		end, definitions)
	)

	local picked, total = {}, 0

	for _, def in ipairs(ranked) do
		local size = def.end_line - def.start_line + 1

		if total + size <= MAX_DEFINITION_TOTAL_LINES then
			table.insert(picked, def)
			total = total + size
		end
	end

	return picked
end

---Lines around a selection, so a summary knows where and how it is used
---@param bufnr number
---@param selection Selection
---@return LineRange range, string text
function M.surrounding(bufnr, selection)
	local start_line = math.max(1, selection.start_line - SURROUNDING_LINES)
	local end_line = math.min(
		vim.api.nvim_buf_line_count(bufnr),
		selection.end_line + SURROUNDING_LINES
	)
	local lines =
		vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)

	return { start_line = start_line, end_line = end_line },
		table.concat(lines, '\n')
end

---Resolve where the names in a selection are defined, so a summary of e.g. a
---lone function name can describe the function body. Calls back with an empty
---list when no language server can answer
---@param bufnr number
---@param selection Selection
---@param shown LineRange lines of `bufnr` the caller already shows
---@param callback fun(definitions: Definition[])
function M.definitions(bufnr, selection, shown, callback)
	local method = 'textDocument/definition'
	local clients = vim.lsp.get_clients({ bufnr = bufnr, method = method })
	local ok, symbols = pcall(selection_symbols, bufnr, selection)

	if not ok then
		vim.notify(
			'Reading selection symbols failed: ' .. symbols,
			vim.log.levels.WARN
		)
		symbols = {}
	end

	if #symbols == 0 or #clients == 0 then
		return callback({})
	end

	local responses, cancels = {}, {}
	local pending = #symbols
	local done = false

	local function finish()
		if done then
			return
		end

		done = true

		if pending > 0 then
			for _, cancel in pairs(cancels) do
				pcall(cancel)
			end
		end

		local resolved, definitions =
			pcall(to_definitions, bufnr, shown, symbols, responses)

		if not resolved then
			vim.notify(
				'Resolving definitions failed: ' .. definitions,
				vim.log.levels.WARN
			)
			definitions = {}
		end

		callback(definitions)
	end

	vim.defer_fn(finish, DEFINITION_TIMEOUT_MS)

	for i, symbol in ipairs(symbols) do
		local line =
			vim.api.nvim_buf_get_lines(bufnr, symbol.row, symbol.row + 1, false)[1]

		cancels[i] = vim.lsp.buf_request_all(bufnr, method, function(client)
			return {
				textDocument = { uri = vim.uri_from_bufnr(bufnr) },
				position = {
					line = symbol.row,
					character = vim.str_utfindex(
						line,
						client.offset_encoding,
						symbol.col,
						false
					),
				},
			}
		end, function(results)
			responses[i] = results
			pending = pending - 1

			if pending == 0 then
				finish()
			end
		end)
	end
end

function M.get_curr_context(opts)
	if vim.fn.mode() == 'n' then
		local file = quote_path(M.rel_file())

		---a range of 0 means the command was run without any lines selected
		if opts.range and opts.range == 0 then
			return '@' .. file .. ' '
		end

		return string.format('@%s %s', file, M.line_label(opts.line1, opts.line2))
	end

	local selection = M.get_visual()

	if not selection then
		return ''
	end

	local ref = string.format(
		'@%s %s',
		quote_path(M.rel_file()),
		M.line_label(selection.start_line, selection.end_line)
	)

	if selection.mode ~= 'v' then
		return ref
	end

	local text = M.selection_text(selection)

	if selection.start_line ~= selection.end_line then
		return string.format('```\n%s\n```\n%s', text, ref)
	end

	return string.format('"%s" %s', text, ref)
end

return M
