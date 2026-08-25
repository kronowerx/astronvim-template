-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here.
--
-- Options, mappings and autocommands now live in `lua/plugins/astrocore.lua`.
-- Neither of the two below can: the first because AstroCore's `options` table
-- applies `vim[scope][key] = value` by iterating the table, and a nil value is
-- unrepresentable in Lua (the key simply vanishes), so *unsetting* an
-- environment variable has to stay as raw Lua; the second because it patches a
-- Neovim runtime function, which no AstroNvim config table exposes.

-- Unset GCP creds JSON path
vim.env.GOOGLE_APPLICATION_CREDENTIALS = nil

-- Silence a spurious "documentHighlight is not supported" error on Dockerfiles.
--
-- `Snacks.words` (reference highlighting under the cursor) debounces
-- `vim.lsp.buf.document_highlight()` 200ms after CursorMoved. Two clients attach
-- to a `dockerfile` buffer: null-ls (hadolint, no documentHighlight) and
-- docker_language_server (has it — `documentHighlightProvider` is set statically
-- at initialize and never unregistered). `vim.lsp.buf_request` intermittently
-- fails its own capability check, and because null-ls *is* attached it takes the
-- "clients exist but none support this method" branch and notifies at ERROR
-- level. Verified spurious: the capability reports true both immediately before
-- and immediately after the failing check, ~1-2 times per session.
--
-- `on_unsupported` is buf_request's documented hook replacing that notify, so a
-- no-op silences it without touching the request path — highlighting still works
-- wherever a server answers. Scoped to documentHighlight only, since a missing
-- documentHighlight is never actionable; every other method keeps its warning.
--
-- Presumed a Neovim/snacks bug. Drop this once it stops reproducing.
--
-- Retested on the 0.12.4 -> 0.12.5 bump (snacks.nvim unchanged at v2.31.0) by swapping
-- the no-op below for a counter: 900 documentHighlight requests over six fresh headless
-- sessions on a Dockerfile, both clients attached, zero spurious on_unsupported calls.
-- Kept regardless -- that is a loop firing synthetic CursorMoved events, not the real
-- editing this was observed under, so a clean run is not evidence the race is gone. It
-- costs four inert lines; a wrong removal costs ERROR notifications in daily use. Drop
-- it after a few quiet weeks of real use.
--
-- Also recheck the signature on each bump: this positional wrapper breaks silently if
-- `on_unsupported` moves. Still the 5th parameter of `vim.lsp.buf_request` on 0.12.5
-- ($VIMRUNTIME/lua/vim/lsp.lua:1232).
local buf_request = vim.lsp.buf_request
vim.lsp.buf_request = function(bufnr, method, params, handler, on_unsupported)
  if method == "textDocument/documentHighlight" and on_unsupported == nil then on_unsupported = function() end end
  return buf_request(bufnr, method, params, handler, on_unsupported)
end
