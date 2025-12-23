local M = {}

M.servers = {
	'bashls',
	'cssls',
	'vtsls',
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
	'gh_actions_ls',
	'groovyls',
	'pylsp',
}

vim.lsp.config('jsonls', {
	settings = {
		json = {
			schemas = require('schemastore').json.schemas(),
			validate = { enable = true },
		},
	},
})

vim.lsp.config('yamlls', {
	settings = {
		yaml = {
			schemaStore = {
				-- You must disable built-in schemaStore support if you want to use
				-- this plugin and its advanced options like `ignore`.
				enable = false,
				-- Avoid TypeError: Cannot read properties of undefined (reading 'length')
				url = '',
			},
			schemas = require('schemastore').yaml.schemas(),
		},
	},
})

vim.lsp.enable(M.servers)

return M
