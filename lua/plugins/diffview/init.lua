local utils = require('utils')
local mapper = utils.mapper
local nmap = mapper('n')
local vmap = mapper('x')

local function diffview_default_branch()
	local default_branch = utils.git.get_default_branch()

	if not default_branch or default_branch == '' then
		default_branch = 'main'
	end

	vim.notify('Opening diff against "' .. default_branch .. '" branch')
	vim.cmd.DiffviewOpen(default_branch)
end

-- stylua: ignore
nmap({
	{ '<leader>ee', '<cmd>DiffviewFileHistory %<cr>', 'Git diff file' },
	{ '<leader>en', diffview_default_branch, 'Git diff main branch' },
	{ '<leader>et', '<cmd>DiffviewFileHistory<cr>', 'Git diff branch' },
})

vmap({
	{ '<leader>ee', '<cmd>DiffviewFileHistory %<cr>', 'Git diff selection' },
})

require('diffview').setup()
