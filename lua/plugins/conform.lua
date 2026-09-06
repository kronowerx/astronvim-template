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
    -- lua (stylua) is left entirely to `astrocommunity.pack.lua`.

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
    -- Overrides `astrocommunity.pack.bash`, which sets `{ "shfmt", "shellcheck" }`, for the
    -- same reason `ruff_fix` is dropped above. conform's `shellcheck` entry is not a
    -- formatter: it is `shellcheck '$FILENAME' --format=diff | patch -p1 '$FILENAME'`, so
    -- `:w` applies lint autofixes -- `cat $f` becomes `cat "$f"`. It is the worse of the two
    -- cases, because bashls runs shellcheck internally and already reports SC2086 as a
    -- diagnostic: the warning you just read silently resolves itself with your code rewritten
    -- underneath it. Dropping it costs no diagnostics -- those come from bashls, not conform.
    opts.formatters_by_ft.sh = { "shfmt" }
    opts.formatters_by_ft.zsh = { "shfmt" }
    -- No pack supplies a formatter for these; jsonls/marksman/taplo are LSP-only here
    -- (and AstroLSP formatting is disabled, so their format capability never runs).
    opts.formatters_by_ft.json = { "prettierd" }
    opts.formatters_by_ft.jsonc = { "prettierd" }
    opts.formatters_by_ft.markdown = { "prettierd" }
    opts.formatters_by_ft.toml = { "taplo" }

    opts.formatters = opts.formatters or {}

    local function get_go_module(ctx)
      local root = vim.fs.root(ctx.dirname, { "go.mod" })
      if not root or vim.fn.executable "go" ~= 1 then return nil end

      -- Let Go parse comments, whitespace and quoted/escaped module paths. With only
      -- -json, `go mod edit` reads the file without rewriting it or resolving dependencies.
      -- Keep this save-path lookup bounded and prevent automatic toolchain downloads.
      local result = vim
        .system({ "go", "mod", "edit", "-json", root .. "/go.mod" }, {
          text = true,
          env = { GOTOOLCHAIN = "local" },
        })
        :wait(250)
      if result.code ~= 0 then return nil end
      local ok, mod = pcall(vim.json.decode, result.stdout)
      if ok and type(mod.Module) == "table" and mod.Module.Path ~= "" then return mod.Module.Path end
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
