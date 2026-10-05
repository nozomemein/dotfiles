-- material.nvim setup with a runtime transparency toggle.
local M = {}

-- Diff highlight overrides (diffview)
local colors = {
  blue = "#7aa2f7",
  green = "#9ece6a",
  red = "#f7768e",
  purple = "#bb9af7",
  background = "#24283b",
}

M.transparent = true

local function opts()
  return {
    contrast = {
      terminal = false,
      sidebars = false,
      floating_windows = false,
    },
    styles = {
      comments = { italic = true },
    },
    plugins = {
      "blink",
      "dap",
      "gitsigns",
      "indent-blankline",
      "neotest",
      "nvim-tree",
      "nvim-web-devicons",
      "telescope",
      "which-key",
    },
    disable = {
      background = M.transparent,
    },
    custom_highlights = {
      DiffAdd = { fg = colors.purple, bg = colors.background },
      DiffChange = { fg = colors.purple, bg = colors.background },
      DiffDelete = { fg = colors.purple, bg = colors.background },
      DiffText = { fg = colors.purple, bg = colors.background },
      DiffAdded = { fg = colors.purple, bg = colors.background },
      DiffRemoved = { fg = colors.purple, bg = colors.background },
      DiffFile = { fg = colors.blue, bg = colors.background },
      DiffNewFile = { fg = colors.green, bg = colors.background },
      DiffOldFile = { fg = colors.red, bg = colors.background },
    },
  }
end

function M.apply()
  vim.g.material_style = "deep ocean"
  require("material").setup(opts())
  vim.cmd.colorscheme "material"
end

function M.toggle_transparency()
  M.transparent = not M.transparent
  M.apply()
end

return M
