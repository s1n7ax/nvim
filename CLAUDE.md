# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Formatting
- `stylua .` - Format all Lua files using StyLua according to .stylua.toml configuration
- Format on save is enabled via conform.nvim for Lua files

### LSP Servers
- `lua-language-server` - Lua LSP (configured in lsp/lua_ls.lua)
- `deno lsp` - TypeScript/JavaScript LSP (configured in lsp/denols.lua)

## Architecture Overview

This is a personal Neovim configuration using a modular structure with the native Vim 9.0+ package system (vim.pack.add) instead of a traditional plugin manager.

### Core Structure
- `init.lua` - Entry point that enables LSP servers and loads main configuration
- `lua/s1n7ax/init.lua` - Sets leader keys and loads all modules
- `lua/s1n7ax/` - Main configuration namespace

### Key Components
- **Options** (`options.lua`) - Basic Neovim settings and window resize percentages
- **Keymaps** (`keymaps.lua`) - Custom Colemak keyboard layout remapping and shortcuts
- **Utils** (`utils/`) - Organized utility modules:
  - `utils/keymaps.lua` - Keymap utilities (mapper function)
  - `utils/windows.lua` - Window management and auto-resize functionality
- **Autocmd** (`autocmd.lua`) - Auto commands for yank highlighting and window events
- **Plugins** (`plugins/`) - Plugin configurations loaded via vim.pack.add

### Plugin Architecture
**IMPORTANT**: This configuration uses Neovim's native package system (vim.pack.add) NOT LazyVim or any other plugin manager. Plugin configurations should NOT return LazyVim specs but instead should directly configure the plugin using vim.pack.add() and native Neovim APIs.

**vim.pack.add() Usage**: vim.pack.add() takes a table with the full plugin URL:
```lua
vim.pack.add({ 'https://github.com/username/plugin-name' })
```

Each plugin is configured in its own subdirectory under `plugins/`:
- **blink** - Completion engine with custom Colemak keybindings
- **conform** - Code formatting with StyLua integration
- **lazydev** - Lua development support
- **oil** - File explorer
- **snacks** - Multi-purpose plugin (picker, dashboard, notifications)
- **themes** - Color scheme (Tokyo Night Moon)
- **treesitter** - Syntax highlighting and text objects

### Keyboard Layout
This configuration is heavily customized for the Colemak keyboard layout:
- Navigation uses `m/n/e/i` instead of `h/j/k/l`
- Text manipulation keys are remapped accordingly
- Completion uses `<c-n>/<c-e>` for navigation

### Window Management
Advanced window management with auto-resizing functionality:
- **Navigation**: `<C-m/n/e/i>` for left/down/up/right window navigation
- **Splitting**: `<Alt-m/n/e/i>` for left/down/up/right window splits
- **Auto-resize**: Focused window takes configurable percentage of space
- **Configuration**: 
  - `vim.g.s1n7ax_window_horizontal_percentage` (default: 0.7)
  - `vim.g.s1n7ax_window_vertical_percentage` (default: 0.7)
  - `vim.g.s1n7ax_window_ignore_filetypes` (default: oil, help, qf, etc.)
- **Smart filtering**: Ignores floating windows and specified filetypes

### LSP Configuration
LSP servers are configured in the `lsp/` directory:
- Each server has its own configuration file
- Enabled globally in init.lua with `vim.lsp.enable()`
- Supports Lua development and Deno-based TypeScript/JavaScript

### Code Style
- Uses tabs for indentation (width: 2)
- Line length: 80 characters
- Single quotes preferred for strings
- Configured via .editorconfig and .stylua.toml

## Working with this Configuration

When modifying this configuration:
1. Follow the modular structure - each plugin gets its own directory
2. Use utilities from `utils/` directory:
   - `utils.keymaps.mapper()` for consistent keymap creation
   - `utils.windows.*` for window management functions
3. Respect the Colemak layout customizations
4. Format code with StyLua before committing
5. LSP configuration changes go in the `lsp/` directory
6. Plugin configurations use vim.pack.add() for package management
7. Window management settings can be customized via global variables in `options.lua`

## Features

### Yank Highlighting
- Visual feedback when yanking text (timeout: 100ms)
- Custom highlight group: `YankHighlight`

### Window Auto-Resize
- Automatically resizes windows when navigating between them
- Respects floating windows and ignored filetypes
- Configurable resize percentages for horizontal and vertical splits