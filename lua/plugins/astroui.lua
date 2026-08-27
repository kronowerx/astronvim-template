-- AstroUI provides the basis for configuring the AstroNvim User Interface
-- Configuration documentation can be found with `:h astroui`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astroui",
  -- NOTE: no `lazy`/`priority` here. Upstream `_astroui.lua` is `lazy = true`, and it should
  -- stay that way: astrocore (the `lazy = false, priority = 10000` start plugin) requires
  -- astroui during its own setup to call `set_colorscheme()`, so astroui is pulled in exactly
  -- when it is needed. This file briefly carried `lazy = false, priority = 10000` from an
  -- early attempt at getting catppuccin to apply; the real fix was the flavour pinning in
  -- plugins/catppuccin.lua, whose reasoning cites astroui being lazy upstream.
  ---@type AstroUIOpts
  opts = {
    -- change colorscheme
    -- NOTE: use the SUFFIXED name. `colors/catppuccin-frappe.lua` runs
    -- `require("catppuccin").load "frappe"` -- an explicit argument, so the flavour is
    -- deterministic. The bare `catppuccin` name calls `load()` with no argument and
    -- resolves the flavour from `options` at load time, i.e. whatever setup() happened to
    -- have applied by then (defaults if it has not run at all).
    colorscheme = "catppuccin-frappe",
    -- AstroUI allows you to easily modify highlight groups easily for any and all colorschemes
    highlights = {
      init = { -- this table overrides highlights in all themes
        -- Normal = { bg = "#000000" },
      },
      astrodark = { -- a table of overrides/changes when applying the astrotheme theme
        -- Normal = { bg = "#000000" },
      },
    },
    -- Icons can be configured throughout the interface
    icons = {
      -- configure the loading of the lsp in the status line
      LSPLoading1 = "⠋",
      LSPLoading2 = "⠙",
      LSPLoading3 = "⠹",
      LSPLoading4 = "⠸",
      LSPLoading5 = "⠼",
      LSPLoading6 = "⠴",
      LSPLoading7 = "⠦",
      LSPLoading8 = "⠧",
      LSPLoading9 = "⠇",
      LSPLoading10 = "⠏",
    },
  },
}
