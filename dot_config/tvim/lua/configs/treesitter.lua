local M = {}

-- Parsers bundled with Neovim (c, lua, vim, vimdoc, query, markdown) are omitted.
---@type string[]
M.languages = {
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

function M.setup()
  -- idempotent: already-installed parsers are skipped
  require("nvim-treesitter").install(M.languages)

  -- the main branch does not enable highlighting by itself
  vim.api.nvim_create_autocmd("FileType", {
    callback = function(args)
      pcall(vim.treesitter.start, args.buf)
    end,
  })
end

return M
