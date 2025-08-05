local utils = require('utils')
local mapper = utils.mapper
local nmap = mapper('n')
local vmap = mapper('x')

-- stylua: ignore
nmap({
	{ '<leader>ii', '<cmd>DiffviewFileHistory %<cr>', 'Git diff file' },
	{ '<leader>in', '<cmd>DiffviewFileHistory<cr>', 'Git diff branch' },
})

vmap({
	{ '<leader>ii', '<cmd>DiffviewFileHistory %<cr>', 'Git diff selection' },
})

require('diffview').setup()
