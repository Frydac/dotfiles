return {
    "lukas-reineke/indent-blankline.nvim",
    disable = false,
    config = function()
        -- vim.g.indent_blankline_char_list = {'|', '¦', '┆', '┊'}
        -- vim.g.indent_blankline_char = '┆'
        -- vim.g.indent_blankline_context_char = '┊'
        require("ibl").setup({
            indent = {
                char = "┆",
                -- char = "│",
                -- context_char = "│",
                -- show_current_context = true,
                -- show_current_context_start = false,
            },
            scope = {
                char = "│",
                show_start = false,
                show_end = false,
                -- highlight = { "IndentBlanklineContextChar" }
            }
            -- for example, context is off by default, use this to turn it on
            -- show_current_context = true,
            -- show_current_context_start = false,
            -- char = "┊",
            -- context_char = "│",
            -- context_char = "┊",
            -- context_patterns = {
            --     "class",
            --     "^func",
            --     "method",
            --     "^if",
            --     "while",
            --     "for",
            --     "with",
            --     "try",
            --     "except",
            --     "arguments",
            --     "argument_list",
            --     "object",
            --     "dictionary",
            --     "element",
            --     "table",
            --     "tuple",
            --     "struct",
            --     "return",
            -- },
            -- filetype_exclude = { "lspinfo", "packer", "checkhealth", "help", "alpha" },
        })
    end,
}
