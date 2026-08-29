-- LLVM coding-guidelines helpers, ported from the upstream `utils/vim/vimrc`.
--
-- Dropped deliberately during the port:
--   * `set nocompatible`, `syntax on`, `filetype on` -- all no-ops or defaults in Nvim.
--   * `ClangComplete()` + `set omnifunc=ClangComplete` -- superseded by the clangd
--     LSP client (lua/lsp/clangd.lua). Leaving it in clobbered the omnifunc that
--     Nvim installs on LspAttach, which broke blink.cmp's `omni` source.
--   * `set smartindent` / `set cindent` autocmds -- treesitter + clangd indent now.
--   * `*Makefile*` / `*.ll` / `*.td` / `*.rst` filetype autocmds -- covered by
--     Nvim's built-in ftdetect plus the files in `ftdetect/`.
--   * Global `softtabstop`/`shiftwidth`/`expandtab` -- moved to configs/options.lua
--     so there is a single source of truth.

-- Lines longer than 80 columns.
vim.o.colorcolumn = "80"

-- Trailing whitespace, minus the run you are actively typing.
vim.api.nvim_set_hl(0, "WhitespaceEOL", { link = "DiffDelete", default = true })

local group = vim.api.nvim_create_augroup("llvm_whitespace", { clear = true })

local function match_trailing(pattern)
  if vim.w.llvm_ws_match then
    pcall(vim.fn.matchdelete, vim.w.llvm_ws_match)
    vim.w.llvm_ws_match = nil
  end
  if not vim.bo.modifiable or vim.bo.buftype ~= "" then
    return
  end
  vim.w.llvm_ws_match = vim.fn.matchadd("WhitespaceEOL", pattern, -1)
end

vim.api.nvim_create_autocmd({ "BufWinEnter", "InsertLeave" }, {
  group = group,
  desc = "Highlight trailing whitespace",
  callback = function() match_trailing([[\s\+$]]) end,
})

vim.api.nvim_create_autocmd("InsertEnter", {
  group = group,
  desc = "Highlight trailing whitespace, except where the cursor is",
  callback = function() match_trailing([[\s\+\%#\@<!$]]) end,
})

-- Cleanup commands from the LLVM vimrc.
vim.api.nvim_create_user_command("DeleteTrailingWs", function()
  local view = vim.fn.winsaveview()
  vim.cmd([[keeppatterns %s/\s\+$//e]])
  vim.fn.winrestview(view)
end, { desc = "Delete trailing whitespace on every line" })

vim.api.nvim_create_user_command("Untab", function()
  local view = vim.fn.winsaveview()
  vim.cmd([[keeppatterns %s/\t/  /ge]])
  vim.fn.winrestview(view)
end, { desc = "Convert every tab character to two spaces" })
