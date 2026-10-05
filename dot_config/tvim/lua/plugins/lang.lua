return {
  { "slim-template/vim-slim", ft = "slim" },
  { "tpope/vim-rails", ft = { "ruby", "eruby", "slim", "haml", "yaml" } },
  { "noprompt/vim-yardoc", ft = "ruby" },
  { "qnighy/lalrpop.vim", ft = "lalrpop" },

  {
    "akinsho/flutter-tools.nvim",
    ft = "dart",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim",
    },
    opts = {
      fvm = true, -- uses <workspace>/.fvm/flutter_sdk
      root_patterns = { ".git", "pubspec.yaml" },
    },
  },

  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    -- yarn is not installed; the plugin can download a prebuilt server instead
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
  },
}
