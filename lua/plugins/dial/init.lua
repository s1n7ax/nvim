vim.pack.add({ 'https://github.com/monaqa/dial.nvim' })

local utils = require('utils')
local mapper = utils.mapper
local nmap = mapper('n')
local vmap = mapper('x')

local function manipulate(direction, mode, group)
	return function()
		require('dial.map').manipulate(direction, mode, group)
	end
end

nmap({
	{ '<C-a>', manipulate('increment', 'normal'), 'Increment' },
	{ '<c-x>', manipulate('decrement', 'normal'), 'Decrement' },
	{ 'g<C-a>', manipulate('increment', 'gnormal'), 'Increment' },
	{ 'g<C-x>', manipulate('decrement', 'gnormal'), 'Decrement' },
})

vmap({
	{ '<C-a>', manipulate('increment', 'visual'), 'Visual Increment' },
	{ '<C-x>', manipulate('decrement', 'visual'), 'Visual Decrement' },
	{ 'g<C-a>', manipulate('increment', 'gvisual'), 'Visual Increment' },
	{ 'g<C-x>', manipulate('decrement', 'gvisual'), 'Visual Decrement' },
})

local augend = require('dial.augend')

local common = {
	augend.integer.alias.decimal,
	augend.integer.alias.hex,
	augend.constant.alias.bool,
	augend.date.alias['%Y/%m/%d'],
	augend.date.alias['%d/%m/%Y'],
}

local common_lang = {
	augend.constant.new({
		elements = { '<', '>' },
		word = false,
		cyclic = true,
	}),
	augend.constant.new({
		elements = { '&&', '||' },
		word = false,
		cyclic = true,
	}),
	augend.constant.new({
		elements = { 'and', 'or' },
		word = true,
		cyclic = true,
	}),
	augend.constant.new({
		elements = { 'private', 'public', 'protected' },
		word = true,
		cyclic = true,
	}),
	augend.constant.new({
		elements = { 'class', 'interface', 'enum' },
		word = true,
		cyclic = true,
	}),
	augend.constant.new({
		elements = { 'const', 'let' },
		word = true,
		cyclic = true,
	}),
}

for _, v in ipairs(common) do
	table.insert(common_lang, v)
end

require('dial.config').augends:register_group({
	default = common,
})

local on_filetype = {}

for _, lang in ipairs({
	'lua',
	'java',
	'javascript',
	'typescript',
	'rust',
	'python',
	'typescriptreact',
	'javascriptreact',
}) do
	on_filetype[lang] = common_lang
end

on_filetype['markdown'] = {
	augend.misc.alias.markdown_header,
}

require('dial.config').augends:on_filetype(on_filetype)
