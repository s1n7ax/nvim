local M = {}

local PR_URL_ARGS = { 'pr', 'view', '--json', 'url', '-q', '.url' }

local function repo_dir()
	return vim.fs.root(0, '.git') or vim.uv.cwd()
end

local function gh(args, cwd, on_done)
	return vim.system(
		vim.list_extend({ 'gh' }, args),
		{ cwd = cwd, text = true },
		on_done and vim.schedule_wrap(on_done)
	)
end

local function notify_failure(what, res)
	local stderr = vim.trim(res.stderr or '')

	vim.notify(
		what
			.. ' failed: '
			.. (stderr ~= '' and stderr or ('exited with ' .. res.code)),
		vim.log.levels.ERROR
	)
end

local function create_pr_web(cwd)
	vim.notify('No PR for this branch, opening the create page')

	gh({ 'pr', 'create', '--web' }, cwd, function(create)
		if create.code ~= 0 then
			notify_failure('gh pr create', create)
		end
	end)
end

function M.open_or_create_pr_web()
	local cwd = repo_dir()

	gh(PR_URL_ARGS, cwd, function(view)
		if view.code ~= 0 then
			if vim.trim(view.stderr or ''):match('no pull requests found') then
				create_pr_web(cwd)
			else
				notify_failure('gh pr view', view)
			end

			return
		end

		local url = vim.trim(view.stdout or '')
		local _, err = vim.ui.open(url)

		if err then
			vim.notify(err, vim.log.levels.ERROR)
			return
		end

		vim.notify('Opened PR in browser: ' .. url)
	end)
end

function M.yank_pr_url()
	local res = gh(PR_URL_ARGS, repo_dir()):wait(5000)
	local url = res and res.code == 0 and vim.trim(res.stdout or '') or ''

	return url ~= '' and url or nil
end

return M
