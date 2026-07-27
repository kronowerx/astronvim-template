-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.helm" },
  -- conform owns all formatting: disables AstroLSP's format-on-save and none-ls's
  -- formatting sources, and provides <Leader>lf/<Leader>uf/<Leader>uF + :Format
  { import = "astrocommunity.editing-support.conform-nvim" },
  -- Sets lazy = true (so setup() runs before the colorscheme applies) and
  -- auto_integrations = true. Flavour is overridden in plugins/catppuccin.lua.
  { import = "astrocommunity.colorscheme.catppuccin" },
  -- import/override with your plugins folder
}
