local WIDTH_MIN = 10
local HEIGHT_MIN = 20

---@class FocusMatchCondition
---@field filetype? string|string[]
---@field bufname? string -- lua pattern
---@field win_var? table<string, any>

---@class FocusSizeRule
---@field width? number|string -- absolute or "X%"
---@field height? number|string
---@field max_width? number|string
---@field max_height? number|string
---@field min_width? number|string
---@field min_height? number|string

---@class FocusRule
---@field match FocusMatchCondition
---@field focused? FocusSizeRule
---@field unfocused? FocusSizeRule

---@type FocusRule[]
local rules = {}

---Parse size value to absolute pixels
---@param value number|string
---@param total number
---@return number
local function parse_size(value, total)
	if type(value) == 'number' then
		return value
	end
	local pct = value:match('^(%d+)%%$')
	if pct then
		return math.floor(total * tonumber(pct) / 100)
	end
	return tonumber(value) or 0
end

---Check if window matches a rule
---@param winid number
---@param match FocusMatchCondition
---@return boolean
local function matches_rule(winid, match)
	local bufnr = vim.api.nvim_win_get_buf(winid)

	if match.filetype then
		local ft = vim.bo[bufnr].filetype
		local fts = type(match.filetype) == 'table' and match.filetype or { match.filetype }
		local ft_match = false
		for _, f in ipairs(fts) do
			if ft == f then
				ft_match = true
				break
			end
		end
		if not ft_match then
			return false
		end
	end

	if match.bufname then
		local name = vim.api.nvim_buf_get_name(bufnr)
		if not name:match(match.bufname) then
			return false
		end
	end

	if match.win_var then
		for k, v in pairs(match.win_var) do
			local ok, val = pcall(vim.api.nvim_win_get_var, winid, k)
			if not ok or val ~= v then
				return false
			end
		end
	end

	return true
end

---Find matching rule for window
---@param winid number
---@return FocusRule?
local function find_rule(winid)
	for _, rule in ipairs(rules) do
		if matches_rule(winid, rule.match) then
			return rule
		end
	end
	return nil
end

---Apply size rule to window
---@param winid number
---@param size_rule FocusSizeRule
---@param maximize boolean
local function apply_size(winid, size_rule, maximize)
	local cols = vim.o.columns
	local lines = vim.o.lines

	local width, height

	if maximize then
		width = cols
		height = lines
	end

	if size_rule.width then
		width = parse_size(size_rule.width, cols)
	end
	if size_rule.height then
		height = parse_size(size_rule.height, lines)
	end

	if width then
		if size_rule.max_width then
			width = math.min(width, parse_size(size_rule.max_width, cols))
		end
		if size_rule.min_width then
			width = math.max(width, parse_size(size_rule.min_width, cols))
		end
		vim.api.nvim_win_set_width(winid, width)
	end

	if height then
		if size_rule.max_height then
			height = math.min(height, parse_size(size_rule.max_height, lines))
		end
		if size_rule.min_height then
			height = math.max(height, parse_size(size_rule.min_height, lines))
		end
		vim.api.nvim_win_set_height(winid, height)
	end
end

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

local function is_floating(winid)
	return vim.api.nvim_win_get_config(winid).relative ~= ''
end

local M = {}

---Add a window focus rule
---@param rule FocusRule
function M.add_rule(rule)
	table.insert(rules, rule)
end

---Set all rules (replaces existing)
---@param new_rules FocusRule[]
function M.set_rules(new_rules)
	rules = new_rules
end


function M.setup()
	local prev_win = nil

	vim.api.nvim_create_autocmd({ 'WinEnter', 'VimResized' }, {
		callback = function()
			vim.schedule(function()
				local winid = vim.api.nvim_get_current_win()
				if is_floating(winid) then
					return
				end

				local prev = prev_win
				prev_win = winid

				set_min_win_opts()

				-- Maximize focused window first
				local rule = find_rule(winid)
				if rule and rule.focused then
					apply_size(winid, rule.focused, true)
				else
					vim.api.nvim_win_set_width(winid, vim.o.columns)
					vim.api.nvim_win_set_height(winid, vim.o.lines)
				end

				-- Then apply unfocused rules to all ruled windows
				for _, win in ipairs(vim.api.nvim_list_wins()) do
					if win ~= winid and not is_floating(win) then
						local win_rule = find_rule(win)
						if win_rule and win_rule.unfocused then
							apply_size(win, win_rule.unfocused, false)
						end
					end
				end

				vim.fn.winrestview({ leftcol = 0 })
			end)
		end,
	})
end

return M
