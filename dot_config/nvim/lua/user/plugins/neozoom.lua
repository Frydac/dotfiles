-- Maximize(/normalize) current window with NeoZoomToggle
return {
    'nyngwang/NeoZoom.lua',
    enabled = false,
    dependencies = { 'nyngwang/NeoNoName.lua' }, -- this is only required if you want the `keymap` below.
    config = function()
        require('neo-zoom').setup {
            -- top_ratio = 0,
            -- left_ratio = 0.225,
            -- width_ratio = 0.775,
            -- height_ratio = 0.925,
            -- exclude_filetypes = { 'lspinfo', 'mason', 'lazy', 'fzf', 'qf' },
            exclude_buftypes = { 'terminal' },
        }
        vim.keymap.set('n', '<leader><CR>', function()
            local win_on_zoom = vim.api.nvim_get_current_win()
            local buf_on_zoom = vim.api.nvim_get_current_buf()
            vim.cmd('NeoZoomToggle')

            -- if did zoom then clean-up the window on zoom temporarily to create popup effect.
            if require('neo-zoom').did_zoom() then
                vim.api.nvim_set_current_win(win_on_zoom)
                vim.cmd('NeoNoName')
                vim.cmd('wincmd p')
            else
                vim.api.nvim_set_current_buf(buf_on_zoom)
            end
        end, { silent = true, nowait = true })
    end
}
