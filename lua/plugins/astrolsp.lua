-- AstroLSP allows you to customize the features in AstroNvim's LSP configuration engine
-- Configuration documentation can be found with `:h astrolsp`

---@type LazySpec
return {
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = {
      -- Configuration table of features provided by AstroLSP
      features = {
        -- NOTE: no `codelens` key. AstroNvim already computes the correct default
        -- (`not vim.version.range("0.12.0-0.12.1"):has(...)`, i.e. true on 0.12.5);
        -- setting it here only restated that.
        inlay_hints = false, -- enable/disable inlay hints on start
        semantic_tokens = true, -- enable/disable semantic token highlighting
      },
      -- AstroNvim enables an LSP server for every *installed* Mason package that maps to an
      -- lspconfig server name (see `astronvim/plugins/configs/mason-lspconfig.lua`, which
      -- walks `registry.get_installed_package_names()`). nvim-lspconfig ships a `stylua`
      -- server def (`stylua --lsp`), so the stylua formatter in mason.lua was also attaching
      -- to every Lua buffer as a second documentFormatting provider that conform already
      -- covers. `false` skips setup entirely (`:h astrolsp` -> handlers).
      -- Removing a name from `ensure_installed` will NOT undo this -- the package stays on
      -- disk and keeps getting enabled. Use this table, or `:MasonUninstall`.
      handlers = { stylua = false },
      -- NOTE: no `formatting` block here on purpose. conform owns all formatting via
      -- `astrocommunity.editing-support.conform-nvim`, which sets `formatting.disabled = true`.
      -- Anything under `formatting` here would merge OVER that (lua/plugins/* merges after
      -- community/) and re-enable AstroLSP's BufWritePre formatter, so every file would be
      -- formatted twice. Set format timeouts in conform.lua instead.
      -- customize language server configuration passed to `vim.lsp.config`
      -- client specific configuration can also go in `lsp/` in your configuration root (see `:h lsp-config`)
      config = {
        yamlls = {
          settings = {
            yaml = {
              -- NOTE: keep these patterns directory-scoped. yamlls strips a leading `/` and
              -- then unconditionally prepends `**/`, so the common `"/*.yaml"` idiom expands
              -- to `**/*.yaml` -- every yaml file at any depth. That is not merely noisy:
              -- `yaml.schemas` is priority 5 against SchemaStore's 7, so it *displaces* the
              -- correctly auto-detected schema, and the `kubernetes` keyword resolves to the
              -- strict all-kinds schema (`additionalProperties: false`). A GitHub Actions
              -- workflow named `.yaml` then reports "Property jobs is not allowed" while the
              -- same file named `.yml` is clean.
              schemas = { kubernetes = { "k8s/**/*.{yaml,yml}", "manifests/**/*.{yaml,yml}" } },
            },
          },
        },
        -- NOTE: no `gopls` entry. `astrocommunity.pack.go` owns the gopls settings now,
        -- including `gofumpt = true` (which is the one that matters here -- it applies to
        -- gopls' own generated edits from code actions and refactorings; conform owns buffer
        -- formatting, so gopls never formats on `:w`). Two of the pack's settings are worth
        -- knowing about because they are opinionated rather than default:
        --   buildFlags = { "-tags", "integration" } -- gopls analyzes files behind the
        --                         `integration` build tag in every project, not just ones
        --                         that use it.
        --   staticcheck = true -- tri-state; `true` enables *every* analyzer, including the
        --                         ones staticcheck ships off by default. Unset would select
        --                         the maintainer-curated subset.
        -- To go back to a minimal gopls, re-add a `gopls` block here -- it merges over the
        -- pack -- and set those keys to `vim.NIL` to delete them rather than to `false`.
        -- NOTE: no `pyrefly` entry. The obvious `settings = { pyrefly = { ... } }` shape is
        -- inert twice over: pyrefly requests the `python` configuration section and never
        -- `pyrefly`, so the table is never even transmitted; and `preset` is a
        -- pyrefly.toml/CLI key with no LSP-settings equivalent (the server's real keys are
        -- typeCheckingMode, displayTypeErrors, disableLanguageServices, disableTypeErrors,
        -- extraPaths -- unknown fields are dropped without a warning). If a type-checking
        -- mode is ever wanted, the working shape is:
        --   settings = { python = { pyrefly = { typeCheckingMode = "..." } } }
        -- and note it applies only to files not already covered by a pyrefly.toml.
        -- Ruff runs as a linter alongside pyrefly. Ruff 0.16 enables ~413 rules by default
        -- (bugbear, pyupgrade, simplify, comprehensions, pylint, perflint, refurb, ...),
        -- almost none of which a type checker reports -- so it earns its place. But
        -- pyrefly's LSP *does* report a few of the same things, and those exact codes are
        -- ignored here to avoid two diagnostics on one line:
        --   F401 unused-import    -> pyrefly `unused-import`, reported reliably at module
        --                            level regardless of annotations
        --   F821 undefined-name   -> pyrefly `unknown-name` (and pyrefly resolves imports,
        --                            so it is the more accurate of the two)
        --   I001 unsorted-imports -> conform runs ruff_organize_imports on every save, so
        --                            the diagnostic is always about to be auto-fixed
        -- F841 (unused-variable) is deliberately NOT ignored even though pyrefly overlaps
        -- it: pyrefly only reports it inside *annotated* functions, while ruff catches it
        -- everywhere. An occasional duplicate beats silently missing it in untyped code.
        -- If you spot another duplicated pair, add its code here rather than disabling ruff.
        -- Add `configurationPreference = "filesystemFirst"` if a project's own ruff config
        -- should take priority over these editor settings.
        ruff = {
          init_options = {
            settings = {
              lint = { ignore = { "F401", "F821", "I001" } },
            },
          },
        },
        -- ["*"] = { capabilities = {} }, -- modify default LSP client settings such as capabilities
      },
      -- NOTE: no `lsp_codelens_refresh` autocmd group here. AstroNvim deliberately disables
      -- it on Neovim 0.12 (`_astrolsp_autocmds.lua`: `not vim.lsp.codelens.enable and {...}
      -- or false`) because `vim.lsp.codelens.enable` is no longer a refresh -- it is a
      -- state marker guarded by `if enable ~= is_enabled(...)`, and refreshing is now the
      -- decoration provider's job. Re-adding the group merged over that `false` and forced
      -- codelens back on at every BufEnter/InsertLeave, silently defeating AstroNvim's own
      -- <Leader>uL codelens toggle.
      -- mappings to be set up on attaching of a language server
      mappings = {
        n = {
          -- a `cond` key can provided as the string of a server capability to be required to attach, or a function with `client` and `bufnr` parameters from the `on_attach` that returns a boolean
          gD = {
            function() vim.lsp.buf.declaration() end,
            desc = "Declaration of current symbol",
            cond = "textDocument/declaration",
          },
          ["<Leader>uY"] = {
            function() require("astrolsp.toggles").buffer_semantic_tokens() end,
            desc = "Toggle LSP semantic highlight (buffer)",
            cond = function(client)
              return client:supports_method "textDocument/semanticTokens/full" and vim.lsp.semantic_tokens ~= nil
            end,
          },
        },
      },
    },
  },
}
