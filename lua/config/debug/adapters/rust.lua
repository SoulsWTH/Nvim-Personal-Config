local M = {}

local function codelldb_executable()
  local executable = vim.fn.exepath("codelldb")
  if executable ~= "" then
    return executable
  end
  return vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin", "codelldb")
end

local function program_arguments()
  local input = vim.fn.input("Program arguments: ")
  return vim.split(input, "%s+", { trimempty = true })
end

function M.setup(dap)
  -- Defining this eagerly means the configuration is ready even while Mason
  -- is completing its first CodeLLDB installation.
  dap.adapters.codelldb = {
    type = "executable",
    command = codelldb_executable(),
  }

  dap.configurations.rust = {
    {
      type = "codelldb",
      request = "launch",
      name = "Rust: Cargo build",
      cargo = {
        args = { "build" },
        cwd = "${workspaceFolder}",
      },
      cwd = "${workspaceFolder}",
      args = program_arguments,
      sourceLanguages = { "rust" },
      terminal = "integrated",
      stopOnEntry = false,
    },
    {
      type = "codelldb",
      request = "launch",
      name = "Rust: Cargo test",
      cargo = {
        args = { "test", "--no-run" },
        cwd = "${workspaceFolder}",
      },
      cwd = "${workspaceFolder}",
      args = {},
      sourceLanguages = { "rust" },
      terminal = "integrated",
      stopOnEntry = false,
    },
    {
      type = "codelldb",
      request = "launch",
      name = "Rust: Select executable",
      program = function()
        return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
      end,
      cwd = "${workspaceFolder}",
      args = program_arguments,
      sourceLanguages = { "rust" },
      terminal = "integrated",
      stopOnEntry = false,
    },
    {
      type = "codelldb",
      request = "attach",
      name = "Rust: Attach to process",
      pid = require("dap.utils").pick_process,
      cwd = "${workspaceFolder}",
      sourceLanguages = { "rust" },
    },
  }
end

return M
