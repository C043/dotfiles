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

local debug_enabled = vim.env.NVIM_JDTLS_DEBUG == "1"
local function dbg(msg)
  if debug_enabled then
    vim.notify("nvim-jdtls: " .. msg)
  end
end

local function notify_err(msg)
  vim.notify("nvim-jdtls: " .. msg, vim.log.levels.ERROR)
end

local function mason_jdtls_paths()
  local data = vim.fn.stdpath("data")
  local jdtls_root = data .. "/mason/packages/jdtls"
  local launcher = vim.fn.glob(jdtls_root .. "/plugins/org.eclipse.equinox.launcher_*.jar")
  if launcher == "" then
    vim.notify("nvim-jdtls: Mason jdtls launcher not found. Is 'jdtls' installed?", vim.log.levels.ERROR)
    return nil, nil
  end
  local config_dir = jdtls_root .. "/" .. get_os_config_dir()
  return launcher, config_dir
end

local function find_root()
  local root = vim.fs.root(0, { "gradlew", "mvnw", "build.gradle", "settings.gradle", "build.gradle.kts", "pom.xml", ".git" })
  if root and #root > 0 then
    return root
  end
  -- Fallback to directory of current file if no markers
  local fname = vim.api.nvim_buf_get_name(0)
  if fname and #fname > 0 then
    return vim.fs.dirname(fname)
  end
  return nil
end

local function workspace_dir(root)
  local home = vim.fn.expand("~")
  local project = vim.fn.fnamemodify(root, ":p:t")
  return string.format("%s/.local/share/eclipse/%s", home, project)
end

local function java_bin()
  local forced = "/opt/jdk-21.0.4+7/bin/java"
  if vim.fn.executable(forced) == 1 then
    return forced
  end
  local path = vim.fn.exepath("java")
  if path ~= nil and #path > 0 then
    return path
  end
  return forced -- last resort
end

local function make_cmd(launcher, config_dir, ws)
  return {
    java_bin(),
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
  -- Ensure nvim-jdtls is loaded
  local ok, jdtls = pcall(require, "jdtls")
  if not ok then
    pcall(function()
      require("lazy").load({ plugins = { "mfussenegger/nvim-jdtls" } })
    end)
    ok, jdtls = pcall(require, "jdtls")
    if not ok then
      notify_err("plugin not available. Ensure 'mfussenegger/nvim-jdtls' is installed and loaded.")
      return
    end
  end
  local root = find_root()
  dbg("resolved root: " .. tostring(root))
  if not root then
    notify_err("could not determine project root. Add .git, gradle/maven files, or open a *.java file inside a folder.")
    return
  end
  local launcher, config_dir = mason_jdtls_paths()
  dbg("launcher: " .. tostring(launcher))
  dbg("config_dir: " .. tostring(config_dir))
  if not launcher or not config_dir then
    notify_err("missing jdtls launcher or config directory under Mason. Try :Mason and install 'jdtls'.")
    return
  end
  local ws = workspace_dir(root)
  if vim.fn.isdirectory(ws) == 0 then
    pcall(vim.fn.mkdir, ws, "p")
  end
  dbg("workspace: " .. tostring(ws))
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
  dbg("java: " .. tostring(config.cmd and config.cmd[1]))
  local ok_start, err = pcall(function()
    require("jdtls").start_or_attach(config)
  end)
  if not ok_start then
    vim.notify("nvim-jdtls failed to start: " .. tostring(err), vim.log.levels.ERROR)
  end
end

-- Attach when the filetype is detected
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "java" },
  callback = on_java_file,
})

-- Also try on buffer enter for *.java (helps initial buffer on startup)
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  pattern = { "*.java" },
  callback = function()
    if vim.bo.filetype == "java" then
      on_java_file()
    end
  end,
})

-- If current buffer is already a java file (e.g. when starting nvim with a file), start/attach now
if vim.bo.filetype == "java" then
  vim.schedule(on_java_file)
end

-- Manual start command for debugging
vim.api.nvim_create_user_command("JdtlsStart", function()
  on_java_file()
end, { desc = "Start or attach nvim-jdtls for current buffer" })
