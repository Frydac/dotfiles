local function basename(path) return path:sub(path:find("/[^/]*$") + 1) end

return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "kyazdani42/nvim-web-devicons", -- not strictly required, but recommended
        "MunifTanjim/nui.nvim",
        -- {
        --     -- only needed if you want to use the commands with "_with_window_picker" suffix
        --     's1n7ax/nvim-window-picker',
        --     tag = "1.*",
        --     config = function()
        --         require 'window-picker'.setup({
        --             autoselect_one = true,
        --             include_current = false,
        --             filter_rules = {
        --                 -- filter using buffer options
        --                 bo = {
        --                     -- if the file type is one of following, the window will be ignored
        --                     filetype = { 'neo-tree', "neo-tree-popup", "notify", "quickfix" },

        --                     -- if the buffer type is one of following, the window will be ignored
        --                     buftype = { 'terminal' },
        --                 },
        --             },
        --             other_win_hl_color = '#e35e4f',
        --         })
        --     end,
        -- }
    },
    config = function()
        -- If you want icons for diagnostic errors, you'll need to define them somewhere:
        vim.fn.sign_define("DiagnosticSignError",
            { text = " ", texthl = "DiagnosticSignError" })
        vim.fn.sign_define("DiagnosticSignWarn",
            { text = " ", texthl = "DiagnosticSignWarn" })
        vim.fn.sign_define("DiagnosticSignInfo",
            { text = " ", texthl = "DiagnosticSignInfo" })
        vim.fn.sign_define("DiagnosticSignHint",
            { text = "", texthl = "DiagnosticSignHint" })
        -- NOTE: this is changed from v1.x, which used the old style of highlight groups
        -- in the form "LspDiagnosticsSignWarning"

        require("neo-tree").setup({
            use_popups_for_input = false, -- If false, inputs will use vim.ui.input() instead of custom floats.

            close_if_last_window = false, -- Close Neo-tree if it is the last window left in the tab
            use_basename_for_move_and_copy = false,
            popup_border_style = "rounded",
            enable_git_status = true,
            enable_diagnostics = true,
            -- enable_normal_mode_for_inputs = false, -- Enable normal mode for input dialogs.
            open_files_do_not_replace_types = { "terminal", "trouble", "qf" }, -- when opening files, do not use windows containing these filetypes or buftypes
            sort_case_insensitive = false, -- used when sorting files and directories in the tree
            sort_function = nil, -- use a custom function for sorting files and directories in the tree
            -- sort_function = function (a,b)
            --       if a.type == b.type then
            --           return a.path > b.path
            --       else
            --           return a.type > b.type
            --       end
            --   end , -- this sorts files and directories descendantly
            default_component_configs = {
                container = {
                    enable_character_fade = true
                },
                indent = {
                    indent_size = 2,
                    padding = 1, -- extra padding on left hand side
                    -- indent guides
                    with_markers = true,
                    indent_marker = "│",
                    last_indent_marker = "└",
                    highlight = "NeoTreeIndentMarker",
                    -- expander config, needed for nesting files
                    with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
                    expander_collapsed = "",
                    expander_expanded = "",
                    expander_highlight = "NeoTreeExpander",
                },
                icon = {
                    folder_closed = ' ',
                    folder_open = ' ',
                    folder_empty = ' ',
                    -- The next two settings are only a fallback, if you use nvim-web-devicons and configure default icons there
                    -- then these will never be used.
                    default = "*",
                    highlight = "NeoTreeFileIcon"
                },
                modified = {
                    symbol = "[+]",
                    highlight = "NeoTreeModified",
                },
                name = {
                    trailing_slash = false,
                    use_git_status_colors = true,
                    highlight = "NeoTreeFileName",
                },
                git_status = {
                    symbols = {
                        -- Change type
                        added     = "", -- or "✚", but this is redundant info if you use git_status_colors on the name
                        modified  = "", -- or "", but this is redundant info if you use git_status_colors on the name
                        deleted   = "✖", -- this can only be used in the git_status source
                        renamed   = "", -- this can only be used in the git_status source
                        -- Status type
                        untracked = "",
                        ignored   = " ",
                        unstaged  = " ",
                        staged    = " ",
                        conflict  = "",
                    }
                },
            },
            window = {
                position = "left",
                width = 60,
                mapping_options = {
                    noremap = true,
                    nowait = true,
                },
                mappings = {
                    ["<space>"] = {
                        "toggle_node",
                        nowait = false, -- disable `nowait` if you have existing combos starting with this char that you want to use
                    },
                    ["<2-LeftMouse>"] = "open",
                    ["<cr>"] = "open",
                    ["<tab>"] = "toggle_preview", -- enter preview mode, which shows the current node without focusing
                    ["P"] = { "toggle_preview", config = { use_float = true } },
                    ["<esc>"] = "revert_preview",
                    ["S"] = "open_split",
                    ["s"] = "open_vsplit",
                    -- ["S"] = "split_with_window_picker",
                    -- ["s"] = "vsplit_with_window_picker",
                    ["t"] = "open_tabnew",
                    ["w"] = "open_with_window_picker",
                    ["C"] = "close_node",
                    ["z"] = "close_all_subnodes",
                    ["<space>z"] = "close_all_nodes",
                    -- TODO: find something for expand_all_subnodes
                    ["Z"] = "expand_all_nodes",
                    ["a"] = {
                        "add",
                        -- some commands may take optional config options, see `:h neo-tree-mappings` for details
                        -- config = {
                        --     -- show_path = "none" -- "none", "relative", "absolute"
                        --     show_path = "absolute" -- "none", "relative", "absolute"
                        -- }
                    },
                    ["A"] = "add_directory", -- also accepts the config.show_path option.
                    ["d"] = "delete",
                    ["r"] = "rename",
                    ["y"] = "copy_to_clipboard",
                    ["x"] = "cut_to_clipboard",
                    ["p"] = "paste_from_clipboard",
                    ["c"] = {
                        "copy", -- takes text input for destination
                        config = {
                            -- show_path = "none"
                            show_path = "absolute"
                        }
                    },
                    ["m"] = {
                        "move",
                        config = {
                            show_path = "absolute"
                        }
                    }, -- takes text input for destination
                    ["q"] = "close_window",
                    ["R"] = "refresh",
                    ["?"] = "show_help",
                    ["<"] = "prev_source",
                    [">"] = "next_source",
                    -- ["Y"] = function(state)
                    --     local node = state.tree:get_node()
                    --     vim.fn.setreg('*', node.name, 'c')
                    -- end,
                    ["gy"] = function(state)
                        local node = state.tree:get_node()
                        local full_path = node.path
                        local relative_path = full_path:sub(#state.path + 2)
                        vim.fn.setreg('"', relative_path, 'c')
                        vim.fn.setreg('+', relative_path, 'c')
                        print("Yanked '" .. relative_path .. "'")
                    end,
                    ["gY"] = function(state)
                        local node = state.tree:get_node()
                        local full_path = node.path
                        vim.fn.setreg('"', full_path, 'c')
                        vim.fn.setreg('+', full_path, 'c')
                        print("Yanked '" .. full_path .. "'")
                    end,
                    ["<space>gy"] = function(state)
                        local node = state.tree:get_node()
                        local full_path = node.path
                        local basename_ = basename(full_path)
                        vim.fn.setreg('"', basename_, 'c')
                        vim.fn.setreg('+', basename_, 'c')
                        print("Yanked '" .. basename_ .. "'")
                    end
                }
            },
            nesting_rules = {},
            filesystem = {
                filtered_items = {
                    visible = false, -- when true, they will just be displayed differently than normal items
                    hide_dotfiles = true,
                    hide_gitignored = false,
                    hide_hidden = false, -- only works on Windows for hidden files/directories
                    hide_by_name = {
                        --"node_modules"
                    },
                    hide_by_pattern = { -- uses glob style patterns
                        --"*.meta"
                    },
                    never_show = { -- remains hidden even if visible is toggled to true
                        --".DS_Store",
                        --"thumbs.db"
                    },
                },
                follow_current_file = { enabled = false }, -- This will find and focus the file in the active buffer every
                -- time the current file is changed while the tree is open.
                group_empty_dirs = false, -- when true, empty folders will be grouped together
                hijack_netrw_behavior = "open_default", -- netrw disabled, opening a directory opens neo-tree
                -- in whatever position is specified in window.position
                -- "open_current",  -- netrw disabled, opening a directory opens within the
                -- window like netrw would, regardless of window.position
                -- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
                use_libuv_file_watcher = false, -- This will use the OS level file watchers to detect changes
                -- instead of relying on nvim autocmd events.
                window = {
                    mappings = {
                        ["<bs>"] = "navigate_up",
                        ["."] = "set_root",
                        ["H"] = "toggle_hidden",
                        ["/"] = "noop", -- disable the default fuzzy search in favor of default vim search
                        ["g/"] = "fuzzy_finder",
                        ["D"] = "fuzzy_finder_directory",
                        ["f"] = "filter_on_submit",
                        ["<c-x>"] = "clear_filter",
                        ["[g"] = "prev_git_modified",
                        ["]g"] = "next_git_modified",
                    }
                }
            },
            buffers = {
                follow_current_file = { enabled = true }, -- This will find and focus the file in the active buffer every
                -- time the current file is changed while the tree is open.
                group_empty_dirs = true, -- when true, empty folders will be grouped together
                show_unloaded = true,
                hijack_netrw_behavior = "open_default", -- netrw disabled, opening a directory opens neo-tree
                    -- in whatever position is specified in window.position
                    -- "open_current",  -- netrw disabled, opening a directory opens within the
                    -- window like netrw would, regardless of window.position
                    -- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
                use_libuv_file_watcher = false, -- This will use the OS level file watchers to detect changes
                    -- instead of relying on nvim autocmd events.
                window = {
                    mappings = {
                        ["bd"] = "buffer_delete",
                        ["<bs>"] = "navigate_up",
                        ["."] = "set_root",
                    }
                },
            },
            git_status = {
                window = {
                    position = "float",
                    mappings = {
                        ["A"]  = "git_add_all",
                        ["gu"] = "git_unstage_file",
                        ["ga"] = "git_add_file",
                        ["gr"] = "git_revert_file",
                        ["gc"] = "git_commit",
                        ["gp"] = "git_push",
                        ["gg"] = "git_commit_and_push",
                    }
                }
            },

            event_handlers = {
                {
                    event = 'file_opened',
                    handler = function(_file_path)
                        -- auto close
                        require('neo-tree').close_all()
                    end

                }
            },
            log_level = "trace",
            log_to_file = true,
        })

        vim.keymap.set('n', '-', "<cmd>Neotree reveal_force_cwd left<cr>")
        vim.keymap.set('n', '<leader>-', "<cmd>Neotree reveal_force_cwd float<cr>")
    end
}
