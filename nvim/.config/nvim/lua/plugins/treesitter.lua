local highlight_filetypes = {
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
}

return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			-- Polyfill vim.list.unique for nvim < 0.12
			if not vim.list then
				vim.list = { unique = function(t)
					local seen, result = {}, {}
					for _, v in ipairs(t) do
						if not seen[v] then
							seen[v] = true
							result[#result + 1] = v
						end
					end
					return result
				end }
			end

			require("nvim-treesitter").install({
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
			})

			local group = vim.api.nvim_create_augroup("dotfiles-treesitter", { clear = true })

			vim.api.nvim_create_autocmd("FileType", {
				group = group,
				pattern = highlight_filetypes,
				callback = function(args)
					pcall(vim.treesitter.start, args.buf)
				end,
			})

		end,
	},
}
