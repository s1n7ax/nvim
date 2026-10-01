---
name: keymap-conventions
description: Leader-key layout conventions for this nvim config. Use whenever adding, editing, or reviewing a keymap — choosing a leader prefix, a group letter, or a second letter within a `<leader><group>` pair.
---

## Keymap conventions

- `,<key>` (comma leader) is reserved for the most frequently used commands.
- `<leader>u<key>` (Toggle group) is for choice selections (`vim.ui.select` style menus) and toggles — anything infrequent that flips a setting or picks from a list, e.g. switching the AI agent, spell check, auto-format, markdown rendering.
- For other `<leader><group><key>` groups, assign the second letter by frequency: doubled group letter (e.g. `ee`) for the single most-used command, then `n`/`t`, then `e`/`s`, then `o`/`a`, then `i`/`r`.
