-- Customize Mason

---@type LazySpec
return {
  -- use mason-tool-installer for automatically installing Mason packages
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    -- overrides `require("mason-tool-installer").setup(...)`
    opts = {
      -- Make sure to use the names found in `:Mason`
      ensure_installed = {
        "docker-compose-language-service",
        "dockerfile-language-server",
        "gci",
        "goimports",
        "gopls",
        "hadolint",
        "lua-language-server",
        "prettierd",
        "pyrefly",
        "ruff",
        "rust-analyzer",
        "stylua",
        "taplo",
        "tree-sitter-cli",
        "yaml-language-server",
      },
    },
  },
}
