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
      -- Two things to know before editing this list:
      --   * AstroNvim declares `opts_extend = { "ensure_installed" }`, so these CONCATENATE
      --     with the community packs rather than replacing them. `lua-language-server`,
      --     `stylua` and `selene` also come from `astrocommunity.pack.lua`, and `helm-ls`
      --     from `astrocommunity.pack.helm`; they are repeated here on purpose so the
      --     toolchain does not silently depend on those imports. Duplicates are harmless.
      --   * A package here that maps to an lspconfig server name is auto-started as a
      --     language server (see the `handlers` note in astrolsp.lua). Deleting a name from
      --     this list does not stop that -- the package stays installed. Use
      --     `:MasonUninstall`, or disable it via astrolsp `handlers`.
      ensure_installed = {
        "docker-compose-language-service",
        "dockerfile-language-server",
        "gci",
        "gofumpt",
        "goimports",
        "gopls",
        "hadolint",
        "helm-ls",
        "lua-language-server",
        "prettierd",
        "pyrefly",
        "ruff",
        "selene",
        "stylua",
        "taplo",
        "tree-sitter-cli",
        "yaml-language-server",
      },
    },
  },
}
