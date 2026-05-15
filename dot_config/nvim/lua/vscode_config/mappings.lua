-- VSCode Neovim mappings (loaded only when vim.g.vscode == 1).
-- Keep keymaps aligned with:
--   * NvChad defaults + ~/.config/nvim/lua/mappings.lua
--   * Zed keymap (~/.config/zed/keymap.json) — same leader (space) layout

local ok, vscode = pcall(require, "vscode")
if not ok then
  return
end

local map = vim.keymap.set
local opts = { silent = true, noremap = true }

local function act(action)
  return function()
    vscode.action(action)
  end
end

-- ─── insert mode: jj → ESC ───────────────────────────────────────────
-- VSCode Neovim handles insert-mode keys in VSCode (not Neovim) for perf,
-- so this is configured via `vscode-neovim.compositeKeys` in settings.json.
-- TODO: bring vscode settings.json under chezmoi management so this lives with the rest of the dotfiles.

-- ─── line start / end (NvChad local: S-h / S-l) ─────────────────────
-- overrides vim default H/L (top/bottom of viewport)
map({ "n", "v" }, "<S-h>", "^", opts)
map({ "n", "v" }, "<S-l>", "$", opts)

-- ─── save / buffer (tab) nav ─────────────────────────────────────────
map("n", "<C-s>", act "workbench.action.files.save", opts)
map("n", "<tab>", act "workbench.action.nextEditor", opts)
map("n", "<S-tab>", act "workbench.action.previousEditor", opts)
map("n", "gt", act "workbench.action.nextEditor", opts)
map("n", "gT", act "workbench.action.previousEditor", opts)
-- NvChad local: bracket buffer nav
map("n", "]b", act "workbench.action.nextEditor", opts)
map("n", "[b", act "workbench.action.previousEditor", opts)

-- ─── splits (local: | vsplit / \\ hsplit) ───────────────────────────
map("n", "|", act "workbench.action.splitEditorRight", opts)
map("n", "\\", act "workbench.action.splitEditorDown", opts)
map("n", "<C-w>v", act "workbench.action.splitEditorRight", opts)
map("n", "<C-w>s", act "workbench.action.splitEditorDown", opts)

-- ─── window navigation (NvimTree / editor groups) ───────────────────
map("n", "<C-h>", act "workbench.action.focusLeftGroup", opts)
map("n", "<C-j>", act "workbench.action.focusBelowGroup", opts)
map("n", "<C-k>", act "workbench.action.focusAboveGroup", opts)
map("n", "<C-l>", act "workbench.action.focusRightGroup", opts)

-- ─── telescope-ish finders (leader f*) ──────────────────────────────
map("n", "<leader>ff", act "workbench.action.quickOpen", opts)
map("n", "<leader>fw", act "workbench.action.findInFiles", opts)
map("n", "<leader>fb", act "workbench.action.showAllEditors", opts)
map("n", "<leader>fz", act "actions.find", opts)
map("n", "<leader>fm", act "editor.action.formatDocument", opts)
map("n", "<leader>fp", act "workbench.action.openRecent", opts)

-- ─── comment toggle ─────────────────────────────────────────────────
map({ "n", "v" }, "<leader>/", act "editor.action.commentLine", opts)

-- ─── LSP ────────────────────────────────────────────────────────────
map("n", "K", act "editor.action.showHover", opts)
map("n", "gd", act "editor.action.revealDefinition", opts)
map("n", "<leader>ca", act "editor.action.quickFix", opts)
map("n", "<leader>ds", act "workbench.actions.view.problems", opts)

-- ─── project / buffers ──────────────────────────────────────────────
map("n", "<leader>e", act "workbench.view.explorer", opts)
map("n", "<C-n>", act "workbench.view.explorer", opts)
map("n", "<leader>q", act "workbench.action.closeActiveEditor", opts)
map("n", "<leader>x", act "workbench.action.closeActiveEditor", opts)
map("n", "<leader>Q", act "workbench.action.closeWindow", opts)
map("n", "<leader>b", act "workbench.action.files.newUntitledFile", opts)
map("n", "<leader>tn", act "workbench.action.files.newUntitledFile", opts)
map("n", "<leader>tc", act "workbench.action.closeActiveEditor", opts)

-- ─── git (built-in SCM + GitLens compatible) ────────────────────────
map("n", "<leader>gg", act "workbench.scm.focus", opts)
map("n", "<leader>gh", act "git.viewHistory", opts)
map("n", "<leader>gb", act "gitlens.toggleFileBlame", opts) -- requires GitLens
map("n", "<leader>gd", act "git.openChange", opts)
map("n", "<leader>gm", act "workbench.scm.focus", opts)

-- ─── bookmarks (requires "Bookmarks" extension by alefragnani) ──────
map("n", "<leader>mm", act "bookmarks.toggle", opts)
map("n", "<leader>mn", act "bookmarks.jumpToNext", opts)
map("n", "<leader>mp", act "bookmarks.jumpToPrevious", opts)
map("n", "<leader>ml", act "bookmarks.list", opts)
map("n", "<leader>mc", act "bookmarks.clear", opts)
