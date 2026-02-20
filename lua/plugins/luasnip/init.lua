local utils = require('utils')
local nmap = utils.keymaps.mapper({ 'n' })

local helper = require('plugins.luasnip.helper')

helper.register_snippets()
-- stylua: ignore
vim.keymap.set({ 'i', 's' }, '<c-i>', helper.expand_or_jump(), { desc = '(Snippet) Expand or jump' })
vim.keymap.set(
	'n',
	'<c-i>',
	helper.expand_or_jump(),
	{ desc = '(Snippet) Expand or jump' }
)

-- stylua: ignore
-- nmap({
-- 	{ { 'i', 's' }, '<c-i>', helper.expand_or_jump(), { desc = '(Snippet) Expand or jump' } },
-- 	{ { 'i', 's' }, '<c-i>', helper.expand_or_jump(), { desc = '(Snippet) Expand or jump' } },
-- })

vim.keymap.set({ 'i', 's' }, '<Tab>', '<Tab>', {desc = 'Tab Space'})
-- vim.keymap.set(
-- 	{ 'i', 's' },
-- 	'<c-m>',
-- 	helper.jump_prev(),
-- 	{ desc = '(Snippet) Jump prev placeholder' }
-- )

vim.keymap.set(
	{ 'i', 's' },
	'<c-l>',
	helper.change_choice(),
	{ desc = '(Snippet) Change choice' }
)

return {
	-- { '<Tab>', '<Tab>', desc = 'Tab Space', mode = { 'i', 's' } },
	-- {
	-- 	'<c-i>',
	-- 	helper.expand_or_jump(),
	-- 	desc = '(Snippet) Expand or jump',
	-- 	mode = { 'i', 's' },
	-- },
	-- {
	-- 	'<c-m>',
	-- 	helper.jump_prev(),
	-- 	desc = '(Snippet) Jump prev placeholder',
	-- 	mode = { 's' },
	-- },
	-- {
	-- 	'<c-l>',
	-- 	helper.change_choice(),
	-- 	desc = '(Snippet) Change choice',
	-- 	mode = { 'i', 's' },
	-- },
}
