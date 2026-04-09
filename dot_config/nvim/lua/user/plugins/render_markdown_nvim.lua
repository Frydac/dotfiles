-- return {
--     'MeanderingProgrammer/render-markdown.nvim',
--     opts = {},
--     -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
--     dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
--     -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
-- }
return {
    'MeanderingProgrammer/render-markdown.nvim',
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' }, -- if you use the mini.nvim suite
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' }, -- if you use standalone mini plugins
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
        code = {
            -- position = 'right',
            style = 'langauge',
            -- width = 'block',
            left_pad = 2,
            right_pad = 4,
            -- border = 'thick',
            -- highlight_border = false,
        },
        heading = {
            border = true,
            -- border_prefix = true,
            atx = true,
            setext = true,
            icons = { "# ", "## ", "### ", "#### ", "##### ", "###### " },
            -- icons = { "󰎤 ", "󰎧 ", "󰎪 ", "󰎭 ", "󰎱 ", "󰎳 " },

        },
        completions = { lsp = { enabled = true } },
        ft = { "markdown", "codecompanion" }
    },
}
