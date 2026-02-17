local utils = require('utils')
local mapper = utils.mapper
local nmap = mapper('n')
local vmap = mapper('x')

local function diffview_default_branch()
	local handle = utils.git.get_default_branch()

	if not handle then
		vim.notify('No default branch found', vim.log.levels.ERROR)
		return
	end

	local default_branch = handle:read('*a'):gsub('%s+', '')
	handle:close()

	if default_branch == '' then
		default_branch = 'main'
	end

	vim.notify('Opening diff against "' .. default_branch .. '" branch')
	vim.cmd.DiffviewOpen(default_branch)
end

-- stylua: ignore
nmap({
	{ '<leader>ie', '<cmd>DiffviewFileHistory %<cr>', 'Git diff file' },
	{ '<leader>in', diffview_default_branch, 'Git diff main branch' },
	{ '<leader>it', '<cmd>DiffviewFileHistory<cr>', 'Git diff branch' },
})

vmap({
	{ '<leader>ie', '<cmd>DiffviewFileHistory %<cr>', 'Git diff selection' },
})

require('diffview').setup()
