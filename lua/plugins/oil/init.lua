vim.pack.add({ 'https://github.com/stevearc/oil.nvim' })

require('oil').setup({
	columns = { 'icon' },
	delete_to_trash = true,
	skip_confirm_for_simple_edits = false,
	use_default_keymaps = false,
	view_options = {
		show_hidden = true,
		is_always_hidden = function(name)
			return name == '..'
		end,
	},
	keymaps = {
		['<backspace>'] = { 'actions.parent', mode = 'n' },
		['<CR>'] = { 'actions.select', mode = 'n' },
		['<leader>e'] = { 'actions.close', mode = 'n' },
		['za'] = { 'actions.toggle_hidden', mode = 'n' },
		['='] = { 'actions.open_cwd', mode = 'n' },
	},
})

-- stylua: ignore
vim.keymap.set('n', '<leader>e', '<cmd>Oil<cr>', { desc = 'Open parent directory' })
