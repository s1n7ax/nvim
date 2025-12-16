vim.g.no_plugin_maps = true

-- configuration
require('nvim-treesitter-textobjects').setup({
	select = {
		-- Automatically jump forward to textobj, similar to targets.vim
		lookahead = true,
		-- You can choose the select mode (default is charwise 'v')
		--
		-- Can also be a function which gets passed a table with the keys
		-- * query_string: eg '@function.inner'
		-- * method: eg 'v' or 'o'
		-- and should return the mode ('v', 'V', or '<c-v>') or a table
		-- mapping query_strings to modes.
		selection_modes = {
			['@parameter.outer'] = 'v', -- charwise
			['@function.outer'] = 'v', -- linewise
			['@class.outer'] = '<c-v>', -- blockwise
		},
		-- If you set this to `true` (default is `false`) then any textobject is
		-- extended to include preceding or succeeding whitespace. Succeeding
		-- whitespace has priority in order to act similarly to eg the built-in
		-- `ap`.
		--
		-- Can also be a function which gets passed a table with the keys
		-- * query_string: eg '@function.inner'
		-- * selection_mode: eg 'v'
		-- and should return true of false
		include_surrounding_whitespace = false,
	},
})

local to_select = function(key, sel)
	vim.keymap.set({ 'x', 'o' }, key, function()
		require('nvim-treesitter-textobjects.select').select_textobject(
			sel,
			'textobjects'
		)
	end)
end

to_select('ak', '@block.outer')
to_select('hk', '@block.inner')
to_select('ac', '@class.outer')
to_select('hc', '@class.inner')
to_select('af', '@function.outer')
to_select('hf', '@function.inner')
to_select('al', '@loop.outer')
to_select('hl', '@loop.inner')
to_select('aa', '@parameter.outer')
to_select('ha', '@parameter.inner')

local move_next = function(key, mov)
	vim.keymap.set({ 'n', 'x', 'o' }, key, function()
		require('nvim-treesitter-textobjects.move').goto_next_start(
			mov,
			'textobjects'
		)
	end)
end

local move_prev = function(key, mov)
	vim.keymap.set({ 'n', 'x', 'o' }, key, function()
		require('nvim-treesitter-textobjects.move').goto_previous_start(
			mov,
			'textobjects'
		)
	end)
end

move_next(']a', '@parameter.inner')
move_next(']f', '@function.outer')
move_next(']c', '@call.inner')
move_next(']v', '@assignment.inner')
move_next(']r', '@return.inner')

move_prev('[a', '@parameter.inner')
move_prev('[f', '@function.outer')
move_prev('[c', '@call.inner')
move_prev('[v', '@assignment.inner')
move_prev('[r', '@return.inner')
