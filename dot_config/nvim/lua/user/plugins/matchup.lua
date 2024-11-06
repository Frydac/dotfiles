return {
    'andymass/vim-matchup',
    disable = false,
    config = function()
        -- may set any options here
        vim.g.matchup_matchparen_offscreen = { method = "popup" }
        vim.g.matchup_delim_stopline = 1000

        -- trying to improve performance
        vim.g.matchup_matchparen_deferred = 1

        -- let g:matchup_matchparen_timeout = 300
        -- let g:matchup_matchparen_insert_timeout = 60
    end
}
