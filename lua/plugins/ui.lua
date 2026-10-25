local function project_cwd()
  return vim.g.esteban_start_cwd or vim.fn.getcwd()
end

return {
  {
    "yukazakiri/inir.nvim",
    lazy = false,
    priority = 1100,
    dependencies = { "nyoom-engineering/oxocarbon.nvim" },
    opts = function()
      return require("config.theme").inir_opts()
    end,
    config = function(_, opts)
      require("inir").setup(opts)
      local theme = require("config.theme")
      theme.setup_commands()
      theme.load()
    end,
    keys = {
      { "<leader>ut", "<cmd>ThemeToggle<cr>", desc = "Toggle iNiR colors" },
    },
  },
  {
    "echasnovski/mini.icons",
    lazy = true,
    opts = { style = "glyph" },
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      dashboard = {
        enabled = true,
        preset = {
          header = [[
 ███╗   ██╗██╗   ██╗██╗███╗   ███╗
 ████╗  ██║██║   ██║██║████╗ ████║
 ██╔██╗ ██║██║   ██║██║██╔████╔██║
 ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║
 ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║
 ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝]],
          keys = {
            { icon = " ", key = "f", desc = "Find file", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = " ", key = "n", desc = "New file", action = ":ene | startinsert" },
            { icon = " ", key = "r", desc = "Recent files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            { icon = " ", key = "g", desc = "Find text", action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = " ", key = "k", desc = "Keymaps", action = ":lua Snacks.picker.keymaps()" },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
      },
      explorer = { enabled = true },
      indent = {
        enabled = true,
        animate = { enabled = false },
        scope = { enabled = true },
      },
      input = { enabled = true },
      notifier = { enabled = true, timeout = 3000 },
      picker = {
        enabled = true,
        ui_select = true,
        layout = { preset = "ivy" },
      },
      quickfile = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
    },
    keys = {
      {
        "<leader><space>",
        function()
          Snacks.picker.smart()
        end,
        desc = "Smart find files",
      },
      {
        "<leader>e",
        function()
          Snacks.explorer({ cwd = project_cwd() })
        end,
        desc = "File explorer",
      },
      {
        "<leader>ff",
        function()
          Snacks.picker.files()
        end,
        desc = "Find files",
      },
      {
        "<leader>fg",
        function()
          Snacks.picker.grep()
        end,
        desc = "Find text",
      },
      {
        "<leader>fb",
        function()
          Snacks.picker.buffers()
        end,
        desc = "Find buffers",
      },
      {
        "<leader>fr",
        function()
          Snacks.picker.recent()
        end,
        desc = "Recent files",
      },
      {
        "<leader>fp",
        function()
          Snacks.picker.projects()
        end,
        desc = "Projects",
      },
      {
        "<leader>fh",
        function()
          Snacks.picker.help()
        end,
        desc = "Help pages",
      },
      {
        "<leader>fk",
        function()
          Snacks.picker.keymaps()
        end,
        desc = "Keymaps",
      },
      {
        "<leader>fc",
        function()
          Snacks.picker.commands()
        end,
        desc = "Commands",
      },
      {
        "<leader>fn",
        function()
          Snacks.picker.notifications()
        end,
        desc = "Notification history",
      },
      {
        "<leader>gB",
        function()
          Snacks.picker.git_branches()
        end,
        desc = "Git branches",
      },
      {
        "<leader>gl",
        function()
          Snacks.lazygit()
        end,
        desc = "LazyGit",
      },
      {
        "<leader>un",
        function()
          Snacks.notifier.hide()
        end,
        desc = "Dismiss notifications",
      },
      {
        "<leader>z",
        function()
          Snacks.zen()
        end,
        desc = "Zen mode",
      },
      {
        "<C-`>",
        function()
          Snacks.terminal()
        end,
        desc = "Toggle terminal",
      },
    },
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          _G.dd = function(...)
            Snacks.debug.inspect(...)
          end
          vim.print = _G.dd
        end,
      })
    end,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      delay = 250,
      icons = { mappings = true },
      spec = {
        { "<leader>b", group = "buffers" },
        { "<leader>c", group = "code" },
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git / navigation" },
        { "<leader>m", group = "marks" },
        { "<leader>q", group = "quit/session" },
        { "<leader>d", group = "debug" },
        { "<leader>u", group = "ui toggles" },
        { "<leader>w", group = "write/window" },
        { "<leader>x", group = "diagnostics" },
      },
      win = { border = "rounded" },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer keymaps",
      },
    },
  },
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = { focus = true },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Workspace diagnostics" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer diagnostics" },
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false win.position=right<cr>", desc = "Document symbols" },
      { "<leader>xl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP locations" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix list" },
      {
        "[q",
        function()
          require("trouble").prev({ skip_groups = true, jump = true })
        end,
        desc = "Previous trouble item",
      },
      {
        "]q",
        function()
          require("trouble").next({ skip_groups = true, jump = true })
        end,
        desc = "Next trouble item",
      },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "echasnovski/mini.icons" },
    opts = function()
      return {
        options = {
          theme = require("config.theme").lualine_theme,
          globalstatus = true,
          component_separators = { left = "│", right = "│" },
          section_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = { { "mode", icon = "" } },
          lualine_b = { "branch", "diff" },
          lualine_c = { { "filename", path = 1, symbols = { modified = " ●", readonly = " " } } },
          lualine_x = {
            {
              function()
                return "  " .. require("dap").status()
              end,
              cond = function()
                return package.loaded.dap and require("dap").status() ~= ""
              end,
            },
            {
              function()
                local clients = vim.lsp.get_clients({ bufnr = 0 })
                if #clients == 0 then
                  return ""
                end
                return "  "
                  .. table.concat(
                    vim.tbl_map(function(client)
                      return client.name
                    end, clients),
                    ", "
                  )
              end,
            },
            "diagnostics",
            "filetype",
          },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        extensions = { "lazy", "mason", "quickfix" },
      }
    end,
  },
}
