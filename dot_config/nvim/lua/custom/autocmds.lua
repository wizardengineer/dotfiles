-- ~/.config/nvim/lua/custom/autocmds.lua

-- Auto‐open netrw on `nvim .`
local autocmd = vim.api.nvim_create_autocmd

autocmd("VimEnter", {
  command = ":NvimTreeToggle",
})

-- Format C/C++ files on save, EXCEPT in llvm-project
autocmd("BufWritePre", {
  pattern = { "*.c", "*.cpp", "*.h", "*.hpp", "*.inc" },
  callback = function()
    -- Check if we're in llvm-project
    local filepath = vim.fn.expand("%:p")
    if not filepath:match("llvm%-project") then
      vim.lsp.buf.format({ async = false })
    end
  end,
})
