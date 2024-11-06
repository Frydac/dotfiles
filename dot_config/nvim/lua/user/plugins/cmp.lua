local function setup()
    if IsNotAvailable('cmp') then return end
    local cmp = require('cmp')
    local lspkind = require('lspkind')

    cmp.setup({
        mapping = {
            ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
            ['<C-e>'] = cmp.mapping({
                i = cmp.mapping.abort(),
                c = cmp.mapping.close()
            }),

            -- ['<C-y>'] = cmp.mapping.confirm({select = true}),
            ['<C-p>'] = cmp.mapping.confirm({ select = true }),
            ["<Tab>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "s" }),
            ["<S-Tab>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "s" }),
            ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
            ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' })
        },
        sources = {
            { name = 'nvim_lsp', max_item_count = 15 },
            { name = 'nvim_lua' },
            -- { name = 'codeium' },
            -- { name = 'cmp_tabnine' },
            { name = 'luasnip' },
            { name = 'ultisnips' },
            { name = 'buffer', max_item_count = 15 },
            { name = 'path' }
            -- { name = 'ultisnips' },
            -- {name = 'copilot'},
            -- { name = 'treesitter' },
            -- { name = 'spell' },
        },
        experimental = { ghost_text = false },
        formatting = {
            -- format of popup menu
            format = function(entry, vim_item)
                local kind_icons = {
                    Text = "",
                    Method = "󰆧",
                    Function = "󰊕",
                    Constructor = "",
                    Field = "󰇽",
                    Variable = "󰂡",
                    Class = "󰠱",
                    Interface = "",
                    Module = "",
                    Property = "󰜢",
                    Unit = "",
                    Value = "󰎠",
                    Enum = "",
                    Keyword = "󰌋",
                    Snippet = "",
                    Color = "󰏘",
                    File = "󰈙",
                    Reference = "",
                    Folder = "󰉋",
                    EnumMember = "",
                    Constant = "󰏿",
                    Struct = "",
                    Event = "",
                    Operator = "󰆕",
                    TypeParameter = "󰅲",
                }

                vim_item.kind = string.format(" %s %s ",
                    lspkind.presets.default[vim_item.kind],
                    vim_item.kind)
                vim_item.menu = ({
                    nvim_lsp = "[Lsp]",
                    nvim_lua = "[Lua]",
                    treesitter = "[TS]",
                    path = "[Path]",
                    buffer = "[Buffer]",
                    zsh = "[Zsh]",
                    spell = "[Spell]",
                    -- ultisnips = "[Ultisnips]",
                    luasnip = "[Luasnip]",
                    cmp_tabnine = "[TabNine]",
                    codeium = "[Codeium]"
                    -- copilot = "[Copilot]"
                })[entry.source.name]
                return vim_item
            end
        },
        snippet = {
            expand = function(args)
                -- vim.fn["UltiSnips#Anon"](args.body)
                require('luasnip').lsp_expand(args.body)
            end
        },
        window = {
            completion = cmp.config.window.bordered({
                winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:Search",
            }),
            documentation = cmp.config.window.bordered({
                winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:Search",
            }),
        }
    })

    -- Set configuration for specific filetype.
    if IsAvailable('cmp_git') then
        require('cmp_git').setup({})
        cmp.setup.filetype('gitcommit', {
            sources = cmp.config.sources({ { name = 'git' } }, { { name = 'buffer' } })
        })
    end

    if IsAvailable("aerial") then
        require('aerial').setup()
    end

    -- `:` cmdline setup. Maybe wilder is better..
    cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources(
            { { name = 'path' } },
            { {
                name = 'cmdline',
                option = {
                    ignore_cmds = { 'Man', '!' }
                }
            } }
        ),
        matching = { disallow_symbol_nonprefix_matching = false }
    })
    -- -- If you want insert `(` after select function or method item
    -- local cmp_autopairs = require('nvim-autopairs.completion.cmp')
    -- cmp.event:on( 'confirm_done', cmp_autopairs.on_confirm_done({  map_char = { tex = '' } }))
    -- -- add a lisp filetype (wrap my-function), FYI: Hardcoded = { "clojure", "clojurescript", "fennel", "janet" }
    -- cmp_autopairs.lisp[#cmp_autopairs.lisp+1] = "racket"

    -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
    -- cmp.setup.cmdline('/', {
    --     sources = cmp.config.sources({
    --         { name = 'nvim_lsp_document_symbol' }
    --     }, {
    --         { name = 'buffer' }
    --     })
    -- })
    -- -- completion for
    -- cmp.setup.cmdline(':', {
    --     sources = {
    --         { name = 'cmdline_history' },
    --     },
    -- })

    -- filter_kind can also be specified as a filetype map.
    -- vim.g.aerial = {
    --     filter_kind = {
    --         -- use underscore to specify the default behavior
    --         ['_']  = {"Class", "Function", "Interface", "Method", "Struct"},
    --         -- c = {"Namespace", "Function", "Struct", "Enum"},
    --         cpp = {"Namespace", "Class", "Struct", "Function", "Enum"}
    --     }
    -- }
end

return {
    "hrsh7th/nvim-cmp",
    -- disable = false,
    dependencies = {
        -- This actually requires nvim-cmp.. but yeah..
        { "onsails/lspkind-nvim" },
        { "hrsh7th/cmp-buffer" },
        { "hrsh7th/cmp-nvim-lsp" },
        { "hrsh7th/cmp-path" },
        { "hrsh7th/cmp-nvim-lua" },
        { "hrsh7th/cmp-cmdline" },
        { "hrsh7th/cmp-nvim-lsp-document-symbol" },
        { "dmitmel/cmp-cmdline-history" },
        { "ray-x/cmp-treesitter" },
        { "f3fora/cmp-spell" },
        { "saadparwaiz1/cmp_luasnip" },
        -- { "ray-x/lsp_signature.nvim" },
        {'stevearc/aerial.nvim'}, -- code outline :AerialToggle TODO: make shortcuts? -> doesn't show signature
        { "lukas-reineke/cmp-under-comparator" },
        { "petertriho/cmp-git" },
        -- {
        --     'tzachar/cmp-tabnine',
        --     build = './install.sh',
        -- },
    },
    config = function()
        setup()
    end,
    -- after = 'nvim-autopairs'
}
