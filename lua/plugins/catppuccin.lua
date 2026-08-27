-- Catppuccin theme. The base spec comes from `astrocommunity.colorscheme.catppuccin`,
-- which sets `lazy = true` and `auto_integrations = true`.
--
-- Flavour is pinned in three places on purpose, because the name `catppuccin` has three
-- independent claimants on the runtimepath and they must not disagree:
--
--   * astroui sets `colorscheme = "catppuccin-frappe"`, whose colors file calls
--     `load "frappe"` with an explicit argument. This is the authoritative path, and
--     the only one of the three that is unambiguous -- no other runtime file claims the
--     suffixed name.
--   * `load()` with NO argument (the bare `catppuccin` name) instead resolves
--     `options.flavour or options.background[vim.o.background]` at load time. If setup()
--     has not run yet, options are defaults -- whatever the plugin ships in
--     `background.dark`, which is not ours to rely on. Setting both `flavour` and
--     `background` here means even that path lands on frappe deliberately.
--   * Neovim 0.12 ships its OWN `$VIMRUNTIME/colors/catppuccin.vim`, so the bare name is
--     now genuinely ambiguous: the plugin's `colors/catppuccin.lua` only wins on rtp order.
--     This is why the AstroNvim v6 migration guide tells users to rename `catppuccin` ->
--     `catppuccin-nvim`. Do NOT follow that advice here. The plugin's
--     `colors/catppuccin-nvim.vim` is a one-liner calling `require("catppuccin").load()`
--     with no argument -- i.e. it disambiguates the plugin-vs-builtin collision by opting
--     into the non-deterministic flavour path above. The suffixed name already sidesteps
--     both problems.
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
    flavour = "frappe",
    background = { light = "latte", dark = "frappe" },
  },
}
