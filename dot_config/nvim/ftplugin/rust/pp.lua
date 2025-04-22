local keymap_opts = { buffer = true, silent = true, noremap = true }

vim.keymap.set('n', '<leader>pp', [["zyiwoprintln!("{}: {}", "<c-r>z", <c-r>z);<esc>]], keymap_opts)
vim.keymap.set('v', '<leader>pp', [["zyoprintln!("{}: {}", "<c-r>z", <c-r>z);<esc>]], keymap_opts)
vim.keymap.set('n', '<leader>pe', [["zyiwoprintln!("{:?}: {:?}", "<c-r>z", <c-r>z);<esc>]], keymap_opts)
vim.keymap.set('v', '<leader>pe', [["zyoprintln!("{:?}: {:?}", "<c-r>z", <c-r>z);<esc>]], keymap_opts)
vim.keymap.set('n', '<leader>pd', [["zyiwodbg!(<c-r>z);<esc>]], keymap_opts)
vim.keymap.set('v', '<leader>pd', [["zyodbg!(<c-r>z);<esc>]], keymap_opts)
