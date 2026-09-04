-- AstroNvim installs guess-indent itself (`astronvim/plugins/guess-indent.lua`) with
-- `opts = { auto_cmd = false }` and drives it from an astrocore BufReadPost autocmd calling
-- `set_from_buffer(buf, true, true)`. The `true` context flag is what makes the plugin honour
-- `filetype_exclude`, so opting a filetype out here is enough -- no autocmd surgery needed.
--
-- NOTE: `filetype_exclude` must restate the plugin's defaults. lazy.nvim deep-merges this
-- fragment with AstroNvim's, but guess-indent's own `set_config` then does a *shallow*
-- `vim.tbl_extend("force", default_config, user_config)`, so a list given here replaces
-- `{ "netrw", "tutor" }` outright rather than appending to it.
---@type LazySpec
return {
  "NMAC427/guess-indent.nvim",
  opts = {
    filetype_exclude = {
      "netrw",
      "tutor",
      -- Mermaid: indentation is cosmetic and files in the wild use anything from 2 to 8
      -- spaces, so guessing from the file gives inconsistent results across diagrams. The
      -- fixed 4-space setting lives in the `mermaid_indent` autocmd in plugins/astrocore.lua.
      "mermaid",
    },
  },
}
