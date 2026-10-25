local context = require('utils.context')
local float = require('utils.window.float')
local TUI = require('utils').tui

local M = {}

---@class AIAgent
---@field cmd string[] interactive TUI command
---@field ft? string buffer filetype override
---@field print_args? string[] flags for a one-shot, tool-less headless run
---@field title? fun(title: string, dir: string): string|nil the session title
---in the terminal title the agent sets, nil while it has none. `dir` is the
---name of the directory the agent runs in

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
		---`<mark> <title>`, the mark animating while it works. The title is
		---`Claude Code` until the session has one
		title = function(title)
			title = title:gsub('^[\128-\255]+%s+', '')
			return title ~= 'Claude Code' and title or nil
		end,
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
		---`π - <dir>`, or `π - <name> - <dir>` once the session is named
		title = function(title, dir)
			local rest = title:match('^π %- (.*)$')

			if not rest then
				return title
			end

			if rest == dir then
				return nil
			end

			local suffix = ' - ' .. dir
			return vim.endswith(rest, suffix) and rest:sub(1, -#suffix - 1) or rest
		end,
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

---Kind new agents start as
local agent = read_agent()

---`<c-1>`..`<c-9>` reach one agent each
local MAX_AGENTS = 9
---Cells a session title may take in the header
local TITLE_WIDTH = 30
---How the other agents' entries shrink, step by step, until the header fits:
---the cells their titles may take, and whether their kind stays
local SHRINK = {
	{ title = TITLE_WIDTH, kind = true },
	{ title = 10, kind = true },
	{ title = 0, kind = true },
	{ title = 0, kind = false },
}
---padded outside `%{}`, which strips leading spaces from plain text
local HEADER = " %{%v:lua.require'utils.ai'.header()%}"
local HEADER_SEPARATOR = ' │ '

---@class AISession
---@field kind string
---@field tui TUI
---@field dir string name of the directory the agent runs in

---Agents by slot. An agent keeps its slot until it exits, when `TermClose`
---frees it
---@type table<number, AISession>
local sessions = {}

---Slot of the agent shown last
---@type number|nil
local last

---Cheap enough for the header, which is drawn on every redraw
---@param n number|nil
---@return boolean
local function is_running(n)
	return sessions[n] ~= nil and sessions[n].tui.buf ~= nil
end

---@param n number
---@return boolean
local function is_free(n)
	return not is_running(n)
end

---@param match fun(n: number): boolean
---@return number|nil
local function lowest(match)
	for n = 1, MAX_AGENTS do
		if match(n) then
			return n
		end
	end
end

---@param buf number
---@return number|nil
local function slot_of(buf)
	for n, session in pairs(sessions) do
		if session.tui.buf == buf then
			return n
		end
	end
end

---A window showing an agent, running or exited: the current window, then one
---in this tab, then one in any tab
---@return number|nil
local function find_agent_win()
	local wins = { vim.api.nvim_get_current_win() }
	vim.list_extend(wins, vim.api.nvim_tabpage_list_wins(0))
	vim.list_extend(wins, vim.api.nvim_list_wins())

	for _, win in ipairs(wins) do
		if vim.b[vim.api.nvim_win_get_buf(win)].ai_agent then
			return win
		end
	end
end

---Headers also list agents their window does not show, so a change to any
---agent redraws them all
local function redraw_headers()
	vim.cmd.redrawstatus({ bang = true })
end

---@param session AISession
---@return string|nil
local function session_title(session)
	local title = vim.b[session.tui.buf].term_title

	---the terminal is named `term://...` until the agent sets a title
	if
		type(title) ~= 'string'
		or title == ''
		or vim.startswith(title, 'term://')
	then
		return nil
	end

	local parse = AGENTS[session.kind].title

	if parse then
		title = parse(title, session.dir)
	elseif title == session.tui.cmd[1] then
		title = nil
	end

	return title ~= '' and title or nil
end

---@param text string
---@param width number cells
---@return string
local function truncate(text, width)
	if vim.fn.strdisplaywidth(text) <= width then
		return text
	end

	return vim.fn.strcharpart(text, 0, width - 1) .. '…'
end

---Winbar of an agent window: every running agent by slot, with its kind and
---session title, the one the window shows highlighted. `%{}` evaluates it with
---the winbar's window as the current one
---@return string
function M.header()
	local win = vim.api.nvim_get_current_win()
	local current = slot_of(vim.api.nvim_win_get_buf(win))
	local entries = {}

	for n = 1, MAX_AGENTS do
		if is_running(n) then
			table.insert(entries, {
				n = n,
				kind = sessions[n].kind,
				title = session_title(sessions[n]),
			})
		end
	end

	---@param other { title: number, kind: boolean } how much of the other
	---agents to show
	---@return string text, string winbar
	local function render(other)
		local labels, items = {}, {}

		for _, entry in ipairs(entries) do
			local is_current = entry.n == current
			local shown = is_current and SHRINK[1] or other
			local label = tostring(entry.n)

			if shown.kind then
				label = label .. ' ' .. entry.kind
			end

			if entry.title and shown.title > 0 then
				label = label .. ': ' .. truncate(entry.title, shown.title)
			end

			if is_current then
				label = '[' .. label .. ']'
			end

			table.insert(labels, label)
			local escaped = label:gsub('%%', '%%%%')

			---a header that still does not fit is cut after the current agent
			table.insert(
				items,
				is_current and ('%#TabLineSel#' .. escaped .. '%*%<') or escaped
			)
		end

		return table.concat(labels, HEADER_SEPARATOR),
			table.concat(items, HEADER_SEPARATOR)
	end

	---less the padding
	local available = vim.api.nvim_win_get_width(win) - 1
	local text, winbar

	for _, other in ipairs(SHRINK) do
		text, winbar = render(other)

		if vim.fn.strdisplaywidth(text) <= available then
			break
		end
	end

	return winbar
end

---Keep the header and the slots in step with the agent in `buf`
---@param buf number
local function watch(buf)
	vim.b[buf].ai_agent = true

	vim.api.nvim_create_autocmd('BufWinEnter', {
		buffer = buf,
		callback = function()
			vim.wo.winbar = HEADER
		end,
	})

	vim.api.nvim_create_autocmd('BufEnter', {
		buffer = buf,
		callback = function()
			last = slot_of(buf) or last
		end,
	})

	vim.api.nvim_create_autocmd('TermRequest', {
		buffer = buf,
		callback = function(ev)
			---OSC 0 and 2 set the title. Other sequences arrive far more often
			if ev.data.sequence:match('^\27%][02];') then
				redraw_headers()
			end
		end,
	})

	vim.api.nvim_create_autocmd('TermClose', {
		buffer = buf,
		once = true,
		callback = function()
			local n = slot_of(buf)

			if n then
				sessions[n] = nil
			end

			vim.schedule(function()
				if vim.api.nvim_buf_is_valid(buf) then
					if #vim.fn.win_findbuf(buf) == 0 then
						vim.api.nvim_buf_delete(buf, { force = true })
					else
						---shown with its exit status until the window moves on
						vim.bo[buf].bufhidden = 'wipe'
					end
				end

				redraw_headers()
			end)
		end,
	})
end

local show

---@param tui TUI
local function map_keys(tui)
	tui:map('t', ',t', function()
		if M.ctx and M.ctx ~= '' then
			tui:send_prompt(M.ctx)
		end
	end, { desc = 'Insert file context' })

	for n = 1, MAX_AGENTS do
		tui:map({ 'n', 't' }, '<c-' .. n .. '>', function()
			show(n)
		end, { desc = 'AI agent ' .. n })
	end
end

---Start an agent of the selected kind in slot `n`, in `win` or in a new
---window at `position`
---@param n number
---@param position? TUIPosition
---@param win? number
local function start(n, position, win)
	local spec = AGENTS[agent]
	local tui = TUI:new({ cmd = spec.cmd, ft = spec.ft, on_create = watch })

	map_keys(tui)
	sessions[n] = {
		kind = agent,
		tui = tui,
		dir = vim.fs.basename(vim.fn.getcwd()),
	}
	tui:create_term(nil, position, win)

	---not installed
	if not tui.buf then
		sessions[n] = nil
		return
	end

	last = n
	redraw_headers()
end

---Show agent `n` in the current window, in the mode the window is in, or
---start it there when its slot is free
---@param n number
function show(n)
	local win = vim.api.nvim_get_current_win()

	if is_free(n) then
		return start(n, nil, win)
	end

	local tui = sessions[n].tui
	tui.insert = vim.fn.mode() == 't'
	vim.api.nvim_win_set_buf(win, tui.buf)
end

---Close the agent window when one is open. Otherwise open the agent shown
---last, else the lowest-numbered running one, else start one
---@param position? TUIPosition
function M.toggle(position)
	local win = find_agent_win()

	if win then
		return vim.api.nvim_win_close(win, false)
	end

	local n = is_running(last) and last or lowest(is_running)

	if n then
		sessions[n].tui:open_term_buf_in_win(position)
	else
		start(lowest(is_free) --[[@as number]], position)
	end
end

function M.toggle_right()
	M.toggle('right')
end

---Start an agent of the selected kind in the lowest free slot, in the agent
---window when one is open, otherwise in a float
function M.new()
	local n = lowest(is_free)

	if not n then
		vim.notify(
			'All ' .. MAX_AGENTS .. ' AI agents are running',
			vim.log.levels.WARN
		)
		return
	end

	start(n, nil, find_agent_win())
end

---Set the kind new agents start as, for this and every new Neovim instance.
---Running agents keep running
---@param name string
function M.set_agent(name)
	if not AGENTS[name] then
		vim.notify('Unknown AI agent: ' .. name, vim.log.levels.ERROR)
		return
	end

	vim.fn.mkdir(vim.fs.dirname(STATE_FILE), 'p')
	vim.fn.writefile({ name }, STATE_FILE)
	agent = name

	vim.notify('AI agent: ' .. name)
end

---Remember the file reference `,t` inserts. An agent's own terminal is not a
---file, so pressed in an agent window this keeps the reference it has
---@param opts { range: number, line1?: number, line2?: number }
local function capture_ctx(opts)
	if not vim.b.ai_agent then
		M.ctx = context.get_curr_context(opts)
	end
end

---Pick a kind of AI agent from a list and start one
function M.select_agent()
	vim.ui.select(vim.tbl_keys(AGENTS), {
		prompt = 'AI agent (current: ' .. agent .. ')',
	}, function(name)
		if not name then
			return
		end

		M.set_agent(name)
		---same file reference `PromptAI` captures without a range
		capture_ctx({ range = 0 })
		M.new()
	end)
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
		capture_ctx(opts)
		M.toggle(opts.fargs[1])
	end, { range = true, nargs = '?' })
end

return M
