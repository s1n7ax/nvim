-- Set up keymap for WinShift
vim.keymap.set('n', '<c-w>m', '<cmd>WinShift<cr>', { desc = 'Shift window mode' })

-- Configure winshift with Colemak keymaps
require('winshift').setup({
	keymaps = {
		disable_defaults = true,
		win_move_mode = {
			['m'] = 'left',
			['n'] = 'down',
			['e'] = 'up',
			['i'] = 'right',
			['M'] = 'far_left',
			['N'] = 'far_down',
			['E'] = 'far_up',
			['I'] = 'far_right',
			['<left>'] = 'left',
			['<down>'] = 'down',
			['<up>'] = 'up',
			['<right>'] = 'right',
			['<S-left>'] = 'far_left',
			['<S-down>'] = 'far_down',
			['<S-up>'] = 'far_up',
			['<S-right>'] = 'far_right',
		},
	},
})