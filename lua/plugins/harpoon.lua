-- Harpoon: four pinned file slots, navigated by index.
--
-- NOTE: no mappings here. They live in plugins/astrocore.lua per this repo's convention,
-- which is also what gives them which-key group names and descriptions. Because each of
-- those mappings is a function that `require`s harpoon, lazy.nvim loads this plugin on
-- first keypress -- so it needs no `event`/`keys` trigger and no longer loads at startup
-- (a bare `config` with no trigger meant `lazy = false`).
--
-- `opts` is safe despite harpoon2's setup being a method: `Harpoon.setup(self, config)`
-- detects being called with a config as its first argument and re-dispatches, so
-- lazy.nvim's `require("harpoon").setup(opts)` is a supported call shape.
return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  lazy = true,
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {},
}
