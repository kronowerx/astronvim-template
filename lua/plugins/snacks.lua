-- NOTE: keep `opts` a plain table. AstroNvim's own `plugins/snacks.lua` is an earlier
-- *function* fragment that assigns `opts.input = {}`; a plain table here deep-merges on
-- top, so that assignment (and every other key it sets) survives.

---@type LazySpec
return {
  "folke/snacks.nvim",
  opts = {
    input = {
      win = {
        wo = {
          -- Works around an AstroCore bug that ate one cursor column per keystroke in
          -- every `vim.ui.input` prompt. Most visible on LSP rename (`grn`), which opens
          -- prefilled: typing `123` over `foobar` produced `fooba123r`, and each further
          -- keystroke drifted another column left.
          --
          -- AstroCore refreshes folds by scheduling `vim.cmd "normal! zx"` whenever it
          -- disables treesitter for a buffer (astrocore/treesitter.lua:330-332, still
          -- present on astrocore main). Its only guard is `buftype ~= "terminal"` -- it
          -- does not check for insert mode, and running a `:normal!` command from insert
          -- mode does an insert -> normal -> insert round trip. Leaving insert mode always
          -- shifts the cursor one column left, so every such refresh costs a column.
          --
          -- This fires repeatedly here because snacks re-applies `bo.filetype` from its
          -- `expand` TextChangedI handler, so `FileType` fires on every text change; and
          -- astrocore's `reconcile_buffer` resets `enabled[buf] = nil` right after calling
          -- `M.disable`, defeating its own `if enabled[args.buf] == false then return end`
          -- early-out. The `snacks_input` filetype never has a parser, so the disable path
          -- re-runs per keystroke.
          --
          -- The bug is astrocore's and reproduces with only astrocore loaded, in an
          -- ordinary buffer, no snacks involved. It is fixed here rather than there
          -- because this is the only window in this config where it actually bites -- the
          -- picker prompts were checked and are unaffected.
          --
          -- `onemore` lets the cursor sit one past the last character, which is what the
          -- round trip would otherwise clamp away, so it *prevents* the shift instead of
          -- correcting it afterwards. Window-local, so ordinary editing is untouched.
          virtualedit = "onemore",
        },
      },
    },
  },
}
