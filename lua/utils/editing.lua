local M = {}

function M.add_line_above()
	local curr_line = vim.api.nvim_win_get_cursor(0)[1]
	local prev_line = curr_line - 1
	vim.api.nvim_buf_set_lines(0, prev_line, prev_line, true, { '' })
	vim.api.nvim_input('<up>')
end

function M.add_line_below()
	local curr_line = vim.api.nvim_win_get_cursor(0)[1]
	vim.api.nvim_buf_set_lines(0, curr_line, curr_line, true, { '' })
	vim.api.nvim_input('<down>')
end

function M.duplicate_line()
	local buffer = vim.api.nvim_get_current_buf()
	local cursor = vim.api.nvim_win_get_cursor(0)
	local curr_line = vim.api.nvim_get_current_line()
	vim.api.nvim_buf_set_lines(buffer, cursor[1], cursor[1], true, { curr_line })
	vim.api.nvim_win_set_cursor(0, { cursor[1] + 1, cursor[2] })
end

function M.escape()
	vim.api.nvim_input('<esc>')
end

return M
