return {
  "coder/claudecode.nvim",
  -- Pinned to main HEAD (2026-07-12): upstream has no recent tags, so pin a
  -- commit for reproducibility. Bump deliberately.
  commit = "2390c6e45c4789072c293ac69de051d169668b29",
  -- Must load at startup (not on cmd/keys): the WebSocket server + lock file
  -- have to exist before `/ide` is run from the `claude` CLI in a tmux pane.
  event = "VeryLazy",
  config = function()
    require("claudecode").setup({
      -- `claude` runs in a tmux pane, never inside Neovim. "none" skips all
      -- terminal management but keeps the WebSocket server + lock file running
      -- so `/ide` (or `claude --ide`) can attach to this Neovim instance.
      terminal = { provider = "none" },
    })

    -- Upstream issue #218 (segfault accepting a NEW-file diff while
    -- render-markdown.nvim is active) was fixed by PR #224, which is included
    -- in the pinned commit — no local workaround needed. If you ever pin
    -- earlier than #224, re-check that issue.

    -- Keymaps: <leader>a* was free (grep of lua/ found no <leader>a mappings).
    vim.keymap.set("x", "<leader>as", "<cmd>ClaudeCodeSend<cr>",       { desc = "Claude: send selection to prompt" })
    vim.keymap.set("n", "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>",      { desc = "Claude: add current buffer to context" })
    vim.keymap.set("n", "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", { desc = "Claude: accept proposed diff" })
    vim.keymap.set("n", "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>",   { desc = "Claude: deny proposed diff" })
  end,
}
