local M = {}

function M.setup()
    local lspconfig = require('lspconfig')
    lspconfig.ccls.setup {
        -- init_options = {
        --     highlight = { lsRanges = true }
        -- },
        on_attach = function (client, bufnr)

            local opts = { noremap=true, silent=true, buffer = bufnr }
            -- vim.keymap.set('n', '<M-s>', function() vim.lsp.buf.signature_help() end, opts)
            vim.keymap.set('n', '<BS>gmm', '<cmd>CclsMembers<cr>', opts)
            vim.keymap.set('n', '<BS>gmf', '<cmd>CclsMemberFunctions<cr>', opts)
            vim.keymap.set('n', '<BS>gmt', '<cmd>CclsMemberTypes<cr>', opts)
            require('user.plugins.lsp.on_attach').on_attach(client, bufnr)
        end,
        root_dir = lspconfig.util.root_pattern(
            "compile_commands.json",
            ".vim/",
            ".hg/",
            "ccls_root"
        ) or vim.fn.getcwd,
        lsp = {
            codelens = {
                enable = true
            }
        }
    }
end

return M
