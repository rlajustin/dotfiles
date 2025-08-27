return { -- Autocompletion
  'saghen/blink.cmp',
  event = 'VimEnter',
  version = '1.*',
  lazy = false,
  dependencies = {
    -- Snippet Engine
    {
      'L3MON4D3/LuaSnip',
      version = 'v2.*',
      config = function()
        require('luasnip.loaders.from_lua').load { paths = { '~/.config/nvim/lua/snippets/' } }

        local luasnip = require 'luasnip'
        luasnip.config.set_config {
          -- Enable autotriggered snippets
          keep_roots = true, --Link children
          exit_roots = true, --Link children
          enable_autosnippets = true,
          link_children = true,
          -- Use Tab (or some other key if you prefer) to trigger visual selection
          -- store_selection_keys = '<Tab>',
        }
      end,
    },
    'folke/lazydev.nvim',
  },
  --- @module 'blink.cmp'
  --- @type blink.cmp.Config
  opts = {
    keymap = {
      preset = 'default',
      ['<C-j>'] = { 'select_next', 'fallback' },
      ['<C-k>'] = { 'select_prev', 'fallback' },
      ['<C-l>'] = { 'select_and_accept', 'fallback' },
      ['<CR>'] = {
        function(cmp)
          if cmp.is_visible() then
            return cmp.select_and_accept()
          end
        end,
        'fallback',
      },
    },

    completion = {
      -- By default, you may press `<c-space>` to show the documentation.
      -- Optionally, set `auto_show = true` to show the documentation after a delay.
      documentation = { auto_show = false, auto_show_delay_ms = 500 },
    },

    appearance = {
      nerd_font_variant = 'mono',
    },

    snippets = { preset = 'luasnip' },

    sources = {
      default = { 'lsp', 'path', 'snippets', 'lazydev', 'buffer' },
      providers = {
        lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
      },
    },

    -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
    -- which automatically downloads a prebuilt binary when enabled.
    --
    -- By default, we use the Lua implementation instead, but you may enable
    -- the rust implementation via `'prefer_rust_with_warning'`
    --
    -- See :h blink-cmp-config-fuzzy for more information
    fuzzy = { implementation = 'lua' },

    -- Shows a signature help window while you type arguments for a function
    signature = { enabled = true },
  },
}
