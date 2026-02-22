local WIDTH_MIN = 10
local HEIGHT_MIN = 20

local function set_min_win_opts()
	local width = vim.o.columns
	local height = vim.o.lines

	local min_w = math.floor(width / 100 * WIDTH_MIN)
	local min_h = math.floor(height / 100 * HEIGHT_MIN)

	if vim.o.winminwidth > min_w + 1 then
		vim.o.winminwidth = min_w
		vim.o.winwidth = min_w + 1
	else
		vim.o.winwidth = min_w + 1
		vim.o.winminwidth = min_w
	end

	if vim.o.winminheight > min_h + 1 then
		vim.o.winminheight = min_h
		vim.o.winheight = min_h + 1
	else
		vim.o.winheight = min_h + 1
		vim.o.winminheight = min_h
	end
end

local function set_win_size(winid)
	local width = vim.o.columns
	local height = vim.o.lines

	vim.api.nvim_win_set_width(winid, width)
	vim.api.nvim_win_set_height(winid, height)
	vim.fn.winrestview({ leftcol = 0 })
end

local M = {}

function M.setup()
	vim.api.nvim_create_autocmd({ 'WinEnter', 'VimResized' }, {
		callback = function()
			local winid = vim.api.nvim_get_current_win()
			if vim.api.nvim_win_get_config(winid).relative ~= '' then
				return
			end

			set_min_win_opts()
			set_win_size(winid)
		end,
	})
end

return M
