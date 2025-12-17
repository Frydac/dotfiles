local keymap_opts = { buffer = true, silent = true, noremap = true }

vim.keymap.set('n', '<leader><leader>r', function() vim.cmd.RustLsp('run') end, keymap_opts)
vim.keymap.set('n', '<leader>rt', function() vim.cmd.RustLsp('testables') end, keymap_opts)
vim.keymap.set('n', '<leader>rr', function() vim.cmd.RustLsp('runnables') end, keymap_opts)
-- vim.keymap.set('n', '<leader>rr', function() vim.cmd.RustLsp('run') end, keymap_opts)
