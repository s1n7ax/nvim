local M = {}

function M.mapper(mode)
	return function(maps)
		for index in ipairs(maps) do
			local map = maps[index]
			local key = map[1]
			local action = map[2]
			local options = map[3]

			if type(options) == 'string' then
				options = {
					desc = options,
				}
			end

			vim.keymap.set(mode, key, action, options)
		end
	end
end

return M
