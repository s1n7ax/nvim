local context = require('utils.context')
local TUI = require('utils').tui

local claude = TUI:new({ cmd = { 'claude' } })

local M = {}

function M.toggle()
	claude:toggle()
end

function M.setup_cmd()
	---@see https://github.com/neovim/neovim/discussions/26092
	vim.api.nvim_create_user_command('PromptAI', function(opts)
		local ctx = context.get_curr_context(opts)

		vim.ui.input({ prompt = 'Send to AI' }, function(input)
			if input then
				input = input:gsub('@this', ctx)
				input = input:gsub('@here', ctx)
				claude:toggle(input)
			end
		end)
	end, { range = true })
end

return M
