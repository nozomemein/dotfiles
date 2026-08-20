-- see nvim-lspconfig for more info on server configurations
-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
return {
  "williamboman/mason-lspconfig.nvim",
  config = function()
    require("mason-lspconfig").setup {
      ensure_installed = {
        "lua_ls",
        "solargraph",
        "tailwindcss",
        "ts_ls",
        "gopls",
        "terraformls",
        "rust_analyzer",
      },
    }
  end,
}
