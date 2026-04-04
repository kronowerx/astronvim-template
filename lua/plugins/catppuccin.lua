-- Catppuccin theme
return {
  'catppuccin/nvim',
  name = 'catppuccin',
  priority = 1000,
  config = function()
    require('catppuccin').setup {
      flavor = 'macchiato',
      background = { -- :h background
        light = 'latte',
        dark = 'macchiato'
      }
    }
    vim.cmd.colorscheme 'catppuccin'
  end
}
