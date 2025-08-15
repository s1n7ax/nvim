local M = {}

-- Import all utility modules
M.keymaps = require('utils.keymaps')
M.windows = require('utils.windows')
M.editing = require('utils.editing')

-- Re-export commonly used functions for backwards compatibility
M.mapper = M.keymaps.mapper

return M
