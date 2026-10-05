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
  },
  {
    "leoluz/nvim-dap-go",
    ft = "go",
    dependencies = { "mfussenegger/nvim-dap" },
    opts = {},
  },
}
