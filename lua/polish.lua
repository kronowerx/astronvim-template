-- if true then return end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Spell check
vim.o.spell = false

-- Block cursor
vim.o.guicursor = 'n-v-c-sm-i-ci-ve:block,r-cr-o:hor20,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor'

-- Tab
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = false

-- Disable mouse
vim.o.mouse = ''

-- Remap prev and next buffer
vim.api.nvim_set_keymap('n', '<S-Tab>', ':bprev<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<Tab>', ':bnext<CR>', { noremap = true })

local function go_org_imports(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  local clients = vim.lsp.get_clients({
    bufnr = bufnr,
    name = "gopls",
  })

  if #clients == 0 then return end

  local client = clients[1]

  local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
  params.context = {
    only = { "source.organizeImports" },
    diagnostics = {},
  }

  local result = client.request_sync("textDocument/codeAction", params, 1000, bufnr)

  if not result or not result.result then return end

  for _, action in ipairs(result.result) do
    if action.edit then
      vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
    end

    if action.command then
      client.request_sync("workspace/executeCommand", action.command, 1000, bufnr)
    end
  end
end

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  group = vim.api.nvim_create_augroup("GoOrganizeImports", { clear = true }),
  callback = function(args)
    go_org_imports(args.buf)
  end,
})
