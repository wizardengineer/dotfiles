-- In your minuet-ai.nvim config
return {
     "milanglacier/minuet-ai.nvim",
     config = function()
       require("minuet").setup({
         provider = "claude",
         notify = "warn",
         context_window = 8192,
         throttle = 1000,
         debounce = 400,
         request_timeout = 3,
         provider_options = {
           claude = {
             model = "claude-sonnet-4.5",
             max_tokens = 256,
             stream = true,
             api_key = "ANTHROPIC_API_KEY",
           },
         },
       })
       -- Use leader+Enter to accept completion
       vim.keymap.set('i', '<leader><CR>', function()
         if require('minuet.virtualtext').action.is_visible() then
           require('minuet.virtualtext').action.accept()
         else
           return '<CR>' -- fallback to normal Enter if no completion
         end
       end, { expr = true, desc = "Accept Minuet completion" })
       -- Optional: Accept line by line
       vim.keymap.set('i', '<leader>l', function()
         require('minuet.virtualtext').action.accept_line()
       end, { desc = "Accept Minuet completion line" })
       -- Navigate between multiple completions
       vim.keymap.set('i', '<C-n>', function()
         require('minuet.virtualtext').action.next()
       end, { desc = "Next Minuet completion" })
       vim.keymap.set('i', '<C-p>', function()
         require('minuet.virtualtext').action.prev()
       end, { desc = "Previous Minuet completion" })
       -- Dismiss completion
       vim.keymap.set('i', '<C-c>', function()
         require('minuet.virtualtext').action.dismiss()
       end, { desc = "Dismiss Minuet completion" })
     end,
    { 'nvim-lua/plenary.nvim' },
    -- optional, if you are using virtual-text frontend, blink is not required.
    { 'Saghen/blink.cmp' },
}



