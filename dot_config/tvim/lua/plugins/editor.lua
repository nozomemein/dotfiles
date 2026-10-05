---@type LazySpec
return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
    opts = function()
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
          -- flex: side-by-side preview on wide windows, preview below the
          -- results on narrow ones instead of dropping the preview entirely
          layout_strategy = "flex",
          layout_config = {
            width = 0.9,
            height = 0.85,
            horizontal = {
              prompt_position = "top",
              preview_width = 0.55,
            },
            vertical = {
              prompt_position = "top",
              mirror = true,
              preview_height = 0.5,
            },
            flex = { flip_columns = 140 },
          },
          mappings = {
            n = { ["q"] = require("telescope.actions").close },
          },
          -- build output and vendored deps (patterns are Lua patterns on the relative path)
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
    end,
  },

  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFocus" },
    opts = {
      filters = { dotfiles = false },
      disable_netrw = true,
      hijack_cursor = true,
      sync_root_with_cwd = true,
      update_focused_file = {
        enable = true,
        update_root = false,
      },
      view = {
        side = "right",
        width = 30,
        preserve_window_proportions = true,
      },
      actions = {
        open_file = {
          window_picker = {
            enable = true,
            -- with splits, always open in the left-most (then top-most) editor
            -- window instead of asking which one
            picker = function()
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
              return best or -1 -- -1: let nvim-tree fall back to its own target window
            end,
          },
        },
      },
      renderer = {
        root_folder_label = false,
        highlight_git = true,
        indent_markers = { enable = true },
        icons = {
          glyphs = {
            default = "󰈚",
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
    },
  },

  {
    "akinsho/toggleterm.nvim",
    cmd = { "ToggleTerm", "TermExec" },
    opts = {
      size = function(term)
        if term.direction == "horizontal" then
          return math.floor(vim.o.lines * 0.3)
        elseif term.direction == "vertical" then
          return math.floor(vim.o.columns * 0.3)
        end
      end,
      start_in_insert = true,
      float_opts = { border = "single" },
    },
  },

  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      signs = {
        delete = { text = "󰍵" },
        changedelete = { text = "󱕖" },
      },
      current_line_blame = true,
    },
  },

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      fast_wrap = {},
      disable_filetype = { "TelescopePrompt", "vim" },
    },
  },

  {
    "kylechui/nvim-surround",
    lazy = false,
    opts = {},
  },

  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    lazy = false,
    opts = {
      provider_selector = function()
        return { "treesitter", "indent" }
      end,
    },
  },

  { "monaqa/dial.nvim" },

  {
    "Wansmer/treesj",
    cmd = { "TSJToggle", "TSJSplit", "TSJJoin" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = { use_default_keymaps = false },
  },

  {
    "bronson/vim-trailing-whitespace",
    lazy = false,
    init = function()
      -- completion popups pad entries with spaces; don't paint them red
      vim.g.extra_whitespace_ignored_filetypes = {
        "blink-cmp-menu",
        "blink-cmp-documentation",
        "blink-cmp-signature",
        "TelescopePrompt",
        "TelescopeResults",
        "lazy",
        "mason",
        "toggleterm",
      }
    end,
  },
}
