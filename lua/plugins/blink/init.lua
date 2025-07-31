local blink = require('blink.cmp')

blink.setup({
	fuzzy = {
		implementation = 'prefer_rust',
		prebuilt_binaries = { force_version = 'v1.6.0' },
	},
	signature = { enabled = true, window = { border = 'single' } },

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
		transform_items = function(_, items)
			-- removes snippes from completion items
			return vim.tbl_filter(function(item)
				local kind = require('blink.cmp.types').CompletionItemKind
				return (item.kind ~= kind.Snippet and item.kind ~= kind.Copilot)
			end, items)
		end,
	},
	keymap = {
		preset = 'none',
		['<c-space>'] = { 'show' },
		['<c-n>'] = { 'select_next', 'snippet_forward', 'fallback' },
		['<c-e>'] = { 'select_prev', 'snippet_backward', 'fallback' },
		['<cr>'] = { 'select_and_accept', 'fallback' },
	},
	completion = {
		menu = { border = 'single' },
		documentation = { window = { border = 'single' } },
		ghost_text = {
			enabled = false,
		},
	},
})

return {
	'saghen/blink.cmp',
	optional = true,
	enabled = true,
	dependencies = { 'L3MON4D3/LuaSnip', version = 'v2.*' },
	---@type blink.cmp.Config
	opts = {
		snippets = { preset = 'luasnip' },
		signature = { enabled = true, window = { border = 'single' } },
		sources = {
			default = { 'lsp', 'path', 'buffer' },

			transform_items = function(_, items)
				-- removes snippes from completion items
				return vim.tbl_filter(function(item)
					local kind = require('blink.cmp.types').CompletionItemKind
					return (item.kind ~= kind.Snippet and item.kind ~= kind.Copilot)
				end, items)
			end,
		},

		keymap = {
			preset = 'none',
			['<c-space>'] = { 'show' },
			['<c-n>'] = { 'select_next', 'snippet_forward', 'fallback' },
			['<c-e>'] = { 'select_prev', 'snippet_backward', 'fallback' },
			['<cr>'] = { 'select_and_accept', 'fallback' },
		},
		completion = {
			menu = { border = 'single' },
			documentation = { window = { border = 'single' } },
			ghost_text = {
				enabled = false,
			},
		},
	},
}
