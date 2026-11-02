-- Wakaba: green / blue dark colorscheme, the Neovim half of the Zed theme in
-- ~/.config/zed/themes/wakaba.json. Keep the two palettes in sync by hand.
--
-- Neutral grey ground with a slight blue bias, young-leaf green as the UI
-- accent (cursor, selection, matches), sky blue keywords, teal types, and a
-- single warm sand for strings so the cool palette doesn't go flat.

local M = {}

---@class WakabaPalette
M.palette = {
  -- ground
  bg = "#161819",
  bg_dark = "#18191b", -- bars (status / tab)
  surface = "#1a1c1e", -- side panels
  elevated = "#1f2224", -- floats, popups
  hover = "#242729",
  selected = "#2c3033",
  border = "#2e3134",
  border_soft = "#26292b",
  invisible = "#3a3e41",
  linenr = "#545a5e",
  placeholder = "#6e7478",
  muted = "#8a9094",
  text = "#d6d8d9",
  bright = "#e9ebec",

  -- accent and overlays (flattened over bg)
  accent = "#8fe3a0",
  accent_soft = "#b0f0bb",
  selection = "#29382f",
  highlight_read = "#1f2a24",
  highlight_write = "#2c3f32",
  search = "#344b3b",

  -- syntax
  keyword = "#7fb4ff",
  func = "#8fe3a0",
  type = "#5ed6cb",
  string = "#e2c391",
  number = "#a5cfff",
  constant = "#b9c0ff",
  property = "#a7dcd3",
  preproc = "#9fd68a",
  special = "#e0a7bb", -- self / builtin variables
  comment = "#6b7a76",
  punct = "#9aa7a3",
  punct_special = "#83908c",
  inlay = "#7f8c88",

  -- status
  error = "#ff6b6b",
  warn = "#f0b860",
  info = "#7fb4ff",
  hint = "#8a9094",
  added = "#8fe3a0",
  modified = "#7fb4ff",
  deleted = "#ff6b6b",
  conflict = "#f0b860",
  renamed = "#5ed6cb",

  -- terminal
  ansi = {
    black = "#212c2a",
    red = "#ff6b6b",
    green = "#8fe3a0",
    yellow = "#e2c391",
    blue = "#7fb4ff",
    magenta = "#c7a3e0",
    cyan = "#5ed6cb",
    white = "#d5dedb",
    bright_black = "#4f615d",
    bright_red = "#ff8f8f",
    bright_green = "#b0f0bb",
    bright_yellow = "#f0d4a3",
    bright_blue = "#a5cfff",
    bright_magenta = "#dcc0ee",
    bright_cyan = "#8fe6dd",
    bright_white = "#e8efec",
  },
}

---@class WakabaOptions
---@field transparent? boolean clear the editor background (floats stay opaque)
---@field italic_comments? boolean
---@field overrides? table<string, vim.api.keyset.highlight> applied last

---@type WakabaOptions
M.options = { transparent = false, italic_comments = true, overrides = {} }

---@param opts? WakabaOptions
function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", M.options, opts or {})
end

---@return table<string, vim.api.keyset.highlight>
local function highlights()
  local p = M.palette
  local o = M.options
  local bg = o.transparent and "NONE" or p.bg
  local panel = o.transparent and "NONE" or p.surface

  ---@type table<string, vim.api.keyset.highlight>
  local h = {
    -- ===== editor =====
    Normal = { fg = p.text, bg = bg },
    NormalNC = { fg = p.text, bg = bg },
    NormalFloat = { fg = p.text, bg = p.elevated },
    FloatBorder = { fg = p.border, bg = p.elevated },
    FloatTitle = { fg = p.accent, bg = p.elevated, bold = true },
    EndOfBuffer = { fg = bg == "NONE" and p.bg or bg },
    SignColumn = { fg = p.linenr, bg = bg },
    LineNr = { fg = p.linenr },
    LineNrAbove = { fg = p.linenr },
    LineNrBelow = { fg = p.linenr },
    CursorLineNr = { fg = p.bright, bold = true },
    CursorLine = { bg = p.elevated },
    CursorColumn = { bg = p.elevated },
    ColorColumn = { bg = p.surface },
    Cursor = { fg = p.bg, bg = p.accent },
    lCursor = { fg = p.bg, bg = p.accent },
    TermCursor = { fg = p.bg, bg = p.accent },
    TermCursorNC = { fg = p.bg, bg = p.muted },
    Visual = { bg = p.selection },
    VisualNOS = { bg = p.selection },
    Search = { bg = p.search },
    IncSearch = { fg = p.bg, bg = p.accent },
    CurSearch = { fg = p.bg, bg = p.accent },
    Substitute = { fg = p.bg, bg = p.warn },
    MatchParen = { fg = p.accent, bg = p.selected, bold = true },
    NonText = { fg = p.invisible },
    Whitespace = { fg = p.invisible },
    SpecialKey = { fg = p.invisible },
    Conceal = { fg = p.muted },
    Folded = { fg = p.muted, bg = p.surface },
    FoldColumn = { fg = p.linenr, bg = bg },
    WinSeparator = { fg = p.border },
    VertSplit = { fg = p.border },
    StatusLine = { fg = p.text, bg = bg == "NONE" and "NONE" or p.bg_dark },
    StatusLineNC = { fg = p.muted, bg = bg == "NONE" and "NONE" or p.bg_dark },
    TabLine = { fg = p.muted, bg = p.bg_dark },
    TabLineFill = { bg = p.bg_dark },
    TabLineSel = { fg = p.text, bg = p.bg, bold = true },
    WinBar = { fg = p.text, bg = bg },
    WinBarNC = { fg = p.muted, bg = bg },
    Pmenu = { fg = p.text, bg = p.elevated },
    PmenuSel = { fg = p.bg, bg = p.accent, bold = true },
    PmenuSbar = { bg = p.elevated },
    PmenuThumb = { bg = p.border },
    PmenuKind = { fg = p.type, bg = p.elevated },
    PmenuExtra = { fg = p.muted, bg = p.elevated },
    WildMenu = { fg = p.bg, bg = p.accent },
    QuickFixLine = { bg = p.selected },
    Directory = { fg = p.keyword },
    Title = { fg = p.text, bold = true },
    Question = { fg = p.accent },
    MoreMsg = { fg = p.accent },
    ModeMsg = { fg = p.text, bold = true },
    ErrorMsg = { fg = p.error },
    WarningMsg = { fg = p.warn },
    NvimInternalError = { fg = p.error },
    healthSuccess = { fg = p.bg, bg = p.added },
    DiffAdd = { bg = "#1f2e23" },
    DiffChange = { bg = "#1d262e" },
    DiffDelete = { fg = p.deleted, bg = "#2e1f20" },
    DiffText = { bg = "#2a3b4a" },
    Added = { fg = p.added },
    Changed = { fg = p.modified },
    Removed = { fg = p.deleted },
    SpellBad = { sp = p.error, undercurl = true },
    SpellCap = { sp = p.warn, undercurl = true },
    SpellLocal = { sp = p.info, undercurl = true },
    SpellRare = { sp = p.hint, undercurl = true },

    -- ===== legacy syntax =====
    Comment = { fg = p.comment, italic = o.italic_comments },
    Constant = { fg = p.constant },
    String = { fg = p.string },
    Character = { fg = p.string },
    Number = { fg = p.number },
    Float = { fg = p.number },
    Boolean = { fg = p.constant },
    Identifier = { fg = p.text },
    Function = { fg = p.func },
    Statement = { fg = p.keyword },
    Conditional = { fg = p.keyword },
    Repeat = { fg = p.keyword },
    Label = { fg = p.func },
    Operator = { fg = p.text },
    Keyword = { fg = p.keyword },
    Exception = { fg = p.keyword },
    PreProc = { fg = p.preproc },
    Include = { fg = p.keyword },
    Define = { fg = p.preproc },
    Macro = { fg = p.preproc },
    PreCondit = { fg = p.preproc },
    Type = { fg = p.type },
    StorageClass = { fg = p.keyword },
    Structure = { fg = p.type },
    Typedef = { fg = p.type },
    Special = { fg = p.constant },
    SpecialChar = { fg = p.punct },
    Tag = { fg = p.type },
    Delimiter = { fg = p.punct },
    SpecialComment = { fg = p.comment, italic = o.italic_comments },
    Debug = { fg = p.special },
    Underlined = { underline = true },
    Ignore = { fg = p.placeholder },
    Error = { fg = p.error },
    Todo = { fg = p.bg, bg = p.info, bold = true },

    -- ===== tree-sitter =====
    ["@variable"] = { fg = p.text },
    ["@variable.builtin"] = { fg = p.special },
    ["@variable.parameter"] = { fg = p.text },
    ["@variable.parameter.builtin"] = { fg = p.special },
    ["@variable.member"] = { fg = p.property },
    ["@constant"] = { fg = p.constant },
    ["@constant.builtin"] = { fg = p.constant },
    ["@constant.macro"] = { fg = p.preproc },
    ["@module"] = { fg = p.text },
    ["@module.builtin"] = { fg = p.special },
    ["@label"] = { fg = p.func },
    ["@string"] = { fg = p.string },
    ["@string.documentation"] = { fg = p.comment },
    ["@string.regexp"] = { fg = p.text },
    ["@string.escape"] = { fg = p.punct },
    ["@string.special"] = { fg = p.string },
    ["@string.special.symbol"] = { fg = p.text },
    ["@string.special.path"] = { fg = p.string },
    ["@string.special.url"] = { fg = p.keyword, underline = true },
    ["@character"] = { fg = p.string },
    ["@character.special"] = { fg = p.punct },
    ["@boolean"] = { fg = p.constant },
    ["@number"] = { fg = p.number },
    ["@number.float"] = { fg = p.number },
    ["@type"] = { fg = p.type },
    ["@type.builtin"] = { fg = p.type },
    ["@type.definition"] = { fg = p.type },
    ["@attribute"] = { fg = p.constant },
    ["@attribute.builtin"] = { fg = p.constant },
    ["@property"] = { fg = p.property },
    ["@function"] = { fg = p.func },
    ["@function.builtin"] = { fg = p.func },
    ["@function.call"] = { fg = p.func },
    ["@function.macro"] = { fg = p.preproc },
    ["@function.method"] = { fg = p.func },
    ["@function.method.call"] = { fg = p.func },
    ["@constructor"] = { fg = p.type },
    ["@operator"] = { fg = p.text },
    ["@keyword"] = { fg = p.keyword },
    ["@keyword.coroutine"] = { fg = p.keyword },
    ["@keyword.function"] = { fg = p.keyword },
    ["@keyword.operator"] = { fg = p.keyword },
    ["@keyword.import"] = { fg = p.keyword },
    ["@keyword.type"] = { fg = p.keyword },
    ["@keyword.modifier"] = { fg = p.keyword },
    ["@keyword.repeat"] = { fg = p.keyword },
    ["@keyword.return"] = { fg = p.keyword },
    ["@keyword.debug"] = { fg = p.special },
    ["@keyword.exception"] = { fg = p.keyword },
    ["@keyword.conditional"] = { fg = p.keyword },
    ["@keyword.conditional.ternary"] = { fg = p.keyword },
    ["@keyword.directive"] = { fg = p.preproc },
    ["@keyword.directive.define"] = { fg = p.preproc },
    ["@punctuation.delimiter"] = { fg = p.punct },
    ["@punctuation.bracket"] = { fg = p.punct },
    ["@punctuation.special"] = { fg = p.punct_special },
    ["@comment"] = { fg = p.comment, italic = o.italic_comments },
    ["@comment.documentation"] = { fg = p.comment, italic = o.italic_comments },
    ["@comment.error"] = { fg = p.bg, bg = p.error, bold = true },
    ["@comment.warning"] = { fg = p.bg, bg = p.warn, bold = true },
    ["@comment.todo"] = { fg = p.bg, bg = p.info, bold = true },
    ["@comment.note"] = { fg = p.bg, bg = p.hint, bold = true },
    ["@markup.strong"] = { fg = p.string, bold = true },
    ["@markup.italic"] = { italic = true },
    ["@markup.strikethrough"] = { strikethrough = true },
    ["@markup.underline"] = { underline = true },
    ["@markup.heading"] = { fg = p.text, bold = true },
    ["@markup.heading.1"] = { fg = p.accent, bold = true },
    ["@markup.heading.2"] = { fg = p.keyword, bold = true },
    ["@markup.heading.3"] = { fg = p.type, bold = true },
    ["@markup.quote"] = { fg = p.comment },
    ["@markup.math"] = { fg = p.number },
    ["@markup.link"] = { fg = p.keyword },
    ["@markup.link.label"] = { fg = p.constant, underline = true },
    ["@markup.link.url"] = { fg = p.keyword, underline = true },
    ["@markup.raw"] = { fg = p.string },
    ["@markup.raw.block"] = { fg = p.string },
    ["@markup.list"] = { fg = p.text },
    ["@markup.list.checked"] = { fg = p.added },
    ["@markup.list.unchecked"] = { fg = p.muted },
    ["@tag"] = { fg = p.type },
    ["@tag.builtin"] = { fg = p.type },
    ["@tag.attribute"] = { fg = p.constant },
    ["@tag.delimiter"] = { fg = p.punct },
    ["@diff.plus"] = { fg = p.added },
    ["@diff.minus"] = { fg = p.deleted },
    ["@diff.delta"] = { fg = p.modified },

    -- ===== LSP semantic tokens =====
    ["@lsp.type.class"] = { link = "@type" },
    ["@lsp.type.comment"] = {}, -- let tree-sitter decide
    ["@lsp.type.decorator"] = { link = "@attribute" },
    ["@lsp.type.enum"] = { link = "@type" },
    ["@lsp.type.enumMember"] = { link = "@constant" },
    ["@lsp.type.function"] = { link = "@function" },
    ["@lsp.type.interface"] = { link = "@type" },
    ["@lsp.type.keyword"] = { link = "@keyword" },
    ["@lsp.type.macro"] = { link = "@function.macro" },
    ["@lsp.type.method"] = { link = "@function.method" },
    ["@lsp.type.namespace"] = { link = "@module" },
    ["@lsp.type.parameter"] = { link = "@variable.parameter" },
    ["@lsp.type.property"] = { link = "@property" },
    ["@lsp.type.struct"] = { link = "@type" },
    ["@lsp.type.type"] = { link = "@type" },
    ["@lsp.type.typeParameter"] = { link = "@type" },
    ["@lsp.type.variable"] = {}, -- let tree-sitter decide
    ["@lsp.type.selfKeyword"] = { link = "@variable.builtin" },
    ["@lsp.type.selfTypeKeyword"] = { link = "@type" },
    ["@lsp.type.lifetime"] = { link = "@keyword" },
    ["@lsp.typemod.variable.readonly"] = { link = "@constant" },
    ["@lsp.typemod.variable.defaultLibrary"] = { link = "@variable.builtin" },
    ["@lsp.typemod.function.defaultLibrary"] = { link = "@function.builtin" },

    -- ===== diagnostics / LSP UI =====
    DiagnosticError = { fg = p.error },
    DiagnosticWarn = { fg = p.warn },
    DiagnosticInfo = { fg = p.info },
    DiagnosticHint = { fg = p.hint },
    DiagnosticOk = { fg = p.added },
    DiagnosticUnderlineError = { sp = p.error, undercurl = true },
    DiagnosticUnderlineWarn = { sp = p.warn, undercurl = true },
    DiagnosticUnderlineInfo = { sp = p.info, undercurl = true },
    DiagnosticUnderlineHint = { sp = p.hint, undercurl = true },
    DiagnosticUnderlineOk = { sp = p.added, undercurl = true },
    DiagnosticVirtualTextError = { fg = p.error, bg = "#2e1f20" },
    DiagnosticVirtualTextWarn = { fg = p.warn, bg = "#2e2a1f" },
    DiagnosticVirtualTextInfo = { fg = p.info, bg = "#1d262e" },
    DiagnosticVirtualTextHint = { fg = p.hint, bg = p.surface },
    DiagnosticSignError = { fg = p.error, bg = bg },
    DiagnosticSignWarn = { fg = p.warn, bg = bg },
    DiagnosticSignInfo = { fg = p.info, bg = bg },
    DiagnosticSignHint = { fg = p.hint, bg = bg },
    DiagnosticUnnecessary = { fg = p.placeholder },
    DiagnosticDeprecated = { sp = p.warn, strikethrough = true },
    LspReferenceText = { bg = p.highlight_read },
    LspReferenceRead = { bg = p.highlight_read },
    LspReferenceWrite = { bg = p.highlight_write },
    LspInlayHint = { fg = p.inlay, bg = p.surface },
    LspCodeLens = { fg = p.placeholder },
    LspSignatureActiveParameter = { fg = p.accent, bold = true },

    -- ===== plugins =====
    -- gitsigns
    GitSignsAdd = { fg = p.added, bg = bg },
    GitSignsChange = { fg = p.modified, bg = bg },
    GitSignsDelete = { fg = p.deleted, bg = bg },
    GitSignsCurrentLineBlame = { fg = p.hint, italic = true },
    -- diffview
    DiffviewFilePanelTitle = { fg = p.accent, bold = true },
    DiffviewFilePanelCounter = { fg = p.keyword, bold = true },
    DiffviewFilePanelFileName = { fg = p.text },
    DiffviewFilePanelPath = { fg = p.muted },
    DiffviewFilePanelInsertions = { fg = p.added },
    DiffviewFilePanelDeletions = { fg = p.deleted },
    DiffviewStatusAdded = { fg = p.added },
    DiffviewStatusModified = { fg = p.modified },
    DiffviewStatusDeleted = { fg = p.deleted },
    DiffviewStatusRenamed = { fg = p.renamed },
    DiffviewStatusUntracked = { fg = p.added },
    -- nvim-tree
    NvimTreeNormal = { fg = p.text, bg = panel },
    NvimTreeNormalNC = { fg = p.text, bg = panel },
    NvimTreeEndOfBuffer = { fg = panel == "NONE" and p.bg or panel },
    NvimTreeWinSeparator = { fg = p.border, bg = panel },
    NvimTreeRootFolder = { fg = p.accent, bold = true },
    NvimTreeFolderName = { fg = p.keyword },
    NvimTreeOpenedFolderName = { fg = p.keyword, bold = true },
    NvimTreeEmptyFolderName = { fg = p.muted },
    NvimTreeFolderIcon = { fg = p.keyword },
    NvimTreeIndentMarker = { fg = p.border },
    NvimTreeSpecialFile = { fg = p.string },
    NvimTreeExecFile = { fg = p.added },
    NvimTreeSymlink = { fg = p.type },
    NvimTreeImageFile = { fg = p.constant },
    NvimTreeGitDirty = { fg = p.modified },
    NvimTreeGitStaged = { fg = p.added },
    NvimTreeGitNew = { fg = p.added },
    NvimTreeGitDeleted = { fg = p.deleted },
    NvimTreeGitRenamed = { fg = p.renamed },
    NvimTreeGitIgnored = { fg = p.placeholder },
    NvimTreeCursorLine = { bg = p.selected },
    -- telescope
    TelescopeNormal = { fg = p.text, bg = p.elevated },
    TelescopeBorder = { fg = p.border, bg = p.elevated },
    TelescopePromptNormal = { fg = p.text, bg = p.hover },
    TelescopePromptBorder = { fg = p.border, bg = p.hover },
    TelescopePromptTitle = { fg = p.bg, bg = p.accent, bold = true },
    TelescopePromptPrefix = { fg = p.accent, bg = p.hover },
    TelescopePromptCounter = { fg = p.muted, bg = p.hover },
    TelescopePreviewTitle = { fg = p.bg, bg = p.keyword, bold = true },
    TelescopeResultsTitle = { fg = p.bg, bg = p.type, bold = true },
    TelescopeSelection = { fg = p.text, bg = p.selected, bold = true },
    TelescopeSelectionCaret = { fg = p.accent, bg = p.selected },
    TelescopeMatching = { fg = p.accent, bold = true },
    TelescopePreviewLine = { fg = p.bg, bg = p.keyword, bold = true },
    TelescopeResultsDiffAdd = { fg = p.added },
    TelescopeResultsDiffChange = { fg = p.modified },
    TelescopeResultsDiffDelete = { fg = p.deleted },
    -- blink.cmp
    BlinkCmpMenu = { fg = p.text, bg = p.elevated },
    BlinkCmpMenuBorder = { fg = p.border, bg = p.elevated },
    BlinkCmpMenuSelection = { fg = p.bg, bg = p.accent, bold = true },
    BlinkCmpScrollBarThumb = { bg = p.border },
    BlinkCmpScrollBarGutter = { bg = p.elevated },
    BlinkCmpLabel = { fg = p.text },
    BlinkCmpLabelDeprecated = { fg = p.placeholder, strikethrough = true },
    BlinkCmpLabelMatch = { fg = p.accent, bold = true },
    BlinkCmpLabelDetail = { fg = p.muted },
    BlinkCmpLabelDescription = { fg = p.muted },
    BlinkCmpKind = { fg = p.type },
    BlinkCmpKindFunction = { fg = p.func },
    BlinkCmpKindMethod = { fg = p.func },
    BlinkCmpKindConstructor = { fg = p.type },
    BlinkCmpKindVariable = { fg = p.text },
    BlinkCmpKindField = { fg = p.property },
    BlinkCmpKindProperty = { fg = p.property },
    BlinkCmpKindKeyword = { fg = p.keyword },
    BlinkCmpKindText = { fg = p.string },
    BlinkCmpKindSnippet = { fg = p.preproc },
    BlinkCmpKindConstant = { fg = p.constant },
    BlinkCmpKindModule = { fg = p.text },
    BlinkCmpKindClass = { fg = p.type },
    BlinkCmpKindInterface = { fg = p.type },
    BlinkCmpKindStruct = { fg = p.type },
    BlinkCmpKindEnum = { fg = p.type },
    BlinkCmpKindEnumMember = { fg = p.constant },
    BlinkCmpKindFile = { fg = p.text },
    BlinkCmpKindFolder = { fg = p.keyword },
    BlinkCmpDoc = { fg = p.text, bg = p.elevated },
    BlinkCmpDocBorder = { fg = p.border, bg = p.elevated },
    BlinkCmpDocSeparator = { fg = p.border, bg = p.elevated },
    BlinkCmpSignatureHelp = { fg = p.text, bg = p.elevated },
    BlinkCmpSignatureHelpBorder = { fg = p.border, bg = p.elevated },
    BlinkCmpSignatureHelpActiveParameter = { fg = p.accent, bold = true },
    BlinkCmpGhostText = { fg = p.placeholder },
    -- indent-blankline
    IblIndent = { fg = p.border_soft },
    IblWhitespace = { fg = p.border_soft },
    IblScope = { fg = p.border },
    -- bufferline
    BufferLineFill = { bg = p.bg_dark },
    BufferLineBackground = { fg = p.muted, bg = p.bg_dark },
    BufferLineBufferSelected = { fg = p.text, bg = p.bg, bold = true },
    BufferLineBufferVisible = { fg = p.muted, bg = p.bg_dark },
    BufferLineIndicatorSelected = { fg = p.accent, bg = p.bg },
    BufferLineModified = { fg = p.modified, bg = p.bg_dark },
    BufferLineModifiedSelected = { fg = p.modified, bg = p.bg },
    BufferLineSeparator = { fg = p.bg_dark, bg = p.bg_dark },
    BufferLineSeparatorSelected = { fg = p.bg_dark, bg = p.bg },
    BufferLineOffsetSeparator = { fg = p.border, bg = p.bg_dark },
    BufferLineTruncMarker = { fg = p.muted, bg = p.bg_dark },
    -- which-key
    WhichKey = { fg = p.accent },
    WhichKeyGroup = { fg = p.keyword },
    WhichKeyDesc = { fg = p.text },
    WhichKeySeparator = { fg = p.muted },
    WhichKeyNormal = { fg = p.text, bg = p.elevated },
    WhichKeyBorder = { fg = p.border, bg = p.elevated },
    WhichKeyTitle = { fg = p.accent, bg = p.elevated },
    -- neotest
    NeotestPassed = { fg = p.added },
    NeotestFailed = { fg = p.error },
    NeotestRunning = { fg = p.warn },
    NeotestSkipped = { fg = p.muted },
    NeotestAdapterName = { fg = p.keyword, bold = true },
    NeotestDir = { fg = p.keyword },
    NeotestFile = { fg = p.type },
    NeotestNamespace = { fg = p.constant },
    NeotestFocused = { bold = true },
    NeotestIndent = { fg = p.border },
    NeotestExpandMarker = { fg = p.border },
    NeotestWinSelect = { fg = p.accent, bold = true },
    NeotestMarked = { fg = p.warn, bold = true },
    NeotestTarget = { fg = p.accent },
    -- nvim-dap / dap-ui / virtual text
    DapBreakpoint = { fg = p.error },
    DapBreakpointCondition = { fg = p.warn },
    DapLogPoint = { fg = p.info },
    DapStopped = { fg = p.accent },
    DapStoppedLine = { bg = p.highlight_write },
    DapUIScope = { fg = p.keyword },
    DapUIType = { fg = p.type },
    DapUIValue = { fg = p.text },
    DapUIVariable = { fg = p.text },
    DapUIModifiedValue = { fg = p.warn, bold = true },
    DapUIDecoration = { fg = p.border },
    DapUIThread = { fg = p.added },
    DapUIStoppedThread = { fg = p.accent },
    DapUISource = { fg = p.keyword },
    DapUILineNumber = { fg = p.linenr },
    DapUIFloatBorder = { fg = p.border },
    DapUIWatchesEmpty = { fg = p.muted },
    DapUIWatchesValue = { fg = p.added },
    DapUIWatchesError = { fg = p.error },
    DapUIBreakpointsPath = { fg = p.keyword },
    DapUIBreakpointsInfo = { fg = p.added },
    DapUIBreakpointsCurrentLine = { fg = p.accent, bold = true },
    DapUIPlayPause = { fg = p.added },
    DapUIRestart = { fg = p.added },
    DapUIStop = { fg = p.error },
    DapUIStepOver = { fg = p.keyword },
    DapUIStepInto = { fg = p.keyword },
    DapUIStepBack = { fg = p.keyword },
    DapUIStepOut = { fg = p.keyword },
    DapUIUnavailable = { fg = p.placeholder },
    NvimDapVirtualText = { fg = p.inlay, italic = true },
    NvimDapVirtualTextChanged = { fg = p.warn, italic = true },
    NvimDapVirtualTextError = { fg = p.error, italic = true },
    -- nvim-ufo
    UfoFoldedEllipsis = { fg = p.muted },
    UfoFoldedBg = { bg = p.surface },
    -- lazy.nvim / mason
    LazyNormal = { fg = p.text, bg = p.elevated },
    LazyButton = { fg = p.text, bg = p.selected },
    LazyButtonActive = { fg = p.bg, bg = p.accent, bold = true },
    LazyH1 = { fg = p.bg, bg = p.accent, bold = true },
    LazyProgressDone = { fg = p.accent },
    LazyProgressTodo = { fg = p.border },
    LazySpecial = { fg = p.keyword },
    LazyReasonPlugin = { fg = p.constant },
    MasonNormal = { fg = p.text, bg = p.elevated },
    MasonHeader = { fg = p.bg, bg = p.accent, bold = true },
    MasonHighlight = { fg = p.accent },
    MasonHighlightBlock = { fg = p.bg, bg = p.accent },
    MasonHighlightBlockBold = { fg = p.bg, bg = p.accent, bold = true },
    MasonMuted = { fg = p.muted },
    MasonMutedBlock = { fg = p.text, bg = p.selected },
    MasonMutedBlockBold = { fg = p.text, bg = p.selected, bold = true },
    -- flutter-tools / misc
    FlutterToolsOutlineGuides = { fg = p.border },
    ZenBg = { bg = bg },
    -- markdown-preview / render: nothing special
  }

  for name, spec in pairs(o.overrides) do
    h[name] = spec
  end
  return h
end

function M.load()
  if vim.g.colors_name then
    vim.cmd.highlight "clear"
  end
  vim.o.termguicolors = true
  vim.o.background = "dark"
  vim.g.colors_name = "wakaba"

  for name, spec in pairs(highlights()) do
    vim.api.nvim_set_hl(0, name, spec)
  end

  local a = M.palette.ansi
  vim.g.terminal_color_0 = a.black
  vim.g.terminal_color_1 = a.red
  vim.g.terminal_color_2 = a.green
  vim.g.terminal_color_3 = a.yellow
  vim.g.terminal_color_4 = a.blue
  vim.g.terminal_color_5 = a.magenta
  vim.g.terminal_color_6 = a.cyan
  vim.g.terminal_color_7 = a.white
  vim.g.terminal_color_8 = a.bright_black
  vim.g.terminal_color_9 = a.bright_red
  vim.g.terminal_color_10 = a.bright_green
  vim.g.terminal_color_11 = a.bright_yellow
  vim.g.terminal_color_12 = a.bright_blue
  vim.g.terminal_color_13 = a.bright_magenta
  vim.g.terminal_color_14 = a.bright_cyan
  vim.g.terminal_color_15 = a.bright_white
end

return M
