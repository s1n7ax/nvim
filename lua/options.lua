vim.o.autowriteall = true
vim.o.clipboard = 'unnamedplus'
-- When there's no native clipboard (SSH session, or a microvm console with no
-- Wayland/X display), sync the host clipboard over OSC 52. We can't use the
-- builtin 'osc52' provider directly: its paste blocks on an OSC 52 read query
-- and, on terminals that don't answer (e.g. inside the microvm), times out and
-- returns nothing, so `p` fails with `E353: Nothing in register "`.
-- Instead copy via OSC 52 but paste from an in-session cache, so `p` always
-- returns the last yank without touching the terminal.
if vim.env.SSH_TTY or not (vim.env.WAYLAND_DISPLAY or vim.env.DISPLAY) then
	local osc52 = require('vim.ui.clipboard.osc52')
	local cache = { ['+'] = { '' }, ['*'] = { '' } }
	local function cached_copy(reg)
		local write = osc52.copy(reg)
		return function(lines, regtype)
			cache[reg] = lines
			write(lines, regtype)
		end
	end
	local function cached_paste(reg)
		return function()
			return cache[reg]
		end
	end
	vim.g.clipboard = {
		name = 'osc52-cached',
		copy = { ['+'] = cached_copy('+'), ['*'] = cached_copy('*') },
		paste = { ['+'] = cached_paste('+'), ['*'] = cached_paste('*') },
	}
end
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

-- custom options
-- AI

local focus = require('utils.window.focus')
focus.setup()
focus.add_rule({
	match = { filetype = 'claude' },
	focused = { width = 80 },
	unfocused = { width = 80 },
})
