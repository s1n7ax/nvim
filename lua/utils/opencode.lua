local M = {}

---@see https://github.com/neovim/neovim/discussions/26092
vim.api.nvim_create_user_command('OpenCodePrompt', function(opts)
	local this_template = M.get_this_template(opts)
	vim.ui.input({ prompt = 'Send to OpenCode' }, function(input)
		if input then
			input = input:gsub('@this', this_template)
			input = input:gsub('@here', this_template)
			M.send_prompt(input)
		end
	end)
end, { range = true })

local state = {
	buf = nil,
	chan = nil,
}

local function is_valid()
	return state.buf and vim.api.nvim_buf_is_valid(state.buf)
end

local function get_win_config()
	local width = math.floor(vim.o.columns * 0.95)
	local height = vim.o.lines - 1
	local col = math.floor((vim.o.columns - width) / 2)
	return {
		relative = 'editor',
		width = width,
		height = height,
		col = col,
		row = 0,
		style = 'minimal',
		border = 'rounded',
	}
end

local function find_existing_win()
	if not is_valid() then
		return nil
	end
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(win) == state.buf then
			return win
		end
	end
	return nil
end

local function close_win()
	local win = find_existing_win()
	if win then
		vim.api.nvim_win_close(win, false)
	end
end

local function set_buf_keymaps(buf)
	local opts = { buffer = buf, noremap = true, silent = true }
	vim.keymap.set('t', '<c-c>', close_win, opts)
end

local function create_terminal(cmd)
	state.buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_set_option_value('filetype', 'opencode', { buf = state.buf })
	vim.api.nvim_open_win(state.buf, true, get_win_config())
	state.chan = vim.fn.termopen(cmd)
	set_buf_keymaps(state.buf)
	vim.cmd('startinsert')
end

function M.toggle()
	local existing_win = find_existing_win()
	if existing_win then
		vim.api.nvim_win_close(existing_win, false)
		return
	end

	if is_valid() then
		vim.api.nvim_open_win(state.buf, true, get_win_config())
		vim.cmd('startinsert')
		return
	end

	create_terminal('opencode')
end

function M.send_prompt(input)
	if is_valid() and state.chan then
		vim.fn.chansend(state.chan, input)
		M.toggle()
		return
	end

	create_terminal({ 'opencode', '--prompt', input })
end

function M.get_this_template(opts)
	local m = vim.fn.mode()

	local template = ''

	if m == 'n' then
		local file = vim.fn.fnamemodify(vim.fn.expand('%:p'), ':.')
		local line_diff = opts.line1 == opts.line2 and (opts.line1 .. 'L')
			or (opts.line1 .. 'L-' .. opts.line2 .. 'L')
		template = string.format('tt %s:%s', file, line_diff)
	elseif m == 'v' then
		vim.cmd([[execute "normal! \<ESC>"]])
		local start_pos = vim.fn.getpos("'<")
		local end_pos = vim.fn.getpos("'>")

		local start_line, start_col = start_pos[2], start_pos[3]
		local end_line, end_col = end_pos[2], end_pos[3]

		local lines = vim.api.nvim_buf_get_text(
			0,
			start_line - 1,
			start_col - 1,
			end_line - 1,
			end_col,
			{}
		)

		local text = table.concat(lines, '\n')
		print('text', text)
		local file = vim.fn.fnamemodify(vim.fn.expand('%:p'), ':.')
		local line_diff = start_line == end_line and (start_line .. 'L')
			or (start_line .. 'L-' .. end_line .. 'L')

		if #lines > 1 then
			text = string.format('```\n%s\n```', text)
			template = string.format('%s\nat %s:%s', text, file, line_diff)
		else
			template = string.format('"%s" at %s:%s', text, file, line_diff)
		end
	elseif m == 'V' or m == '\22' then -- <C-V>
		vim.cmd([[execute "normal! \<ESC>"]])
		local start_pos = vim.fn.getpos("'<")
		local end_pos = vim.fn.getpos("'>")

		local start_line = start_pos[2]
		local end_line = end_pos[2]

		local file = vim.fn.fnamemodify(vim.fn.expand('%:p'), ':.')
		local line_diff = start_line == end_line and (start_line .. 'L')
			or (start_line .. 'L-' .. end_line .. 'L')

		template = string.format('at %s:%s', file, line_diff)
	end

	return template
end

return M
