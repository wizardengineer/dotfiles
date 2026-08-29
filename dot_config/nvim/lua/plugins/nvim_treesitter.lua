-- nvim-treesitter `main` branch (requires Nvim 0.11+).
--
-- `master` is frozen upstream and the whole `require('nvim-treesitter.configs').setup{}`
-- module is gone on `main` -- that call was the "module 'nvim-treesitter.configs'
-- not found" error on every startup. On `main` the plugin only installs parsers;
-- highlighting/indent/folding are core Nvim (`vim.treesitter.*`).

local ENSURE_INSTALLED = {
  "bash", "c", "cmake", "cpp", "diff", "git_config", "git_rebase", "gitcommit",
  "go", "json", "lua", "luadoc", "make", "markdown", "markdown_inline", "python",
  "query", "regex", "rust", "toml", "vim", "vimdoc", "yaml",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({})

      -- `auto_install` no longer exists on `main`; install the pinned set once,
      -- then lazily fetch anything else a buffer turns out to need.
      local missing = vim.tbl_filter(function(lang)
        return not vim.tbl_contains(require("nvim-treesitter.config").get_installed("parsers"), lang)
      end, ENSURE_INSTALLED)
      if #missing > 0 then
        require("nvim-treesitter").install(missing)
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
        desc = "Start treesitter highlighting, installing the parser on demand",
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
          if not lang then
            return
          end

          if pcall(vim.treesitter.start, args.buf, lang) then
            -- Core indentexpr; only set where the language actually has one.
            if vim.treesitter.query.get(lang, "indents") then
              vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end
            return
          end

          if vim.tbl_contains(require("nvim-treesitter.config").get_available(), lang) then
            require("nvim-treesitter").install(lang):await(function()
              if vim.api.nvim_buf_is_valid(args.buf) then
                pcall(vim.treesitter.start, args.buf, lang)
              end
            end)
          end
        end,
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = "VeryLazy",
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = {
          -- Jump forward to the textobject, like targets.vim.
          lookahead = true,
          selection_modes = {
            ["@parameter.outer"] = "v", -- charwise
            ["@function.outer"] = "V",  -- linewise
            ["@class.outer"] = "<c-v>", -- blockwise
          },
          include_surrounding_whitespace = true,
        },
        move = { set_jumps = true },
      })

      -- On `main` the keymaps are yours to define; there is no `keymaps = {}` table.
      local select = require("nvim-treesitter-textobjects.select")
      local textobjects = {
        ["af"] = { "@function.outer", "textobjects", "Select outer part of a function" },
        ["if"] = { "@function.inner", "textobjects", "Select inner part of a function" },
        ["ac"] = { "@class.outer", "textobjects", "Select outer part of a class" },
        ["ic"] = { "@class.inner", "textobjects", "Select inner part of a class region" },
        ["as"] = { "@local.scope", "locals", "Select language scope" },
      }
      for lhs, spec in pairs(textobjects) do
        local query, group, desc = spec[1], spec[2], spec[3]
        vim.keymap.set({ "x", "o" }, lhs, function()
          select.select_textobject(query, group)
        end, { desc = desc })
      end
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "VeryLazy",
    config = function()
      require("treesitter-context").setup()
      vim.keymap.set("n", "[c", function()
        require("treesitter-context").go_to_context(vim.v.count1)
      end, { silent = true, desc = "Jump to 1 layer of context" })
    end,
  },
}
