---@type LazySpec
return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "saghen/blink.cmp" },
    config = function()
      require("configs.lsp").setup()
    end,
  },

  {
    "mason-org/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate" },
    opts = {
      PATH = "skip", -- PATH is prepended in core/options.lua
      ui = {
        icons = {
          package_pending = "\u{f019} ",
          package_installed = "\u{f058} ",
          package_uninstalled = "\u{f192} ",
        },
      },
      max_concurrent_installers = 10,
    },
  },

  {
    "mason-org/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
    opts = {
      ensure_installed = {
        "lua_ls",
        "solargraph",
        "tailwindcss",
        "ts_ls",
        "gopls",
        "terraformls",
        "rust_analyzer",
      },
    },
  },

  {
    "stevearc/conform.nvim",
    cmd = "ConformInfo",
    opts = function()
      return require "configs.conform"
    end,
  },
}
