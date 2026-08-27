return {
	{
		-- Configured in pluginConfigs/nvimJavaConfig.lua.
		-- Use :lua require("jdtls").update_projects_config() (or <leader>ju) to
		-- make jdtls pick up new pom.xml / build.gradle changes.
		"mfussenegger/nvim-jdtls",
		ft = "java",
		dependencies = {
			"mfussenegger/nvim-dap",
		},
	},
}
