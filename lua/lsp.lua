local M = {}

M.servers = {
	'bashls',
	'biome',
	'biome',
	'cssls',
	'vtsls',
	'denols',
	'docker_compose_language_service',
	'emmet_language_server',
	'eslint',
	'fish_lsp',
	'html',
	'jsonls',
	'emmylua_ls',
	'nil_ls',
	'svelte',
	'tailwindcss',
	'ts_ls',
}

vim.lsp.enable(M.servers)

return M
