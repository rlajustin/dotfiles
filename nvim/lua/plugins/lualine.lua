--- @type LazyPluginSpec
return {
  'nvim-lualine/lualine.nvim',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
    'AndreM222/copilot-lualine',
    'letieu/harpoon-lualine',
    'pnx/lualine-lsp-status',
  },
  config = function()
    local lualine = require 'lualine'
    -- 🌟 IMPORT THE ROSÉ PINE PALETTE
    -- This 'colors' table will now contain your custom grayscale values
    -- for 'base', 'surface', 'text', 'muted', etc.
    local colors = require 'rose-pine.palette'

    -- NOTE: Rose Pine's color names:
    --   Base/Background: base, surface, overlay
    --   Foreground/Text: text, subtle, muted
    --   Accents: love (red), gold (yellow), pine (green), foam (blue), iris (magenta/violet), rose (cyan/pink)

    local theme = {
      normal = {
        -- Set all sections to use transparent background
        a = { bg = 'None', gui = 'bold' },
        b = { bg = 'None', gui = 'bold' },
        c = { bg = 'None', gui = 'bold' },
        x = { bg = 'None', gui = 'bold' },
        y = { bg = 'None', gui = 'bold' },
        z = { bg = 'None', gui = 'bold' },
      },
      -- Repeat for all modes to ensure transparency
      insert = {
        a = { bg = 'None', gui = 'bold' },
        b = { bg = 'None', gui = 'bold' },
        c = { bg = 'None', gui = 'bold' },
        x = { bg = 'None', gui = 'bold' },
        y = { bg = 'None', gui = 'bold' },
        z = { bg = 'None', gui = 'bold' },
      },
      visual = {
        a = { bg = 'None', gui = 'bold' },
        b = { bg = 'None', gui = 'bold' },
        c = { bg = 'None', gui = 'bold' },
        x = { bg = 'None', gui = 'bold' },
        y = { bg = 'None', gui = 'bold' },
        z = { bg = 'None', gui = 'bold' },
      },
      replace = {
        a = { bg = 'None', gui = 'bold' },
        b = { bg = 'None', gui = 'bold' },
        c = { bg = 'None', gui = 'bold' },
        x = { bg = 'None', gui = 'bold' },
        y = { bg = 'None', gui = 'bold' },
        z = { bg = 'None', gui = 'bold' },
      },
      command = {
        a = { bg = 'None', gui = 'bold' },
        b = { bg = 'None', gui = 'bold' },
        c = { bg = 'None', gui = 'bold' },
        x = { bg = 'None', gui = 'bold' },
        y = { bg = 'None', gui = 'bold' },
        z = { bg = 'None', gui = 'bold' },
      },
      inactive = {
        a = { bg = 'None', gui = 'bold' },
        b = { bg = 'None', gui = 'bold' },
        c = { bg = 'None', gui = 'bold' },
        x = { bg = 'None', gui = 'bold' },
        y = { bg = 'None', gui = 'bold' },
        z = { bg = 'None', gui = 'bold' },
      },
    }

    local conditions = {
      hide_in_width = function()
        return vim.fn.winwidth(0) > 80
      end,
      alpha = function()
        if vim.bo.filetype ~= 'alpha' then
          return true
        end
      end,
    }

    -- ⚡️ MAP MODE COLORS TO ROSÉ PINE ACCENTS
    local mode_color = {
      n = colors.love, -- Normal (Red)
      i = colors.pine, -- Insert (Green)
      v = colors.foam, -- Visual (Blue)
      [''] = colors.foam, -- Visual Block
      V = colors.foam, -- Visual Line
      c = colors.iris, -- Command (Magenta/Violet)
      no = colors.love, -- Normal Operator-pending
      s = colors.gold, -- Select (Yellow/Gold)
      S = colors.gold,
      [''] = colors.gold,
      ic = colors.gold, -- Insert Completion
      R = colors.iris, -- Replace
      Rv = colors.iris, -- Visual Replace
      cv = colors.love, -- Command Visual
      ce = colors.love, -- Command Ex
      r = colors.rose, -- Prompt/Hit-Enter (Cyan/Pink)
      rm = colors.rose,
      ['r?'] = colors.rose,
      ['!'] = colors.love,
      t = colors.love, -- Terminal
    }

    local function mason_updates()
      local registry = require 'mason-registry'
      registry.refresh()
      local installed_packages = registry.get_installed_package_names()

      local packages_outdated = 0

      for _, pkg in pairs(installed_packages) do
        local p = registry.get_package(pkg)
        local version = p.get_installed_version(p)
        local latest = p.get_latest_version(p)

        if version ~= latest then
          packages_outdated = packages_outdated + 1
        end
      end

      return packages_outdated
    end

    local function show_macro_recording()
      local recording_register = vim.fn.reg_recording()
      if recording_register == '' then
        return ''
      else
        return '󰑋  ' .. recording_register
      end
    end

    local function get_buffers()
      local bufs = vim.api.nvim_list_bufs()
      local bufNumb = 0
      local function buffer_is_valid(buf_id, buf_name)
        -- Use Rosé Pine colors for `text` and `base`
        return 1 == vim.fn.buflisted(buf_id) and buf_name ~= ''
      end
      for idx = 1, #bufs do
        local buf_id = bufs[idx]
        local buf_name = vim.api.nvim_buf_get_name(buf_id)
        if buffer_is_valid(buf_id, buf_name) then
          bufNumb = bufNumb + 1
        end
      end

      if bufNumb == 1 then
        return bufNumb .. ' '
      else
        return bufNumb .. ' '
      end
    end

    -- 🎨 APPLY ROSÉ PINE COLORS TO COMPONENTS
    local mode = {
      'mode',
      separator = { left = '', right = '' },
      right_padding = 2,
      color = function()
        -- Background is the Mode Color, Foreground is the Rosé Pine Base
        return { bg = mode_color[vim.fn.mode()], fg = colors.base }
      end,
    }
    local filename = {
      'filename',
      color = { fg = colors.rose, bg = 'None', gui = 'bold' },
      cond = conditions.alpha,
    }
    local alpha = {
      function()
        return 'Alpha Dashboard'
      end,
      color = { fg = colors.rose, bg = 'None', gui = 'bold' },
      cond = function()
        if vim.bo.filetype == 'alpha' then
          return true
        end
      end,
    }
    local branch = {
      'branch',
      icon = '',
      color = { fg = colors.iris, bg = 'None', gui = 'bold' },
      on_click = function()
        vim.cmd 'LazyGit'
      end,
    }
    local lsp_status = {
      'lsp-status',
      color = { fg = colors.pine, bg = 'None', gui = 'bold' },
      on_click = function()
        vim.cmd 'LspInfo'
      end,
      cond = conditions.alpha,
    }
    local diagnostics = {
      'diagnostics',
      sources = { 'nvim_diagnostic' },
      symbols = { error = ' ', warn = ' ', info = ' ' },
      diagnostics_color = {
        -- Map to Rosé Pine Accent Colors
        color_error = { fg = colors.love, bg = 'None', gui = 'bold' },
        color_warn = { fg = colors.gold, bg = 'None', gui = 'bold' },
        color_info = { fg = colors.foam, bg = 'None', gui = 'bold' },
      },
      -- NOTE: `color` should not be `bg = mode`. Setting to text for consistency.
      color = { fg = colors.text, gui = 'bold' },
    }
    local macro_recording = {
      show_macro_recording,
      -- Use Rosé Pine names
      color = { fg = colors.text, bg = colors.love },
      separator = { left = '', right = '' },
    }
    local harpoon = {
      'harpoon2',
      icon = '󰀱',
      indicators = { '1', '2', '3', '4' },
      active_indicators = { '[1]', '[2]', '[3]', '[4]' },
      _separator = ' ',
      separator = { left = '', right = '' },
      color = function()
        -- Background is the Mode Color, Foreground is the Rosé Pine Base
        return { bg = mode_color[vim.fn.mode()], fg = colors.base, gui = 'bold' }
      end,
    }
    local copilot = {
      'copilot',
      symbols = {
        status = {
          hl = {
            -- Map to Rosé Pine Accent Colors
            enabled = colors.pine,
            sleep = colors.gold,
            disabled = colors.base,
            warning = colors.love, -- Using love (red) for a warning state
            unknown = colors.love,
          },
        },
      },
      show_colors = true,
      color = { bg = 'None', gui = 'bold' },
      cond = conditions.alpha,
    }
    local diff = {
      'diff',
      symbols = { added = ' ', modified = '󰝤 ', removed = ' ' },
      diff_color = {
        -- Map to Rosé Pine Accent Colors
        added = { fg = colors.pine, bg = 'None' },
        modified = { fg = colors.gold, bg = 'None' },
        removed = { fg = colors.love, bg = 'None' },
      },
      cond = conditions.hide_in_width,
    }
    local fileformat = {
      'fileformat',
      fmt = string.upper,
      color = { fg = colors.pine, bg = 'None', gui = 'bold' },
      cond = conditions.alpha,
    }
    local lazy = {
      require('lazy.status').updates,
      cond = require('lazy.status').has_updates,
      color = { fg = colors.iris, bg = 'None' },
      on_click = function()
        vim.ui.select({ 'Yes', 'No' }, { prompt = 'Update plugins?' }, function(choice)
          if choice == 'Yes' then
            vim.cmd 'Lazy sync'
          else
            vim.notify('Update cancelled', vim.log.levels.INFO, { title = 'Lazy' })
          end
        end)
      end,
    }
    local mason = {
      mason_updates() .. '',
      color = { fg = colors.iris, bg = 'None' },
      cond = function()
        return mason_updates() > 0
      end,
      icon = '',
      on_click = function()
        vim.cmd 'Mason'
      end,
    }
    local buffers = {
      get_buffers(),
      color = { fg = colors.foam, bg = 'None' },
      on_click = function()
        -- assuming you have a buffer manager plugin installed
        -- require('buffer_manager.ui').toggle_quick_menu()
        vim.cmd.Telescope 'buffers'
      end,
    }
    local filetype = {
      'filetype',
      color = { fg = colors.foam, bg = 'None' },
      cond = conditions.alpha,
    }
    local progress = {
      'progress',
      color = { fg = colors.rose, bg = 'None' },
    }
    local location = {
      'location',
      separator = { left = '', right = '' },
      left_padding = 2,
      color = function()
        -- Background is the Mode Color, Foreground is the Rosé Pine Base
        return { bg = mode_color[vim.fn.mode()], fg = colors.base }
      end,
    }
    local sep = {
      '%=',
      -- Foreground is the Rosé Pine Base for a true separator color
      color = { fg = colors.base, bg = 'None' },
    }

    lualine.setup {
      options = {
        theme = theme,
        component_separators = '',
        section_separators = { left = '', right = '' },
        always_divide_middle = false,
      },
      sections = {
        lualine_a = { mode },
        lualine_b = { filename, alpha, branch, lsp_status },
        lualine_c = { diagnostics, sep, macro_recording, harpoon },
        lualine_x = { copilot, diff, fileformat, lazy, mason },
        lualine_y = { buffers, filetype, progress },
        lualine_z = { location },
      },
      inactive_sections = {
        lualine_a = { filename },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = { location },
      },
      tabline = {},
      extensions = {},
    }
  end,
}
