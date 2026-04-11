---@class TUI
---@field cmd string[]
---@field buf number|nil
---@field ft string
---@field chan number|nil
local M = {}

---@param args { cmd: string[], ft?: string }
function M:new(args)
	local o = {
		cmd = args.cmd,
		ft = args.ft or args.cmd[1],
	}
	setmetatable(o, self)
	self.__index = self
	return o
end

---@alias TUIPosition 'float' | 'left' | 'right'

---@param input? string
---@param position? TUIPosition
function M:toggle(input, position)
	position = position or 'float'

	if type(input) == 'string' then
		input = input:gsub('^%s*(.-)%s*$', '%1')
	end

	if not self.buf or not vim.api.nvim_buf_is_valid(self.buf) then
		self.buf = nil
		self.chan = nil
		return self:create_term(input, position)
	end

	local win = self.find_winid_for_buf(self.buf)

	if win then
		return self:close_term()
	else
		self:open_term_buf_in_win(position)

		if type(input) == 'string' and input ~= '' then
			self:send_prompt(input)
		end
	end
end

---@param position? TUIPosition
function M:open_term_buf_in_win(position)
	if not self.buf then
		return
	end

	self.open_win(self.buf, position)
end

---@param input? string
---@param position? TUIPosition
function M:create_term(input, position)
	self.buf = vim.api.nvim_create_buf(false, true)
	vim.bo[self.buf].filetype = self.ft
	self.open_win(self.buf, position)
	local cmd = vim.list_extend(vim.list_extend({}, self.cmd), { input })
	self.chan = vim.fn.jobstart(cmd, { term = true })
	vim.cmd('startinsert')
end

---@param buf number
---@param position? TUIPosition
function M.open_win(buf, position)
	position = position or 'float'

	if position == 'float' then
		vim.api.nvim_open_win(buf, true, M.get_win_config())
	else
		-- Go to leftmost or rightmost window first
		vim.cmd('wincmd ' .. (position == 'left' and 'H' or 'L'))
		vim.api.nvim_open_win(buf, true, { split = position })
	end

	vim.cmd('startinsert')
end

function M:close_term()
	if not self.buf then
		return
	end

	local win = self.find_winid_for_buf(self.buf)

	if not win or not vim.api.nvim_win_is_valid(win) then
		return
	end

	vim.api.nvim_win_close(win, false)
end

function M.get_win_config()
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

---@private
---@param buf number
---@return integer|nil
function M.find_winid_for_buf(buf)
	if not vim.api.nvim_buf_is_valid(buf) then
		return
	end

	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(win) == buf then
			return win
		end
	end
end

function M:send_prompt(input)
	if not self.chan then
		return
	end

	vim.fn.chansend(self.chan, input)
end

return M
