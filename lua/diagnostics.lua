local constants = require('constants')

-- Configure vim.diagnostic
vim.diagnostic.config({
	underline = true,
	update_in_insert = false,
	virtual_text = false,
	severity_sort = true,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = constants.icons.diagnostics.Error,
			[vim.diagnostic.severity.WARN] = constants.icons.diagnostics.Warn,
			[vim.diagnostic.severity.HINT] = constants.icons.diagnostics.Hint,
			[vim.diagnostic.severity.INFO] = constants.icons.diagnostics.Info,
		},
	},
	float = {
		border = 'rounded',
		header = '',
		prefix = function(diagnostic)
			local severity = diagnostic.severity
			local icon = ''
			if severity == vim.diagnostic.severity.ERROR then
				icon = constants.icons.diagnostics.Error
			elseif severity == vim.diagnostic.severity.WARN then
				icon = constants.icons.diagnostics.Warn
			elseif severity == vim.diagnostic.severity.HINT then
				icon = constants.icons.diagnostics.Hint
			elseif severity == vim.diagnostic.severity.INFO then
				icon = constants.icons.diagnostics.Info
			end
			return icon .. ' ',
				'DiagnosticSign' .. vim.diagnostic.severity[severity]:gsub(
					'^%l',
					string.upper
				)
		end,
		format = function(diagnostic)
			local source = diagnostic.source and diagnostic.source or 'unknown'
			local code = diagnostic.code and string.format(' (%s)', diagnostic.code)
				or ''
			-- Clean up source by removing unwanted characters
			local source_text = source:gsub('[.%%]', '')
			local separator_width = 40
			local padding =
				math.max(0, math.floor((separator_width - #source_text) / 2))
			local left_sep = string.rep('─', padding)
			local right_sep =
				string.rep('─', separator_width - padding - #source_text)
			return string.format(
				'%s%s%s\n%s%s\n',
				left_sep,
				source_text,
				right_sep,
				diagnostic.message,
				code
			)
		end,
		suffix = function()
			return ' ', 'DiagnosticFloatingHint'
		end,
	},
})
