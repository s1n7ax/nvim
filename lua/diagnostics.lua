local constants = require('constants')

-- Configure vim.diagnostic
vim.diagnostic.config({
	underline = true,
	update_in_insert = false,
	virtual_text = {
		spacing = 4,
		source = 'if_many',
		prefix = '●',
	},
	severity_sort = true,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = constants.icons.diagnostics.Error,
			[vim.diagnostic.severity.WARN] = constants.icons.diagnostics.Warn,
			[vim.diagnostic.severity.HINT] = constants.icons.diagnostics.Hint,
			[vim.diagnostic.severity.INFO] = constants.icons.diagnostics.Info,
		},
	},
})

