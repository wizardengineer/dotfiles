return {
  "augmentcode/augment.vim",
  config = function()
    -- Optional: configure workspace folders for better context
    -- vim.g.augment_workspace_folders = { "~/Developer" }

    -- Keybindings
    vim.keymap.set("i", "<C-y>", "<cmd>call augment#Accept()<cr>", { desc = "Accept Augment suggestion" })
    vim.keymap.set("n", "<leader>ac", "<cmd>Augment chat<CR>", { desc = "Augment chat" })
    vim.keymap.set("n", "<leader>at", "<cmd>Augment chat-toggle<CR>", { desc = "Toggle Augment chat" })
    vim.keymap.set("n", "<leader>an", "<cmd>Augment chat-new<CR>", { desc = "New Augment chat" })
  end,
}
