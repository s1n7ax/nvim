require('fyler').setup({
	default_explorer = true,
	icon_provider = 'nvim_web_devicons',
	delete_to_trash = true,
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
	buf_opts = {},
	win_opts = {
		-- number = false,
		-- relativenumber = false,
	},
})

vim.keymap.set('n', ',t', '<cmd>Fyler<cr>', { desc = 'Open files explorer' })
