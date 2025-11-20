local M = {}

local config = require("tabscope.config")
local utils = require("tabscope.utils")

local function get_path()
    local name = vim.fn.getcwd():gsub("[\\/:]+", "%%")
    if config.options.branch then
        local branch = utils.get_git_branch()
        if branch and branch ~= "" then name = name .. "%%" .. branch end
    end
    return config.options.dir .. name
end

---Write data to save file
---@param data table
---@void
function M.write(data)
    assert(type(data) == "table", "Data must be a table")

    local path = get_path()
    local encoded = vim.mpack.encode(data)
    local f = assert(io.open(path, "wb"), "Failed to open file: " .. path)

    f:write(encoded)
    f:close()
end

---Read data from save file
---@return table
function M.read()
    local path = get_path()
    local f = assert(io.open(path, "rb"))
    local bytes = f:read("*all")

    f:close()

    return vim.mpack.decode(bytes)
end

---Check if save file exists
---@return boolean
function M.exists() return vim.fn.filereadable(get_path()) == 1 end

return M
