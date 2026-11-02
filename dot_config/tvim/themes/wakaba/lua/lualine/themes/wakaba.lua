-- lualine theme for Wakaba. core/theme.lua palette() reads the mode colors
-- from here (normal.a.bg = green, insert = blue, visual = purple,
-- replace = red, command = yellow, normal.b.bg = grey), so keep that shape.
local p = require("wakaba").palette

local a_fg = p.bg
local b = { fg = p.text, bg = p.selected }
local c = { fg = p.muted, bg = p.bg }

return {
  normal = { a = { fg = a_fg, bg = p.accent, gui = "bold" }, b = b, c = c },
  insert = { a = { fg = a_fg, bg = p.keyword, gui = "bold" }, b = b, c = c },
  visual = { a = { fg = a_fg, bg = p.constant, gui = "bold" }, b = b, c = c },
  replace = { a = { fg = a_fg, bg = p.error, gui = "bold" }, b = b, c = c },
  command = { a = { fg = a_fg, bg = p.string, gui = "bold" }, b = b, c = c },
  terminal = { a = { fg = a_fg, bg = p.type, gui = "bold" }, b = b, c = c },
  inactive = {
    a = { fg = p.muted, bg = p.surface },
    b = { fg = p.muted, bg = p.surface },
    c = { fg = p.placeholder, bg = p.bg },
  },
}
