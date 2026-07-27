-- Catppuccin theme. The base spec comes from `astrocommunity.colorscheme.catppuccin`,
-- which sets `lazy = true` and `auto_integrations = true`.
--
-- Two things matter here and are easy to get wrong:
--
-- 1. Do NOT set `lazy = false` or a `priority`. astroui applies the colorscheme from
--    astrocore's setup at priority 10000; a start-loaded catppuccin at priority 1000
--    would have `:colorscheme` run BEFORE its own setup(), so these opts would never
--    apply and every flavour would be compiled twice per launch. With `lazy = true`,
--    lazy.nvim's ColorSchemePre handler loads the plugin at colorscheme time, so
--    setup() is guaranteed to run first.
-- 2. `flavour` only has an effect because astroui uses the bare `catppuccin` name.
--    A suffixed name like `catppuccin-macchiato` passes the flavour explicitly and
--    would make this setting inert.
--
-- Integrations are auto-detected from the plugin spec list, so there is no manual
-- integrations table to keep in sync.
return {
  "catppuccin/nvim",
  opts = { flavour = "macchiato" },
}
