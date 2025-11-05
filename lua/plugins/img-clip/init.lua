require('img-clip').setup({})

local utils = require('utils')
local mapper = utils.mapper
local nmap = mapper('n')

-- stylua: ignore
nmap({
	{ "<leader><leader>t", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
})
