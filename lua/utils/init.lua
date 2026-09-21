--- Aggregates the `utils.*` submodules.
---
--- Access is resolved on first use, so requiring this module costs nothing for
--- the submodules a caller never touches.
local M = {}

local submodules = {
	'keymaps',
	'editing',
	'lsp',
	'git',
	'tui',
	'context',
}

return setmetatable(M, {
	__index = function(_, key)
		if key == 'mapper' then
			return require('utils.keymaps').mapper
		end

		if vim.tbl_contains(submodules, key) then
			local mod = require('utils.' .. key)
			rawset(M, key, mod)
			return mod
		end
	end,
})
