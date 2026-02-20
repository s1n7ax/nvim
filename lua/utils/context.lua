local M = {}

function M.get_curr_context(opts)
	local m = vim.fn.mode()

	local template = ''

	if m == 'n' then
		local file = vim.fn.fnamemodify(vim.fn.expand('%:p'), ':.')

		if opts.range and opts.range == 0 then
			-- no lines selected
			return file
		end

		local line_diff = opts.line1 == opts.line2 and (opts.line1 .. 'L')
			or (opts.line1 .. 'L-' .. opts.line2 .. 'L')
		template = string.format('at %s:%s', file, line_diff)
	elseif m == 'v' then
		vim.cmd([[execute "normal! \<ESC>"]])
		local start_pos = vim.fn.getpos("'<")
		local end_pos = vim.fn.getpos("'>")

		local start_line, start_col = start_pos[2], start_pos[3]
		local end_line, end_col = end_pos[2], end_pos[3]

		local lines = vim.api.nvim_buf_get_text(
			0,
			start_line - 1,
			start_col - 1,
			end_line - 1,
			end_col,
			{}
		)

		local text = table.concat(lines, '\n')
		local file = vim.fn.fnamemodify(vim.fn.expand('%:p'), ':.')
		local line_diff = start_line == end_line and (start_line .. 'L')
			or (start_line .. 'L-' .. end_line .. 'L')

		if #lines > 1 then
			text = string.format('```\n%s\n```', text)
			template = string.format('%s\nat %s:%s', text, file, line_diff)
		else
			template = string.format('"%s" at %s:%s', text, file, line_diff)
		end
	elseif m == 'V' or m == '\22' then -- <C-V>
		vim.cmd([[execute "normal! \<ESC>"]])
		local start_pos = vim.fn.getpos("'<")
		local end_pos = vim.fn.getpos("'>")

		local start_line = start_pos[2]
		local end_line = end_pos[2]

		local file = vim.fn.fnamemodify(vim.fn.expand('%:p'), ':.')
		local line_diff = start_line == end_line and (start_line .. 'L')
			or (start_line .. 'L-' .. end_line .. 'L')

		template = string.format('at %s:%s', file, line_diff)
	end

	return template
end

return M
