vim.o.sessionoptions =
	'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'

---@type AutoSession.Config
require('auto-session').setup({
	suppressed_dirs = { '~/', '~/Projects', '~/Downloads', '/' },
})
