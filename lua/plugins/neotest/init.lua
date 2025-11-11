local utils = require('utils')
local mapper = utils.mapper
local nmap = mapper('n')

require('neotest').setup({
	adapters = {
		require('neotest-jest'),
		require('neotest-vitest'),
	},
})


-- stylua: ignore
nmap({
	{ '<leader>ss', function() require("neotest").run.run({strategy = "dap"}) end, 'Run current test', },
	{ '<leader>sr', function() require("neotest").run.run_last({strategy = "dap"}) end, 'Run last test', },
	{ '<leader>st', function() require("neotest").run.run(vim.fn.expand("%")) end, 'Run current test file', },
	{ '<leader>sS', function() require("neotest").run.stop() end, 'Stop current test', },

	{ '<leader>sn', function() require("neotest").jump.next() end, 'Jump to next test', },
	{ '<leader>se', function() require("neotest").jump.prev() end, 'Jump to previous test', },

	{ '<leader>sa', function() require("neotest").output.open() end, 'Open test output', },
	{ '<leader>so', function() require("neotest").summary.open() end, 'Open test summary', },
})
