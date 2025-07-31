local utils = require('utils')
local mapper = utils.mapper
local nmap = mapper('n')

-- stylua: ignore
nmap({
	{ '<leader>r', '', '+Rest' },
	{ '<leader>ra', function() require('kulala').run_all() end, 'Send all requests', },
	{ '<leader>rs', function() require('kulala').run() end, 'Send the request', },
	{ '<leader>rt', function() require('kulala').toggle_view() end, 'Toggle headers/body', },
	{ '<leader>re', function() require('kulala').jump_prev() end, 'Jump to previous request', },
	{ '<leader>rn', function() require('kulala').jump_next() end, 'Jump to next request', },
})

require('kulala').setup({
	default_view = 'headers_body',
	icons = {
		inlay = {
			loading = '',
			done = '',
			error = '',
		},
	},
})
