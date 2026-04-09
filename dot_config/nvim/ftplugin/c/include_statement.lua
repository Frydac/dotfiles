-- vim.keymap.set('n', 'ydi', function()
--     if not pcall(require, "related_files.file") then return end
--     local RFile = require('related_files.file')
--     local rfile = RFile:new(vim.api.nvim_buf_get_name(0))
--     local line = "#include <" .. rfile.namespace .. rfile.basename .. ">"
--     local linewise = "l"
--     vim.fn.setreg('"', line, linewise)
--     print("Changed unnamed register to: " .. line)
-- end, { buffer = true, noremap = true, desc = "Create an include statement for the current buffer" })

vim.keymap.set('n', 'ydi', function()
    local ok, RFile = pcall(require, "related_files.file")
    if not ok then return end

    local rfile = RFile:new(vim.api.nvim_buf_get_name(0))
    local line = "#include <" .. rfile.namespace .. rfile.basename .. ">"

    -- linewise register type
    local regtype = "V"

    -- Always set the unnamed register
    vim.fn.setreg('"', line .. "\n", regtype)

    -- If clipboard=unnamed/unnamedplus is set, also populate the clipboard registers
    local cb = vim.o.clipboard
    if cb:find("unnamedplus") then
        vim.fn.setreg('+', line .. "\n", regtype)
    end
    if cb:find("unnamed") then
        vim.fn.setreg('*', line .. "\n", regtype)
    end

    print("Include copied: " .. line)
end, { buffer = true, noremap = true, desc = "Create an include statement for the current buffer" })
