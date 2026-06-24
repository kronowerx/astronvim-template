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
    opts.formatters_by_ft.lua = { "stylua" }

    opts.formatters = opts.formatters or {}

    local function get_go_module(ctx)
      local utils = require("conform.util")
      local root = utils.root_file({ "go.mod" })(ctx)
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
    -- format-on-save is owned by AstroLSP (see astrolsp.lua); conform just
    -- supplies the Go formatters above. Defining opts.format_on_save here too
    -- would bypass AstroLSP's settings (and the <Leader>uf autoformat toggle).
  end,
}
