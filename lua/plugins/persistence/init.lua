require('persistence').setup({})

vim.api.nvim_create_autocmd('UIEnter', {
	callback = function()
		vim.schedule(function()
			require('persistence').load({ last = true })
		end)
	end,
})
