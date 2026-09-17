local M = {}

local modes = { auto = true, inir = true, oxocarbon = true }

local fallback = {
  bg = "#161616",
  surface = "#262626",
  surface_alt = "#393939",
  muted = "#525252",
  fg = "#f2f4f8",
  subdued = "#dde1e6",
  blue = "#78a9ff",
  cyan = "#3ddbd9",
  green = "#42be65",
  pink = "#ee5396",
  purple = "#be95ff",
  red = "#ff7eb6",
}

local function generated_dir()
  local state_home = vim.env.XDG_STATE_HOME
  if not state_home or state_home == "" then
    state_home = vim.fn.expand("~/.local/state")
  end
  return vim.fs.joinpath(state_home, "quickshell", "user", "generated")
end

local function preference_path()
  return vim.fs.joinpath(vim.fn.stdpath("state"), "theme")
end

local function read_preference()
  local ok, lines = pcall(vim.fn.readfile, preference_path(), "", 1)
  local mode = ok and lines[1] or nil
  return modes[mode] and mode or "auto"
end

local function write_preference(mode)
  vim.fn.mkdir(vim.fn.fnamemodify(preference_path(), ":h"), "p")
  vim.fn.writefile({ mode }, preference_path())
end

local function apply_highlights(highlights)
  for name, value in pairs(highlights) do
    vim.api.nvim_set_hl(0, name, value)
  end
end

function M.has_inir_palette()
  local dir = generated_dir()
  return vim.fn.filereadable(vim.fs.joinpath(dir, "palette.json")) == 1
    or vim.fn.filereadable(vim.fs.joinpath(dir, "colors.json")) == 1
end

function M.inir_opts()
  return {
    generated_dir = generated_dir(),
    live_reload = true,
    terminal_colors = true,
    transparent = true,
    on_highlights = function(hl, colors)
      hl.NormalNC = { fg = colors.dark_fg, bg = "NONE" }
      hl.EndOfBuffer = { fg = colors.bg, bg = "NONE" }
      hl.FoldColumn = { fg = colors.muted, bg = "NONE" }
      hl.SignColumn = { fg = colors.dark_fg, bg = "NONE" }
      hl.FloatBorder = { fg = colors.muted, bg = colors.bg }
      hl.NormalFloat = { fg = colors.fg, bg = colors.bg }
      hl.Pmenu = { fg = colors.fg, bg = colors.dark_bg }
      hl.PmenuSel = { fg = colors.fg, bg = colors.lighter_bg, bold = true }
      hl.WinSeparator = { fg = colors.lighter_bg }

      hl.BlinkCmpMenu = { fg = colors.fg, bg = colors.dark_bg }
      hl.BlinkCmpMenuBorder = { fg = colors.muted, bg = colors.dark_bg }
      hl.BlinkCmpMenuSelection = { fg = colors.fg, bg = colors.lighter_bg, bold = true }
      hl.BlinkCmpKindFunction = { fg = colors.blue }
      hl.BlinkCmpKindMethod = { fg = colors.blue }
      hl.BlinkCmpKindVariable = { fg = colors.cyan }
      hl.BlinkCmpKindClass = { fg = colors.purple }
      hl.BlinkCmpKindInterface = { fg = colors.purple }
      hl.BlinkCmpKindSnippet = { fg = colors.green }
      hl.BlinkCmpKindKeyword = { fg = colors.orange }

      -- inir.nvim reloads itself when the wallpaper palette changes. Rebuild
      -- lualine's cached theme after those new highlights have been applied.
      if package.loaded.lualine then
        vim.schedule(function()
          require("lualine").setup()
        end)
      end
    end,
  }
end

local function refresh_lualine()
  if package.loaded.lualine then
    vim.schedule(function()
      require("lualine").setup()
    end)
  end
end

local function load_oxocarbon()
  vim.cmd.colorscheme("oxocarbon")
  apply_highlights({
    Normal = { fg = fallback.fg, bg = "none" },
    NormalNC = { fg = fallback.subdued, bg = "none" },
    EndOfBuffer = { fg = fallback.bg, bg = "none" },
    FoldColumn = { fg = fallback.muted, bg = "none" },
    SignColumn = { fg = fallback.subdued, bg = "none" },
    FloatBorder = { fg = fallback.muted, bg = fallback.bg },
    NormalFloat = { bg = fallback.bg },
    Pmenu = { bg = fallback.surface, fg = fallback.fg },
    PmenuSel = { bg = fallback.surface_alt, fg = fallback.fg, bold = true },
    WinSeparator = { fg = fallback.surface_alt },
    BlinkCmpMenu = { bg = fallback.surface, fg = fallback.fg },
    BlinkCmpMenuBorder = { fg = fallback.muted, bg = fallback.surface },
    BlinkCmpMenuSelection = { bg = fallback.surface_alt, fg = fallback.fg, bold = true },
    BlinkCmpKindFunction = { fg = fallback.blue },
    BlinkCmpKindMethod = { fg = fallback.blue },
    BlinkCmpKindVariable = { fg = fallback.cyan },
    BlinkCmpKindClass = { fg = fallback.purple },
    BlinkCmpKindInterface = { fg = fallback.purple },
    BlinkCmpKindSnippet = { fg = fallback.green },
    BlinkCmpKindKeyword = { fg = fallback.pink },
  })
end

function M.use(mode, persist)
  if not modes[mode] then
    error("Unknown theme mode: " .. tostring(mode))
  end

  vim.opt.background = "dark"

  local selected = mode
  if selected == "auto" then
    selected = M.has_inir_palette() and "inir" or "oxocarbon"
  end

  if selected == "inir" then
    if not M.has_inir_palette() then
      vim.notify("iNiR palette not found; keeping " .. (vim.g.colors_name or "the current theme"), vim.log.levels.WARN)
      return false
    end
    vim.cmd.colorscheme("inir")
  else
    load_oxocarbon()
  end

  if persist then
    write_preference(mode)
  end
  refresh_lualine()
  return true
end

function M.load()
  local mode = read_preference()
  if mode == "inir" and not M.has_inir_palette() then
    mode = "oxocarbon"
  end
  M.use(mode, false)
end

function M.setup_commands()
  vim.api.nvim_create_user_command("ThemeToggle", function()
    local target = vim.g.colors_name == "inir" and "oxocarbon" or "inir"
    if M.use(target, true) then
      vim.notify("Theme: " .. target)
    end
  end, { desc = "Toggle between iNiR and Oxocarbon", force = true })

  vim.api.nvim_create_user_command("ThemeUse", function(opts)
    if M.use(opts.args, true) then
      local selected = opts.args == "auto" and (vim.g.colors_name or "auto") or opts.args
      vim.notify("Theme: " .. selected .. (opts.args == "auto" and " (auto)" or ""))
    end
  end, {
    nargs = 1,
    desc = "Select and persist a theme mode",
    force = true,
    complete = function(arg_lead)
      return vim.iter(vim.tbl_keys(modes)):filter(function(mode)
        return vim.startswith(mode, arg_lead)
      end):totable()
    end,
  })
end

function M.lualine_theme()
  if vim.g.colors_name == "inir" then
    return "inir"
  end

  return {
    normal = {
      a = { fg = fallback.bg, bg = fallback.blue, gui = "bold" },
      b = { fg = fallback.fg, bg = fallback.surface_alt },
      c = { fg = fallback.subdued, bg = fallback.surface },
    },
    insert = { a = { fg = fallback.bg, bg = fallback.green, gui = "bold" } },
    visual = { a = { fg = fallback.bg, bg = fallback.purple, gui = "bold" } },
    replace = { a = { fg = fallback.bg, bg = fallback.red, gui = "bold" } },
    command = { a = { fg = fallback.bg, bg = fallback.pink, gui = "bold" } },
    inactive = { c = { fg = fallback.muted, bg = fallback.bg } },
  }
end

return M
