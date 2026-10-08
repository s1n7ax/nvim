local context = require('utils.context')
local float = require('utils.window.float')
local TUI = require('utils').tui

local M = {}

---@class AIAgent
---@field cmd string[] interactive TUI command
---@field ft? string buffer filetype override
---@field print_args? string[] flags for a one-shot, read-only headless run

---@type table<string, AIAgent>
local AGENTS = {
	claude = {
		cmd = { 'claude' },
		print_args = {
			'--print',
			'--no-session-persistence',
			'--strict-mcp-config',
			---`--tools` is variadic, so the space form swallows the prompt
			'--tools=Read,Grep,Glob',
		},
	},
	pi = {
		cmd = { 'pi' },
		print_args = {
			'--print',
			'--no-session',
			'--tools',
			'read,grep,find,ls',
		},
	},
	codex = {
		cmd = { 'codex' },
		print_args = {
			'exec',
			'--skip-git-repo-check',
			'--sandbox',
			'read-only',
			'--ask-for-approval',
			'never',
		},
	},
	cursor = {
		cmd = { 'agent' },
		ft = 'cursor',
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
	ai = TUI:new({ cmd = AGENTS[agent].cmd, ft = AGENTS[agent].ft })

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

---Pick the AI agent from a list and open it
function M.select_agent()
	vim.ui.select(vim.tbl_keys(AGENTS), {
		prompt = 'AI agent (current: ' .. agent .. ')',
	}, function(name)
		if not name then
			return
		end

		M.set_agent(name)
		---same file reference `PromptAI` captures without a range
		M.ctx = context.get_curr_context({ range = 0 })
		ai:open()
	end)
end

function M.toggle()
	ai:toggle()
end

function M.toggle_right()
	ai:toggle(nil, 'right')
end

---@class AITarget
---@field code string the selection, or the whole buffer in normal mode
---@field label string float title, e.g. `lua/foo.lua 2L-7L`
---@field subject string what the prompt asks about, e.g. `lines 2-7 of lua/foo.lua`

---Code to summarize: the visual selection, or the whole buffer in normal mode
---@return AITarget
local function get_target()
	local file = context.rel_file()
	local has_file = vim.api.nvim_buf_get_name(0) ~= ''
	local selection = context.get_visual()

	if not selection then
		return {
			code = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n'),
			label = file,
			subject = has_file and ('the file ' .. file) or 'an unsaved buffer',
		}
	end

	local s, e = selection.start_line, selection.end_line
	local lines = s == e and ('line ' .. s) or string.format('lines %d-%d', s, e)

	return {
		code = context.selection_text(selection),
		label = string.format('%s %s', file, context.line_label(s, e)),
		subject = has_file and string.format('%s of %s', lines, file)
			or (lines .. ' of an unsaved buffer'),
	}
end

---@param target AITarget
---@return string
local function build_prompt(target)
	local prompt = {
		'Give a TLDR of ' .. target.subject .. ', piped in below.',
		'Read the file and any related code you need',
		'to explain what it does in the context of this project.',
		'Do not modify anything.',
		'Reply in markdown: one sentence on what it is,',
		'then at most 5 short bullets on what it does.',
		'No preamble, no code blocks, no closing remarks.',
	}

	if vim.bo.modified then
		table.insert(
			prompt,
			'The buffer has unsaved changes, so trust the piped code over the file on disk.'
		)
	end

	if vim.bo.filetype ~= '' then
		table.insert(prompt, 'The code is ' .. vim.bo.filetype .. '.')
	end

	return table.concat(prompt, ' ')
end

---Summarize the visual selection, or the whole file in normal mode, by piping
---it to the headless agent (`--print`) and rendering the answer in a float
function M.tldr()
	local spec = AGENTS[agent]
	local cmd = spec.cmd[1]

	if not spec.print_args then
		vim.notify(agent .. ' does not support headless summaries yet', vim.log.levels.WARN)
		return
	end

	if vim.fn.executable(cmd) ~= 1 then
		vim.notify(cmd .. ' is not on PATH', vim.log.levels.ERROR)
		return
	end

	local target = get_target()
	---read before the float steals focus
	local prompt = build_prompt(target)
	local cwd = vim.fn.getcwd()

	if target.code:match('^%s*$') then
		vim.notify('Nothing to summarize', vim.log.levels.WARN)
		return
	end

	local win = float.open({
		title = ' TLDR ' .. target.label .. ' ',
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
		local args = vim.list_extend({ cmd }, spec.print_args)
		table.insert(args, prompt)

		job = vim.system(args, {
			---run in the project like a normal session, so the agent picks up
			---AGENTS.md/CLAUDE.md and can read the code around the selection
			cwd = cwd,
			stdin = target.code,
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
end

return M
