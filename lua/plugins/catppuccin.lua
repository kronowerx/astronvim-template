-- Catppuccin theme. The base spec comes from `astrocommunity.colorscheme.catppuccin`,
-- which sets `lazy = true` and `auto_integrations = true`.
--
-- Flavour is pinned in three places on purpose, because catppuccin has two independent
-- resolution paths and they must not disagree:
--
--   * astroui sets `colorscheme = "catppuccin-macchiato"`, whose colors file calls
--     `load "macchiato"` with an explicit argument. This is the authoritative path.
--   * `load()` with NO argument (the bare `catppuccin` name) instead resolves
--     `options.flavour or options.background[vim.o.background]` at load time. If setup()
--     has not run yet, options are defaults and `background.dark` is "mocha" -- so the
--     bare name silently renders mocha. Setting both `flavour` and `background` here means
--     even that path lands on macchiato.
--
-- Do NOT set `lazy = false` or a `priority`: astroui applies the colorscheme from
-- astrocore's setup at priority 10000, so a start-loaded catppuccin at priority 1000 would
-- have `:colorscheme` run before its own setup(), recompiling every flavour twice per
-- launch. With `lazy = true`, lazy.nvim's ColorSchemePre handler loads it at colorscheme
-- time instead.
--
-- Integrations are auto-detected from the plugin spec list, so there is no manual
-- integrations table to keep in sync.
return {
  "catppuccin/nvim",
  opts = {
    flavour = "macchiato",
    background = { light = "latte", dark = "macchiato" },
  },
}
