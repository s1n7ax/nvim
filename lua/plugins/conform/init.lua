local prettier_val = { 'prettierd', 'prettier', stop_after_first = true }

local prettier_rules = {
	javascript = prettier_val,
	javascriptreact = prettier_val,
	typescript = prettier_val,
	typescriptreact = prettier_val,
	css = prettier_val,
	scss = prettier_val,
	less = prettier_val,
	html = prettier_val,
	vue = prettier_val,
	json = prettier_val,
	jsonc = prettier_val,
	graphql = prettier_val,
	markdown = prettier_val,
	mdx = prettier_val,
	yaml = prettier_val,
	handlebars = prettier_val,
	hbs = prettier_val,
	svelte = prettier_val,
	astro = prettier_val,
	toml = prettier_val,
	solidity = prettier_val,
	php = prettier_val,
	xml = prettier_val,
	['html.twig'] = prettier_val,
	django = prettier_val,
}

local other_rules = {
	lua = { 'stylua' },
	python = { 'black' },
	bash = { 'shfmt' },
	sh = { 'shfmt' },
	nix = { 'nixfmt' },
}

require('conform').setup({
	formatters_by_ft = vim.tbl_extend('force', prettier_rules, other_rules),
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
