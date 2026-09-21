local utils = require('utils.keymaps')
local nmap = utils.mapper('n')

local WIDTH = 0.7
local HEIGHT = 0

local open_grep = function()
	Snacks.picker.grep()
end

-- stylua: ignore
local open_files = function()
	Snacks.picker.smart({ filter = { cwd = true } })
end

--- Wraps a `Snacks.picker` source so that indexing it - which pulls in the
--- picker module - happens on the keypress rather than while mapping.
local function picker(source)
	return function()
		Snacks.picker[source]()
	end
end

-- stylua: ignore
nmap({
	{ ',,', open_files, 'Find files' },
	{ ',p', function() Snacks.zen() end, 'Zen mode' },
	{ '<leader>/', open_grep, 'Find text' },

	{ '<leader>tn', picker('lines'), 'Find lines' },
	{ '<leader>te', picker('commands'), 'Find commands' },
	{ '<leader>ti', picker('lsp_symbols'), 'Find symbols' },
	-- { '<leader>to', snacks.picker.buffers, 'Find buffers' },
	{ "<leader>tl", picker('lsp_type_definitions'), "Find type definition" },
	{ "<leader>tp", picker('colorschemes'), "Find colorschemes" },

	{ '<leader>tt', picker('diagnostics'), 'Find diagnostics' },
	{ '<leader>ts', picker('git_branches'), 'Find git branches' },
	{ '<leader>tr', picker('lsp_workspace_symbols'), 'Find workspace symbols', },
	{ '<leader>ta', picker('keymaps'), 'Find keymaps' },
	{ '<leader>th', picker('help'), 'Find help' },

	{ '<leader>tf', picker('files'), 'Find help' },

	-- lsp keymaps
	{ '<leader>nn', picker('lsp_definitions'), "Goto Definition" },
	{ '<leader>ni', picker('lsp_references'), { desc = "References", nowait = true } },
	{ '<leader>nr', picker('lsp_implementations'), "Goto Implementation" },
	{ "<leader>na", picker('lsp_type_definitions'), "Goto T[y]pe Definition" },

	-- git
	{ ',s', function () Snacks.lazygit() end, "Open lazygit" },

	-- gh
	{ '<leader>er', function () Snacks.picker.gh_pr() end, "GitHub Pull Requests (open)" },

	-- file
	{ ',t', function() Snacks.explorer.reveal() end, "Explorer"  },

	{ "<leader>us",  function() Snacks.scratch() end, { desc = "Toggle Scratch Buffer" }},
	{ "<leader>to",  function() Snacks.scratch.select() end, { desc = "Select Scratch Buffer" } },

})

---@type snacks.Config
require('snacks').setup({
	bigfile = { enabled = true },
	dashboard = { enabled = false },
	explorer = {
		enabled = false,
		replace_netrw = true,
		trash = true,
	},
	indent = { enabled = false },
	input = {
		enabled = true,
		win = {
			keys = {
				cc_cancel = {
					'<c-c>',
					{ 'cmp_close', 'cancel' },
					mode = 'n',
					expr = true,
				},
				cc_cancel_i = {
					'<c-c>',
					{ 'cmp_close', 'stopinsert', 'cancel' },
					mode = 'i',
					expr = true,
				},
			},
		},
	},
	notifier = { enabled = false },
	quickfile = { enabled = true },
	scope = { enabled = false },
	scroll = { enabled = false },
	statuscolumn = { enabled = true },
	words = { enabled = true },
	lazygit = {
		enabled = true,
		win = {
			width = 0,
			height = HEIGHT,
		},
	},
	picker = {
		matcher = {
			frecency = true,
			history_bonus = true,
		},
		formatters = {
			file = {
				filename_first = true,
			},
		},
		sources = {
			explorer = {
				hidden = false,
				ignored = false,
				win = {
					list = {
						keys = {
							['h'] = 'focus_input',
							['<c-c>'] = 'cancel',
							['<c-h>'] = 'toggle_hidden',
							['<c-i>'] = 'toggle_ignored',
						},
					},
				},

				auto_close = true,
				layout = {
					cycle = false,
					preset = 'dropdown',
					layout = {
						width = WIDTH,
						height = HEIGHT,
					},
				},
			},
		},

		layout = {
			preset = 'default',
			layout = {
				width = 0,
				height = HEIGHT,
			},
		},

		win = {
			input = {
				keys = {
					['<c-n>'] = { 'list_down', mode = { 'i', 'n' } },
					['<c-e>'] = { 'list_up', mode = { 'i', 'n' } },
					['<c-h>'] = { 'toggle_hidden', mode = { 'i', 'n' } },
					['<c-i>'] = { 'toggle_ignored', mode = { 'i', 'n' } },
				},
			},
			list = {
				keys = {
					['n'] = 'list_down',
					['e'] = 'list_up',
					['<c-c>'] = 'cancel',
					['<c-q>'] = 'close',
					['h'] = 'focus_input',
					['<c-h>'] = 'toggle_hidden',
					['<c-i>'] = 'toggle_ignored',
				},
			},
			preview = {
				keys = {
					['<c-c>'] = 'cancel',
				},
			},
		},
	},
	scratch = {},
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
