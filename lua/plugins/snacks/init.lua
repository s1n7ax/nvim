local snacks = require('snacks')
local utils = require('utils.keymaps')
local nmap = utils.mapper('n')

local open_grep = function()
	snacks.picker.grep({ hidden = true, ignored = false, regex = false })
end

-- stylua: ignore
local open_files = function()
	snacks.picker.smart({ hidden = true, ignored = false, filter = { cwd = true } })
end

-- stylua: ignore
nmap({
	{ ',,', open_files, 'Find files' },
	{ ',a', function() snacks.zen() end, 'Zen mode' },
	{ '<leader>/', open_grep, 'Find text' },

	{ '<leader>tn', snacks.picker.lines, 'Find lines' },
	{ '<leader>te', snacks.picker.commands, 'Find commands' },
	{ '<leader>ti', snacks.picker.lsp_symbols, 'Find symbols' },
	{ '<leader>to', snacks.picker.buffers, 'Find buffers' },
	{ "<leader>tl", snacks.picker.lsp_type_definitions, desc = "Find type definition" },

	{ '<leader>tt', snacks.picker.diagnostics, 'Find diagnostics' },
	{ '<leader>ts', snacks.picker.git_branches, 'Find git branches' },
	{ '<leader>tr', snacks.picker.lsp_workspace_symbols, 'Find workspace symbols', },
	{ '<leader>ta', snacks.picker.keymaps, 'Find keymaps' },
	{ '<leader>th', snacks.picker.help, 'Find help' },

	{ '<leader>tf', snacks.picker.files, 'Find help' },

	-- lsp keymaps
	{ '<leader>nn', snacks.picker.lsp_definitions, "Goto Definition" },
	{ '<leader>ni', snacks.picker.lsp_references, { desc = "References", nowait = true } },
	{ '<leader>nr', snacks.picker.lsp_implementations, "Goto Implementation" },

	-- git
	{ '<leader>is', function () snacks.lazygit() end, "Open lazygit" }
})

require('snacks').setup({
	bigfile = { enabled = true },
	dashboard = { enabled = false },
	explorer = { enabled = false },
	indent = { enabled = false },
	input = { enabled = true },
	notifier = { enabled = false },
	quickfile = { enabled = true },
	scope = { enabled = false },
	scroll = { enabled = false },
	statuscolumn = { enabled = true },
	words = { enabled = true },
	picker = {
		sources = {
			explorer = {
				win = {
					list = {
						keys = {
							['h'] = 'focus_input',
							['<c-c>'] = 'cancel',
						},
					},
				},
				auto_close = true,
				layout = {
					preset = 'select',
					layout = {
						width = 0.8,
						height = 0.8,
					},
				},
			},
		},

		win = {
			input = {
				keys = {
					['<c-n>'] = { 'list_down', mode = { 'i', 'n' } },
					['<c-e>'] = { 'list_up', mode = { 'i', 'n' } },
				},
			},
			list = {
				keys = {
					['n'] = 'list_down',
					['e'] = 'list_up',
					['<c-c>'] = 'cancel',
					['<c-q>'] = 'close',
					['h'] = 'focus_input',
				},
			},
			preview = {
				keys = {
					['<c-c>'] = 'cancel',
				},
			},
		},
	},

	---@class snacks.zen.Config
	zen = {
		toggles = {
			dim = false,
		},
		win = {
			style = { backdrop = { transparent = false } },
		},
	},
})
