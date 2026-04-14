local context = require('utils.context')
local TUI = require('utils').tui

local M = {}

local ai = TUI:new({ cmd = { 'claude' } })
-- local ai = TUI:new({ cmd = { 'opencode', '--prompt' } })

ai:map('t', ',t', function()
	if M.ctx ~= '' then
		ai:send_prompt(M.ctx)
	end
end, { desc = 'Insert file context' })

function M.toggle()
	ai:toggle()
end

function M.toggle_right()
	ai:toggle(nil, 'right')
end

function M.setup_cmd()
	---@see https://github.com/neovim/neovim/discussions/26092
	vim.api.nvim_create_user_command('PromptAI', function(opts)
		M.ctx = context.get_curr_context(opts)
		local position = opts.fargs[1]
		ai:toggle(nil, position)
	end, { range = true, nargs = '?' })
end

return M
