return {
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = { check_ts = true },
  },
  {
    "brenoprata10/nvim-highlight-colors",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      render = "virtual",
      virtual_symbol = "■",
      virtual_symbol_position = "eol",
      enable_named_colors = true,
      enable_tailwind = true,
    },
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = { modes = { char = { enabled = false } } },
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash jump",
      },
      {
        "S",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
    },
  },
  {
    "cbochs/grapple.nvim",
    event = { "BufReadPost", "BufNewFile" },
    cmd = "Grapple",
    opts = { scope = "git", icons = true, status = true },
    keys = {
      { "<leader>a", "<cmd>Grapple toggle<cr>", desc = "Toggle file mark" },
      { "<leader>mm", "<cmd>Grapple toggle_tags<cr>", desc = "Open marks" },
      { "<C-.>", "<cmd>Grapple cycle_tags next<cr>", desc = "Next mark" },
      { "<C-,>", "<cmd>Grapple cycle_tags prev<cr>", desc = "Previous mark" },
      { "<C-h>", "<cmd>Grapple select index=1<cr>", desc = "Mark 1" },
      { "<C-t>", "<cmd>Grapple select index=2<cr>", desc = "Mark 2" },
      { "<C-n>", "<cmd>Grapple select index=3<cr>", desc = "Mark 3" },
      { "<C-s>", "<cmd>Grapple select index=4<cr>", desc = "Mark 4" },
    },
  },
  {
    "mbbill/undotree",
    cmd = "UndotreeToggle",
    keys = { { "<leader>bu", "<cmd>UndotreeToggle<cr>", desc = "Undo tree" } },
  },
}
