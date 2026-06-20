local utils = require('utils')
local mapper = utils.mapper
local nmap = mapper('n')

-- stylua: ignore
nmap({
	{ '<leader>ie', '<cmd>OverseerRun<cr>', 'Run task' },
	{ '<leader>in', '<cmd>OverseerToggle<cr>', 'Task list' },
	{ '<leader>ii', '<cmd>OverseerShell<cr>', 'Run task' },
	{ '<leader>it', '<cmd>OverseerQuickAction<cr>', 'Action recent task' },
	{ '<leader>is', '<cmd>OverseerLoadBundle<cr>', 'Load bundle' },
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
