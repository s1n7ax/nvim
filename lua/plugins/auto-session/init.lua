vim.opt.sessionoptions:remove({ 'help', 'tabpages', 'terminal', 'winsize' })

-- vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

---@type AutoSession.Config
require('auto-session').setup({
	suppressed_dirs = { '~/', '~/Projects', '~/Downloads', '/' },
	git_use_branch_name = true,
	git_auto_restore_on_branch_change = true,
})
