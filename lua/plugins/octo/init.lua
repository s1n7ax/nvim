local utils = require('utils')
local nmap = utils.mapper('n')

require('octo').setup({
	picker = 'snacks',
	enable_builtin = true,
})

-- stylua: ignore
nmap({
	{ '<leader>er', '<cmd>Octo pr list<cr>', 'GitHub PRs (review)' },
	{ '<leader>ev', '<cmd>Octo review start<cr>', 'Start PR review' },
})
