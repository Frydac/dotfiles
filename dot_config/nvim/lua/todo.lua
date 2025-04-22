local M = {}

M.do_log = false
local function log_info(msg)
    if (M.do_log == true) then print("Info: "..msg) end
end

local function string_insert(str, str_insert, pos)
    return str:sub(1,pos)..str_insert..str:sub(pos + 1)
end

local function set_todo_line_icon(line, new_todo_icon)
    log_info('set_todo called for line: '..line)

    -- check if line is a bullet list item
    local bul_b, bul_e = string.find(line, '*')
    if not bul_b then
        log_info('no bullet list item found.')
        return nil
    end

    -- check if alredy todo list item
    local new_todo_icon_pos = string.find(line, new_todo_icon, bul_b)
    if new_todo_icon_pos then
        log_info("is already a todo line")
        return nil
    end

    -- check if other icons are used -> change to todo
    for _, old_todo_icon in pairs(M.icons) do
        local old_todo_icon_pos = string.find(line, old_todo_icon, bul_b)
        if old_todo_icon_pos then
            log_info("replacing existing icon: "..old_todo_icon.." with icon: "..new_todo_icon)
            line = string.gsub(line, old_todo_icon, new_todo_icon, 1)
            return line
        end
    end

    -- no icon yet exists, we need to insert
    log_info("insert todo icon")
    line = string_insert(line, new_todo_icon.." ", bul_e + 1)

    log_info("result: "..line)
    return line
end

-- TODO: better name!
local function set_todo_icon(icon)
    local line = set_todo_line_icon(vim.fn.getline('.'), icon)
    if line then
        vim.fn.setline('.', line)
        vim.cmd("redraw")
    end
end

function M.set_todo()
    set_todo_icon(M.icons.todo)
end
function M.set_todo_working()
    set_todo_icon(M.icons.todo_working)
end
function M.set_todo_wont()
    set_todo_icon(M.icons.todo_wont)
end
function M.set_todo_done()
    set_todo_icon(M.icons.todo_done)
end

local function test()
    local line

    line = " * 🟡 todo line"
    set_todo_line_icon(line, M.icons.todo)
    if line then log_info("result: "..line.."\n") end

    line = "no bullet line"
    line = set_todo_line_icon(line, M.icons.todo)
    if line then log_info("result: "..line.."\n") end

    line = " * emtpy bullet line"
    line = set_todo_line_icon(line, M.icons.todo)
    if line then log_info("result: "..line.."\n") end

    line = " * 🔴 todo_wont line"
    line = set_todo_line_icon(line, M.icons.todo)
    if line then log_info("result: "..line.."\n") end
end

M.todo_test = test

-- Test script
-- vim.api.nvim_set_keymap('n', '<leader><leader>t', "<cmd>lua require('todo').todo_test()<cr>", {})
-- TODO: only add mappings to supported filetypes

vim.api.nvim_set_keymap('n', '<Plug>Todo', "<cmd>lua Reload('todo').set_todo()<cr>", {})
vim.api.nvim_set_keymap('n', '<Plug>TodoWorking', "<cmd>lua Reload('todo').set_todo_working()<cr>", {})
vim.api.nvim_set_keymap('n', '<Plug>TodoWont', "<cmd>lua Reload('todo').set_todo_wont()<cr>", {})
vim.api.nvim_set_keymap('n', '<Plug>TodoDone', "<cmd>lua Reload('todo').set_todo_done()<cr>", {})

vim.api.nvim_set_keymap('n', '<leader>td', "<Plug>Todo", {})
vim.api.nvim_set_keymap('n', '<leader>tw', "<Plug>TodoWorking", {})
vim.api.nvim_set_keymap('n', '<leader>tn', "<Plug>TodoWont", {})
vim.api.nvim_set_keymap('n', '<leader>ty', "<Plug>TodoDone", {})

M.icons = {
    todo = "◯",
    todo_working = "🟡",
    todo_wont = "🔴",
    todo_done = "🟢"}

return M


--[[
I put these here because the lsp freaks out on these characters if they are first
icons 🔴 🟡 🟢 🔵 🟡 🟠 ⬛ ◯ ◯◯◯◯◯◯◯ ⏩❌❎✅
todo = "🟡",
☐ ☒ ☑
❗
--]]

