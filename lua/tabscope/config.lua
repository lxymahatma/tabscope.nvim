local M = {}

---@class Tabscope.Config
---@field dir string
---@field branch boolean
---@field persistence boolean

---@type Tabscope.Config
M.options = {
    dir = vim.fn.stdpath("state") .. "/tabscopes/",
    branch = true,
    persistence = false,
}

---@param opts Tabscope.Config?
function M.setup(opts)
    M.options = vim.tbl_deep_extend("force", M.options, opts or {}) --[[@as Tabscope.Config]]
    vim.fn.mkdir(M.options.dir, "p")
end

return M
