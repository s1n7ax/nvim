# s1n7ax's Neovim Configuration

Modern Neovim config for Colemak users. Uses native `vim.pack` and latest LSP architecture.

## Features

- **Colemak-optimized**: Complete key remapping for Colemak layout
- **Native packages**: Uses `vim.pack.add()` - no plugin managers
- **Modern LSP**: Simple `vim.lsp.enable('<name>')` activation
- **Fast startup**: Minimal, performance-focused

## Components

- **UI**: Tokyo Night Moon, clean statuscolumn, snacks.nvim
- **Completion**: Blink.cmp with LSP integration
- **Navigation**: Snacks picker, Oil file manager, Treesitter
- **LSP**: `lsp/` directory, `vim.lsp.enable()` activation
- **Formatting**: conform.nvim with StyLua

## Installation

```bash
mv ~/.config/nvim ~/.config/nvim.backup
git clone <repo-url> ~/.config/nvim
nvim
```

## Colemak Keys

- Navigate: `m/n/e/i` (left/down/up/right)
- Insert: `h`
- Find files: `,,`
- Search: `<leader>/`
- Completion: `<C-n>/<C-e>` to navigate

## Adding LSP Servers

1. Create config in `lsp/<server>.lua`
2. Add `vim.lsp.enable('<server>')` to `init.lua`

## Why This Config?

- Native `vim.pack` - no plugin managers
- Modern LSP with simple activation
- Built specifically for Colemak users
- Fast and minimal
