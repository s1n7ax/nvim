local blink = require('blink.cmp')

blink.setup({
	enabled = function()
		return vim.bo.buftype ~= 'terminal'
	end,
	fuzzy = {
		implementation = 'prefer_rust',
	},
	signature = { enabled = true, window = { border = 'rounded' } },
	snippets = { preset = 'luasnip' },
	sources = {
		-- add lazydev to your completion providers
		default = { 'lazydev', 'lsp', 'path', 'buffer' },
		providers = {
			lazydev = {
				name = 'LazyDev',
				module = 'lazydev.integrations.blink',
				-- make lazydev completions top priority (see `:h blink.cmp`)
				score_offset = 100,
			},
		},

		-- disable all snippets coming from LSP
		-- transform_items = function(_, items)
		-- 	-- removes snippes from completion items
		-- 	return vim.tbl_filter(function(item)
		-- 		local kind = require('blink.cmp.types').CompletionItemKind
		-- 		return (item.kind ~= kind.Snippet and item.kind ~= kind.Copilot)
		-- 	end, items)
		-- end,
	},
	keymap = {
		preset = 'none',
		['<c-space>'] = { 'show' },
		['<c-n>'] = { 'select_next', 'snippet_forward', 'fallback' },
		['<c-e>'] = { 'select_prev', 'snippet_backward', 'fallback' },
		-- `accept` only accepts an already selected item and otherwise falls
		-- through to the newline. `select_and_accept` would always grab the
		-- first item whenever the menu was open, so pressing `<cr>` in
		-- `.hello {|}` inserted a property instead of a newline.
		['<cr>'] = { 'accept', 'fallback' },
		['<c-l>'] = { 'cancel', 'fallback' },
	},
	-- Keep terminal TUIs (for example, LazyGit) in control of their own input.
	term = { enabled = false },
	cmdline = {
		enabled = false,
		keymap = {
			preset = 'none',
			['<c-space>'] = { 'show' },
			['<c-n>'] = { 'select_next', 'fallback' },
			['<c-e>'] = { 'select_prev', 'fallback' },
			['<cr>'] = { 'accept_and_enter', 'fallback' },
			['<c-l>'] = { 'cancel', 'fallback' },
		},
		completion = { menu = { auto_show = false } },
	},
	completion = {
		-- Preselect the top match only once the user has typed a word to match
		-- on. With an empty keyword (right after `{`, `:`, or a space) nothing
		-- is selected. Keyword characters are letters, digits, `_` and `-`.
		list = {
			selection = {
				preselect = function(ctx)
					return ctx:get_keyword() ~= ''
				end,
			},
		},
		-- A trigger character right after accepting an item would re-open the
		-- menu with the tag's closing bracket, so `<cr>` accepted it again and
		-- `<html></html>` became `<html></html></html>`
		--
		-- Entering insert mode after a trigger character (`a` on the `>` of
		-- `<body></body>`) must not open the menu either. Typing a trigger
		-- character still opens it: that is `show_on_trigger_character`.
		trigger = {
			show_on_accept_on_trigger_character = false,
			show_on_insert_on_trigger_character = false,
		},
		menu = { border = 'padded' },
		documentation = { window = { border = 'single' } },
		ghost_text = {
			enabled = false,
		},
	},
})
