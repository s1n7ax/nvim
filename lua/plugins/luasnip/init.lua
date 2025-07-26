vim.pack.add({
	'https://github.com/L3MON4D3/LuaSnip',
	'https://github.com/s1n7ax/nvim-snips',
	'https://github.com/s1n7ax/nvim-ts-utils',
	'https://github.com/nvim-treesitter/nvim-treesitter',
})

local helper = require('plugins.luasnip.helper')

helper.register_snippets()
-- stylua: ignore
vim.keymap.set(
	{ 'i', 's' }, '<c-i>', helper.expand_or_jump(), { desc = '(Snippet) Expand or jump' })

-- return {
-- 	{ '<Tab>', '<Tab>', desc = 'Tab Space', mode = { 'i', 's' } },
-- 	{
-- 		'<c-i>',
-- 		helper.expand_or_jump(),
-- 		desc = '(Snippet) Expand or jump',
-- 		mode = { 'i', 's' },
-- 	},
-- 	{
-- 		'<c-m>',
-- 		helper.jump_prev(),
-- 		desc = '(Snippet) Jump prev placeholder',
-- 		mode = { 's' },
-- 	},
-- 	{
-- 		'<c-l>',
-- 		helper.change_choice(),
-- 		desc = '(Snippet) Change choice',
-- 		mode = { 'i', 's' },
-- 	},
-- }
