-- conform.nvim formatters.
--   <leader>fm -> formatters_by_ft (safe)
--   <leader>fM -> the "aggressive" variants listed in core/mappings.lua

-- RuboCop with the given autocorrect flag. Runs through bundler when the
-- project has a Gemfile so the project's RuboCop version and plugins are used.
---@param autocorrect "-a"|"-A"  -a: safe autocorrects only, -A: all (may change semantics)
---@return conform.FileFormatterConfig
local function rubocop(autocorrect)
  local function in_bundle(ctx)
    return vim.fs.root(ctx.dirname, "Gemfile") ~= nil
  end
  return {
    command = function(_, ctx)
      return in_bundle(ctx) and "bundle" or "rubocop"
    end,
    args = function(_, ctx)
      local args = { "--server", autocorrect, "-f", "quiet", "--stderr", "--stdin", "$FILENAME" }
      if in_bundle(ctx) then
        table.insert(args, 1, "exec")
        table.insert(args, 2, "rubocop")
      end
      return args
    end,
    exit_codes = { 0, 1 },
  }
end

return {
  formatters_by_ft = {
    lua = { "stylua" },
    go = { "goimports" },
    rust = { "rustfmt" },
    ruby = { "rubocop" },
    eruby = { "erb-formatter" },
  },
  formatters = {
    rubocop = rubocop "-a",
    rubocop_unsafe = rubocop "-A",
  },
}
