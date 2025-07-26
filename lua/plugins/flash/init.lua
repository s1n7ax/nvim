vim.pack.add({ 'https://github.com/folke/flash.nvim' })

local utils = require('utils')
local mapper = utils.mapper
local nmap = mapper('n')
local omap = mapper('o')
local amap = mapper({ 'n', 'o', 'x' })

local flash = function(func_name)
	return function()
		require('flash')[func_name]()
	end
end

omap({ { 'r', flash('remote'), 'Remote Flash' } })
amap({ { 'S', flash('treesitter'), 'Flash Treesitter' } })
nmap({ { 'R', flash('treesitter_search'), 'Treesitter Search' } })

require('flash').setup({
	modes = {
		search = {
			enabled = false,
		},
		char = {
			enabled = true,
			keys = { 'F', 'f', 'T', 't' },
		},
	},
})
