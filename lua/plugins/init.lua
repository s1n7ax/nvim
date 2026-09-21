local lazy = require('utils.lazy')

local gh = function(repo)
	return 'https://github.com/' .. repo
end

--- Per-plugin configuration lives in `lua/plugins/<name>/init.lua`; the
--- functions below only decide *when* that file runs. See `utils.lazy` for the
--- available triggers.
local function config(module)
	return function()
		require('plugins.' .. module)
	end
end

--- Themes other than the active one are only needed by the colourscheme
--- picker, so they join 'runtimepath' once the UI is up.
local function theme(repo)
	return { src = gh(repo), event = 'VeryLazy' }
end

lazy.setup({
	---------------------------------------------------------------------------
	--- Loaded during startup
	---------------------------------------------------------------------------
	{ src = gh('catppuccin/nvim'), config = config('themes') },
	{ src = gh('neovim/nvim-lspconfig') },
	{ src = gh('folke/snacks.nvim'), config = config('snacks') },
	{ src = gh('rmagatti/auto-session'), config = config('auto-session') },
	{
		src = gh('nvim-treesitter/nvim-treesitter'),
		config = config('treesitter'),
	},

	---------------------------------------------------------------------------
	--- Libraries, pulled in by whatever requires them first
	---------------------------------------------------------------------------
	{ src = gh('nvim-lua/plenary.nvim'), mod = 'plenary' },
	{ src = gh('MunifTanjim/nui.nvim'), mod = 'nui' },
	{ src = gh('nvim-neotest/nvim-nio'), mod = 'nio' },
	{ src = gh('b0o/SchemaStore.nvim'), mod = 'schemastore' },
	{ src = gh('s1n7ax/nvim-ts-utils'), mod = 'ts-utils' },
	{ src = gh('s1n7ax/nvim-snips'), mod = 'snips' },
	{ src = gh('Saghen/blink.lib'), mod = { 'blink.lib', 'blink.download' } },
	{ src = gh('nvim-mini/mini.icons.git'), mod = 'mini.icons' },
	{ src = gh('nvim-tree/nvim-web-devicons'), mod = 'nvim-web-devicons' },
	{ src = gh('kevinhwang91/promise-async'), mod = { 'promise', 'async' } },

	---------------------------------------------------------------------------
	--- Editing
	---------------------------------------------------------------------------
	{
		src = gh('Saghen/blink.cmp'),
		event = { 'InsertEnter', 'CmdlineEnter' },
		config = config('blink'),
	},
	{
		src = gh('L3MON4D3/LuaSnip'),
		event = 'InsertEnter',
		mod = 'luasnip',
		config = config('luasnip'),
	},
	{
		src = gh('windwp/nvim-autopairs'),
		event = 'InsertEnter',
		config = config('autopair'),
	},
	{
		src = gh('stevearc/conform.nvim'),
		mod = 'conform',
		init = config('conform'),
		config = function()
			require('plugins.conform').setup()
		end,
	},
	{
		src = gh('mfussenegger/nvim-lint'),
		mod = 'lint',
		init = config('lint'),
		config = function()
			require('plugins.lint').setup()
		end,
	},
	{
		src = gh('s1n7ax/nvim-comment-frame'),
		keys = { '<leader>cc', '<leader>cd' },
		config = config('comment-frame'),
	},
	{
		src = gh('echasnovski/mini.move'),
		event = 'VeryLazy',
		config = config('mini-move'),
	},
	{ src = gh('monaqa/dial.nvim'), event = 'VeryLazy', config = config('dial') },
	{
		src = gh('Goose97/timber.nvim'),
		event = 'VeryLazy',
		config = config('timber'),
	},

	---------------------------------------------------------------------------
	--- Motions
	---------------------------------------------------------------------------
	{
		src = gh('chrisgrieser/nvim-spider'),
		event = 'VeryLazy',
		config = config('spider'),
	},
	{ src = gh('smoka7/hop.nvim'), event = 'VeryLazy', config = config('hop') },
	{
		src = gh('folke/flash.nvim'),
		event = 'VeryLazy',
		config = config('flash'),
	},
	{
		src = gh('karb94/neoscroll.nvim'),
		event = 'VeryLazy',
		config = config('neoscroll'),
	},

	---------------------------------------------------------------------------
	--- Buffer decoration
	---------------------------------------------------------------------------
	{
		src = gh('lewis6991/gitsigns.nvim'),
		event = 'VeryLazy',
		config = config('gitsigns'),
	},
	{
		src = gh('folke/todo-comments.nvim'),
		event = 'VeryLazy',
		config = config('todo-comments'),
	},
	{
		src = gh('nvim-treesitter/nvim-treesitter-context'),
		event = 'VeryLazy',
		config = config('treesitter-context'),
	},
	{
		src = gh('kevinhwang91/nvim-ufo'),
		event = 'VeryLazy',
		init = config('ufo'),
		config = function()
			require('plugins.ufo').setup()
		end,
	},
	{
		src = gh('MeanderingProgrammer/render-markdown.nvim'),
		ft = 'markdown',
		config = config('markdown'),
	},
	{
		src = gh('norcalli/nvim-colorizer.lua'),
		cmd = { 'ColorizerToggle', 'ColorizerAttachToBuffer' },
	},

	---------------------------------------------------------------------------
	--- Language support
	---------------------------------------------------------------------------
	{
		src = gh('folke/lazydev.nvim'),
		ft = 'lua',
		mod = 'lazydev',
		config = config('lazydev'),
	},
	{
		src = gh('nvim-treesitter/nvim-treesitter-textobjects'),
		version = 'main',
		-- stylua: ignore
		keys = {
			{ { 'x', 'o' }, 'ak' }, { { 'x', 'o' }, 'hk' },
			{ { 'x', 'o' }, 'ac' }, { { 'x', 'o' }, 'hc' },
			{ { 'x', 'o' }, 'af' }, { { 'x', 'o' }, 'hf' },
			{ { 'x', 'o' }, 'al' }, { { 'x', 'o' }, 'hl' },
			{ { 'x', 'o' }, 'aa' }, { { 'x', 'o' }, 'ha' },
			{ { 'n', 'x', 'o' }, ']a' }, { { 'n', 'x', 'o' }, '[a' },
			{ { 'n', 'x', 'o' }, ']f' }, { { 'n', 'x', 'o' }, '[f' },
			{ { 'n', 'x', 'o' }, ']c' }, { { 'n', 'x', 'o' }, '[c' },
			{ { 'n', 'x', 'o' }, ']v' }, { { 'n', 'x', 'o' }, '[v' },
			{ { 'n', 'x', 'o' }, ']r' }, { { 'n', 'x', 'o' }, '[r' },
		},
		config = config('treesitter-textobjects'),
	},

	---------------------------------------------------------------------------
	--- Navigation and windows
	---------------------------------------------------------------------------
	{
		src = gh('ThePrimeagen/harpoon'),
		-- stylua: ignore
		keys = { ',l', ',L', '<c-1>', '<c-2>', '<c-3>', '<c-4>', '<c-5>' },
		config = config('harpoon'),
	},
	{
		src = gh('sindrets/winshift.nvim'),
		keys = { '<c-w>m' },
		cmd = 'WinShift',
		config = config('winshift'),
	},
	{
		src = gh('s1n7ax/nvim-terminal'),
		keys = { '<leader>;', '<leader>1', '<leader>2', '<leader>3' },
		config = config('terminal'),
	},
	{
		src = gh('folke/which-key.nvim'),
		event = 'VeryLazy',
		config = config('whichkey'),
	},

	---------------------------------------------------------------------------
	--- Git
	---------------------------------------------------------------------------
	{
		src = gh('linrongbin16/gitlinker.nvim'),
		keys = { '<leader>ee', { 'x', '<leader>ee' } },
		cmd = 'GitLink',
		config = config('gitlinker'),
	},
	{
		src = gh('dlyongemallo/diffview-plus.nvim'),
		-- stylua: ignore
		keys = { '<leader>en', '<leader>et', '<leader>es', { 'x', '<leader>es' } },
		cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
		config = config('diffview'),
	},

	---------------------------------------------------------------------------
	--- Search and replace
	---------------------------------------------------------------------------
	{
		src = gh('MagicDuck/grug-far.nvim'),
		keys = { '<leader>aa' },
		cmd = 'GrugFar',
		config = config('grug-far'),
	},

	---------------------------------------------------------------------------
	--- Tasks, tests and debugging
	---------------------------------------------------------------------------
	{
		src = gh('stevearc/overseer.nvim'),
		-- stylua: ignore
		keys = { '<leader>ii', '<leader>in', '<leader>it', '<leader>ie', '<leader>is' },
		cmd = {
			'OverseerRun',
			'OverseerToggle',
			'OverseerQuickAction',
			'OverseerLoadBundle',
			'OverseerShell',
		},
		config = config('overseer'),
	},
	{
		src = gh('nvim-neotest/neotest'),
		dep = { 'FixCursorHold.nvim', 'neotest-jest', 'neotest-vitest' },
		-- stylua: ignore
		keys = {
			'<leader>ss', '<leader>sr', '<leader>st', '<leader>sS',
			'<leader>sn', '<leader>se', '<leader>sa', '<leader>so',
		},
		config = config('neotest'),
	},
	{ src = gh('antoinemadec/FixCursorHold.nvim') },
	{ src = gh('nvim-neotest/neotest-jest'), mod = 'neotest-jest' },
	{ src = gh('marilari88/neotest-vitest'), mod = 'neotest-vitest' },
	{
		src = gh('mfussenegger/nvim-dap'),
		dep = { 'nvim-dap-ui' },
		-- stylua: ignore
		keys = {
			'<leader>dd', '<leader>dn', '<leader>di', '<leader>de', '<leader>do',
			'<leader>dO', '<leader>du', '<leader>dh', '<leader>dl', '<leader>dt',
		},
		config = config('dap'),
	},
	{ src = gh('rcarriga/nvim-dap-ui'), mod = 'dapui' },

	---------------------------------------------------------------------------
	--- Disabled
	---------------------------------------------------------------------------
	-- { src = gh('nvim-focus/focus.nvim'), config = config('focus') },
	-- { src = gh('folke/noice.nvim'), config = config('noice') },
	-- { src = gh('folke/persistence.nvim'), config = config('persistence') },
	-- { src = gh('mistricky/codesnap.nvim'), config = config('codesnap') },
	-- { src = gh('mistweaverco/kulala.nvim'), config = config('kulala') },
	-- { src = gh('stevearc/oil.nvim'), config = config('oil') },
	-- { src = gh('HakonHarnes/img-clip.nvim'), config = config('img-clip') },
	-- { src = gh('A7Lavinraj/fyler.nvim'), config = config('fyler') },

	---------------------------------------------------------------------------
	--- Themes
	---------------------------------------------------------------------------
	theme('folke/tokyonight.nvim'),
	theme('rebelot/kanagawa.nvim'),
	theme('morhetz/gruvbox'),
	theme('sainnhe/everforest'),
	theme('EdenEast/nightfox.nvim'),
	theme('savq/melange-nvim'),
	theme('nyoom-engineering/oxocarbon.nvim'),
	theme('jpwol/thorn.nvim'),
	theme('vague-theme/vague.nvim'),
	theme('rose-pine/neovim'),
	theme('joshdick/onedark.vim'),
	theme('WTFox/luna.nvim'),
})
