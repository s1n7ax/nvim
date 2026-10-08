local utils = require('utils')
local mapper = utils.mapper
local nmap = mapper('n')

nmap({
	{ '<leader>en', '<cmd>NvimDiffPR<cr>', 'Review PR (current branch)' },
})
