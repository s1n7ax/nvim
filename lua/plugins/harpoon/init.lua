local utils = require('utils')
local mapper = utils.mapper
local nmap = mapper('n')

-- stylua: ignore
nmap({
	{ ',l', function() require('harpoon.mark').add_file() end, 'Add file to harpoon' },
	{ ',L', function() require('harpoon.ui').toggle_quick_menu() end, 'Open harpoon UI' },
	{ '<c-1>', function() require('harpoon.ui').nav_file(1) end, 'Harpoon file 1' },
	{ '<c-2>', function() require('harpoon.ui').nav_file(2) end, 'Harpoon file 2' },
	{ '<c-3>', function() require('harpoon.ui').nav_file(3) end, 'Harpoon file 3' },
	{ '<c-4>', function() require('harpoon.ui').nav_file(4) end, 'Harpoon file 4' },
	{ '<c-5>', function() require('harpoon.ui').nav_file(5) end, 'Harpoon file 5' },
})

require('harpoon').setup()
