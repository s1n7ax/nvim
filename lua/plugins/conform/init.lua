local formatters = {
	prettierd = {
		'javascript',
		'javascriptreact',
		'typescript',
		'typescriptreact',
		'svelte',
		'json',
		'css',
	},
	stylua = { 'lua' },
	nixfmt = { 'nix' },
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
		return { timeout_ms = 500, lsp_format = 'fallback' }
	end,
})

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
