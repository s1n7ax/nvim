vim.pack.add({ 'https://github.com/mistricky/codesnap.nvim' })

require('codesnap').setup({
	has_breadcrumbs = true,
	watermark = '',
	bg_x_padding = 15,
	bg_y_padding = 15,
})
