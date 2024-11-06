-- TODO: most of these are not relevant anymore, review/rework
--
-- reset all autocommands in the augroup cmd, to which we add later
vim.cmd [[ augroup cmds | autocmd! | augroup end ]]

-- save on loose foxus TODO: this doesn't always work, e.g. when part of tmux
-- pane, some autosave plugin might be better, though I've had issues with lsp
-- going at it.
vim.cmd [[ autocmd cmds FocusLost * silent! wa ]]

-- Preview window with line wrap
vim.cmd [[ autocmd cmds WinEnter * if &previewwindow | setlocal wrap | endif ]]

-- Help window vertical split right
-- TODO: only do this when wide enough
vim.cmd [[ autocmd cmds FileType help wincmd L ]]

-- Set spell checking on for certain filetypes
-- TODO: maybe not?
vim.cmd [[ autocmd cmds FileType markdown setlocal spell ]]
vim.cmd [[ autocmd cmds FileType gitcommit setlocal spell ]]

-- Save last session when exiting using startify
-- TODO: make something smarter that saves multiple sessions, telescope pick? (show open buffers in session?)
-- vim.cmd [[ autocmd cmds VimLeavePre * SSave! last_session ]]


vim.cmd [[ autocmd cmds TextYankPost * silent! lua vim.highlight.on_yank({timeout=100}) ]]

-------------------
-- Abbreviations --
-------------------

vim.cmd [[
cnoreabbrev Q q
cnoreabbrev Qa qa
cnoreabbrev W w
cnoreabbrev Wqa wqa
cnoreabbrev Wa wa

" write current file as sudo (Write Sudo)
cnoreabbrev Ws ws

"Write current file as sudo
command! Ws w !sudo tee %

"disable norelativenumber completely
command! NoRelativenumber windo set norelativenumber <bar> tabdo set norelativenumber <bar> bufdo set norelativenumber <bar> set norelativenumber
command! Relativenumber windo set relativenumber <bar> tabdo set relativenumber <bar> set relativenumber
]]

-- TODO: replace Ws with https://vi.stackexchange.com/questions/25027/saving-a-non-user-file-with-neovim-eg-root-owned-etc-pulse-default-pa



vim.cmd [[
    function! Profile()
    exe 'profile start ~/vim_profile.log'
    exe 'profile func *'
    exe 'profile file *'
    endfunction

    function! ProfileQuit()
    exe 'profile pause'
    exe 'noautocmd qall'
    endfunction
]]


-- local winbar_filetype_exclude = {
--     "help",
--     "startify",
--     "dashboard",
--     "packer",
--     "neogitstatus",
--     "NvimTree",
--     "Trouble",
--     "alpha",
--     "lir",
--     "Outline",
--     "spectre_panel",
--     "toggleterm",
-- }
-- BufWinEnter and BufFilePost give error "E36 Not enough room" when going to command mode (something with window size probably, maybe too early)
-- vim.api.nvim_create_autocmd({ "CursorMoved", "BufWinEnter", "BufFilePost" }, {
-- vim.api.nvim_create_autocmd({ "CursorMoved"}, {
--     callback = function()
--         if vim.tbl_contains(winbar_filetype_exclude, vim.bo.filetype) then
--             vim.opt_local.winbar = nil
--             return
--         end
--
--         local value = require("emile.winbar").gps()
--         if value == nil then
--             value = require("emile.winbar").filename()
--         end
--         vim.opt_local.winbar = value
--     end,
-- })
