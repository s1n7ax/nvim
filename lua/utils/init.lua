local M = {}

M.keymaps = require('utils.keymaps')
M.editing = require('utils.editing')
M.lsp = require('utils.lsp')
M.opencode = require('utils.opencode')

M.mapper = M.keymaps.mapper

return M
