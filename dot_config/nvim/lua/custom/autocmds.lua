-- ~/.config/nvim/lua/custom/autocmds.lua

-- Auto‐open netrw on `nvim .`
local autocmd = vim.api.nvim_create_autocmd

autocmd("VimEnter", {
  command = ":NvimTreeToggle",
})

autocmd("BufWritePre", {
  pattern = { "*.c", "*.cpp", "*.h", "*.hpp" },
  -- adjust the patterns to match the filetypes you want formatted
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})
