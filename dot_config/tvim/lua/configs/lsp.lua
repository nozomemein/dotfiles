-- nvim-lspconfig setup: diagnostics look, shared client settings, server list.
-- Buffer-local keymaps live in core/mappings.lua (M.lsp).
-- Dart is handled by flutter-tools (configs/flutter.lua); do not add dartls here.
local M = {}

---@type string[] server names as known to nvim-lspconfig
M.servers = {
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

local function diagnostics()
  local x = vim.diagnostic.severity
  vim.diagnostic.config {
    virtual_text = { prefix = "\u{f445}" },
    signs = { text = { [x.ERROR] = "\u{f0159}", [x.WARN] = "\u{f071}", [x.INFO] = "\u{f02fc}", [x.HINT] = "\u{f0335}" } },
    underline = true,
    float = { border = "single" },
  }
end

-- semantic tokens fight with treesitter highlighting; keep treesitter's
---@param client vim.lsp.Client
local function on_init(client, _)
  if client:supports_method "textDocument/semanticTokens" then
    client.server_capabilities.semanticTokensProvider = nil
  end
end

function M.setup()
  diagnostics()

  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      require("core.mappings").lsp(args.buf)
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

  for _, server in ipairs(M.servers) do
    vim.lsp.enable(server)
  end
end

return M
