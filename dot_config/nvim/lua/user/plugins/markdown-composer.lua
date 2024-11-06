return {
        "euclio/vim-markdown-composer",
        run = "cargo build --release",
        config = function()
            vim.g.markdown_composer_external_renderer = "pandoc -f markdown -t html"
            vim.g.markdown_composer_autostart = 0
        end,
    }
