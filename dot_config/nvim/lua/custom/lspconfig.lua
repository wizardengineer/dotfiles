local base = require("nvchad.configs.lspconfig")
local on_attach = base.on_attach
local capabilities = base.capabilities

local lspconfig = require("lspconfig")

local function switch_source_header(bufnr)
    local method_name = 'textDocument/switchSourceHeader'
    local client = vim.lsp.get_clients({ bufnr = bufnr, name = 'clangd' })[1]
    if not client then
        return vim.notify(('method %s is not supported by any servers active on the current buffer'):format(method_name))
    end
    local params = vim.lsp.util.make_text_document_params(bufnr)
    client.request(method_name, params, function(err, result)
        if err then
            error(tostring(err))
        end
        if not result then
            vim.notify('corresponding file cannot be determined')
            return
        end
        vim.cmd.edit(vim.uri_to_fname(result))
    end, bufnr)
end


lspconfig.clangd.setup {
  on_attach = function(client, bufnr)
    client.server_capabilities.signatureHelpProvider = false
    on_attach(client, bufnr)

    vim.api.nvim_buf_create_user_command(0, 'LspClangdSwitchSourceHeader', function()
            switch_source_header(0)
        end, { desc = 'Switch between source/header' })
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

