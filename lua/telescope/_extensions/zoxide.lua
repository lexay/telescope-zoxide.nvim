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

local function find_existing_bufname(path)
  local all_buffers = vim.api.nvim_list_bufs()
  local separator = path:match("[\\/]")

  if path == "/" then
    separator = ""
  end

  for _, buf in ipairs(all_buffers) do
    local bufname = vim.api.nvim_buf_get_name(buf)
    if bufname:find(path .. separator, 1, true) then
      return bufname
    end
  end
end

local function open_new_buf(wintype)
  local commands = {
    default = "enew",
    horizontal = "new",
    vertical = "vnew",
    tab = "tabnew",
  }

  vim.cmd(commands[wintype])
end

local function open_existing_buf(bufname, wintype)
  local commands = {
    default = "edit",
    horizontal = "split",
    vertical = "vsplit",
    tab = "tabedit",
  }

  vim.cmd(commands[wintype] .. " " .. bufname)
end

local function change_local_cwd(path)
  vim.cmd("lcd" .. " " .. path)
  print(vim.fn.getcwd())
end

local function remap(bufnr, wintype)
  return function()
    actions.close(bufnr)
    local selection = action_state.get_selected_entry()
    local path = selection[1]:match("/.*") or selection[1]:match("%a:[\\/].*")
    local bufname = find_existing_bufname(path)

    if bufname then
      open_existing_buf(bufname, wintype)
    else
      open_new_buf(wintype)
    end

    change_local_cwd(path)
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
      attach_mappings = function(bufnr)
        actions.select_default:replace(remap(bufnr, "default"))
        actions.select_horizontal:replace(remap(bufnr, "horizontal"))
        actions.select_vertical:replace(remap(bufnr, "vertical"))
        actions.select_tab:replace(remap(bufnr, "tab"))
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
