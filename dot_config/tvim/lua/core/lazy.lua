-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

---@type LazyConfig
local opts = {
  defaults = { lazy = true },
  install = { colorscheme = { require("core.theme").colorscheme() } },
  checker = { enabled = false },
  rocks = { enabled = false }, -- no plugin here needs luarocks
  change_detection = { notify = false },

  performance = {
    rtp = {
      -- builtin runtime plugins we don't use (names must match runtime/plugin/*)
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "zipPlugin",
        "netrwPlugin", -- nvim-tree
        "tutor",
        "rplugin", -- remote plugin hosts; providers are disabled in options.lua
      },
    },
  },
}

require("lazy").setup({
  { import = "plugins" },
}, opts)
