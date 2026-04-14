local highlight_filetypes = {
	"bash",
	"python",
	"c",
	"diff",
	"html",
	"javascript",
	"lua",
	"luadoc",
	"markdown",
	"query",
	"typescript",
	"vim",
}

local indent_filetypes = {
	"bash",
	"c",
	"diff",
	"jsdoc",
	"lua",
	"luadoc",
	"markdown",
	"query",
	"typescript",
	"vim",
}

return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local treesitter = require("nvim-treesitter")

			treesitter.setup({
				ensure_installed = {
					"bash",
					"c",
					"diff",
					"go",
					"html",
					"javascript",
					"jsdoc",
					"lua",
					"luadoc",
					"markdown",
					"python",
					"query",
					"tsx",
					"typescript",
					"vim",
				},
			})

			local group = vim.api.nvim_create_augroup("dotfiles-treesitter", { clear = true })

			vim.api.nvim_create_autocmd("FileType", {
				group = group,
				pattern = highlight_filetypes,
				callback = function(args)
					pcall(vim.treesitter.start, args.buf)
				end,
			})

			vim.api.nvim_create_autocmd("FileType", {
				group = group,
				pattern = indent_filetypes,
				callback = function(args)
					vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})
		end,
	},
}
