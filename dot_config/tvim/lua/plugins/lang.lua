---@type LazySpec
return {
  { "qnighy/lalrpop.vim", ft = "lalrpop" },

  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    -- The prebuilt server binary is x86_64 only and this Mac has no Rosetta,
    -- so install the node dependencies instead (npm comes with node via asdf).
    build = "cd app && npm install --no-audit --no-fund",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
  },
}
