--- Lazy-loading layer over |vim.pack|.
---
--- A spec is a `vim.pack.Spec` plus optional triggers. A spec with at least one
--- trigger is kept off 'runtimepath' during startup and handed to
--- `vim.pack.add()` only when a trigger fires. A spec with no trigger is added
--- during startup, exactly like a plain `vim.pack.add()` call.
---
--- Triggers (any combination; the first to fire loads the plugin):
---   `event`  autocmd event name(s). The pseudo-event `VeryLazy` fires once,
---            on the first event-loop tick after startup finished.
---   `ft`     filetype(s), via a `FileType` autocmd.
---   `cmd`    user command name(s). A stub command is created and replays the
---            original command line once the real one is defined.
---   `keys`   `lhs` strings, or `{ mode, lhs }` pairs (mode defaults to `n`).
---            A stub mapping is created and replays the key once loaded.
---   `mod`    lua module prefix(es). `require()`ing anything under one of them
---            loads the plugin first. This is how libraries stay lazy.
---
--- `dep` names other specs to load first. `init` runs during startup, for the
--- options, autocmds and commands that have to exist before the plugin does,
--- and `config` runs right after the plugin lands on 'runtimepath'.

local M = {}

local PACK_DIR =
	vim.fs.joinpath(vim.fn.stdpath('data'), 'site', 'pack', 'core', 'opt')

---@class LazySpec : vim.pack.Spec
---@field event? string|string[]
---@field ft? string|string[]
---@field cmd? string|string[]
---@field keys? (string|string[])[]
---@field mod? string|string[]
---@field dep? string|string[]
---@field init? fun()
---@field config? fun()

---@type table<string, LazySpec>
local specs = {}

---@type table<string, boolean>
local loaded = {}

--- Lua module prefix -> owning spec name.
---@type table<string, string>
local module_owner = {}

--- Spec name -> stub user commands awaiting removal.
---@type table<string, string[]>
local stub_cmds = {}

--- Spec name -> stub mappings awaiting removal, as `{ mode, lhs }`.
---@type table<string, string[][]>
local stub_keys = {}

local group = vim.api.nvim_create_augroup('LazyPack', { clear = true })

---@param value string|string[]|nil
---@return string[]
local function as_list(value)
	if value == nil then
		return {}
	end

	return type(value) == 'table' and value or { value }
end

---@param spec LazySpec
---@return string
local function spec_name(spec)
	return spec.name or (spec.src:gsub('%.git$', ''):match('[^/]+$'))
end

---@param spec LazySpec
---@return boolean
local function is_lazy(spec)
	return spec.event ~= nil
		or spec.ft ~= nil
		or spec.cmd ~= nil
		or spec.keys ~= nil
		or spec.mod ~= nil
end

--- Whether `name` is declared by the config. Lazy plugins spend most of a
--- session off 'runtimepath', so this - not `vim.pack.get().active` - is what
--- tells a wanted plugin apart from a leftover one.
---@param name string
---@return boolean
function M.is_declared(name)
	return specs[name] ~= nil
end

--- Adds a plugin to the session, running its dependencies and config.
--- Stubs registered for the plugin are removed first so that the real commands
--- and mappings defined by the plugin win.
---@param name string
function M.load(name)
	local spec = specs[name]

	if not spec or loaded[name] then
		return
	end

	loaded[name] = true

	for _, cmd in ipairs(stub_cmds[name] or {}) do
		pcall(vim.api.nvim_del_user_command, cmd)
	end

	for _, key in ipairs(stub_keys[name] or {}) do
		pcall(vim.keymap.del, key[1], key[2])
	end

	for _, dep in ipairs(as_list(spec.dep)) do
		M.load(dep)
	end

	vim.pack.add(
		{ { src = spec.src, name = name, version = spec.version } },
		{ confirm = false }
	)

	if spec.config then
		spec.config()
	end
end

--- Finds the spec that owns `modname`, matching the longest registered prefix
--- so that e.g. `mini.icons` and `mini.move` can be told apart.
---@param modname string
---@return string?
local function owner_of(modname)
	local key = modname

	while key do
		local name = module_owner[key]

		if name then
			return name
		end

		key = key:match('^(.*)%.[^.]+$')
	end
end

--- `package.loaders` entry that puts a plugin on 'runtimepath' the first time
--- one of its modules is required.
---
--- The plugin's own `config` usually requires the same module, which completes
--- while this searcher is still running. Returning the already-built module
--- keeps `require()` from sourcing the file a second time and handing out a
--- second copy.
---@param modname string
---@return (fun(): any)?
local function searcher(modname)
	local name = owner_of(modname)

	if not name or loaded[name] then
		return
	end

	M.load(name)

	local mod = package.loaded[modname]

	if mod ~= nil then
		return function()
			return mod
		end
	end
end

---@param name string
---@param spec LazySpec
local function register_events(name, spec)
	local events, pattern = {}, nil

	for _, event in ipairs(as_list(spec.event)) do
		if event == 'VeryLazy' then
			table.insert(events, 'User')
			pattern = 'VeryLazy'
		else
			table.insert(events, event)
		end
	end

	if #events == 0 then
		return
	end

	vim.api.nvim_create_autocmd(events, {
		group = group,
		pattern = pattern,
		once = true,
		desc = 'Lazy load ' .. name,
		callback = function()
			M.load(name)
		end,
	})
end

---@param name string
---@param spec LazySpec
local function register_ft(name, spec)
	local filetypes = as_list(spec.ft)

	if #filetypes == 0 then
		return
	end

	vim.api.nvim_create_autocmd('FileType', {
		group = group,
		pattern = filetypes,
		once = true,
		desc = 'Lazy load ' .. name,
		callback = function()
			M.load(name)
		end,
	})
end

--- Rebuilds the command line that triggered a stub so it can be re-run against
--- the real command.
---@param cmd string
---@param ev table
---@return string
local function replay_cmd(cmd, ev)
	local range = ''

	if ev.range == 1 then
		range = tostring(ev.line1)
	elseif ev.range == 2 then
		range = ev.line1 .. ',' .. ev.line2
	end

	return range .. cmd .. (ev.bang and '!' or '') .. ' ' .. ev.args
end

---@param name string
---@param spec LazySpec
local function register_cmds(name, spec)
	stub_cmds[name] = as_list(spec.cmd)

	for _, cmd in ipairs(stub_cmds[name]) do
		vim.api.nvim_create_user_command(cmd, function(ev)
			M.load(name)
			vim.cmd(replay_cmd(cmd, ev))
		end, {
			bang = true,
			range = true,
			nargs = '*',
			complete = 'file',
			desc = 'Lazy load ' .. name,
		})
	end
end

---@param name string
---@param spec LazySpec
local function register_keys(name, spec)
	stub_keys[name] = {}

	for _, key in ipairs(spec.keys or {}) do
		local mode, lhs = 'n', key

		if type(key) == 'table' then
			mode, lhs = key[1], key[2]
		end

		table.insert(stub_keys[name], { mode, lhs })

		vim.keymap.set(mode, lhs, function()
			M.load(name)

			local replay =
				vim.api.nvim_replace_termcodes('<Ignore>' .. lhs, true, true, true)
			vim.api.nvim_feedkeys(replay, 'm', false)
		end, { desc = 'Lazy load ' .. name })
	end
end

--- Declares every plugin of the config.
---@param list LazySpec[]
function M.setup(list)
	local eager, missing = {}, {}

	for _, spec in ipairs(list) do
		local name = spec_name(spec)
		specs[name] = spec

		for _, prefix in ipairs(as_list(spec.mod)) do
			module_owner[prefix] = name
		end

		if not is_lazy(spec) then
			table.insert(
				eager,
				{ src = spec.src, name = name, version = spec.version }
			)
		elseif not vim.uv.fs_stat(vim.fs.joinpath(PACK_DIR, name)) then
			table.insert(
				missing,
				{ src = spec.src, name = name, version = spec.version }
			)
		end
	end

	--- Plugins absent from disk are installed up front, so that a fresh clone of
	--- the config still pulls everything down in a single pass instead of
	--- stalling later on whichever key happens to be pressed first.
	vim.pack.add(vim.list_extend(eager, missing))

	table.insert(package.loaders, 1, searcher)

	for _, spec in ipairs(list) do
		local name = spec_name(spec)

		if is_lazy(spec) and not loaded[name] then
			register_events(name, spec)
			register_ft(name, spec)
			register_cmds(name, spec)
			register_keys(name, spec)
		end
	end

	for _, spec in ipairs(list) do
		if spec.init then
			spec.init()
		end
	end

	for _, spec in ipairs(list) do
		local name = spec_name(spec)

		if not is_lazy(spec) and not loaded[name] then
			loaded[name] = true

			if spec.config then
				spec.config()
			end
		end
	end

	vim.api.nvim_create_autocmd('VimEnter', {
		group = group,
		once = true,
		desc = 'Fire the VeryLazy pseudo-event',
		callback = function()
			vim.schedule(function()
				vim.api.nvim_exec_autocmds('User', { pattern = 'VeryLazy' })
			end)
		end,
	})
end

return M
