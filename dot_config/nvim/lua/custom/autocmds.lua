-- ~/.config/nvim/lua/custom/autocmds.lua

-- Auto‐open netrw on `nvim .`
local autocmd = vim.api.nvim_create_autocmd

autocmd("VimEnter", {
  command = ":NvimTreeToggle",
})
