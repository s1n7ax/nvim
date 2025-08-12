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
	'lua_ls',
	'nil_ls',
	'svelte',
	'tailwindcss',
	'ts_ls',
	'gh_actions_ls',
	'groovyls',
}

vim.lsp.enable(M.servers)

return M
