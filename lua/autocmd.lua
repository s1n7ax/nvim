-- Auto commands for various features

-- Yank highlight functionality
-- stylua: ignore
vim.api.nvim_set_hl( 0, 'YankHighlight', { bg = '#3d59a1', fg = '#ffffff', bold = true })

vim.api.nvim_create_autocmd('TextYankPost', {
	group = vim.api.nvim_create_augroup('YankHighlight', { clear = true }),
	callback = function()
		vim.hl.on_yank({ higroup = 'YankHighlight', timeout = 100 })
	end,
})

vim.api.nvim_create_autocmd('BufWinEnter', {
	group = vim.api.nvim_create_augroup('WinBar', { clear = true }),
	pattern = '*',
	callback = function()
		-- skip if a pop up window
		if vim.fn.win_gettype() == 'popup' then
			return
		end

		-- skip if new buffer
		if vim.bo.filetype == '' then
			return
		end

		vim.wo.winbar = "%{%v:lua.require'utils.winbar'.eval()%}"
	end,
})

-- Restore <CR> behavior in quickfix and location lists
vim.api.nvim_create_autocmd('FileType', {
	group = vim.api.nvim_create_augroup('QuickfixRemap', { clear = true }),
	pattern = 'qf',
	callback = function()
		-- stylua: ignore
		vim.keymap.set( 'n', '<CR>', '<CR>', { buffer = true, desc = 'Open quickfix entry' })
	end,
})
