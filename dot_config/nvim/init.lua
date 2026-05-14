vim.g.mapleader = " "

if vim.g.vscode then
  require "vscode_config"
else
  require "nvchad_config"
end
