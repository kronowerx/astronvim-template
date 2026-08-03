-- Customize Mason

---@type LazySpec
return {
  -- use mason-tool-installer for automatically installing Mason packages
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    -- overrides `require("mason-tool-installer").setup(...)`
    opts = {
      -- Make sure to use the names found in `:Mason`.
      --
      -- This list is now only the GAPS. Every language toolchain comes from the
      -- `astrocommunity.pack.*` imports in community.lua, which register their own servers,
      -- formatters and linters through this same plugin -- AstroNvim declares
      -- `opts_extend = { "ensure_installed" }`, so the fragments CONCATENATE. Restating a
      -- pack's package here would be harmless but misleading about who owns it; add a name
      -- only when no imported pack installs it.
      --
      -- Also note: a package here that maps to an lspconfig server name is auto-started as a
      -- language server (see the `handlers` note in astrolsp.lua). Deleting a name from this
      -- list does not stop that -- the package stays installed. Use `:MasonUninstall`, or
      -- disable it via astrolsp `handlers`.
      ensure_installed = {
        -- Go: the pack installs gopls + goimports, but the rest of conform.lua's Go chain
        -- (goimports -> gofumpt -> gci) is this config's own.
        "gci",
        "gofumpt",
        -- conform.lua formats json/jsonc/markdown with prettierd; no pack supplies it.
        "prettierd",
        -- `astrocommunity.pack.rust` installs only codelldb and expects rust-analyzer on
        -- PATH via rustup. Pin it to Mason so a machine without rustup still works.
        "rust-analyzer",
        "tree-sitter-cli",
      },
    },
  },
}
