-- RSpec adapter: runs inside the app container
---@return neotest.Adapter
local function get_rspec_adapter()
  return require "neotest-rspec" {
    rspec_cmd = function()
      return {
        "docker", "compose", "exec", "-i",
        "-w", "/myapp",
        "-e", "RAILS_ENV=test",
        "puma",
        "bundle", "exec", "rspec",
      }
    end,
    transform_spec_path = function(path)
      local prefix = require("neotest-rspec").root(path)
      return string.sub(path, string.len(prefix) + 2, -1)
    end,
    results_path = "tmp/rspec.output",
  }
end

---@type LazySpec
return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      { "olimorris/neotest-rspec", commit = "53fc108a06ae43d7f873d42ee5189c2301e33623" },
      { "fredrikaverpil/neotest-golang", version = "*" },
    },
    config = function()
      -- neotest annotates every config field as required
      ---@diagnostic disable-next-line: missing-fields
      require("neotest").setup {
        adapters = {
          get_rspec_adapter(),
          require "neotest-golang",
        },
      }
    end,
  },

  {
    "mogulla3/rspec.nvim",
    cmd = { "RSpecNearest", "RSpecCurrentFile", "RSpecRerun", "RSpecOnlyFailures", "RSpecShowLastResult" },
    opts = {
      open_quickfix_when_spec_failed = true,
    },
  },
}
