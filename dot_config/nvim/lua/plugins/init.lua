-- VERY VERY bad
-- BIG TODO: I need to organize this better...ik it's bad
-- my morals are just starting to kick in

return {
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
    config = function ()
      local mason_registry = require('mason-registry')
      local codelldb = mason_registry.get_package("codelldb")
      local extension_path = codelldb:get_install_path() .. "/extension/"
      local codelldb_path = extension_path .. "adapter/codelldb"
      local liblldb_path = extension_path.. "lldb/lib/liblldb.dylib"
	-- If you are on Linux, replace the line above with the line below:
	-- local liblldb_path = extension_path .. "lldb/lib/liblldb.so"
      local cfg = require('rustaceanvim.config')
      vim.fn.jobstart('cargo build')
      -- vim.lsp.handlers["textDocument/hover"] = function(_, _, _) end

      vim.g.rustaceanvim = {
        dap = {
          adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path),
        },

        -- Don't work fr
        FloatWinConfig = {
          auto_focus = false,
          enable = false
        }
      }
    end
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
       "html", "css"
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
		-- 	{
		-- -- TELESCOPE
		--
		-- { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
		--
		-- {
		-- 	"nvim-telescope/telescope-frecency.nvim",
		-- 	-- install the latest stable version
		-- 	version = "*",
		-- },
		--
	-- 	{
	-- 		'nvim-telescope/telescope.nvim',
	-- 		tag = '0.1.8',
	-- 		-- or                              , branch = '0.1.x',
	-- 		dependencies = { 'nvim-lua/plenary.nvim',
	-- 			"nvim-telescope/telescope-live-grep-args.nvim",
	-- 		},
	--
	-- 		config = function()
	-- 			require('telescope').load_extension('fzf')
	-- 			require('telescope').load_extension('live_grep_args')
	-- 			require("telescope").load_extension "frecency"
	-- 			local live_grep_args_shortcuts = require("telescope-live-grep-args.shortcuts")
	-- 			local builtin = require('telescope.builtin')
	--
	-- 			require('telescope').setup {
	-- 				defaults = {
	-- 					cache_picker = {
	-- 						num_pickers = 20
	-- 					}
	-- 					-- Default configuration for telescope goes here:
	-- 					-- config_key = value,
	-- 					-- ..
	-- 				}, }
	--
	--
	-- 			vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
	-- 			vim.keymap.set("n", "<leader>fg",
	-- 				":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>")
	-- 			vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
	-- 			vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
	-- 			vim.keymap.set('n', '/', builtin.current_buffer_fuzzy_find, {})
	--
	-- 			vim.keymap.set('n', '<leader>fr', builtin.pickers, {})
	-- 			vim.keymap.set('n', '<leader>fp', builtin.pickers, {})
	--
	-- 			vim.keymap.set("n", "<leader>g", live_grep_args_shortcuts.grep_word_under_cursor, { noremap = true, silent = true })
	-- 			vim.keymap.set("x", "<leader>g", live_grep_args_shortcuts.grep_visual_selection, { noremap = true, silent = true })
	--
	--
	-- 			-- SET UP KEYMAP FOR LSP, POTENTIALLY VIA TELESCOPE
	-- 			vim.keymap.set("n", "<leader>la", ":lua vim.lsp.buf.code_action()<CR>") -- Show code actions
	-- 			vim.keymap.set("n", "<leader>lr", ":lua vim.lsp.buf.rename()<CR>") -- Rename symbols with scope-correctness
	-- 			vim.keymap.set("n", "gd", ":lua vim.lsp.buf.definition()<CR>", { noremap = true, silent = true }) -- Go to definition
	-- 			vim.keymap.set("n", "<leader>ldc", ":lua vim.lsp.buf.declaration()<CR>") -- Go to declaration
	--
	-- 			vim.keymap.set("n", "<leader>m", builtin.lsp_implementations, {}) -- Go to implementation
	-- 			vim.keymap.set("n", "<leader>i", ":lua vim.lsp.buf.incoming_calls()<CR>", {}) -- Show incoming calls to the function under the cursor
	-- 			vim.keymap.set("n", "<leader>o", ":lua vim.lsp.buf.outgoing_calls()<CR>", {}) -- Show outgoing calls from the function under the cursor
	-- 			vim.keymap.set("n", "<leader>td", builtin.lsp_type_definitions)   -- Go to type definition
	-- 			vim.keymap.set("n", "<leader>th", ":lua vim.lsp.buf.typehierachy()<CR>") -- Show type hierarchy
	-- 		end
	-- 	}
	-- },

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
    "ibhagwan/fzf-lua",

    dependencies = { "nvim-tree/nvim-web-devicons" },

    config = function()
      local fzf_lua = require("fzf-lua")

      -- -- list the modes and keys you intend to use
      -- local mappings = {
      --   n = { "<leader>ff", "<leader>fg", "<leader>fb", "<leader>fh", "/", "<leader>fr",
      --         "<leader>fi", "<leader>fo", "<leader>fm", "<leader>fp", "<leader>fd",
      --         "<leader>gw", "<leader>gr", "gd", },
      --   x = { "<leader>g", },
      -- }
      -- -- delete any prior mapping for those keys
      -- for mode, keys in pairs(mappings) do
      --   for _, key in ipairs(keys) do
      --     pcall(vim.keymap.del, mode, key)
      --   end
      -- end

      -- now set only your desired mappings
      vim.keymap.set('n', '<leader>ff', fzf_lua.files, { noremap=true, silent=true, desc="Find files" })
      vim.keymap.set('n', '<leader>fg', fzf_lua.live_grep_native, { noremap=true, silent=true, desc="Find words" })
      vim.keymap.set('n', '<leader>fb', fzf_lua.grep, { noremap=true, silent=true, desc="Find buffers" })
      vim.keymap.set('n', '<leader>fh', fzf_lua.help_tags, { noremap=true, silent=true, desc="Find help tags" })
      vim.keymap.set('n', '/',       fzf_lua.lgrep_curbuf, { noremap=true, silent=true, desc="Find in current buffer" })
      vim.keymap.set('n', '<leader>fr', fzf_lua.resume, { noremap=true, silent=true, desc="Resume last fzf search" })
      vim.keymap.set('n', '<leader>fi', fzf_lua.lsp_incoming_calls, { noremap=true, silent=true, desc="LSP incoming calls" })
      vim.keymap.set('n', '<leader>fo', fzf_lua.lsp_outgoing_calls, { noremap=true, silent=true, desc="LSP outgoing calls" })
      vim.keymap.set('n', '<leader>fm', fzf_lua.man_pages, { noremap=true, silent=true, desc="Find man pages" })
      vim.keymap.set('n', '<leader>fp', fzf_lua.search_history, { noremap=true, silent=true, desc="Search history" })
      vim.keymap.set('n', '<leader>fd', fzf_lua.lsp_finder, { noremap=true, silent=true, desc="LSP diagnostics" })
      vim.keymap.set('n', '<leader>gw', fzf_lua.grep_cword, { noremap=true, silent=true, desc="Grep word under cursor" })
      vim.keymap.set('n', '<leader>gr', fzf_lua.lsp_references, { noremap=true, silent=true, desc="LSP references" })
      vim.keymap.set('x', '<leader>g', fzf_lua.grep_visual, { noremap=true, silent=true, desc="Grep visual selection" })
      vim.keymap.set('n', '<leader>la', fzf_lua.lsp_code_actions, { noremap=true, silent=true, desc="LSP code actions" })
    end
  }
}
