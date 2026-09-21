local lsp = require('lsp')

local M = {}

function M.setup()
	require('ufo').setup()

	--- ufo only attaches on `BufWinEnter`, which has already fired for the
	--- windows that were open at startup, so replay it for them.
	pcall(vim.cmd, 'silent! doautoall Ufo BufWinEnter')
end

vim.o.foldcolumn = '1' -- '0' is not bad
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true

-- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
vim.keymap.set('n', 'zR', function()
	require('ufo').openAllFolds()
end, { desc = 'Open all folds' })
vim.keymap.set('n', 'zM', function()
	require('ufo').closeAllFolds()
end, { desc = 'Close all folds' })

-- Add folding capabilities to LSP
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.foldingRange = {
	dynamicRegistration = false,
	lineFoldingOnly = true,
}

for _, server in ipairs(lsp.servers) do
	vim.lsp.config(server, { capabilities = capabilities })
end

return M
