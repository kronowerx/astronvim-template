-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here.
--
-- Options, mappings and autocommands now live in `lua/plugins/astrocore.lua`.
-- The one setting below cannot: AstroCore's `options` table applies
-- `vim[scope][key] = value` by iterating the table, and a nil value is
-- unrepresentable in Lua (the key simply vanishes), so *unsetting* an
-- environment variable has to stay as raw Lua.

-- Unset GCP creds JSON path
vim.env.GOOGLE_APPLICATION_CREDENTIALS = nil
