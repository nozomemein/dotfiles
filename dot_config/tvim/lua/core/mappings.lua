-- Keymaps. General editor / plugin keymaps come first, personal additions
-- follow. Plugin-specific keymaps use <cmd> or a lazy require so they work
-- with lazy-loading.
local map = vim.keymap.set

---------------------------------------------------------------------------
-- General
---------------------------------------------------------------------------
map("i", "<C-b>", "<ESC>^i", { desc = "move beginning of line" })
map("i", "<C-e>", "<End>", { desc = "move end of line" })
map("i", "<C-h>", "<Left>", { desc = "move left" })
map("i", "<C-l>", "<Right>", { desc = "move right" })
map("i", "<C-j>", "<Down>", { desc = "move down" })
map("i", "<C-k>", "<Up>", { desc = "move up" })

map("n", "<C-h>", "<C-w>h", { desc = "switch window left" })
map("n", "<C-l>", "<C-w>l", { desc = "switch window right" })
map("n", "<C-j>", "<C-w>j", { desc = "switch window down" })
map("n", "<C-k>", "<C-w>k", { desc = "switch window up" })

map("n", "<Esc>", "<cmd>noh<CR>", { desc = "general clear highlights" })

map("n", "<C-s>", "<cmd>w<CR>", { desc = "general save file" })
map("n", "<C-c>", "<cmd>%y+<CR>", { desc = "general copy whole file" })

map("n", "<leader>n", "<cmd>set nu!<CR>", { desc = "toggle line number" })
map("n", "<leader>rn", "<cmd>set rnu!<CR>", { desc = "toggle relative number" })

map({ "n", "x" }, "<leader>fm", function()
  require("conform").format { lsp_fallback = true }
end, { desc = "general format file" })

-- global lsp mappings
map("n", "<leader>ds", vim.diagnostic.setloclist, { desc = "LSP diagnostic loclist" })

-- buffers (bufferline)
map("n", "<tab>", "<cmd>BufferLineCycleNext<CR>", { desc = "buffer goto next" })
map("n", "<S-tab>", "<cmd>BufferLineCyclePrev<CR>", { desc = "buffer goto prev" })
map("n", "]b", "<cmd>BufferLineCycleNext<CR>", { desc = "buffer goto next" })
map("n", "[b", "<cmd>BufferLineCyclePrev<CR>", { desc = "buffer goto prev" })

map("n", "<leader>x", function()
  local buf = vim.api.nvim_get_current_buf()
  local listed = vim.tbl_filter(function(b)
    return vim.bo[b].buflisted
  end, vim.api.nvim_list_bufs())
  if #listed > 1 then
    vim.cmd "BufferLineCyclePrev"
  end
  vim.cmd("confirm bdelete " .. buf)
end, { desc = "buffer close" })

map("n", "<leader>bx", "<cmd>BufferLineCloseOthers<CR>", { desc = "Close all buffers except current one" })

-- Comment (builtin gc operator)
map("n", "<leader>/", "gcc", { desc = "toggle comment", remap = true })
map("v", "<leader>/", "gc", { desc = "toggle comment", remap = true })

-- nvimtree
map("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", { desc = "nvimtree toggle window" })
map("n", "<leader>e", "<cmd>NvimTreeFocus<CR>", { desc = "nvimtree focus window" })

-- telescope
map("n", "<leader>fw", "<cmd>Telescope live_grep<CR>", { desc = "telescope live grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "telescope find buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "telescope help page" })
map("n", "<leader>ma", "<cmd>Telescope marks<CR>", { desc = "telescope find marks" })
map("n", "<leader>fo", "<cmd>Telescope oldfiles<CR>", { desc = "telescope find oldfiles" })
map("n", "<leader>fz", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "telescope find in current buffer" })
map("n", "<leader>cm", "<cmd>Telescope git_commits<CR>", { desc = "telescope git commits" })
map("n", "<leader>gt", "<cmd>Telescope git_status<CR>", { desc = "telescope git status" })
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "telescope find files" })
map(
  "n",
  "<leader>fa",
  "<cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>",
  { desc = "telescope find all files" }
)

-- terminal (toggleterm)
map("t", "<C-x>", "<C-\\><C-N>", { desc = "terminal escape terminal mode" })

map("n", "<leader>h", "<cmd>ToggleTerm direction=horizontal<CR>", { desc = "terminal new horizontal term" })
map("n", "<leader>v", "<cmd>ToggleTerm direction=vertical<CR>", { desc = "terminal new vertical term" })

-- toggleable terminals; ids keep the three terminals independent
-- NOTE: Alt chords do not reach Neovim while Ghostty's macos-option-as-alt is off.
map({ "n", "t" }, "<A-v>", "<cmd>2ToggleTerm direction=vertical<CR>", { desc = "terminal toggleable vertical term" })
map({ "n", "t" }, "<A-h>", "<cmd>3ToggleTerm direction=horizontal<CR>", { desc = "terminal toggleable horizontal term" })
map({ "n", "t" }, "<A-i>", "<cmd>4ToggleTerm direction=float<CR>", { desc = "terminal toggle floating term" })

-- whichkey
map("n", "<leader>wK", "<cmd>WhichKey <CR>", { desc = "whichkey all keymaps" })
map("n", "<leader>wk", function()
  vim.cmd("WhichKey " .. vim.fn.input "WhichKey: ")
end, { desc = "whichkey query lookup" })

---------------------------------------------------------------------------
-- Personal mappings
---------------------------------------------------------------------------

-- general
map("i", "jj", "<ESC>")
map("n", "<leader>q", ":q<CR>", { desc = "Quit" })
map("n", "<leader>Q", ":qa<CR>", { desc = "Quit all" })
map("n", "|", "<Cmd>vsplit<CR>", { desc = "Vertical Split" })
map("n", "\\", "<Cmd>split<CR>", { desc = "Horizontal Split" })

map("n", "<leader>tt", function()
  require("core.theme").toggle_transparency()
end, { desc = "Toggle Background Transparency" })

-- Movement enhancements
map("n", "<S-l>", "$")
map("n", "<S-h>", "^")

-- lazy plugin manager
map("n", "<leader>pi", function()
  require("lazy").install()
end, { desc = "Install Plugin" })

-- mason installer
map("n", "<leader>pm", "<cmd>Mason<CR>", { desc = "Open Mason Installer" })

-- lazygit
map("n", "<leader>gg", "<cmd>LazyGit<CR>", { desc = "LazyGit" })

-- lazydocker
map("n", "<leader>ld", "<cmd>Lazydocker<CR>", { desc = "LazyDocker" })

-- telescope: command picker
map("n", "<leader>fc", function()
  local dropdown = require("telescope.themes").get_dropdown {
    previewer = false,
    layout_config = { width = 0.5, height = 0.6 },
    prompt_title = "Commands",
  }
  local displayer = require("telescope.pickers.entry_display").create {
    separator = " ",
    items = {
      { width = 0.35 },
      { remaining = true },
    },
  }

  dropdown.entry_maker = function(entry)
    local desc = (entry.definition or ""):gsub("\n", " ")
    return {
      value = entry,
      ordinal = entry.name .. " " .. desc,
      display = function()
        return displayer {
          { entry.name, "TelescopeResultsIdentifier" },
          desc,
        }
      end,
    }
  end

  require("telescope.builtin").commands(dropdown)
end, { desc = "Find & run Vim command" })

-- LSP buffer-local mappings (K, gd, <leader>ca, <leader>ra, ...) live in
-- comment
-- lua/plugins/lsp.lua (on_attach).

-- diffview
map("n", "<leader>gdo", "<cmd>DiffviewOpen<CR>", { desc = "DiffviewOpen" })
map("n", "<leader>gdc", "<cmd>DiffviewClose<CR>", { desc = "DiffviewClose" })
map("n", "<leader>gdb", "<cmd>DiffviewFileHistory<CR>", { desc = "Diffview on current branch" })
map("n", "<leader>gdf", "<cmd>DiffviewFileHistory %<CR>", { desc = "Diffview on current file" })
map("n", "<leader>gdm", "<cmd>BranchDiff<CR>", { desc = "Diff this branch against main" })
map("n", "<leader>gdl", "<cmd>BranchLog<CR>", { desc = "Commits on this branch" })

-- neotest
map("n", "<leader>nr", "<Cmd>lua require('neotest').run.run()<CR>", { desc = "Run the nearest test" })
map("n", "<leader>nf", "<Cmd>lua require('neotest').run.run(vim.fn.expand('%'))<CR>",
  { desc = "Run the tests of current file" })
map("n", "<leader>nR", "<Cmd>lua require('neotest').run.run(vim.fn.getcwd())<CR>", { desc = "Run all tests" })
map("n", "<leader>nS", "<Cmd>lua require('neotest').stop()<CR>", { desc = "Stop the tests" })
map("n", "<leader>no", "<Cmd>lua require('neotest').output.open({ enter = true })<CR>", { desc = "Open output" })
map("n", "<leader>ns", "<Cmd>lua require('neotest').summary.toggle()<CR>", { desc = "Open summary" })

-- RSpec commands
map("n", "<leader>rn", ":RSpecNearest<CR>", { desc = "Run nearest spec", silent = true })
map("n", "<leader>rf", ":RSpecCurrentFile<CR>", { desc = "Run current file spec", silent = true })
map("n", "<leader>rr", ":RSpecRerun<CR>", { desc = "Rerun spec", silent = true })
map("n", "<leader>rF", ":RSpecOnlyFailures<CR>", { desc = "Run only failed spec", silent = true })
map("n", "<leader>rs", ":RSpecShowLastResult<CR>", { desc = "Show spec results", silent = true })

-- dial.nvim
map("n", "<C-a>", function()
  require("dial.map").manipulate("increment", "normal")
end, { desc = "Increment number under cursor" })
map("n", "<C-x>", function()
  require("dial.map").manipulate("decrement", "normal")
end, { desc = "Decrement number under cursor" })
map("v", "<C-a>", function()
  require("dial.map").manipulate("increment", "visual")
end, { desc = "Increment number under visual" })
map("v", "<C-x>", function()
  require("dial.map").manipulate("decrement", "visual")
end, { desc = "Decrement number under visual" })

-- treesj
map("n", "<leader>mt", "<cmd>TSJToggle<CR>", { desc = "Toggle split/join (treesj)" })

-- dap
map("n", "<F5>", ":lua require'dap'.continue()<CR>",
  { silent = true, desc = "Continue debugging or start if not started" })
map("n", "<F9>", ":lua require'dap'.step_into()<CR>", { silent = true, desc = "Step into the function call" })
map("n", "<F10>", ":lua require'dap'.step_over()<CR>", { silent = true, desc = "Step over the current line of code" })
map("n", "<F12>", ":lua require'dap'.step_out()<CR>", { silent = true, desc = "Step out of the current function" })

map("n", "<leader>b", ":lua require'dap'.toggle_breakpoint()<CR>",
  { silent = true, desc = "Toggle breakpoint at the current line" })
map("n", "<leader>bu", ":lua require'dap'.clear_breakpoints()<CR>", { silent = true, desc = "Clear all breakpoints" })
map("n", "<leader>bc", ":lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
  { silent = true, desc = "Set a breakpoint with a condition" })
map("n", "<leader>l", ":lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>",
  { silent = true, desc = "Set a log point" })

-- dap-ui
map("n", "<leader>d", ":lua require'dapui'.toggle()<CR>", { silent = true, desc = "Toggle dap-ui" })

-- ZenMode
map("n", "<leader>zz", ":ZenMode<CR>", { desc = "ZenMode" })

-- Paste without yanking in visual mode
map("x", "p", '"_dP', { desc = "Paste without yanking", silent = true })

-- Bookmarks
-- NOTE: In BookmarksGoto telescope picker, <C-d> deletes the selected bookmark
map("n", "mm", "<cmd>BookmarksMark<CR>", { desc = "Toggle bookmark" })
map("n", "mo", "<cmd>BookmarksGoto<CR>", { desc = "Go to bookmark" })
map("n", "mc", "<cmd>BookmarksCommands<CR>", { desc = "Bookmark commands" })
map("n", "mn", "<cmd>BookmarksGotoNext<CR>", { desc = "Next bookmark" })
map("n", "mp", "<cmd>BookmarksGotoPrev<CR>", { desc = "Prev bookmark" })
map("n", "ml", "<cmd>BookmarksLists<CR>", { desc = "Bookmark lists" })
map("n", "mt", "<cmd>BookmarksTree<CR>", { desc = "Bookmark tree view" })
