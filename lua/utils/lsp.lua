local M = {}

M.action = setmetatable({}, {
	__index = function(_, action)
		return function()
			vim.lsp.buf.code_action({
				apply = true,
				context = {
					only = { action },
					diagnostics = {},
				},
			})
		end
	end,
})

---@alias utils.lsp.State 'attached' | 'running' | 'idle'

local STATE_ORDER = { attached = 1, running = 2, idle = 3 }

---@type table<utils.lsp.State, { label: string, dot: string, hl: string }>
local STATES = {
	attached = { label = 'attached here', dot = '●', hl = 'DiagnosticOk' },
	running = { label = 'running elsewhere', dot = '○', hl = 'DiagnosticInfo' },
	idle = { label = 'not running', dot = '·', hl = 'Comment' },
}

-- Deeper nesting or longer nested lists say nothing useful in a preview pane
local MAX_DEPTH = 8
local MAX_ENTRIES = 20

---Names of the servers this config enables, plus every server that is running
---@return table<string, true>
local function server_names()
	local names = {} ---@type table<string, true>

	for _, name in ipairs(require('lsp').servers) do
		names[name] = true
	end

	for _, client in ipairs(vim.lsp.get_clients()) do
		names[client.name] = true
	end

	return names
end

---@param name string
---@return utils.lsp.State
local function state(name)
	if #vim.lsp.get_clients({ bufnr = 0, name = name }) > 0 then
		return 'attached'
	elseif #vim.lsp.get_clients({ name = name }) > 0 then
		return 'running'
	end

	return 'idle'
end

---Every server this config enables, plus every running server, with its state
---@return { name: string, state: utils.lsp.State }[]
local function server_states()
	local servers = {}
	for name in pairs(server_names()) do
		table.insert(servers, { name = name, state = state(name) })
	end

	table.sort(servers, function(a, b)
		if a.state ~= b.state then
			return STATE_ORDER[a.state] < STATE_ORDER[b.state]
		end

		return a.name < b.name
	end)

	return servers
end

---The config the server resolves to: what this config sets, merged with the
---defaults Neovim ships for it
---@param name string
---@return table
local function resolve_config(name)
	-- Indexing `vim.lsp.config` runs an `lsp/<name>.lua` from 'runtimepath', so
	-- one broken server file must not take the whole list down
	local ok, config = pcall(function()
		return vim.lsp.config[name]
	end)

	if not ok or type(config) ~= 'table' then
		return {}
	end

	return config
end

---@param value table
---@return boolean
local function has_nested_tables(value)
	for _, item in pairs(value) do
		if type(item) == 'table' then
			return true
		end
	end

	return false
end

---Copy of `value` that can be printed as Lua source: functions become markers
---and tables too big to read collapse into a count
---@param value any
---@param depth number
---@return any
local function printable(value, depth)
	if type(value) == 'function' then
		return '<function, resolved at server start>'
	end

	if type(value) ~= 'table' then
		return value
	end

	if depth <= 0 then
		return '<...>'
	end

	-- Long lists of plain values print on one line, so only nested tables are
	-- worth collapsing: jsonls' schemastore list alone is thousands of rows
	local count = vim.tbl_count(value)
	if count > MAX_ENTRIES and has_nested_tables(value) then
		return ('<%d entries>'):format(count)
	end

	local out = {}
	for key, item in pairs(value) do
		out[key] = printable(item, depth - 1)
	end

	return out
end

---The values a running server resolved when it started, which the config alone
---cannot show because they are functions
---@param name string
---@return string[]
local function client_lines(name)
	local lines = {}

	for _, client in ipairs(vim.lsp.get_clients({ name = name })) do
		table.insert(lines, ('-- client %d is running with:'):format(client.id))
		table.insert(
			lines,
			('--   cmd = %s'):format((vim.inspect(client.config.cmd):gsub('\n', ' ')))
		)
		table.insert(
			lines,
			('--   root_dir = %s'):format(client.config.root_dir or 'none')
		)
	end

	return lines
end

---@param name string
---@param server_state utils.lsp.State
---@return string
local function preview(name, server_state)
	local lines = {
		('-- %s — %s'):format(name, STATES[server_state].label),
	}

	vim.list_extend(lines, client_lines(name))

	local config = printable(resolve_config(name), MAX_DEPTH)
	if config.capabilities then
		config.capabilities = '<merged default capabilities>'
	end
	if config.handlers then
		config.handlers = '<default handlers>'
	end

	table.insert(lines, '')
	table.insert(
		lines,
		('return %s'):format(vim.inspect(config, { newline = '\n', indent = '  ' }))
	)

	return table.concat(lines, '\n')
end

---@param item snacks.picker.Item
---@return snacks.picker.Highlight[]
local function format(item)
	local server_state = STATES[item.state]

	return {
		{ server_state.dot .. ' ', server_state.hl },
		{ item.name, item.state == 'idle' and 'Comment' or 'SnacksPickerLabel' },
		{ '  ' .. server_state.label, server_state.hl },
	}
end

---Read-only picker listing every LSP server and the config it resolves to
function M.show()
	local items = {}
	for _, server in ipairs(server_states()) do
		table.insert(items, {
			text = ('%s %s'):format(server.name, STATES[server.state].label),
			name = server.name,
			state = server.state,
			resolve = function(item)
				item.preview = {
					text = preview(item.name, item.state),
					ft = 'lua',
				}
			end,
		})
	end

	require('snacks').picker.pick({
		title = 'LSP servers',
		items = items,
		format = format,
		preview = 'preview',
		-- Snacks closes on the second <esc> by default (the first leaves insert
		-- mode); this viewer is read-only, so one press should close it
		win = {
			input = {
				keys = { ['<Esc>'] = { 'close', mode = { 'n', 'i' } } },
			},
		},
		confirm = function(picker)
			picker:close()
		end,
	})
end

return M
