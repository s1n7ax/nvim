local M = {}

function M.pick_pkg_to_update()
	local pkgs = vim.pack.get()

	vim.ui.select(pkgs, {
		prompt = 'Select package to update',
		format_item = function(item)
			return item.spec.name
		end,
	}, function(item)
		if item then
			vim.pack.update({ item.spec.name })
		end
	end)
end

return M
