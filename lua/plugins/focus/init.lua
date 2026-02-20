local focus = require('focus')
local utils = require('utils')
local nmap = utils.mapper('n')

local ignore_filetypes = {
	'help',
	'qf',
	'quickfix',
	'NvimTree',
	'neo-tree',
	'checkhealth',
	'nvim-pack',
	'DiffviewFiles',
	'OverseerList',
	'OverseerForm',
	'overseer',
}

-- stylua: ignore
nmap({
	{ '<a-m>', '<cmd>vsplit<cr><c-w>h', 'Split left' },
	{ '<a-n>', '<cmd>split<cr>', 'Split down' },
	{ '<a-e>', '<cmd>split<cr><c-w>k', 'Split up' },
	{ '<a-i>', '<cmd>vsplit<cr>', 'Split right' },
})

local augroup = vim.api.nvim_create_augroup('FocusDisable', { clear = true })

vim.api.nvim_create_autocmd('FileType', {
	group = augroup,
	callback = function(_)
		if vim.tbl_contains(ignore_filetypes, vim.bo.filetype) then
			vim.b.focus_disable = true
		else
			vim.b.focus_disable = false
		end
	end,
})

focus.setup({
	autoresize = {
		minwidth = 10,
	},
	split = {
		bufnew = false,
	},
	ui = {
		cursorline = false,
		signcolumn = false,
	},
})
