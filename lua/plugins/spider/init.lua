vim.pack.add({ 'https://github.com/chrisgrieser/nvim-spider' })

-- Configure spider
require('spider').setup({
	subwordMovement = false,
})

-- stylua: ignore start
-- Set up keymaps for spider motions
vim.keymap.set({ 'n', 'o', 'x' }, 'w', function()
	require('spider').motion('w')
end, { desc = 'Spider w motion' })

vim.keymap.set({ 'n', 'o', 'x' }, 'l', function()
	require('spider').motion('e')
end, { desc = 'Spider e motion' })

vim.keymap.set({ 'n', 'o', 'x' }, 'b', function()
	require('spider').motion('b')
end, { desc = 'Spider b motion' })

vim.keymap.set('n', 'cw', 'ce', { desc = 'Change to end of word' })
vim.keymap.set('n', 'dw', 'de', { desc = 'Delete to end of word' })
-- stylua: ignore end
