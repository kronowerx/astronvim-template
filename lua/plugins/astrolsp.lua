-- AstroLSP allows you to customize the features in AstroNvim's LSP configuration engine
-- Configuration documentation can be found with `:h astrolsp`

---@type LazySpec
return {
  -- `:LspRestart` comes from nvim-lspconfig, but AstroNvim only registers
  -- LspInfo/LspLog/LspStart as lazy-load triggers. Add LspRestart so the global
  -- <Leader>lR mapping in astrocore.lua works before lspconfig has loaded
  -- (e.g. from the dashboard) instead of failing with E492.
  { "neovim/nvim-lspconfig", cmd = { "LspRestart" } },
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = {
      -- Configuration table of features provided by AstroLSP
      features = {
        codelens = true, -- enable/disable codelens refresh on start
        inlay_hints = false, -- enable/disable inlay hints on start
        semantic_tokens = true, -- enable/disable semantic token highlighting
      },
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
              schemas = {
                kubernetes = "/*.yaml",
              },
            },
          },
        },
        gopls = {
          settings = {
            gopls = {
              gofumpt = true,
              staticcheck = true,
              completeUnimported = true,
              analyses = {
                unusedparams = true,
                unusedwrite = true,
                nilness = true,
              },
            },
          },
        },
        pyrefly = {
          settings = {
            pyrefly = {
              preset = "default",
            },
          },
        },
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
      -- Configure buffer local auto commands to add when attaching a language server
      autocmds = {
        -- first key is the `augroup` to add the auto commands to (:h augroup)
        lsp_codelens_refresh = {
          -- Optional condition to create/delete auto command group
          -- can either be a string of a client capability or a function of `fun(client, bufnr): boolean`
          cond = "textDocument/codeLens",
          {
            event = { "InsertLeave", "BufEnter" },
            desc = "Refresh codelens (buffer)",
            callback = function(args)
              if require("astrolsp").config.features.codelens then
                vim.lsp.codelens.enable(true, { bufnr = args.buf })
              end
            end,
          },
        },
      },
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
          -- Free up <Leader>lR (AstroLSP's "Search references") for the LSP restart mapping
          -- in astrocore.lua. `grr` is the Neovim 0.11+ default for references.
          -- NOTE: the restart cannot live here -- a table would deep-merge and retain
          -- AstroNvim's `cond = "textDocument/references"`, so the key would only exist
          -- while a references-capable client is attached, i.e. never after a crash.
          ["<Leader>lR"] = false,
        },
      },
    },
  },
}
