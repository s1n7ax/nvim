vim.pack.add({
	'https://github.com/kevinhwang91/nvim-ufo',
	'https://github.com/kevinhwang91/promise-async',
})

local lsp = require('lsp')

vim.o.foldcolumn = '1' -- '0' is not bad
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true

-- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)

-- Add folding capabilities to LSP
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.foldingRange = {
	dynamicRegistration = false,
	lineFoldingOnly = true,
}

for _, server in ipairs(lsp.servers) do
	vim.lsp.config(server, { capabilities = capabilities })
end

require('ufo').setup()
