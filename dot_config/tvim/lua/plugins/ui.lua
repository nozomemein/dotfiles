return {
  -- colorscheme: see lua/core/theme.lua
  require("core.theme").spec(),

  {
    "nvim-tree/nvim-web-devicons",
    opts = {},
  },

  {
    "nvim-lualine/lualine.nvim",
    lazy = false,
    opts = function()
      -- "bubbles" layout: every component is its own rounded pill drawn on
      -- the editor background. Pill colors come from the theme's mode colors
      -- so switching themes keeps the look consistent.
      local theme = require("core.theme").lualine()
      if type(theme) == "string" then
        theme = vim.deepcopy(require("lualine.themes." .. theme))
      end

      local fg = theme.normal.a.fg
      local palette = {
        green = theme.normal.a.bg,
        blue = theme.insert.a.bg,
        purple = theme.visual.a.bg,
        red = theme.replace.a.bg,
        yellow = theme.command.a.bg,
        grey = theme.normal.b.bg,
      }
      local function pill(bg, gui)
        return { fg = fg, bg = bg, gui = gui or "bold" }
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
      -- lualine paints a cap over the neighbouring component's background, so
      -- put a transparent spacer between pills to get a real gap
      local gap = {
        function()
          return " "
        end,
        padding = 0,
        separator = "",
        color = { bg = "NONE" },
      }

      return {
        options = {
          theme = theme,
          globalstatus = true,
          component_separators = "",
          section_separators = "",
        },
        -- left: mode / branch / file   right: diagnostics / LSP / filetype / position
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
            { "lsp_status", separator = caps, color = pill(palette.purple) },
            gap,
          },
          lualine_y = {
            { "filetype", separator = caps, color = { fg = theme.normal.b.fg, bg = palette.grey, gui = "italic" } },
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
    end,
  },

  {
    "akinsho/bufferline.nvim",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        mode = "buffers",
        diagnostics = "nvim_lsp",
        show_buffer_close_icons = false,
        show_close_icon = false,
        offsets = {
          { filetype = "NvimTree", text = "", separator = true },
        },
      },
    },
  },

  {
    "folke/which-key.nvim",
    keys = { "<leader>", "<c-w>", '"', "'", "`", "c", "v", "g" },
    cmd = "WhichKey",
    opts = {},
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    main = "ibl",
    opts = {
      indent = { char = "│" },
      scope = { char = "│" },
    },
    config = function(_, opts)
      local hooks = require "ibl.hooks"
      hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
      require("ibl").setup(opts)
    end,
  },

  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    opts = {},
  },
}
