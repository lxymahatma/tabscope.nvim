# tabscope.nvim

Provides an independent buffer scope for each tab in Neovim.

[![Lua](https://img.shields.io/badge/Lua-blue?logo=lua&logoColor=white)](https://www.lua.org)
[![Neovim](https://img.shields.io/badge/Neovim-0.8+-green?logo=neovim&logoColor=white)](https://neovim.io)

The core idea of `tabscope.nvim` is to maintain a separate list of buffers for each tab.
When you switch between tabs, the buffer list in your bufferline can dynamically update to show only the buffers relevant to the current tab.

## Core Concept

This plugin is primarily designed for users of [heirline.nvim](https://github.com/rebelot/heirline.nvim) to enable a tab-specific buffer list component.
While `tabscope.nvim` can run standalone, it better integrates with `heirline.nvim`.

## ✨ Features

- Maintains an independent buffer list for each tab.
- Integrates seamlessly with `heirline.nvim` to provide an out-of-the-box buffer list component.
- Supports session restore through [persistence.nvim](https://github.com/folke/persistence.nvim).
- Provides a clean Lua API for easy extension and integration.

## 💾 Installation

Install with [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "lxymahatma/tabscope.nvim",
    dependencies = { "rebelot/heirline.nvim" }, -- Strongly recommended
    opts = {
        -- Your custom options here
    }
}
```

## ⚙️ Configuration

The plugin comes with a set of default options.

### Default Configuration

```lua
{
    "lxymahatma/tabscope.nvim",
    opts = {
        -- Directory to store tab scope data
        dir = vim.fn.stdpath("state") .. "/tabscopes/",

        -- Whether to record git branch information in the scope
        branch = true,

        integrations = {
            -- Enable integration with persistence.nvim
            persistence = false,
        }
    }
}
```

### Heirline Integration

The primary use case for `tabscope.nvim` is to provide a per-tab buffer list in your `heirline` configuration.
This is achieved by passing the `get_buflist` function to `heirline`'s `utils.make_buflist` helper.

Below is an example of a `heirline` bufferline configuration that uses `tabscope` to create a dynamic buffer line.

**Example `heirline` configuration:**

```lua
local BufferLine = utils.make_buflist(
    { BufferBlock },
    { provider = " ", hl = { fg = "text" } },
    { provider = " ", hl = { fg = "text" } },
    function() return require("tabscope").get_buflist() end,
    false
)
```

In `utils.make_buflist`, pass `function() return require("tabscope").get_buflist() end, false` as the fourth and fifth argument.
This tells `heirline` to use `tabscope` as the data source for the buffer list.

## 📚 API & Commands

### Commands

- `:TabScopeSave` - Manually saves the state of all tabs to persistent storage path set in options.
- `:TabScopeLoad` - Manually loads the state of all tabs from persistent storage path set in options.
- `:TabScopeNext` - Navigate to the next buffer in tab-scoped order (alternative to `:bnext`).
- `:TabScopePrev` - Navigate to the previous buffer in tab-scoped order (alternative to `:bprevious`).
- `:TabScopeCloseLeft` - Close all buffers to the left of the current buffer in the current tab.
- `:TabScopeCloseRight` - Close all buffers to the right of the current buffer in the current tab.

> [!NOTE]
> The native `:bnext` and `:bprevious` commands navigate buffers by their internal buffer numbers, which may differ from the visual order in your bufferline.
> Use `:TabScopeNext` and `:TabScopePrev` for navigation that respects the tab-scoped buffer order.

### Some Keymaps Examples

```lua
vim.keymap.set("n", "<Tab>", "<Cmd>TabScopeNext<CR>", { desc = "Next buffer in tab" })
vim.keymap.set("n", "<S-Tab>", "<Cmd>TabScopePrev<CR>", { desc = "Previous buffer in tab" })
vim.keymap.set("n", "<leader>bl", "<Cmd>TabScopeCloseLeft<CR>", { desc = "Close buffers to the left" })
vim.keymap.set("n", "<leader>br", "<Cmd>TabScopeCloseRight<CR>", { desc = "Close buffers to the right" })
```

### Lua API

`tabscope.nvim` also exposes a simple API for you to use in your Lua configurations or other plugins:

```lua
local tabscope = require("tabscope")

-- Get the list of buffers associated with the current tab
local buflist = tabscope.get_buflist()

-- Navigate to next/previous buffer in tab-scoped order
tabscope.next_buffer()
tabscope.prev_buffer()

-- Close buffers to the left or right
tabscope.close_buffers("left")
tabscope.close_buffers("right")

-- Manually save the current tab-buffer mapping to persistent storage
tabscope.save()

-- Manually load the tab-buffer mapping from persistent storage
tabscope.load()
```
