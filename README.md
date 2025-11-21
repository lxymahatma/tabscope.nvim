# Tabscope.nvim

## Installation

```lua
-- Lua
{
    "lxymahatma/tabscope.nvim",
    dependencies = { "rebelot/heirline.nvim" }
    --- Default options
    opts = {
        dir = vim.fn.stdpath("state") .. "/tabscopes/",
        branch = true,
        persistence = false,
    }
}
```

Then, in heirline configuration where you use the `utils.make_buflist` function, after the `right_trunc`, add `function() return require("tabscope").get_buflist() end, false`
