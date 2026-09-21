local M = {}

M.servers = {
	'bashls',
	'cssls',
	'tsc',
	'docker_compose_language_service',
	'emmet_language_server',
	'eslint',
	'fish_lsp',
	'html',
	'jsonls',
	'jsonnet_ls',
	'lua_ls',
	'nil_ls',
	'svelte',
	'tailwindcss',
	'gh_actions_ls',
	'groovyls',
	'pylsp',
}

vim.lsp.config('nil_ls', {
	settings = {
		['nil'] = {
			nix = {
				flake = {
					autoArchive = true,
				},
			},
		},
	},
})

--- SchemaStore ships a large catalog, so the schema lists are only built once
--- a matching buffer shows up. These autocmds are registered before
--- `vim.lsp.enable()` below so they run ahead of the one it installs, and the
--- server still starts with its settings in place.
vim.api.nvim_create_autocmd('FileType', {
	group = vim.api.nvim_create_augroup('LspSchemaStore', { clear = true }),
	pattern = { 'json', 'jsonc' },
	once = true,
	callback = function()
		vim.lsp.config('jsonls', {
			settings = {
				json = {
					schemas = require('schemastore').json.schemas(),
					validate = { enable = true },
				},
			},
		})
	end,
})

vim.api.nvim_create_autocmd('FileType', {
	group = 'LspSchemaStore',
	pattern = { 'yaml', 'yaml.docker-compose', 'yaml.gitlab' },
	once = true,
	callback = function()
		vim.lsp.config('yamlls', {
			settings = {
				yaml = {
					schemaStore = {
						--- You must disable built-in schemaStore support if you want to
						--- use this plugin and its advanced options like `ignore`.
						enable = false,
						--- Avoid TypeError: Cannot read properties of undefined
						--- (reading 'length')
						url = '',
					},
					schemas = require('schemastore').yaml.schemas(),
				},
			},
		})
	end,
})

vim.lsp.enable(M.servers)

return M
