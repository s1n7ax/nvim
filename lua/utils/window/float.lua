local mapper = require('utils.keymaps').mapper

local SPINNER =
	{ '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
local SPINNER_INTERVAL_MS = 100
local WIDTH_RATIO = 0.8
local HEIGHT_RATIO = 0.6

local nmap = mapper('n')

local M = {}

---Centered floating window config, sized in absolute cells
---@param width number
---@param height number
---@param title? string
---@return vim.api.keyset.win_config
function M.config(width, height, title)
	return {
		relative = 'editor',
		width = width,
		height = height,
		col = math.floor((vim.o.columns - width) / 2),
		row = math.floor((vim.o.lines - height) / 2),
		style = 'minimal',
		title = title,
		title_pos = title and 'center' or nil,
	}
end

---A scratch floating window whose contents are written by the owner
---@class Float
---@field buf number
---@field win number
---@field private tail number 0-indexed row of the last, possibly incomplete, line
---@field private partial string text already written on that line
---@field private transient boolean contents are a spinner frame, to be overwritten
local Float = {}
Float.__index = Float

---@class FloatOpts
---@field title? string
---@field filetype? string
---@field max_width? number

---@param opts? FloatOpts
---@return Float
function M.open(opts)
	opts = opts or {}

	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].filetype = opts.filetype or ''
	vim.bo[buf].bufhidden = 'wipe'

	local width = math.min(
		opts.max_width or math.huge,
		math.floor(vim.o.columns * WIDTH_RATIO)
	)
	local height = math.floor(vim.o.lines * HEIGHT_RATIO)

	local win =
		vim.api.nvim_open_win(buf, true, M.config(width, height, opts.title))

	vim.wo[win].wrap = true
	vim.wo[win].conceallevel = 2

	nmap({
		{ 'q', '<cmd>close<cr>', { buffer = buf, desc = 'Close float' } },
		{ '<esc>', '<cmd>close<cr>', { buffer = buf, desc = 'Close float' } },
	})

	return setmetatable({
		buf = buf,
		win = win,
		tail = 0,
		partial = '',
		transient = false,
	}, Float)
end

---@return boolean
function Float:is_valid()
	return vim.api.nvim_buf_is_valid(self.buf)
end

---@private
---@param from number 0-indexed row to rewrite from
---@param text string
function Float:write(from, text)
	local lines = vim.split(text, '\n')

	vim.bo[self.buf].modifiable = true
	vim.api.nvim_buf_set_lines(self.buf, from, -1, false, lines)
	vim.bo[self.buf].modifiable = false

	self.tail = from + #lines - 1
	self.partial = lines[#lines]
	self.transient = false

	if vim.api.nvim_win_is_valid(self.win) then
		vim.api.nvim_win_set_cursor(self.win, { self.tail + 1, 0 })
	end
end

---Replace the contents, keeping the view pinned to the last line
---@param text string
function Float:render(text)
	if not self:is_valid() then
		return
	end

	self:write(0, text)
end

---Append streamed text, rewriting only the trailing line
---@param text string
function Float:append(text)
	if not self:is_valid() then
		return
	end

	self:write(self.tail, self.partial .. text)
end

function Float:scroll_to_top()
	if self:is_valid() and vim.api.nvim_win_is_valid(self.win) then
		vim.api.nvim_win_set_cursor(self.win, { 1, 0 })
	end
end

---Run a spinner in the float until the returned stop function is called, which
---also wipes the last frame so the owner can write from a clean buffer
---@param message string
---@return fun() stop
function Float:spinner(message)
	local timer = vim.uv.new_timer()
	local index = 0
	local stopped = false

	local function stop()
		if stopped then
			return
		end

		stopped = true
		timer:stop()
		timer:close()

		if self.transient then
			self:render('')
		end
	end

	timer:start(
		0,
		SPINNER_INTERVAL_MS,
		vim.schedule_wrap(function()
			if stopped then
				return
			end

			if not self:is_valid() then
				return stop()
			end

			index = index % #SPINNER + 1
			self:render(SPINNER[index] .. ' ' .. message)
			self.transient = true
		end)
	)

	return stop
end

---@param callback fun()
function Float:on_close(callback)
	vim.api.nvim_create_autocmd('BufWipeout', {
		buffer = self.buf,
		once = true,
		callback = callback,
	})
end

return M
