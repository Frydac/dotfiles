local setup = function()
    if IsNotAvailable('nvim-treesitter.configs') then return end
    local tree_sitter_config = {}

    tree_sitter_config.endwise = {
        enable = true
    }
    tree_sitter_config.ensure_installed = {
        'bash',
        'c',
        'cmake',
        'cpp',
        'diff',
        'git_rebase',
        'gitattributes',
        -- 'gitcommit',
        'gitignore',
        'vimdoc',
        'html',
        'http',
        'json',
        'json5',
        'jsonc',
        'lua',
        'make',
        'ninja',
        'norg',
        'python',
        'regex',
        'ruby',
        'rust',
        'vim',
        'vue',
        'yaml',
    }
    tree_sitter_config.highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
        -- disable = { 'gitcommit' } --stopped working, not sure why
        disable = { 'markdown' }
    }
    tree_sitter_config.incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = '<CR>',
            scope_incremental = '<CR>',
            node_incremental = '<TAB>',
            node_decremental = '<S-TAB>'
        }
    }
    tree_sitter_config.textobjects = {}
    tree_sitter_config.textobjects.select = {
        enable = false,

        -- Automatically jump forward to textobj, similar to targets.vim
        lookahead = true,

        keymaps = {
            -- You can use the capture groups defined in textobjects.scm
            ["am"] = "@function.outer",
            ["im"] = "@function.inner",
            ["as"] = "@class.outer",
            ["is"] = "@class.inner",
            ["al"] = "@block.outer",
            ["il"] = "@block.inner",
            ["ac"] = "@comment.outer",
            ["ic"] = "@comment.inner",

            -- Or you can define your own textobjects like this
            -- ["iF"] = {
            --     python = "(function_definition) @function",
            --     cpp = "(function_definition) @function",
            --     c = "(function_definition) @function",
            --     java = "(method_declaration) @function",
            -- },
        },
    }
    tree_sitter_config.textobjects.move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
            ["]m"] = "@function.outer",
            ["]]"] = "@class.outer",
        },
        goto_next_end = {
            ["]M"] = "@function.outer",
            ["]["] = "@class.outer",
        },
        goto_previous_start = {
            ["[m"] = "@function.outer",
            ["[["] = "@class.outer",
        },
        goto_previous_end = {
            ["[M"] = "@function.outer",
            ["[]"] = "@class.outer",
        },
    }
    tree_sitter_config.textobjects.lsp_interop = {
        enable = true,
        border = 'none',
        peek_definition_code = {
            ["<leader>df"] = "@function.outer",
            ["<leader>dF"] = "@class.outer",
        },
    }

    -- if IsAvailable('nvim-treesitter.nt-cpp-tools.output_handlers') then
    --     tree_sitter_config.nt_cpp_tools = {
    --         enable = true,
    --         preview = {
    --             quit = 'q',                           -- optional keymapping for quit preview
    --             accept = '<tab>'                      -- optional keymapping for accept preview
    --         },
    --         header_extension = 'h',                   -- optional
    --         source_extension = 'cxx',                 -- optional
    --         custom_define_class_function_commands = { -- optional
    --             TSCppImplWrite = {
    --                 output_handle = require 'nvim-treesitter.nt-cpp-tools.output_handlers'.get_add_to_cpp()
    --             }
    --             --[[
    --     <your impl function custom command name> = {
    --         output_handle = function (str, context)
    --             -- string contains the class implementation
    --             -- do whatever you want to do with it
    --         end
    --     }
    --     ]]
    --         }
    --     }
    -- end

    tree_sitter_config.playground = {
        enable = true,
        disable = {},
        updatetime = 25,         -- Debounced time for highlighting nodes in the playground from source code
        persist_queries = false, -- Whether the query persists across vim sessions
        keybindings = {
            toggle_query_editor = 'o',
            toggle_hl_groups = 'i',
            toggle_injected_languages = 't',
            toggle_anonymous_nodes = 'a',
            toggle_language_display = 'I',
            focus_language = 'f',
            unfocus_language = 'F',
            update = 'R',
            goto_node = '<cr>',
            show_help = '?',
        },
    }

    tree_sitter_config.rainbow = {
        enable = false,
        disable = { "tree" },  -- list of languages you want to disable the plugin for
        extended_mode = false, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
        max_file_lines = nil,  -- Do not enable for files with more than n lines, int
        -- colors = {}, -- table of hex strings
        -- termcolors = {} -- table of colour name strings
    }

    if IsAvailable('treesitter-context') then
        require 'treesitter-context'.setup({
            enable = true,
            max_lines = 10,
            separator = ' ',

        })
        vim.keymap.set("n", "[x", function()
            require("treesitter-context").go_to_context(vim.v.count1)
        end, { silent = true })
    end

    if IsAvailable('nvim-treesitter.configs') then
        tree_sitter_config.matchup = {
            require 'nvim-treesitter.configs'.setup {
                matchup = {
                    enable = true, -- mandatory, false will disable the whole extension
                    -- disable = { "c", "ruby" }, -- optional, list of language that will be disabled
                    -- [options]
                }
            }
        }
    end

    require('nvim-treesitter.configs').setup(tree_sitter_config)

    -- require('nvim-treesitter.configs').setup {
    --     endwise = {
    --         enable = true
    --     },
    --     -- ensure_installed = 'maintained',
    --     ensure_installed = {'c', 'cpp', 'ruby', 'cmake', 'json', 'lua', 'ninja', 'vim', 'yaml'},
    --     highlight = {
    --         enable = true,
    --         additional_vim_regex_highlighting = false,
    --     },
    --     incremental_selection = {
    --         enable = true,
    --         keymaps = {
    --             init_selection = '<CR>',
    --             scope_incremental = '<CR>',
    --             node_incremental = '<TAB>',
    --             node_decremental = '<S-TAB>'
    --         }
    --     },
    --     textobjects = {
    --         select = {
    --             enable = true,
    --
    --             -- Automatically jump forward to textobj, similar to targets.vim
    --             lookahead = true,
    --
    --             keymaps = {
    --                 -- You can use the capture groups defined in textobjects.scm
    --                 ["am"] = "@function.outer",
    --                 ["im"] = "@function.inner",
    --                 ["ac"] = "@class.outer",
    --                 ["ic"] = "@class.inner",
    --
    --                 -- Or you can define your own textobjects like this
    --                 -- ["iF"] = {
    --                 --     python = "(function_definition) @function",
    --                 --     cpp = "(function_definition) @function",
    --                 --     c = "(function_definition) @function",
    --                 --     java = "(method_declaration) @function",
    --                 -- },
    --             },
    --         },
    --         move = {
    --             enable = true,
    --             set_jumps = true, -- whether to set jumps in the jumplist
    --             goto_next_start = {
    --                 ["]m"] = "@function.outer",
    --                 ["]]"] = "@class.outer",
    --             },
    --             goto_next_end = {
    --                 ["]M"] = "@function.outer",
    --                 ["]["] = "@class.outer",
    --             },
    --             goto_previous_start = {
    --                 ["[m"] = "@function.outer",
    --                 ["[["] = "@class.outer",
    --             },
    --             goto_previous_end = {
    --                 ["[M"] = "@function.outer",
    --                 ["[]"] = "@class.outer",
    --             },
    --         },
    --         lsp_interop = {
    --             enable = true,
    --             border = 'none',
    --             peek_definition_code = {
    --                 ["<leader>df"] = "@function.outer",
    --                 ["<leader>dF"] = "@class.outer",
    --             },
    --         },
    --     },
    -- }

    -- vim.cmd [[ augroup treesitter | autocmd! | augroup end ]]
    -- vim.cmd [[
    -- augroup treesittergroup
    -- autocmd!
    -- autocmd FileType cpp setlocal foldmethod=expr
    -- autocmd FileType cpp setlocal foldexpr=nvim_treesitter#foldexpr()
    -- augroup END
    -- ]]

    -- vim.cmd [[
    --     autocmd treesitter FileType cpp,c setlocal foldexpr=nvim_treesitter#foldexpr()
    --     autocmd treesitter FileType cpp,c setlocal foldmethod=expr
    -- ]]
end

return {
    {
        "nvim-treesitter/nvim-treesitter",
        -- commit = '48a3da710369688df80beb2847dabbbd02e2180e',
        config = function()
            setup()
        end,
    },
    "nvim-treesitter/playground",
    {
        -- Has commands starting with :TSCpp..
        "Badhi/nvim-treesitter-cpp-tools",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        -- Optional: Configuration
        opts = function()
            local options = {
                preview = {
                    quit = "q",                       -- optional keymapping for quit preview
                    accept = "<tab>",                 -- optional keymapping for accept preview
                },
                header_extension = "hpp",               -- optional
                source_extension = "cpp",             -- optional
                custom_define_class_function_commands = { -- optional
                    TSCppImplWrite = {
                        output_handle = require("nt-cpp-tools.output_handlers").get_add_to_cpp(),
                    },
                    --[[
                <your impl function custom command name> = {
                    output_handle = function (str, context)
                        -- string contains the class implementation
                        -- do whatever you want to do with it
                    end
                }
                ]]
                },
            }
            return options
        end,
        -- End configuration
        config = true,
    },
    {
        "mrjones2014/nvim-ts-rainbow"
    },
    {
        'nvim-treesitter/nvim-treesitter-context'
    }
    -- split/join, not great.. and use_default_mappings = false doesn't seem to work, uses <leader>m
    -- {
    --     'Wansmer/treesj',
    --     config = function()
    --         require('treesj').setup({
    --             use_default_mappings = false
    --         })
    --     end,
    -- }

}
