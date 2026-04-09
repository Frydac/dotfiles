local myhostname = "wuuut"

local function setup_mason_tool_installer()
    require("mason-tool-installer").setup({
        ensure_installed = {
            "bash-language-server",
            "lua-language-server",
            "vim-language-server",
            "jdtls",
            "stylua",
            "shellcheck",
            "shfmt",
            "vint",
            "solargraph",
            "clangd",
            "json-lsp",
            "marksman",
        },
        auto_update = false,
        run_on_start = true,
        start_delay = 3000,
    })
end

local function patch_lsp_dynamic_registration()
    local handlers = vim.lsp.handlers
    if not handlers or handlers._java_language_server_register_patch then
        return
    end

    local original = handlers["client/registerCapability"]
    handlers["client/registerCapability"] = function(err, result, ctx, config)
        if result and result.registrations then
            for _, registration in ipairs(result.registrations) do
                if registration.registerOptions == vim.NIL then
                    registration.registerOptions = {}
                end
            end
        end

        local ok, response = pcall(original, err, result, ctx, config)
        if ok then
            return response
        end

        if tostring(response):find("ipairs", 1, true) then
            vim.schedule(function()
                vim.notify(
                    "Ignored invalid dynamic LSP registration from java_language_server",
                    vim.log.levels.DEBUG
                )
            end)
            return nil
        end

        error(response)
    end

    handlers._java_language_server_register_patch = true
end

local function make_capabilities()
    local capabilities = vim.lsp.protocol.make_client_capabilities()

    if IsAvailable("cmp_nvim_lsp") then
        capabilities = vim.tbl_extend(
            "force",
            capabilities,
            require("cmp_nvim_lsp").default_capabilities(capabilities)
        )
    end

    if IsAvailable("blink.cmp", false) then
        capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)
    end

    return capabilities
end

local function configure_server(name, config)
    vim.lsp.config(name, config)
end

local function enable_servers(server_names)
    for _, server_name in ipairs(server_names) do
        vim.lsp.enable(server_name)
    end
end

local function configure_servers()
    configure_server("solargraph", {
        root_markers = { ".solargraph.yml" },
    })

    configure_server("clangd", {
        cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--log=verbose",
            "--header-insertion=never",
            "--query-driver=/home/emile/.config/auro/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-elf/bin/aarch64-elf-gcc",
        },
        initialization_options = {
            fallbackFlags = { "-I/home/emile/repos/root-all/sdk/nxp.i3d/integration/cpp11/public" },
        },
        on_init = function(client, _)
            client.server_capabilities.semanticTokensProvider = nil
        end,
    })

    configure_server("java_language_server", {
        cmd = { "/home/emile/.local/share/java-language-server-patched/lang_server_linux_system.sh" },
        root_markers = {
            "gradlew",
            "settings.gradle",
            "settings.gradle.kts",
            "build.gradle",
            "build.gradle.kts",
            "pom.xml",
            ".git",
        },
    })

    require("user.plugins.lsp.sumneko_lua").setup()

    configure_server("jsonls", {
        cmd = { "vscode-json-language-server", "--stdio" },
        filetypes = { "json" },
        settings = {
            json = {
                validate = { enable = true },
                schemas = {},
            },
        },
    })

    configure_server("cmake", {
        cmd = { "cmake-language-server" },
        filetypes = { "cmake" },
        root_markers = {
            "CMakeLists.txt",
            ".git",
            "build",
        },
        init_options = {
            buildDirectory = "build",
        },
    })
end

local function setup_lsp()
    local capabilities = make_capabilities()

    patch_lsp_dynamic_registration()
    require("user.plugins.lsp.on_attach").setup()

    vim.lsp.config("*", {
        capabilities = capabilities,
    })

    require("mason-lspconfig").setup({
        -- Keep custom-managed servers on the explicit vim.lsp.enable path and
        -- let mason-lspconfig auto-enable only lightweight builtin configs.
        automatic_enable = { "marksman" },
    })

    configure_servers()
    enable_servers({
        "solargraph",
        "clangd",
        "lua_ls",
        "java_language_server",
        "jsonls",
        "cmake",
    })

    if vim.fn.hostname() == myhostname then
        require("user.plugins.lsp.ccls").setup()
    end
end

local lsp_config = {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        {
            "j-hui/fidget.nvim",
            tag = "v1.0.0",
            opts = {},
        },
        { "m-pilia/vim-ccls" },
        {
            "glepnir/lspsaga.nvim",
            enabled = false,
            branch = "main",
            config = function()
                require("lspsaga").setup({})
            end,
        },
        require("user.plugins.lsp.lazydev"),
        { "lvimuser/lsp-inlayhints.nvim" },
        {
            "SmiteshP/nvim-navbuddy",
            dependencies = {
                "SmiteshP/nvim-navic",
                "MunifTanjim/nui.nvim",
            },
            opts = {
                window = { size = "90%" },
                lsp = { auto_attach = true },
            },
        },
        {
            "smjonas/inc-rename.nvim",
            config = function()
                require("inc_rename").setup({})
            end,
        },
    },
    config = function()
        require("mason").setup()
        setup_mason_tool_installer()
        setup_lsp()
    end,
}

return {
    lsp_config,
}
