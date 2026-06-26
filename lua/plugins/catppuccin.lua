-- Catppuccin theme
return {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = false,
  priority = 1000,
  opts = {
    flavour = "mocha", -- Note: 'flavour' with a 'u' is required by catppuccin
    background = {
      light = "latte",
      dark = "mocha",
    },
    -- AstroNvim users typically want integrations enabled
    integrations = {
      cmp = true,
      gitsigns = true,
      nvimtree = true,
      treesitter = true,
      notify = false,
      mini = {
        enabled = true,
        indentscope_color = "",
      },
      telescope = {
        enabled = true,
      },
    },
  },
}
