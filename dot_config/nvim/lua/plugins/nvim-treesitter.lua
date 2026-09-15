return {
  "nvim-treesitter/nvim-treesitter",
  -- Pin to master: NvChad's config uses nvim-treesitter.configs (master API).
  -- The main branch is a rewrite that drops that module; switch only once NvChad supports it.
  branch = "master",
  opts = {
    ensure_installed = {
      "vim",
      "lua",
      "typescript",
      "javascript",
      "json",
      "html",
      "css",
      "scss",
      "ruby",
      "go",
      "terraform",
      "c",
      "dart",
      "graphql"
    }
  }
}
