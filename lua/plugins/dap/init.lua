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

--- Opens the UI from a clean state.
--- `dapui.open()` leaves the layout half-built when a split fails with E36
--- (not enough room, e.g. neotest windows are taking up the screen), and every
--- later open then errors with "Invalid 'win': Expected Lua number". Closing
--- first resets the tracked windows so each attempt starts fresh.
local function open_dapui()
	dapui.close()
	local ok, err = pcall(dapui.open)
	if not ok then
		vim.notify('dap-ui: ' .. tostring(err), vim.log.levels.WARN)
	end
end

-- Auto open/close UI
dap.listeners.after.event_initialized['dapui_config'] = function()
	open_dapui()
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
	{ '<leader>di', function() dap.step_into() end, 'Step into' },
	{ '<leader>de', function() dap.step_out() end, 'Step out' },

	-- breakpoints
	{ '<leader>do', function() dap.toggle_breakpoint() end, 'Toggle breakpoint' },
	{ '<leader>dO', function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, 'Conditional breakpoint' },

	-- ui & info
	{ '<leader>du', function() dapui.toggle() end, 'Toggle DAP UI' },
	{ '<leader>dh', function() dap.repl.open() end, 'Open REPL' },
	{ '<leader>dl', function() dap.run_last() end, 'Run last' },

	-- terminate
	{ '<leader>dt', function() dap.terminate() end, 'Terminate' },
})
