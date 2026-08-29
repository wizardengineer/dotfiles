-- ftplugin runs per buffer: use buffer-local options, not `vim.opt` (global),
-- otherwise opening one C file re-indents every other buffer in the session.
vim.bo.tabstop = 2
vim.bo.softtabstop = 2
vim.bo.shiftwidth = 2
vim.bo.expandtab = true

-- LLVM cinoptions, from utils/vim/vimrc. Only a fallback -- clangd's
-- indentation wins whenever the LSP is attached.
vim.bo.cinoptions = ":0,g0,(0,Ws,l1"
