local M = {}

M.servers = {
	'lua_ls',
	'denols',
	'biome',
	'svelte',
}

for _, server in ipairs(M.servers) do
	vim.lsp.enable(server)
end

return M
