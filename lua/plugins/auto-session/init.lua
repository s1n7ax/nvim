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
	suppressed_dirs = { '~/', '~/Projects', '~/Downloads', '/' },
	git_use_branch_name = true,
	git_auto_restore_on_branch_change = true,
})
