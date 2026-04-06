-- if true then return end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

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

-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here
