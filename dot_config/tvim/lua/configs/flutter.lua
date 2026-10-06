-- flutter-tools.nvim options.
-- The plugin starts the Dart analysis server itself (do not enable dartls
-- elsewhere) and registers the "dart" DAP adapter with nvim-dap.

---@return string project root (directory holding pubspec.yaml), cwd as a fallback
local function project_root()
  return vim.fs.root(0, { "pubspec.yaml" }) or vim.fn.getcwd()
end

-- Launch configurations from the project's .vscode/launch.json (type "dart"),
-- so flavors and dart-defines set up for VS Code work here too.
---@param root string
---@param paths { dart_sdk?: string, flutter_sdk?: string }
---@return dap.Configuration[]
local function launch_json_configs(root, paths)
  local ok, configs = pcall(require("dap.ext.vscode").getconfigs, root .. "/.vscode/launch.json")
  if not ok then
    return {}
  end
  local result = {}
  for _, c in ipairs(configs) do
    if c.type == "dart" then
      local entry = vim.deepcopy(c)
      entry._from_launch_json = true -- marker used to replace, not duplicate, on re-register
      entry.cwd = entry.cwd or root
      entry.dartSdkPath = entry.dartSdkPath or paths.dart_sdk
      entry.flutterSdkPath = entry.flutterSdkPath or paths.flutter_sdk
      table.insert(result, entry)
    end
  end
  return result
end

-- :FlutterRun only offers dap.configurations.dart; merge launch.json into it.
-- Called by flutter-tools every time it (re)registers its own defaults.
-- When the project has launch.json entries, the plugin's own flavor-less
-- "Launch flutter" entry is dropped: on projects that require --flavor it only
-- builds and then fails to start, so it must not be offered (same as VS Code,
-- which shows launch.json entries only).
---@param paths { dart_sdk?: string, flutter_sdk?: string }
local function register_configurations(paths)
  local dap = require "dap"
  local from_launch_json = launch_json_configs(project_root(), paths)
  local configs = vim.tbl_filter(function(c)
    if c._from_launch_json then
      return false
    end
    local plugin_default_launch = c.request == "launch" and c.name == "Launch flutter"
    return not (plugin_default_launch and #from_launch_json > 0)
  end, dap.configurations.dart or {})
  vim.list_extend(configs, from_launch_json)
  dap.configurations.dart = configs
end

---@type table flutter-tools setup options
return {
  fvm = true, -- use <project>/.fvm/flutter_sdk (run `fvm install` once per clone)
  root_patterns = { ".git", "pubspec.yaml" },
  ui = { border = "single" },
  decorations = {
    statusline = { device = true, project_config = true }, -- shown by lualine (configs/lualine.lua)
  },
  widget_guides = { enabled = true },
  closing_tags = { highlight = "Comment", prefix = "// " },
  dev_log = {
    enabled = true,
    open_cmd = "15split",
    focus_on_open = false,
  },
  debugger = {
    enabled = true, -- :FlutterRun goes through nvim-dap; F5 / <leader>b etc. apply
    exception_breakpoints = {},
    evaluate_to_string_in_debug_views = true,
    register_configurations = register_configurations,
  },
  lsp = {
    ---@param config lsp.ClientCapabilities
    capabilities = function(config)
      return require("blink.cmp").get_lsp_capabilities(config)
    end,
    settings = {
      showTodos = true,
      completeFunctionCalls = true,
      renameFilesWithClasses = "prompt",
      enableSnippets = true,
      updateImportsOnRename = true,
    },
  },
}
