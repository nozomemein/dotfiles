---@type LazySpec
return {
  {
    "mfussenegger/nvim-dap",
    -- loaded on the first require("dap") from the keymaps in core/mappings.lua
    dependencies = {
      "nvim-neotest/nvim-nio",
      { "rcarriga/nvim-dap-ui", opts = {} },
      { "theHamsta/nvim-dap-virtual-text", opts = {} },
    },
    config = function()
      -- Why: nvim-dap reads .vscode/launch.json through dap.ext.vscode.json_decode,
      -- which defaults to vim.json.decode. That parser skips comments but rejects
      -- a trailing comma before "]" or "}", and VS Code tolerates those, so
      -- launch.json files written for VS Code (e.g. driver_app) fail to load.
      -- Swapping the decoder here fixes it for every language, not just Dart.
      local vscode = require "dap.ext.vscode"
      ---@param str string
      ---@param opts? table
      ---@diagnostic disable-next-line: duplicate-set-field -- intentional override
      vscode.json_decode = function(str, opts)
        -- drop "," that is directly followed by "]" or "}"; the extra parentheses
        -- discard gsub's second return value (the match count)
        return vim.json.decode((str:gsub(",%s*([%]}])", "%1")), opts)
      end
    end,
  },
  {
    "leoluz/nvim-dap-go",
    ft = "go",
    dependencies = { "mfussenegger/nvim-dap" },
    opts = {},
  },
}
