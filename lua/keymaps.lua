local utils = require('utils')
local clipboard = require('utils.clipboard')

local mapper = utils.mapper
local add_line_above = utils.editing.add_line_above
local add_line_below = utils.editing.add_line_below
local duplicate_line = utils.editing.duplicate_line
local escape = utils.editing.escape

local amap = mapper({ 'n', 'o', 'x' })
local cmap = mapper('c')
local nmap = mapper('n')
local imap = mapper('i')
local tmap = mapper('t')
local vmap = mapper('v')

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
	{ '<c-q>', '<cmd>confirm quit<cr>', 'Close' },
	{ '<c-s>', '<cmd>silent w<cr>', 'Save' },
	{ '<leader><leader>o', '<cmd>messages<cr>', 'Open messages window' },
	{ '<leader>p', 'a <esc>p', 'Paste After a Space' },
	{ '[<leader>', add_line_above, 'Add line above' },
	{ ']<leader>', add_line_below, 'Add line below' },
	{ 'x', '"_x', 'Delete Character' },
	{ '<leader>uz', '<cmd>set spell!<cr>', 'Toggle spell check' },
	{ "''", '``zz', 'Go to last jump point' },
	{ '0', '^5zH', 'Go to first character of line' },
	{ '<C-l>', '<C-i>zz', 'Go to next jump point' },
	{ '<C-o>', '<C-o>zz', 'Go to prev jump point' },
	{ '^', '0', 'Go to start of line' },
	-- Window navigation
	{ '<c-n>', '<c-w>j', 'Window down' },
	{ '<c-e>', '<c-w>k', 'Window up' },
	{ '<c-m>', '<c-w>h', 'Window left' },
	{ '<c-i>', '<c-w>l', 'Window right' },

	-- window split
	{ '<m-m>', require('utils.window.split').split('left'), 'Split window left' },
	{ '<m-i>', require('utils.window.split').split('right'), 'Split window right' },
	{ '<m-e>', require('utils.window.split').split('above'), 'Split window above' },
	{ '<m-n>', require('utils.window.split').split('below'), 'Split window below' },

	-- LSP
	{ '<leader>ne', vim.lsp.buf.rename, 'Rename' },
	{ '<leader>no', utils.lsp.action["source.organizeImports"], 'Organize imports' },
	{ '<leader>nt', function ()
		vim.lsp.buf.code_action({ context = { only = { 'quickfix' } } })
	end, 'Code actions quickfix' },
	{ '<leader>ns', function ()
		vim.lsp.buf.code_action({ context = { only = { 'refactor' } } })
	end, 'Code actions refactor' },
	{ 'I', vim.lsp.buf.hover, 'LSP hover info' },
	{ ']d', function() vim.diagnostic.jump({ count = 1, float = true }) end, 'Next diagnostic' },
	{ '[d', function() vim.diagnostic.jump({ count = -1, float = true }) end, 'Previous diagnostic' },

	-- File path
	{ '<leader>yy', clipboard.copy_file_path, 'Copy file path to clipboard' },
	{ '<leader>yn', clipboard.copy_file_name, 'Copy file name to clipboard' },

	-- package manager
	{ '<leader>oo', function () vim.pack.update() end, "Update packages" },
	{ '<leader>on', function () vim.pack.update(nil, { target = 'lockfile' }) end, "Restore packages to lockfile" },
	{ '<leader>ot', function ()
    local pkgs = vim.iter(vim.pack.get())
     :filter(function(x) return not x.active end)
     :map(function(x) return x.spec.name end)
     :totable()

		if(#pkgs == 0) then
			vim.notify('No unused packages', vim.log.levels.WARN)
			return
		end

		vim.pack.del(pkgs)
	end, "Remove unused packages" },
	-- { '<leader>on', function () require('utils.pack').pick_pkg_to_update() end, "Update packages" }
})

-- insert mode keymaps
imap({
	{ '<c-c>', escape, 'Escape' },
	{ '<c-s>', '<cmd>silent w<cr>', 'Save the file' },
	{ '<c-v>', '<esc>pa', 'Paste' },
	{ '<m-a>', '<esc>I', '(Insert) Jump to line start' },
	{ '<m-e>', '<esc>A', '(Insert) Jump to line end' },
	{ '<m-h>', '<esc>O', 'Insert new line below' },
	{ '<m-k>', '<esc>ddi', 'Delete current line' },
	{ '<m-y>', duplicate_line, 'Duplicate current line' },
})

-- terminal mode keymaps
tmap({
	{ 'yy', '<C-\\><C-n>', 'Exit terminal mode' },
	{ '<c-q>', '<cmd>quit<cr>', 'Quit terminal window' },
})

-- visual mode keymaps
vmap({
	{ 'p', 'P', 'Paste yanked text' },
	{ '$', 'g_', 'Select until end of line' },
})

-- opencode
local nxmap = mapper({ 'n', 'x' })

-- stylua: ignore
nmap({
	{ ',a', function() require('utils.ai').toggle() end, 'Toggle AI' },
})

-- stylua: ignore
nxmap({
	{ ',r', '<cmd>PromptAI<cr>', 'Ask AI' },
})

-- git
nmap({
	{
		'<leader>is',
		function()
			require('utils.git').checkout_file_to_origin_default_state()
		end,
		'Reset file to default state',
	},
})

-- neovim has x mode in keymap for vim.lsp.buf.selection_range
-- I don't really need that and keymap and this collides with coleman move right
-- in visual mode keymap
vim.keymap.del('x', 'in')
