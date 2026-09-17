return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = function()
      local icons = require("config.icons").git
      return {
        signs = {
          add = { text = icons.added },
          change = { text = icons.modified },
          delete = { text = icons.removed },
          topdelete = { text = icons.removed },
          changedelete = { text = icons.modified },
          untracked = { text = icons.added },
        },
        current_line_blame = false,
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local function map(lhs, rhs, desc, mode)
            vim.keymap.set(mode or "n", lhs, rhs, { buffer = bufnr, desc = desc })
          end
          map("]h", function()
            if vim.wo.diff then
              vim.cmd.normal({ "]h", bang = true })
            else
              gs.nav_hunk("next")
            end
          end, "Next Git hunk", "n")
          map("[h", function()
            if vim.wo.diff then
              vim.cmd.normal({ "[h", bang = true })
            else
              gs.nav_hunk("prev")
            end
          end, "Previous Git hunk", "n")
          map("<leader>gs", gs.stage_hunk, "Stage hunk", { "n", "x" })
          map("<leader>gr", gs.reset_hunk, "Reset hunk", { "n", "x" })
          map("<leader>gp", gs.preview_hunk, "Preview hunk")
          map("<leader>gb", gs.blame_line, "Blame line")
          map("<leader>gD", gs.diffthis, "Diff against index")
          map("<leader>gL", function() gs.blame_line({ full = true }) end, "Full blame")
          map("<leader>ug", gs.toggle_current_line_blame, "Toggle Git blame")
        end,
      }
    end,
  },
}
