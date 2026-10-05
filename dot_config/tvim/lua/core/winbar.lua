-- Per-window file label, shown only while the tab page has two or more
-- normal windows, so splits are easy to tell apart without wasting a line
-- in the single-window case.
local M = {}

local skip_filetypes = { NvimTree = true, toggleterm = true, DiffviewFiles = true, DiffviewFileHistory = true }

---@param win integer
---@return boolean
local function is_normal_window(win)
  if vim.api.nvim_win_get_config(win).relative ~= "" then
    return false -- floating
  end
  local buf = vim.api.nvim_win_get_buf(win)
  return not skip_filetypes[vim.bo[buf].filetype] and vim.bo[buf].buftype == ""
end

local function define_highlights()
  local p = require("core.theme").palette()
  vim.api.nvim_set_hl(0, "WinBarFile", { fg = p.fg, bg = p.blue, bold = true })
  vim.api.nvim_set_hl(0, "WinBarFileCap", { fg = p.blue, bg = "NONE" })
  vim.api.nvim_set_hl(0, "WinBarFileNC", { fg = p.text, bg = p.grey })
  vim.api.nvim_set_hl(0, "WinBarFileNCCap", { fg = p.grey, bg = "NONE" })
  vim.api.nvim_set_hl(0, "WinBar", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "WinBarNC", { bg = "NONE" })
end

local function refresh()
  local wins = vim.tbl_filter(is_normal_window, vim.api.nvim_tabpage_list_wins(0))
  local show = #wins > 1
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local value = ""
    if show and is_normal_window(win) then
      local active = win == vim.api.nvim_get_current_win()
      local hl = active and "WinBarFile" or "WinBarFileNC"
      value = ("%%#%sCap#\u{e0b6}%%#%s# %%f %%#%sCap#\u{e0b4}%%*"):format(hl, hl, hl)
    end
    if vim.wo[win].winbar ~= value then
      vim.wo[win].winbar = value
    end
  end
end

function M.setup()
  define_highlights()
  local group = vim.api.nvim_create_augroup("tvim_winbar", { clear = true })
  vim.api.nvim_create_autocmd({ "WinEnter", "WinNew", "WinClosed", "BufWinEnter", "FileType" }, {
    group = group,
    callback = function()
      vim.schedule(refresh)
    end,
  })
  vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = define_highlights })
end

return M
