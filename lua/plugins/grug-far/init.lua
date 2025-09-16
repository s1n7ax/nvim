require('grug-far').setup({})

vim.keymap.set('n', '<leader>sr', function()
	local grug = require('grug-far')
	local ext = vim.bo.buftype == '' and vim.fn.expand('%:e')
	grug.open({
		transient = true,
		prefills = {
			filesFilter = ext and ext ~= '' and '*.' .. ext or nil,
		},
	})
end, {
	desc = 'Search and Replace',
})
