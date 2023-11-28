local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
  error("This extension requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)")
end

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local io = require("io")

local M = {}

M.netrw_zi = function(opts)
  local command = "zoxide query --list"
  local handle = io.popen(command)
  local entries = handle:read("a")
  handle.close()

  local results = {}
  for line in entries:gmatch("[^\r\n]+") do
    table.insert(results, line)
  end

  opts = opts or {}

  pickers
    .new(opts, {
      prompt_title = "Change directory",
      finder = finders.new_table({
        results = results,
      }),
      sorter = conf.generic_sorter(opts),
    })
    :find()
end

return telescope.register_extension({
  exports = {
    zoxide = M.netrw_zi,
  },
})
