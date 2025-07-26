vim.diagnostic.config {
  severity_sort = true,
  underline = {
    severity = { vim.diagnostic.severity.ERROR, vim.diagnostic.severity.WARN },
  },
  virtual_text = {
    spacing = 4,
    source = 'if_many',
    prefix = '●',
    format = function(diagnostic)
      local icons = {
        [vim.diagnostic.severity.ERROR] = ' ',
        [vim.diagnostic.severity.WARN] = ' ',
        [vim.diagnostic.severity.INFO] = ' ',
        [vim.diagnostic.severity.HINT] = '󰌵 ',
      }
      return string.format('%s %s', icons[diagnostic.severity] or '●', diagnostic.message)
    end,
  },
  float = {
    focusable = false,
    style = 'minimal',
    border = 'rounded',
    -- source = 'always',
    header = '',
    prefix = '',
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = ' ',
      [vim.diagnostic.severity.WARN] = ' ',
      [vim.diagnostic.severity.INFO] = ' ',
      [vim.diagnostic.severity.HINT] = '󰌵 ',
    },
  },
}

-- Global diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
-- vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })

return {}
