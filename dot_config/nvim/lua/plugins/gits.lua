return {
    {
        "tpope/vim-fugitive"
    },
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require('gitsigns').setup {
                signs                        = {
                    add          = { text = '┃┃' },
                    change       = { text = '┃┃' },
                    delete       = { text = '__' },
                    topdelete    = { text = '‾‾' },
                    changedelete = { text = '~~' },
                    untracked    = { text = '┆┆' },
                },
                signs_staged                 = {
                    add          = { text = '┃┃' },
                    change       = { text = '┃┃' },
                    delete       = { text = '__' },
                    topdelete    = { text = '‾‾' },
                    changedelete = { text = '~~' },
                    untracked    = { text = '┆┆' },
                },
                signs_staged_enable          = true,
                signcolumn                   = true,  -- Toggle with `:Gitsigns toggle_signs`
                numhl                        = false, -- Toggle with `:Gitsigns toggle_numhl`
                linehl                       = false, -- Toggle with `:Gitsigns toggle_linehl`
                word_diff                    = false, -- Toggle with `:Gitsigns toggle_word_diff`
                watch_gitdir                 = {
                    follow_files = true
                },
                auto_attach                  = true,
                attach_to_untracked          = false,
                current_line_blame           = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
                current_line_blame_opts      = {
                    virt_text = true,
                    virt_text_pos = 'right_align', -- 'eol' | 'overlay' | 'right_align'
                    delay = 300,
                    ignore_whitespace = false,
                    virt_text_priority = 100,
                },
                current_line_blame_formatter = '<summary> - <author>, <author_time:%R>',
                sign_priority                = 6,
                update_debounce              = 100,
                status_formatter             = nil,   -- Use default
                max_file_length              = 40000, -- Disable if file is longer than this (in lines)
                preview_config               = {
                    -- Options passed to nvim_open_win
                    border = 'single',
                    style = 'minimal',
                    relative = 'cursor',
                    row = 0,
                    col = 1
                },
                on_attach                    = function(bufnr)
                    local gitsigns = require('gitsigns')

                    local function map(mode, l, r, opts)
                        opts = opts or {}
                        opts.buffer = bufnr
                        vim.keymap.set(mode, l, r, opts)
                    end
                    vim.keymap.set('n', '<leader>yh', "<cmd> GitBlameCopySHA<CR>",
                        { desc = "Copy the git blame SHA on current line" })
                    vim.keymap.set('n', '<leader>hb', '<cmd> Gitsigns blame<CR>',
                        { desc = "Show the git blame on the current file" })


                    vim.keymap.set('n', '<leader>hs', gitsigns.stage_hunk,
                        { desc = "Stage the current hunk to git add" })
                    vim.keymap.set('n', '<leader>hr', gitsigns.reset_hunk,
                        { desc = "Reset the current hunk from git add" })

                    vim.keymap.set('v', '<leader>hs', function()
                            gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
                        end,
                        { desc = "Stage the current hunk to git add (Visual edition)" })

                    vim.keymap.set('v', '<leader>hr', function()
                        gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
                    end, { desc = "Reset the current hunk from git add (Visual edition)" })

                    vim.keymap.set('n', '<leader>hp', gitsigns.preview_hunk,
                        { desc = "Git diff on the current hunk, see how different it is" })
                end
            }
        end,
    },

    { -- GIT BLAME
        "f-person/git-blame.nvim",
        -- load the plugin at startup
        event = "VeryLazy",
        -- Because of the keys part, you will be lazy loading this plugin.
        -- The plugin wil only load once one of the keys is used.
        -- If you want to load the plugin at startup, add something like event = "VeryLazy",
        -- or lazy = false. One of both options will work.
        opts = {
            -- your configuration comes here
            -- for example
            enabled = true, -- if you want to enable the plugin
            message_template = " <summary> • <date> • <author> • <<sha>>", -- template for the blame message, check the Message template section for more options
            date_format = "%m-%d-%Y", -- template for the date, check Date format section for more options
            virtual_text_column = 0, -- virtual text start column, check Start virtual text at column section for more options
        },
        vim.keymap.set('n', '<leader>yh', "<cmd> GitBlameCopySHA<CR>")
    }
}
