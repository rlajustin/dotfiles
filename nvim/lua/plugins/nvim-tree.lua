return {
  'nvim-tree/nvim-tree.lua',
  lazy = false,
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  config = function()
    local function on_attach(bufnr)
      local api = require 'nvim-tree.api'

      local function opts(desc)
        return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
      end

      api.config.mappings.default_on_attach(bufnr)

      -- custom keymaps
      vim.keymap.set('n', 'h', api.node.navigate.parent_close, opts 'Close Directory')
      vim.keymap.set('n', 'l', api.node.open.edit, opts 'Open')
      vim.keymap.set('n', '<CR>', api.node.open.edit, opts 'Open')
      vim.keymap.set('n', '<C-v>', api.node.open.vertical, opts 'Open: Vertical Split')
      vim.keymap.set('n', '<C-x>', api.node.open.horizontal, opts 'Open: Horizontal Split')
      vim.keymap.set('n', '<C-n>', api.tree.toggle, opts 'Toggle Tree')
      vim.keymap.set('n', '<S-l>', '<C-w><C-l>', opts 'Move focus to the right window')
      vim.keymap.set('n', 'q', api.tree.close, opts 'Close Tree')
    end

    require('nvim-tree').setup {
      on_attach = on_attach,
      sort_by = 'case_sensitive',
      view = {
        width = 35,
      },
      renderer = {
        group_empty = true,
      },
      filters = {
        dotfiles = false, -- show hidden files
      },
      update_focused_file = {
        enable = true,
        update_root = true,
      },
      actions = {
        open_file = {
          quit_on_open = false, -- set to true if you want the tree to close when opening a file
        },
      },
      git = {
        enable = true,
        ignore = true,
      },
      respect_buf_cwd = true,
      sync_root_with_cwd = true,
    }

    vim.keymap.set('n', '<leader>e', require('nvim-tree.api').tree.toggle, { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>o', require('nvim-tree.api').tree.focus, { noremap = true, silent = true })
  end,
}
