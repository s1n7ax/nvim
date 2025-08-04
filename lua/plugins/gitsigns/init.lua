require('gitsigns').setup({
	current_line_blame = true,
	word_diff = false,
	linehl = true,
})

-- Git hunk navigation keymaps
local gs = require('gitsigns')
vim.keymap.set('n', ']g', gs.next_hunk, { desc = 'Next git hunk' })
vim.keymap.set('n', '[g', gs.prev_hunk, { desc = 'Previous git hunk' })
