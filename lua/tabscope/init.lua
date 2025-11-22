local M = {}

local config = require("tabscope.config")
local core = require("tabscope.core")

local function setup_autocmds()
    local group = vim.api.nvim_create_augroup("tabscope", { clear = true })

    vim.api.nvim_create_autocmd("BufEnter", { group = group, callback = core.add_buffer })
    vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, { group = group, callback = core.remove_buffer })

    vim.api.nvim_create_autocmd("TabEnter", { group = group, callback = core.on_tab_enter })
    vim.api.nvim_create_autocmd("TabLeave", { group = group, callback = core.on_tab_leave })
    vim.api.nvim_create_autocmd("TabClosed", { group = group, callback = core.on_tab_closed })
    vim.api.nvim_create_autocmd("TabNewEntered", { group = group, callback = core.on_tab_new_entered })

    vim.api.nvim_create_user_command("TabScopeSave", function() core.save() end, {})
    vim.api.nvim_create_user_command("TabScopeLoad", function() core.load() end, {})

    if config.options.integrations.persistence then
        vim.api.nvim_create_autocmd("User", {
            group = group,
            pattern = "PersistenceSavePost",
            callback = function() core.save() end,
        })
        vim.api.nvim_create_autocmd("User", {
            group = group,
            pattern = "PersistenceLoadPost",
            callback = function() core.load() end,
        })
    end
end

function M.setup(opts)
    config.setup(opts)
    setup_autocmds()
end

return setmetatable(M, {
    __index = core,
})
