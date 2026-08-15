local context = require('utils.context')
local TUI = require('utils').tui

local M = {}

local SPINNER =
	{ '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }

local ai = TUI:new({ cmd = { 'claude' } })
-- local ai = TUI:new({ cmd = { 'opencode', '--prompt' } })

ai:map('t', ',t', function()
	if M.ctx ~= '' then
		ai:send_prompt(M.ctx)
	end
end, { desc = 'Insert file context' })

function M.toggle()
	ai:toggle()
end

function M.toggle_right()
	ai:toggle(nil, 'right')
end

---@return string code, string label
local function get_target()
	local mode = vim.fn.mode()
	local file = vim.fn.fnamemodify(vim.fn.expand('%:p'), ':.')

	if file == '' then
		file = '[No Name]'
	end

	if mode == 'v' or mode == 'V' or mode == '\22' then
		vim.cmd([[execute "normal! \<esc>"]])
		local start_line = vim.fn.getpos("'<")[2]
		local end_line = vim.fn.getpos("'>")[2]
		local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

		return table.concat(lines, '\n'),
			string.format('%s %dL-%dL', file, start_line, end_line)
	end

	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

	return table.concat(lines, '\n'), file
end

---@param title string
---@return number buf, number win
local function open_float(title)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].filetype = 'markdown'
	vim.bo[buf].bufhidden = 'wipe'

	local width = math.min(100, math.floor(vim.o.columns * 0.8))
	local height = math.floor(vim.o.lines * 0.6)

	local win = vim.api.nvim_open_win(buf, true, {
		relative = 'editor',
		width = width,
		height = height,
		col = math.floor((vim.o.columns - width) / 2),
		row = math.floor((vim.o.lines - height) / 2),
		style = 'minimal',
		border = 'rounded',
		title = title,
		title_pos = 'center',
	})

	vim.wo[win].wrap = true
	vim.wo[win].linebreak = true
	vim.wo[win].conceallevel = 2

	vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = buf })
	vim.keymap.set('n', '<esc>', '<cmd>close<cr>', { buffer = buf })

	return buf, win
end

---@param buf number
---@param win number
---@param text string
---@param final? boolean
local function render(buf, win, text, final)
	if not vim.api.nvim_buf_is_valid(buf) then
		return
	end

	vim.bo[buf].modifiable = true
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(text, '\n'))
	vim.bo[buf].modifiable = false

	if not vim.api.nvim_win_is_valid(win) then
		return
	end

	local line = final and 1 or vim.api.nvim_buf_line_count(buf)
	vim.api.nvim_win_set_cursor(win, { line, 0 })
end

---@param buf number
---@return fun()
local function start_spinner(buf)
	local timer = vim.uv.new_timer()
	local index = 0
	local stopped = false

	timer:start(
		0,
		100,
		vim.schedule_wrap(function()
			if stopped or not vim.api.nvim_buf_is_valid(buf) then
				return
			end

			index = index % #SPINNER + 1
			vim.bo[buf].modifiable = true
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
				SPINNER[index] .. ' Summarizing...',
			})
			vim.bo[buf].modifiable = false
		end)
	)

	return function()
		if stopped then
			return
		end

		stopped = true
		timer:stop()
		timer:close()
	end
end

---Summarize the visual selection, or the whole file in normal mode, by
---piping it to a headless `claude -p` and streaming the answer to a float
function M.tldr()
	local code, label = get_target()

	if code:match('^%s*$') then
		vim.notify('Nothing to summarize', vim.log.levels.WARN)
		return
	end

	local prompt = {
		'Give a TLDR of the code below.',
		'Reply in markdown: one sentence on what it is,',
		'then at most 5 short bullets on what it does.',
		'No preamble, no code blocks, no closing remarks.',
	}

	if vim.bo.filetype ~= '' then
		table.insert(prompt, 'The code is ' .. vim.bo.filetype .. '.')
	end

	local buf, win = open_float(' TLDR ' .. label .. ' ')
	local stop_spinner = start_spinner(buf)
	local chunks = {}

	local job = vim.system({
		'claude',
		'-p',
		table.concat(prompt, ' '),
	}, {
		cwd = vim.fn.getcwd(),
		stdin = code,
		text = true,
		stdout = function(_, data)
			if not data then
				return
			end

			table.insert(chunks, data)

			vim.schedule(function()
				stop_spinner()
				render(buf, win, table.concat(chunks))
			end)
		end,
	}, function(res)
		vim.schedule(function()
			stop_spinner()

			if res.code ~= 0 then
				local err = res.stderr ~= '' and res.stderr
					or ('claude exited with ' .. res.code)
				render(buf, win, '# Error\n\n' .. err, true)
				return
			end

			render(buf, win, table.concat(chunks), true)
		end)
	end)

	vim.api.nvim_create_autocmd('BufWipeout', {
		buffer = buf,
		once = true,
		callback = function()
			stop_spinner()
			job:kill('sigterm')
		end,
	})
end

function M.setup_cmd()
	---@see https://github.com/neovim/neovim/discussions/26092
	vim.api.nvim_create_user_command('PromptAI', function(opts)
		M.ctx = context.get_curr_context(opts)
		local position = opts.fargs[1]
		ai:toggle(nil, position)
	end, { range = true, nargs = '?' })
end

return M
