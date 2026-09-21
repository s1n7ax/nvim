local M = {}

function M.setup()
	require('lint').linters_by_ft = {
		lua = { 'luacheck' },
		shellcheck = { 'sh', 'bash' },
	}
end

--- Auto-run linting on save and text changes. The `require` is what pulls
--- nvim-lint onto 'runtimepath', so the plugin costs nothing until the first
--- edit or write.
vim.api.nvim_create_autocmd({ 'BufWritePost', 'TextChanged', 'InsertLeave' }, {
	group = vim.api.nvim_create_augroup('NvimLint', { clear = true }),
	callback = function()
		require('lint').try_lint()
	end,
})

return M
