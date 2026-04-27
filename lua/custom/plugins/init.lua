require("lazy").setup({
	-- Simple setups

	"tpope/vim-fugitive", -- Git integration with vim
	"tpope/vim-rhubarb", -- Github integration for vim-fugitive
	"NMAC427/guess-indent.nvim", -- Automatic tab and space detection
	"folke/which-key.nvim", -- Keybind display / helper
	-- "norcalli/nvim-colorizer.lua",
	"ThePrimeagen/harpoon",
	"lewis6991/gitsigns.nvim", -- Adds git related signs to the gutter, as well as utilities for managing changes

	-- Simple setups, but require an opts = {} to run properly

	{ "numToStr/Comment.nvim", opts = {} }, -- "gc" command to comment visually selected lines

	-- Advanced setups

	-- Autocompletion
	{
		"saghen/blink.cmp",
		dependencies = {
			"saghen/blink.lib",
			"rafamadriz/friendly-snippets",
		},
		-- See: https://cmp.saghen.dev/installation for opts explanations
		opts = {
			keymap = { preset = "enter" },
			appearance = { nerd_font_variant = "mono" },
			completion = { documentation = { auto_show = true } },
			sources = {
				default = { "lsp", "path", "snippets", "lazydev", "buffer" },
				providers = {
					lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
				},
			},
			snippets = { preset = "luasnip" },
			fuzzy = { implementation = "lua" },
		},
		opts_extend = { "sources.default" },
	},

	-- Theme
	require("custom/theme/setup"),

	-- Status bar (uses theme)
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			options = {
				icons_enabled = true,
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
		-- branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim", -- I don't think I'm smart enough to understand quite what this does lol, but it's some async something for telescope
			-- Fast C implementation of the fuzzy finder's algorithm (Requires `make` to compile)
			{
				-- The weird build commands and use of specifically Cmake is so that the plugin works on Windows, which I have to use for work. :(
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
				cond = function()
					return vim.fn.executable("cmake") == 1
				end,
			},
			{ "nvim-telescope/telescope-ui-select.nvim" },
			{
				"nvim-tree/nvim-web-devicons",
				enabled = vim.g.have_nerd_font,
			},
		},
	},

	-- Treesitter language parser
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		branch = "main",
		build = ":TSUpdate",
		opts = {
			ensure_installed = {
				"bash",
				"c",
				"html",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"query",
				"vim",
				"vimdoc",
			},
			-- Autoinstall languages that are not installed
			auto_install = true,
			highlight = {
				enable = true,
				-- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
				--  If you are experiencing weird indenting issues, add the language to
				--  the list of additional_vim_regex_highlighting and disabled languages for indent.
				additional_vim_regex_highlighting = { "ruby" },
			},
			indent = { enable = true, disable = { "ruby" } },
		},
		-- [[ Configure Treesitter ]] See `:help nvim-treesitter-intro`
		config = function()
			-- ensure basic parser are installed
			local parsers = {
				"bash",
				"c",
				"diff",
				"html",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"query",
				"vim",
				"vimdoc",
			}
			require("nvim-treesitter").install(parsers)

			---@param buf integer
			---@param language string
			local function treesitter_try_attach(buf, language)
				-- check if parser exists and load it
				if not vim.treesitter.language.add(language) then
					return
				end
				-- enables syntax highlighting and other treesitter features
				vim.treesitter.start(buf, language)

				-- enables treesitter based folds
				-- for more info on folds see `:help folds`
				-- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
				-- vim.wo.foldmethod = 'expr'

				-- check if treesitter indentation is available for this language, and if so enable it
				-- in case there is no indent query, the indentexpr will fallback to the vim's built in one
				local has_indent_query = vim.treesitter.query.get(language, "indents") ~= nil

				-- enables treesitter based indentation
				if has_indent_query then
					vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end

			local available_parsers = require("nvim-treesitter").get_available()
			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					local buf, filetype = args.buf, args.match

					local language = vim.treesitter.language.get_lang(filetype)
					if not language then
						return
					end

					local installed_parsers = require("nvim-treesitter").get_installed("parsers")

					if vim.tbl_contains(installed_parsers, language) then
						-- enable the parser if it is installed
						treesitter_try_attach(buf, language)
					elseif vim.tbl_contains(available_parsers, language) then
						-- if a parser is available in `nvim-treesitter` auto install it, and enable it after the installation is done
						require("nvim-treesitter").install(language):await(function()
							treesitter_try_attach(buf, language)
						end)
					else
						-- try to enable treesitter features in case the parser exists but is not available from `nvim-treesitter`
						treesitter_try_attach(buf, language)
					end
				end,
			})
		end,
	},

	-- Automatically restart session
	{
		"rmagatti/auto-session",
		opts = {
			lazy_support = true,
			log_level = "error",
			suppress_dirs = { "/", "~/", "~/Downloads" },
		},
		-- config = function()
		-- 	vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
		-- end,
	},

	-- LSP confg
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"mason-org/mason.nvim",
			"mason-org/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			{ "j-hui/fidget.nvim", opts = {} },
			"saghen/blink.cmp",
		},
	},

	-- LSP integration with nvim
	{ "L3MON4D3/LuaSnip" },

	-- Specific Rust LSP config with extra features
	{
		"mrcjkb/rustaceanvim",
		version = "^9", -- Recommended
		lazy = false, -- This plugin is already lazy
	},
	{
		"saecki/crates.nvim",
		tag = "stable",
		event = { "BufRead Cargo.toml" },
		config = function()
			require("crates").setup()
		end,
	},

	-- LSP config for neovim
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
})

-- Post config that can't or shouldn't be done in opts}
require("custom/plugins/config")
