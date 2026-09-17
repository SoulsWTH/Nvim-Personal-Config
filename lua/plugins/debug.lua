local function dap()
  return require("dap")
end

return {
  {
    "mfussenegger/nvim-dap",
    cmd = {
      "DapContinue",
      "DapEval",
      "DapInstall",
      "DapNew",
      "DapTerminate",
      "DapToggleBreakpoint",
      "DapUninstall",
      "DapViewOpen",
      "DapViewToggle",
    },
    dependencies = {
      {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = { "mason-org/mason.nvim" },
        opts = {
          ensure_installed = { "codelldb" },
          automatic_installation = false,
          handlers = {
            function(config)
              require("mason-nvim-dap").default_setup(config)
            end,
            codelldb = function(config)
              -- Rust has richer Cargo-aware configurations in its adapter
              -- module. Preserve Mason defaults for C/C++ and related types.
              config.filetypes = vim.tbl_filter(function(filetype)
                return filetype ~= "rust"
              end, config.filetypes)
              require("mason-nvim-dap").default_setup(config)
            end,
          },
        },
      },
      {
        "korri123/bun-dap-x",
        build = "bun install --frozen-lockfile && bun run build",
      },
      {
        "igorlfs/nvim-dap-view",
        version = "1.*",
        opts = {
          auto_toggle = true,
          follow_tab = true,
          virtual_text = { enabled = true },
          winbar = {
            controls = { enabled = true, position = "right" },
            default_section = "scopes",
          },
          windows = {
            position = "left",
            size = 0.3,
            terminal = {
              position = "below",
              size = 0.25,
            },
          },
        },
      },
    },
    config = function()
      require("config.debug").setup()
    end,
    keys = {
      { "<leader>db", function() dap().toggle_breakpoint() end, desc = "Toggle breakpoint" },
      {
        "<leader>dB",
        function() dap().set_breakpoint(vim.fn.input("Breakpoint condition: ")) end,
        desc = "Conditional breakpoint",
      },
      { "<leader>dc", function() dap().continue() end, desc = "Start/continue" },
      { "<leader>de", function() require("dap.ui.widgets").hover() end, mode = { "n", "v" }, desc = "Evaluate" },
      { "<leader>dg", function() dap().run_to_cursor() end, desc = "Run to cursor" },
      { "<leader>di", function() dap().step_into() end, desc = "Step into" },
      { "<leader>do", function() dap().step_over() end, desc = "Step over" },
      { "<leader>dO", function() dap().step_out() end, desc = "Step out" },
      { "<leader>dr", function() dap().run_last() end, desc = "Run last" },
      { "<leader>dt", function() dap().terminate() end, desc = "Terminate" },
      { "<leader>du", "<cmd>DapViewToggle<cr>", desc = "Toggle debug UI" },
    },
  },
}
