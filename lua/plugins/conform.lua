---@type LazySpec
return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    opts.formatters_by_ft = opts.formatters_by_ft or {}

    -- Do NOT set `opts.format_on_save` here: the astrocommunity conform module installs a
    -- function there gated on vim.b/vim.g.autoformat, and a table would replace it,
    -- breaking <Leader>uf/<Leader>uF. Raise the timeout via default_format_opts instead --
    -- conform fills only nil keys, so this reaches the save path (default is 1000ms).
    -- This is a synchronous budget blocking `:w`, so keep it modest.
    opts.default_format_opts = vim.tbl_extend("force", opts.default_format_opts or {}, { timeout_ms = 1500 })

    -- Only filetypes this config genuinely disagrees with the packs on are listed here.
    -- lua (stylua) and sh/zsh (shfmt + shellcheck) are left entirely to
    -- `astrocommunity.pack.{lua,bash}`.

    -- Overrides `astrocommunity.pack.go`, which sets `{ "goimports", lsp_format = "last" }`.
    -- Assigning the key replaces that wholesale, which is the intent: dropping
    -- `lsp_format = "last"` keeps gopls out of the save path (conform owns formatting).
    opts.formatters_by_ft.go = {
      "goimports",
      "gofumpt",
    }
    -- Overrides `astrocommunity.pack.python.ruff`, which sets
    -- `{ "ruff_fix", "ruff_organize_imports", "ruff_format" }`. `ruff_fix` is omitted on
    -- purpose: it applies ruff's lint autofixes on every `:w`, which is a code change rather
    -- than a formatting change. Delete this line to take the pack's chain instead.
    opts.formatters_by_ft.python = { "ruff_organize_imports", "ruff_format" }
    -- No pack supplies a formatter for these; jsonls/marksman/taplo are LSP-only here
    -- (and AstroLSP formatting is disabled, so their format capability never runs).
    opts.formatters_by_ft.json = { "prettierd" }
    opts.formatters_by_ft.jsonc = { "prettierd" }
    opts.formatters_by_ft.markdown = { "prettierd" }
    opts.formatters_by_ft.toml = { "taplo" }

    opts.formatters = opts.formatters or {}

    local function get_go_module(ctx)
      local root = vim.fs.root(ctx.dirname, { "go.mod" })
      if root then
        local file = io.open(root .. "/go.mod", "r")
        if file then
          local first_line = file:read "*l"
          file:close()
          if first_line then return first_line:match "^module%s+(.+)$" end
        end
      end
      return nil
    end

    -- Go import grouping is project-aware rather than hardcoded to an org: `-local <module>`
    -- is read out of the nearest go.mod, which makes goimports emit std | third-party | local
    -- as three groups instead of folding local packages in with third-party.
    --
    -- This replaced a `goimports -> gofumpt -> gci` chain. gci produced the same grouping via
    -- `prefix(<mod>)` and ran last, which is why `-local` used to be inert here and was
    -- deliberately omitted. With gci dropped, this flag is the only thing doing the grouping
    -- -- do not remove it expecting something downstream to compensate.
    --
    -- A function `args` replaces conform's built-in arg table wholesale (it is not merged),
    -- so `-srcdir $DIRNAME` has to be repeated here or it is lost. goimports needs it to
    -- resolve the file's own package: conform pipes the buffer over stdin, so without
    -- -srcdir the tool has no path to locate go.mod from.
    opts.formatters.goimports = {
      args = function(_, ctx)
        local args = { "-srcdir", "$DIRNAME" }
        local mod = get_go_module(ctx)
        if mod then
          table.insert(args, "-local")
          table.insert(args, mod)
        end
        return args
      end,
    }
  end,
}
