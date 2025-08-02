-- VERY VERY bad
-- BIG TODO: I need to organize this better...ik it's bad
-- my morals are just starting to kick in

return {
  { "alexghergh/nvim-tmux-navigation" },
  { "sitiom/nvim-numbertoggle" },
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!

  {
    'nvim-java/nvim-java'
  },

  {
    'topaxi/pipeline.nvim',
    keys = {
      { '<leader>ci', '<cmd>Pipeline<cr>', desc = 'Open pipeline.nvim' },
    },
    -- optional, you can also install and use `yq` instead.
    build = 'make',
    ---@type pipeline.Config
    opts = {},
  },

  {
    'kristijanhusak/vim-dadbod-ui',
    dependencies = {
      { 'tpope/vim-dadbod', lazy = true },
      { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true }, -- Optional
    },
    cmd = {
      'DBUI',
      'DBUIToggle',
      'DBUIAddConnection',
      'DBUIFindBuffer',
    },
    init = function()
      -- Your DBUI configuration
      vim.g.db_ui_use_nerd_fonts = 1
    end,
  },

  {
    'tpope/vim-dadbod'
  },

  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      routes = {
        {
          filter = { event = "notify", find = "No information available" },
          opts = { skip = true },
        },
      },

    lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          ['cmp.entry.get_documentation'] = true,
        },
      },

      presets = {
        lsp_doc_border = true,
      },
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },

    config = function()
      require("noice.lsp").hover()
    end
  },

  {
    'mrcjkb/rustaceanvim',
    version = '^5', -- Recommended
    lazy = false, -- This plugin is already lazy
    ft = "rust",
	--    config = function ()
	--      local mason_registry = require('mason-registry')
	--      local codelldb = mason_registry.get_package("codelldb")
	--      local extension_path = codelldb:get_install_path() .. "/extension/"
	--      local codelldb_path = extension_path .. "adapter/codelldb"
	--      local liblldb_path = extension_path.. "lldb/lib/liblldb.dylib"
	-- -- If you are on Linux, replace the line above with the line below:
	-- -- local liblldb_path = extension_path .. "lldb/lib/liblldb.so"
	--      local cfg = require('rustaceanvim.config')
	--      vim.fn.jobstart('cargo build')
	--      -- vim.lsp.handlers["textDocument/hover"] = function(_, _, _) end
	--
	--      vim.g.rustaceanvim = {
	--        dap = {
	--          adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path),
	--        },
	--
	--        -- Don't work fr
	--        FloatWinConfig = {
	--          auto_focus = false,
	--          enable = false
	--        }
	--      }
	--    end
  },

  {
    'rust-lang/rust.vim',
    ft = "rust",
    init = function ()
      vim.g.rustfmt_autosave = 1
    end
  },

  {
    'mfussenegger/nvim-dap',
    config = function()
			local dap, dapui = require("dap"), require("dapui")
      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end
		end,
  },

  {
    'rcarriga/nvim-dap-ui',
    dependencies = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"},
    config = function()
			require("dapui").setup()
		end,
  },

  {
    'saecki/crates.nvim',
    ft = {"toml"},
    config = function()
      require("crates").setup {
        completion = {
          cmp = {
            enabled = true
          },
        },
      }
      require('cmp').setup.buffer({
        sources = { { name = "crates" }}
      })
    end
  },

  -- RELATED TO CUSTOM CONFIGURATION 
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
      require "custom.lspconfig"
    end,
  },

  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "clangd",
        "clang-format",
        "rust_analyzer"
      }
    }
  },

  -- TODO: seperate these files
  {
    "neovim/nvim-lspconfig",
    dependencies = {
        {
            "SmiteshP/nvim-navbuddy",
            dependencies = {
                "SmiteshP/nvim-navic",
                "MunifTanjim/nui.nvim"
            },
            opts = { lsp = { auto_attach = true } }
        }
    },
    -- your lsp config or other stuff
  },

  {
    'kevinhwang91/nvim-ufo',
    dependencies = { 'kevinhwang91/promise-async' },
    --    event = 'VeryLazy',   -- You can make it lazy-loaded via VeryLazy, but comment out if thing doesn't work
    init = function()
        vim.o.foldlevel = 99
        vim.o.foldlevelstart = 99
        -- vim.o.foldenable = true
    end,
    config = function()
        require('ufo').setup {
            -- your config goes here
            -- open_fold_hl_timeout = ...,
            provider_selector = function(bufnr, filetype)
              return {'lsp', 'indent'}
            end,
        }
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim", "lua", "vimdoc",
        "html", "css", "cpp",
        "rust", "java", "javascript",
        "python"
      },
      highlight = {
        enable = true,
        -- disable the async scheduled highlighter (avoids invalid-window errors)
        -- the legacy regex-based Vim highlighter will still run as fallback
        additional_vim_regex_highlighting = false,
        -- you can also selectively disable the incremental TS highlighter entirely:
        use_languagetree = false,
      },
    },
  },

    { -- GIT BLAME :: Got this from https://github.com/badumbatish/dotfiles/blob/aa8f32216ea0b8d29da8446a0c597d13a3fa5666/dot_config/nvim/lua/plugins/gits.lua#L71
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
          date_format = "%m-%d-%Y %H:%M:%S", -- template for the date, check Date format section for more options
          virtual_text_column = 1, -- virtual text start column, check Start virtual text at column section for more options
      },

      vim.keymap.set('n', '<leader>yh', "<cmd>GitBlameCopySHA<CR>")

  },

  {
	"badumbatish/brt.nvim",
	-- dir = "~/Developer/nvim_proj/brt.nvim",
	-- dev = { true },
	-- @t
	config = function()
		local project_map = {
			["sammine-lang/"] = {
				build_command =
				"cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=1  && cmake --build build -j",
				run_command = "./build/src/sammine -f unit-tests/artifacts/valid_grammar.txt --llvm-ir --diagnostics",
				test_command = "ctest --test-dir build --output-on-failure",
				name = "sammine-lang"
			},
    }
		local brt = require("brt")
		brt.set_project_map(project_map)

		require("brt").setup()
	end
  },

  {
    'nvim-telescope/telescope.nvim',
    enabled = false,
  },

  {
    'Bekaboo/dropbar.nvim',
    -- optional, but required for fuzzy finder support
    config = function()
    end
  },

  {
    'nvim-pack/nvim-spectre',
    dependencies = {'nvim-lua/plenary.nvim'},
    config = function()
    end
  },

  {
    "ibhagwan/fzf-lua",
    lazy = false,

    dependencies = { "nvim-tree/nvim-web-devicons",
    "nvim-treesitter/nvim-treesitter-context"},


    config = function()
      local context_config = {
          enable = true,            -- Enable this plugin (Can be enabled/disabled later via commands)
          multiwindow = false,      -- Enable multiwindow support.
          max_lines = 0,            -- How many lines the window should span. Values <= 0 mean no limit.
          min_window_height = 0,    -- Minimum editor window height to enable context. Values <= 0 mean no limit.
          line_numbers = true,
          multiline_threshold = 20, -- Maximum number of lines to show for a single context
          trim_scope = 'outer',     -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
          mode = 'cursor',          -- Line used to calculate context. Choices: 'cursor', 'topline'
          -- Separator between context and content. Should be a single character string, like '-'.
          -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
          separator = nil,
          zindex = 20,     -- The Z-index of the context window
          on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
        }
        local actions = require("fzf-lua").actions
        require('fzf-lua').setup({
          'telescope',
          "hide",
          winopts = {
            -- split = "belowright new",-- open in a split instead?
            -- "belowright new"  : split below
            -- "aboveleft new"   : split above
            -- "belowright vnew" : split right
            -- "aboveleft vnew   : split left
            -- Only valid when using a float window
            -- (i.e. when 'split' is not defined, default)
            height     = 1, -- window height
            width      = 1, -- window width
            row        = 1, -- window row position (0=top, 1=bottom)
            col        = 0, -- window col position (0=left, 1=right)
            -- border argument passthrough to nvim_open_win()
            border     = "rounded",
            -- Backdrop opacity, 0 is fully opaque, 100 is fully transparent (i.e. disabled)
            backdrop   = 60,
            -- title         = "Title",
            -- title_pos     = "center",        -- 'left', 'center' or 'right'
            -- title_flags   = false,           -- uncomment to disable title flags
            fullscreen = true, -- start fullscreen?
            -- enable treesitter highlighting for the main fzf window will only have
            -- effect where grep like results are present, i.e. "file:line:col:text"
            -- due to highlight color collisions will also override `fzf_colors`
            -- set `fzf_colors=false` or `fzf_colors.hl=...` to override
            treesitter = {
              enabled    = true,
              fzf_colors = { ["hl"] = "-1:reverse", ["hl+"] = "-1:reverse" }
            },
            preview    = {

              -- default     = 'bat',           -- override the default previewer?
              -- default uses the 'builtin' previewer
              border       = "rounded", -- preview border: accepts both `nvim_open_win`
              -- and fzf values (e.g. "border-top", "none")
              -- native fzf previewers (bat/cat/git/etc)
              -- can also be set to `fun(winopts, metadata)`
              wrap         = true,        -- preview line wrap (fzf's 'wrap|nowrap')
              hidden       = false,       -- start preview hidden
              vertical     = "down:45%",  -- up|down:size
              horizontal   = "right:60%", -- right|left:size
              layout       = "flex",      -- horizontal|vertical|flex
              flip_columns = 100,         -- #cols to switch to horizontal on flex
              -- Only used with the builtin previewer:
              title        = true,        -- preview border title (file/buf)?
              title_pos    = "center",    -- left|center|right, title alignment
              scrollbar    = "float",     -- `false` or string:'float|border'
              -- float:  in-window floating border
              -- border: in-border "block" marker
              scrolloff    = -1, -- float scrollbar offset from right
              -- applies only when scrollbar = 'float'
              delay        = 20, -- delay(ms) displaying the preview
              -- prevents lag on fast scrolling
              winopts      = {   -- builtin previewer window options
                number         = true,
                relativenumber = false,
                cursorline     = true,
                cursorlineopt  = "both",
                cursorcolumn   = false,
                signcolumn     = "no",
                list           = false,
                foldenable     = false,
                foldmethod     = "manual",
              },
            },
            on_create  = function()
              -- called once upon creation of the fzf main window
              -- can be used to add custom fzf-lua mappings, e.g:
              --   vim.keymap.set("t", "<C-j>", "<Down>", { silent = true, buffer = true })
            end,
            -- called once _after_ the fzf interface is closed
            -- on_close = function() ... end
          },
          oldfiles = {
            prompt                  = 'History❯ ',
            cwd_only                = true,
            stat_file               = true, -- verify files exist on disk
            -- can also be a lua function, for example:
            -- stat_file = require("fzf-lua").utils.file_is_readable,
            -- stat_file = function() return true end,
            include_current_session = true, -- include bufs from current session
          },
          --
          previewers = {
            builtin = {
              syntax          = true,             -- preview syntax highlight?
              syntax_limit_l  = 0,                -- syntax limit (lines), 0=nolimit
              syntax_limit_b  = 1024 * 1024,      -- syntax limit (bytes), 0=nolimit
              limit_b         = 1024 * 1024 * 10, -- preview limit (bytes), 0=nolimit
              -- previewer treesitter options:
              -- enable specific filetypes with: `{ enabled = { "lua" } }
              -- exclude specific filetypes with: `{ disabled = { "lua" } }
              -- disable `nvim-treesitter-context` with `context = false`
              -- disable fully with: `treesitter = false` or `{ enabled = false }`
              treesitter      = {
                enabled = true,
                disabled = {},
                -- nvim-treesitter-context config options
                context = context_config
              },
              -- By default, the main window dimensions are calculated as if the
              -- preview is visible, when hidden the main window will extend to
              -- full size. Set the below to "extend" to prevent the main window
              -- from being modified when toggling the preview.
              toggle_behavior = "default",
              -- Title transform function, by default only displays the tail
              -- title_fnamemodify = function(s) return vim.fn.fnamemodify(s, ":t") end,
              -- preview extensions using a custom shell command:
              -- for example, use `viu` for image previews
              -- will do nothing if `viu` isn't executable
              extensions      = {
                -- neovim terminal only supports `viu` block output
                ["png"] = { "viu", "-b" },
                -- by default the filename is added as last argument
                -- if required, use `{file}` for argument positioning
                ["svg"] = { "chafa", "{file}" },
                ["jpg"] = { "ueberzug" },
              },
              -- if using `ueberzug` in the above extensions map
              -- set the default image scaler, possible scalers:
              --   false (none), "crop", "distort", "fit_contain",
              --   "contain", "forced_cover", "cover"
              -- https://github.com/seebye/ueberzug
              ueberzug_scaler = "cover",
              -- render_markdown.nvim integration, enabled by default for markdown
              render_markdown = { enabled = true, filetypes = { ["markdown"] = true } },
              -- snacks.images integration, enabled by default
              snacks_image    = { enabled = true, render_inline = true },
            },
            -- Code Action previewers, default is "codeaction" (set via `lsp.code_actions.previewer`)
            -- "codeaction_native" uses fzf's native previewer, recommended when combined with git-delta
            codeaction = {
              -- options for vim.diff(): https://neovim.io/doc/user/lua.html#vim.diff()
              diff_opts = { ctxlen = 3 },
            },
            codeaction_native = {
              diff_opts = { ctxlen = 3 },
              -- git-delta is automatically detected as pager, set `pager=false`
              -- to disable, can also be set under 'lsp.code_actions.preview_pager'
              -- recommended styling for delta
              --pager = [[delta --width=$COLUMNS --hunk-header-style="omit" --file-style="omit"]],
            },
          },
          -- use `defaults` (table or function) if you wish to set "global-picker" defaults
          -- for example, using "mini.icons" globally and open the quickfix list at the top
          --   defaults = {
          --     file_icons   = "mini",
          --     copen        = "topleft copen",
          --   },
          files = {
            -- previewer      = "bat",          -- uncomment to override previewer
            -- (name from 'previewers' table)
            -- set to 'false' to disable
            prompt                 = 'Files❯ ',
            multiprocess           = true,  -- run command in a separate process
            git_icons              = false, -- show git icons?
            file_icons             = true,  -- show file icons (true|"devicons"|"mini")?
            color_icons            = true,  -- colorize file|git icons
            -- path_shorten   = 1,              -- 'true' or number, shorten path?
            -- Uncomment for custom vscode-like formatter where the filename is first:
            -- e.g. "fzf-lua/previewer/fzf.lua" => "fzf.lua previewer/fzf-lua"
            -- formatter      = "path.filename_first",
            -- executed command priority is 'cmd' (if exists)
            -- otherwise auto-detect prioritizes `fd`:`rg`:`find`
            -- default options are controlled by 'fd|rg|find|_opts'
            -- cmd            = "rg --files",
            find_opts              = [[-type f \! -path '*/.git/*']],
            rg_opts                = [[--color=never --hidden --files -g "!.git"]],
            fd_opts                = [[--color=never --hidden --type f --type l --exclude .git]],
            dir_opts               = [[/s/b/a:-d]],
            -- by default, cwd appears in the header only if {opts} contain a cwd
            -- parameter to a different folder than the current working directory
            -- uncomment if you wish to force display of the cwd as part of the
            -- query prompt string (fzf.vim style), header line or both
            -- cwd_header = true,
            cwd_prompt             = true,
            cwd_prompt_shorten_len = 32,            -- shorten prompt beyond this length
            cwd_prompt_shorten_val = 1,             -- shortened path parts length
            toggle_ignore_flag     = "--no-ignore", -- flag toggled in `actions.toggle_ignore`
            toggle_hidden_flag     = "--hidden",    -- flag toggled in `actions.toggle_hidden`
            toggle_follow_flag     = "-L",          -- flag toggled in `actions.toggle_follow`
            hidden                 = true,          -- enable hidden files by default
            follow                 = false,         -- do not follow symlinks by default
            no_ignore              = false,         -- respect ".gitignore"  by default
            actions                = {
              -- inherits from 'actions.files', here we can override
              -- or set bind to 'false' to disable a default action
              -- uncomment to override `actions.file_edit_or_qf`
              --   ["enter"]     = actions.file_edit,
              -- custom actions are available too
              --   ["ctrl-y"]    = function(selected) print(selected[1]) end,
            }
          },
          git = {
            files = {
              prompt       = 'GitFiles❯ ',
              cmd          = 'git ls-files --exclude-standard',
              multiprocess = true, -- run command in a separate process
              git_icons    = true, -- show git icons?
              file_icons   = true, -- show file icons (true|"devicons"|"mini")?
              color_icons  = true, -- colorize file|git icons
              -- force display the cwd header line regardless of your current working
              -- directory can also be used to hide the header when not wanted
              -- cwd_header = true
            },
            status = {
              prompt       = 'GitStatus❯ ',
              cmd          = "git -c color.status=false --no-optional-locks status --porcelain=v1 -u",
              multiprocess = true, -- run command in a separate process
              file_icons   = true,
              color_icons  = true,
              previewer    = "git_diff",
              -- git-delta is automatically detected as pager, uncomment to disable
              -- preview_pager = false,
              actions      = {
                -- actions inherit from 'actions.files' and merge
                ["right"]  = { fn = actions.git_unstage, reload = true },
                ["left"]   = { fn = actions.git_stage, reload = true },
                ["ctrl-x"] = { fn = actions.git_reset, reload = true },
              },
              -- If you wish to use a single stage|unstage toggle instead
              -- using 'ctrl-s' modify the 'actions' table as shown below
              -- actions = {
              --   ["right"]   = false,
              --   ["left"]    = false,
              --   ["ctrl-x"]  = { fn = actions.git_reset, reload = true },
              --   ["ctrl-s"]  = { fn = actions.git_stage_unstage, reload = true },
              -- },
            },
            diff = {
              cmd         = "git --no-pager diff --name-only {ref}",
              ref         = "HEAD",
              preview     = "git diff {ref} {file}",
              -- git-delta is automatically detected as pager, uncomment to disable
              -- preview_pager = false,
              file_icons  = true,
              color_icons = true,
              fzf_opts    = { ["--multi"] = true },
            },
            hunks = {
              cmd         = "git --no-pager diff --color=always {ref}",
              ref         = "HEAD",
              file_icons  = true,
              color_icons = true,
              fzf_opts    = {
                ["--multi"] = true,
                ["--delimiter"] = ":",
                ["--nth"] = "3..",
              },
            },
            commits = {
              prompt  = 'Commits❯ ',
              cmd     = [[git log --color --pretty=format:"%C(yellow)%h%Creset ]]
                  .. [[%Cgreen(%><(12)%cr%><|(12))%Creset %s %C(blue)<%an>%Creset"]],
              preview = "git show --color {1}",
              -- git-delta is automatically detected as pager, uncomment to disable
              -- preview_pager = false,
              actions = {
                ["enter"]  = actions.git_checkout,
                -- remove `exec_silent` or set to `false` to exit after yank
                ["ctrl-y"] = { fn = actions.git_yank_commit, exec_silent = true },
              },
            },
            bcommits = {
              prompt  = 'BCommits❯ ',
              -- default preview shows a git diff vs the previous commit
              -- if you prefer to see the entire commit you can use:
              --   git show --color {1} --rotate-to={file}
              --   {1}    : commit SHA (fzf field index expression)
              --   {file} : filepath placement within the commands
              cmd     = [[git log --color --pretty=format:"%C(yellow)%h%Creset ]]
                  .. [[%Cgreen(%><(12)%cr%><|(12))%Creset %s %C(blue)<%an>%Creset" {file}]],
              preview = "git show --color {1} -- {file}",
              -- git-delta is automatically detected as pager, uncomment to disable
              -- preview_pager = false,
              actions = {
                ["enter"]  = actions.git_buf_edit,
                ["ctrl-s"] = actions.git_buf_split,
                ["ctrl-v"] = actions.git_buf_vsplit,
                ["ctrl-t"] = actions.git_buf_tabedit,
                ["ctrl-y"] = { fn = actions.git_yank_commit, exec_silent = true },
              },
            },
            blame = {
              prompt  = "Blame> ",
              cmd     = [[git blame --color-lines {file}]],
              preview = "git show --color {1} -- {file}",
              -- git-delta is automatically detected as pager, uncomment to disable
              -- preview_pager = false,
              actions = {
                ["enter"]  = actions.git_goto_line,
                ["ctrl-s"] = actions.git_buf_split,
                ["ctrl-v"] = actions.git_buf_vsplit,
                ["ctrl-t"] = actions.git_buf_tabedit,
                ["ctrl-y"] = { fn = actions.git_yank_commit, exec_silent = true },
              },
            },
            branches = {
              prompt  = 'Branches❯ ',
              cmd     = "git branch --all --color",
              preview = "git log --graph --pretty=oneline --abbrev-commit --color {1}",
              remotes = "local", -- "detach|local", switch behavior for remotes
              actions = {
                ["enter"]  = actions.git_switch,
                ["ctrl-x"] = { fn = actions.git_branch_del, reload = true },
                ["ctrl-a"] = { fn = actions.git_branch_add, field_index = "{q}", reload = true },
              },
              -- If you wish to add branch and switch immediately
              -- cmd_add  = { "git", "checkout", "-b" },
              cmd_add = { "git", "branch" },
              -- If you wish to delete unmerged branches add "--force"
              -- cmd_del  = { "git", "branch", "--delete", "--force" },
              cmd_del = { "git", "branch", "--delete" },
            },
            tags = {
              prompt  = "Tags> ",
              cmd     = [[git for-each-ref --color --sort="-taggerdate" --format ]]
                  .. [["%(color:yellow)%(refname:short)%(color:reset) ]]
                  .. [[%(color:green)(%(taggerdate:relative))%(color:reset)]]
                  .. [[ %(subject) %(color:blue)%(taggername)%(color:reset)" refs/tags]],
              preview = [[git log --graph --color --pretty=format:"%C(yellow)%h%Creset ]]
                  .. [[%Cgreen(%><(12)%cr%><|(12))%Creset %s %C(blue)<%an>%Creset" {1}]],
              actions = { ["enter"] = actions.git_checkout },
            },
            stash = {
              prompt  = 'Stash> ',
              cmd     = "git --no-pager stash list",
              preview = "git --no-pager stash show --patch --color {1}",
              actions = {
                ["enter"]  = actions.git_stash_apply,
                ["ctrl-x"] = { fn = actions.git_stash_drop, reload = true },
              },
            },
            icons = {
              ["M"] = { icon = "M", color = "yellow" },
              ["D"] = { icon = "D", color = "red" },
              ["A"] = { icon = "A", color = "green" },
              ["R"] = { icon = "R", color = "yellow" },
              ["C"] = { icon = "C", color = "yellow" },
              ["T"] = { icon = "T", color = "magenta" },
              ["?"] = { icon = "?", color = "magenta" },
              -- override git icons?
              -- ["M"]        = { icon = "★", color = "red" },
              -- ["D"]        = { icon = "✗", color = "red" },
              -- ["A"]        = { icon = "+", color = "green" },
            },
          },
          grep = {
            prompt         = 'Rg❯ ',
            input_prompt   = 'Grep For❯ ',
            multiprocess   = true, -- run command in a separate process
            git_icons      = true, -- show git icons?
            file_icons     = true, -- show file icons (true|"devicons"|"mini")?
            color_icons    = true, -- colorize file|git icons
            -- executed command priority is 'cmd' (if exists)
            -- otherwise auto-detect prioritizes `rg` over `grep`
            -- default options are controlled by 'rg|grep_opts'
            -- cmd            = "rg --vimgrep",
            grep_opts      = "--binary-files=without-match --line-number --recursive --color=auto --perl-regexp -e",
            rg_opts        = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e",
            hidden         = false, -- disable hidden files by default
            follow         = false, -- do not follow symlinks by default
            no_ignore      = false, -- respect ".gitignore"  by default
            -- Uncomment to use the rg config file `$RIPGREP_CONFIG_PATH`
            -- RIPGREP_CONFIG_PATH = vim.env.RIPGREP_CONFIG_PATH
            --
            -- Set to 'true' to always parse globs in both 'grep' and 'live_grep'
            -- search strings will be split using the 'glob_separator' and translated
            -- to '--iglob=' arguments, requires 'rg'
            -- can still be used when 'false' by calling 'live_grep_glob' directly
            rg_glob        = true,      -- default to glob parsing with `rg`
            glob_flag      = "--iglob", -- for case sensitive globs use '--glob'
            glob_separator = "%s%-%-",  -- query separator pattern (lua): ' --'
            -- advanced usage: for custom argument parsing define
            -- 'rg_glob_fn' to return a pair:
            --   first returned argument is the new search query
            --   second returned argument are additional rg flags
            -- rg_glob_fn = function(query, opts)
            --   ...
            --   return new_query, flags
            -- end,
            --
            -- Enable with narrow term width, split results to multiple lines
            -- NOTE: multiline requires fzf >= v0.53 and is ignored otherwise
            -- multiline      = 1,      -- Display as: PATH:LINE:COL\nTEXT
            -- multiline      = 2,      -- Display as: PATH:LINE:COL\nTEXT\n
            actions        = {
              -- actions inherit from 'actions.files' and merge
              -- this action toggles between 'grep' and 'live_grep'
              ["ctrl-g"] = { actions.grep_lgrep },
              -- uncomment to enable '.gitignore' toggle for grep
              ["ctrl-r"] = { actions.toggle_ignore }
            },
            no_header      = true, -- hide grep|cwd header?
            no_header_i    = true, -- hide interactive header?
          },
          args = {
            prompt     = 'Args❯ ',
            files_only = true,
            -- actions inherit from 'actions.files' and merge
            actions    = { ["ctrl-x"] = { fn = actions.arg_del, reload = true } },
          },
          buffers = {
            prompt        = 'Buffers❯ ',
            file_icons    = true,  -- show file icons (true|"devicons"|"mini")?
            color_icons   = true,  -- colorize file|git icons
            sort_lastused = true,  -- sort buffers() by last used
            show_unloaded = true,  -- show unloaded buffers
            cwd_only      = false, -- buffers for the cwd only
            cwd           = nil,   -- buffers list for a given dir
            actions       = {
              -- actions inherit from 'actions.files' and merge
              -- by supplying a table of functions we're telling
              -- fzf-lua to not close the fzf window, this way we
              -- can resume the buffers picker on the same window
              -- eliminating an otherwise unaesthetic win "flash"
              ["ctrl-x"] = { fn = actions.buf_del, reload = true },
            }
          },
          tabs = {
            prompt      = 'Tabs❯ ',
            tab_title   = "Tab",
            tab_marker  = "<<",
            locate      = true, -- position cursor at current window
            file_icons  = true, -- show file icons (true|"devicons"|"mini")?
            color_icons = true, -- colorize file|git icons
            actions     = {
              -- actions inherit from 'actions.files' and merge
              ["enter"]  = actions.buf_switch,
              ["ctrl-x"] = { fn = actions.buf_del, reload = true },
            },
            fzf_opts    = {
              -- hide tabnr
              ["--delimiter"] = "[\\):]",
              ["--with-nth"]  = '2..',
            },
          },
          -- `blines` has the same defaults as `lines` aside from prompt and `show_bufname`
          blines = {
            prompt  = 'CurrentBuffer❯ ',
          },
          lines = {
            prompt          = 'Lines❯ ',
            file_icons      = false,
            show_bufname    = false,  -- display buffer name
            show_unloaded   = false,  -- show unloaded buffers
            show_unlisted   = false,  -- exclude 'help' buffers
            no_term_buffers = true,   -- exclude 'term' buffers
            sort_lastused   = true,   -- sort by most recent
            winopts         = { treesitter = true }, -- enable TS highlights
            fzf_opts        = {
              -- do not include bufnr in fuzzy matching
              -- tiebreak by line no.
              ["--multi"]     = true,
              ["--delimiter"] = "[\t]",
              ["--tabstop"]   = "1",
              ["--tiebreak"]  = "index",
              ["--with-nth"]  = "2..",
              ["--nth"]       = "4..",
            },

          },
          tags = {
            prompt       = 'Tags❯ ',
            ctags_file   = nil, -- auto-detect from tags-option
            multiprocess = true,
            file_icons   = true,
            color_icons  = true,
            -- 'tags_live_grep' options, `rg` prioritizes over `grep`
            rg_opts      = "--no-heading --color=always --smart-case",
            grep_opts    = "--color=auto --perl-regexp",
            fzf_opts     = { ["--tiebreak"] = "begin" },
            actions      = {
              -- actions inherit from 'actions.files' and merge
              -- this action toggles between 'grep' and 'live_grep'
              ["ctrl-g"] = { actions.grep_lgrep }
            },
            no_header    = false, -- hide grep|cwd header?
            no_header_i  = false, -- hide interactive header?
          },
          btags = {
            prompt        = 'BTags❯ ',
            ctags_file    = nil,  -- auto-detect from tags-option
            ctags_autogen = true, -- dynamically generate ctags each call
            multiprocess  = true,
            file_icons    = false,
            rg_opts       = "--color=never --no-heading",
            grep_opts     = "--color=never --perl-regexp",
            fzf_opts      = { ["--tiebreak"] = "begin" },
            -- actions inherit from 'actions.files'
          },
          colorschemes = {
            prompt       = 'Colorschemes❯ ',
            live_preview = true, -- apply the colorscheme on preview?
            actions      = { ["enter"] = actions.colorscheme },
            winopts      = { height = 0.55, width = 0.30, },
            -- uncomment to ignore colorschemes names (lua patterns)
            -- ignore_patterns   = { "^delek$", "^blue$" },
          },
          awesome_colorschemes = {
            prompt       = 'Colorschemes❯ ',
            live_preview = true, -- apply the colorscheme on preview?
            max_threads  = 5,    -- max download/update threads
            winopts      = { row = 0, col = 0.99, width = 0.50 },
            fzf_opts     = {
              ["--multi"]     = true,
              ["--delimiter"] = "[:]",
              ["--with-nth"]  = "3..",
              ["--tiebreak"]  = "index",
            },
            actions      = {
              ["enter"]  = actions.colorscheme,
              ["ctrl-g"] = { fn = actions.toggle_bg, exec_silent = true },
              ["ctrl-r"] = { fn = actions.cs_update, reload = true },
              ["ctrl-x"] = { fn = actions.cs_delete, reload = true },
            },
          },
          keymaps = {
            prompt          = "Keymaps> ",
            winopts         = { preview = { layout = "vertical" } },
            fzf_opts        = { ["--tiebreak"] = "index", },
            -- by default, we ignore <Plug> and <SNR> mappings
            -- set `ignore_patterns = false` to disable filtering
            ignore_patterns = { "^<SNR>", "^<Plug>" },
            show_desc       = true,
            show_details    = true,
            actions         = {
              ["enter"]  = actions.keymap_apply,
              ["ctrl-s"] = actions.keymap_split,
              ["ctrl-v"] = actions.keymap_vsplit,
              ["ctrl-t"] = actions.keymap_tabedit,
            },
          },
          nvim_options = {
            prompt       = "Nvim Options> ",
            separator    = "│", -- separator between option name and value
            color_values = true, -- colorize boolean values
            actions      = {
              ["enter"]     = { fn = actions.nvim_opt_edit_local, reload = true },
              ["alt-enter"] = { fn = actions.nvim_opt_edit_global, reload = true },
            },
          },
          quickfix = {
            file_icons = true,
            only_valid = false, -- select among only the valid quickfix entries
          },
          quickfix_stack = {
            prompt = "Quickfix Stack> ",
            marker = ">", -- current list marker
          },
          lsp = {
            prompt_postfix     = '❯ ', -- will be appended to the LSP label
            -- to override use 'prompt' instead
            cwd_only           = false, -- LSP/diagnostics for cwd only?
            async_or_timeout   = 5000, -- timeout(ms) or 'true' for async calls
            file_icons         = true,
            git_icons          = false,
            jump1              = true, -- skip the UI when result is a single entry
            jump1_action       = FzfLua.actions.file_edit,
            -- The equivalent of using `includeDeclaration` in lsp buf calls, e.g:
            -- :lua vim.lsp.buf.references({includeDeclaration = false})
            includeDeclaration = true, -- include current declaration in LSP context
            -- settings for 'lsp_{document|workspace|lsp_ive_workspace}_symbols'
            symbols            = {
              -- lsp_query      = "foo"       -- query passed to the LSP directly
              -- query          = "bar"       -- query passed to fzf prompt for fuzzy matching
              async_or_timeout = true, -- symbols are async by default
              symbol_style     = 1,    -- style for document/workspace symbols
              -- false: disable,    1: icon+kind
              --     2: icon only,  3: kind only
              -- NOTE: icons are extracted from
              -- vim.lsp.protocol.CompletionItemKind
              -- icons for symbol kind
              -- see https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#symbolKind
              -- see https://github.com/neovim/neovim/blob/829d92eca3d72a701adc6e6aa17ccd9fe2082479/runtime/lua/vim/lsp/protocol.lua#L117
              symbol_icons     = {
                File          = "󰈙",
                Module        = "",
                Namespace     = "󰦮",
                Package       = "",
                Class         = "󰆧",
                Method        = "󰊕",
                Property      = "",
                Field         = "",
                Constructor   = "",
                Enum          = "",
                Interface     = "",
                Function      = "󰊕",
                Variable      = "󰀫",
                Constant      = "󰏿",
                String        = "",
                Number        = "󰎠",
                Boolean       = "󰨙",
                Array         = "󱡠",
                Object        = "",
                Key           = "󰌋",
                Null          = "󰟢",
                EnumMember    = "",
                Struct        = "󰆼",
                Event         = "",
                Operator      = "󰆕",
                TypeParameter = "󰗴",
              },
              -- colorize using Treesitter '@' highlight groups ("@function", etc).
              -- or 'false' to disable highlighting
              symbol_hl        = function(s) return "@" .. s:lower() end,
              -- additional symbol formatting, works with or without style
              symbol_fmt       = function(s, opts) return "[" .. s .. "]" end,
              -- prefix child symbols. set to any string or `false` to disable
              child_prefix     = true,
              fzf_opts         = { ["--tiebreak"] = "begin" },
            },
            code_actions       = {
              prompt           = 'Code Actions> ',
              async_or_timeout = 5000,
              -- when git-delta is installed use "codeaction_native" for beautiful diffs
              -- try it out with `:FzfLua lsp_code_actions previewer=codeaction_native`
              -- scroll up to `previewers.codeaction{_native}` for more previewer options
              previewer        = "codeaction",
            },
            finder             = {
              prompt             = "LSP Finder> ",
              file_icons         = true,
              color_icons        = true,
              async              = true, -- async by default
              silent             = true, -- suppress "not found"
              separator          = "| ", -- separator after provider prefix, `false` to disable
              includeDeclaration = true, -- include current declaration in LSP context
              -- by default display all LSP locations
              -- to customize, duplicate table and delete unwanted providers
              providers          = {
                { "references",      prefix = require("fzf-lua").utils.ansi_codes.blue("ref ") },
                { "definitions",     prefix = require("fzf-lua").utils.ansi_codes.green("def ") },
                { "declarations",    prefix = require("fzf-lua").utils.ansi_codes.magenta("decl") },
                { "typedefs",        prefix = require("fzf-lua").utils.ansi_codes.red("tdef") },
                { "implementations", prefix = require("fzf-lua").utils.ansi_codes.green("impl") },
                { "incoming_calls",  prefix = require("fzf-lua").utils.ansi_codes.cyan("in  ") },
                { "outgoing_calls",  prefix = require("fzf-lua").utils.ansi_codes.yellow("out ") },
              },
            }
          },
          diagnostics = {
            prompt         = 'Diagnostics❯ ',
            cwd_only       = false,
            file_icons     = false,
            git_icons      = false,
            color_headings = true, -- use diag highlights to color source & filepath
            diag_icons     = true, -- display icons from diag sign definitions
            diag_source    = true, -- display diag source (e.g. [pycodestyle])
            diag_code      = true, -- display diag code (e.g. [undefined])
            icon_padding   = '',   -- add padding for wide diagnostics signs
            multiline      = 2,    -- split heading and diag to separate lines
            -- severity_only:   keep any matching exact severity
            -- severity_limit:  keep any equal or more severe (lower)
            -- severity_bound:  keep any equal or less severe (higher)
          },
          marks = {
            marks = "", -- filter vim marks with a lua pattern
            -- for example if you want to only show user defined marks
            -- you would set this option as %a this would match characters from [A-Za-z]
            -- or if you want to show only numbers you would set the pattern to %d (0-9).
          },
          complete_path = {
            cmd          = nil, -- default: auto detect fd|rg|find
            complete     = { ["enter"] = actions.complete },
            word_pattern = nil, -- default: "[^%s\"']*"
          },
          complete_file = {
            cmd          = nil, -- default: auto detect rg|fd|find
            file_icons   = true,
            color_icons  = true,
            word_pattern = nil,
            -- actions inherit from 'actions.files' and merge
            actions      = { ["enter"] = actions.complete },
            -- previewer hidden by default
            winopts      = { preview = { hidden = true } },
          },
          zoxide = {
            cmd       = "zoxide query --list --score",
            git_root  = false, -- auto-detect git root
            formatter = "path.dirname_first",
            fzf_opts  = {
              ["--no-multi"]  = true,
              ["--delimiter"] = "[\t]",
              ["--tabstop"]   = "4",
              ["--tiebreak"]  = "end,index", -- prefer dirs ending with search term
              ["--nth"]       = "2..",       -- exclude score from fuzzy matching
            },
            actions   = { enter = actions.cd }
          },
          -- uncomment to use fzf native previewers
          -- (instead of using a neovim floating window)
          -- manpages = { previewer = "man_native" },
          -- helptags = { previewer = "help_native" },
        })


        local fzf_lua = require("fzf-lua")

        -- these will completely shadow any Telescope mappings:
        -- vim.keymap.del("n", "<leader>ff")
        vim.keymap.set('n', '<leader>ff', fzf_lua.files,               { noremap=true, silent=true, desc=" FzfLua: find files"         })
        vim.keymap.set('n', '<leader>fg', fzf_lua.live_grep_native,   { noremap=true, silent=true, desc=" FzfLua: live grep"          })
        vim.keymap.set('n', '<leader>fb', fzf_lua.buffers,            { noremap=true, silent=true, desc="🗂 FzfLua: list buffers"      })
        vim.keymap.set('n', '<leader>fh', fzf_lua.help_tags,          { noremap=true, silent=true, desc=" FzfLua: help tags"         })
        vim.keymap.set('n', '<leader>fr', fzf_lua.resume,             { noremap=true, silent=true, desc=" FzfLua: resume last search" })
        vim.keymap.set('n', '<leader>fp', fzf_lua.search_history,     { noremap=true, silent=true, desc=" FzfLua: search history"     })

        vim.keymap.set("n", '<leader>fs',fzf_lua.treesitter, { desc =  "Symbols in current buffer" })
        -- grep under cursor / visual:
        vim.keymap.set('n', '<leader>gw', fzf_lua.grep_cword,         { noremap=true, silent=true, desc=" FzfLua: grep under cursor" })
        vim.keymap.set('x', '<leader>g', fzf_lua.grep_visual,         { noremap=true, silent=true, desc=" FzfLua: grep selection"    })

        -- LSP-related picks:
        vim.keymap.set('n', '<leader>fi', fzf_lua.lsp_incoming_calls, { noremap=true, silent=true, desc="󰙾 FzfLua: LSP incoming calls" })
        vim.keymap.set('n', '<leader>fo', fzf_lua.lsp_outgoing_calls, { noremap=true, silent=true, desc="󰙿 FzfLua: LSP outgoing calls" })
        vim.keymap.set('n', '<leader>fa', fzf_lua.lsp_code_actions,   { noremap=true, silent=true, desc="󰠴 FzfLua: LSP code actions"   })
        vim.keymap.set('n', '<leader>fd', fzf_lua.lsp_finder,         { noremap=true, silent=true, desc="󰍩 FzfLua: LSP finder"         })
        vim.keymap.set('n', '<leader>fr', fzf_lua.man_pages,          { noremap=true, silent=true, desc=" FzfLua: man pages"           })


        -- vim.api.nvim_create_user_command("FR", function(opts)
        --   vim.api.nvim_command(string.format("cdo s/%s/%s", opts.fargs[1], opts.fargs[2]))
        --   vim.api.nvim_command("cfdo update")
        -- end, { nargs = "*" })
        --
        --
        -- vim.api.nvim_set_keymap(
        --   "n",
        --   "<leader>r",
        --   ":FR",
        --   { noremap = true })
        --
        --
        --



    end
  },

  {
  "folke/flash.nvim",
  event = "VeryLazy",
  ---@type Flash.Config
  opts = {},
  -- stylua: ignore
  keys = {
    { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
    { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
  },
}
}
