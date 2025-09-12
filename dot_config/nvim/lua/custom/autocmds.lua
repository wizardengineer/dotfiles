-- ~/.config/nvim/lua/custom/autocmds.lua

-- Auto‐open netrw on `nvim .`
local autocmd = vim.api.nvim_create_autocmd

autocmd("VimEnter", {
  command = ":NvimTreeToggle",
})

-- Format C/C++ files on save, EXCEPT in llvm-project and clangir
autocmd("BufWritePre", {
  pattern = { "*.c", "*.cpp", "*.h", "*.hpp", "*.inc" },
  callback = function()
    -- Check if we're in llvm-project or clangir
    local filepath = vim.fn.expand("%:p")
    if not filepath:match("llvm%-project") and not filepath:match("clangir") then
      vim.lsp.buf.format({ async = false })
    end
  end,
})
