vim.opt.sessionoptions:remove({ 'help', 'tabpages', 'terminal' })

---@type AutoSession.Config
require('auto-session').setup({
	suppressed_dirs = { '~/', '~/Projects', '~/Downloads', '/' },
})
