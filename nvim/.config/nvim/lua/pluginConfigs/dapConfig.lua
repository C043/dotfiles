local dap = require("dap")

-- Resolve js-debug adapter path without requiring mason at startup.
-- This avoids errors when mason isn't loaded yet during init.
local function js_debug_path()
    -- Prefer mason-registry if available
    local ok_registry, registry = pcall(require, "mason-registry")
    if ok_registry then
        local ok_pkg, pkg = pcall(registry.get_package, "js-debug-adapter")
        if ok_pkg and pkg and pkg.get_install_path then
            local ok_install, install_path = pcall(function()
                return pkg:get_install_path()
            end)
            if ok_install and install_path then
                return install_path .. "/js-debug/src/dapDebugServer.js"
            end
        end
    end
    -- Fallback to default mason package location
    local fallback = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js"
    return fallback
end

dap.adapters["pwa-node"] = {
    type = "server",
    host = "localhost",
    port = "${port}",
    executable = {
        command = "node",
        args = { js_debug_path(), "${port}" },
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
