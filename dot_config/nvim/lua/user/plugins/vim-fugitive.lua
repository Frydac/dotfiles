return {
    'tpope/vim-fugitive',
    config = function()
        -- TODO: use wich-key?
        vim.cmd [[
            """ fugitive
            " copied from the interwebs
            nnoremap <leader>gs   :vertical Git<CR>
            nnoremap <leader>gc   :Git commit -v -q<CR>
            nnoremap <leader>ga   :Git commit --amend<CR>
            nnoremap <leader>gt   :Git commit -v -q %<CR>
            " nnoremap <leader>gd   :tabnew Git diff %<CR>
            nnoremap <leader>gd   :tabedit %<CR>:Gdiff<CR>
            nnoremap <leader>ge   :Gedit<CR>
            nnoremap <leader>gr   :Gread<CR>
            nnoremap <leader>gw   :Gwrite<CR><CR>
            nnoremap <leader>gl   :Gclog<CR>
            nnoremap <leader>gp   :Ggrep<Space>
            nnoremap <leader>gm   :Gmove<Space>
            " nnoremap <leader>gb   :Git branch<Space>
            nnoremap <leader>gb   :Git blame<--CR>
            nnoremap <leader>go   :Git checkout<Space>
            nnoremap <leader>gps  :Git push<CR>
            nnoremap <leader>gpl  :Git pull --ff-only<CR>
            ]]
    end
}
