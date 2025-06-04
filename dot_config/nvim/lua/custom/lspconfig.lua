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
--     settings = {
--         ["rust-analyzer"] = {
--             hover = {
--                 enabled = false, -- Disable rust-analyzer's default hover
--             }
--         }
--     },
-- }
--
-- lspconfig.rust_analyzer.setup {
--   on_attach = function(client, bufnr)
--     -- Disable signature help
--     client.handlers["textDocument/signatureHelp"] = nil
--     on_attach(client, bufnr)
--   end,
-- }

