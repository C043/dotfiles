require("java").setup({})

local home = os.getenv("HOME")
local os_name = vim.loop.os_uname().sysname
local config_platform
if os_name == "Darwin" then
	config_platform = "config_mac"
elseif os_name == "Linux" then
	config_platform = "config_linux"
else
	error("Unsupported OS for jdtls: " .. os_name)
end
local workspace_dir = home .. "/.local/share/eclipse" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local config_path = home .. "/.local/share/nvim/mason/packages/jdtls/" .. config_platform
local launcher_jar =
	vim.fn.glob(home .. "/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher.jar")

if launcher_jar == "" then
	error("Could not find org.eclipse.equinox.launcher.jar")
end

require("lspconfig").jdtls.setup({
	cmd = {
		"/opt/jdk-21.0.4+7/bin/java", -- ✅ Force correct Java version here
		"-Declipse.application=org.eclipse.jdt.ls.core.id1",
		"-Dosgi.bundles.defaultStartLevel=4",
		"-Declipse.product=org.eclipse.jdt.ls.core.product",
		"-Dlog.protocol=true",
		"-Dlog.level=ALL",
		"-Xmx1g",
		"--add-modules=ALL-SYSTEM",
		"--add-opens",
		"java.base/java.util=ALL-UNNAMED",
		"--add-opens",
		"java.base/java.lang=ALL-UNNAMED",
		"-jar",
		launcher_jar,
		"-configuration",
		config_path,
		"-data",
		workspace_dir,
	},
	settings = {
		java = {
			configuration = {
				runtimes = {
					{
						name = "JavaSE-21",
						path = "/opt/jdk-21.0.4+7",
						default = true,
					},
				},
			},
		},
	},
})
