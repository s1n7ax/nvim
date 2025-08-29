local utils = require('utils.keymaps')
local nmap = utils.mapper('n')

-- stylua: ignore
nmap({
	{ '<leader>mn', function() require('noice').cmd('last') end, 'Show last message', },
	{ '<leader>mh', function() require('noice').cmd('history') end, 'Show message history', },
	{ '<leader>mm', function() require('noice').cmd('all') end, 'Show all messages', },
})

require('noice').setup({
	cmdline = {
		enabled = true,
		view = 'cmdline_popup',
		opts = {
			position = {
				row = '10%',
				col = '50%',
			},
		},
	},
})
