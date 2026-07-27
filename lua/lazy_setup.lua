require("lazy").setup({
  {
    "AstroNvim/AstroNvim",
    version = "^6", -- Remove version tracking to elect for nightly AstroNvim
    import = "astronvim.plugins",
    opts = { -- AstroNvim options must be set here with the `import` key
      mapleader = " ", -- This ensures the leader key must be configured before Lazy is set up
      maplocalleader = ",", -- This ensures the localleader key must be configured before Lazy is set up
      icons_enabled = true, -- Set to false to disable icons (if no Nerd Font is available)
      pin_plugins = nil, -- Default will pin plugins when tracking `version` of AstroNvim, set to true/false to override
      -- NOTE: singular. The official AstroNvim template ships this as `update_notifications`,
      -- but the only read site is `astronvim.config.update_notification` -- the plural key is
      -- never consulted.
      update_notification = true, -- notify about running `:Lazy update` twice to update pinned plugins
    },
  },
  { import = "community" },
  { import = "plugins" },
} --[[@as LazySpec]], {
  -- Configure any other `lazy.nvim` configuration options here
  concurrency = 4, -- avoid splitting proxy bandwidth so thin that each fetch times out
  git = {
    timeout = 300, -- don't kill slow-but-progressing fetches through the proxy (was 120)
  },
  install = { colorscheme = { "catppuccin-macchiato", "astrotheme", "habamax" } },
  ui = { backdrop = 100 },
  performance = {
    rtp = {
      -- disable some rtp plugins, add more to your liking
      disabled_plugins = {
        "gzip",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "zipPlugin",
      },
    },
  },
} --[[@as LazyConfig]])
