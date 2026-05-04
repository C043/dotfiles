return {
	{
		"c043/dashboard-nvim",
		event = "VimEnter",
		dependencies = {
			{ "nvim-tree/nvim-web-devicons" },
			{ "amansingh-afk/milli.nvim" },
		},
		config = function()
			local splash = require("milli").load({ splash = "blackhole" })
			require("dashboard").setup({
				theme = "hyper",
				config = {
					header = splash.frames[1],
					week_header = {
						enable = false,
					},
					project = {
						enable = false,
					},
					disable_move = true,
					shortcut = {
						{ desc = "󰚰 Update", group = "@property", action = "Lazy update", key = "u" },
						{ desc = " Plugins", group = "@property", action = "Lazy", key = "p" },
						{
							icon_hl = "@variable",
							desc = "󰭎 Files",
							group = "Label",
							action = "Telescope find_files",
							key = "f",
						},
						{
							icon = " ",
							desc = "Grep",
							group = "String",
							action = function()
								require("telescope.builtin").live_grep()
							end,
							key = "g",
						},
						{
							desc = "  Mason",
							group = "DiagnosticHint",
							action = "Mason",
							key = "m",
						},
					},
				},
			})
			require("milli").dashboard({ splash = "blackhole", loop = true })
		end,
	},
}
