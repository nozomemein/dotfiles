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
      require("configs.neotest").setup()
    end,
  },

  {
    "mogulla3/rspec.nvim",
    cmd = { "RSpecNearest", "RSpecCurrentFile", "RSpecRerun", "RSpecOnlyFailures", "RSpecShowLastResult" },
    opts = { open_quickfix_when_spec_failed = true },
  },
}
