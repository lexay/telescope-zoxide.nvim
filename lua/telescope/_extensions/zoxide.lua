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
  local command = "zoxide query --list"
  local handle = io.popen(command)
  local entries = handle:read("a")
  handle.close()

  local results = {}
  for line in entries:gmatch("[^\r\n]+") do
    table.insert(results, line)
  end
  return results
end


  opts = opts or {}

  pickers
    .new(opts, {
      prompt_title = "Change directory",
      finder = finders.new_table({
        results = results,
        results = _G.zoxide_list(),
      }),
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(bufnr, map)
        actions.select_default:replace(function()
          actions.close(bufnr)
          local selection = action_state.get_selected_entry()
          vim.api.nvim_set_current_dir(selection[1])
          print(vim.fn.getcwd())

          local all_buffs = vim.api.nvim_list_bufs()
          local unnamed_buf

          for _, i in ipairs(all_buffs) do
            if vim.api.nvim_buf_get_option(i, "buflisted") and vim.api.nvim_buf_get_name(i) == "" then
              unnamed_buf = i
            end
          end

          if not unnamed_buf then
            unnamed_buf = vim.api.nvim_create_buf(true, false)
          end

          vim.api.nvim_set_current_buf(unnamed_buf)
        end)
        return true
      end,
    })
    :find()
end

return telescope.register_extension({
  exports = {
    zoxide = M.zi,
  },
})
