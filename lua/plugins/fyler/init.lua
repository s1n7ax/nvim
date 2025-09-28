require('fyler').setup({
	icon_provider = 'nvim_web_devicons',
	mappings = {
		[',t'] = 'CloseView',
		['<CR>'] = 'Select',
		['<C-v>'] = 'SelectVSplit',
		['<C-x>'] = 'SelectSplit',
		['^'] = 'GotoParent',
		['='] = 'GotoCwd',
		['.'] = 'GotoNode',
		['#'] = 'CollapseAll',
		['<BS>'] = 'CollapseNode',
	},
})

vim.keymap.set('n', ',t', '<cmd>Fyler<cr>', { desc = 'Open files explorer' })
