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

---@type AutoSession.Config
require('auto-session').setup({
	lazy_support = true,
	legacy_cmds = false,
})
