local M = {}
local formatter = require('utils.formatter')

local state = {
	buf = nil,
	chan = nil,
}

local function is_valid()
	return state.buf and vim.api.nvim_buf_is_valid(state.buf)
end

local function get_win_config()
	local width = math.floor(vim.o.columns * 0.95)
	local height = vim.o.lines - 1
	local col = math.floor((vim.o.columns - width) / 2)
	return {
		relative = 'editor',
		width = width,
		height = height,
		col = col,
		row = 0,
		style = 'minimal',
		border = 'rounded',
	}
end

local function find_existing_win()
	if not is_valid() then
		return nil
	end
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(win) == state.buf then
			return win
		end
	end
	return nil
end

local function close_win()
	local win = find_existing_win()
	if win then
		vim.api.nvim_win_close(win, false)
	end
end

local function set_buf_keymaps(buf)
	local opts = { buffer = buf, noremap = true, silent = true }
	vim.keymap.set('t', '<c-c>', close_win, opts)
end

local function create_terminal(cmd)
	state.buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_set_option_value('filetype', 'opencode', { buf = state.buf })
	vim.api.nvim_open_win(state.buf, true, get_win_config())
	state.chan = vim.fn.termopen(cmd)
	set_buf_keymaps(state.buf)
	vim.cmd('startinsert')
end

function M.toggle()
	local existing_win = find_existing_win()
	if existing_win then
		vim.api.nvim_win_close(existing_win, false)
		return
	end

	if is_valid() then
		vim.api.nvim_open_win(state.buf, true, get_win_config())
		vim.cmd('startinsert')
		return
	end

	create_terminal('opencode')
end

function M.send_prompt(input)
	local formatted = formatter.format_opencode_prompt(input)

	if is_valid() and state.chan then
		vim.fn.chansend(state.chan, formatted)
		-- vim.fn.chansend(state.chan, '\r\n')
		M.toggle()
		return
	end

	create_terminal({ 'opencode', '--prompt', formatted })
end

return M
