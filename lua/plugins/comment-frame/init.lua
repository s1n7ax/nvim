vim.pack.add({ 'https://github.com/s1n7ax/nvim-comment-frame' })

local utils = require('utils')
local mapper = utils.mapper
local normal_map = mapper('n')

-- stylua: ignore
normal_map({
	{ '<leader><leader>c', function() require('nvim-comment-frame').add_comment() end, 'Add comment frame' },
	{ '<leader><leader>CC', function() require('nvim-comment-frame').add_multiline_comment() end, 'Add multiline comment frame' },
})

require('nvim-comment-frame').setup()
