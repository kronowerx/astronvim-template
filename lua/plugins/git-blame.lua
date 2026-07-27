-- inline git blame
return {
  "f-person/git-blame.nvim",
  -- load the plugin at startup
  event = "VeryLazy",
  opts = {
    -- your configuration comes here
    -- for example
    enabled = true, -- if you want to enable the plugin
    date_format = "%r",
    delay = 0,
    message_template = "    <author> • <date>",
    message_when_not_committed = "    Not Committed Yet",
    -- virtual_text_column = 88
  },
}
