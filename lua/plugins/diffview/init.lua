local utils = require('utils')
local mapper = utils.mapper
local nmap = mapper('n')
local vmap = mapper('x')

local function diffview_default_branch()
	local handle = io.popen(
		'git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed "s@^refs/remotes/origin/@@"'
	)

	if not handle then
		return vim.cmd.DiffviewFileHistory()
	end

	local default_branch = handle:read('*a'):gsub('%s+', '')
	handle:close()

	if default_branch == '' then
		default_branch = 'main'
	end

	vim.cmd.DiffviewOpen(default_branch)
end

-- stylua: ignore
nmap({
	{ '<leader>ii', '<cmd>DiffviewFileHistory %<cr>', 'Git diff file' },
	{ '<leader>in', diffview_default_branch, 'Git diff main branch' },
	{ '<leader>it', '<cmd>DiffviewFileHistory<cr>', 'Git diff branch' },
})

vmap({
	{ '<leader>ii', '<cmd>DiffviewFileHistory %<cr>', 'Git diff selection' },
})

require('diffview').setup()
