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
vim.o.winborder = 'rounded'
vim.o.autoread = true
vim.opt.shortmess:append({ W = true, I = true, c = true, C = true })
vim.opt.fillchars = {
	foldopen = '',
	foldclose = '',
	fold = ' ',
	foldsep = ' ',
	diff = '╱',
	eob = ' ',
}
vim.o.equalalways = false

vim.opt.sessionoptions:remove({
	'blank',
	'buffers',
	'curdir',
	'folds',
	'help',
	'tabpages',
	'winsize',
	'terminal',
	'options',
})

require('vim._core.ui2').enable({
	enable = true,
	msg = {
		targets = {
			[''] = 'msg',
			empty = 'cmd',
			bufwrite = 'msg',
			confirm = 'cmd',
			emsg = 'pager',
			echo = 'msg',
			echomsg = 'msg',
			echoerr = 'pager',
			completion = 'cmd',
			list_cmd = 'pager',
			lua_error = 'pager',
			lua_print = 'msg',
			progress = 'pager',
			rpc_error = 'pager',
			quickfix = 'msg',
			search_cmd = 'cmd',
			search_count = 'cmd',
			shell_cmd = 'pager',
			shell_err = 'pager',
			shell_out = 'pager',
			shell_ret = 'msg',
			undo = 'msg',
			verbose = 'pager',
			wildlist = 'cmd',
			wmsg = 'msg',
			typed_cmd = 'cmd',
		},
		cmd = {
			height = 0.5,
		},
		dialog = {
			height = 0.5,
		},
		msg = {
			height = 0.3,
			timeout = 5000,
		},
		pager = {
			height = 0.5,
		},
	},
})
