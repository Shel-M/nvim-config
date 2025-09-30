require("catppuccin").setup({
	flavour = "mocha",
	float = {
		transparent = true,
		solid = false,
	},

	color_overrides = {
		mocha = {
			base = "#000000",
		},
	},
	integrations = {
		blink_cmp = { style = "bordered" },
		gitsigns = true,
		harpoon = true,
		mason = true,
	},
})
vim.cmd.colorscheme("catppuccin")
