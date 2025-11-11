
local M = {}

---@diagnostic disable-next-line: undefined-field
local sysname = vim.loop.os_uname().sysname

if sysname == "Darwin" then
  -- macOS
  M.llvm_bin = "/Users/juliusalexandre/Projects/MainRepo/llvm-project/build/bin/"
  M.clangir_repo = "/Users/juliusalexandre/Projects/MainRepo/clangir/"
  M.prebuilt_llvm_bin = "/Users/juliusalexandre/Projects/MainRepo/LLVM-21.1.2-macOS-X64/bin/"
elseif sysname == "Linux" then
  -- Linux
  M.llvm_bin = "/home/juliusalexandre/Projects/MainRepo/llvm-project/build/bin/"
  M.clangir_repo = "/home/juliusalexandre/Projects/MainRepo/clangir/"
  M.prebuilt_llvm_bin = "/home/juliusalexandre/Projects/MainRepo/LLVM-21.1.2-Linux-X64/bin/"
else
  error("Unsupported OS, not sure how to set this up: " .. sysname)
end

return M
