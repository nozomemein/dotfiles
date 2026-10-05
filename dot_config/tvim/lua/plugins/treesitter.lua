local languages = {
  "vim",
  "vimdoc",
  "lua",
  "luadoc",
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
  "graphql",
}

---@type LazySpec
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install(languages)

      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end,
  },
}
