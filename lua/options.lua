vim.o.autowriteall = true
vim.o.clipboard = vim.env.SSH_TTY and '' or 'unnamedplus'
vim.o.cmdheight = 0
vim.o.confirm = true
vim.o.cursorline = true
vim.o.expandtab = true
vim.o.hlsearch = false
vim.o.ignorecase = true
vim.o.laststatus = 0
vim.o.linebreak = true
vim.o.messagesopt = 'hit-enter,history:5000'
vim.o.more = false
vim.o.number = true
vim.o.pumblend = 10
vim.o.relativenumber = true
vim.o.scrolloff = 6
vim.o.shiftround = true
vim.o.shiftwidth = 2
vim.o.showmode = false
vim.o.sidescrolloff = 0
vim.o.signcolumn = 'yes:2'
vim.o.smartcase = true
vim.o.smartindent = true
vim.o.smoothscroll = true
vim.o.splitbelow = true
vim.o.splitkeep = 'cursor'
vim.o.splitright = true
vim.o.swapfile = false
vim.o.tabstop = 2
vim.o.termguicolors = true
vim.o.undofile = true
vim.o.undolevels = 10000
vim.o.wildmode = 'longest:full,full'
vim.o.winminwidth = 5
vim.o.wrap = false
vim.opt.shortmess:append({ W = true, I = true, c = true, C = true })
vim.opt.spelllang = { 'en' }
vim.o.spell = true
vim.opt.fillchars = {
	foldopen = '',
	foldclose = '',
	fold = ' ',
	foldsep = ' ',
	diff = '╱',
	eob = ' ',
}

vim.g.s1n7ax_window_horizontal_percentage = 0.8 -- Focused window width percentage
vim.g.s1n7ax_window_vertical_percentage = 0.7 -- Focused window height percentage
vim.g.s1n7ax_window_ignore_filetypes = {
	'help',
	'qf',
	'quickfix',
	'NvimTree',
	'neo-tree',
	'checkhealth',
	'nvim-pack',
	'DiffviewFiles',
} -- Skip resizing for these filetypes
vim.g.s1n7ax_window_vertical_only_filetypes = {
	'OverseerList',
	'OverseerForm',
	'overseer',
} -- Resize vertically only for these filetypes

vim.g.s1n7ax_spell_disable_for_empty_buffers = true -- Disable spell check for buffers without files
vim.g.s1n7ax_spell_disable_filetypes = {
	'git',
	'gitcommit',
	'gitrebase',
	'gitconfig',
} -- Disable spell check for these filetypes
