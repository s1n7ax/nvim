local render_markdown = require('render-markdown')
local nmap = require('utils').mapper('n')

render_markdown.setup({
	latex = { enabled = false },
})

-- stylua: ignore
nmap({
	{ '<leader>uo', '<cmd>MdRender textsize toggle<cr>', 'Toggle markdown large headings' },
})

vim.api.nvim_create_autocmd('FileType', {
	group = vim.api.nvim_create_augroup('MarkdownKeymaps', { clear = true }),
	pattern = 'markdown',
	callback = function(event)
		local opts = function(desc)
			return { buffer = event.buf, desc = desc }
		end

		-- stylua: ignore
		nmap({
			{ '<leader>un', '<cmd>vertical MdRender split<cr>', opts('Markdown preview (split)') },
			{ '<leader>ue', render_markdown.buf_toggle, opts('Toggle markdown rendering') },
		})
	end,
})
