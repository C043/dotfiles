local dap = require("dap")

dap.adapters["pwa-node"] = {
	type = "server",
	host = "localhost",
	port = "${port}",
	executable = {
		command = "node",
		args = {
			require("mason-registry").get_package("js-debug-adapter"):get_install_path()
				.. "/js-debug/src/dapDebugServer.js",
			"${port}",
		},
	},
}

dap.configurations.javascript = {
	{
		type = "pwa-node",
		request = "launch",
		name = "Launch File",
		program = "${file}",
		cwd = vim.fn.getcwd(),
		sourceMaps = true,
		protocol = "inspector",
		console = "integratedTerminal",
	},
	{
		type = "pwa-node",
		request = "attach",
		name = "Attach to Process",
		processId = require("dap.utils").pick_process,
		cwd = vim.fn.getcwd(),
	},
}
