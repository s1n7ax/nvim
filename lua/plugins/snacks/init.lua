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
	{ ',a', snacks.zen, 'Zen mode' },
	{ '<leader>/', open_grep, 'Find text' },
	{ '<leader>nn', snacks.picker.lines, 'Find lines' },
	{ '<leader>nt', snacks.picker.diagnostics, 'Find diagnostics' },
	{ '<leader>ns', snacks.picker.git_branches, 'Find git branches' },
	{ '<leader>nr', snacks.picker.lsp_workspace_symbols, 'Find workspace symbols', },
	{ '<leader>na', snacks.picker.keymaps, 'Find keymaps' },
	{ '<leader>ne', snacks.picker.commands, 'Find commands' },
	{ '<leader>ni', snacks.picker.lsp_symbols, 'Find symbols' },
	{ '<leader>no', snacks.picker.buffers, 'Find symbols' },
	{ '<leader>nh', snacks.picker.help, 'Find help' },

	-- lsp keymaps
	{ 'gd', snacks.picker.lsp_definitions, "Goto Definition" },
	{ 'gri', snacks.picker.lsp_implementations, "Goto Implementation" },
	{ 'grr', snacks.picker.lsp_references, { desc = "References", nowait = true } },
})

require('snacks').setup({
	bigfile = { enabled = true },
	dashboard = { enabled = false },
	explorer = { enabled = false },
	indent = { enabled = false },
	input = { enabled = true },
	notifier = { enabled = false },
	quickfile = { enabled = false },
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
