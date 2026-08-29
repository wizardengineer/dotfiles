return {
  -- Maintained fork of sindrets/diffview.nvim (original unmaintained since 2024).
  -- Purpose: live review surface for edits made by terminal coding agents
  -- (codex/pi in tmux panes) — pairs with the autoread/checktime already set up.
  "dlyongemallo/diffview.nvim",
  cmd = {
    "DiffviewOpen",
    "DiffviewClose",
    "DiffviewFileHistory",
    "DiffviewToggleFiles",
    "DiffviewFocusFiles",
    "DiffviewRefresh",
  },
  -- <leader>d belongs to opencode (session half-page-down), so these live
  -- under <leader>g* instead (<leader>gv/<leader>gh were free in normal mode).
  keys = {
    {
      "<leader>gv",
      function()
        -- Toggle: close the tab's Diffview if one is open, otherwise open one.
        if require("diffview.lib").get_current_view() then
          vim.cmd("DiffviewClose")
        else
          vim.cmd("DiffviewOpen")
        end
      end,
      desc = "Diffview: toggle working-tree diff",
    },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: history of current file" },
  },
  config = function()
    require("diffview").setup({})
  end,
}
