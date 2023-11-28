### Description

[WIP]

Telescope extension for `neovim` powered by `zoxide`.

Navigate between the directories `zoxide` knows about, with the prompt from
`telescope`, and open them in `netrw`.

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
