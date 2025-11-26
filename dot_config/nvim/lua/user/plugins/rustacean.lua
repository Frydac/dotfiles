return {
    'mrcjkb/rustaceanvim',
    enabled = true,
    version = '^6', -- Recommended
    lazy = false, -- This plugin is already lazy
    config = function()
        vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(args)
                local on_attach = require('user.plugins.lsp.on_attach').on_attach
                local client = vim.lsp.get_client_by_id(args.data.client_id)
                if client then
                    on_attach(client, args.buf)
                end
            end,
        })
    end
}
