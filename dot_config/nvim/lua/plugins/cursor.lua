return {
  'hoscarcito/cursor-nvim-plugin',
  config = function()
    -- Cursor CLI keymaps
    local keymap = vim.keymap.set
    local opts = { noremap = true, silent = true }

    keymap('n', '<leader>mc', ':CursorChat<CR>', vim.tbl_extend('force', opts, { desc = 'Cursor chat' }))
    keymap('n', '<leader>mg', ':CursorGenerate<CR>', vim.tbl_extend('force', opts, { desc = 'Cursor generate code' }))
    keymap('n', '<leader>mr', ':CursorReview<CR>', vim.tbl_extend('force', opts, { desc = 'Cursor review code' }))

    -- Normal and visual mode mappings
    keymap({'n', 'v'}, '<leader>me', ':CursorEdit<CR>', vim.tbl_extend('force', opts, { desc = 'Cursor edit' }))

    -- Visual mode only mappings
    keymap('v', '<leader>mx', ':CursorExplain<CR>', vim.tbl_extend('force', opts, { desc = 'Cursor explain' }))
    keymap('v', '<leader>ms', ':CursorOptimize<CR>', vim.tbl_extend('force', opts, { desc = 'Cursor optimize' }))
    keymap('v', '<leader>mf', ':CursorFix<CR>', vim.tbl_extend('force', opts, { desc = 'Cursor fix' }))
    keymap('v', '<leader>mrf', ':CursorRefactor<CR>', vim.tbl_extend('force', opts, { desc = 'Cursor refactor' }))
  end,
}


