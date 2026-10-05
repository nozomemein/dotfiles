-- Colorscheme single source of truth.
-- To switch themes, change `M.current` below (then :Lazy sync once).
-- Everything else (plugin spec, lualine theme, lazy install colorscheme,
-- transparency toggle) is derived from the entry in `M.themes`.
local M = {}

M.current = "bamboo"
M.transparent = true

-- Each entry: plugin repo, the :colorscheme name, the lualine theme name,
-- and a setup(transparent) function that configures the plugin.
M.themes = {
  tokyonight = {
    plugin = "folke/tokyonight.nvim",
    colorscheme = "tokyonight",
    lualine = "tokyonight",
    setup = function(transparent)
      require("tokyonight").setup {
        style = "night",
        transparent = transparent,
        styles = {
          comments = { italic = true },
          sidebars = transparent and "transparent" or "dark",
          -- keep floats opaque so popups (completion menu, docs) stay readable
          floats = "dark",
        },
        on_highlights = function(hl, c)
          -- make the selected completion item stand out
          hl.BlinkCmpMenuSelection = { bg = c.bg_visual, bold = true }
          hl.TelescopePreviewLine = { fg = c.bg, bg = c.blue, bold = true }
          -- Diff highlight overrides (diffview)
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
    end,
  },

  bamboo = {
    plugin = "ribru17/bamboo.nvim",
    colorscheme = "bamboo",
    lualine = "bamboo",
    setup = function(transparent)
      require("bamboo").setup {
        style = "vulgaris",
        transparent = transparent,
        dim_inactive = false,
        code_style = {
          comments = { italic = true },
          conditionals = {},
          namespaces = {},
          parameters = {},
        },
        lualine = { transparent = transparent },
        highlights = {
          -- keep popups opaque even when the editor background is transparent
          NormalFloat = { fg = "$fg", bg = "$bg1" },
          -- make the selected completion item stand out
          BlinkCmpMenuSelection = { fg = "$bg0", bg = "$bg_blue", fmt = "bold" },
          -- the line a grep hit points to in the Telescope previewer
          TelescopePreviewLine = { fg = "$bg0", bg = "$bg_blue", fmt = "bold" },
        },
      }
    end,
  },

  material = {
    plugin = "marko-cerovac/material.nvim",
    colorscheme = "material",
    lualine = "material-nvim",
    setup = function(transparent)
      vim.g.material_style = "deep ocean"
      require("material").setup {
        styles = { comments = { italic = true } },
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
        disable = { background = transparent },
        custom_highlights = {
          BlinkCmpMenuSelection = { bg = "#283457", bold = true },
          TelescopePreviewLine = { fg = "#0f111a", bg = "#82aaff", bold = true },
        },
      }
    end,
  },
}

local function theme()
  return assert(M.themes[M.current], "unknown theme: " .. tostring(M.current))
end

-- lazy.nvim plugin spec for the active theme (used by plugins/ui.lua)
function M.spec()
  return {
    theme().plugin,
    lazy = false,
    priority = 1000,
    config = M.apply,
  }
end

function M.colorscheme()
  return theme().colorscheme
end

function M.lualine()
  return theme().lualine
end

function M.apply()
  local t = theme()
  t.setup(M.transparent)
  vim.cmd.colorscheme(t.colorscheme)
end

function M.toggle_transparency()
  M.transparent = not M.transparent
  M.apply()
end

return M
