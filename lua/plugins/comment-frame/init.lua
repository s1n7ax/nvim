local utils = require('utils')
local mapper = utils.mapper
local normal_map = mapper('n')

-- stylua: ignore
normal_map({
	{ '<leader>tt', function() require('nvim-comment-frame').add_comment() end, 'Add comment frame' },
	{ '<leader>tn', function() require('nvim-comment-frame').add_multiline_comment() end, 'Add multiline comment frame' },
})

require('nvim-comment-frame').setup()
