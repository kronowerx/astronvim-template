-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",

  -- Language/format setup is owned by these packs. They supply the LSP servers, treesitter
  -- parsers, formatters, linters and Mason packages for each language; `lua/plugins/` only
  -- overrides where this config genuinely disagrees.
  --
  -- NOTE: `pack.helm` must stay FIRST. Its astrocore fragment is a *function* calling
  -- `extend_tbl` (`tbl_deep_extend "force"`), which list-REPLACES `treesitter.ensure_installed`
  -- rather than appending. Every other pack declares that key as a plain table and so appends
  -- via astrocore's `opts_extend = { "treesitter.ensure_installed" }`. Any pack imported
  -- *before* helm would have its parsers silently discarded; anything after is safe.
  { import = "astrocommunity.pack.helm" },

  { import = "astrocommunity.pack.bash" }, -- also attaches bashls to zsh (upstream: experimental)
  { import = "astrocommunity.pack.docker" }, -- transitively imports pack.yaml
  { import = "astrocommunity.pack.go" },
  { import = "astrocommunity.pack.json" },
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.markdown" },
  -- Deliberately NOT `astrocommunity.pack.python`, which is base + basedpyright + black +
  -- isort. basedpyright would be a second type checker running alongside pyrefly, and
  -- black/isort a second formatter chain alongside ruff. These three subpacks are the same
  -- pyrefly + ruff pairing this config already ran by hand; see the ruff `lint.ignore` list
  -- in plugins/astrolsp.lua for how the overlapping diagnostics are deduplicated.
  { import = "astrocommunity.pack.python.base" },
  { import = "astrocommunity.pack.python.pyrefly" },
  { import = "astrocommunity.pack.python.ruff" },
  { import = "astrocommunity.pack.rust" }, -- transitively imports pack.toml
  { import = "astrocommunity.pack.toml" },
  { import = "astrocommunity.pack.yaml" },

  -- conform owns all formatting: disables AstroLSP's format-on-save and none-ls's
  -- formatting sources, and provides <Leader>lf/<Leader>uf/<Leader>uF + :Format
  { import = "astrocommunity.editing-support.conform-nvim" },
  -- Sets lazy = true (so setup() runs before the colorscheme applies) and
  -- auto_integrations = true. Flavour is overridden in plugins/catppuccin.lua.
  { import = "astrocommunity.colorscheme.catppuccin" },
  -- import/override with your plugins folder
}
