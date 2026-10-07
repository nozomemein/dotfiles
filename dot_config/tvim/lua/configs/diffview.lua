-- diffview.nvim: make :DiffviewOpen / :BranchDiff look like the file history
-- view (file list in a bottom panel, diff above) and keep the diff buffers
-- free of editor noise. Also defines :BranchDiff / :BranchLog.
local M = {}

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

local function define_commands()
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
end

function M.setup()
  require("diffview").setup {
    -- dim unchanged text inside changed lines so word-level changes stand out
    enhanced_diff_hl = true,
    view = {
      -- winbar_info names each side (e.g. "HEAD" vs "working tree") like the
      -- file history view does
      default = { layout = "diff2_horizontal", winbar_info = true },
      file_history = { layout = "diff2_horizontal", winbar_info = true },
      merge_tool = { layout = "diff3_horizontal", winbar_info = true },
    },
    -- same shape as the file history panel: flat list, bottom, 16 rows
    file_panel = {
      listing_style = "list",
      win_config = { position = "bottom", height = 16 },
    },
    file_history_panel = {
      win_config = { position = "bottom", height = 16 },
    },
    hooks = {
      -- The working-tree side of :DiffviewOpen is a real file buffer, so it
      -- would show LSP diagnostics and gitsigns on top of the diff; the file
      -- history view never has those. Silence them for every diff buffer.
      ---@param bufnr integer
      diff_buf_read = function(bufnr)
        vim.diagnostic.enable(false, { bufnr = bufnr })
        pcall(function()
          require("gitsigns").detach(bufnr)
        end)
      end,
    },
  }

  define_commands()
end

return M
