-- nvim-jdtls setup: start or attach when opening Java files
local jdtls = require("jdtls")

local function get_os_config_dir()
  local sys = vim.loop.os_uname().sysname
  if sys == "Darwin" then
    return "config_mac"
  elseif sys == "Linux" then
    return "config_linux"
  else
    error("Unsupported OS for jdtls: " .. sys)
  end
end

local function mason_jdtls_paths()
  local data = vim.fn.stdpath("data")
  local jdtls_root = data .. "/mason/packages/jdtls"
  local launcher = vim.fn.glob(jdtls_root .. "/plugins/org.eclipse.equinox.launcher_*.jar")
  if launcher == "" then
    error("Could not find equinox launcher jar under Mason jdtls. Install jdtls via :Mason.")
  end
  local config_dir = jdtls_root .. "/" .. get_os_config_dir()
  return launcher, config_dir
end

local function find_root()
  return vim.fs.root(0, { "gradlew", "mvnw", ".git" })
end

local function workspace_dir(root)
  local home = vim.fn.expand("~")
  local project = vim.fn.fnamemodify(root, ":p:h:t")
  return string.format("%s/.local/share/eclipse/%s", home, project)
end

local function make_cmd(launcher, config_dir, ws)
  return {
    "/opt/jdk-21.0.4+7/bin/java", -- use your Java 21 path
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-Xmx1g",
    "--add-modules=ALL-SYSTEM",
    "--add-opens", "java.base/java.util=ALL-UNNAMED",
    "--add-opens", "java.base/java.lang=ALL-UNNAMED",
    "-jar", launcher,
    "-configuration", config_dir,
    "-data", ws,
  }
end

local function on_java_file()
  local root = find_root()
  if not root then
    return
  end
  local launcher, config_dir = mason_jdtls_paths()
  local ws = workspace_dir(root)
  local config = {
    cmd = make_cmd(launcher, config_dir, ws),
    root_dir = root,
    settings = {
      java = {
        configuration = {
          runtimes = {
            { name = "JavaSE-21", path = "/opt/jdk-21.0.4+7", default = true },
          },
        },
      },
    },
  }
  jdtls.start_or_attach(config)
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "java" },
  callback = on_java_file,
})
