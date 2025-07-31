local utils = require('utils')
local mapper = utils.mapper
local normal_map = mapper('n')

-- stylua: ignore
normal_map({
	{ '<leader>ee', '<cmd>OverseerToggle<cr>', 'Task list' },
	{ '<leader>en', '<cmd>OverseerRun<cr>', 'Run task' },
	{ '<leader>ei', '<cmd>OverseerQuickAction<cr>', 'Action recent task' },
	{ '<leader>et', '<cmd>OverseerInfo<cr>', 'Overseer Info' },
	{ '<leader>es', '<cmd>OverseerBuild<cr>', 'Task builder' },
	{ '<leader>er', '<cmd>OverseerTaskAction<cr>', 'Task action' },
	{ '<leader>ea', '<cmd>OverseerClearCache<cr>', 'Clear cache' },
	{ '<leader>el', '<cmd>OverseerLoadBundle<cr>', 'Load bundle' },
})

require('overseer').setup({
	task_list = {
		bindings = {
			['<C-q>'] = false,
			['<C-e>'] = false,
		},
	},
	task_launcher = {
		bindings = {
			i = {
				['<C-c>'] = false,
			},
		},
	},
	task_editor = {
		bindings = {
			i = {
				['<C-c>'] = false,
			},
		},
	},
})

