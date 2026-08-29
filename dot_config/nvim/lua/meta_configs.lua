--- Machine-specific paths to locally built / prebuilt LLVM trees.
local M = {}

local sysname = vim.uv.os_uname().sysname

if sysname == "Darwin" then
  M.home = "/Users/juliusalexandre"
elseif sysname == "Linux" then
  M.home = "/home/juliusalexandre"
else
  error("Unsupported OS, not sure how to set this up: " .. sysname)
end

M.llvm_bin = M.home .. "/Projects/MainRepo/llvm-project/build/bin/"
M.clangir_repo = M.home .. "/Projects/MainRepo/clangir/"
M.prebuilt_llvm_bin = M.home .. "/Projects/MainRepo/LLVM-21.1.2-macOS-X64/bin/"
if sysname == "Linux" then
  M.prebuilt_llvm_bin = M.home .. "/Projects/MainRepo/LLVM-21.1.2-Linux-X64/bin/"
end

--- Resolve an LLVM tool to the first candidate that actually exists.
---
--- The hardcoded trees above are not present on every machine. Handing
--- `vim.lsp.config` a `cmd` pointing at a missing binary makes the server fail
--- to spawn with no visible error, so fall back to `$PATH` and finally to the
--- bare name (so `:checkhealth vim.lsp` reports the real problem).
---
---@param name string Tool name, e.g. "clangd" or "mlir-lsp-server".
---@param extra? string[] Additional absolute paths to try before the defaults.
---@return string path Absolute path to the tool, or `name` if none was found.
function M.llvm_tool(name, extra)
  local candidates = vim.list_extend(vim.deepcopy(extra or {}), {
    M.prebuilt_llvm_bin .. name,
    M.llvm_bin .. name,
  })
  for _, path in ipairs(candidates) do
    if vim.uv.fs_stat(path) then
      return path
    end
  end
  local on_path = vim.fn.exepath(name)
  return on_path ~= "" and on_path or name
end

return M
