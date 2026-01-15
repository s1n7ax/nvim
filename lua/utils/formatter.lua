local M = {}

function M.format_opencode_prompt(input)
	local new_input = input
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")
	local has_selection = not (
		start_pos[2] == end_pos[2] and start_pos[3] == end_pos[3]
	)

	if new_input:match('@this') then
		local curr_file = vim.fn.fnamemodify(vim.fn.expand('%:p'), ':.')
		local replacement = curr_file
		if has_selection then
			local start_line, end_line = vim.fn.line("'<"), vim.fn.line("'>")
			replacement = table.concat({ curr_file, start_line, end_line }, ':')
		end
		new_input = new_input:gsub('@this', replacement)
	end

	if new_input:match('@buf') then
		local content
		if has_selection then
			local start_line, start_col = start_pos[2], start_pos[3]
			local end_line, end_col = end_pos[2], end_pos[3]
			local lines =
				vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

			if #lines == 1 then
				lines[1] = lines[1]:sub(start_col, end_col)
			else
				lines[1] = lines[1]:sub(start_col)
				lines[#lines] = lines[#lines]:sub(1, end_col)
			end
			content = table.concat(lines, '\n')
		else
			local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
			content = table.concat(lines, '\n')
		end
		local filetype = vim.bo.filetype
		local replacement = string.format('\n\n```%s\n%s\n```\n', filetype, content)
		new_input = new_input:gsub('@buf', replacement)
	end

	return new_input
end

return M
