local snacks = require('snacks')

local M = {}

---lazygit writes the directory it is in to `LAZYGIT_NEW_DIR_FILE` whenever it
---switches worktree, submodule or repo, and when it quits
local dir_file = vim.fn.tempname()

---@type snacks.win?
local term

---Root of the repo the running lazygit is in
---@type string?
local term_root

---@param path string
---@return string? root real path of the git worktree containing `path`
local function git_root(path)
	local root = vim.fs.root(path, '.git')
	return root and vim.uv.fs_realpath(root)
end

---@return string? dir lazygit recorded since the last call
local function recorded_dir()
	local file = io.open(dir_file)
	if not file then
		return
	end
	local dir = file:read('*l')
	file:close()
	os.remove(dir_file)
	return dir
end

---Change nvim's cwd to the repo lazygit switched to. Runs whenever the lazygit
---window closes, both when it is hidden and when lazygit quits
local function follow()
	local dir = recorded_dir()
	local root = dir and git_root(dir)

	if not root then
		return
	end

	term_root = root

	if root == git_root(vim.fn.getcwd()) then
		return
	end

	vim.schedule(function()
		vim.api.nvim_set_current_dir(root)
		vim.notify('cwd: ' .. vim.fn.fnamemodify(root, ':~'))
	end)
end

---Toggle lazygit. The running instance is reused as long as it is in the repo
---nvim is in, so it keeps its state across worktree switches
function M.toggle()
	if term and term:buf_valid() then
		if term:valid() or term_root == git_root(vim.fn.getcwd()) then
			term:toggle()
			return
		end

		-- nvim moved to another repo on its own, this instance would show the old
		term:close()
	end

	term_root = git_root(vim.fn.getcwd())
	term = snacks.lazygit({
		env = { LAZYGIT_NEW_DIR_FILE = dir_file },
		win = { on_close = follow },
	})
end

return M
