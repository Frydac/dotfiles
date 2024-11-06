-- The goal of nvim-ufo is to make Neovim's fold look modern and keep high performance.
return {
    'kevinhwang91/nvim-ufo',
    disable = false,
    dependencies = 'kevinhwang91/promise-async',
    config = function()
        vim.wo.foldlevel = 99 -- feel free to decrease the value
        vim.o.foldlevelstart = 99
        vim.wo.foldenable = true

        vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
        vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
        vim.keymap.set('n', 'zm', require('ufo').closeFoldsWith)

        -- if IsAvailable('lspconfig') then
        --     -- option 2: nvim lsp as LSP client
        --     -- tell the server the capability of foldingRange
        --     -- nvim hasn't added foldingRange to default capabilities, users must add it manually
        --     local capabilities = vim.lsp.protocol.make_client_capabilities()
        --     capabilities.textDocument.foldingRange = {
        --         dynamicRegistration = false,
        --         lineFoldingOnly = true
        --     }
        --     -- local language_servers = {'ccls'} -- like {'gopls', 'clangd'}
        --     local language_servers = {} -- like {'gopls', 'clangd'}
        --     for _, ls in ipairs(language_servers) do
        --         require('lspconfig')[ls].setup({
        --             capabilities = capabilities,
        --             -- other_fields = ...
        --         })
        --     end
        -- end

        -- @returns
        --   A table of tables, the leaves are pairs of text and highlight groups that will be
        --   concatenated into the virtual text line that replaces the folded block
        -- @param virtual_text The code line of the fold (which will be a virtual text line?)
        local handler = function(virtual_text, line_start, line_end, window_width, truncate)
            local newVirtText = {}
            local suffix = ('    ⋯ %d lines '):format(line_end - line_start)
            local suffix_width = vim.fn.strdisplaywidth(suffix)
            local target_width = window_width - suffix_width
            local current_width = 0
            for _, chunk in ipairs(virtual_text) do
                local chunkText = chunk[1]
                local chunkWidth = vim.fn.strdisplaywidth(chunkText)
                if target_width > current_width + chunkWidth then
                    table.insert(newVirtText, chunk)
                else
                    chunkText = truncate(chunkText, target_width - current_width)
                    local hlGroup = chunk[2]
                    table.insert(newVirtText, { chunkText, hlGroup })
                    chunkWidth = vim.fn.strdisplaywidth(chunkText)
                    -- str width returned from truncate() may less than 2nd argument, need padding
                    if current_width + chunkWidth < target_width then
                        suffix = (' '):rep(target_width - current_width - chunkWidth) .. suffix
                    end
                    break
                end
                current_width = current_width + chunkWidth
            end
            -- local padding_width = math.min(target_width - current_width, 5)
            -- local padding = (' '):rep(padding_width)
            -- table.insert(newVirtText, { padding, 'UfoFoldedFg' })
            table.insert(newVirtText, { suffix, 'Comment' })
            return newVirtText
        end

        require('ufo').setup({
            open_fold_hl_timeout = 50,
            provider_selector = function(bufnr, filetype, buftype)
                return { 'treesitter', 'indent' }
            end,

            fold_virt_text_handler = handler
        })

        -- buffer scope handler
        -- will override global handler if it is existed
        local bufnr = vim.api.nvim_get_current_buf()
        require('ufo').setFoldVirtTextHandler(bufnr, handler)

    end
}
