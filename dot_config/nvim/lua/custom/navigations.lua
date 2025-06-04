-- https://github.com/badumbatish/dotfiles/blob/aa8f32216ea0b8d29da8446a0c597d13a3fa5666/dot_config/nvim/lua/plugins/navigations.lua

return {
	{
		-- TELESCOPE

		{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
		{
			"nvim-telescope/telescope-frecency.nvim",
			-- install the latest stable version
			version = "*",
		},
		{
			'nvim-telescope/telescope.nvim',
			tag = '0.1.8',
			-- or                              , branch = '0.1.x',
			dependencies = { 'nvim-lua/plenary.nvim',
				"nvim-telescope/telescope-live-grep-args.nvim",
			},

			config = function()
				require('telescope').load_extension('fzf')
				require('telescope').load_extension('live_grep_args')
				require("telescope").load_extension "frecency"
				local live_grep_args_shortcuts = require("telescope-live-grep-args.shortcuts")
				local builtin = require('telescope.builtin')

				require('telescope').setup {
					defaults = {
						cache_picker = {
							num_pickers = 20
						}
						-- Default configuration for telescope goes here:
						-- config_key = value,
						-- ..
					}, }


				vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
				vim.keymap.set("n", "<leader>fg",
					":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>")
				vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
				vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
				vim.keymap.set('n', '/', builtin.current_buffer_fuzzy_find, {})

				vim.keymap.set('n', '<leader>fr', builtin.pickers, {})
				vim.keymap.set('n', '<leader>fp', builtin.pickers, {})

				vim.keymap.set("n", "<leader>g", live_grep_args_shortcuts.grep_word_under_cursor)
				vim.keymap.set("x", "<leader>g", live_grep_args_shortcuts.grep_visual_selection)


				-- SET UP KEYMAP FOR LSP, POTENTIALLY VIA TELESCOPE
				vim.keymap.set("n", "<leader>la", ":lua vim.lsp.buf.code_action()<CR>") -- Show code actions
				vim.keymap.set("n", "<leader>lr", ":lua vim.lsp.buf.rename()<CR>") -- Rename symbols with scope-correctness
				vim.keymap.set("n", "<leader>ldf", ":lua vim.lsp.buf.definition()<CR>", {}) -- Go to definition
				vim.keymap.set("n", "<leader>ldc", ":lua vim.lsp.buf.declaration()<CR>") -- Go to declaration

				vim.keymap.set("n", "<leader>m", builtin.lsp_implementations, {}) -- Go to implementation
				vim.keymap.set("n", "<leader>i", ":lua vim.lsp.buf.incoming_calls()<CR>", {}) -- Show incoming calls to the function under the cursor
				vim.keymap.set("n", "<leader>o", ":lua vim.lsp.buf.outgoing_calls()<CR>", {}) -- Show outgoing calls from the function under the cursor
				vim.keymap.set("n", "<leader>td", builtin.lsp_type_definitions)   -- Go to type definition
				vim.keymap.set("n", "<leader>th", ":lua vim.lsp.buf.typehierachy()<CR>") -- Show type hierarchy
			end
		}
	},
	-- {
	-- 	"christoomey/vim-tmux-navigator",
	-- 	cmd = {
	-- 		"TmuxNavigateLeft",
	-- 		"TmuxNavigateDown",
	-- 		"TmuxNavigateUp",
	-- 		"TmuxNavigateRight",
	-- 		"TmuxNavigatePrevious",
	-- 	},
	-- 	keys = {
	-- 		{ "<c-h>",  "<cmd><C-U>TmuxNavigateLeft<cr>" },
	-- 		{ "<c-j>",  "<cmd><C-U>TmuxNavigateDown<cr>" },
	-- 		{ "<c-k>",  "<cmd><C-U>TmuxNavigateUp<cr>" },
	-- 		{ "<c-l>",  "<cmd><C-U>TmuxNavigateRight<cr>" },
	-- 		{ "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
	-- 	},
	-- }
}
