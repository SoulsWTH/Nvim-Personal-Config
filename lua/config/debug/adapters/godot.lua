local M = {}

function M.setup(dap)
  local port = tonumber(vim.env.GODOT_DAP_PORT) or 6006

  dap.adapters.godot = {
    type = "server",
    host = "127.0.0.1",
    port = port,
  }

  dap.configurations.gdscript = {
    {
      type = "godot",
      request = "launch",
      name = "Godot: Launch scene",
      project = "${workspaceFolder}",
    },
  }
end

return M
