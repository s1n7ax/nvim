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
---@field on_create? fun(buf: number) called with the new buffer before it is shown
local float = require('utils.window.float')

local M = {}

---@param args { cmd: string[], ft?: string, on_create?: fun(buf: number) }
function M:new(args)
	local o = {
		cmd = args.cmd,
		ft = args.ft or args.cmd[1],
		keymaps = {},
		on_create = args.on_create,
	}
	setmetatable(o, self)
	self.__index = self
	return o
end

---@alias TUIPosition 'float' | 'left' | 'right'

---@param position? TUIPosition
function M:open_term_buf_in_win(position)
	if not self.buf then
		return
	end

	self.open_win(self.buf, position, self.insert)
end

---Start the terminal in a new window at `position`, or in `win` when given
---@param position? TUIPosition
---@param win? number existing window to start it in
function M:create_term(position, win)
	---checked before `open_win` rearranges the layout
	if vim.fn.executable(self.cmd[1]) ~= 1 then
		vim.notify(self.cmd[1] .. ' is not executable', vim.log.levels.ERROR)
		return
	end

	self.buf = vim.api.nvim_create_buf(false, true)
	vim.bo[self.buf].filetype = self.ft
	self:apply_keymaps()
	self:track_mode()

	if self.on_create then
		self.on_create(self.buf)
	end

	if win then
		vim.api.nvim_set_current_win(win)
		vim.api.nvim_win_set_buf(win, self.buf)
	else
		self.open_win(self.buf, position, false)
	end

	self.chan = vim.fn.jobstart(self.cmd, { term = true })
	vim.cmd('startinsert')
end

---Record whether the window is used in terminal or normal mode. Only entering
---terminal mode, or leaving it while staying in the window, counts. Entering
---the window from elsewhere (`n` -> `nt`) is ignored, and leaving terminal mode
---is checked a tick later so that doing it only as a side effect of leaving the
---window (mouse click, `<C-\><C-o><C-w>h`, a `<C-\><C-n><C-w>h` mapping)
---keeps terminal mode. Closing the window records nothing, so the last mode
---used inside it is what gets restored
---@private
function M:track_mode()
	vim.api.nvim_create_autocmd('ModeChanged', {
		buffer = self.buf,
		callback = function()
			local old, new = vim.v.event.old_mode, vim.v.event.new_mode

			if new == 't' then
				self.insert = true
			elseif old == 't' and new == 'nt' then
				vim.schedule(function()
					if
						vim.api.nvim_get_current_buf() == self.buf
						and vim.fn.mode(1) == 'nt'
					then
						self.insert = false
					end
				end)
			end
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

function M.get_win_config()
	return float.config(math.floor(vim.o.columns * 0.95), vim.o.lines - 1)
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
