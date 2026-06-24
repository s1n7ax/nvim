local utils = require('utils')
local mapper = utils.mapper
local normal_map = mapper('n')
local visual_map = mapper('x')

normal_map({
	{ '<leader>ee', '<cmd>GitLink<cr>', 'Copy git link' },
})

visual_map({
	{ '<leader>ee', '<cmd>GitLink<cr>', 'Copy git link (selection)' },
})

require('gitlinker').setup()
