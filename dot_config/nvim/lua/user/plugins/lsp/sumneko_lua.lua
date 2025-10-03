local M = {}

-- TODO: remove if not needed, maybe for windows? (to find lua lsp exe and root path)
-- local function lua_lsp_paths()
--     local system_name
--     if vim.fn.has("mac") == 1 then
--         system_name = "macOS"
--     elseif vim.fn.has("unix") == 1 then
--         system_name = "Linux"
--     elseif vim.fn.has('win32') == 1 then
--         system_name = "Windows"
--     else
--         print("Unsupported system for sumneko")
--     end

--     local paths = {}

--     -- set the path to the sumneko installation; if you previously installed via the now deprecated :LspInstall, use
--     paths.root_path = vim.fn.stdpath('cache')..'/lspconfig/sumneko_lua/lua-language-server'
--     paths.binary = paths.root_path.."/bin/"..system_name.."/lua-language-server"

--     return paths
-- end

-- local function library_paths()
--     local lib_paths = vim.api.nvim_get_runtime_file("", true)
--     local function lib_paths_expand_and_add(paths)
--         for _, path in pairs(vim.fn.expand(paths, false, true)) do
--             path = vim.loop.fs_realpath(path)
--             lib_paths[path] = true
--         end
--     end
--     lib_paths_expand_and_add("~/.config/nvim")
--     lib_paths_expand_and_add("~/.local/share/nvim/site/pack/packer/opt/*")
--     lib_paths_expand_and_add("~/.local/share/nvim/site/pack/packer/start/*")
--     return lib_paths
-- end

local function runtime_paths()
    local runtime_path = vim.split(package.path, ';')
    table.insert(runtime_path, "lua/?.lua")
    table.insert(runtime_path, "lua/?/init.lua")
    return runtime_path
end

-- local str = "string"
-- string.find(str, 'r')
-- str:find('r')
-- local tbl = {}
-- table.insert(tbl, 'a')
-- tbl:insert('b')

-- print(vim.inspect(runtime_paths()))

local function basename(path) return path:sub(path:find("/[^/]*$") + 1) end

-- return lua dir in path or nil
-- local function find_lua_parent(path)
--     local Path = require('plenary.path')
--     path = Path:new(path)
--     for _, parent in pairs(path:parents()) do
--         if (basename(parent) == "lua") then return parent end
--     end
-- end

-- Find parent directory named "lua"
local function find_lua_parent(path)
    local dir = vim.fs.dirname(path)
    for parent in vim.fs.parents(dir) do
        if vim.fs.basename(parent) == "lua" then
            return parent
        end
    end
end

-- for some reason adding the .config/nvim causes double results with goto/references
-- TOOD: it still finds stuff double it seems, not sure why?
local function get_runtime_paths_without_config()
    local paths = vim.api.nvim_get_runtime_file("", true)
    local new_paths = {}
    for _, path in pairs(paths) do
        if not path:find(".config") then
            table.insert(new_paths, path)
        end
    end
    return new_paths
end

-- get_runtime_paths_without_config()

function M.setup_old()

    -- local lsp_paths = lua_lsp_paths();

    local lspconfig = require('lspconfig')
    -- lspconfig.sumneko_lua.setup {
    --     on_attach = require('emile.plugins.lsp.on_attach').on_attach,
    --     root_dir = find_lua_parent or lspconfig.util.root_pattern(".git") or lspconfig.util.path.dirname,
    -- }
    lspconfig.lua_ls.setup {
        -- not needed on manjaro, it has a package that does this in a bash script
        -- cmd = {lsp_paths.binary, "-E", lsp_paths.root_path .. "/main.lua"};
        --     cmd = {"/usr/bin/lua-language-server"},
        on_attach = require('user.plugins.lsp.on_attach').on_attach,
        root_dir = find_lua_parent or lspconfig.util.root_pattern(".git") or lspconfig.util.path.dirname,
        commands = {
            Format = {
                function()
                    -- TODO: table merge when available, otherwise leave default?
                    -- if IsNotAvailable("stylua-nvim") then return end
                    -- require("stylua-nvim").format_file()
                end,
            },
        },
        settings = {
            Lua = {
                runtime = {
                    -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                    version = 'LuaJIT',
                    -- Setup your lua path
                    -- path = runtime_paths(),
                },
                diagnostics = {
                    -- Get the language server to recognize the `vim` global
                    globals = { 'vim' },
                },
                workspace = {
                    -- Make the server aware of Neovim runtime files
                    library = vim.api.nvim_get_runtime_file("", true),
                    -- Make the server aware of Neovim runtime files
                    -- library = get_runtime_paths_without_config()
                    -- library = library_paths(),
                    -- maxPreload = 5000,
                    -- preloadFileSize = 100000
                    -- Not sure what this does: sumneko's lua server wants to
                    -- set this, but only vs code lets language servers change
                    -- options, so need to set it manually.
                    checkThirdParty = false -- stop check at start with question
                },
                --             -- Do not send telemetry data containing a randomized but unique identifier
                telemetry = {
                    enable = false,
                },
                completion = {
                    callSnippet = "Replace"
                },
                hint = {
                    enable = true
                }
            },
        },
    }
end

-- return M


-- local M = {}

function M.setup()
    local default_on_attach = require("user.plugins.lsp.on_attach").on_attach

    -- Merge with existing lua_ls defaults
    vim.lsp.config["lua_ls"] = vim.tbl_deep_extend(
        "force",
        vim.lsp.config["lua_ls"] or {},
        {
            on_attach = default_on_attach,
            root_dir = function(fname)
                return find_lua_parent(fname)
                    or vim.fs.find(".git", { upward = true, path = fname })[1]
                    or vim.fs.dirname(fname)
            end,
            commands = {
                Format = {
                    function()
                        -- TODO: integrate stylua-nvim here
                    end,
                },
            },
            settings = {
                Lua = {
                    runtime = { version = "LuaJIT" },
                    diagnostics = { globals = { "vim" } },
                    workspace = {
                        library = vim.api.nvim_get_runtime_file("", true),
                        checkThirdParty = false,
                    },
                    telemetry = { enable = false },
                    completion = { callSnippet = "Replace" },
                    hint = { enable = true },
                },
            },
        }
    )
end

return M
