local M = {}

local function jump_to_definition()
  vim.lsp.buf.definition({
    on_list = function(locations)
      -- Neovim opens quickfix when the LSP returns multiple definitions.
      -- Keep those alternatives in the window-local list, but jump directly.
      vim.fn.setloclist(0, {}, " ", locations)
      vim.cmd.lfirst()
    end,
  })
end

function M.on_attach(event)
  local client = vim.lsp.get_client_by_id(event.data.client_id)
  if not client then
    return
  end

  local function map(lhs, rhs, desc, modes)
    vim.keymap.set(modes or "n", lhs, rhs, { buffer = event.buf, desc = desc })
  end

  map("gd", function()
    Snacks.picker.lsp_definitions()
  end, "Go to definition")
  map("<leader>gd", jump_to_definition, "Jump to definition")
  map("gD", vim.lsp.buf.declaration, "Go to declaration")
  map("gri", function()
    Snacks.picker.lsp_implementations()
  end, "Go to implementation")
  map("grr", function()
    Snacks.picker.lsp_references()
  end, "Show references")
  map("grt", function()
    Snacks.picker.lsp_type_definitions()
  end, "Go to type definition")
  map("K", vim.lsp.buf.hover, "Hover documentation")

  map("<leader>ca", vim.lsp.buf.code_action, "Code action", { "n", "x" })
  map("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
  map("<leader>cs", function()
    Snacks.picker.lsp_symbols()
  end, "Document symbols")
  map("<leader>cS", function()
    Snacks.picker.lsp_workspace_symbols()
  end, "Workspace symbols")
  map("<leader>cd", vim.diagnostic.open_float, "Line diagnostics")
  map("<leader>cc", vim.lsp.codelens.run, "Run code lens")
  map("<leader>cC", vim.lsp.codelens.refresh, "Refresh code lens")

  if client:supports_method("textDocument/inlayHint") then
    map("<leader>uh", function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }), { bufnr = event.buf })
    end, "Toggle inlay hints")
  end

  if client:supports_method("textDocument/documentHighlight") then
    local group = vim.api.nvim_create_augroup("lsp-highlight-" .. event.buf, { clear = true })
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      group = group,
      buffer = event.buf,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
      group = group,
      buffer = event.buf,
      callback = vim.lsp.buf.clear_references,
    })
  end
end

return M
