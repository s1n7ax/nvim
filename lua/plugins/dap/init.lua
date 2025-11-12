local utils = require('utils')
local mapper = utils.mapper
local nmap = mapper('n')

local dap = require('dap')
local dapui = require('dapui')

-- DAP UI setup
dapui.setup()

-- Load debug adapters
require('plugins.dap.adapters')

-- Breakpoint signs
vim.fn.sign_define('DapBreakpoint', {
	text = '●',
	texthl = 'DiagnosticError',
	linehl = '',
	numhl = '',
})
vim.fn.sign_define('DapBreakpointCondition', {
	text = '◆',
	texthl = 'DiagnosticWarn',
	linehl = '',
	numhl = '',
})
vim.fn.sign_define('DapStopped', {
	text = '→',
	texthl = 'DiagnosticInfo',
	linehl = 'CursorLine',
	numhl = '',
})

-- Auto open/close UI
dap.listeners.after.event_initialized['dapui_config'] = function()
	dapui.open()
end
dap.listeners.before.event_terminated['dapui_config'] = function()
	dapui.close()
end
dap.listeners.before.event_exited['dapui_config'] = function()
	dapui.close()
end

-- stylua: ignore
nmap({
	-- primary controls (home row priority)
	{ '<leader>dd', function() dap.continue() end, 'Continue/Start debugging' },
	{ '<leader>dn', function() dap.step_over() end, 'Step over' },
	{ '<leader>ds', function() dap.step_into() end, 'Step into' },
	{ '<leader>dr', function() dap.step_out() end, 'Step out' },

	-- breakpoints
	{ '<leader>db', function() dap.toggle_breakpoint() end, 'Toggle breakpoint' },
	{ '<leader>dB', function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, 'Conditional breakpoint' },

	-- ui & info
	{ '<leader>du', function() dapui.toggle() end, 'Toggle DAP UI' },
	{ '<leader>di', function() dap.repl.open() end, 'Open REPL' },
	{ '<leader>dl', function() dap.run_last() end, 'Run last' },

	-- terminate
	{ '<leader>dT', function() dap.terminate() end, 'Terminate' },
})
