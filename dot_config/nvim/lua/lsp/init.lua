local language_servers = {
  "lua_ls",                -- ✅ Lua LSP (installed)
  "pylsp",                 -- ✅ Python LSP (installed)
  "clangd",                -- ✅ C/C++ LSP (works\!)
  "rust_analyzer",         -- ✅ Rust LSP (rustup component, ~/.cargo/bin)
  "tblgen_lsp_server",     -- ✅ TableGen LSP (fixed path\!)
  "mlir_lsp_server",       -- ✅ MLIR LSP (fixed path\!)
  -- "cir_lsp_server",     -- ⚠️ Enable if you have ClangIR built
  -- Commented out not installed LSPs:
  -- "fortls",             -- ⚠️ Not installed
  -- "gleam",              -- ⚠️ Not installed
  -- "esbonio",            -- ⚠️ Not installed
  -- "cmake-language-server", -- ⚠️ Not installed
}
-- Was `vim.lsp.set_log_level(4)`: deprecated, removed in Nvim 0.13.
vim.lsp.log.set_level(vim.log.levels.ERROR)

for _, name in ipairs(language_servers) do
  local ok, config = pcall(require, "lsp." .. name)
  if ok then
    vim.lsp.config[name] = config
  else
    -- No local override; fall through to whatever nvim-lspconfig ships.
    vim.notify(("lsp: no local config for %q, using lspconfig default"):format(name), vim.log.levels.DEBUG)
  end
  vim.lsp.enable(name)
end

-- vim.lsp.enable("clangd")



--- AUTO COMMANDS
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function(args)
    -- vim.lsp.buf.format({
    --     async = false,
    --     bufnr = args.buf,
    --     timeout_ms = 1000,
    -- })
  end,
})

--- KEY MAPS

vim.keymap.set("n", "<leader>c", function()
  vim.cmd("LspClangdSwitchSourceHeader")
end, { desc = "Open matching source file in current buffer" })

vim.keymap.set("n", "gd", vim.lsp.buf.definition, { noremap = true, silent = true, desc = "Go to implementation" })

vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename,
  { noremap = true, silent = true, desc = "Rename" })


vim.keymap.set('n', '<leader>lt', vim.lsp.buf.typehierarchy,
  { desc = "type hierachy" })
