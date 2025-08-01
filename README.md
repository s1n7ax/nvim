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

### Core Navigation (Colemak Remapped)
- Navigate: `m/n/e/i` (left/down/up/right) - replaces hjkl
- Insert: `h` - replaces i
- Marks: `j` - replaces m  
- Find next: `k` - replaces n
- End of word: `l` - replaces e

### Core Keymaps
- `<C-s>` - Save file
- `<C-d>` - Close/quit
- `<C-m/n/e/i>` - Window navigation
- `<A-m/n/e/i>` - Window splitting
- `gd` - LSP go to definition
- `I` - LSP hover info
- `]d/[d` - Next/previous diagnostic
- `<leader>yp/yn` - Copy file path/name

### Insert Mode Enhancements
- `<C-c>` - Escape
- `<C-s>` - Save
- `<C-v>` - Paste
- `<M-a/e>` - Jump to line start/end
- `<M-k>` - Delete line
- `<M-y>` - Duplicate line

## Plugin Keymaps (Frequency-Based)

### Comma-based (Most Frequent)
- `,,` - Find files (snacks.picker.files)
- `,a` - Zen mode (snacks.zen)
- `,d` - Insert log below (timber)
- `,t` - Open/close file explorer (oil)
- `,l` - Add file to harpoon
- `,L` - Open harpoon UI
- `,n` - Init/expand treesitter selection
- `,s` - Scope incremental selection
- `,e` - Node decremental selection

### Snacks (`<leader>n`) - Picker/Finder
- `<leader>nn` - Find lines
- `<leader>nt` - Find diagnostics  
- `<leader>ns` - Find git branches
- `<leader>nr` - Find workspace symbols
- `<leader>na` - Find keymaps
- `<leader>ne` - Find commands
- `<leader>ni` - Find symbols
- `<leader>no` - Find buffers
- `<leader>nh` - Find help
- `<leader>/` - Find text (grep)

### LSP Navigation (Snacks)
- `<C-t>` - Go to definition
- `<C-s>` - Go to implementation
- `<C-r>` - Find references

### Overseer (`<leader>e`) - Task Runner
- `<leader>ee` - Toggle task list
- `<leader>en` - Run task
- `<leader>ei` - Quick action
- `<leader>et` - Overseer info
- `<leader>es` - Task builder
- `<leader>er` - Task action
- `<leader>ea` - Clear cache
- `<leader>el` - Load bundle

### Git Tools (`<leader>i`) - Diffview & Gitlinker
- `<leader>ii` - Git diff file
- `<leader>in` - Git diff branch  
- `<leader>ie` - Copy git link

### Kulala (`<leader>r`) - REST Client
- `<leader>ra` - Run all requests
- `<leader>rs` - Send request
- `<leader>rt` - Toggle view
- `<leader>re` - Previous request
- `<leader>rn` - Next request

### Comment Frame (`<leader>t`)
- `<leader>tt` - Add comment frame
- `<leader>tn` - Add multiline comment frame

### File Navigation & Bookmarks
- `<C-1>` to `<C-5>` - Navigate to harpoon files 1-5

### Motion & Navigation Plugins
- `s` - Hop to word
- `M` - Hop to line
- `S` - Flash treesitter (all modes)
- `R` - Treesitter search (normal)
- `r` - Remote flash (operator-pending)
- `w` - Enhanced word forward (spider)
- `l` - Enhanced end-of-word (spider)
- `b` - Enhanced word backward (spider)

### Completion (Blink.cmp)
- `<C-space>` - Show completion
- `<C-n>` - Next completion item
- `<C-e>` - Previous completion item
- `<CR>` - Accept completion

### Text Objects (Treesitter)
**Around/Inside pairs (Colemak 'a'/'h')**:
- `ak/hk` - Around/inside block
- `ac/hc` - Around/inside class
- `af/hf` - Around/inside function
- `al/hl` - Around/inside loop
- `aa/ha` - Around/inside argument
- `a?/h?` - Around/inside conditional

### Text Manipulation
- `<C-a>/<C-x>` - Increment/decrement numbers (dial)
- `g<C-a>/g<C-x>` - Global increment/decrement (dial)
- `cw` → `ce`, `dw` → `de` - Word operation remaps (spider)

### Folding (UFO)
- `zR` - Open all folds
- `zM` - Close all folds

### Window Management (WinShift)
- `<C-w>m` - Enter window shift mode
- In shift mode: `m/n/e/i` - Move window directionally


## Adding LSP Servers

1. Create config in `lsp/<server>.lua`
2. Add `vim.lsp.enable('<server>')` to `init.lua`

## Why This Config?

- Native `vim.pack` - no plugin managers
- Modern LSP with simple activation
- Built specifically for Colemak users
- Fast and minimal
