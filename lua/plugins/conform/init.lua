local formatters = {
	prettierd = { 'javascript', 'typescript', 'json' },
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
	format_on_save = {
		-- These options will be passed to conform.format()
		timeout_ms = 3000,
		lsp_format = 'fallback',
	},
})
