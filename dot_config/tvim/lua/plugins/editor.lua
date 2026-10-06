---@type LazySpec
return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
    opts = function()
      return require "configs.telescope"
    end,
  },

  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFocus" },
    opts = function()
      return require "configs.nvimtree"
    end,
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
        delete = { text = "\u{f0375}" },
        changedelete = { text = "\u{f1556}" },
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

  { "kylechui/nvim-surround", lazy = false, opts = {} },

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
