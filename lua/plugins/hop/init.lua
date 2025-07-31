local utils = require('utils')
local mapper = utils.mapper
local nmap = mapper('n')

-- stylua: ignore
nmap({
	{ 's', function() require('hop').hint_words() end, 'Hop to word', },
	{ 'M', function() require('hop').hint_lines() end, 'Hop to line', },
})

require('hop').setup({
	keys = 'dhwyfuplaorisetn',
})

