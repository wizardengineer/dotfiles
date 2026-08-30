-- The global ruler is 80 (lua/configs/llvm_style.lua), which is LLVM's limit.
-- Rust's is 100: rustfmt defaults to max_width = 100, and Nvim's own bundled
-- $VIMRUNTIME/ftplugin/rust.vim:53 already does `setlocal textwidth=100` to
-- match. Without this the ruler marked a limit that does not apply here.
--
-- `colorcolumn` is a WINDOW option, so `vim.bo` (used by the other ftplugins
-- in this directory for buffer options) does not apply. Window options set in
-- an ftplugin persist in that window after switching to another buffer, hence
-- the b:undo_ftplugin entry below.
vim.opt_local.colorcolumn = "100"

vim.b.undo_ftplugin = (vim.b.undo_ftplugin and vim.b.undo_ftplugin .. " | " or "")
    .. "setlocal colorcolumn<"
