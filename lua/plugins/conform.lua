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

    opts.formatters_by_ft.go = {
      "goimports",
      "gofumpt",
      "gci",
    }
    -- Duplicates `astrocommunity.pack.lua`, which sets exactly this. Kept explicit so the
    -- lua formatter does not silently depend on that community import staying in place.
    opts.formatters_by_ft.lua = { "stylua" }
    opts.formatters_by_ft.python = { "ruff_organize_imports", "ruff_format" }
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

    -- NOTE: `goimports` intentionally gets no `-local` override. gci runs after it and its
    -- `prefix(<mod>)` section produces the identical std|third-party|local grouping, so the
    -- flag was overwritten every time -- verified by diffing the full chain with and without
    -- it. goimports still earns its slot in `formatters_by_ft.go`: it adds and removes
    -- imports, which gci never does (gci only sorts).
    --
    -- This override replaces conform's built-in gci args wholesale (a function `args` is not
    -- merged with the built-in table), so `--skip-generated` and `--skip-vendor` have to be
    -- repeated here or they are lost.
    opts.formatters.gci = {
      args = function(_, ctx)
        local args = { "write", "--skip-generated", "--skip-vendor", "-s", "standard", "-s", "default" }
        local mod = get_go_module(ctx)
        if mod then
          table.insert(args, "-s")
          table.insert(args, "prefix(" .. mod .. ")")
        end
        table.insert(args, "$FILENAME")
        return args
      end,
      stdin = false,
    }
  end,
}
