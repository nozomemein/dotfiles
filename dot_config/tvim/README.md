# tvim

Personal Neovim configuration. Run it side by side with `~/.config/nvim` via
`NVIM_APPNAME=tvim nvim` (alias `tvim`).

## Layout

```
init.lua                 leader key, then require("core")
lua/core/
  init.lua               load order: options -> lazy -> autocmds -> mappings
  options.lua            vim.o / vim.opt
  autocmds.lua
  lazy.lua               lazy.nvim bootstrap and options
  theme.lua              colorscheme single source of truth (M.current)
  mappings.lua           ALL keymaps; M.lsp(bufnr) for the buffer-local LSP ones
lua/plugins/*.lua        lazy.nvim specs only (what to install, when to load)
lua/configs/*.lua        option tables / setup functions for the bigger plugins,
                         referenced from the specs
```

Rules of thumb:

- A keymap goes in `core/mappings.lua`, never in a plugin spec.
- A plugin whose options fit in a few lines stays inline in `plugins/`.
  Anything with helper functions or more than a screenful goes to `configs/`.
- Switching colorscheme: change `M.current` in `core/theme.lua`, then `:Lazy sync`.

## Checks

```
VIMRUNTIME=$(nvim --clean --headless +'lua io.stdout:write(vim.env.VIMRUNTIME)' +qa 2>&1) \
  ~/.local/share/tvim/mason/bin/lua-language-server --check ~/.config/tvim --checklevel=Warning
```
