return {
	"mfussenegger/nvim-lint",
	config = function()
		require("lint").linters_by_ft = {
			json = { "jsonlint" },
		}

		vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
			callback = function()
				require("lint").try_lint()
			end,
		})
	end,
}
