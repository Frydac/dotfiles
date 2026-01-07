return {
    "mrcjkb/rustaceanvim",
    enabled = true,
    version = "^6",
    lazy = false,

    dependencies = {
        {
            "akinsho/toggleterm.nvim",
            version = "*",
            config = function()
                require("toggleterm").setup({
                    direction = "vertical",
                    size = 80,
                    persist_size = true,
                    close_on_exit = false,
                    auto_scroll = true,
                    start_in_insert = false,
                    insert_mappings = false,
                    terminal_mappings = false,
                })
            end,
        },
    },

    config = function()
        vim.g.rustaceanvim = {
            tools = {
                executor = {
                    type = "toggleterm",
                    options = {
                        term_id = 3,
                    },
                },
            },
        }

        vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(args)
                local on_attach = require("user.plugins.lsp.on_attach").on_attach
                local client = vim.lsp.get_client_by_id(args.data.client_id)
                if client then
                    on_attach(client, args.buf)
                end
            end,
        })
    end,
}

-- return {
--     'mrcjkb/rustaceanvim',
--     enabled = true,
--     version = '^6', -- Recommended
--     lazy = false, -- This plugin is already lazy
--     config = function()
--         vim.api.nvim_create_autocmd("LspAttach", {
--             callback = function(args)
--                 local on_attach = require('user.plugins.lsp.on_attach').on_attach
--                 local client = vim.lsp.get_client_by_id(args.data.client_id)
--                 if client then
--                     on_attach(client, args.buf)
--                 end
--             end,
--         })
--     end
-- }
