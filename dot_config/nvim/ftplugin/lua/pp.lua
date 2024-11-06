local keymap_opts = { buffer = true, silent = true, noremap = true }

vim.keymap.set('n', '<leader>pp', [["zyiwoprint("<c-r>z: " .. <c-r>z)<esc>]], keymap_opts)
vim.keymap.set('v', '<leader>pp', [["zyoprint("<c-r>z: " .. <c-r>z)<esc>]], keymap_opts)

-- use custom global function L()
vim.keymap.set('n', '<leader>pl', [["zyiwoL("<c-r>z: ", <c-r>z)<esc>]], keymap_opts)
vim.keymap.set('v', '<leader>pl', [["zyoL("<c-r>z: ", <c-r>z)<esc>]], keymap_opts)
