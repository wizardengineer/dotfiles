-- nvim-ufo takes over folding per-buffer once it attaches; these are the
-- defaults it expects, plus a treesitter fallback for buffers it skips.
--
-- Was: foldexpr = "nvim_treesitter#foldexpr()" -- a Vimscript function that only
-- existed on nvim-treesitter's `master` branch and is gone on `main`. Nvim ships
-- `vim.treesitter.foldexpr()` natively, so no plugin is needed for this at all.
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldtext = ""
vim.opt.fillchars:append({ fold = " " })

vim.o.foldenable = true
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
