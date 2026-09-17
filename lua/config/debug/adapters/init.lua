local M = {}

local adapters = {
  "bun",
  "godot",
  "rust",
}

function M.setup(dap)
  for _, name in ipairs(adapters) do
    require("config.debug.adapters." .. name).setup(dap)
  end
end

return M
