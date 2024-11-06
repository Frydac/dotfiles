-- TODO: repalce with fzf.nvim? fzf.lua? if --no-sort is possible..
-- get fzf
return {
    { 'junegunn/fzf', run = ":call fzf#install()" }, -- not needed when installed with package? run = function() vim.cmd('call fzf#install()') end}
    {
        'junegunn/fzf.vim',
        -- disable = true,
        config = function()
            vim.g.fzf_layout = { window = { width = 0.9, height = 0.9 } }
            -- vim.g.fzf_preview_window = { 'ctrl-/' }
            -- vim.g.fzf_layout = {down = '~80%'}

            vim.cmd [[
                function! RipgrepFzf(query, fullscreen)
                  let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case %s || true'
                  let initial_command = printf(command_fmt, shellescape(a:query))
                  let reload_command = printf(command_fmt, '{q}')
                  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
                  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
                endfunction

                command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)


                " let g:fzf_preview_window = ['right,50%', 'ctrl-/']
                " Preview window is hidden by default. You can toggle it with ctrl-/.
                " It will show on the right with 50% width, but if the width is smaller
                " than 70 columns, it will show above the candidate list
                " let g:fzf_preview_window = ['hidden,>200(right,50%),<70(up,40%)', 'ctrl-/']
            ]]

            -- vim.cmd [[
            --     command! -bang -nargs=* History
            --     \ call fzf#vim#history(fzf#vim#with_preview({'options': '--no-sort'}))
            -- ]]
            --
            -- vim.cmd [[
            --     command! -bang -nargs=* History
            --     \ call fzf#vim#history({'options': '--no-sort'})
            -- ]]

            -- vim.cmd [[
            --     command! -bang -nargs=* Buffers
            --     \ call fzf#vim#buffers(fzf#vim#with_preview({'options': '--no-sort'}))
            -- ]]

            vim.cmd [[
                command! -bang -nargs=* Buffers
                \ call fzf#vim#buffers({'options': '--no-sort'})
            ]]

            vim.cmd [[
            command! -bang -nargs=* Rgg
            \ call fzf#vim#grep(
            \   'rg --column --line-number --no-heading --color=always '.shellescape(<q-args>), 1,
            \   <bang>0 ? fzf#vim#with_preview('up:60%')
            \           : fzf#vim#with_preview('right:50%:hidden', '?'),
            \   <bang>0)
            ]]
        end
    }
}
