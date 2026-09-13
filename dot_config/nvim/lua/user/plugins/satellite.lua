return {
    -- satellite.nvim is a Neovim plugin that displays decorated scrollbars
    "lewis6991/satellite.nvim",
    opts = {},
    config = function(_, opts)
        require("satellite").setup(opts)

        -- Satellite caches diagnostics without checking whether display is enabled.
        local handlers = require("satellite.handlers")
        handlers.init()
        for _, handler in ipairs(handlers.handlers) do
            if handler.name == "diagnostic" then
                local update = handler.update
                handler.update = function(bufnr, winid)
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
