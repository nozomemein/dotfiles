-- flutter-tools starts the Dart analysis server itself (do not enable dartls
-- elsewhere) and registers the "dart" DAP adapter with nvim-dap.
---@type LazySpec
return {
  {
    "nvim-flutter/flutter-tools.nvim",
    ft = "dart",
    cmd = { "FlutterRun", "FlutterDevices", "FlutterEmulators", "FlutterPubGet", "FlutterLspRestart" },
    dependencies = { "nvim-lua/plenary.nvim", "mfussenegger/nvim-dap" },
    opts = function()
      return require "configs.flutter"
    end,
  },
}
