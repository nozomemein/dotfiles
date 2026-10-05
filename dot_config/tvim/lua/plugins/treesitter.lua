-- Parsers bundled with Neovim (c, lua, vim, vimdoc, query, markdown) are omitted.
local languages = {
  "luadoc",
  "typescript",
  "tsx", -- .tsx needs its own parser; .jsx is covered by javascript
  "javascript",
  "json",
  "html",
  "css",
  "scss",
  "ruby",
  "go",
  "terraform",
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
