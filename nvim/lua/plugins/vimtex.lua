return {
  'lervag/vimtex',
  lazy = false, -- lazy-loading will disable inverse search
  config = function()
    vim.g.vimtex_mappings_disable = { ['n'] = { 'K' } } -- disable `K` as it conflicts with LSP hover
    vim.g.vimtex_quickfix_method = vim.fn.executable 'pplatex' == 1 and 'pplatex' or 'latexlog'
    vim.g.vimtex_format_enabled = 1
    vim.g.vimtex_quickfix_enabled = 0
    vim.g.vimtex_quickfix_ignore_filters = {
      'Overfull',
    }
  end,
  keys = {
    { '<leader>l', '', desc = '+vimtex', ft = 'tex' },
  },
  init = function()
    vim.g.vimtex_view_method = 'zathura'
    vim.g.vimtex_view_automatic = 1
    vim.g.vimtex_compiler_latexmk = {
      options = {
        '-verbose',
        '-file-line-error',
        '-synctex=1',
        '-interaction=nonstopmode',
        '-shell-escape',
      },
    }
  end,
}
