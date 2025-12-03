local utils = require('utils')
local mapper = utils.mapper
local nmap = mapper('n')

-- stylua: ignore
nmap({
	{ '<leader>ee', '<cmd>OverseerRun<cr>', 'Run task' },
	{ '<leader>en', '<cmd>OverseerToggle<cr>', 'Task list' },
	{ '<leader>et', '<cmd>OverseerQuickAction<cr>', 'Action recent task' },
	{ '<leader>es', '<cmd>OverseerLoadBundle<cr>', 'Load bundle' },
})

require('overseer').setup({
	task_list = {
		keymaps = {
			['<C-q>'] = { '<CMD>close<CR>', desc = 'Close task list' },
			['<C-e>'] = false,
		},
	},
	task_launcher = {
		keymaps = {
			i = {
				['<C-q>'] = { '<CMD>close<CR>', desc = 'Close task list' },
				['<C-c>'] = false,
			},
		},
	},
	task_editor = {
		keymaps = {
			i = {
				['<C-q>'] = { '<CMD>close<CR>', desc = 'Close task list' },
				['<C-c>'] = false,
			},
		},
	},
})
