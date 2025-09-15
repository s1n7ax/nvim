require('supermaven-nvim').setup({
	keymaps = {
		accept_suggestion = '<C-o>',
		clear_suggestion = '<C-l>',
	},
	color = {
		suggestion_color = '#ffffff',
		cterm = 244,
	},
	disable_inline_completion = false,
	disable_keymaps = false,
})
