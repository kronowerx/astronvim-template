-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`

-- NOTE: keep `opts` a plain table. AstroNvim's own `_astrocore_options.lua` uses a function
-- `opts` that wholesale-assigns `opts.options`; because it is an earlier fragment, a plain
-- table here deep-merges on top and all of AstroNvim's other defaults survive. A function
-- `opts` that reassigned `opts.options` would drop them.

-- Mappings are built above the spec so the harpoon slots can be generated in a loop.
-- `opts` itself stays a plain table (see the NOTE above); only the value assigned to
-- `mappings` is computed.
---@type table<string, table<string, AstroCoreMapping|false>>
local mappings = {
  n = {
    -- Buffer navigation. Deliberately not <Tab>, which is <C-i> in a terminal and
    -- would clobber jumplist-forward. Mirrors the built-in ]b/[b.
    ["<S-l>"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
    ["<S-h>"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },

    -- Oil. Lives here rather than in the plugin's `config` so it carries a description
    -- and follows this repo's one-place-for-mappings convention.
    ["-"] = { "<Cmd>Oil --float<CR>", desc = "Open parent directory" },

    -- Harpoon: four pinned file slots. These were `vim.keymap.set` calls inside the
    -- plugin's `config`, which cost them their which-key group names and left <C-e>
    -- and <C-S-P>/<C-S-N> with no description at all. Every entry is a function that
    -- `require`s harpoon, so lazy.nvim loads the plugin on first use -- which is also
    -- what lets plugins/harpoon.lua stay `lazy = true` instead of loading at startup.
    ["<Leader>a"] = { desc = "Harpoon pin" },
    -- NOTE: no `<Leader>x` group declared. That prefix is already AstroNvim's
    -- "Quickfix/Lists" section (`_astrocore_mappings.lua` `_map_sections.x`, alongside
    -- <Leader>xq and <Leader>xl), so the unpin keys below are guests inside an existing
    -- group rather than owners of it -- declaring a group here would rename AstroNvim's.
    -- Worth rebinding to a free prefix if the mixed group ever gets confusing.
    -- NOTE: <C-S-P>/<C-S-N> only reach Neovim from a terminal that speaks the kitty
    -- keyboard protocol. Under tmux that additionally needs `extended-keys on`, or the
    -- keys collapse to a plain <C-P>/<C-N>; see ~/.config/tmux/tmux.conf.
    ["<C-S-P>"] = { function() require("harpoon"):list():prev() end, desc = "Harpoon previous" },
    ["<C-S-N>"] = { function() require("harpoon"):list():next() end, desc = "Harpoon next" },
    -- Overrides the built-in scroll-down-one-line, on purpose.
    ["<C-e>"] = {
      function()
        local harpoon = require "harpoon"
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end,
      desc = "Harpoon quick menu",
    },
  },
  v = {
    -- With `formatting.disabled = true`, AstroLSP's visual <Leader>lf is suppressed and
    -- the conform module only supplies normal mode, so range formatting needs a key here.
    ["<Leader>lf"] = { ":<C-U>'<,'>Format<CR>", desc = "Format selection" },
  },
}

for i = 1, 4 do
  mappings.n["<Leader>" .. i] = { function() require("harpoon"):list():select(i) end, desc = "Harpoon go to " .. i }
  mappings.n["<Leader>a" .. i] =
    { function() require("harpoon"):list():replace_at(i) end, desc = "Harpoon pin to " .. i }
  mappings.n["<Leader>x" .. i] = { function() require("harpoon"):list():remove_at(i) end, desc = "Harpoon unpin " .. i }
end

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
        -- Hard tabs, 4 columns wide (overrides AstroNvim's expandtab/tabstop=2).
        --
        -- NOTE: this is the *fallback*, not the effective setting for most files.
        -- AstroNvim ships guess-indent with a BufReadPost autocmd calling
        -- `set_from_buffer(buf, true, true)`, which re-derives these per buffer from the
        -- file's own indentation. Measured: a 4-space file gets expandtab=true sw=4, a
        -- tab-indented file expandtab=false sw=0 (follow tabstop). These values only
        -- survive where there is nothing to infer from -- new buffers, and files with no
        -- indented lines. That is the intent (match the file you are editing); the point
        -- is that editing these numbers will not change how an existing file indents.
        tabstop = 4,
        softtabstop = 4,
        shiftwidth = 4,
        expandtab = false,
        mouse = "", -- disable mouse
        -- Hide the tabline. This is the approach the AstroNvim docs recommend: heirline's
        -- tabline stays defined, so it remains toggleable with <Leader>ut and the
        -- interactive buffer pickers (<Leader>bb/bd/b\/b|) keep working.
        showtabline = 0,
      },
    },
    -- Mappings can be configured through AstroCore as well. Every mapping in this config
    -- belongs here, including ones for third-party plugins -- see the block above.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = mappings,
    -- Treesitter parsers are configured here, not in the nvim-treesitter spec (which is
    -- only a download utility on the `main` branch).
    --
    -- NOTE: this list must be exhaustive -- it is a union backstop, not an increment.
    -- Upstream `astrocommunity.pack.helm` declares its parser with a *function* `opts` calling
    -- `extend_tbl` (`tbl_deep_extend "force"`), which bypasses astrocore's
    -- `opts_extend = { "treesitter.ensure_installed" }` and list-REPLACES this key --
    -- collapsing everything merged before it down to just { "helm" }. community.lua imports
    -- helm first to limit that blast radius, but re-declaring the full set here (this fragment
    -- merges last) is correct whether the merge appends or replaces; relying on append
    -- semantics is not. `auto_install` stays on for anything missed.
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
        "gowork",
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
        "rust",
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
      --
      -- This is the whole of the reload-from-disk setup: `:checktime` is what notices the
      -- change, and `autoread` -- on by default in Neovim, so not restated in `options`
      -- above -- is what makes the reload silent instead of a prompt.
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
