local M = {}

-- RSpec adapter: runs inside the app container
---@return neotest.Adapter
local function rspec_adapter()
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

function M.setup()
  -- neotest annotates every config field as required
  ---@diagnostic disable-next-line: missing-fields
  require("neotest").setup {
    adapters = {
      rspec_adapter(),
      require "neotest-golang",
    },
  }
end

return M
