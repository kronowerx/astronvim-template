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
  -- NOTE: the `-` mapping lives in plugins/astrocore.lua, not in a `config` function here.
  -- With it gone there is nothing left for `config` to do that lazy.nvim's default
  -- `require("oil").setup(opts)` does not already do.
}
