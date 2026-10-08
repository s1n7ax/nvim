require('lint').linters_by_ft = {
	lua = { 'luacheck' },
	sh = { 'shellcheck' },
	bash = { 'shellcheck' },
}

-- luacheck resolves .luacheckrc relative to its cwd, not the linted file's
-- directory. nvim-lint defaults that cwd to Neovim's own cwd, so a
-- .luacheckrc next to the file (e.g. hyprland/binds.lua) is silently
-- ignored when the project is opened from a parent directory. Walk up from
-- the buffer to the nearest .luacheckrc and run luacheck from there.
local function luacheck_cwd(bufnr)
	local file = vim.api.nvim_buf_get_name(bufnr)
	return vim.fs.root(file, '.luacheckrc') or vim.fn.getcwd()
end

-- Auto-run linting on save and text changes
vim.api.nvim_create_autocmd({ 'BufWritePost', 'TextChanged', 'InsertLeave' }, {
	callback = function()
		local opts
		if vim.bo.filetype == 'lua' then
			opts = { cwd = luacheck_cwd(0) }
		end
		require('lint').try_lint(nil, opts)
	end,
})
