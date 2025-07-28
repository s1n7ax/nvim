vim.pack.add({ 'https://github.com/j-hui/fidget.nvim' })

require('fidget').setup({
	notification = {
		window = {
			winblend = 100,
		},
	},
	progress = {
		display = {
			render_limit = 5,
		},
	},
})

