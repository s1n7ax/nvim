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
			{
				'<leader>un',
				function()
					render_markdown.buf_toggle()
					local ok, state = pcall(require, 'render-markdown.state')
					if ok then
						local config_ok, config = pcall(state.get, event.buf)
						if config_ok then
							require('utils.toggle').notify('Markdown rendering', config.enabled)
						end
					end
				end,
				{ buffer = event.buf, desc = 'Toggle markdown rendering' },
			},
		})
	end,
})
