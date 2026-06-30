-- zen mode
return {
  'folke/zen-mode.nvim',
  config = function()
    require('zen-mode').setup {
      window = {
        backdrop = 0.85,
        width = 120,
      },
      plugins = {
        options = { laststatus = 3 },
        alacritty = { enabled = true, font = '12' },
      },
    }
    vim.keymap.set('n', '<leader>z', ':ZenMode<CR>', { desc = 'Toggle [Z]enMode' })
  end,
}
