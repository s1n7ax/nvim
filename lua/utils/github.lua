local M = {}

local function repo_dir()
	return vim.fs.root(0, '.git') or vim.uv.cwd()
end

local function gh(args, on_done)
	vim.system(
		vim.list_extend({ 'gh' }, args),
		{ cwd = repo_dir(), text = true },
		vim.schedule_wrap(on_done)
	)
end

function M.open_or_create_pr_web()
	gh({ 'pr', 'view', '--web' }, function(view)
		if view.code == 0 then
			return
		end

		local err = vim.trim(view.stderr or '')

		if not err:match('no pull requests found') then
			vim.notify('gh pr view failed: ' .. err, vim.log.levels.ERROR)
			return
		end

		gh({ 'pr', 'create', '--web' }, function(create)
			if create.code ~= 0 then
				vim.notify(
					'gh pr create failed: ' .. vim.trim(create.stderr or ''),
					vim.log.levels.ERROR
				)
			end
		end)
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
