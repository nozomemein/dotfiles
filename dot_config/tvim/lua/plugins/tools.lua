return {
  {
    "mgierada/lazydocker.nvim",
    cmd = "Lazydocker",
    dependencies = { "akinsho/toggleterm.nvim" },
    opts = {},
  },

  {
    "LintaoAmons/bookmarks.nvim",
    tag = "3.2.0",
    event = "VeryLazy",
    dependencies = {
      "kkharji/sqlite.lua",
      "nvim-telescope/telescope.nvim",
    },
    opts = {},
  },
}
