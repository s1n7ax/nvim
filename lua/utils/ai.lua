local context = require('utils.context')
local float = require('utils.window.float')
local TUI = require('utils').tui

local M = {}

---@class AIAgent
---@field cmd string[] interactive TUI command
---@field ft? string buffer filetype override
---@field print_args? string[] flags for a one-shot, tool-less headless run

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

---Code to summarize: the visual selection, or the whole buffer in normal mode
---@return string code, string label, Selection|nil selection
local function get_target()
	local file = context.rel_file()
	local selection = context.get_visual()

	if selection then
		return context.selection_text(selection),
			string.format(
				'%s %s',
				file,
				context.line_label(selection.start_line, selection.end_line)
			),
			selection
	end

	return table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n'),
		file,
		nil
end

---Wrap text in a tag the prompt can point at
---@param tag string
---@param attrs string
---@param text string
---@return string
local function block(tag, attrs, text)
	return string.format('<%s %s>\n%s\n</%s>', tag, attrs, text, tag)
end

---What the agent reads on stdin: the code, plus for a selection the lines
---around it and the definitions of the names it uses, since a selection like
---a lone function name says nothing on its own
---@param bufnr number buffer the code comes from
---@param code string
---@param label string
---@param selection Selection|nil
---@param callback fun(input: string)
local function build_input(bufnr, code, label, selection, callback)
	local code_block = block('code', string.format('source="%s"', label), code)

	if not selection then
		return callback(code_block)
	end

	local file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':.')
	local shown, surrounding = context.surrounding(bufnr, selection)

	context.definitions(bufnr, selection, shown, function(definitions)
		local blocks = {
			code_block,
			block(
				'surrounding',
				string.format(
					'source="%s %s"',
					file,
					context.line_label(shown.start_line, shown.end_line)
				),
				surrounding
			),
		}

		for _, def in ipairs(definitions) do
			table.insert(
				blocks,
				block(
					'definition',
					string.format(
						'name="%s" source="%s %s"',
						def.name,
						def.path,
						context.line_label(def.start_line, def.end_line)
					),
					def.text
				)
			)
		end

		callback(table.concat(blocks, '\n\n'))
	end)
end

---@param filetype string
---@param has_context boolean
---@return string
local function build_prompt(filetype, has_context)
	local prompt = { 'Give a TLDR of the code in the <code> block.' }

	if has_context then
		vim.list_extend(prompt, {
			'The <surrounding> and <definition> blocks are context only:',
			'use them to work out what the names in <code> refer to and how',
			'<code> is used. If <code> is just a name, summarize what it',
			'refers to. Never mention these blocks or what was provided.',
		})
	end

	vim.list_extend(prompt, {
		'Reply in markdown: one sentence on what it is,',
		'then at most 5 short bullets on what it does.',
		'No preamble, no code blocks, no closing remarks.',
	})

	if filetype ~= '' then
		table.insert(prompt, 'The code is ' .. filetype .. '.')
	end

	return table.concat(prompt, ' ')
end

---Summarize the visual selection, or the whole file in normal mode, by piping
---it to the headless agent (`--print`) and rendering the answer in a float
function M.tldr()
	local spec = AGENTS[agent]
	local cmd = spec.cmd[1]

	if not spec.print_args then
		vim.notify(
			agent .. ' does not support headless summaries yet',
			vim.log.levels.WARN
		)
		return
	end

	if vim.fn.executable(cmd) ~= 1 then
		vim.notify(cmd .. ' is not on PATH', vim.log.levels.ERROR)
		return
	end

	local code, label, selection = get_target()
	---read before the float steals focus
	local bufnr = vim.api.nvim_get_current_buf()
	local prompt = build_prompt(vim.bo.filetype, selection ~= nil)

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

	---@param input string
	local function run(input)
		---closed while the language server was still answering
		if not win:is_valid() then
			return
		end

		local ok, err = pcall(function()
			local args = vim.list_extend({ cmd }, spec.print_args)
			table.insert(args, prompt)

			job = vim.system(args, {
				---keep the summary about the code itself, free of project CLAUDE.md
				cwd = vim.fn.stdpath('cache'),
				stdin = input,
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

	build_input(bufnr, code, label, selection, run)
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
