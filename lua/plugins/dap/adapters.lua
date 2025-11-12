local dap = require('dap')

-- Node.js / JavaScript / TypeScript
-- Requires: npm install -g vscode-js-debug
dap.adapters['pwa-node'] = {
	type = 'server',
	host = 'localhost',
	port = '${port}',
	executable = {
		command = 'js-debug-adapter',
		args = { '${port}' },
	},
}

dap.configurations.javascript = {
	{
		type = 'pwa-node',
		request = 'launch',
		name = 'Launch file',
		program = '${file}',
		cwd = '${workspaceFolder}',
	},
	{
		type = 'pwa-node',
		request = 'attach',
		name = 'Attach',
		processId = require('dap.utils').pick_process,
		cwd = '${workspaceFolder}',
	},
}

dap.configurations.typescript = dap.configurations.javascript

-- Python
-- Requires: pip install debugpy
dap.adapters.python = {
	type = 'executable',
	command = 'python',
	args = { '-m', 'debugpy.adapter' },
}

dap.configurations.python = {
	{
		type = 'python',
		request = 'launch',
		name = 'Launch file',
		program = '${file}',
		pythonPath = function()
			return '/usr/bin/python'
		end,
	},
}

-- Go
-- Requires: go install github.com/go-delve/delve/cmd/dlv@latest
dap.adapters.go = {
	type = 'server',
	port = '${port}',
	executable = {
		command = 'dlv',
		args = { 'dap', '-l', '127.0.0.1:${port}' },
	},
}

dap.configurations.go = {
	{
		type = 'go',
		name = 'Debug',
		request = 'launch',
		program = '${file}',
	},
	{
		type = 'go',
		name = 'Debug test',
		request = 'launch',
		mode = 'test',
		program = '${file}',
	},
}

-- Rust
-- Requires: codelldb extension
dap.adapters.codelldb = {
	type = 'server',
	port = '${port}',
	executable = {
		command = 'codelldb',
		args = { '--port', '${port}' },
	},
}

dap.configurations.rust = {
	{
		name = 'Launch',
		type = 'codelldb',
		request = 'launch',
		program = function()
			return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
		end,
		cwd = '${workspaceFolder}',
		stopOnEntry = false,
	},
}
