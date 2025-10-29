-- ~/.config/nvim/lua/custom/autocmds.lua

-- Auto‐open netrw on `nvim .`
local autocmd = vim.api.nvim_create_autocmd

autocmd("VimEnter", {
  command = ":NvimTreeToggle",
})

-- Format C/C++ files on save, EXCEPT in llvm-project, clangir, instafix, and instafix-llvm
autocmd("BufWritePre", {
  pattern = { "*.c", "*.cpp", "*.h", "*.hpp", "*.inc" },
  callback = function()
    -- Check if we're in llvm-project, clangir, instafix, or instafix-llvm
    local filepath = vim.fn.expand("%:p")
    if not filepath:match("llvm%-project") 
       and not filepath:match("clangir") 
       and not filepath:match("instafix") 
       and not filepath:match("instafix%-llvm") then
      vim.lsp.buf.format({ async = false })
    end
  end,
})
