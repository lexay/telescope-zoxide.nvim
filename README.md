### Description

Telescope extension for `neovim` powered by `zoxide`.

Change the current working directory to a directory `zoxide` knows about, with the prompt from
`telescope`.

### Installation

Using plugin managers:

Lazy:
```
local M = {
  "lexay/telescope-zoxide.nvim",
}

M.config = function()
  require("telescope").load_extension("zoxide")
end

return M
```

Packer:
```
use {
  "lexay/telescope-zoxide.nvim",
  config = function()
    require("telescope").load_extension("zoxide")
  end
}
```

### Keyboard mapping suggestions

In the `telescope` config you can assign it to something like this:

```
vim.keymap.set("n", "<leader>fz", "<cmd>Telescope zoxide<cr>")
```

If openning the `find_files` telescope prompt or a file explorer is the first thing that you do, when
switching to the project dir, you may consider chaining the two commands together:

```
vim.keymap.set("n", "<leader>fz", "<cmd>Telescope zoxide<cr><cmd>Telescope find_files<cr>")
```

or

```
vim.keymap.set("n", "<leader>fz", "<cmd>Telescope zoxide<cr><cmd>Lexplore<cr>")
```
