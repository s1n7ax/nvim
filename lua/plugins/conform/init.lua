local formatters = {
	prettierd = {
		'javascript',
		'javascriptreact',
		'typescript',
		'typescriptreact',
		'css',
		'scss',
		'less',
		'html',
		'vue',
		'json',
		'jsonc',
		'graphql',
		'markdown',
		'mdx',
		'yaml',
		'handlebars',
		'hbs',
		'svelte',
		'astro',
		'toml',
		'solidity',
		'php',
		'xml',
		'html.twig',
		'django',
	},
	stylua = { 'lua' },
	nixfmt = { 'nix' },
	black = { 'python' },
	shfmt = { 'bash', 'sh' },
}

local formatters_by_ft = {}

for formatter_name, langs in pairs(formatters) do
	for _, lang in ipairs(langs) do
		if not formatters_by_ft[lang] then
			formatters_by_ft[lang] = {}
		end

		table.insert(formatters_by_ft[lang], formatter_name)
	end
end

require('conform').setup({
	formatters_by_ft = formatters_by_ft,
	format_on_save = function(bufnr)
		-- Disable with a global or buffer-local variable
		if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
			return
		end
		return { timeout_ms = 5000, lsp_format = 'fallback' }
	end,
})

vim.keymap.set('n', '<leader>ut', function()
	local toggled = not vim.g.disable_autoformat
	vim.b.disable_autoformat = toggled
	vim.g.disable_autoformat = toggled
	vim.notify('Auto-formatting ' .. (toggled and 'disabled' or 'enabled'))
end, { desc = 'Toggle auto-formatting' })

vim.api.nvim_create_user_command('Format', function(args)
	local range = nil
	if args.count ~= -1 then
		local end_line =
			vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
		range = {
			start = { args.line1, 0 },
			['end'] = { args.line2, end_line:len() },
		}
	end
	require('conform').format({
		async = true,
		lsp_format = 'fallback',
		range = range,
	})
end, { range = true })

vim.api.nvim_create_user_command('FormatDisable', function(args)
	if args.bang then
		-- FormatDisable! will disable formatting just for this buffer
		vim.b.disable_autoformat = true
	else
		vim.g.disable_autoformat = true
	end
end, {
	desc = 'Disable autoformat-on-save',
	bang = true,
})

vim.api.nvim_create_user_command('FormatEnable', function()
	vim.b.disable_autoformat = false
	vim.g.disable_autoformat = false
end, {
	desc = 'Re-enable autoformat-on-save',
})
