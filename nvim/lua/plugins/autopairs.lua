-- autopairs
-- https://github.com/windwp/nvim-autopairs

return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  opts = { disable_filetype = { 'text', 'markdown', 'tex', 'latex' } },
}
