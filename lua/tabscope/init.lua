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

local function create_user_commands()
    vim.api.nvim_create_user_command("TabScopeSave", core.save, {})
    vim.api.nvim_create_user_command("TabScopeLoad", core.load, {})
end

function M.setup(opts)
    config.setup(opts)
    -- TODO: check current buffer list
    local file_buffers = vim.tbl_filter(
        function(buf) return vim.fn.buflisted(buf) == 1 and vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= "" end,
        vim.api.nvim_list_bufs()
    )
    if #file_buffers > 0 then
        for _, buf in ipairs(file_buffers) do
            core.add_buffer_by_id(buf)
        end
    end
    setup_autocmds()
    create_user_commands()
end

return setmetatable(M, {
    __index = core,
})
