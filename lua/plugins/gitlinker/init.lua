local utils = require('utils')
local mapper = utils.mapper
local normal_map = mapper('n')
local visual_map = mapper('x')

normal_map({
	{ '<leader>ii', '<cmd>GitLink<cr>', 'Copy git link' },
})

visual_map({
	{ '<leader>ii', '<cmd>GitLink<cr>', 'Copy git link for selection' },
})

require('gitlinker').setup()
