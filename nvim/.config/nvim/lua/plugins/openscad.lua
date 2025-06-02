return {
	{
		"salkin-mada/openscad.nvim",
		config = function()
			vim.g.openscad_load_snippets = true
			vim.g.openscad_default_mappings = true
			require("openscad")
		end,
		dependencies = { "L3MON4D3/LuaSnip", "junegunn/fzf.vim" },
	},
}
