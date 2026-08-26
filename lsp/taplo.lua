-- Merged over nvim-lspconfig's `lsp/taplo.lua` (which supplies cmd/filetypes/root_markers).
--
-- Upstream only marks a root with `.taplo.toml`, `taplo.toml`, or `.git`. A lone TOML file
-- outside such a directory (`~/.config/alacritty/alacritty.toml`, a stray `foo.toml` in $HOME)
-- therefore attaches with `root_dir = nil`, and taplo puts it in a *detached* workspace. A
-- workspace decides membership with an include glob set built during `initialize` -- normally
-- defaulting to `<root>/**/*.toml` -- and a detached one never gets that set built at all
-- ("no file matches were set up" in taplo's log). The document is then excluded from its own
-- workspace: a Hint diagnostic `this document has been excluded`, and null results for hover,
-- completion, formatting, and documentSymbol.
--
-- Falling back to the file's own directory always yields a root, so the glob set is built.
-- The other escape hatch -- non-null `settings.evenBetterToml`, which makes taplo run
-- `update_configuration` and lazily build globs for the detached workspace -- is a trap: an
-- empty Lua table encodes as `[]`, not `{}`, which taplo cannot deserialize, and the document
-- is excluded again. `vim.empty_dict()` survives only until something deep-extends it.
return {
  root_dir = function(bufnr, cb)
    cb(vim.fs.root(bufnr, { ".taplo.toml", "taplo.toml", ".git" }) or vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)))
  end,
}
