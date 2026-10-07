---@type LazySpec
return {
  {
    "kdheepak/lazygit.nvim",
    cmd = { "LazyGit", "LazyGitCurrentFile", "LazyGitFilter", "LazyGitFilterCurrentFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "BranchDiff", "BranchLog" },
    -- BranchDiff / BranchLog are defined in configs/diffview.lua, after the
    -- plugin loads: lazy's cmd stubs would otherwise overwrite them at startup.
    config = function()
      require("configs.diffview").setup()
    end,
  },
}
