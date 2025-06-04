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
      presets = {
        lsp_doc_border = true,
      },
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
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
      vim.lsp.handlers["textDocument/hover"] = function(_, _, _) end

      vim.g.rustaceanvim = {
        dap = {
          adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path),
        },

        FloatWinConfig = {
          auto_focus = false,
          enable = true 
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
}
