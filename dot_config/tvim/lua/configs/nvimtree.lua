-- With splits, open files in the left-most (then top-most) editor window
-- instead of asking which one. Returns -1 when there is no candidate so
-- nvim-tree falls back to its own target window.
---@return integer
local function leftmost_window()
  local best, best_pos
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    local floating = vim.api.nvim_win_get_config(win).relative ~= ""
    if not floating and vim.bo[buf].buftype == "" and vim.bo[buf].filetype ~= "NvimTree" then
      local row, col = unpack(vim.api.nvim_win_get_position(win))
      if not best_pos or col < best_pos[2] or (col == best_pos[2] and row < best_pos[1]) then
        best, best_pos = win, { row, col }
      end
    end
  end
  return best or -1
end

return {
  filters = { dotfiles = false },
  disable_netrw = true,
  hijack_cursor = true,
  sync_root_with_cwd = true,
  update_focused_file = { enable = true, update_root = false },
  view = {
    side = "right",
    width = 30,
    preserve_window_proportions = true,
  },
  actions = {
    open_file = {
      window_picker = { enable = true, picker = leftmost_window },
    },
  },
  renderer = {
    root_folder_label = false,
    highlight_git = true,
    indent_markers = { enable = true },
    icons = {
      glyphs = {
        default = "\u{f021a}",
        folder = {
          default = "\u{e6ad}",
          empty = "\u{ea83}",
          empty_open = "\u{ebdf}",
          open = "\u{eaf6}",
          symlink = "\u{eaed}",
        },
        git = { unmerged = "\u{eafe}" },
      },
    },
  },
}
