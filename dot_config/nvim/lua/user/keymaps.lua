-- mappings related to vim builtin functionality
-- NOTE: mappings for plugins are defined with the plugin settings

local M = {}
M.setup = function()
    -- NOTE: the colon `:` for nohl is needed for it to throw an event so the 'kevinhwang91/nvim-hlslens' plugin can use it.
    -- vim.api.nvim_set_keymap('n', '<leader><esc>', ':nohl<cr><cmd>MarkClear<cr><cmd>pclose<cr><cmd>LuaSnipUnlinkCurrent<cr>', { silent = true })
    vim.api.nvim_set_keymap('n', '<leader><esc>', ':nohl<cr><cmd>pclose<cr><cmd>LuaSnipUnlinkCurrent<cr>',
        { silent = true })
    vim.keymap.set('n', '<leader><esc>', function()
        if IsAvailable('luasnip', false) then
            require('luasnip').unlink_current()
        end
        vim.cmd('nohl')
        vim.cmd('pclose')
    end, { silent = true })
    -- vim.api.nvim_set_keymap('n', '<leader><esc>', ':nohl<cr>', { silent = true })

    -- get out of terminal (note: <c-[> == <esc> )
    -- probably not needed anymore because we can change windows and tabs from other keys?
    local exit_terminal_map = '<c-\\><c-n>'
    -- this keymap breaks the fzf popup
    -- vim.api.nvim_set_keymap('t', '<c-[><c-[>', exit_terminal_map, {})

    local noremap = {
        noremap = true
    }

    -- change windows with Alt key maps
    for _, key in ipairs({ 'h', 'j', 'k', 'l' }) do
        vim.api.nvim_set_keymap('t', '<M-' .. key .. '>', exit_terminal_map .. '<c-w><c-' .. key .. '>', noremap)
        vim.api.nvim_set_keymap('n', '<M-' .. key .. '>', '<c-w><c-' .. key .. '>', noremap)
        vim.api.nvim_set_keymap('v', '<M-' .. key .. '>', '<esc><c-w><c-' .. key .. '>', noremap)
        vim.api.nvim_set_keymap('i', '<M-' .. key .. '>', '<esc><c-w><c-' .. key .. '>', noremap)
    end
    vim.api.nvim_set_keymap('t', '<M-BS>', exit_terminal_map .. '<c-w><c-w>', noremap)
    vim.api.nvim_set_keymap('n', '<M-BS>', '<c-w><c-w>', noremap)
    vim.api.nvim_set_keymap('v', '<M-BS>', '<esc><c-w><c-w>', noremap)
    vim.api.nvim_set_keymap('i', '<M-BS>', '<esc><c-w><c-w>', noremap)
    vim.keymap.set({ 't' }, '<M-t>', exit_terminal_map .. 'gt', noremap)


    -- change tabs with Alt Key maps
    -- I have change awesome wm panes to <windows_key-esc>
    vim.api.nvim_set_keymap('t', '<M-Esc>', exit_terminal_map .. 'gt', noremap)
    vim.api.nvim_set_keymap('n', '<M-Esc>', '<esc>gt', noremap)
    vim.api.nvim_set_keymap('v', '<M-Esc>', '<esc>gt', noremap)
    vim.api.nvim_set_keymap('i', '<M-Esc>', 'gt', noremap)
    vim.api.nvim_set_keymap('i', '<M-Esc>', 'gt', noremap)

    vim.cmd [[
        " Surround `line;` -> `MSS(line);`
        nnoremap <leader>aM ^ct;MSS()<esc>P^
        nnoremap <leader>aB ^ct;MSS_B()<esc>P^
        nnoremap <leader>aC ^ct;MSS_RC()<esc>P^
        " Surround `line;` -> `REQUIRE(line);`
        nnoremap <leader>aR ^ct;REQUIRE()<esc>P^
        nnoremap <leader>aK ^ct;A_CHECK_OK()<esc>P^
    ]]


    vim.api.nvim_set_keymap('n', '<leader><leader>s', '<cmd>wa<cr>', {})

    -- debugging
    -- vim.api.nvim_set_keymap('v', "<leader><leader>b", ':<c-u>lua require("emile.util").visual_selection_range(true)<cr>', { noremap = true })
    -- vim.api.nvim_set_keymap('v', '<leader><leader>a', ':<c-u>lua require("emile.align_floats").align_floats()<cr>', { noremap = true })

    -- (re)load file
    vim.api.nvim_set_keymap('n', '<leader><leader>x', '<cmd>w<cr><cmd>luafile %<cr>', {})

    vim.api.nvim_set_keymap('n', '<BS>dd', '<cmd>lua vim.diagnostic.disable(0)<cr>', {})
    vim.api.nvim_set_keymap('n', '<BS>de', '<cmd>lua vim.diagnostic.enable(0)<cr>', {})

    -- TODO: https://stackoverflow.com/questions/2119754/switch-to-last-active-tab-in-vim
    -- vim.keymap.set('n', '<leader>tl', '', { desc = 'Switch between last tabs' })
end

-- local M = {}
--
-- M.change_dir_to_git_module = function()
--     local lspconfig = require('lspconfig')
--     local find_dir_function = lspconfig.util.root_pattern(".git")
--     local current_buffer_filename = vim.api.nvim_buf_get_name(0)
--     local nearest_parent_with_dot_git = find_dir_function(current_buffer_filename)
--     if (nearest_parent_with_dot_git) then
--         vim.cmd("cd "..nearest_parent_with_dot_git)
--         print("pwd: "..nearest_parent_with_dot_git)
--     else
--         print("can't find .git in parent")
--     end
-- end
--
-- vim.api.nvim_set_keymap('n', '<leader>cdg', '<cmd>lua require("emile.key_maps").change_dir_to_git_module()<cr>', {})
local function get_first_use_block(lines)
    local block_lines = {}
    local state = "before_use"
    local bracket_counter = 0
    local opening_bracket_encountered = false
    for index, line in ipairs(lines) do
        if state == "before_use" then
            local use_pos = line:find("use")
            if use_pos then
                block_lines.first = index
                state = 'after_use_begin'
            end
        end
        if state == "after_use_begin" then
            -- for now assume block with `{}`, just search for closing matching bracket
            for pos = 0, #line do
                local current_char = line:sub(pos, pos)
                if current_char == '{' then
                    bracket_counter = bracket_counter + 1
                    opening_bracket_encountered = true
                elseif current_char == '}' then
                    bracket_counter = bracket_counter - 1
                end
            end

            if opening_bracket_encountered and bracket_counter == 0 then
                block_lines.last = index
                return block_lines
            end
        end
    end
    return block_lines
end

-- NOTE: assuming no escaped string in the string literal
local function get_string_literal(line)
    local start_pos = line:find("['\"]")
    if start_pos then
        start_pos = start_pos + 1
        local end_pos = line:find("['\"]", start_pos)
        if end_pos then
            end_pos = end_pos - 1
            local string_literal = line:sub(start_pos, end_pos)
            return string_literal
        end
    end
end

local function get_plugin_name(lines, use_block_lines)
    for line_nr = use_block_lines.first, use_block_lines.last do
        local line = lines[line_nr]
        local full_name = get_string_literal(line)
        if full_name then
            local pos_last_slash = full_name:find("/[^/]*$")
            if not pos_last_slash then return nil end
            local basename = full_name:sub(pos_last_slash + 1)
            return basename
        end
    end
end

local function octal_to_decimal(octal)
    return tonumber(tostring(octal), 8)
end

local function extract_plugin_to_its_own_file()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local cursor_line_nr = cursor[1]
    local lines = vim.api.nvim_buf_get_lines(0, cursor_line_nr - 1, vim.api.nvim_buf_line_count(0), true)
    local use_block_line_nrs = get_first_use_block(lines)
    local name = get_plugin_name(lines, use_block_line_nrs)
    local util = require('emile.util')
    if not name then
        util.print_error("Can't parse name from use { 'name' }")
        return nil
    end

    local plugin_base_dir = vim.fn.stdpath('config') .. "/lua/emile/plugins/"
    local fn_plugin = plugin_base_dir .. name .. ".lua"

    -- file exists?
    if vim.loop.fs_stat(fn_plugin) then
        util.print_warning("New plugin file already exists, not adjusting content: '" .. fn_plugin .. "'")
        return nil
    end

    -- create new file
    local open_mode = octal_to_decimal(755)
    local fd, err = vim.loop.fs_open(fn_plugin, "w", open_mode)
    if not fd then
        util.print_error("Can't create new file: '" .. fn_plugin .. "'\n" .. err)
        return nil
    end
    util.print_info("Created new file: '" .. fn_plugin .. "'")

    -- accumulate new content and write to file
    local plugin_file_common_start = [[
if IsNotAvailable('packer') then return end
local packer = require('packer')
local use = packer.use

    ]]
    local new_content = plugin_file_common_start .. "\n"
    for line_nr = use_block_line_nrs.first, use_block_line_nrs.last do
        new_content = new_content .. lines[line_nr] .. "\n"
    end
    if not vim.loop.fs_write(fd, new_content) then
        util.print_error("Cannot write content to new file: '" .. fn_plugin .. "'")
    end
    vim.loop.fs_close(fd)

    -- replace current use block with require
    local new_require_line = {}
    new_require_line[1] = "require('emile.plugins." .. name .. "')"

    do
        local first = cursor_line_nr - 1
        local last = first + use_block_line_nrs.last
        vim.api.nvim_buf_set_lines(0, first, last, true, new_require_line)
    end

end

local function testing()
    local util = require('emile.util')

    local fn = "/tmp/testing.txt"
    -- local open_mode = vim.loop.constants.O_CREAT + vim.loop.constants.O_WRONLY + vim.loop.constants.O_TRUNC
    -- local open_mode = vim.loop.constants.O_RDWR
    local open_mode = tonumber("755", 8)
    print("open_mode: " .. open_mode)
    local fd, err = vim.loop.fs_open(fn, "w", 493)
    if not fd then
        util.print_error("Can't create new file: '" .. fn .. "'\n" .. err)
        return nil
    end
    local rc = vim.loop.fs_write(fd, "testing something to write")
    L("rc: ", rc)
    if not rc then
        util.print_error("Cannot write content to new file: '" .. fn .. "'")
        goto cleanup
    end

    ::cleanup::
    print("closing file")
    vim.loop.fs_close(fd)
end

vim.keymap.set('n', '<leader>aep', function() extract_plugin_to_its_own_file() end)
vim.keymap.set('n', '<leader>aaa', function() testing() end)

-- save all and reload -> e.g. force lsp update
vim.keymap.set('n', '<leader>ww', '<cmd>wa<cr><cmd>e<cr>')

vim.keymap.set('n', '<leader>dl', vim.diagnostic.setloclist, { desc = 'Open [D]iagnostic [L]ocation list' })

return M

-- use {
--     'bla'
-- }
