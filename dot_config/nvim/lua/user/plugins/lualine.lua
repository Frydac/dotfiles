local function setup()
    local theme = 'auto'
    if vim.g.colors_name == 'nightfox' or vim.g.colors_name == nil then
        if IsNotAvailable('nightfox') then
            -- goto setup_lualine
            return
        end
        -- -- if IsNotAvailable('nightfox.colors') then return end
        --
        -- -- Create custom nightfox colors
        -- -- local colors = require("nightfox.colors").load()
        local palette = require("nightfox.palette").load('nightfox')
        local Color = require("nightfox.lib.color")

        -- local util = require("nightfox.util")
        local custom_nightfox = require('lualine.themes.nightfox')

        -- custom_nightfox.normal.c.fg = palette.red.base
        -- local brighten_factor = 2.5
        -- custom_nightfox.normal.b.bg = util.brighten(colors.bg_statusline, brighten_factor)
        -- custom_nightfox.normal.b.bg = Color.new(palette.bg0):brighten(brighten_factor):to_css()
        -- custom_nightfox.normal.b.bg = palette.comment
        -- custom_nightfox.insert.b.bg = util.brighten(colors.bg_statusline, brighten_factor)
        -- custom_nightfox.command.b.bg = util.brighten(colors.bg_statusline, brighten_factor)
        -- custom_nightfox.visual.b.bg = util.brighten(colors.bg_statusline, brighten_factor)
        -- custom_nightfox.inactive.c.fg = util.darken(colors.fg_sidebar, 0.50)
        -- local gps = require("nvim-gps")
        --
        -- require('lualine').setup({
        --     options = {theme = custom_nightfox},
        --     sections = {
        --         lualine_b = {
        --             'branch', 'diff',
        --             {'diagnostics', sources = {'nvim_diagnostic', 'coc'}}
        --         },
        --         lualine_c = {
        --             {
        --                 'filename',
        --                 file_status = true, -- displays file status (readonly status, modified status)
        --                 path = 1, -- 0 = just filename, 1 = relative path, 2 = absolute path
        --                 shorting_target = 40 -- Shortens path to leave 40 space in the window
        --                                      -- for other components. Terrible name any suggestions?
        --             },
        --             -- using winbar for this
        --             -- {
        --             --     gps.get_location, cond = gps.is_available
        --             -- }
        --         }
        --     },
        --     inactive_sections = {
        --         lualine_c = {
        --             {
        --                 'filename',
        --                 file_status = true, -- displays file status (readonly status, modified status)
        --                 path = 1, -- 0 = just filename, 1 = relative path, 2 = absolute path
        --                 shorting_target = 40 -- Shortens path to leave 40 space in the window
        --                 -- for other components. Terrible name any suggestions?
        --             }
        --         }
        --     }
        -- })
        theme = custom_nightfox

    elseif vim.g.colors_name == 'nord' then
        require('lualine').setup({
            options = { theme = 'nord' }
        })
    elseif vim.g.colors_name == 'adwaita' then
        require('lualine').setup({
            options = { theme = 'adwaita' }
        })
    end

    -- ::setup_lualine

    require('lualine').setup({
        options = { theme = theme },
        sections = {
            lualine_b = {
                'branch', 'diff',
                { 'diagnostics', sources = { 'nvim_diagnostic', 'coc' } }
            },
            lualine_c = {
                {
                    'filename',
                    file_status = true, -- displays file status (readonly status, modified status)
                    path = 1, -- 0 = just filename, 1 = relative path, 2 = absolute path
                    shorting_target = 40 -- Shortens path to leave 40 space in the window
                    -- for other components. Terrible name any suggestions?
                }
            }
        },
        inactive_sections = {
            lualine_c = {
                {
                    'filename',
                    file_status = true, -- displays file status (readonly status, modified status)
                    path = 1, -- 0 = just filename, 1 = relative path, 2 = absolute path
                    shorting_target = 40 -- Shortens path to leave 40 space in the window
                    -- for other components. Terrible name any suggestions?
                }
            }
        }
    })
end

return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "kyazdani42/nvim-web-devicons", opt = true },
    -- lazy = false,
    config = function()
        vim.api.nvim_create_autocmd({ "ColorScheme" }, {
            callback = function()
                setup()
            end
        })
    end,
}
