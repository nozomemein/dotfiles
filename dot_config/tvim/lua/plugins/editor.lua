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
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.55,
            },
            width = 0.87,
            height = 0.80,
          },
          mappings = {
            n = { ["q"] = require("telescope.actions").close },
          },
          file_ignore_patterns = { "node_modules/", "vendor/" },
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
