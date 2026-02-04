# AGENTS.md

Guidance for AI coding agents working in this Neovim configuration repository.

## Build/Lint/Test Commands

### Formatting
```bash
stylua .                    # Format all Lua files
stylua lua/path/to/file.lua # Format single file
```

### Validation
```bash
nvim --headless -c "lua require('init')" -c "qa"  # Test config loads
nvim -u init.lua +checkhealth +qa                 # Run health checks
```

### LSP Check
```bash
lua-language-server --check lua/  # Static analysis
```

## Architecture Overview

Native Neovim package system using `vim.pack.add()` - NOT LazyVim or any plugin manager.

### Directory Structure
```
init.lua                    # Entry point: leader keys, requires modules
lua/
├── options.lua             # Neovim settings
├── keymaps.lua             # Colemak-optimized keymaps
├── autocmd.lua             # Auto commands
├── diagnostics.lua         # Diagnostic configuration
├── lsp.lua                 # LSP server list and configs
├── constants.lua           # Icons and shared constants
├── utils/
│   ├── init.lua            # Utils module aggregator
│   ├── keymaps.lua         # Keymap helper (mapper function)
│   ├── editing.lua         # Text editing utilities
│   ├── lsp.lua             # LSP utilities
│   └── clipboard.lua       # Clipboard utilities
└── plugins/
    └── {plugin}/init.lua   # Each plugin in own directory
```

## Code Style Guidelines

### Formatting (StyLua)
- **Indentation**: Tabs, width 2
- **Line length**: 80 characters max
- **Quotes**: Single quotes preferred (`'string'`)
- **Parentheses**: Always use call parentheses

### Module Structure
```lua
-- Standard module pattern
local M = {}

function M.public_function()
    -- implementation
end

local function private_function()
    -- implementation
end

return M
```

### Imports
```lua
-- External requires at top
local snacks = require('snacks')
local utils = require('utils')

-- Destructure commonly used functions
local mapper = utils.mapper
```

### Keymaps
Use the `mapper` utility for consistent keymap creation:
```lua
local utils = require('utils')
local nmap = utils.mapper('n')
local amap = utils.mapper({ 'n', 'o', 'x' })

nmap({
    { '<leader>key', action, 'Description' },
    { '<leader>key2', action2, { desc = 'Description', silent = true } },
})
```

### Plugin Configuration
Plugins are added in two places:

1. **`lua/plugins/init.lua`** - Register plugin URL and import config:
```lua
vim.pack.add({
    -- ... other plugins
    'https://github.com/author/plugin-name',
})

-- ... other requires
require('plugins.plugin-name')
```

2. **`lua/plugins/{name}/init.lua`** - Plugin configuration only:
```lua
local plugin = require('plugin-name')
local utils = require('utils')
local nmap = utils.mapper('n')

-- Keymaps first (if any)
nmap({
    { '<leader>xx', plugin.action, 'Plugin action' },
})

-- Setup call
plugin.setup({
    option = value,
})
```

### Naming Conventions
- **Variables**: `snake_case` for locals and module fields
- **Functions**: `snake_case`
- **Constants**: `SCREAMING_SNAKE_CASE` for true constants
- **Modules**: Return table named `M`

### Colemak Keyboard Layout
Navigation remapped from `hjkl` to `mnei`:
- `m` = left, `n` = down, `e` = up, `i` = right
- `h` = insert mode (replaces `i`)
- Window nav: `<C-m/n/e/i>`
- Window split: `<A-m/n/e/i>`

### Keymap Organization (Frequency-Based)
1. **Comma-based** (most frequent): `,,`, `,a`, `,d`, `,s`
2. **Leader groups** (by frequency): `<leader>t` (snacks), `<leader>n` (LSP)
3. **Native replacements**: Enhance existing keymaps, don't create new groups

### Error Handling
```lua
-- Use pcall for potentially failing operations
local ok, result = pcall(require, 'optional-module')
if ok then
    result.setup({})
end

-- Use pcall for API calls that might fail
pcall(vim.api.nvim_win_set_width, win, width)
```

### Auto Commands
```lua
vim.api.nvim_create_autocmd('EventName', {
    group = vim.api.nvim_create_augroup('GroupName', { clear = true }),
    pattern = '*',
    callback = function()
        -- implementation
    end,
})
```

### LSP Configuration
Add servers to `lua/lsp.lua`:
```lua
M.servers = {
    'server_name',
    -- ...
}

vim.lsp.config('server_name', {
    settings = { ... },
})

vim.lsp.enable(M.servers)
```

## Important Patterns

### stylua: ignore
Use `-- stylua: ignore` comment to prevent formatting specific blocks:
```lua
-- stylua: ignore
nmap({
    { 'key1', action1, 'desc' },
    { 'key2', action2, 'desc' },
})
```

### Adding New Plugins
1. Add URL to `lua/plugins/init.lua` vim.pack.add list
2. Create `lua/plugins/{name}/init.lua`
3. Configure plugin with setup call
4. Add keymaps using mapper utility

### Constants and Icons
Use shared icons from `lua/constants.lua`:
```lua
local constants = require('constants')
local icons = constants.icons.diagnostics
```

## What NOT to Do
- Don't use LazyVim specs or return plugin specs
- Don't use `h/j/k/l` for navigation (use `m/n/e/i`)
- Don't create semantic keymaps (use frequency-based positions)
- Don't add single-line comments for implementation code
- Only add doc comments for high-level public APIs
