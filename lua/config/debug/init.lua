local M = {}

local signs = {
  DapBreakpoint = { text = "", texthl = "DiagnosticError" },
  DapBreakpointCondition = { text = "", texthl = "DiagnosticWarn" },
  DapBreakpointRejected = { text = "", texthl = "DiagnosticError" },
  DapLogPoint = { text = "◆", texthl = "DiagnosticInfo" },
  DapStopped = { text = "", texthl = "DiagnosticOk", linehl = "CursorLine" },
}

function M.setup()
  local dap = require("dap")

  for name, sign in pairs(signs) do
    vim.fn.sign_define(name, sign)
  end

  -- Adapters supplied by applications, or adapters that need behavior beyond
  -- mason-nvim-dap's defaults, live in their own modules here.
  require("config.debug.adapters").setup(dap)
end

return M
