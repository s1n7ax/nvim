local utils = require('utils')
local mapper = utils.mapper
local normal_map = mapper('n')

-- stylua: ignore
normal_map({
	{ '<leader>ee', '<cmd>OverseerRun<cr>', 'Run task' },
	{ '<leader>en', '<cmd>OverseerToggle<cr>', 'Task list' },
	{ '<leader>et', '<cmd>OverseerQuickAction<cr>', 'Action recent task' },
	{ '<leader>es', '<cmd>OverseerLoadBundle<cr>', 'Load bundle' },
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
