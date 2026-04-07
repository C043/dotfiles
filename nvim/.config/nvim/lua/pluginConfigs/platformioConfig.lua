require("platformio").setup({
	lsp = "clangd",
	clangd_source = "compiledb", -- valid values: "ccls" | "compiledb"
	-- "compiledb" generates compile_commands.json for clangd
})
