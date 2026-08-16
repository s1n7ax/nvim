local context = require('utils.context')
local float = require('utils.window.float')
local TUI = require('utils').tui

local M = {}

local AI_CMD = 'claude'

local ai = TUI:new({ cmd = { AI_CMD } })
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

---Code to summarize: the visual selection, or the whole buffer in normal mode
---@return string code, string label, string filetype
local function get_target()
	local file = context.rel_file()
	local filetype = vim.bo.filetype
	local selection = context.get_visual()

	if selection then
		return selection.text,
			string.format(
				'%s %s',
				file,
				context.line_label(selection.start_line, selection.end_line)
			),
			filetype
	end

	return table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n'),
		file,
		filetype
end

---@param filetype string filetype of the code, taken before the float steals focus
---@return string
local function build_prompt(filetype)
	local prompt = {
		'Give a TLDR of the code below.',
		'Reply in markdown: one sentence on what it is,',
		'then at most 5 short bullets on what it does.',
		'No preamble, no code blocks, no closing remarks.',
	}

	if filetype ~= '' then
		table.insert(prompt, 'The code is ' .. filetype .. '.')
	end

	return table.concat(prompt, ' ')
end

---Summarize the visual selection, or the whole file in normal mode, by piping
---it to a headless `claude --print` and rendering the answer in a float
function M.tldr()
	if vim.fn.executable(AI_CMD) ~= 1 then
		vim.notify(AI_CMD .. ' is not on PATH', vim.log.levels.ERROR)
		return
	end

	local code, label, filetype = get_target()

	if code:match('^%s*$') then
		vim.notify('Nothing to summarize', vim.log.levels.WARN)
		return
	end

	local win = float.open({
		title = ' TLDR ' .. label .. ' ',
		filetype = 'markdown',
		max_width = 100,
	})

	local stop_spinner = win:spinner('Summarizing...')
	local chunks = {}
	local job

	win:on_close(function()
		stop_spinner()

		if job then
			job:kill('sigterm')
		end
	end)

	local ok, err = pcall(function()
		job = vim.system({
			AI_CMD,
			'--print',
			'--no-session-persistence',
			'--strict-mcp-config',
			---`--tools` is variadic, so the space form swallows the prompt
			'--tools=',
			build_prompt(filetype),
		}, {
			---keep the summary about the code itself, free of project CLAUDE.md
			cwd = vim.fn.stdpath('cache'),
			stdin = code,
			text = true,
			stdout = function(_, data)
				if not data then
					return
				end

				table.insert(chunks, data)

				vim.schedule(function()
					stop_spinner()
					win:render(table.concat(chunks))
				end)
			end,
		}, function(res)
			vim.schedule(function()
				stop_spinner()

				if res.code ~= 0 then
					local reason = res.stderr ~= '' and res.stderr
						or (AI_CMD .. ' exited with ' .. res.code)
					win:render('# Error\n\n' .. reason)
				else
					win:render(table.concat(chunks))
				end

				win:scroll_to_top()
			end)
		end)
	end)

	if not ok then
		stop_spinner()
		win:render('# Error\n\n' .. tostring(err))
		win:scroll_to_top()
	end
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
