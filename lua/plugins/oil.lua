return {
  "stevearc/oil.nvim",
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {
    watch_for_changes = true,
    view_options = { show_hidden = true },
    float = {
      max_height = 0.8,
      max_width = 0.8,
    },
  },
  -- Optional dependencies
  dependencies = { { "nvim-mini/mini.icons", opts = {} } },
  -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
  -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
  lazy = false,
  config = function(_, opts)
    require("oil").setup(opts)
    vim.keymap.set("n", "-", "<CMD>Oil --float<CR>", { desc = "Open parent directory" })
  end,
}
