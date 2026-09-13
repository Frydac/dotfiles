return {
    -- satellite.nvim is a Neovim plugin that displays decorated scrollbars
    "lewis6991/satellite.nvim",
    opts = {},
    config = function(_, opts)
        require("satellite").setup(opts)

        -- Support dynamic diagnostics toggle, see also .config/nvim/lua/user/keymaps.lua
        -- Satellite caches diagnostic data when DiagnosticChanged fires. Disabling
        -- diagnostics only hides Neovim's decorations; it does not empty that cache,
        -- so Satellite would keep drawing its cached marks in the scrollbar.
        local handlers = require("satellite.handlers")
        handlers.init() -- Load built-in handlers before finding the diagnostic one.
        for _, handler in ipairs(handlers.handlers) do
            if handler.name == "diagnostic" then
                local update = handler.update -- Keep Satellite's original mark builder.
                handler.update = function(bufnr, winid)
                    -- Returning no marks makes Satellite clear this scrollbar's old
                    -- diagnostic extmarks during the refresh requested by keymaps.lua.
                    if not vim.diagnostic.is_enabled({ bufnr = bufnr }) then
                        return {}
                    end
                    return update(bufnr, winid)
                end
                break
            end
        end
    end,
}
