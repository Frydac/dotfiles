return {
    "selimacerbas/markdown-preview.nvim",
    dependencies = { "selimacerbas/live-server.nvim" },
    cmd = { "MarkdownPreview", "MarkdownPreviewRefresh", "MarkdownPreviewStop" },
    config = function()
        require("markdown_preview").setup({
            instance_mode = "takeover",
            port = 0,
            open_browser = true,
            default_theme = "dark",
            debounce_ms = 300,
        })
    end,
}
