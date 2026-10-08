local utils = require('utils')
local mapper = utils.mapper
local nmap = mapper('n')
local vmap = mapper('x')

-- stylua: ignore
nmap({
	{ '<leader>et', '<cmd>DiffviewFileHistory<cr>', 'File history (branch)' },
	{ '<leader>es', '<cmd>DiffviewFileHistory %<cr>', 'File history (current)' },
})

vmap({
	{ '<leader>es', '<cmd>DiffviewFileHistory %<cr>', 'File history (selection)' },
})

require('diffview').setup()
