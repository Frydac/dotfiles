vim.keymap.set('n', 'ydi', function()
    if not pcall(require, "related_files.file") then return end
    local RFile = require('related_files.file')
    local rfile = RFile:new(vim.api.nvim_buf_get_name(0))
    local line = "#include <" .. rfile.namespace .. rfile.basename .. ">"
    local linewise = "l"
    vim.fn.setreg('"', line, linewise)
    print("Changed unnamed register to: " .. line)
end, { buffer = true, noremap = true })
