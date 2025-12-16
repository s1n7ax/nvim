require('lint').linters_by_ft = {
	lua = { 'luacheck' },
	shellcheck = { 'sh', 'bash' },
}

-- Auto-run linting on save and text changes
vim.api.nvim_create_autocmd({ 'BufWritePost', 'TextChanged', 'InsertLeave' }, {
	callback = function()
		require('lint').try_lint()
	end,
})
