local M = {}

---Notify about an on/off toggle state change.
---@param name string label, e.g. 'Spell check'
---@param on boolean true = enabled, false = disabled
function M.notify(name, on)
	vim.notify(name .. ' ' .. (on and 'enabled' or 'disabled'))
end

return M
