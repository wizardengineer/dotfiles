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

vim.keymap.set("n", "<leader>c", function()
    vim.cmd("LspClangdSwitchSourceHeader")
end, { desc = "Open matching source file in current buffer" })

-- vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename,
--     { noremap = true, silent = true, desc = "Rename" })

vim.keymap.set("n", "<leader>lD", vim.diagnostic.goto_prev,
    { noremap = true, silent = true, desc = "Go to previous diagnostics error" })

vim.keymap.set("n", "<leader>ld", vim.diagnostic.goto_next,
    { noremap = true, silent = true, desc = "Go to next diagnostics error" })

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

