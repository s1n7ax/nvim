vim.o.number = true
vim.o.relativenumber = true
vim.o.scrolloff = 5
vim.o.signcolumn = 'yes:2'
vim.o.cmdheight = 0
vim.o.more = false
vim.o.hlsearch = false

-- Window split behavior
vim.o.splitright = true
vim.o.splitbelow = true

-- Disable status line
vim.o.laststatus = 0

-- Disable text wrapping
vim.o.wrap = false

-- Enable clipboard support
vim.o.clipboard = 'unnamedplus'
vim.o.splitkeep = 'cursor'

vim.g.s1n7ax_window_horizontal_percentage = 0.8 -- Focused window width percentage
vim.g.s1n7ax_window_vertical_percentage = 0.7 -- Focused window height percentage
vim.g.s1n7ax_window_ignore_filetypes =
	{ 'help', 'qf', 'quickfix', 'NvimTree', 'neo-tree', 'checkhealth' } -- Skip resizing for these filetypes
