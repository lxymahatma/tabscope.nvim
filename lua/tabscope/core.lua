local api = vim.api

local utils = require("tabscope.utils")
local storage = require("tabscope.storage")

local M = {}

local buffer_cache = {}

local is_switching_tab = false

local function add_buffer_by_id(bufnr)
    if not utils.is_valid_buf(bufnr) then return end

    api.nvim_set_option_value("buflisted", true, { buf = bufnr })

    local current_handle = utils.get_current_tabhandle()
    buffer_cache[current_handle] = buffer_cache[current_handle] or {}

    -- If buffer already exists in the current tab
    if vim.tbl_contains(buffer_cache[current_handle], bufnr) then return end

    table.insert(buffer_cache[current_handle], bufnr)
end

function M.on_startup()
    local current_bufs = api.nvim_list_bufs()
    for _, bufnr in ipairs(current_bufs) do
        if utils.is_valid_buf(bufnr) then add_buffer_by_id(bufnr) end
    end
end

function M.add_buffer(args) add_buffer_by_id(args.buf) end

function M.remove_buffer(args)
    if is_switching_tab then return end
    local bufnr = args.buf
    for _, list in pairs(buffer_cache) do
        for i = #list, 1, -1 do
            if list[i] == bufnr then table.remove(list, i) end
        end
    end
end

function M.on_tab_enter(args)
    local current_handle = utils.get_current_tabhandle()

    if not buffer_cache[current_handle] then
        local current_buf = api.nvim_get_current_buf()
        add_buffer_by_id(current_buf)
    end

    local cached_bufs = buffer_cache[current_handle] or {}

    local allowed_bufs = utils.to_set(cached_bufs)
    local all_bufs = api.nvim_list_bufs()

    -- Unlist buffer in tab enter not tab leave to prevent buffers exists in both tabs and unlist buffer for a while
    for _, bufnr in ipairs(all_bufs) do
        if api.nvim_buf_is_valid(bufnr) then
            local should_show = allowed_bufs[bufnr] or false
            api.nvim_set_option_value("buflisted", should_show, { buf = bufnr })
        end
    end

    vim.schedule(function() is_switching_tab = false end)
end

function M.on_tab_leave(args) is_switching_tab = true end

function M.on_tab_closed(args)
    local closed_handle = tonumber(args.file)
    if closed_handle then buffer_cache[closed_handle] = nil end
end

function M.on_tab_new_entered(args) end

--- Save the current tab-buffer mapping to persistent storage
---@void
function M.save()
    local data = {}
    local tabs = api.nvim_list_tabpages()

    for _, handle in ipairs(tabs) do
        local paths = {}
        local buf_list = buffer_cache[handle] or {}

        for _, bufnr in ipairs(buf_list) do
            if api.nvim_buf_is_valid(bufnr) then
                local name = api.nvim_buf_get_name(bufnr)
                if name and name ~= "" then table.insert(paths, name) end
            end
        end

        table.insert(data, paths)
    end

    storage.write(data)
end

--- Load the tab-buffer mapping from persistent storage
--- @void
function M.load()
    if not storage.exists() then return end

    buffer_cache = {}

    local data = storage.read()
    local current_handle = utils.get_current_tabhandle()
    local tabs = api.nvim_list_tabpages()

    for i, paths in ipairs(data) do
        local handle = tabs[i]

        if handle then
            local bufnr_list = {}
            for _, path in ipairs(paths) do
                local bufnr = vim.fn.bufadd(path)
                if bufnr and bufnr > 0 then
                    table.insert(bufnr_list, bufnr)
                    local is_current = (handle == current_handle)
                    api.nvim_set_option_value("buflisted", is_current, { buf = bufnr })
                end
            end
            buffer_cache[handle] = bufnr_list
        end
    end
end

function M.get_buflist()
    local current_handle = utils.get_current_tabhandle()
    local buffers = buffer_cache[current_handle] or {}

    return vim.list_slice(buffers)
end

function M.next_buffer()
    local current_handle = utils.get_current_tabhandle()
    local buffers = buffer_cache[current_handle] or {}

    if #buffers <= 1 then return end

    local current_buf = api.nvim_get_current_buf()
    local current_idx = nil

    for i, bufnr in ipairs(buffers) do
        if bufnr == current_buf then
            current_idx = i
            break
        end
    end

    if not current_idx then return end

    local next_idx = current_idx % #buffers + 1
    api.nvim_set_current_buf(buffers[next_idx])
end

function M.prev_buffer()
    local current_handle = utils.get_current_tabhandle()
    local buffers = buffer_cache[current_handle] or {}

    if #buffers <= 1 then return end

    local current_buf = api.nvim_get_current_buf()
    local current_idx = nil

    for i, bufnr in ipairs(buffers) do
        if bufnr == current_buf then
            current_idx = i
            break
        end
    end

    if not current_idx then return end

    local prev_idx = (current_idx - 2) % #buffers + 1
    api.nvim_set_current_buf(buffers[prev_idx])
end

---@param direction "left"|"right"
function M.close_buffers(direction)
    local current_handle = utils.get_current_tabhandle()
    local buffers = buffer_cache[current_handle] or {}
    local current_buf = api.nvim_get_current_buf()
    local current_idx = nil

    for i, buf in ipairs(buffers) do
        if buf == current_buf then
            current_idx = i
            break
        end
    end

    if not current_idx then return end

    local targets = {}

    if direction == "left" then
        for i = 1, current_idx - 1 do
            table.insert(targets, buffers[i])
        end
    elseif direction == "right" then
        for i = current_idx + 1, #buffers do
            table.insert(targets, buffers[i])
        end
    end

    if #targets == 0 then return end

    for _, bufnr in ipairs(targets) do
        if api.nvim_buf_is_valid(bufnr) then api.nvim_buf_delete(bufnr, { force = false }) end
    end
end

return M
