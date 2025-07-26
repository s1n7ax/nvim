vim.pack.add({ 'https://github.com/stevearc/overseer.nvim' })

local utils = require('utils')
local mapper = utils.mapper
local normal_map = mapper('n')

-- stylua: ignore
normal_map({
	{ '<leader>ow', '<cmd>OverseerToggle<cr>', 'Task list' },
	{ '<leader>oo', '<cmd>OverseerRun<cr>', 'Run task' },
	{ '<leader>oq', '<cmd>OverseerQuickAction<cr>', 'Action recent task' },
	{ '<leader>oi', '<cmd>OverseerInfo<cr>', 'Overseer Info' },
	{ '<leader>ob', '<cmd>OverseerBuild<cr>', 'Task builder' },
	{ '<leader>ot', '<cmd>OverseerTaskAction<cr>', 'Task action' },
	{ '<leader>oc', '<cmd>OverseerClearCache<cr>', 'Clear cache' },
	{ '<leader>ol', '<cmd>OverseerLoadBundle<cr>', 'Load bundle' },
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

