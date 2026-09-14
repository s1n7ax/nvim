---@class TUIKeymap
---@field mode string|string[]
---@field lhs string
---@field rhs string|function
---@field opts? vim.keymap.set.Opts

---@class TUI
---@field cmd string[]
---@field buf number|nil
---@field ft string
---@field chan number|nil
---@field keymaps TUIKeymap[]
---@field insert boolean|nil whether the window was last used in terminal mode
local float = require('utils.window.float')

local M = {}

---@param args { cmd: string[], ft?: string }
function M:new(args)
	local o = {
		cmd = args.cmd,
		ft = args.ft or args.cmd[1],
		keymaps = {},
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
		self:reset()
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

	self.open_win(self.buf, position, self.insert)
end

---@param input? string
---@param position? TUIPosition
function M:create_term(input, position)
	self.buf = vim.api.nvim_create_buf(false, true)
	vim.bo[self.buf].filetype = self.ft
	self:apply_keymaps()
	self:track_mode()
	self.open_win(self.buf, position)
	local cmd = vim.list_extend(vim.list_extend({}, self.cmd), { input })
	local ok, chan = pcall(vim.fn.jobstart, cmd, { term = true })

	if not ok then
		vim.cmd('stopinsert')
		vim.api.nvim_buf_delete(self.buf, { force = true })
		self:reset()
		vim.notify(chan, vim.log.levels.ERROR)
		return
	end

	self.chan = chan
end

---@private
function M:reset()
	self.buf = nil
	self.chan = nil
	self.insert = nil
end

---Record whether the window is used in terminal or normal mode. The check is
---deferred a tick so that leaving terminal mode only as a side effect of
---leaving the window (mouse click, `<C-\><C-o><C-w>h`, a `<C-\><C-n><C-w>h`
---mapping) keeps terminal mode. Closing the window records nothing, so the
---last mode used inside it is what gets restored
---@private
function M:track_mode()
	vim.api.nvim_create_autocmd('ModeChanged', {
		buffer = self.buf,
		callback = function()
			vim.schedule(function()
				if vim.api.nvim_get_current_buf() ~= self.buf then
					return
				end

				local mode = vim.fn.mode(1)

				if mode == 't' or mode == 'nt' then
					self.insert = mode == 't'
				end
			end)
		end,
	})
end

---@param buf number
---@param position? TUIPosition
---@param insert? boolean enter terminal mode, defaults to true
function M.open_win(buf, position, insert)
	position = position or 'float'

	if position == 'float' then
		vim.api.nvim_open_win(buf, true, M.get_win_config())
	else
		-- Go to leftmost or rightmost window first
		vim.cmd('wincmd ' .. (position == 'left' and 'H' or 'L'))
		local win = vim.api.nvim_open_win(buf, true, { split = position })
		vim.wo[win].winfixwidth = true
	end

	if insert ~= false then
		vim.cmd('startinsert')
	end
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
	return float.config(math.floor(vim.o.columns * 0.95), vim.o.lines - 1)
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

---@param mode string|string[]
---@param lhs string
---@param rhs string|function
---@param opts? vim.keymap.set.Opts
function M:map(mode, lhs, rhs, opts)
	table.insert(self.keymaps, { mode = mode, lhs = lhs, rhs = rhs, opts = opts })
end

---@private
function M:apply_keymaps()
	if not self.buf then
		return
	end

	for _, km in ipairs(self.keymaps) do
		local opts = vim.tbl_extend('force', km.opts or {}, { buffer = self.buf })
		vim.keymap.set(km.mode, km.lhs, km.rhs, opts)
	end
end

return M
