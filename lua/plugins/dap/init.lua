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

---@type { height: integer, width: integer }?
local saved_win_min

--- Opens the UI from a clean state.
--- dap-ui stacks one split per element, which fails with `E36: Not enough room`
--- against the large `winminheight`/`winminwidth` that utils.window.focus sets.
--- A failed split leaves the layout half-built and every later open then errors
--- with "Invalid 'win': Expected Lua number", so relax the minimums while the UI
--- is up and close first so each attempt starts fresh.
local function open_dapui()
	dapui.close()

	if not saved_win_min then
		saved_win_min = { height = vim.o.winminheight, width = vim.o.winminwidth }
	end
	vim.o.winminheight = 1
	vim.o.winminwidth = 1

	local ok, err = pcall(dapui.open)
	if not ok then
		vim.notify('dap-ui: ' .. tostring(err), vim.log.levels.WARN)
	end
end

--- Closes the UI and restores the window minimums taken by `open_dapui`.
local function close_dapui()
	dapui.close()

	if saved_win_min then
		vim.o.winminheight = saved_win_min.height
		vim.o.winminwidth = saved_win_min.width
		saved_win_min = nil
	end
end

-- Auto open/close UI
dap.listeners.after.event_initialized['dapui_config'] = function()
	open_dapui()
end
dap.listeners.before.event_terminated['dapui_config'] = function()
	close_dapui()
end
dap.listeners.before.event_exited['dapui_config'] = function()
	close_dapui()
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
