local formatter = require('utils.formatter')
local snacks = require('snacks')
local utils = require('utils.keymaps')
local nmap = utils.mapper('n')
local nxmap = utils.mapper({ 'n', 'x' })

local WIDTH = 0.7
local HEIGHT = 0.9

local open_grep = function()
	snacks.picker.grep()
end

-- stylua: ignore
local open_files = function()
	snacks.picker.smart({ hidden = true, ignored = false, filter = { cwd = true } })
end

-- stylua: ignore
nmap({
	{ ',,', open_files, 'Find files' },
	{ ',p', function() snacks.zen() end, 'Zen mode' },
	{ '<leader>/', open_grep, 'Find text' },

	{ '<leader>tn', snacks.picker.lines, 'Find lines' },
	{ '<leader>te', snacks.picker.commands, 'Find commands' },
	{ '<leader>ti', snacks.picker.lsp_symbols, 'Find symbols' },
	-- { '<leader>to', snacks.picker.buffers, 'Find buffers' },
	{ "<leader>tl", snacks.picker.lsp_type_definitions, "Find type definition" },
	{ "<leader>tp", snacks.picker.colorschemes, "Find colorschemes" },

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
	{ ',s', function () snacks.lazygit() end, "Open lazygit" },
	{ ',a', function () snacks.terminal.toggle('opencode') end, "Open opencode" },

	-- gh
	{ '<leader>ir', function () snacks.picker.gh_pr() end, "GitHub Pull Requests (open)" },

	-- file
	-- { ',t', function() snacks.explorer.reveal() end, "Explorer"  },

	{ "<leader>us",  function() snacks.scratch() end, desc = "Toggle Scratch Buffer" },
	{ "<leader>to",  function() snacks.scratch.select() end, desc = "Select Scratch Buffer" },

})

nxmap({
	{
		',r',
		function()
			vim.ui.input({ prompt = 'Send to OpenCode' }, function(input)
				local formatted_input = formatter.format_opencode_prompt(input)
				local term_list = snacks.terminal.list()

				for _, v in ipairs(term_list) do
					if vim.islist(v.cmd) then
						if v.cmd[1] == 'opencode' then
							local job = vim.b[v.buf].terminal_job_id
							vim.fn.chansend(job, formatted_input)
							v:show()
							return
						end
					elseif string.find(v.cmd, '^opencode') then
						local job = vim.b[v.buf].terminal_job_id
						vim.fn.chansend(job, formatted_input)
						v:show()
						return
					end
				end

				snacks.terminal.open({ 'opencode', '--prompt', formatted_input })
			end)
		end,
		'Opencode',
	},
})

require('snacks').setup({
	bigfile = { enabled = true },
	dashboard = { enabled = false },
	explorer = {
		enabled = false,
		replace_netrw = true,
		trash = true,
	},
	indent = { enabled = false },
	input = { enabled = true },
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
		sources = {
			explorer = {
				hidden = true,
				ignored = true,
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
