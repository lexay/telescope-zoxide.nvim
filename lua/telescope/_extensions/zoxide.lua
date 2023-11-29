local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
  error("This extension requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)")
end

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
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
      attach_mappings = function(bufnr, map)
        actions.select_default:replace(function()
          actions.close(bufnr)
          local selection = action_state.get_selected_entry()
          vim.cmd("cd " .. selection[1])
          print("CWD changed to " .. selection[1])
        end)
        return true
      end,
    })
    :find()
end

return telescope.register_extension({
  exports = {
    zoxide = M.netrw_zi,
  },
})
