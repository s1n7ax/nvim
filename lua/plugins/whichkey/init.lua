local wk = require('which-key')

wk.setup({
	preset = 'modern',
	delay = 1000,
	icons = {
		rules = {
			{ pattern = 'terminal', icon = '  ', color = 'red' },
			{ pattern = 'find', icon = '  ', color = 'blue' },
			{ pattern = 'search', icon = '  ', color = 'blue' },
			{ pattern = 'git', icon = ' 󰊢 ', color = 'red' },
			{ pattern = 'task', icon = '  ', color = 'green' },
			{ pattern = 'comment', icon = ' 󰆈 ', color = 'blue' },
			{ pattern = 'package', icon = ' 󰏖 ', color = 'orange' },
			{ pattern = 'copy', icon = ' 󰆏 ', color = 'blue' },
			{ pattern = 'paste', icon = ' 󰆏 ', color = 'blue' },
			{ pattern = 'other', icon = '  ', color = 'gray' },
			{ pattern = 'request', icon = ' 󰖟 ', color = 'yellow' },
		},
	},
})

-- stylua: ignore
wk.add({
	{ '<leader>t', group = 'Finder' },
	{ '<leader>n', group = 'LSP' },
	{ '<leader>e', group = 'Task Runner' },
	{ '<leader>i', group = 'Git' },
	{ '<leader>c', group = 'Comments' },
	{ '<leader>o', group = 'Package Manager' },
	{ '<leader>u', group = 'Toggle' },
	{ '<leader>m', group = 'Messages' },
	{ '<leader>s', group = 'Search & Replace' },
	{ '<leader>/' },

	{ '<leader>r', group ='Request' },
	{ '<leader>y', group ='Copy' },
	{ '<leader><leader>', group ='Other' },
})
