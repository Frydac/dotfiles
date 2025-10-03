
print("nightfox.lua required")

return {
    "EdenEast/nightfox.nvim",
    event = "VimEnter",
    config = function()
        vim.g.nightfox_loaded = true
        print("nightfox config executing")
        local palette = require("nightfox.palette").load('nightfox')
        local Color = require("nightfox.lib.color")
        local comment_brighter = Color.new(palette.comment):brighten(5):to_css()
        local nightfox = require('nightfox')
        nightfox.setup({
            options = {
                -- Compiled file's destination location
                compile_path = vim.fn.stdpath("cache") .. "/nightfox",
                compile_file_suffix = "_compiled", -- Compiled file suffix
                transparent = false, -- Disable setting background
                terminal_colors = true, -- Set terminal colors (vim.g.terminal_color_*) used in `:terminal`
                dim_inactive = false, -- Non focused panes set to alternative background
                styles = { -- Style to be applied to different syntax groups
                    comments = "italic", -- Value is any valid attr-list value `:help attr-list`
                    conditionals = "NONE",
                    constants = "NONE",
                    functions = "NONE",
                    keywords = "NONE",
                    numbers = "NONE",
                    operators = "NONE",
                    strings = "NONE",
                    types = "NONE",
                    variables = "NONE",
                },
                inverse = { -- Inverse highlight for different types
                    match_paren = false,
                    visual = false,
                    search = false,
                },
                modules = { -- List of various plugins and additional options
                    -- ...
                },
            },
            groups = {
                nightfox = {
                    WinSeparator = { fg = "#aaaaaa" },
                    Comment = { fg = comment_brighter },
                    IndentBlanklineContextChar = { fg = palette.bg3 },
                    IndentBlanklineChar = { fg = palette.bg2 },
                    CursorLine = { bg = palette.bg2 },
                    LspSignatureActiveParameter = { fg = palette.cyan, bg = palette.bg2 },
                    VertSplit = { fg = palette.blue.dim },
                    NormalFloat = { bg = palette.bg2 },
                    FloatBorder = { bg = palette.bg2 },
                    MasonNormal = { bg = palette.bg0 },
                    LazyNormal = { bg = palette.bg0 },
                    BqfPreviewBorder = { fg = palette.blue.dim },
                    DiffAdd = { fg = palette.red },
                    DiffDelete = { fg = palette.red },
                    DiffChange = { fg = palette.pink },
                    DiffText = { fg = palette.orange },


                    -- Treesitter
                    ["@symbol"] = { fg = palette.cyan.dim },
                }
            }
        })

        vim.cmd [[colorscheme nightfox]]

        -- `:help attr-list`
        -- bold
        -- underline
        -- underlineline	double underline
        -- undercurl	curly underline
        -- underdot	dotted underline
        -- underdash	dashed underline
        -- strikethrough
        -- reverse
        -- inverse		same as reverse
        -- italic
        -- standout
        -- nocombine	override attributes instead of combining them
        -- NONE		no attributes used (used to reset it)

        -- nightfox.setup({
        --     options = {
        --         styles = {
        --             comments = "italic"
        --             -- keywords = "bold",
        --             -- functions = "bold,italic"
        --         },
        --     }


        --     fox = 'nightfox',
        --     hlgroups = {
        --         Comment = {fg = comment_brighter},
        --         Todo = { bg = colors.blue_dm, fg = colors.bg },
        --         TSWarning = { bg = colors.blue_dm, fg = colors.bg },
        --
        --         -- TSNamespace = {fg = colors.blue},
        --         LspCxxHlSymNamespace = {fg = colors.blue_dm},
        --         LspCxxHlSymFunction = {fg = colors.blue_br},
        --         LspCxxHlSymClass = {fg = colors.green_dm},
        --         LspCxxHlSymTypeAlias = {fg = colors.green},
        --         LspCxxHlSymParameter = {fg = colors.fg, style = "italic"},
        --         LspCxxHlSymVariable = {fg = colors.fg, style = "none"},
        --     --     Type = {fg = colors.green},
        --         TSParameter = {fg = colors.fg},
        --         -- TSVariable = {fg = colors.fg_alt},
        --     --     -- TSNumber = {fg = color_lsp_cxx_magenta},
        --     --     TSNumber = {fg = colors.blue_br},
        --     --     String = {fg = colors.green_dm},
        --     --     Boolean = {fg = colors.yellow},
        --     --     Conditional = {fg = colors.orange},
        --     --     Repeat = {fg = colors.orange},
        --     --     -- VertSplit = {fg = colors.bg_},
        --     --
        --     --     -- Function = {fg = colors.blue, style = "bold"},
        --     --     Function = {fg = colors.blud},
        --     --     LspCxxHlSymMethod = {fg = colors.blue_dm, style = "bold"},
        --     --     -- Function = {fg = colors.blue},
        --     --     -- Type = {fg = colors.yellow_dm},
        --     --     -- LspCxxHlGroupMemberVariable = {fg = colors.fg, style = "bold"},
        --     --     LspCxxHlGroupMemberVariable = {
        --     --         fg = colors.white_dm,
        --     --         style = "bold"
        --     --     },
        --     --     TSProperty = {fg = colors.white_dm, style = "bold"},
        --     --     -- LspCxxHlNa
        --     helpCommand = {fg = colors.magenta, style = "bold"},
        --     helpExample = {fg = colors.blue },
        --     TSKeywordFunction = {fg = colors.red},
        --     LineNr = {fg = require("nightfox.util").brighten(colors.fg_gutter, 0.24)},
        --     CursorLineNr = {fg = colors.fg},
        --     -- LineNrBelow = {fg = colors.blue},
        --     -- LineNrAfter = {fg = colors.red},
        --     -- TSVariable = {fg = colors.fg},
        --
        --     -- hi default link HlSearchNear IncSearch
        --     -- hi default link HlSearchLens WildMenu  -> other
        --     -- hi default link HlSearchLensNear IncSearch -> after current
        --     -- hi default link HlSearchFloat IncSearch
        --     -- HlSearchNear = { fg = colors.fg, bg = colors.bg },
        --     HlSearchLensNear = { fg = colors.white, bg = colors.bg, style = "bold" },
        --     HlSearchLens = { fg = colors.fg_alt, bg = colors.bg_alt },
        --     -- HlSearchFloat = { fg = colors.fg, bg = colors.bg },
        --     -- IndentBlanklineContextStart = { style = "NONE" },
        --     -- VirtColumn = { fg =  }
        --     BqfPreviewBorder = { fg = colors.cyan_br },
        --
        --
        --     WinBar = { bg = colors.bg_alt, style = "bold" },
        --
        --     -- UfoFoldedFg
        --     -- UfoFoldedBg = { bg = bg_darker },
        --     -- UfoFoldedBg = { bg = colors.black },
        --     UfoFoldedEllipsis = { fg = colors.cyan }

        -- hi link helpCommand Keyword
        -- hi link helpExample Function
        --     }
        -- })
        -- nightfox.load()

        -- require('nightfox').load('nordfox')
        -- require('nightfox').load('nightfox')
    end
}
