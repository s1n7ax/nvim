local M = {}

local function repo_dir()
	return vim.fs.root(0, '.git') or vim.uv.cwd()
end

local function gh(args, cwd, on_done)
	vim.system(
		vim.list_extend({ 'gh' }, args),
		{ cwd = cwd, text = true },
		vim.schedule_wrap(on_done)
	)
end

local function notify_failure(what, res)
	vim.notify(
		what .. ' failed: ' .. vim.trim(res.stderr or ''),
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

local function open_pr_web(cwd, url)
	gh({ 'pr', 'view', '--web' }, cwd, function(open)
		if open.code ~= 0 then
			notify_failure('gh pr view --web', open)
			return
		end

		vim.notify('Opened PR in browser: ' .. url)
	end)
end

function M.open_or_create_pr_web()
	local cwd = repo_dir()

	gh({ 'pr', 'view', '--json', 'url', '-q', '.url' }, cwd, function(view)
		if view.code ~= 0 then
			if vim.trim(view.stderr or ''):match('no pull requests found') then
				create_pr_web(cwd)
			else
				notify_failure('gh pr view', view)
			end

			return
		end

		open_pr_web(cwd, vim.trim(view.stdout or ''))
	end)
end

function M.yank_pr_url()
	local res = vim
		.system({ 'gh', 'pr', 'view', '--json', 'url', '-q', '.url' }, {
			cwd = repo_dir(),
			text = true,
		})
		:wait()

	if res.code ~= 0 then
		return nil
	end

	local url = vim.trim(res.stdout or '')

	return url ~= '' and url or nil
end

return M
