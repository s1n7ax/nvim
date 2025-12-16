require('nvim-treesitter')
	.install({
		'bash',
		'c',
		'cmake',
		'comment',
		'cpp',
		'css',
		'csv',
		'diff',
		'dockerfile',
		'gitcommit',
		'gitignore',
		'html',
		'java',
		'javascript',
		'json5',
		'lua',
		'markdown',
		'markdown_inline',
		'nix',
		'python',
		'query',
		'regex',
		'requirements',
		'rust',
		'scss',
		'sql',
		'todotxt',
		'tsx',
		'typescript',
		'vimdoc',
		'vue',
		'xml',
		'yaml',
		'svelte',
		'groovy',
	})
	:wait(300000)

local group = vim.api.nvim_create_augroup('TreesitterSetup', { clear = true })

local ignore_filetypes = {
	'checkhealth',
	'lazy',
	'mason',
	'noice',
	'snacks_dashboard',
	'snacks_notif',
	'snacks_win',
}

-- Auto-install parsers and enable highlighting on FileType
vim.api.nvim_create_autocmd('FileType', {
	group = group,
	desc = 'Enable treesitter highlighting and indentation',
	callback = function(event)
		if vim.tbl_contains(ignore_filetypes, event.match) then
			return
		end

		-- Start highlighting immediately (works if parser exists)
		local ok = pcall(vim.treesitter.start)

		-- Enable treesitter indentation
		if ok then
			vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end
	end,
})
