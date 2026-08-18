local M = {}

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
