-- Install lazy.nvim package manager if needed
local function bootstrap()
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not vim.loop.fs_stat(lazypath) then
        print("* Installing lazy.nvim")

        vim.fn.system({
            "git",
            "clone",
            "--filter=blob:none",
            "--single-branch",
            "https://github.com/folke/lazy.nvim.git",
            lazypath,
        })
    end
    vim.opt.runtimepath:prepend(lazypath)
end

local plugins = {
    -- require("user.plugins.hop"),

    require("user.plugins.ai_gpt"),
    require("user.plugins.avante"),  -- ai plugin
    require("user.plugins.agentic"), -- ai plugin
    require("user.plugins.align"),
    -- require("user.plugins.autopairs"),
    -- require("user.plugins.blink_cmp"),
    require("user.plugins.block_nvim"), -- use :Block
    require("user.plugins.cmp"),
    -- require("user.plugins.codeium"),
    require("user.plugins.supermaven"),
    -- require("user.plugins.codecompanion"),
    require("user.plugins.csvview"), -- markdown todo stuff
    require("user.plugins.checkmate"), -- markdown todo stuff
    require("user.plugins.color_syntax"),
    -- require("user.plugins.mini.comment"),
    require("user.plugins.comment"),
    require("user.plugins.cppman"),
    require("user.plugins.ctags"),
    require("user.plugins.dap"),
    require("user.plugins.dial"),  -- additional <c-x>, <c-a> increase/decrease functionality
    require("user.plugins.diffview"),
    require("user.plugins.flash"), -- extended s/f find functionality
    require("user.plugins.fzf"),
    require("user.plugins.fzf_lua"),
    require("user.plugins.gp_nvim"),
    require("user.plugins.gitsigns-nvim"),
    require("user.plugins.harpoon"),
    require("user.plugins.illuminate"), -- automatically highlight other uses of word under cursor, :IlluminateToggle
    -- require("user.plugins.lightspeed"),
    require("user.plugins.krust"),
    require("user.plugins.lsp"),
    require("user.plugins.luadev"),
    require("user.plugins.lualine"),
    require("user.plugins.luasnip"),
    -- require("user.plugins.markdown-composer"),
    require("user.plugins.markdown-preview"),

    -- require("user.plugins.marks"),
    require("user.plugins.matchup"),
    -- require("user.plugins.multicursor"),
    require("user.plugins.mine"),
    require("user.plugins.neotree"),
    require("user.plugins.neogit"),
    require("user.plugins.neotest"),
    -- require("user.plugins.nightfox"),
    -- require("user.plugins.noice"),
    require("user.plugins.colorschemes"),
    require("user.plugins.mini.files"),
    -- require("user.plugins.mini.surround"),
    require("user.plugins.oil"),
    require("user.plugins.persistence"),
    require("user.plugins.replacer"),
    require("user.plugins.render_markdown_nvim"),
    require("user.plugins.sideways"),
    require("user.plugins.symbols"),
    require("user.plugins.surround_nvim"),
    require("user.plugins.telescope"),
    require("user.plugins.textobjects"),
    require("user.plugins.treesitter"),
    require("user.plugins.treewalker"),
    require("user.plugins.troublesum"), -- show diagnostics in top right corner
    require("user.plugins.vim-fugitive"),
    require("user.plugins.yanky"),
    require("user.plugins.hightlight_word_under_cursor"),
    require("user.plugins.debugprint"),
    require("user.plugins.gitlinker"),      -- get link to online repository, usage: `<leader>gy` on a selection
    require("user.plugins.hlsens"),         -- highlight search items and count
    require("user.plugins.indent-blankline"),
    require("user.plugins.ufo"),            -- The goal of nvim-ufo is to make Neovim's fold look modern and keep high performance.
    require("user.plugins.bqf"),            -- enhanced quickfix list
    require("user.plugins.virtual-column"), -- use virtual text to draw the colorcolumn at textwidth
    require("user.plugins.neozoom"),
    require('user.plugins.mind'),
    require('user.plugins.noneckpain'),
    require('user.plugins.rustacean'),
    require('user.plugins.statuscol'),
    -- require('user.plugins.symbols_outline'),
    require('user.plugins.tiny_devicons_auto_colors'),
    require('user.plugins.trouble'),
    require('user.plugins.xmake'),
    require('user.plugins.undotree'),
    "milisims/nvim-luaref",
    -- "tpope/vim-surround",
    "RRethy/nvim-treesitter-endwise",
    "lambdalisue/suda.vim",
    -- 'chrisbra/csv.vim',
    -- 'ibhagwan/fzf-lua',
    "jremmen/vim-ripgrep",
    "mg979/vim-visual-multi",
    "Valloric/ListToggle", -- <leader>q <leader>l
    "tpope/vim-unimpaired",
    "bogado/file-line",    -- open file with file:line:column format
    "kazhala/close-buffers.nvim",
    "AndrewRadev/linediff.vim",
    { "CRAG666/code_runner.nvim",  config = true },
    { 'akinsho/git-conflict.nvim', version = "*", config = true }

    -- 'AndrewRadev/splitjoin.vim',
    -- use 'tpope/vim-endwise'
}

local options = {
    -- install = {
    --     -- try to load the colorscheme when installing missing plugins at startup (e.g. before loading any plugins)
    --     colorscheme = { 'nightfox' }
    -- },
    dev = {
        path = "~/repos",        -- dir where local plugins are stored
        patterns = { "Frydac" }, -- plugins that match will be searched in repos dir
        fallback = true,         -- fallback to url
    }
}

bootstrap()
require("lazy").setup(plugins, options)
