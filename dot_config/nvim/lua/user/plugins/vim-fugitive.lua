
local gv = {
    'junegunn/gv.vim',
    cmd = 'GV',
}

local fugitive = {
    'tpope/vim-fugitive',
    cmd = { 'Git', 'G', 'Gdiffsplit', 'Gedit', 'Gread', 'Gwrite', 'Gclog', 'Ggrep', 'Gmove' },
    keys = {
        { '<leader>gs', '<cmd>vertical Git<CR>', desc = 'Git status' },
        { '<leader>gc', '<cmd>Git commit -v -q<CR>', desc = 'Git commit' },
        { '<leader>ga', '<cmd>Git commit --amend<CR>', desc = 'Git amend' },
        { '<leader>gt', '<cmd>Git commit -v -q %<CR>', desc = 'Git commit file' },
        { '<leader>gd', '<cmd>tabedit %<CR><cmd>Gdiffsplit<CR>', desc = 'Git diff file' },
        { '<leader>ge', '<cmd>Gedit<CR>', desc = 'Git edit' },
        { '<leader>gr', '<cmd>Gread<CR>', desc = 'Git read' },
        { '<leader>gw', '<cmd>Gwrite<CR>', desc = 'Git write' },
        { '<leader>gl', '<cmd>Gclog<CR>', desc = 'Git log' },
        -- { '<leader>gh', '<cmd>0Gclog<CR>', desc = 'Git log' },
        { '<leader>gp', ':Ggrep ', desc = 'Git grep' },
        { '<leader>gm', ':Gmove ', desc = 'Git move' },
        { '<leader>gb', '<cmd>Git blame<CR>', desc = 'Git blame' },
        { '<leader>go', ':Git checkout ', desc = 'Git checkout' },
        { '<leader>gps', '<cmd>Git push<CR>', desc = 'Git push' },
        { '<leader>gpl', '<cmd>Git pull --ff-only<CR>', desc = 'Git pull' },
    },
}

return {
    gv,
    fugitive
}
