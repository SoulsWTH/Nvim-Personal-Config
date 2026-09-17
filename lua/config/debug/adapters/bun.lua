local M = {}

local filetypes = {
  "javascript",
  "javascriptreact",
  "typescript",
  "typescriptreact",
}

local function adapter_executable()
  local plugin = require("lazy.core.config").plugins["bun-dap-x"]
  if not plugin then
    return "bun-dap-x"
  end
  return vim.fs.joinpath(plugin.dir, "dist", "bun-dap-x")
end

local function program_arguments()
  local input = vim.fn.input("Program arguments: ")
  return vim.split(input, "%s+", { trimempty = true })
end

function M.setup(dap)
  dap.adapters["bun-dap-x"] = {
    type = "executable",
    command = adapter_executable(),
  }

  local configurations = {
    {
      type = "bun-dap-x",
      request = "launch",
      name = "Bun: Current file",
      program = "${file}",
      cwd = "${workspaceFolder}",
      runtime = "bun",
      args = {},
      runtimeArgs = {},
      stopOnEntry = false,
    },
    {
      type = "bun-dap-x",
      request = "launch",
      name = "Bun: Current file with arguments",
      program = "${file}",
      cwd = "${workspaceFolder}",
      runtime = "bun",
      args = program_arguments,
      runtimeArgs = {},
      stopOnEntry = false,
    },
    {
      type = "bun-dap-x",
      request = "launch",
      name = "Bun: Test current file",
      program = "${file}",
      cwd = "${workspaceFolder}",
      runtime = "bun",
      runtimeArgs = { "test" },
      args = {},
      stopOnEntry = false,
      disableTestTimeout = true,
    },
  }

  for _, filetype in ipairs(filetypes) do
    dap.configurations[filetype] = configurations
  end
end

return M
