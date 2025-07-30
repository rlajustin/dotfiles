return {
  'nvim-treesitter/nvim-treesitter-context',
  config = function()
    local tsc = require 'treesitter-context'
    tsc.setup()
    vim.keymap.set('n', '<leader>[', function()
      tsc.go_to_context(vim.v.count1)
    end, { noremap = true, silent = true, desc = 'Jump to start of treesitter-context' })

    vim.keymap.set('n', '<leader>tc', function()
      tsc.toggle()
    end, { noremap = true, silent = true, desc = 'Toggle treesitter context' })
  end,
}
