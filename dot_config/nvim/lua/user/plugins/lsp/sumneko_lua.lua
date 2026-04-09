local M = {}

local function find_lua_parent(path)
    local dir = vim.fs.dirname(path)
    for parent in vim.fs.parents(dir) do
        if vim.fs.basename(parent) == "lua" then
            return parent
        end
    end
end

function M.setup()
    vim.lsp.config("lua_ls", {
        root_dir = function(fname)
            return find_lua_parent(fname)
                or vim.fs.find(".git", { upward = true, path = fname })[1]
                or vim.fs.dirname(fname)
        end,
        commands = {
            Format = {
                function()
                    -- TODO: integrate stylua-nvim here if it becomes part of the config again.
                end,
            },
        },
        settings = {
            Lua = {
                runtime = {
                    version = "LuaJIT",
                },
                diagnostics = {
                    globals = { "vim" },
                },
                workspace = {
                    library = vim.api.nvim_get_runtime_file("", true),
                    checkThirdParty = false,
                },
                telemetry = {
                    enable = false,
                },
                completion = {
                    callSnippet = "Replace",
                },
                hint = {
                    enable = true,
                },
            },
        },
    })
end

return M
