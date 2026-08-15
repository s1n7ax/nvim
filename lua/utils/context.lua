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
---@field text string
---@field start_line number
---@field end_line number
---@field mode string charwise `v`, linewise `V` or blockwise `<c-v>`

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
		text = table.concat(
			vim.fn.getregion(start_pos, end_pos, { type = mode }),
			'\n'
		),
		start_line = start_pos[2],
		end_line = end_pos[2],
		mode = mode,
	}
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

	if selection.start_line ~= selection.end_line then
		return string.format('```\n%s\n```\n%s', selection.text, ref)
	end

	return string.format('"%s" %s', selection.text, ref)
end

return M
