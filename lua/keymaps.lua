local utils = require('utils')

local mapper = utils.mapper
local navigate_window = utils.windows.navigate_window
local split_left = utils.windows.split_left
local split_right = utils.windows.split_right
local split_top = utils.windows.split_top
local split_bottom = utils.windows.split_bottom
local add_line_above = utils.editing.add_line_above
local add_line_below = utils.editing.add_line_below
local duplicate_line = utils.editing.duplicate_line
local escape = utils.editing.escape

local amap = mapper({ 'n', 'o', 'x' })
local cmap = mapper('c')
local nmap = mapper('n')
local imap = mapper('i')
local tmap = mapper('t')
local vmap = mapper('x')

-- colemak remaps
amap({
	{ '<c-l>', '<c-i>', 'Jump to previous jump point' },
	{ 'E', 'K', 'Keyword lookup' },
	{ 'H', 'I', 'Insert at line start' },
	{ 'K', 'N', 'Find prev' },
	{ 'L', 'E', 'Last char before white space' },
	{ 'N', 'J', 'Join below line' },
	{ 'e', '<up>', 'Up' },
	{ 'h', 'i', 'Insert' },
	{ 'i', '<right>', 'Right' },
	{ 'j', 'm', 'Create mark' },
	{ 'k', 'n', 'Find next' },
	{ 'l', 'e', 'Next end of word' },
	{ 'm', '<left>', 'Left' },
	{ 'n', '<down>', 'Down' },
})

-- command mode keymaps
cmap({
	{ '<c-e>', '<c-p>', 'Previous' },
})

-- normal mode keymaps
-- stylua: ignore
nmap({
	{ '<c-s>', ':silent w<cr>', 'Save' },
	{ '<c-q>', ':confirm q<cr>', 'Close' },
	{ '<leader><leader>o', '<cmd>messages<cr>', 'Open messages window' },
	{ '<leader>p', 'a <esc>p', 'Paste After a Space' },
	{ '[<leader>', add_line_above, 'Add line above' },
	{ ']<leader>', add_line_below, 'Add line below' },
	{ 'x', '"_x', 'Delete Character' },
	{ "''", '``zz', 'Go to last jump point' },
	{ '0', '^', 'Go to first character of line' },
	{ '<C-l>', '<C-i>zz', 'Go to next jump point' },
	{ '<C-o>', '<C-o>zz', 'Go to prev jump point' },
	{ '^', '0', 'Go to start of line' },
	{ '<C-u>', '<C-u>zz', 'Scroll up and center' },
	{ '<C-d>', '<C-d>zz', 'Scroll down and center' },
	-- Window navigation
	{ '<c-n>', navigate_window('j'), 'Window down' },
	{ '<c-e>', navigate_window('k'), 'Window up' },
	{ '<c-m>', navigate_window('h'), 'Window left' },
	{ '<c-i>', navigate_window('l'), 'Window right' },
	-- Window splitting
	{ '<a-m>', split_left, 'Split left' },
	{ '<a-n>', split_bottom, 'Split down' },
	{ '<a-e>', split_top, 'Split up' },
	{ '<a-i>', split_right, 'Split right' },
	-- LSP
	{ 'gd', vim.lsp.buf.definition, 'Go to definition' },
	{ 'I', vim.lsp.buf.hover, 'LSP hover info' },
	{ ']d', function() vim.diagnostic.jump({ count = 1, float = true }) end, 'Next diagnostic' },
	{ '[d', function() vim.diagnostic.jump({ count = -1, float = true }) end, 'Previous diagnostic' },
})

-- insert mode keymaps
imap({
	{ '<c-c>', escape, 'Escape' },
	{ '<c-s>', '<cmd>:w<cr>', 'Save the file' },
	{ '<c-v>', '<esc>pa', 'Paste' },
	{ '<m-a>', '<esc>I', '(Insert) Jump to line start' },
	{ '<m-e>', '<esc>A', '(Insert) Jump to line end' },
	{ '<m-h>', '<esc>O', 'Insert new line below' },
	{ '<m-k>', '<esc>ddi', 'Delete current line' },
	{ '<m-y>', duplicate_line, 'Duplicate current line' },
})

-- terminal mode keymaps
tmap({
	{ 'nn', '<C-\\><C-n>', 'Exit terminal mode' },
})

-- visual mode keymaps
vmap({
	{ 'p', 'P', 'Paste yanked text' },
	{ '$', 'g_', 'Select until end of line' },
})
