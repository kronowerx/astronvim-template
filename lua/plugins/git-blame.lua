-- inline git blame
return {
  'f-person/git-blame.nvim',
  -- load the plugin at startup
  event = 'VeryLazy',
  -- Because of the keys part, you will be lazy loading this plugin.
  -- The plugin will only load once one of the keys is used.
  -- If you want to load the plugin at startup, add something like event = "VeryLazy",
  -- or lazy = false. One of both options will work.
  opts = {
    -- your configuration comes here
    -- for example
    enabled = true, -- if you want to enable the plugin
    date_format = '%r',
    delay = 0,
    message_template = '    <author> • <date>',
    message_when_not_committed = '    Not Committed Yet'
    -- virtual_text_column = 88
  }
}
