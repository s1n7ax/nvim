local mapper = require('utils.keymaps').mapper

local SPINNER =
	{ '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
local SPINNER_INTERVAL_MS = 100

local nmap = mapper('n')

local M = {}

---Centered floating window config with this config's house style
---@param width number
---@param height number
---@param opts? { row?: number, title?: string }
---@return vim.api.keyset.win_config
function M.config(width, height, opts)
	opts = opts or {}

	return {
		relative = 'editor',
		width = width,
		height = height,
		col = math.floor((vim.o.columns - width) / 2),
		row = opts.row or math.floor((vim.o.lines - height) / 2),
		style = 'minimal',
		border = 'rounded',
		title = opts.title,
		title_pos = opts.title and 'center' or nil,
	}
end

---A scratch floating window whose contents are written by the owner
---@class Float
---@field buf number
---@field win number
local Float = {}
Float.__index = Float

---@class FloatOpts
---@field title? string
---@field filetype? string
---@field width_ratio? number
---@field height_ratio? number
---@field max_width? number

---@param opts? FloatOpts
---@return Float
function M.open(opts)
	opts = opts or {}

	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].filetype = opts.filetype or ''
	vim.bo[buf].bufhidden = 'wipe'

	local width = math.min(
		opts.max_width or vim.o.columns,
		math.floor(vim.o.columns * (opts.width_ratio or 0.8))
	)
	local height = math.floor(vim.o.lines * (opts.height_ratio or 0.6))

	local win = vim.api.nvim_open_win(
		buf,
		true,
		M.config(width, height, { title = opts.title })
	)

	vim.wo[win].wrap = true
	vim.wo[win].linebreak = true
	vim.wo[win].conceallevel = 2

	nmap({
		{ 'q', '<cmd>close<cr>', { buffer = buf, desc = 'Close float' } },
		{ '<esc>', '<cmd>close<cr>', { buffer = buf, desc = 'Close float' } },
	})

	return setmetatable({ buf = buf, win = win }, Float)
end

---@return boolean
function Float:is_valid()
	return vim.api.nvim_buf_is_valid(self.buf)
end

---Replace the contents, keeping the view pinned to the last line
---@param text string
function Float:render(text)
	if not self:is_valid() then
		return
	end

	vim.bo[self.buf].modifiable = true
	vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, vim.split(text, '\n'))
	vim.bo[self.buf].modifiable = false

	if vim.api.nvim_win_is_valid(self.win) then
		local line = vim.api.nvim_buf_line_count(self.buf)
		vim.api.nvim_win_set_cursor(self.win, { line, 0 })
	end
end

function Float:scroll_to_top()
	if self:is_valid() and vim.api.nvim_win_is_valid(self.win) then
		vim.api.nvim_win_set_cursor(self.win, { 1, 0 })
	end
end

---Run a spinner in the float until the returned stop function is called
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
