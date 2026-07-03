---@type LazySpec
return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    opts.formatters_by_ft = opts.formatters_by_ft or {}
    opts.format_on_save = {
      timeout_ms = 500,
      lsp_format = "fallback",
    }

    opts.formatters_by_ft.go = {
      "goimports",
      "gofumpt",
      "gci",
    }
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
          local first_line = file:read("*l")
          file:close()
          if first_line then
            return first_line:match("^module%s+(.+)$")
          end
        end
      end
      return nil
    end

    opts.formatters.goimports = {
      prepend_args = function(self, ctx)
        local mod = get_go_module(ctx)
        if mod then
          return { "-local", mod }
        end
        return {}
      end,
    }

    opts.formatters.gci = {
      command = "gci",
      args = function(self, ctx)
        local args = { "write", "--skip-generated", "-s", "standard", "-s", "default" }
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
