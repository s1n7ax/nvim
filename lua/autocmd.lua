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

-- Auto-resize on window enter
vim.api.nvim_create_autocmd('WinEnter', {
	group = vim.api.nvim_create_augroup('AutoResize', { clear = true }),
	callback = function()
		vim.schedule(function()
			require('utils.windows').auto_resize_windows()
		end)
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

-- Spell check control based on buffer type and filetype
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter' }, {
	group = vim.api.nvim_create_augroup('SpellCheckControl', { clear = true }),
	callback = function()
		local bufname = vim.fn.expand('%')
		local filetype = vim.bo.filetype
		local disable_for_empty = vim.g.s1n7ax_spell_disable_for_empty_buffers
		local disable_filetypes = vim.g.s1n7ax_spell_disable_filetypes or {}

		local should_disable = false

		-- Check if should disable for empty buffers
		if disable_for_empty and bufname == '' then
			should_disable = true
		end

		-- Check if filetype is in disable list
		for _, ft in ipairs(disable_filetypes) do
			if filetype == ft then
				should_disable = true
				break
			end
		end

		vim.wo.spell = not should_disable
	end,
})
