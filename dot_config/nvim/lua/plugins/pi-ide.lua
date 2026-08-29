return {
  -- TRIAL: pi IDE protocol over WebSocket — lets the `pi` CLI in a tmux pane
  -- discover this Neovim via a ~/.pi/ide/<port>.lock file (no `pi --ide` flag
  -- needed; pi matches on workspace folder) and open proposed-edit diffs,
  -- read LSP diagnostics, etc. Remove this file if the trial doesn't pan out.
  "ldelossa/pi-ide.nvim",
  -- Must load at startup so the server + lock file exist before pi looks for them.
  event = "VeryLazy",
  config = function()
    require("pi-ide").setup({
      auto_start = true,
      -- claudecode.nvim already owns the ~/.claude/ide lock file; don't let
      -- pi-ide write a competing one.
      claude_code_compatibility = false,
      -- Ghost-text completions off: llama.vim already owns FIM ghost text and
      -- <Tab> (pi-ide's default accept key) belongs to blink.cmp.
      suggestion = {
        auto_trigger = false,
        default_keys = false,
      },
    })
  end,
}
