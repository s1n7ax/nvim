local context = require('utils.context')
local float = require('utils.window.float')
local TUI = require('utils').tui

local M = {}

---@class AIAgent
---@field cmd string[] interactive TUI command
---@field print_args string[] flags for a one-shot, tool-less headless run

---@type table<string, AIAgent>
local AGENTS = {
	claude = {
		cmd = { 'claude' },
		print_args = {
			'--print',
			'--no-session-persistence',
			'--strict-mcp-config',
			---`--tools` is variadic, so the space form swallows the prompt
			'--tools=',
		},
	},
	pi = {
		cmd = { 'pi' },
		print_args = {
			'--print',
			'--no-session',
			'--no-tools',
			'--no-context-files',
			'--no-extensions',
			'--no-skills',
			'--no-prompt-templates',
		},
	},
}

local DEFAULT_AGENT = 'pi'

---Remembers the selected agent across Neovim instances
local STATE_FILE = vim.fn.stdpath('state') .. '/ai-agent'

---@return string
local function read_agent()
	local ok, lines = pcall(vim.fn.readfile, STATE_FILE)
	local name = ok and lines[1] or nil
	return AGENTS[name] and name or DEFAULT_AGENT
end

local agent = read_agent()

---@type TUI
local ai

local function new_tui()
	ai = TUI:new({ cmd = AGENTS[agent].cmd })

	ai:map('t', ',t', function()
		if M.ctx ~= '' then
			ai:send_prompt(M.ctx)
		end
	end, { desc = 'Insert file context' })
end

new_tui()

---Switch the AI agent for this and every new Neovim instance. A running
---session of the previous agent is closed
---@param name string
function M.set_agent(name)
	if not AGENTS[name] then
		vim.notify('Unknown AI agent: ' .. name, vim.log.levels.ERROR)
		return
	end

	vim.fn.mkdir(vim.fs.dirname(STATE_FILE), 'p')
	vim.fn.writefile({ name }, STATE_FILE)

	if name ~= agent then
		ai:discard()
		agent = name
		new_tui()
	end

	vim.notify('AI agent: ' .. name)
end

---Pick the AI agent from a list
function M.select_agent()
	vim.ui.select(vim.tbl_keys(AGENTS), {
		prompt = 'AI agent (current: ' .. agent .. ')',
	}, function(name)
		if name then
			M.set_agent(name)
		end
	end)
end

function M.toggle()
	ai:toggle()
end

function M.toggle_right()
	ai:toggle(nil, 'right')
end

---Code to summarize: the visual selection, or the whole buffer in normal mode
---@return string code, string label
local function get_target()
	local file = context.rel_file()
	local selection = context.get_visual()

	if selection then
		return context.selection_text(selection),
			string.format(
				'%s %s',
				file,
				context.line_label(selection.start_line, selection.end_line)
			)
	end

	return table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n'), file
end

---@param filetype string
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
---it to the headless agent (`--print`) and rendering the answer in a float
function M.tldr()
	local cmd = AGENTS[agent].cmd[1]

	if vim.fn.executable(cmd) ~= 1 then
		vim.notify(cmd .. ' is not on PATH', vim.log.levels.ERROR)
		return
	end

	local code, label = get_target()
	---read before the float steals focus
	local prompt = build_prompt(vim.bo.filetype)

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
	local job

	win:on_close(function()
		stop_spinner()

		if job then
			job:kill('sigterm')
		end
	end)

	local function fail(reason)
		stop_spinner()
		win:render('# Error\n\n' .. reason)
		win:scroll_to_top()
	end

	local ok, err = pcall(function()
		local args = vim.list_extend({ cmd }, AGENTS[agent].print_args)
		table.insert(args, prompt)

		job = vim.system(args, {
			---keep the summary about the code itself, free of project CLAUDE.md
			cwd = vim.fn.stdpath('cache'),
			stdin = code,
			text = true,
			stdout = function(_, data)
				if not data then
					return
				end

				vim.schedule(function()
					stop_spinner()
					win:append(data)
				end)
			end,
		}, function(res)
			vim.schedule(function()
				if res.code ~= 0 then
					return fail(
						res.stderr ~= '' and res.stderr
							or (cmd .. ' exited with ' .. res.code)
					)
				end

				stop_spinner()
				win:scroll_to_top()
			end)
		end)
	end)

	if not ok then
		fail(tostring(err))
	end
end

function M.setup_cmd()
	---@see https://github.com/neovim/neovim/discussions/26092
	vim.api.nvim_create_user_command('PromptAI', function(opts)
		M.ctx = context.get_curr_context(opts)
		local position = opts.fargs[1]
		ai:toggle(nil, position)
	end, { range = true, nargs = '?' })

	vim.api.nvim_create_user_command('AIAgent', function(opts)
		if opts.args == '' then
			M.select_agent()
		else
			M.set_agent(opts.args)
		end
	end, {
		nargs = '?',
		complete = function()
			return vim.tbl_keys(AGENTS)
		end,
	})
end

return M
