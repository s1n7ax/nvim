local utils = require('utils')
local mapper = utils.mapper
local nmap = mapper('n')

-- stylua: ignore
nmap({
	{ '<leader>ht', function() require('nvim-comment-frame').add_comment() end, 'Add comment frame' },
	{ '<leader>hn', function() require('nvim-comment-frame').add_multiline_comment() end, 'Add multiline comment frame' },
})

require('nvim-comment-frame').setup()
