local M = {}

function M.copy_file_path()
	local path = vim.fn.expand('%:p')
	vim.fn.setreg('+', path)
	vim.notify('Copied file path: ' .. path)
end

function M.copy_file_name()
	local name = vim.fn.expand('%:t')
	vim.fn.setreg('+', name)
	vim.notify('Copied file name: ' .. name)
end

return M
