local M = {}

M.keymaps = require('utils.keymaps')
M.editing = require('utils.editing')
M.lsp = require('utils.lsp')
M.opencode = require('utils.opencode')
M.git = require('utils.git')
M.tui = require('utils.tui')
M.context = require('utils.context')

M.mapper = M.keymaps.mapper

return M
