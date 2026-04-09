local install_languages = {
    'bash',
    'c',
    'cmake',
    'cpp',
    'diff',
    'git_rebase',
    'gitattributes',
    'gitignore',
    'html',
    'http',
    'json',
    'json5',
    'lua',
    'make',
    'markdown',
    'markdown_inline',
    'ninja',
    'python',
    'query',
    'regex',
    'ruby',
    'rust',
    'vim',
    'vimdoc',
    'vue',
    'yaml',
}

local highlight_disabled = {
    markdown = true,
}

local setup = function()
    local ok, treesitter = pcall(require, 'nvim-treesitter')
    if not ok then
        return
    end

    treesitter.setup({
        install_dir = vim.fn.stdpath('data') .. '/site',
    })
    treesitter.install(install_languages)

    local group = vim.api.nvim_create_augroup('user_treesitter', { clear = true })
    vim.api.nvim_create_autocmd('FileType', {
        group = group,
        callback = function(args)
            if highlight_disabled[args.match] then
                return
            end
            pcall(vim.treesitter.start, args.buf)
        end,
    })

    if IsAvailable('treesitter-context') then
        require('treesitter-context').setup({
            enable = true,
            max_lines = 0,
            separator = ' ',
        })
        vim.keymap.set('n', '[x', function()
            require('treesitter-context').go_to_context(vim.v.count1)
        end, { silent = true })
    end
end

return {
    {
        'nvim-treesitter/nvim-treesitter',
        branch = 'main',
        lazy = false,
        build = ':TSUpdate',
        config = setup,
    },
    {
        'Badhi/nvim-treesitter-cpp-tools',
        enabled = false,
        dependencies = { 'nvim-treesitter/nvim-treesitter' },
    },
    'RRethy/nvim-treesitter-endwise',
    {
        'nvim-treesitter/nvim-treesitter-context',
    },
}
