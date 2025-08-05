local keymap_util = require('utils.keymaps')
local nmap = keymap_util.mapper('n')

-- stylua: ignore
nmap({
	{ '<leader>;', '<cmd>lua NTGlobal["terminal"]:toggle()<cr>', 'Toggle terminal', },
	{ '<leader>1', '<cmd>lua NTGlobal["terminal"]:open(1)<cr>', 'Open terminal 1', },
	{ '<leader>2', '<cmd>lua NTGlobal["terminal"]:open(2)<cr>', 'Open terminal 2', },
	{ '<leader>3', '<cmd>lua NTGlobal["terminal"]:open(3)<cr>', 'Open terminal 3', },
})

require('nvim-terminal').setup({
	disable_default_keymaps = true,
})
