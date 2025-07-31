# My Neovim Configuration

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

## Plugin Keymaps (Frequency-Based)

### Comma-based (Most Frequent) - Left Hand Home Row
- `,,` - Find files (snacks.picker.files)
- `,a` - Zen mode (snacks.zen)
- `,d` - Insert log below (timber)
- `,r` - Open/close file explorer (oil)

### Snacks (`<leader>n`) - Most Frequent Plugin
- `<leader>nn` - Find lines
- `<leader>nt` - Find diagnostics  
- `<leader>ns` - Find git branches
- `<leader>nr` - Find workspace symbols
- `<leader>na` - Find keymaps
- `<leader>ne` - Find commands
- `<leader>ni` - Find symbols
- `<leader>nl` - Find help

### Overseer (`<leader>e`) - Task Runner
- `<leader>ee` - Toggle task list
- `<leader>en` - Run task
- `<leader>ei` - Quick action recent task
- `<leader>et` - Overseer info
- `<leader>es` - Task builder
- `<leader>er` - Task action
- `<leader>ea` - Clear cache
- `<leader>el` - Load bundle

### Git Tools (`<leader>i`) - Diffview & Gitlinker
- `<leader>ii` - Git diff file (diffview)
- `<leader>in` - Git diff branch (diffview)
- `<leader>ie` - Copy git link (gitlinker)

### Comment Frame (`<leader>t`) - Least Frequent
- `<leader>tt` - Add comment frame
- `<leader>tn` - Add multiline comment frame

### Harpoon - File Navigation
- `,l` - Add file to harpoon
- `,L` - Open harpoon UI
- `<C-1>` to `<C-5>` - Navigate to harpoon files 1-5

### Kulala (`<leader>r`) - REST Client
- `<leader>ra` - Send all requests
- `<leader>rs` - Send the request
- `<leader>rt` - Toggle headers/body view
- `<leader>re` - Jump to previous request
- `<leader>rn` - Jump to next request

### Motion & Navigation Plugins
- `s` - Hop to word
- `M` - Hop to line
- `r` - Remote Flash (operator mode)
- `S` - Flash Treesitter (normal/operator/visual)
- `R` - Treesitter Search (normal)
- `w` - Enhanced word forward (spider)
- `l` - Enhanced end-of-word (spider, remapped from `e`)
- `b` - Enhanced word backward (spider)

### Text Manipulation
- `<C-m>/<C-i>/<C-n>/<C-e>` - Move text left/right/down/up (mini-move)
- `<C-a>/<C-x>` - Increment/decrement numbers (dial)
- `g<C-a>/g<C-x>` - Global increment/decrement (dial)
- `cw`/`dw` - Change/delete to end of word (spider, remapped to `ce`/`de`)

### Window Management
- `<C-w>m` - Enter WinShift mode
- `zR`/`zM` - Open/close all folds (ufo)

### Completion & Snippets
- `<C-space>` - Show completion (blink)
- `<C-n>/<C-e>` - Navigate completion up/down (blink)
- `<CR>` - Accept completion (blink)
- `<C-i>` - Expand snippet or jump next (luasnip)

### LSP & File Operations
- `gd` - Go to definition
- `I` - LSP hover info
- `]d`/`[d` - Next/previous diagnostic
- `<leader>yp` - Copy file path
- `<leader>yn` - Copy file name

## Adding LSP Servers

1. Create config in `lsp/<server>.lua`
2. Add `vim.lsp.enable('<server>')` to `init.lua`

## Why This Config?

- Native `vim.pack` - no plugin managers
- Modern LSP with simple activation
- Built specifically for Colemak users
- Fast and minimal
