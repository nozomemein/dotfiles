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
    -- The commands are defined in config (after the plugin loads), not init:
    -- lazy's cmd stubs would otherwise overwrite them at startup.
    config = function()
      require("diffview").setup()

      -- Base branch for branch diffs: origin's HEAD if known, else main / master.
      ---@return string
      local function base_branch()
        local head = vim.fn.systemlist("git symbolic-ref --short refs/remotes/origin/HEAD")[1]
        if vim.v.shell_error == 0 and head and head ~= "" then
          return (head:gsub("^origin/", ""))
        end
        for _, name in ipairs { "main", "master" } do
          vim.fn.system("git show-ref --verify --quiet refs/heads/" .. name)
          if vim.v.shell_error == 0 then
            return name
          end
        end
        return "main"
      end

      -- :BranchDiff [base]  -> changes on this branch since it forked from base
      vim.api.nvim_create_user_command("BranchDiff", function(cmd)
        local base = cmd.args ~= "" and cmd.args or base_branch()
        vim.cmd("DiffviewOpen " .. base .. "...HEAD")
      end, { nargs = "?", desc = "Diff this branch against its base (merge-base)" })

      -- :BranchLog [base]  -> commits on this branch, each with its diff
      vim.api.nvim_create_user_command("BranchLog", function(cmd)
        local base = cmd.args ~= "" and cmd.args or base_branch()
        vim.cmd("DiffviewFileHistory --range=" .. base .. "..HEAD")
      end, { nargs = "?", desc = "Commits on this branch since its base" })
    end,
  },
}
