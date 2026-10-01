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
			{ pattern = 'debug', icon = '  ', color = 'red' },
			{ pattern = 'test', icon = '  ', color = 'green' },
		},
	},
})

-- Note: `<leader>m` (Messages / noice.nvim) and `<leader>r` (Request /
-- kulala.nvim) have no live keymaps right now because those plugins are
-- commented out in lua/plugins/init.lua. The groups are kept registered so
-- they come back for free if those plugins are re-enabled.

-- stylua: ignore
wk.add({
	{ '<leader>t', group = '🔍 Finder' },
	{ '<leader>n', group = '🧠 LSP' },
	{ '<leader>e', group = '🌿 Git' },
	{ '<leader>i', group = '⚙️ Task Runner' },
	{ '<leader>c', group = '💬 Comments' },
	{ '<leader>o', group = '📦 Package Manager' },
	{ '<leader>u', group = '🎛️ Toggle' },
	{ '<leader>m', group = '📨 Messages' },
	{ '<leader>s', group = '🧪 Test' },
	{ '<leader>a', group = '🔁 Search & Replace' },
	{ '<leader>d', group = '🐞 Debug' },
	{ '<leader>/' },

	{ '<leader>r', group ='🌐 Request' },
	{ '<leader>y', group ='📋 Copy' },
	{ '<leader><leader>', group ='✨ Other' },
})
