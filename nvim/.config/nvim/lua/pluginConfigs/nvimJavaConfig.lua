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

-- Only surface a given error once per session, otherwise every buffer switch
-- turns into a wall of identical notifications.
local notified = {}
local function notify_err(msg)
  if notified[msg] then
    return
  end
  notified[msg] = true
  vim.notify("nvim-jdtls: " .. msg, vim.log.levels.ERROR)
end

local mason_dir = vim.fn.stdpath("data") .. "/mason/packages"

local function mason_jdtls_paths()
  local jdtls_root = mason_dir .. "/jdtls"
  local launcher = vim.fn.glob(jdtls_root .. "/plugins/org.eclipse.equinox.launcher_*.jar")
  if launcher == "" then
    notify_err("Mason jdtls launcher not found. Run :Mason and install 'jdtls'.")
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

-- Resolve the JVM used to run the language server itself.
-- Order: $JDTLS_JAVA_HOME, $JAVA_HOME, `java` on $PATH.
local function java_bin()
  for _, home in ipairs({ vim.env.JDTLS_JAVA_HOME, vim.env.JAVA_HOME }) do
    if home and #home > 0 and vim.fn.executable(home .. "/bin/java") == 1 then
      return home .. "/bin/java"
    end
  end
  local path = vim.fn.exepath("java")
  if path ~= nil and #path > 0 then
    return path
  end
  return nil
end

-- JAVA_HOME of the `java` binary above, following symlinks (nix profiles, alternatives, ...).
local function java_home(bin)
  local real = vim.fn.resolve(bin)
  return vim.fn.fnamemodify(real, ":h:h")
end

local function make_cmd(java, launcher, config_dir, ws)
  local cmd = {
    java,
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-Dsun.zip.disableMemoryMapping=true",
    "-XX:+UseParallelGC",
    "-XX:GCTimeRatio=4",
    "-XX:AdaptiveSizePolicyWeight=90",
    "-Xms100m",
    "-Xmx2g",
    "--add-modules=ALL-SYSTEM",
    "--add-opens", "java.base/java.util=ALL-UNNAMED",
    "--add-opens", "java.base/java.lang=ALL-UNNAMED",
  }

  local lombok = mason_dir .. "/jdtls/lombok.jar"
  if vim.fn.filereadable(lombok) == 1 then
    table.insert(cmd, "-javaagent:" .. lombok)
  end

  vim.list_extend(cmd, {
    "-jar", launcher,
    "-configuration", config_dir,
    "-data", ws,
  })
  return cmd
end

-- Debugger (java-debug-adapter) and test runner (java-test) plugin jars, if installed.
local function bundles()
  local jars = {}
  local debug_jar = vim.fn.glob(
    mason_dir .. "/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar",
    true,
    true
  )
  vim.list_extend(jars, debug_jar)
  local test_jars = vim.fn.glob(mason_dir .. "/java-test/extension/server/*.jar", true, true)
  for _, jar in ipairs(test_jars) do
    -- These two are shipped for the VS Code runtime and break jdtls if loaded.
    if not jar:match("com%.microsoft%.java%.test%.runner%-jar%-with%-dependencies%.jar$")
      and not jar:match("jacoco.*%.jar$") then
      table.insert(jars, jar)
    end
  end
  return jars
end

local function capabilities()
  local caps = vim.lsp.protocol.make_client_capabilities()
  local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
  if ok then
    caps = vim.tbl_deep_extend("force", caps, cmp_lsp.default_capabilities())
  end
  return caps
end

local function on_attach(_, bufnr)
  local jdtls = require("jdtls")
  local map = function(keys, func, desc, mode)
    vim.keymap.set(mode or "n", keys, func, { buffer = bufnr, desc = "Java: " .. desc })
  end

  map("<leader>jo", jdtls.organize_imports, "[O]rganize imports")
  map("<leader>jv", jdtls.extract_variable, "Extract [v]ariable")
  map("<leader>jv", function()
    jdtls.extract_variable(true)
  end, "Extract [v]ariable", "v")
  map("<leader>jc", jdtls.extract_constant, "Extract [c]onstant")
  map("<leader>jc", function()
    jdtls.extract_constant(true)
  end, "Extract [c]onstant", "v")
  map("<leader>jm", function()
    jdtls.extract_method(true)
  end, "Extract [m]ethod", "v")
  map("<leader>jt", jdtls.test_nearest_method, "[T]est nearest method")
  map("<leader>jT", jdtls.test_class, "[T]est class")
  map("<leader>ju", function()
    jdtls.update_projects_config()
  end, "[U]pdate project config")

  -- Debug adapter + test runner, only when the bundles are present.
  if #bundles() > 0 then
    pcall(jdtls.setup_dap, { hotcodereplace = "auto", config_overrides = {} })
    pcall(function()
      require("jdtls.dap").setup_dap_main_class_configs()
    end)
  end
end

local function on_java_file()
  -- Ensure nvim-jdtls is loaded
  local ok, jdtls = pcall(require, "jdtls")
  if not ok then
    pcall(function()
      require("lazy").load({ plugins = { "nvim-jdtls" } })
    end)
    ok, jdtls = pcall(require, "jdtls")
    if not ok then
      notify_err("plugin not available. Ensure 'mfussenegger/nvim-jdtls' is installed and loaded.")
      return
    end
  end

  local java = java_bin()
  if not java then
    notify_err("no 'java' executable found. Install a JDK 21+ (NixOS: add `jdk21` to packages.nix and rebuild) or set $JAVA_HOME.")
    return
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
    return
  end

  local ws = workspace_dir(root)
  if vim.fn.isdirectory(ws) == 0 then
    pcall(vim.fn.mkdir, ws, "p")
  end
  dbg("workspace: " .. tostring(ws))

  local home = java_home(java)
  dbg("java: " .. java .. " (home: " .. home .. ")")

  local config = {
    cmd = make_cmd(java, launcher, config_dir, ws),
    root_dir = root,
    capabilities = capabilities(),
    on_attach = on_attach,
    init_options = {
      bundles = bundles(),
      extendedClientCapabilities = vim.tbl_deep_extend(
        "force",
        jdtls.extendedClientCapabilities or {},
        { resolveAdditionalTextEditsSupport = true, progressReportProvider = false }
      ),
    },
    settings = {
      java = {
        eclipse = { downloadSources = true },
        maven = { downloadSources = true },
        signatureHelp = { enabled = true },
        contentProvider = { preferred = "fernflower" },
        implementationsCodeLens = { enabled = true },
        referencesCodeLens = { enabled = false },
        references = { includeDecompiledSources = true },
        inlayHints = { parameterNames = { enabled = "literals" } },
        format = { enabled = true },
        completion = {
          favoriteStaticMembers = {
            "org.junit.Assert.*",
            "org.junit.Assume.*",
            "org.junit.jupiter.api.Assertions.*",
            "org.junit.jupiter.api.Assumptions.*",
            "org.junit.jupiter.api.DynamicContainer.*",
            "org.junit.jupiter.api.DynamicTest.*",
            "org.mockito.Mockito.*",
            "org.mockito.ArgumentMatchers.*",
            "java.util.Objects.requireNonNull",
            "java.util.Objects.requireNonNullElse",
          },
          importOrder = { "java", "javax", "com", "org" },
        },
        sources = {
          organizeImports = {
            starThreshold = 9999,
            staticStarThreshold = 9999,
          },
        },
        codeGeneration = {
          toString = {
            template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
          },
          useBlocks = true,
          hashCodeEquals = { useJava7Objects = true },
        },
        configuration = {
          updateBuildConfiguration = "interactive",
          runtimes = {
            { name = "JavaSE-21", path = home, default = true },
          },
        },
      },
    },
  }

  local ok_start, err = pcall(function()
    require("jdtls").start_or_attach(config)
  end)
  if not ok_start then
    vim.notify("nvim-jdtls failed to start: " .. tostring(err), vim.log.levels.ERROR)
  end
end

-- Attach when the filetype is detected. `start_or_attach` already reuses a
-- running client for the same root, so one FileType autocmd is enough — no
-- BufEnter hook, which used to re-run (and re-warn) on every buffer switch.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("dotfiles-jdtls", { clear = true }),
  pattern = { "java" },
  callback = on_java_file,
})

-- If current buffer is already a java file (e.g. when starting nvim with a file), start/attach now
if vim.bo.filetype == "java" then
  vim.schedule(on_java_file)
end

-- Manual start command for debugging
vim.api.nvim_create_user_command("JdtlsStart", function()
  notified = {}
  on_java_file()
end, { desc = "Start or attach nvim-jdtls for current buffer" })
