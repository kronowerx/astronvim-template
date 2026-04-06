-- Catppuccin theme
return {
  'catppuccin/nvim',
  name = 'catppuccin',
  priority = 1000,
  config = function()
    require('catppuccin').setup {
      flavor = 'mocha',
      background = { -- :h background
        light = 'latte',
        dark = 'mocha'
      }
    }
    vim.cmd.colorscheme 'catppuccin'
  end
}
