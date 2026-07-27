-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`

-- NOTE: keep `opts` a plain table. AstroNvim's own `_astrocore_options.lua` uses a function
-- `opts` that wholesale-assigns `opts.options`; because it is an earlier fragment, a plain
-- table here deep-merges on top and all of AstroNvim's other defaults survive. A function
-- `opts` that reassigned `opts.options` would drop them.

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        spell = false,
        -- block cursor everywhere except replace/operator-pending
        guicursor = "n-v-c-sm-i-ci-ve:block,r-cr-o:hor20,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor",
        -- hard tabs, 4 columns wide (overrides AstroNvim's expandtab/tabstop=2)
        tabstop = 4,
        softtabstop = 4,
        shiftwidth = 4,
        expandtab = false,
        mouse = "", -- disable mouse
        -- Hide the tabline. This is the approach the AstroNvim docs recommend: heirline's
        -- tabline stays defined, so it remains toggleable with <Leader>ut and the
        -- interactive buffer pickers (<Leader>bb/bd/b\/b|) keep working.
        showtabline = 0,
        autoread = true, -- reload files changed on disk outside neovim
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      n = {
        -- Buffer navigation. Deliberately not <Tab>, which is <C-i> in a terminal and
        -- would clobber jumplist-forward. Mirrors the built-in ]b/[b.
        ["<S-l>"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["<S-h>"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },
      },
      v = {
        -- With `formatting.disabled = true`, AstroLSP's visual <Leader>lf is suppressed and
        -- the conform module only supplies normal mode, so range formatting needs a key here.
        ["<Leader>lf"] = { ":<C-U>'<,'>Format<CR>", desc = "Format selection" },
      },
    },
    -- Treesitter parsers are configured here, not in the nvim-treesitter spec (which is
    -- only a download utility on the `main` branch).
    --
    -- NOTE: this list must be exhaustive. Upstream `astrocommunity.pack.helm` declares its
    -- parser with a *function* `opts` calling `extend_tbl` (`tbl_deep_extend "force"`), which
    -- bypasses lazy's `opts_extend` and list-REPLACES this key -- collapsing AstroNvim's nine
    -- defaults and pack.lua's { "lua", "luap" } down to just { "helm" }. Re-declaring the full
    -- set here (this fragment merges last) is correct whether the merge appends or replaces;
    -- relying on append semantics is not. `auto_install` stays on for anything missed.
    treesitter = {
      ensure_installed = {
        "bash",
        "c",
        "dockerfile",
        "gitignore",
        "go",
        "gomod",
        "gosum",
        "gotmpl",
        "helm",
        "json",
        "jsonc",
        "lua",
        "luap",
        "make",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "sql",
        "toml",
        "vim",
        "vimdoc",
        "yaml",
      },
    },
    autocmds = {
      -- Replaces AstroNvim's built-in `checktime` group (FocusGained/TermClose/TermLeave),
      -- adding BufEnter/CursorHold for more eager reloading while keeping its `nofile`
      -- guard. CursorHoldI is excluded on purpose: reloading from disk mid-insert can pull
      -- text out from under the cursor.
      checktime = {
        {
          event = { "FocusGained", "BufEnter", "CursorHold", "TermClose", "TermLeave" },
          desc = "Reload buffers changed on disk outside Neovim",
          callback = function()
            if vim.bo.buftype ~= "nofile" then vim.cmd.checktime() end
          end,
        },
      },
    },
  },
}
