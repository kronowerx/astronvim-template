# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A personal Neovim config built on the [AstroNvim](https://github.com/AstroNvim/AstroNvim) v6 user template, managed by `lazy.nvim`. It lives at `~/.config/nvim` — editing a file here changes the running editor; there is no build step and no test suite.

Currently running against Neovim 0.12.4.

## Research before configuring

Do not configure a plugin from memory. Plugin APIs and AstroNvim's own layout change between versions, and this config tracks AstroNvim `^6` — recalled option names are frequently stale.

Before adding or changing any plugin spec:

1. **Read the upstream README/docs via the GitHub MCP tools** (`mcp__github__get_file_contents`, `mcp__github__search_code`) for the plugin's actual repo. Confirm the current option names, defaults, and setup contract rather than assuming.
2. **Check the AstroNvim docs at <https://docs.astronvim.com/>** for anything touching AstroCore, AstroLSP, AstroUI, or the community modules — especially the recipes/advanced pages, which document the merge-order behaviour this config depends on.
3. For an AstroCommunity module, read the module source directly (`~/.local/share/nvim/lazy/astrocommunity/lua/astrocommunity/...`) to see exactly what it sets before you override it. This is how the formatting rules below were established.

When fetching docs with `curl`, always bypass the proxy — the shell sets `HTTP_PROXY`/`HTTPS_PROXY` and curl picks them up automatically:

```sh
curl --noproxy '*' -sSL https://docs.astronvim.com/configuration/core_plugins/
```

## Verification

There is nothing to build or test. To check that a change loads cleanly, drive a headless instance and assert on resolved state — this is the established pattern in this repo (see the allowlist in `.claude/settings.local.json` for previously-used invocations):

```sh
# does it load at all, and what did the settings resolve to?
timeout 60 nvim --headless "+lua vim.defer_fn(function() \
  print('colorscheme=' .. (vim.g.colors_name or '?')); \
  print('expandtab=' .. tostring(vim.o.expandtab) .. ' ts=' .. vim.o.tabstop); \
  vim.cmd 'qa' end, 2000)"

# inspect a merged plugin config (astrolsp shown; same idea for conform, astrocore)
timeout 60 nvim --headless "+lua vim.defer_fn(function() \
  print(vim.inspect(require('astrolsp').config.formatting)); vim.cmd 'qa' end, 1500)"

timeout 60 nvim --headless "+Lazy! sync" +qa   # install/update plugins
```

Note for anything LSP-related: on Neovim 0.12 nvim-lspconfig creates **no `Lsp*` user commands**
(`plugin/lspconfig.lua` early-returns when the builtin `:lsp` exists). Use `:lsp restart`,
`:lsp info`, etc. — `:LspRestart` and friends do not exist, and a `cmd = { "Lsp*" }` lazy trigger
will never fire.

The `vim.defer_fn` wrapper is required — plugins load lazily, so state read at startup is not yet final.

Lint and format the config itself with the Mason-installed binaries (`~/.local/share/nvim/mason/bin/` — not on `PATH`):

```sh
~/.local/share/nvim/mason/bin/stylua .    # .stylua.toml: 2-space, 120 col, no call parens
~/.local/share/nvim/mason/bin/selene .    # selene.toml + neovim.yml std
```

Note the deliberate mismatch: the editor's global indent options are 4-wide hard tabs (`astrocore.lua`), but this repo's own Lua is formatted by stylua to 2-wide spaces. Format config files with stylua rather than trusting the editor defaults.

## Architecture

### Spec merge order is the load-bearing invariant

`lua/lazy_setup.lua` imports three sources, **in this order**:

1. `astronvim.plugins` — AstroNvim's own defaults
2. `lua/community.lua` — AstroCommunity modules
3. `lua/plugins/` — this repo's overrides

lazy.nvim deep-merges same-plugin fragments, and **later fragments win**. Nearly every non-obvious comment in this repo exists because of that rule. Before adding an `opts` key, check whether an earlier layer already set it and what happens when yours merges on top.

Two specific traps:

- **`opts` as a table vs. a function.** A plain table deep-merges; a function receives `opts` and can wholesale-reassign it, silently dropping earlier defaults. `plugins/astrocore.lua` must stay a plain table for exactly this reason (AstroNvim's `_astrocore_options.lua` is an earlier *function* fragment that assigns `opts.options`; a table here merges on top and its defaults survive). `plugins/conform.lua` is a function because it needs to append to existing sub-tables.
- **Merging over something you meant to leave alone.** Setting a key that an earlier layer intentionally disabled re-enables it. See formatting, below.

### conform owns all formatting

`community.lua` imports `astrocommunity.editing-support.conform-nvim`, which sets `astrolsp.formatting.disabled = true`, sets mason-null-ls's `methods.formatting = false`, and supplies `:Format`, `<Leader>lf`, `<Leader>lc`, `<Leader>uf`, `<Leader>uF`.

Consequences:

- **Never add a `formatting` block to `plugins/astrolsp.lua`.** It merges *over* `disabled = true` and re-enables AstroLSP's `BufWritePre` formatter, so every file gets formatted twice.
- **Never set `opts.format_on_save` in `plugins/conform.lua`.** The community module installs a *function* there, gated on `vim.b/vim.g.autoformat`; a table replaces it and breaks the autoformat toggles. Raise the save-path budget via `default_format_opts.timeout_ms` instead (currently 1500ms, synchronous, blocks `:w`).
- Visual-mode `<Leader>lf` is defined in `astrocore.lua` because the community module only maps normal mode and AstroLSP's visual mapping is suppressed.

Go formatting is dynamic: `conform.lua` reads `module` out of the nearest `go.mod` and passes it to
`gci`'s prefix section, so import grouping follows the project rather than a hardcoded org. The chain is
`goimports` → `gofumpt` → `gci`; only gci decides the final grouping, so do **not** re-add
`goimports -local` (its output is overwritten — verified by diffing the chain with and without it).
gci's `args` is a function, which replaces conform's built-in arg table wholesale — `--skip-generated`
and `--skip-vendor` must be repeated there or vendored code gets rewritten.

### Python: pyrefly + ruff, deduplicated by hand

Both attach. Ruff's overlapping codes are ignored in `astrolsp.lua` (`F401`, `F821`, `I001`) so a line never gets two diagnostics for the same problem. `F841` is deliberately *not* ignored — pyrefly only reports it inside annotated functions. If you find another duplicated pair, add its code to that ignore list rather than disabling ruff.

### Colorscheme flavour is pinned in three places

Catppuccin has two independent flavour-resolution paths that must agree. `astroui.lua` sets the **suffixed** name `catppuccin-macchiato` (whose colors file calls `load "macchiato"` explicitly); `plugins/catppuccin.lua` sets both `flavour` and `background.dark` so the bare-`catppuccin` path can't fall back to mocha. Do not give catppuccin `lazy = false` or a `priority` — the colorscheme is applied at the end of **astrocore's** setup (`astrocore/init.lua` calls `astroui.set_colorscheme()`), and astrocore is the `lazy = false, priority = 10000` start plugin; astroui itself is `lazy = true` upstream. So a start-loaded catppuccin would run `:colorscheme` before its own `setup()` and recompile every flavour twice per launch.

### Inert template stubs

`lua/plugins/user.lua`, `lua/plugins/none-ls.lua`, and `lua/plugins/treesitter.lua` all begin with `if true then return {} end`. **Editing them has no effect** until that line is removed. Treesitter config in particular is a red herring — parsers are configured through AstroCore's `treesitter` table, not through the nvim-treesitter spec.

The none-ls stub is the misleading one: only the *spec* is inert. none-ls itself still loads from AstroNvim's base config, and `mason-null-ls` auto-registers a diagnostics source for every installed Mason package that maps to one — currently `hadolint` and `selene`, both live. The community conform module only turns off the *formatting* method, so diagnostics sources are unaffected. There is a working linter runner here; it just isn't configured from this file.

`treesitter.ensure_installed` in `astrocore.lua` must stay **exhaustive**. `astrocommunity.pack.helm` declares its parser with a function `opts` calling `extend_tbl` (`tbl_deep_extend "force"`), which bypasses lazy's `opts_extend` and list-replaces the key — left alone it collapses the whole list to `{ "helm" }`.

### Network environment

Plugin fetches go through a corporate proxy, which is why `lazy_setup.lua` caps `concurrency = 4` and raises `git.timeout` to 300s — thin per-fetch bandwidth was causing timeouts. Lower concurrency or raise the timeout if syncs start failing; don't "optimize" these back to defaults.

## Conventions

- Every non-obvious override in this repo carries a comment explaining *why* — usually which layer it is fighting and what breaks otherwise. Preserve these when editing, and add one when introducing a new override that depends on merge order.
- Keep `plugins/mason.lua`'s `ensure_installed` in sync when adding a formatter to `conform.lua` or a server to `astrolsp.lua`; nothing enforces this automatically. Note the list *concatenates* with the community packs (`opts_extend`), and several names are duplicated on purpose: `pack.lua` already ensure-installs `lua-language-server`/`stylua`/`selene` (and sets `formatters_by_ft.lua = { "stylua" }`), `pack.helm` already ensure-installs `helm-ls`. They are repeated locally so the toolchain doesn't silently depend on those imports.
- **A Mason package name can silently become a running LSP server.** AstroNvim walks `registry.get_installed_package_names()` and enables any package that maps to an lspconfig server (`astronvim/plugins/configs/mason-lspconfig.lua`), so e.g. the `stylua` formatter would otherwise attach as `stylua --lsp` on every Lua buffer. Suppress with `handlers = { <server> = false }` in `astrolsp.lua`. Deleting the name from `ensure_installed` does **not** help — the package stays installed and keeps getting enabled; use `:MasonUninstall` for that.
- `lazy-lock.json` is **deliberately gitignored**; do not propose committing it. But note this does *not* mean versions float: because `lazy_setup.lua` sets `version = "^6"`, AstroNvim resolves `pin_plugins = true` and imports `astronvim.lazy_snapshot`, which pins most of the plugin set. A fresh clone reproduces AstroNvim's snapshot, not whatever is newest.
- Mappings, vim options, and autocommands belong in `plugins/astrocore.lua`, not `polish.lua`. `polish.lua` is reserved for the narrow set of things AstroCore's table-driven config cannot express — currently only unsetting an env var, since a `nil` value is unrepresentable in a Lua table.
