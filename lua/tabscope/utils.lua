local M = {}

function M.get_current_tabhandle() return vim.api.nvim_get_current_tabpage() end

--- Check if a buffer is valid for tab scoping
---@param bufnr integer Buffer number
---@return boolean True if valid, false otherwise
function M.is_valid_buf(bufnr)
    -- Check bufnr valid
    if not bufnr or bufnr < 1 then return false end
    if not vim.api.nvim_buf_is_valid(bufnr) then return false end

    -- Check if buffer is listed
    if not vim.api.nvim_get_option_value("buflisted", { buf = bufnr }) then return false end

    -- Check buffer is not special
    local buftype = vim.api.nvim_get_option_value("buftype", { buf = bufnr })
    if buftype ~= "" then return false end

    -- Check buffer has a name
    local name = vim.api.nvim_buf_get_name(bufnr)
    if name == "" then return false end

    return true
end

--- Convert a list to a set
---@param list table List of items
---@return table Set representation of the list
function M.to_set(list)
    local set = {}
    for _, item in ipairs(list) do
        set[item] = true
    end
    return set
end

--- Get the current git branch
---@return string|nil Git branch name or nil if not in a git repo
function M.get_git_branch()
    if vim.b.gitsigns_head and vim.b.gitsigns_head ~= "" then return vim.b.gitsigns_head end

    local output = vim.fn.systemlist("git branch --show-current")
    if vim.v.shell_error ~= 0 then return nil end
    local branch = output[1]
    if branch and branch ~= "" then return branch end

    return nil
end

return M
