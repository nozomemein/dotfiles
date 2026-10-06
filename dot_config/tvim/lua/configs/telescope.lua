return {
  defaults = {
    prompt_prefix = " \u{f002}  ",
    selection_caret = " ",
    entry_prefix = " ",
    sorting_strategy = "ascending",
    -- "filename_first" shows "init.lua  lua/lazy" instead of the full path,
    -- so long absolute paths no longer push the match text off screen
    path_display = { "filename_first" },
    dynamic_preview_title = true,
    -- flex: side-by-side preview on wide windows, preview below the results
    -- on narrow ones instead of dropping the preview entirely
    layout_strategy = "flex",
    layout_config = {
      width = 0.9,
      height = 0.85,
      horizontal = { prompt_position = "top", preview_width = 0.55 },
      vertical = { prompt_position = "top", mirror = true, preview_height = 0.5 },
      flex = { flip_columns = 140 },
    },
    mappings = {
      n = { ["q"] = require("telescope.actions").close },
    },
    -- build output and vendored deps (Lua patterns on the relative path)
    file_ignore_patterns = {
      "^%.git/",
      "node_modules/",
      "vendor/",
      "^target/", -- rust
      "^build/", -- flutter / gradle
      "%.dart_tool/",
      "%.fvm/",
    },
  },
  pickers = {
    -- LSP result lists: wider file column, keep the matched line visible
    lsp_references = { fname_width = 45, show_line = true },
    lsp_definitions = { fname_width = 45, show_line = true },
    lsp_implementations = { fname_width = 45, show_line = true },
    lsp_type_definitions = { fname_width = 45, show_line = true },
    diagnostics = { line_width = "full" },
  },
}
