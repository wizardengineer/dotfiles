local base = require("nvchad.configs.lspconfig")
local on_attach = base.on_attach
local capabilities = base.capabilities

local lspconfig = require("lspconfig")

lspconfig.clangd.setup {
  on_attach = function(client, bufnr)
    client.server_capabilities.signatureHelpProvider = false
    on_attach(client, bufnr)
  end,

  capabilities = capabilities,
}

-- lspconfig.rust_analyzer.setup {
--   on_attach = function(client, bufnr)
--     client.server_capabilities.signatureHelpProvider = false
--     vim.lsp.buf.hover.Opts = {
--         focusable = false,
--         focus = false
--       }
--
--     on_attach(client, bufnr)
--   end,
--
--   capabilities = capabilities,
-- }
--
-- lspconfig.rust_analyzer.setup {
--   on_attach = function(client, bufnr)
--     -- Disable signature help
--     client.handlers["textDocument/signatureHelp"] = nil
--     on_attach(client, bufnr)
--   end,
-- }

