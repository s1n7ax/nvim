local render_markdown = require('render-markdown')
local nmap = require('utils').mapper('n')

render_markdown.setup({
	latex = { enabled = false },
})

vim.api.nvim_create_autocmd('FileType', {
	group = vim.api.nvim_create_augroup('MarkdownKeymaps', { clear = true }),
	pattern = 'markdown',
	callback = function(event)
		-- stylua: ignore
		nmap({
			{ '<leader>un', render_markdown.buf_toggle, { buffer = event.buf, desc = 'Toggle markdown rendering' } },
		})
	end,
})
