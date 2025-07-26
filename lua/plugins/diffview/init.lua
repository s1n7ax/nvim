vim.pack.add({ 'https://github.com/sindrets/diffview.nvim' })
vim.pack.add({ 'https://github.com/nvim-lua/plenary.nvim' })

local utils = require('utils')
local mapper = utils.mapper
local nmap = mapper('n')
local vmap = mapper('x')

-- stylua: ignore
nmap({
	{ '<leader>hd', '<cmd>DiffviewFileHistory %<cr>', 'Git diff file' },
	{ '<leader>hD', '<cmd>DiffviewFileHistory<cr>', 'Git diff branch' },
})

vmap({
	{ '<leader>hd', ':DiffviewFileHistory<cr>', 'Git diff selection' },
})

require('diffview').setup()
