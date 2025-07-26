vim.pack.add({ 'https://github.com/folke/snacks.nvim' })

local logo = require('plugins.snacks.logo')

---@class snacks.dashboard.Config
local dashboard = {
	enabled = false,
	preset = {
		header = logo,
	},
}

local open_explorer = function()
	require('snacks').picker.explorer({
		hidden = true,
		ignored = true,
	})
end

local open_grep = function()
	require('snacks').picker.grep({
		hidden = true,
		ignored = false,
	})
end

local open_files = function()
	require('snacks').picker.files({
		hidden = true,
		ignored = false,
	})
end

-- vim.keymap.set('n', '<leader>e', explorer)
vim.keymap.set('n', ',,', open_files, { desc = 'Find Files' })
vim.keymap.set('n', '<leader>/', open_grep, { desc = 'Find Text' })

require('snacks').setup({
	dashboard = dashboard,
	bigfile = { enabled = true },
	notifier = { enabled = true },
	quickfile = { enabled = true },
	statuscolumn = { enabled = true },
	words = { enabled = true },
	scope = { enabled = false },
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
			style = {
				backdrop = { transparent = false },
			},
			width = 100,
		},
	},
})
