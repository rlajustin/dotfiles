-- File: ~/.config/nvim/after/ftplugin/tex.lua

-- Helper function to break a paragraph into lines of specified width
local function break_paragraph(text, width)
  local lines = {}
  local current_line = ''

  -- Split by spaces but keep track of words
  for word in text:gmatch '%S+' do
    -- Check if adding this word would exceed the width
    local test_line = current_line == '' and word or current_line .. ' ' .. word

    if #test_line <= width then
      current_line = test_line
    else
      -- Line would be too long, start a new line
      if current_line ~= '' then
        table.insert(lines, current_line)
      end
      current_line = word
    end
  end

  -- Add the last line if it's not empty
  if current_line ~= '' then
    table.insert(lines, current_line)
  end

  return lines
end

-- LaTeX paragraph formatting function
local function latex_paragraph_format()
  local start_line = vim.v.lnum - 1 -- Convert to 0-indexed
  local count = vim.v.count

  -- Get the lines to format
  local lines = vim.api.nvim_buf_get_lines(0, start_line, start_line + count, false)
  local formatted_lines = {}

  local i = 1
  while i <= #lines do
    local line = lines[i]

    -- Skip empty lines and lines that start with LaTeX commands
    if line:match '^%s*$' or line:match '^%s*\\' or line:match '^%s*%%' then
      table.insert(formatted_lines, line)
      i = i + 1
    else
      -- This is a text line, collect the paragraph
      local paragraph_lines = {}

      -- Collect consecutive non-empty, non-command lines
      while i <= #lines do
        local current_line = lines[i]

        -- Stop if we hit an empty line, command, or comment
        if current_line:match '^%s*$' or current_line:match '^%s*\\' or current_line:match '^%s*%%' then
          break
        end

        table.insert(paragraph_lines, current_line:match '^%s*(.-)%s*$') -- trim whitespace
        i = i + 1
      end

      -- Join the paragraph into one line, then break it nicely
      if #paragraph_lines > 0 then
        local paragraph = table.concat(paragraph_lines, ' ')

        -- Break the paragraph into lines of reasonable length (around 80 chars)
        local formatted_paragraph = break_paragraph(paragraph, 80)

        -- Add the formatted paragraph lines
        for _, p_line in ipairs(formatted_paragraph) do
          table.insert(formatted_lines, p_line)
        end

        -- Add a blank line after each paragraph (if not at the end)
        if i <= #lines then
          table.insert(formatted_lines, '')
        end
      end
    end
  end

  -- Replace the original lines with formatted ones
  vim.api.nvim_buf_set_lines(0, start_line, start_line + count, false, formatted_lines)

  return 0
end

-- Make the function available globally (required for formatexpr)
_G.latex_paragraph_format = latex_paragraph_format

-- Set the formatexpr for this buffer
vim.bo.formatexpr = 'v:lua.latex_paragraph_format()'
