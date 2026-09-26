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

--- Adds a plugin from a local checkout at `~/<name>` or `~/Workspace/<name>`,
--- falling back to installing it from `src` with `vim.pack.add`.
---@param src string git URL of the plugin
function M.add_local_or_remote(src)
	local name = vim.fs.basename(src):gsub('%.git$', '')

	local local_path = vim.iter({ '~/' .. name, '~/Workspace/' .. name })
		:map(vim.fs.normalize)
		:find(function(path)
			return vim.fn.isdirectory(path) == 1
		end)

	if local_path then
		vim.opt.runtimepath:prepend(local_path)
	else
		vim.pack.add({ src })
	end
end

return M
