-- if true then return end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Spell check
vim.o.spell = false

-- Block cursor
vim.o.guicursor = 'n-v-c-sm-i-ci-ve:block,r-cr-o:hor20,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor'

-- Tab
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = false

-- Disable mouse
vim.o.mouse = ''

-- Buffer navigation (avoid remapping <Tab>, which is <C-i> in a terminal and
-- would clobber jumplist-forward). <S-l>/<S-h> next/prev, matching ]b/[b.
vim.keymap.set('n', '<S-l>', function() require('astrocore.buffer').nav(vim.v.count1) end, { desc = 'Next buffer' })
vim.keymap.set('n', '<S-h>', function() require('astrocore.buffer').nav(-vim.v.count1) end, { desc = 'Previous buffer' })

-- Unset GCP creds JSON path
vim.env.GOOGLE_APPLICATION_CREDENTIALS = nil

-- Global settings (e.g. for neominimap float layout)
vim.opt.wrap = false
vim.opt.sidescrolloff = 36 -- Set a large value
