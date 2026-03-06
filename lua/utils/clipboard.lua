local M = {}

function M.copy_file_path()
	local path = vim.fn.expand('%:.')
	vim.fn.setreg('+', path)
	vim.notify('Copied file path: ' .. path)
end

function M.copy_file_name()
	local name = vim.fn.expand('%:t')
	vim.fn.setreg('+', name)
	vim.notify('Copied file name: ' .. name)
end

function M.copy_cwd()
	local cwd = vim.fn.getcwd()
	vim.fn.setreg('+', cwd)
	vim.notify('Copied cwd: ' .. cwd)
end

return M
