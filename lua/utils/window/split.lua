local M = {}

---@param direction 'left' | 'right' | 'above' | 'below'
---@return function
function M.split(direction)
	return function()
		vim.api.nvim_open_win(0, true, {
			split = direction,
		})
	end
end

return M
