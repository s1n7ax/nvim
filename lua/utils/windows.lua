local M = {}

-- Check if current tab is a diffview tab
local function is_diffview_tab()
	-- Method 1: Use diffview API (most reliable)
	local ok, lib = pcall(require, 'diffview.lib')
	if ok then
		local current_view = lib.get_current_view()
		if current_view then
			return true
		end
	end

	-- Method 2: Check windows in current tab
	local tab_windows = vim.api.nvim_tabpage_list_wins(0)
	for _, win in ipairs(tab_windows) do
		local buf = vim.api.nvim_win_get_buf(win)
		local buf_name = vim.api.nvim_buf_get_name(buf)

		-- Check for diffview:// URL scheme
		if buf_name:match('diffview://') then
			return true
		end

		-- Check for diffview buffer variables
		local ok_var, diffview_var =
			pcall(vim.api.nvim_buf_get_var, buf, 'diffview_view')
		if ok_var and diffview_var then
			return true
		end

		-- Check filetype
		local ft = vim.bo[buf].filetype
		if ft == 'DiffviewFiles' or ft == 'DiffviewFileHistory' then
			return true
		end
	end

	return false
end

-- Auto-resize windows functionality
function M.auto_resize_windows()
	local current_win = vim.api.nvim_get_current_win()
	local windows = vim.api.nvim_list_wins()

	-- Only resize if we have multiple windows
	if #windows <= 1 then
		return
	end

	-- Skip if current window is floating
	local win_config = vim.api.nvim_win_get_config(current_win)
	if win_config.relative ~= '' then
		return
	end

	-- Skip if current tab is a diffview tab
	if is_diffview_tab() then
		return
	end

	-- Skip if current buffer has ignored filetype or is a special buffer
	local current_buf = vim.api.nvim_win_get_buf(current_win)
	local current_ft = vim.bo[current_buf].filetype
	local ignore_filetypes = vim.g.s1n7ax_window_ignore_filetypes or {}
	local vertical_only_filetypes = vim.g.s1n7ax_window_vertical_only_filetypes
		or {}

	-- Check if current window should only resize vertically
	local is_vertical_only = false
	for _, ft in ipairs(vertical_only_filetypes) do
		if current_ft == ft then
			is_vertical_only = true
			break
		end
	end

	for _, ft in ipairs(ignore_filetypes) do
		if current_ft == ft then
			return
		end
	end

	-- Filter out floating windows from the windows list
	local normal_windows = {}
	for _, win in ipairs(windows) do
		local config = vim.api.nvim_win_get_config(win)
		if config.relative == '' then
			table.insert(normal_windows, win)
		end
	end

	-- Update windows list to only include normal windows
	windows = normal_windows

	-- Only resize if we have multiple normal windows
	if #windows <= 1 then
		return
	end

	-- Get window info for all windows
	local window_info = {}
	for _, win in ipairs(windows) do
		local pos = vim.api.nvim_win_get_position(win)
		local width = vim.api.nvim_win_get_width(win)
		local height = vim.api.nvim_win_get_height(win)
		window_info[win] = {
			row = pos[1],
			col = pos[2],
			width = width,
			height = height,
		}
	end

	local current_info = window_info[current_win]

	-- Find windows that share the same row (horizontal neighbors)
	local horizontal_neighbors = {}
	-- Find windows that share the same column (vertical neighbors)
	local vertical_neighbors = {}

	for win, info in pairs(window_info) do
		if win ~= current_win then
			if info.row == current_info.row then
				table.insert(horizontal_neighbors, win)
			end
			if info.col == current_info.col then
				table.insert(vertical_neighbors, win)
			end
		end
	end

	-- Check if any horizontal neighbors are vertical-only windows
	local has_vertical_only_neighbor = false
	for _, win in ipairs(horizontal_neighbors) do
		local neighbor_buf = vim.api.nvim_win_get_buf(win)
		local neighbor_ft = vim.bo[neighbor_buf].filetype
		for _, ft in ipairs(vertical_only_filetypes) do
			if neighbor_ft == ft then
				has_vertical_only_neighbor = true
				break
			end
		end
		if has_vertical_only_neighbor then
			break
		end
	end

	-- Determine if we should resize horizontally or vertically
	local should_resize_width = #horizontal_neighbors > 0
		and not is_vertical_only
		and not has_vertical_only_neighbor
	local should_resize_height = #vertical_neighbors > 0

	if should_resize_width then
		-- Resize width for horizontal splits
		local total_width = vim.o.columns
		local horizontal_percentage = vim.g.s1n7ax_window_horizontal_percentage
			or 0.7
		local focused_width = math.floor(total_width * horizontal_percentage)
		local other_width =
			math.floor((total_width - focused_width) / #horizontal_neighbors)

		-- Set focused window width
		pcall(vim.api.nvim_win_set_width, current_win, focused_width)

		-- Set other windows width
		for _, win in ipairs(horizontal_neighbors) do
			pcall(vim.api.nvim_win_set_width, win, other_width)
		end
	end

	if should_resize_height then
		-- Resize height for vertical splits
		local total_height = vim.o.lines - 1
		local vertical_percentage = vim.g.s1n7ax_window_vertical_percentage or 0.7
		local focused_height = math.floor(total_height * vertical_percentage)
		local other_height =
			math.floor((total_height - focused_height) / #vertical_neighbors)

		-- Set focused window height
		pcall(vim.api.nvim_win_set_height, current_win, focused_height)

		-- Set other windows height
		for _, win in ipairs(vertical_neighbors) do
			pcall(vim.api.nvim_win_set_height, win, other_height)
		end
	end

	vim.cmd('normal! 5zH')
end

function M.split_left()
	local splitright = vim.o.splitright
	vim.o.splitright = false
	vim.api.nvim_cmd({ cmd = 'vs' }, {})
	vim.o.splitright = splitright
	-- Auto-resize windows after splitting
	vim.schedule(function()
		M.auto_resize_windows()
	end)
end

function M.split_right()
	local splitright = vim.o.splitright
	vim.o.splitright = true
	vim.api.nvim_cmd({ cmd = 'vs' }, {})
	vim.o.splitright = splitright
	-- Auto-resize windows after splitting
	vim.schedule(function()
		M.auto_resize_windows()
	end)
end

function M.split_top()
	local splitbelow = vim.o.splitbelow
	vim.o.splitbelow = false
	vim.api.nvim_cmd({ cmd = 'sp' }, {})
	vim.o.splitbelow = splitbelow
	-- Auto-resize windows after splitting
	vim.schedule(function()
		M.auto_resize_windows()
	end)
end

function M.split_bottom()
	local splitbelow = vim.o.splitbelow
	vim.o.splitbelow = true
	vim.api.nvim_cmd({ cmd = 'sp' }, {})
	vim.o.splitbelow = splitbelow
	-- Auto-resize windows after splitting
	vim.schedule(function()
		M.auto_resize_windows()
	end)
end

return M
