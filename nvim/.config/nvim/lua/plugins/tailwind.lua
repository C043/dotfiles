return {
	-- tailwind-tools.lua
	{
		"luckasRanarison/tailwind-tools.nvim",
		name = "tailwind-tools",
		build = ":UpdateRemotePlugins",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-telescope/telescope.nvim", -- optional
			"neovim/nvim-lspconfig", -- optional
		},
		opts = {
			-- Prevent tailwind-tools from requiring & configuring lspconfig
			server = { override = false },
			extensions = {
				queries = { "ejs" },
			},
		}, -- your configuration
	},
}
