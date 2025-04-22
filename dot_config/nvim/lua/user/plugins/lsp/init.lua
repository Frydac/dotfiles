local function setup_mason_tool_installer()
    require('mason-tool-installer').setup {

        -- a list of all tools you want to ensure are installed upon
        -- start; they should be the names Mason uses for each tool
        --
        -- List of available packages
        -- https://github.com/williamboman/mason.nvim/blob/main/PACKAGES.md
        ensure_installed = {
            'bash-language-server',
            'lua-language-server',
            'vim-language-server',
            -- 'java-language-server', -- error installing maven build?
            'jdtls',
            'stylua',
            'shellcheck',
            -- 'editorconfig-checker',
            -- 'luacheck', -- requires luarocks
            -- 'misspell', -- depends on go
            'shellcheck',
            'shfmt',
            'vint',
            'solargraph',
            'clangd',
            'clang-format',
            'json-lsp',
            'rust-analyzer'
        },

        -- if set to true this will check each tool for updates. If updates
        -- are available the tool will be updated. This setting does not
        -- affect :MasonToolsUpdate or :MasonToolsInstall.
        -- Default: false
        auto_update = false,

        -- automatically install / update on startup. If set to false nothing
        -- will happen on startup. You can use :MasonToolsInstall or
        -- :MasonToolsUpdate to install tools and check for updates.
        -- Default: true
        run_on_start = true,

        -- set a delay (in ms) before the installation starts. This is only
        -- effective if run_on_start is set to true.
        -- e.g.: 5000 = 5 second delay, 10000 = 10 second delay, etc...
        -- Default: 0
        start_delay = 3000, -- 3 second delay
    }
end

-- local myhostname = "emile-linux-home"
local myhostname = "wuuut"

local function mason_lspconfig_setup_handlers()
    -- make buffer keymaps and stuff when lsp server attaches to buffer
    local default_on_attach = require('user.plugins.lsp.on_attach').on_attach

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    -- L("capabilities: ", capabilities)
    if IsAvailable('cmp_nvim_lsp') then
        -- The nvim-cmp supports extra LSP's capabilities so You should advertise it to LSP servers..
        local cmp_capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
        capabilities = vim.tbl_extend("force", capabilities, cmp_capabilities) -- merge capabilities
    end
    if IsAvailable('blink.cmp', false) then
        capabilities = require('blink.cmp').get_lsp_capabilities(capabilities)
    end

    local lspconfig = require('lspconfig')

    -- only works for servers installed using mason (mason-tool-installer)
    require("mason-lspconfig").setup_handlers({
        -- for servers not listed below
        function(server_name)
            if vim.fn.hostname() == myhostname then
                if server_name == 'clangd' then return end
            end

            lspconfig[server_name].setup({
                on_attach = default_on_attach,
                capabilities = capabilities,
            })
        end,

        -- specific server configurations
        -- NOTE: use the lspconfig name, not the mason name
        ['solargraph'] = function()
            lspconfig.solargraph.setup({
                root_dir = lspconfig.util.root_pattern(".solargraph.yml") or vim.fn.getcwd(),
                on_attach = default_on_attach,
            })
        end,

        ['lua_ls'] = function()
            require("user.plugins.lsp.sumneko_lua").setup()
        end,

        ['jdtls'] = function()
            lspconfig.jdtls.setup({
                root_dir = lspconfig.util.root_pattern(".git") or lspconfig.util.path.dirname,
                on_attach = default_on_attach,
            })
        end,

        ['clangd'] = function()
            lspconfig.clangd.setup({
                on_attach = default_on_attach,
                capabilities = capabilities,
                on_init = function(client, _)
                    client.server_capabilities.semanticTokensProvider = nil -- turn off semantic tokens
                end,
            })
        end
    })

    -- this is not part of mason
    -- TODO: use capabilities of both clangd and ccls
    if vim.fn.hostname() == myhostname then
        require("user.plugins.lsp.ccls").setup()
    end

    -- After setting up mason-lspconfig you may set up servers via lspconfig
    -- require("lspconfig").sumneko_lua.setup {}
    require("neodev").setup()

    -- lspconfig.bashls.setup { on_attach = default_on_attach }
    -- lspconfig.solargraph.setup({
    --     root_dir = lspconfig.util.root_pattern(".solargraph.yml") or vim.fn.getcwd,
    --     on_attach = default_on_attach,
    -- })
end

local lsp_config = {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        'WhoIsSethDaniel/mason-tool-installer.nvim',
        {
            -- NOTE: noice is doing this now
            -- lsp progress gui, fidget spinner
            "j-hui/fidget.nvim",
            tag = 'v1.0.0',
            opts = {}
            -- enabled = true
        },
        { "m-pilia/vim-ccls" },
        {
            "glepnir/lspsaga.nvim",
            enabled = false,
            branch = "main",
            config = function()
                require('lspsaga').setup({})
                -- saga.init_lsp_saga({
                --     -- your configuration
                -- })
            end,
        },
        { "folke/neodev.nvim" },
        { "lvimuser/lsp-inlayhints.nvim" },
        -- {
        --     "DNLHC/glance.nvim",
        --     config = function()
        --         require('glance').setup({

        --         })
        --     end
        -- },
        {
            "SmiteshP/nvim-navbuddy",
            -- config = function ()
            --     local navbuddy = require("nvim-navbuddy")
            --     -- navbuddy.setup({
            --     --     window = {
            --     --         size = "90%"
            --     --     }
            --     -- })
            -- end,
            dependencies = {
                "SmiteshP/nvim-navic",
                "MunifTanjim/nui.nvim"
            },
            opts = {
                window = { size = "90%" },
                lsp = { auto_attach = true }
            }
        },
        {
            "smjonas/inc-rename.nvim",
            config = function()
                require("inc_rename").setup({})
            end,
        }

        -- TODO: integrate
        -- {
        --     "SmiteshP/nvim-navic",
        -- }
    },
    config = function()
        require("mason").setup()
        require("mason-lspconfig").setup({
        })

        -- ensure installed
        setup_mason_tool_installer()

        -- enable/configure lsp servers via lspconfig
        mason_lspconfig_setup_handlers()
    end
}

return {
    -- {
    --     'mfussenegger/nvim-jdtls',
    --     config = function()
    --         require('user.plugins.lsp.jdtls')
    --     end
    -- },
    lsp_config,
    require('user.plugins.lsp.clangd')
}
