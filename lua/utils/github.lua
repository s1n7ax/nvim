local M = {}

function M.open_or_create_pr_web()
	local cmd = 'gh pr view --web'
	io.popen(cmd)
end

function M.yank_pr_url()
	local cmd = 'gh pr view --json url -q .url'
	local url = io.popen(cmd):read()
	return url
end

return M
