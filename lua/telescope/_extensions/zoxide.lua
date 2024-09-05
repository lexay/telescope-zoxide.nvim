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

function _G.zoxide_list()
  local command = "zoxide query --list --score"
  local handle = io.popen(command)
  local entries = handle:read("a")
  handle.close()

  local results = {}
  for line in entries:gmatch("[^\r\n]+") do
    table.insert(results, line)
  end
  return results
end

local function remap(bufnr, command)
  return function()
    actions.close(bufnr)
    vim.cmd(command)
    local selection = action_state.get_selected_entry()
    local path = selection[1]:match("/.*") or selection[1]:match("%a:[\\/].*")
    if command == "tabnew" then
      vim.cmd("tcd " .. path)
    else
      vim.cmd("lcd " .. path)
    end
    print(vim.fn.getcwd())
    io.popen("zoxide add " .. path):close()
  end
end

local function zi(opts)
  opts = opts or {}

  pickers
    .new(opts, {
      prompt_title = "Change Directory",
      finder = finders.new_table({
        results = _G.zoxide_list(),
      }),
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(bufnr, map)
        actions.select_default:replace(remap(bufnr, "enew"))
        actions.select_vertical:replace(remap(bufnr, "vnew"))
        actions.select_tab:replace(remap(bufnr, "tabnew"))
        return true
      end,
    })
    :find()
end

return telescope.register_extension({
  exports = {
    zi = zi,
    zoxide = zi,
  },
})
