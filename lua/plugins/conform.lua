---@type LazySpec
return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    opts.formatters_by_ft = opts.formatters_by_ft or {}

    opts.formatters_by_ft.go = {
        "goimports",
        "gofumpt",
        "gci",
    }

    opts.formatters = opts.formatters or {}

    opts.formatters.goimports = {
      prepend_args = {
        "-local",
        "bda-studio/studio-server",
      },
    }

    opts.formatters.gci = {
      command = "gci",
      args = {
        "write",
        "--skip-generated",
        "-s",
        "standard",
        "-s",
        "default",
        "-s",
        "prefix(bda-studio/studio-server)",
        "$FILENAME",
      },
      stdin = false,
    }
    -- format-on-save is owned by AstroLSP (see astrolsp.lua); conform just
    -- supplies the Go formatters above. Defining opts.format_on_save here too
    -- would bypass AstroLSP's settings (and the <Leader>uf autoformat toggle).
  end,
}
