-- LSP keymaps are buffer-local and attached via LspAttach.
local function on_attach(bufnr)
  local map = vim.keymap.set
  local function opts(desc)
    return { buffer = bufnr, desc = "LSP " .. desc }
  end

  map("n", "gD", vim.lsp.buf.declaration, opts "Go to declaration")
  map("n", "gd", vim.lsp.buf.definition, opts "Go to definition")
  map("n", "K", vim.lsp.buf.hover, opts "Show hover")
  map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts "Add workspace folder")
  map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts "Remove workspace folder")
  map("n", "<leader>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, opts "List workspace folders")
  map("n", "<leader>D", vim.lsp.buf.type_definition, opts "Go to type definition")
  map("n", "<leader>ra", vim.lsp.buf.rename, opts "Rename")
  map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, opts "Code action")
end

-- disable semanticTokens
local function on_init(client, _)
  if client:supports_method "textDocument/semanticTokens" then
    client.server_capabilities.semanticTokensProvider = nil
  end
end

local function diagnostic_config()
  local x = vim.diagnostic.severity
  vim.diagnostic.config {
    virtual_text = { prefix = "\u{f445}" },
    signs = { text = { [x.ERROR] = "󰅙", [x.WARN] = "\u{f071}", [x.INFO] = "󰋼", [x.HINT] = "󰌵" } },
    underline = true,
    float = { border = "single" },
  }
end

local servers = {
  "lua_ls",
  "html",
  "cssls",
  "solargraph",
  "clangd",
  "rust_analyzer",
  "gopls",
  "tailwindcss",
  "ts_ls",
  "terraformls",
}

return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "saghen/blink.cmp" },
    config = function()
      diagnostic_config()

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          on_attach(args.buf)
        end,
      })

      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
        on_init = on_init,
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            workspace = {
              library = {
                vim.fn.expand "$VIMRUNTIME/lua",
                vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy",
                "${3rd}/luv/library",
              },
            },
          },
        },
      })

      for _, server in ipairs(servers) do
        vim.lsp.enable(server)
      end
    end,
  },

  {
    "mason-org/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate" },
    opts = {
      PATH = "skip", -- PATH is prepended in core/options.lua
      ui = {
        icons = {
          package_pending = "\u{f019} ",
          package_installed = "\u{f058} ",
          package_uninstalled = "\u{f192} ",
        },
      },
      max_concurrent_installers = 10,
    },
  },

  {
    "mason-org/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
    opts = {
      ensure_installed = {
        "lua_ls",
        "solargraph",
        "tailwindcss",
        "ts_ls",
        "gopls",
        "terraformls",
        "rust_analyzer",
      },
    },
  },

  {
    "stevearc/conform.nvim",
    cmd = "ConformInfo",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        go = { "goimports" },
        rust = { "rustfmt" },
        eruby = { "erb-formatter" },
      },
    },
  },
}
