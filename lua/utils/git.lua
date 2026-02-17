local M = {}

function M.get_default_branch()
	return io.popen(
		'git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed "s@^refs/remotes/origin/@@"'
	):read()
end

function M.checkout_file_to_origin_default_state()
	local default_branch = M.get_default_branch()

	if not default_branch then
		vim.notify('No default branch found', vim.log.levels.ERROR)
		return
	end

	local curr_file = vim.fn.expand('%:p')
	local cmd = 'git checkout origin/%s -- "%s"'

	vim.notify('Checkout file to origin/' .. default_branch)
	io.popen(cmd:format(default_branch, curr_file))
end

return M
