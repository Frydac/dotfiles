local keymap_opts = { buffer = true, silent = true, noremap = true }

vim.keymap.set('n', '<leader>pp', [["zyiwostd::cout << "<c-r>z: " << <c-r>z << std::endl;<esc>]], keymap_opts)
vim.keymap.set('v', '<leader>pp', [["zyostd::cout << "<c-r>z: " << <c-r>z << std::endl;<esc>]], keymap_opts)

vim.keymap.set('n', '<leader>pd', [[^"zy$ostd::cout << "|| DEBUG: " << __FILE__ << ":" << __LINE__ - 1 << ": '<c-r>z'" << std::endl;<esc>]], keymap_opts)
vim.keymap.set('v', '<leader>pd', [["zyostd::cout << "|| DEBUG: " << __FILE__ << ":" << __LINE__ - 1 << ": '<c-r>z'" << std::endl";<esc>]], keymap_opts)

vim.keymap.set('n', '<leader>pm', [["zyiwoprint("<c-r>z: ", <c-r>z);<esc>]], keymap_opts)
vim.keymap.set('v', '<leader>pm', [["zyoprint("<c-r>z: ", <c-r>z);<esc>]], keymap_opts)

vim.keymap.set('n', '<leader>pl', [["zyiwoL(C(<c-r>z));<esc>]], keymap_opts)
vim.keymap.set('v', '<leader>pl', [["zyoL(C(<c-r>z));<esc>]], keymap_opts)

-- write optional
vim.keymap.set('n', '<leader>po', [["zyiwostd::cout << "<c-r>z.has_value(): " << <c-r>z.has_value() << std::endl;<cr>if (<c-r>z.has_value())<cr>    "<c-r>z: " << *<c-r>z << std::endl;<esc>]], keymap_opts)
-- vim.keymap.set('n', '<leader>po', [["zyiwostd::cout << "<c-r>z.has_value(): "]], keymap_opts)
-- vim.keymap.set('v', '<leader>po', [["zyostd::cout << "<c-r>z: " << <c-r>z << std::endl;<esc>]], keymap_opts)
