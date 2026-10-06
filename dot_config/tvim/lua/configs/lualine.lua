-- lualine "bubbles" layout: every component is its own rounded pill drawn on
-- the editor background. Pill colors come from the theme's mode colors
-- (core/theme.lua palette()) so switching themes keeps the look consistent.
local T = require "core.theme"
local theme = vim.deepcopy(require("lualine.themes." .. T.lualine()))
local palette = T.palette()

---@param bg string
---@param gui? string
---@return { fg: string, bg: string, gui: string }
local function pill(bg, gui)
  return { fg = palette.fg, bg = bg, gui = gui or "bold" }
end

-- make b / c transparent so the gaps between pills show the editor bg
for _, mode in pairs(theme) do
  for _, section in ipairs { "b", "c" } do
    if mode[section] then
      mode[section] = vim.tbl_extend("force", mode[section], { bg = "NONE" })
    end
  end
end

-- rounded caps (Nerd Font U+E0B6 / U+E0B4)
local caps = { left = "\u{e0b6}", right = "\u{e0b4}" }

-- lualine paints a cap over the neighbouring component's background, so a
-- transparent spacer between pills is what produces a real gap
local gap = {
  function()
    return " "
  end,
  padding = 0,
  separator = "",
  color = { bg = "NONE" },
}

-- Device the Flutter app is running on. flutter-tools fills
-- vim.g.flutter_tools_decorations.device while an app runs
-- (decorations.statusline.device = true in configs/flutter.lua). Returning ""
-- makes lualine skip the component, so this pill only shows during a session.
local flutter_device = {
  function()
    local d = vim.g.flutter_tools_decorations
    return d and d.device or ""
  end,
  separator = caps,
  color = pill(palette.green),
}

return {
  options = {
    theme = theme,
    globalstatus = true,
    component_separators = "",
    section_separators = "",
  },
  -- left: mode / branch / file   right: diagnostics / flutter device / LSP / filetype / position
  sections = {
    lualine_a = { { "mode", separator = caps } },
    lualine_b = {
      gap,
      { "branch", separator = caps, color = pill(palette.green) },
      gap,
      { "filename", path = 1, separator = caps, color = pill(palette.blue) },
    },
    lualine_c = {},
    lualine_x = {
      { "diagnostics", separator = caps, color = { bg = palette.grey } },
      gap,
      flutter_device,
      gap,
      { "lsp_status", separator = caps, color = pill(palette.purple) },
      gap,
    },
    lualine_y = {
      { "filetype", separator = caps, color = { fg = palette.text, bg = palette.grey, gui = "italic" } },
      gap,
    },
    lualine_z = { { "location", separator = caps, color = pill(palette.yellow) } },
  },
  inactive_sections = {
    lualine_a = { { "filename", path = 1, separator = caps } },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = { { "location", separator = caps } },
  },
}
