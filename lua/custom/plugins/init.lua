require("lazy").setup({
	-- Simple setups

	"tpope/vim-fugitive", -- Git integration with vim
	"tpope/vim-rhubarb", -- Github integration for vim-fugitive
	"tpope/vim-sleuth", -- Automatic tab and space detection
	"folke/which-key.nvim", -- Keybind display / helper
	"norcalli/nvim-colorizer.lua",
	"ThePrimeagen/harpoon",

	-- Simple setups, but require an opts = {} to run properly

	{ "numToStr/Comment.nvim",            opts = {} }, -- "gc" command to comment visually selected lines

	-- Advanced setups

	-- LSP integration with nvim
	{ 'williamboman/mason.nvim' },
	{ 'williamboman/mason-lspconfig.nvim' },
	{ 'VonHeikemen/lsp-zero.nvim',        branch = 'v3.x' },
	{ 'neovim/nvim-lspconfig' },
	{ 'hrsh7th/cmp-nvim-lsp' },
	{ 'hrsh7th/nvim-cmp' },
	{ 'L3MON4D3/LuaSnip' },
	{ "folke/neodev.nvim",                opts = {} },
	{ "j-hui/fidget.nvim",                opts = {} },

	-- Autocompletion
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"L3MON4D3/LuaSnip", -- Snippet engine
			"saadparwaiz1/cmp_luasnip", -- Snippet engine nvim-cmp integration
			"hrsh7th/cmp-nvim-lsp", -- Autocompletion from LSP
			"rafamadriz/friendly-snippets", -- User-friendly snippet collection
		},
	},

	-- Theme
	require("custom/theme/setup"),

	-- Status bar (uses theme)
	{
		"nvim-lualine/lualine.nvim",
		opts = {
			options = {
				icons_enabled = true,
				theme = "catppuccin",
				component_separators = "|",
				section_separators = "",
			},
		},
	},

	-- Adds indentation guides on all lines, including blank
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {},
	},

	-- Fuzzy finder
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim", -- I don't think I'm smart enough to understand quite what this does lol, but it's some async something for telescope
			-- Fast C implementation of the fuzzy finder's algorithm (Requires `make` to compile)
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build =
				"cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
				cond = function()
					return vim.fn.executable "cmake" == 1
				end,
			},
		},
	},

	-- Treesitter language parser
	{
		"nvim-treesitter/nvim-treesitter",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
			"luckasRanarison/tree-sitter-hypr", -- Treesitter plugin for Hyprland conf files
		},
		build = ":TSUpdate",
	},

	-- Automatically restart session
	{
		"rmagatti/auto-session",
		opts = {
			log_level = "error",
			auto_session_suppress_dirs = { "/", "~/", "~/Downloads" }
		}
	},

	{
		-- Adds git related signs to the gutter, as well as utilities for managing changes
		"lewis6991/gitsigns.nvim",
		opts = {
			-- See `:help gitsigns.txt`
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
			on_attach = function(bufnr)
				vim.keymap.set("n", "<leader>gp", require("gitsigns").preview_hunk,
					{ buffer = bufnr, desc = "Preview git hunk" })

				-- don't override the built-in and fugitive keymaps
				local gs = package.loaded.gitsigns
				vim.keymap.set({ "n", "v" }, "]c", function()
					if vim.wo.diff then
						return "]c"
					end
					vim.schedule(function()
						gs.next_hunk()
					end)
					return "<Ignore>"
				end, { expr = true, buffer = bufnr, desc = "Jump to next hunk" })
				vim.keymap.set({ "n", "v" }, "[c", function()
					if vim.wo.diff then
						return "[c"
					end
					vim.schedule(function()
						gs.prev_hunk()
					end)
					return "<Ignore>"
				end, { expr = true, buffer = bufnr, desc = "Jump to previous hunk" })
			end,
		},
	},
})

-- Post config that can't or shouldn't be done in opts{}
require("custom/plugins/config")
