-- Print current value under cursor or in selection

-- Otherwise this is also executed for filetype='cpp'
if vim.o.ft ~= 'c' then
    return
end

local keymap_format = {
    i = 'd', -- integer
    p = 'p', -- pointer
    f = 'f', -- float
    u = 'u', -- unsigned
    lu = 'lu', -- unsinged long
    zu = 'zu', -- size_t
    s = 's', -- string
    c = 'c', -- char
    x = 'x', -- hex
}

local keymap_opts = { buffer = true, silent = true, noremap = true }

for keymap, format in pairs(keymap_format) do
    vim.keymap.set('n', '<leader>p' .. keymap, [["zyiwoprintf("<c-r>z: %]] .. format .. [[\n", <c-r>z);<esc>]], keymap_opts)
    vim.keymap.set('v', '<leader>p' .. keymap, [["zyoprintf("<c-r>z: %]] .. format .. [[\n", <c-r>z);<esc>]], keymap_opts)
end

-- print debug line: copy current line and print it with filename/linenumber (I do have plugin debugprint.nvim which
-- does this better)
vim.keymap.set('n', '<leader>pd', [[^"zy$oprintf("|| DEBUG: %s:%d: '<c-r>z'\n", __FILE__, __LINE__ - 1);<esc>]], keymap_opts)
vim.keymap.set('v', '<leader>pd', [["zyoprintf("|| DEBUG: %s:%d: '<c-r>z'\n", __FILE__, __LINE__ - 1);<esc>]], keymap_opts)
