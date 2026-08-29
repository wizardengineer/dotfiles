vim.o.hlsearch = true
vim.o.mouse = "a"

vim.opt.clipboard:append("unnamedplus")

vim.o.relativenumber = true
vim.o.number         = true
vim.o.cursorline     = true

vim.o.scrolloff      = 10

-- LLVM house style: spaces, 2-column indents. (Previously came from the
-- sourced `vimrc`, which silently overrode whatever was set here.)
vim.o.tabstop        = 8
vim.o.softtabstop    = 2
vim.o.shiftwidth     = 2
vim.o.expandtab      = true
vim.o.smarttab       = true

vim.o.incsearch      = true

vim.o.spell          = false
vim.o.jumpoptions    = "stack,view"
vim.o.termguicolors  = true

-- `syntax=on` is no longer set: treesitter (`vim.treesitter.start`) owns
-- highlighting, and regex syntax on top of it just costs redraw time.
-- Legacy filetypes without a parser still fall back via ftplugin/syntax files.

vim.diagnostic.config({
    virtual_text = true,
})

-- Enable autoread
vim.o.autoread = true

-- Check if file has changed on disk
--
--
--vim
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
    pattern = "*",
    callback = function()
        if vim.fn.mode() ~= "c" then
            vim.cmd("checktime")
        end
    end
})
-- Notification after file change
-- vim.api.nvim_create_autocmd("FileChangedShellPost", {
--     pattern = "*",
--     callback = function()
--         vim.print({
--             "File changed on disk. Buffer reloaded.",}
--         , false, {})
--     end
-- })
-- Highlighting spaces
-- local match_id = nil
--
-- vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
--   pattern = "*",
--   callback = function()
--     vim.cmd("highlight ExtraSpaces ctermbg=red guibg=red")
--     if match_id then
--       pcall(vim.fn.matchdelete, match_id)
--     end
--     match_id = vim.fn.matchadd("ExtraSpaces", [[\(\S\)\s\{2}\(\S\)]])
--   end,
-- })

--- Open file at the last position it was edited earlier
vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        if mark[1] > 1 and mark[1] <= vim.api.nvim_buf_line_count(0) then
            vim.api.nvim_win_set_cursor(0, mark)
        end
    end,
})

-- highlight yanks
vim.api.nvim_create_autocmd('TextYankPost', {
    pattern  = '*',
    callback = function() vim.hl.on_yank { timeout = 300 } end
})

-- Remove hl search when enter Insert
vim.api.nvim_create_autocmd({ "InsertEnter", "CmdlineEnter" }, {
    desc = "Remove hl search when enter Insert",
    callback = vim.schedule_wrap(function()
        vim.cmd.nohlsearch()
    end),
})

-- Show cursor line only in active window
local cursorGrp = vim.api.nvim_create_augroup('CursorLine', { clear = true })
vim.api.nvim_create_autocmd({ 'InsertLeave', 'WinEnter' }, {
  pattern = '*',
  command = 'set cursorline',
  group = cursorGrp,
})
vim.api.nvim_create_autocmd({ 'InsertEnter', 'WinLeave' }, { pattern = '*', command = 'set nocursorline', group = cursorGrp })


--
