local context = require('utils.context')

local M = {}

---@return boolean
local function has_speak()
	if vim.fn.executable('speak') == 1 then
		return true
	end

	vim.notify('speak is not on PATH', vim.log.levels.WARN)
	return false
end

---Run `speak` in the background and report a failure once it exits
---@param args string[]
---@param stdin string|nil
local function run(args, stdin)
	vim.system(
		vim.list_extend({ 'speak' }, args),
		{ stdin = stdin, text = true },
		function(result)
			if result.code == 0 then
				return
			end

			vim.schedule(function()
				vim.notify(
					'speak failed: ' .. vim.trim(result.stderr or ''),
					vim.log.levels.ERROR
				)
			end)
		end
	)
end

---Read the visual selection aloud, or the whole buffer in normal mode
function M.read()
	if not has_speak() then
		return
	end

	local selection = context.get_visual()
	local text = selection and context.selection_text(selection)
		or table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n')

	if text:match('^%s*$') then
		vim.notify('Nothing to read', vim.log.levels.WARN)
		return
	end

	run({}, text)
end

---Stop the read in progress
function M.stop()
	if not has_speak() then
		return
	end

	run({ '--stop' })
end

return M
