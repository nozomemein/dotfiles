-- tokyonight setup with a runtime transparency toggle.
local M = {}

M.transparent = true

local function opts()
  return {
    style = "night",
    transparent = M.transparent,
    styles = {
      comments = { italic = true },
      sidebars = M.transparent and "transparent" or "dark",
      -- keep floats opaque so popups (completion menu, docs) stay readable
      floats = "dark",
    },
    -- Diff highlight overrides (diffview)
    on_highlights = function(hl, c)
      -- make the selected completion item stand out
      hl.BlinkCmpMenuSelection = { bg = c.bg_visual, bold = true }
      hl.DiffAdd = { fg = c.purple, bg = c.bg_highlight }
      hl.DiffChange = { fg = c.purple, bg = c.bg_highlight }
      hl.DiffDelete = { fg = c.purple, bg = c.bg_highlight }
      hl.DiffText = { fg = c.purple, bg = c.bg_highlight }
      hl.DiffAdded = { fg = c.purple, bg = c.bg_highlight }
      hl.DiffRemoved = { fg = c.purple, bg = c.bg_highlight }
      hl.DiffFile = { fg = c.blue, bg = c.bg_highlight }
      hl.DiffNewFile = { fg = c.green, bg = c.bg_highlight }
      hl.DiffOldFile = { fg = c.red, bg = c.bg_highlight }
    end,
  }
end

function M.apply()
  require("tokyonight").setup(opts())
  vim.cmd.colorscheme "tokyonight"
end

function M.toggle_transparency()
  M.transparent = not M.transparent
  M.apply()
end

return M
