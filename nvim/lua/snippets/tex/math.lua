local ls = require 'luasnip'
local f = ls.function_node
local d = ls.dynamic_node
local r = ls.restore_node

-- Auxiliary functions

-- Math zone context
-- taken from https://ejmastnak.com/

local in_mathzone = function()
  return vim.fn['vimtex#syntax#in_mathzone']() == 1
end
--
-- Add this function after your existing auxiliary functions
local not_in_latex_command = function()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]

  -- Get text before cursor
  local text_before_cursor = line:sub(1, col)

  -- Check if there's a backslash followed by letters without whitespace before cursor
  local in_command = text_before_cursor:match '\\%w*$'

  return not in_command
end

-- Combined condition for math mode and not in LaTeX command
local math_and_not_command = function()
  return in_mathzone() and not_in_latex_command()
end

-- Visual placeholder
-- taken from https://ejmastnak.com/

local get_visual = function(args, parent, default_text)
  if #parent.snippet.env.LS_SELECT_RAW > 0 then
    return sn(nil, i(1, parent.snippet.env.LS_SELECT_RAW))
  else -- If LS_SELECT_RAW is empty, return a blank insert node
    return sn(nil, i(1, default_text))
  end
end

local function v(pos, default_text)
  return d(pos, function(args, parent)
    return get_visual(args, parent, default_text)
  end)
end

-- Matrices and cases
-- taken from github.com/evesdropper

local generate_matrix = function(args, snip)
  local rows = tonumber(snip.captures[2])
  local cols = tonumber(snip.captures[3])
  local nodes = {}
  local ins_indx = 1
  for j = 1, rows do
    table.insert(nodes, r(ins_indx, tostring(j) .. 'x1', i(1)))
    ins_indx = ins_indx + 1
    for k = 2, cols do
      table.insert(nodes, t ' & ')
      table.insert(nodes, r(ins_indx, tostring(j) .. 'x' .. tostring(k), i(1)))
      ins_indx = ins_indx + 1
    end
    table.insert(nodes, t { ' \\\\', '' })
  end
  nodes[#nodes] = t ' \\\\'
  return sn(nil, nodes)
end

local generate_hom_matrix = function(args, snip)
  local rows = tonumber(snip.captures[2])
  local cols = tonumber(snip.captures[3])
  local nodes = {}
  local ins_indx = 1
  for j = 1, rows do
    if j == 1 then
      table.insert(nodes, r(ins_indx, i(1)))
      table.insert(nodes, t '_{11}')
    else
      table.insert(nodes, rep(1))
      table.insert(nodes, t('_{' .. tostring(j) .. '1}'))
    end
    ins_indx = ins_indx + 1
    for k = 2, cols do
      table.insert(nodes, t ' & ')
      table.insert(nodes, rep(1))
      table.insert(nodes, t('_{' .. tostring(j) .. tostring(k) .. '}'))
      ins_indx = ins_indx + 1
    end
    table.insert(nodes, t { ' \\\\', '' })
  end
  nodes[#nodes] = t ' \\\\'
  return sn(nil, nodes)
end

local generate_cases = function(args, snip)
  local rows = tonumber(snip.captures[1]) or 2
  local cols = 2
  local nodes = {}
  local ins_indx = 1
  for j = 1, rows do
    table.insert(nodes, r(ins_indx, tostring(j) .. 'x1', sn(1, { t '    \\hfil ', i(1) })))
    ins_indx = ins_indx + 1
    for k = 2, cols do
      table.insert(nodes, t ' & ')
      table.insert(nodes, r(ins_indx, tostring(j) .. 'x' .. tostring(k), i(1)))
      ins_indx = ins_indx + 1
    end
    table.insert(nodes, t { ' \\\\', '' })
  end
  table.remove(nodes, #nodes)
  return sn(nil, nodes)
end

-- Snippets

return {

  -- Math

  -- Math alphabet identifiers

  s({ trig = 'mc', name = 'Calligraphic math font', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\mathcal{',
    d(1, get_visual),
    t '}',
  }, { condition = math_and_not_command }),

  s({ trig = 'mr', name = 'Roman math font', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\mathrm{',
    d(1, get_visual),
    t '}',
  }, { condition = math_and_not_command }),

  s({ trig = 'mb', name = 'Bold math font', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\mathbf{',
    d(1, get_visual),
    t '}',
  }, { condition = math_and_not_command }),

  s({ trig = 'ms', name = 'Sans serif math font', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\mathsf{',
    d(1, get_visual),
    t '}',
  }, { condition = math_and_not_command }),

  s({ trig = 'mt', name = 'Typewriter math font', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\mathtt{',
    d(1, get_visual),
    t '}',
  }, { condition = math_and_not_command }),

  s({ trig = 'mn', name = 'Normal math font', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\mathnormal{',
    d(1, get_visual),
    t '}',
  }, { condition = math_and_not_command }),

  s({ trig = 'mi', name = 'Italic math font', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\mathit{',
    d(1, get_visual),
    t '}',
  }, { condition = math_and_not_command }),

  s({ trig = 'mf', name = 'Euler Fraktur math font', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\mathfrak{',
    d(1, get_visual),
    t '}',
  }, { condition = math_and_not_command }),

  s({ trig = 'mk', name = 'Blackboard bold math font', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\mathbb{',
    d(1, get_visual),
    t '}',
  }, { condition = math_and_not_command }),

  -- Display environments and alignment structures

  s({ trig = 'mm', name = 'Inline display', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '$',
    d(1, get_visual),
    t '$',
  }),

  s({ trig = 'en', name = 'Generic environment' }, {
    t '\\begin{',
    i(1, 'env'),
    t '}',
    t { '', '' },
    t '    ',
    d(2, get_visual),
    t { '', '' },
    t '\\end{',
    rep(1),
    t '}',
  }),

  s({ trig = 'nn', name = 'New equation' }, {
    c(1, {
      {
        t '\\begin{equation*}',
        t { '', '' },
        t '    ',
        d(1, get_visual),
        t { '', '' },
        t '\\end{equation*}',
      },
      {
        t '\\begin{equation}',
        t { '', '' },
        t '    ',
        d(1, get_visual),
        t { '', '' },
        t '\\end{equation}',
      },
    }),
  }),

  s({ trig = 'ml', name = 'New multline' }, {
    c(1, {
      {
        t '\\begin{multline}',
        t { '', '' },
        t '    ',
        d(1, get_visual),
        t { '', '' },
        t '\\end{multline}',
      },
      {
        t '\\begin{multline*}',
        t { '', '' },
        t '    ',
        d(1, get_visual),
        t { '', '' },
        t '\\end{multline*}',
      },
    }),
  }),

  s({ trig = 'gap', name = 'Multline gap' }, {
    t '\\setlenght\\multlinegap{0pt}',
  }),

  s({ trig = 'sp', name = 'New split' }, {
    t '\\begin{split}',
    t { '', '' },
    t '    ',
    d(1, get_visual),
    t { '', '' },
    t '\\end{split}',
  }),

  s({ trig = 'gg', name = 'New gather' }, {
    c(1, {
      {
        t '\\begin{gather}',
        t { '', '' },
        t '    ',
        d(1, get_visual),
        t { '', '' },
        t '\\end{gather}',
      },
      {
        t '\\begin{gather*}',
        t { '', '' },
        t '    ',
        d(1, get_visual),
        t { '', '' },
        t '\\end{gather*}',
      },
    }),
  }),

  s({ trig = 'aa', name = 'New align' }, {
    c(1, {
      {
        t '\\begin{align*}',
        t { '', '' },
        t '    ',
        d(1, get_visual),
        t { '', '' },
        t '\\end{align*}',
      },
      {
        t '\\begin{align}',
        t { '', '' },
        t '    ',
        d(1, get_visual),
        t { '', '' },
        t '\\end{align}',
      },
    }),
  }),

  s({ trig = 'fal', name = 'New falign' }, {
    c(1, {
      {
        t '\\begin{falign}',
        t { '', '' },
        t '    ',
        d(1, get_visual),
        t { '', '' },
        t '\\end{falign}',
      },
      {
        t '\\begin{falign*}',
        t { '', '' },
        t '    ',
        d(1, get_visual),
        t { '', '' },
        t '\\end{falign*}',
      },
    }),
  }),

  s({ trig = '(%d?)cs', name = 'New cases environment', snippetType = 'autosnippet', regTrig = true }, {
    t '\\begin{cases}',
    t { '', '' },
    d(1, generate_cases),
    t { '', '' },
    t '\\end{cases}',
  }, { condition = math_and_not_command }),

  s({ trig = 'br', name = 'Display line break', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\\\',
    t { '', '' },
    i(1),
  }, { condition = math_and_not_command }),

  s({ trig = 'itr', name = 'Short text between lines', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\intertext{',
    v(1, 'text'),
    t '}',
  }, { condition = math_and_not_command }),

  s({ trig = 'tx', name = 'Text inside display', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\text{',
    v(1, 'text'),
    t '}',
  }, { condition = math_and_not_command }),

  s({ trig = 'dib', name = 'Display page break', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\displaybreak',
  }, { condition = math_and_not_command }),

  s({ trig = 'dis', name = 'Displaystyle', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\displaystyle',
  }, { condition = math_and_not_command }),

  s({ trig = 'ty', name = 'Textstyle', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\textstyle',
  }, { condition = math_and_not_command }),

  -- Equation numbering and tags

  s({ trig = 'ntg', name = 'Suppress equation tag', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\notag',
  }, { condition = math_and_not_command }),

  s({ trig = 'tag', name = 'Equation tag', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        t '\\tag{',
        v(1, 'tag'),
        t '}',
      },
      {
        t '\\tag*{',
        v(1, 'tag'),
        t '}',
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'teq', name = 'Last number equation' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\theequation',
  }),

  -- Matrix-like environments

  s({ trig = '([bBpvV])(%d+)x(%d+)', name = 'New matrix', snippetType = 'autosnippet', regTrig = true }, {
    t '\\begin{',
    f(function(_, snip)
      return snip.captures[1] .. 'matrix'
    end),
    t '}',
    t { '', '' },
    d(1, generate_matrix),
    t { '', '' },
    t '\\end{',
    f(function(_, snip)
      return snip.captures[1] .. 'matrix'
    end),
    t '}',
  }, { condition = math_and_not_command }),

  s({ trig = '([bBpvV])(%d+)h(%d+)', name = 'New homogeneous matrix', snippetType = 'autosnippet', regTrig = true }, {
    t '\\begin{',
    f(function(_, snip)
      return snip.captures[1] .. 'matrix'
    end),
    t '}',
    t { '', '' },
    d(1, generate_hom_matrix),
    t { '', '' },
    t '\\end{',
    f(function(_, snip)
      return snip.captures[1] .. 'matrix'
    end),
    t '}',
  }, { condition = math_and_not_command }),

  s({ trig = '([bBpvV])gn', name = 'New generic matrix', snippetType = 'autosnippet', regTrig = true }, {
    t '\\begin{',
    f(function(_, snip)
      return snip.captures[1] .. 'matrix'
    end),
    t '}',
    t { '', '' },
    t '    ',
    i(1),
    t '_{11} & ',
    rep(1),
    t '_{12} & \\cdots & ',
    rep(1),
    t '_{1',
    i(2),
    t '}',
    t ' \\\\',
    t { '', '' },
    t '    ',
    rep(1),
    t '_{21} & ',
    rep(1),
    t '_{22} & \\cdots & ',
    rep(1),
    t '_{2',
    rep(2),
    t '}',
    t ' \\\\',
    t { '', '' },
    t '    ',
    t '\\vdots & \\vdots & \\ddots & \\vdots \\\\',
    t { '', '' },
    t '    ',
    rep(1),
    t '_{',
    i(3),
    t '1} & ',
    rep(1),
    t '_{',
    rep(3),
    t '2} & \\cdots & ',
    rep(1),
    t '_{',
    rep(3),
    rep(2),
    t '} \\\\',
    t { '', '' },
    t '\\end{',
    f(function(_, snip)
      return snip.captures[1] .. 'matrix'
    end),
    t '}',
  }, { condition = math_and_not_command }),

  -- Subscripts and superscripts

  s({ trig = ':', name = 'Subscript', snippetType = 'autosnippet', wordTrig = false }, {
    t '_{',
    d(1, get_visual),
    t '}',
  }, { condition = math_and_not_command }),

  s({ trig = ';', name = 'Superscript', snippetType = 'autosnippet', wordTrig = false }, {
    t '^{',
    d(1, get_visual),
    t '}',
  }, { condition = math_and_not_command }),

  s({ trig = 'st', name = 'Stacking', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\substack{',
    d(1, get_visual),
    t ' \\\\ ',
    i(2),
    t '}',
  }, { condition = math_and_not_command }),

  -- Compound structures

  s({ trig = 'lxl', name = 'Left relation arrow', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        t '\\xleftarrow{',
        i(1, 'top'),
        t '}',
      },
      {
        t '\\xleftarrow[',
        i(1, 'bottom'),
        t ']{',
        i(2, 'top'),
        t '}',
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'lxr', name = 'Left relation arrow', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        t '\\xrightarrow{',
        i(1, 'top'),
        t '}',
      },
      {
        t '\\xrightarrow[',
        i(1, 'bottom'),
        t ']{',
        i(2, 'top'),
        t '}',
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'cf', name = 'Continued fraction', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        t '\\cfrac{',
        i(1, 'num'),
        t '}{',
        t { '', '' },
        t '    ',
        i(2, 'den'),
        t { '', '' },
        t '}',
      },
      {
        t '\\cfrac[',
        i(1, 'num-alignment'),
        t ']{',
        i(2, 'num'),
        t '}{',
        t { '', '' },
        t '    ',
        i(3, 'den'),
        t { '', '' },
        t '}',
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'bx', name = 'Boxed formula', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\boxed{',
    d(1, get_visual),
    t '}',
  }, { condition = math_and_not_command }),

  s({ trig = 'ff', name = 'Fraction', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        t '\\frac{',
        i(1),
        t '}{',
        i(2),
        t '}',
      },
      {
        t '\\dfrac{',
        i(1),
        t '}{',
        i(2),
        t '}',
      },
      {
        t '\\tfrac{',
        i(1),
        t '}{',
        i(2),
        t '}',
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'bm', name = 'Binomial coefficient', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        t '\\binom{',
        i(1),
        t '}{',
        i(2),
        t '}',
      },
      {
        t '\\dbinom{',
        i(1),
        t '}{',
        i(2),
        t '}',
      },
      {
        t '\\tbinom{',
        i(1),
        t '}{',
        i(2),
        t '}',
      },
    }),
  }, { condition = math_and_not_command }),

  -- Decorations

  s({ trig = 'abv', name = 'Place material above', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\overset{',
    i(1, 'above'),
    t '}{',
    v(2, 'material'),
    t '}',
  }, { condition = math_and_not_command }),

  s({ trig = 'bel', name = 'Place material below', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\underset{',
    i(1, 'below'),
    t '}{',
    v(2, 'material'),
    t '}',
  }, { condition = math_and_not_command }),

  -- Limiting positions

  s({ trig = 'lim', name = 'Above/below operator', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\limits',
  }, { condition = math_and_not_command }),

  s({ trig = 'nli', name = 'Right of the operator', snippetType = 'autosnippet' }, {
    t '\\nolimits',
  }, { condition = math_and_not_command }),

  -- Relations

  s({ trig = 'eq', name = 'Congruence relation', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\equiv',
  }, { condition = math_and_not_command }),

  s({ trig = 'md', name = 'Mod operator', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\Mod{',
    i(1),
    t '}',
  }, { condition = math_and_not_command }),

  -- local macro
  s({ trig = 'mod', name = 'Modular relation', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        i(1, '...'),
        t ' \\equiv ',
        i(2, '...'),
        t ' \\pmod{',
        i(3, '...'),
        t '}',
      },
      {
        i(1, '...'),
        t ' \\not\\equiv ',
        i(2, '...'),
        t ' \\pmod{',
        i(3, '...'),
        t '}',
      },
      {
        i(1, '...'),
        t ' \\equiv ',
        i(2, '...'),
        t ' \\mod{',
        i(3, '...'),
        t '}',
      },
      {
        i(1, '...'),
        t ' \\not\\equiv ',
        i(2, '...'),
        t ' \\mod{',
        i(3, '...'),
        t '}',
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'sbg', name = 'Left triangle', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        i(1, '\\vartriangleleft'),
      },
      {
        i(1, '\\ntriangleleft'),
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'sgc', name = 'Right triangle', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        i(1, '\\vartriangleright'),
      },
      {
        i(1, '\\ntriangleright'),
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'ne', name = 'Not equal', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\ne',
  }, { condition = math_and_not_command }),

  s({ trig = 'nr', name = 'Relation negation', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\not',
  }, { condition = math_and_not_command }),

  s({ trig = 'app', name = 'Approx', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\approx',
  }, { condition = math_and_not_command }),

  s({ trig = 'cn', name = 'Congruent', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        i(1, '\\cong'),
      },
      {
        i(1, '\\ncong'),
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'le', name = 'Less or equal', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\le',
  }, { condition = math_and_not_command }),

  s({ trig = 'ge', name = 'Greater or equal', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\ge',
  }, { condition = math_and_not_command }),

  s({ trig = 'pc', name = 'Precedes', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        i(1, '\\prec'),
      },
      {
        i(1, '\\nprec'),
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'sx', name = 'Succedes', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        i(1, '\\succ'),
      },
      {
        i(1, '\\nsucc'),
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 're', name = 'Relation', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        i(1, '\\sim'),
      },
      {
        i(1, '\\nsim'),
      },
    }),
  }, { condition = math_and_not_command }),

  -- Operators

  s({ trig = 'opr', name = 'Define new operator' }, {
    c(1, {
      {
        t '\\DeclareMathOperator{',
        i(1, 'cmd'),
        t '}{',
        i(2, 'text'),
        t '}',
      },
      {
        t '\\DeclareMathOperator*{',
        i(1, 'cmd'),
        t '}{',
        i(2, 'text'),
        t '}',
      },
    }),
  }),

  s({ trig = 'ce', name = 'Ceiling', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        t '\\lceil ',
        d(1, get_visual),
        t ' \\rceil',
      },
      {
        t '\\left\\lceil ',
        d(1, get_visual),
        t ' \\right\\rceil',
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'fl', name = 'Floor', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        t '\\lfloor ',
        d(1, get_visual),
        t ' \\rfloor',
      },
      {
        t '\\left\\lfloor ',
        d(1, get_visual),
        t ' \\right\\rfloor',
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'sq', name = 'Square root', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        t '\\sqrt{',
        d(1, get_visual),
        t '}',
      },
      {
        t '\\sqrt[',
        i(1, 'n-th'),
        t ']{',
        d(2, get_visual),
        t '}',
      },
      {
        t '\\sqrt[\\leftroot{',
        i(1, 'x'),
        t '}\\uproot{',
        i(2, 'y'),
        t '} ',
        i(3, 'n-th'),
        t ']{',
        d(4, get_visual),
        t '}',
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'imp', name = 'Imaginary part', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\Im',
  }, { condition = math_and_not_command }),

  s({ trig = 'rpa', name = 'Real part', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\Re',
  }, { condition = math_and_not_command }),

  s({ trig = 'opm', name = 'Mod operator', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    i(1, '...'),
    t ' \\bmod ',
    i(2, '...'),
  }, { condition = math_and_not_command }),

  s({ trig = 'mp', name = 'Minus plus', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\mp',
  }, { condition = math_and_not_command }),

  s({ trig = 'pm', name = 'Plus minus', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\pm',
  }, { condition = math_and_not_command }),

  s({ trig = 'tm', name = 'Times', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\times',
  }, { condition = math_and_not_command }),

  s({ trig = 'cd', name = 'Centered dot', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\cdot',
  }, { condition = math_and_not_command }),

  s({ trig = 'cir', name = 'Circle', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\circ',
  }, { condition = math_and_not_command }),

  s({ trig = 'opl', name = 'Oplus', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\oplus',
  }, { condition = math_and_not_command }),

  s({ trig = 'omt', name = 'Otimes', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\otimes',
  }, { condition = math_and_not_command }),

  s({ trig = 'dv', name = 'Middle bar', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\mid',
  }, { condition = math_and_not_command }),

  s({ trig = 'ndv', name = 'Middle bar', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\centernot\\mid',
  }, { condition = math_and_not_command }),

  s({ trig = 'xm', name = 'Maximum', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        i(1, '\\max'),
      },
      {
        t '\\max_{',
        i(1, '...'),
        t '}',
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'mu', name = 'Minimum', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        i(1, '\\min'),
      },
      {
        t '\\min_{',
        i(1, '...'),
        t '}',
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'nf', name = 'Infimum', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        i(1, '\\inf'),
      },
      {
        t '\\inf_{',
        i(1, '...'),
        t '}',
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'sr', name = 'Supremum', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        i(1, '\\sup'),
      },
      {
        t '\\sup_{',
        i(1, '...'),
        t '}',
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'arg', name = 'Argument', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\arg',
  }, { condition = math_and_not_command }),

  s({ trig = 'deg', name = 'Degree', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\deg',
  }, { condition = math_and_not_command }),

  s({ trig = 'det', name = 'Determinant', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\det',
  }, { condition = math_and_not_command }),

  s({ trig = 'dim', name = 'Dimension', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\dim',
  }, { condition = math_and_not_command }),

  s({ trig = 'gc', name = 'Greatest common divisor', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\gcd',
  }, { condition = math_and_not_command }),

  s({ trig = 'hm', name = 'Hom', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\hom',
  }, { condition = math_and_not_command }),

  s({ trig = 'kr', name = 'Kernel', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\ker',
  }, { condition = math_and_not_command }),

  s({ trig = 'lap', name = 'Laplacian', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\nabla^2 ',
  }, { condition = math_and_not_command }),

  s({ trig = 'div', name = 'Divergence', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        t '\\nabla\\cdot\\vv{',
        i(1),
        t '}',
      },
      {
        t '\\nabla\\cdot\\vec{',
        i(1),
        t '}',
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'cur', name = 'Curl', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        t '\\nabla\\times\\vv{',
        i(1),
        t '}',
      },
      {
        t '\\nabla\\times\\vec{',
        i(1),
        t '}',
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'ba', name = 'Bra', snippetType = 'autosnippet' }, {
    c(1, {
      {
        t '\\bra{',
        i(1),
        t '}',
      },
      {
        t '\\bra*{',
        i(1),
        t '}',
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'kt', name = 'Ket', snippetType = 'autosnippet' }, {
    c(1, {
      {
        t '\\ket{',
        i(1),
        t '}',
      },
      {
        t '\\ket*{',
        i(1),
        t '}',
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'bk', name = 'Braket', snippetType = 'autosnippet' }, {
    c(1, {
      {
        t '\\braket{',
        i(1),
        t '}{',
        i(2),
        t '}',
      },
      {
        t '\\braket*{',
        i(1),
        t '}{',
        i(2),
        t '}',
      },
    }),
  }, { condition = math_and_not_command }),

  -- Operators with limits

  s({ trig = 'lm', name = 'Limit', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        t '\\lim_{',
        i(1),
        t ' \\to ',
        i(2),
        t '}',
      },
      {
        i(1, '\\lim'),
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'lif', name = 'liminf', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        t '\\liminf_{',
        i(1),
        t ' \\to ',
        i(2),
        t '}',
      },
      {
        i(1, '\\liminf'),
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'lsu', name = 'limsup', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        t '\\limsup_{',
        i(1),
        t ' \\to ',
        i(2),
        t '}',
      },
      {
        i(1, '\\limsup'),
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'lvf', name = 'varliminf', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        t '\\varliminf_{',
        i(1),
        t ' \\to ',
        i(2),
        t '}',
      },
      {
        i(1, '\\varliminf'),
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'lvu', name = 'varlimsup', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        t '\\varlimsup_{',
        i(1),
        t ' \\to ',
        i(2),
        t '}',
      },
      {
        i(1, '\\varlimsup'),
      },
    }),
  }, { condition = math_and_not_command }),

  -- Functions

  s({ trig = 'fn', name = 'Function domain and codomain', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    i(1, 'fun'),
    t ' : ',
    i(2, 'dom'),
    t ' \\to ',
    i(3, 'cod'),
  }, { condition = math_and_not_command }),

  s({ trig = 'fd', name = 'Function definition' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\begin{align*}',
    t { '', '' },
    t '    ',
    i(1, 'fun'),
    t ' : ',
    i(2, 'dom'),
    t ' & \\to ',
    i(3, 'cod'),
    t ' \\\\',
    t { '', '' },
    t '    ',
    i(4, 'point'),
    t ' & \\longmapsto ',
    i(5, 'img'),
    t { '', '' },
    t '\\end{align*}',
  }),

  s({ trig = 'sin', name = 'sin', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\sin',
  }, { condition = math_and_not_command }),

  s({ trig = 'cos', name = 'cos', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\cos',
  }, { condition = math_and_not_command }),

  s({ trig = 'tan', name = 'tan', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\tan',
  }, { condition = math_and_not_command }),

  s({ trig = 'cot', name = 'cot', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\cot',
  }, { condition = math_and_not_command }),

  s({ trig = 'sec', name = 'sec', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\sec',
  }, { condition = math_and_not_command }),

  s({ trig = 'cc', name = 'csc', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\csc',
  }, { condition = math_and_not_command }),

  s({ trig = 'asin', name = 'arcsin', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\arcsin',
  }, { condition = math_and_not_command }),

  s({ trig = 'acos', name = 'arccos', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\arccos',
  }, { condition = math_and_not_command }),

  s({ trig = 'atan', name = 'arctan', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\arctan',
  }, { condition = math_and_not_command }),

  s({ trig = 'acot', name = 'arccot', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\arccot',
  }, { condition = math_and_not_command }),

  s({ trig = 'asec', name = 'arcsec', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\arcsec',
  }, { condition = math_and_not_command }),

  s({ trig = 'acc', name = 'arccsc', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\arccsc',
  }, { condition = math_and_not_command }),

  s({ trig = 'sinh', name = 'sinh', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\sinh',
  }, { condition = math_and_not_command }),

  s({ trig = 'cosh', name = 'cosh', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\cosh',
  }, { condition = math_and_not_command }),

  s({ trig = 'tanh', name = 'tanh', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\tanh',
  }, { condition = math_and_not_command }),

  s({ trig = 'coth', name = 'coth', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\coth',
  }, { condition = math_and_not_command }),

  s({ trig = 'sch', name = 'sech', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\sech',
  }, { condition = math_and_not_command }),

  s({ trig = 'hcc', name = 'csch', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\csch',
  }, { condition = math_and_not_command }),

  s({ trig = 'ahsin', name = 'arcsinh', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\arcsinh',
  }, { condition = math_and_not_command }),

  s({ trig = 'ahcos', name = 'arccosh', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\arccosh',
  }, { condition = math_and_not_command }),

  s({ trig = 'ahtan', name = 'arctanh', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\arctanh',
  }, { condition = math_and_not_command }),

  s({ trig = 'ahcot', name = 'arccoth', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\arccoth',
  }, { condition = math_and_not_command }),

  s({ trig = 'ahsec', name = 'arcsech', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\arcsech',
  }, { condition = math_and_not_command }),

  s({ trig = 'ahcc', name = 'arccsch', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\arccsch',
  }, { condition = math_and_not_command }),

  s({ trig = 'xp', name = 'exp', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\exp',
  }, { condition = math_and_not_command }),

  s({ trig = 'ln', name = 'ln', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\ln',
  }, { condition = math_and_not_command }),

  s({ trig = 'lg', name = 'log', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\log',
  }, { condition = math_and_not_command }),

  -- Ellipsis

  s({ trig = 'dd', name = 'Lower dots', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\ldots',
  }, { condition = math_and_not_command }),

  s({ trig = 'cr', name = 'Centered dots', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\cdots',
  }, { condition = math_and_not_command }),

  s({ trig = 'vd', name = 'Vertical dots', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\vdots',
  }, { condition = math_and_not_command }),

  s({ trig = 'gd', name = 'Diagonal dots', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\ddots',
  }, { condition = math_and_not_command }),

  s({ trig = 'cln', name = 'Colon', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t ':',
  }, { condition = math_and_not_command }),

  s({ trig = 'sln', name = 'Semicolon', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t ';',
  }, { condition = math_and_not_command }),

  -- Horizontal extensions

  s({ trig = 'ovr', name = 'Overline', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\overline{',
    d(1, get_visual),
    t '}',
  }, { condition = math_and_not_command }),

  s({ trig = 'und', name = 'Underline', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\underline{',
    d(1, get_visual),
    t '}',
  }, { condition = math_and_not_command }),

  s({ trig = 'ovb', name = 'Overbrace', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\overbrace{',
    d(1, get_visual),
    t '}^{',
    i(2, 'top'),
    t '}',
  }, { condition = math_and_not_command }),

  s({ trig = 'unb', name = 'Underbrace', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\underbrace{',
    d(1, get_visual),
    t '}_{',
    i(2, 'bottom'),
    t '}',
  }, { condition = math_and_not_command }),

  -- Delimiters

  s({ trig = 'dp', name = 'Parenthesis', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\left( ',
    d(1, get_visual),
    t ' \\right)',
  }, { condition = math_and_not_command }),

  s({ trig = 'ds', name = 'Brackets', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\left[ ',
    d(1, get_visual),
    t ' \\right]',
  }, { condition = math_and_not_command }),

  s({ trig = 'bb', name = 'Braces', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\{ ',
    d(1, get_visual),
    t ' \\}',
  }, { condition = math_and_not_command }),

  s({ trig = 'db', name = 'Extensible braces', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\left\\{ ',
    d(1, get_visual),
    t ' \\right\\}',
  }, { condition = math_and_not_command }),

  s({ trig = 'dk', name = 'Angle brackets', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        t '\\left\\langle ',
        d(1, get_visual),
        t ' \\right\\rangle',
      },
      {
        t '\\langle ',
        d(1, get_visual),
        t ' \\rangle',
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'da', name = 'Pipes', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        t '\\left\\lvert ',
        d(1, get_visual),
        t ' \\right\\rvert',
      },
      {
        t '\\lvert ',
        d(1, get_visual),
        t ' \\rvert',
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'dn', name = 'Double pipes', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        t '\\left\\lVert ',
        d(1, get_visual),
        t ' \\right\\rVert',
      },
      {
        t '\\lVert ',
        d(1, get_visual),
        t ' \\rVert',
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'big', name = 'Big-d delimiters', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        i(1, '\\big'),
      },
      {
        i(1, '\\Big'),
      },
      {
        i(1, '\\bigg'),
      },
      {
        i(1, '\\Bigg'),
      },
    }),
  }, { condition = math_and_not_command }),

  -- Spacing commands

  s({ trig = 'thp', name = 'Thin space', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\,',
  }, { condition = math_and_not_command }),

  s({ trig = 'mdn', name = 'Medium space', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\:',
  }, { condition = math_and_not_command }),

  s({ trig = 'tkp', name = 'Thick space', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\;',
  }, { condition = math_and_not_command }),

  s({ trig = 'enp', name = 'Enskip', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\enskip',
  }, { condition = math_and_not_command }),

  s({ trig = 'qu', name = 'Quad', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\quad',
  }, { condition = math_and_not_command }),

  s({ trig = 'qq', name = 'Double quad', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\qquad',
  }, { condition = math_and_not_command }),

  s({ trig = 'thn', name = 'Negative thin space', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\!',
  }, { condition = math_and_not_command }),

  s({ trig = 'men', name = 'Negative medium space', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\negmedspace',
  }, { condition = math_and_not_command }),

  s({ trig = 'tkn', name = 'Negative thick space', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\negthickspace',
  }, { condition = math_and_not_command }),

  s({ trig = 'hs', name = 'Horizontal space', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\hspace{',
    i(1),
    t '}',
  }, { condition = math_and_not_command }),

  s({ trig = 'vs', name = 'Vertical space', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\vspace{',
    i(1),
    t '}',
  }, { condition = math_and_not_command }),

  -- Greek alphabet

  s({ trig = '[.]a', name = 'Alpha', snippetType = 'autosnippet', regTrig = true }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\alpha',
  }, { condition = math_and_not_command }),

  s({ trig = '[.]b', name = 'Beta', snippetType = 'autosnippet', regTrig = true }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\beta',
  }, { condition = math_and_not_command }),

  s({ trig = '[.]c', name = 'Chi', snippetType = 'autosnippet', regTrig = true }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\chi',
  }, { condition = math_and_not_command }),

  s({ trig = '[.]D', name = 'Uppercase delta', snippetType = 'autosnippet', regTrig = true }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\Delta',
  }, { condition = math_and_not_command }),

  s({ trig = '[.]d', name = 'Lowercase delta', snippetType = 'autosnippet', regTrig = true }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\delta',
  }, { condition = math_and_not_command }),

  s({ trig = '[.]e', name = 'Epsilon', snippetType = 'autosnippet', regTrig = true }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\varepsilon',
  }, { condition = math_and_not_command }),

  s({ trig = '[.]G', name = 'Uppercase gamma', snippetType = 'autosnippet', regTrig = true }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\Gamma',
  }, { condition = math_and_not_command }),

  s({ trig = '[.]g', name = 'Lowercase gamma', snippetType = 'autosnippet', regTrig = true }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\gamma',
  }, { condition = math_and_not_command }),

  s({ trig = '[.]h', name = 'Eta', snippetType = 'autosnippet', regTrig = true }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\eta',
  }, { condition = math_and_not_command }),

  s({ trig = '[.]i', name = 'Iota', snippetType = 'autosnippet', regTrig = true }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\iota',
  }, { condition = math_and_not_command }),

  s({ trig = '[.]k', name = 'Kappa', snippetType = 'autosnippet', regTrig = true }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\kappa',
  }, { condition = math_and_not_command }),

  s({ trig = '[.]L', name = 'Uppercase lambda', snippetType = 'autosnippet', regTrig = true }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\Lambda',
  }, { condition = math_and_not_command }),

  s({ trig = '[.]l', name = 'Lowercase lambda', snippetType = 'autosnippet', regTrig = true }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\lambda',
  }, { condition = math_and_not_command }),

  s({ trig = '[.]m', name = 'Mu', snippetType = 'autosnippet', regTrig = true }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\mu',
  }, { condition = math_and_not_command }),

  s({ trig = '[.]n', name = 'Nu', snippetType = 'autosnippet', regTrig = true }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\nu',
  }, { condition = math_and_not_command }),

  s({ trig = '[.]O', name = 'Uppercase omega', snippetType = 'autosnippet', regTrig = true }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\Omega',
  }, { condition = math_and_not_command }),

  s({ trig = '[.]o', name = 'Lowercase omega', snippetType = 'autosnippet', regTrig = true }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\omega',
  }, { condition = math_and_not_command }),

  s({ trig = '[.]Ph', name = 'Uppercase phi', snippetType = 'autosnippet', regTrig = true }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\Phi',
  }, { condition = math_and_not_command }),

  s({ trig = '[.]ph', name = 'Lowecase phi', snippetType = 'autosnippet', regTrig = true }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\varphi',
  }, { condition = math_and_not_command }),

  s({ trig = '[.]Pi', name = 'Uppercase pi', snippetType = 'autosnippet', regTrig = true }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\Pi',
  }, { condition = math_and_not_command }),

  s({ trig = '[.]pi', name = 'Lowercase pi', snippetType = 'autosnippet', regTrig = true }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\pi',
  }, { condition = math_and_not_command }),

  s({ trig = '[.]Ps', name = 'Uppercase psi', snippetType = 'autosnippet', regTrig = true }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\Psi',
  }, { condition = math_and_not_command }),

  s({ trig = '[.]ps', name = 'Lowercase psi', snippetType = 'autosnippet', regTrig = true }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\psi',
  }, { condition = math_and_not_command }),

  s({ trig = '[.]r', name = 'Rho', snippetType = 'autosnippet', regTrig = true }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\rho',
  }, { condition = math_and_not_command }),

  s({ trig = '[.]S', name = 'Uppercase sigma', snippetType = 'autosnippet', regTrig = true }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\Sigma',
  }, { condition = math_and_not_command }),

  s({ trig = '[.]s', name = 'Lowercase sigma', snippetType = 'autosnippet', regTrig = true }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\sigma',
  }, { condition = math_and_not_command }),

  s({ trig = '[.]ta', name = 'Tau', snippetType = 'autosnippet', regTrig = true }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\tau',
  }, { condition = math_and_not_command }),

  s({ trig = '[.]Th', name = 'Uppercase theta', snippetType = 'autosnippet', regTrig = true }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\Theta',
  }, { condition = math_and_not_command }),

  s({ trig = '[.]th', name = 'Lowercase theta', snippetType = 'autosnippet', regTrig = true }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\theta',
  }, { condition = math_and_not_command }),

  s({ trig = '[.]U', name = 'Uppercase upsilon', snippetType = 'autosnippet', regTrig = true }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\Upsilon',
  }, { condition = math_and_not_command }),

  s({ trig = '[.]u', name = 'Lowecase upsilon', snippetType = 'autosnippet', regTrig = true }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\upsilon',
  }, { condition = math_and_not_command }),

  s({ trig = '[.]X', name = 'Uppercase xi', snippetType = 'autosnippet', regTrig = true }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\Xi',
  }, { condition = math_and_not_command }),

  s({ trig = '[.]x', name = 'Lowercase xi', snippetType = 'autosnippet', regTrig = true }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\xi',
  }, { condition = math_and_not_command }),

  s({ trig = '[.]z', name = 'Zeta', snippetType = 'autosnippet', regTrig = true }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\zeta',
  }, { condition = math_and_not_command }),

  -- Letter-shaped symbols

  s({ trig = 'ha', name = 'Aleph', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\aleph',
  }, { condition = math_and_not_command }),

  s({ trig = 'hb', name = 'Beth', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\beth',
  }, { condition = math_and_not_command }),

  s({ trig = 'hd', name = 'Daleth', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\daleth',
  }, { condition = math_and_not_command }),

  s({ trig = 'hg', name = 'Gimel', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\gimel',
  }, { condition = math_and_not_command }),

  s({ trig = 'll', name = 'ell', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\ell',
  }, { condition = math_and_not_command }),

  s({ trig = 'cm', name = 'Set complement', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\complement',
  }, { condition = math_and_not_command }),

  s({ trig = 'hr', name = 'hbar', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\hbar',
  }, { condition = math_and_not_command }),

  s({ trig = 'hl', name = 'hslash', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\hslash',
  }, { condition = math_and_not_command }),

  s({ trig = 'pt', name = 'Partial', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\partial',
  }, { condition = math_and_not_command }),

  -- Miscellaneous symbols

  s({ trig = 'dl', name = 'Dollar sign', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\$',
  }, { condition = math_and_not_command }),

  s({ trig = 'hh', name = 'Numeral', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\#',
  }, { condition = math_and_not_command }),

  s({ trig = 'fy', name = 'Infinity', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\infty',
  }, { condition = math_and_not_command }),

  s({ trig = 'pr', name = 'Prime', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\prime',
  }, { condition = math_and_not_command }),

  s({ trig = 'per', name = 'Percentaje', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\%',
  }, { condition = math_and_not_command }),

  s({ trig = 'amp', name = 'Ampersand', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\&',
  }, { condition = math_and_not_command }),

  s({ trig = 'ang', name = 'Angle', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\angle',
  }, { condition = math_and_not_command }),

  s({ trig = 'nb', name = 'Nabla', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\nabla',
  }, { condition = math_and_not_command }),

  s({ trig = 'ch', name = 'Section symbol' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\S',
  }),

  -- Accents

  s({ trig = 'dr', name = 'Dot accent', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        t '\\dot{',
        v(1, '...'),
        t '}',
      },
      {
        t '\\ddot{',
        v(1, '...'),
        t '}',
      },
      {
        t '\\dddot{',
        v(1, '...'),
        t '}',
      },
      {
        t '\\ddddot{',
        v(1, '...'),
        t '}',
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'ht', name = 'Hat', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        t '\\hat{',
        v(1, '...'),
        t '}',
      },
      {
        t '\\widehat{',
        v(1, '...'),
        t '}',
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'rng', name = 'Math ring', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\mathring{',
    v(1, '...'),
    t '}',
  }, { condition = math_and_not_command }),

  s({ trig = 'til', name = 'Tilde', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        t '\\tilde{',
        i(1),
        t '}',
      },
      {
        t '\\widetilde{',
        i(1),
        t '}',
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'vv', name = 'Vector', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        t '\\vv{',
        v(1, '...'),
        t '}',
      },
      {
        t '\\vec{',
        v(1, '...'),
        t '}',
      },
    }),
  }, { condition = math_and_not_command }),

  -- Logic

  s({ trig = 'fa', name = 'For all', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\forall',
  }, { condition = math_and_not_command }),

  s({ trig = 'ex', name = 'Exists', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\exists',
  }, { condition = math_and_not_command }),

  s({ trig = 'nx', name = 'Not exist', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\nexists',
  }, { condition = math_and_not_command }),

  s({ trig = 'lt', name = 'Logic negation', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\lnot',
  }, { condition = math_and_not_command }),

  s({ trig = 'lan', name = 'Logic and', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\land',
  }, { condition = math_and_not_command }),

  s({ trig = 'lor', name = 'Logic or', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\lor',
  }, { condition = math_and_not_command }),

  s({ trig = 'ip', name = 'Implies', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\implies',
  }, { condition = math_and_not_command }),

  s({ trig = 'ib', name = 'Implied by', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\impliedby',
  }, { condition = math_and_not_command }),

  s({ trig = 'iff', name = 'If and only if', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\iff',
  }, { condition = math_and_not_command }),

  -- Sets and inclusion

  s({ trig = 'in', name = 'Belongs to', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\in',
  }, { condition = math_and_not_command }),

  s({ trig = 'ntn', name = 'Not in', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\notin',
  }, { condition = math_and_not_command }),

  s({ trig = 'na', name = 'Owns', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\ni',
  }, { condition = math_and_not_command }),

  s({ trig = 'vc', name = 'Empty set', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        i(1, '\\emptyset'),
      },
      {
        i(1, '\\varnothing'),
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'nun', name = 'Union', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\cup',
  }, { condition = math_and_not_command }),

  s({ trig = 'bun', name = 'Big union', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\bigcup',
  }, { condition = math_and_not_command }),

  s({ trig = 'sun', name = 'Big subscript union', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\bigcup_{',
    i(1),
    t '}',
  }, { condition = math_and_not_command }),

  s({ trig = 'dun', name = 'Big definite union', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\bigcup_{',
    i(1),
    t '}^{',
    i(2),
    t '}',
  }, { condition = math_and_not_command }),

  s({ trig = 'nit', name = 'Intersection', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\cap',
  }, { condition = math_and_not_command }),

  s({ trig = 'bit', name = 'Big intersection', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\bigcap',
  }, { condition = math_and_not_command }),

  s({ trig = 'sit', name = 'Big subscript intersection', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\bigcap_{',
    i(1),
    t '}',
  }, { condition = math_and_not_command }),

  s({ trig = 'dit', name = 'Big definite intersection', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\bigcap_{',
    i(1),
    t '}^{',
    i(2),
    t '}',
  }, { condition = math_and_not_command }),

  s({ trig = 'sf', name = 'Set difference', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\setminus',
  }, { condition = math_and_not_command }),

  s({ trig = 'sbs', name = 'Subset', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\subset',
  }, { condition = math_and_not_command }),

  s({ trig = 'sbq', name = 'Subset or equals', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        i(1, '\\subseteq'),
      },
      {
        i(1, '\\nsubseteq'),
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'sus', name = 'Contains', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\supset',
  }, { condition = math_and_not_command }),

  s({ trig = 'suq', name = 'Contains or equals', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        i(1, '\\supseteq'),
      },
      {
        i(1, '\\nsupseteq'),
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'setd', name = 'Dots set', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\{ ',
    i(1),
    t ' \\std ',
    i(2),
    t ' \\}',
  }, { condition = math_and_not_command }),

  s({ trig = 'setb', name = 'Bar set', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\{ ',
    i(1),
    t ' \\mid ',
    i(2),
    t ' \\}',
  }, { condition = math_and_not_command }),

  -- Arrows

  s({ trig = 'rar', name = 'Long right arrow', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\to ',
  }, { condition = math_and_not_command }),

  s({ trig = 'lar', name = 'Long left arrow', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\longleftarrow',
  }, { condition = math_and_not_command }),

  s({ trig = 'to', name = 'Maps to', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\mapsto',
  }, { condition = math_and_not_command }),

  -- Sums

  s({ trig = 'sm', name = 'Subscript sum', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        t '\\sum_{',
        i(1),
        t '}',
      },
      {
        i(1, '\\sum'),
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'ss', name = 'Definite sum', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\sum_{',
    i(1),
    t '}^{',
    i(2),
    t '}',
  }, { condition = math_and_not_command }),

  s({ trig = 'sos', name = 'Subscript o-sum', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\bigoplus_{',
    i(1),
    t '}',
  }, { condition = math_and_not_command }),

  s({ trig = 'nos', name = 'Definite o-sum', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\bigoplus_{',
    i(1),
    t '}^{',
    i(2),
    t '}',
  }, { condition = math_and_not_command }),

  -- Products

  s({ trig = 'sp', name = 'Subscript product', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        t '\\prod_{',
        i(1),
        t '}',
      },
      {
        i(1, '\\prod'),
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'pp', name = 'Definite product', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\prod_{',
    i(1),
    t '}^{',
    i(2),
    t '}',
  }, { condition = math_and_not_command }),

  s({ trig = 'sop', name = 'Subscript o-product', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\bigotimes_{',
    i(1),
    t '}',
  }, { condition = math_and_not_command }),

  s({ trig = 'nop', name = 'Definite o-product', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\bigotimes_{',
    i(1),
    t '}^{',
    i(2),
    t '}',
  }, { condition = math_and_not_command }),

  -- Derivatives

  s({ trig = 'df', name = 'Differential', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\dx{',
    i(1),
    t '}',
  }, { condition = math_and_not_command }),

  s({ trig = 'der', name = 'Derivative', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        t '\\der{',
        i(1, 'func'),
        t '}{',
        i(2, 'var'),
        t '}',
      },
      {
        t '\\Der{',
        i(1, 'func'),
        t '}{',
        i(2, 'var'),
        t '}',
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'ndr', name = 'n-th derivative', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        t '\\ndr{',
        i(1, 'n'),
        t '}{',
        i(2, 'func'),
        t '}{',
        i(3, 'var'),
        t '}',
      },
      {
        t '\\Ndr{',
        i(1, 'n'),
        t '}{',
        i(2, 'func'),
        t '}{',
        i(3, 'var'),
        t '}',
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'pdr', name = 'Partial derivative', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        t '\\pdr{',
        i(1, 'func'),
        t '}{',
        i(2, 'var'),
        t '}',
      },
      {
        t '\\Pdr{',
        i(1, 'func'),
        t '}{',
        i(2, 'var'),
        t '}',
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'npd', name = 'n-th partial derivative', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        t '\\npd{',
        i(1, 'n'),
        t '}{',
        i(2, 'func'),
        t '}{',
        i(3, 'var'),
        t '}',
      },
      {
        t '\\Npd{',
        i(1, 'n'),
        t '}{',
        i(2, 'func'),
        t '}{',
        i(3, 'var'),
        t '}',
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'evl', name = 'Derivative evaluation', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\evl{',
    i(1),
    t '}',
  }, { condition = math_and_not_command }),

  -- Integrals

  s({ trig = 'itn', name = 'Integral', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        i(1, '\\int'),
      },
      {
        i(1, '\\oint'),
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'its', name = 'Subscript integral', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        t '\\int_{',
        i(1),
        t '}',
      },
      {
        t '\\oint_{',
        i(1),
        t '}',
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'itd', name = 'Definite integral', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\int_{',
    i(1),
    t '}^{',
    i(2),
    t '}',
  }, { condition = math_and_not_command }),

  s({ trig = 'itbn', name = 'Double integral', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        i(1, '\\iint'),
      },
      {
        i(1, '\\oiint'),
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'itbs', name = 'Double integral subscript', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        t '\\iint_{',
        i(1),
        t '}',
      },
      {
        t '\\oiint_{',
        i(1),
        t '}',
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'ittn', name = 'Triple integral', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        i(1, '\\iiint'),
      },
      {
        i(1, '\\oiiint'),
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'itts', name = 'Triple integral subscript', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        t '\\iiint_{',
        i(1),
        t '}',
      },
      {
        t '\\oiiint_{',
        i(1),
        t '}',
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'itqn', name = 'Quadruple integral', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        i(1, '\\iiiint'),
      },
      {
        i(1, '\\oiiint'),
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'itqs', name = 'Quadruple integral subscript', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    c(1, {
      {
        t '\\iiint_{',
        i(1),
        t '}',
      },
      {
        t '\\oiiint_{',
        i(1),
        t '}',
      },
    }),
  }, { condition = math_and_not_command }),

  s({ trig = 'itmn', name = 'Multiple integral', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\idotsint',
  }, { condition = math_and_not_command }),

  s({ trig = 'itms', name = 'Multiple integral subscript', snippetType = 'autosnippet' }, {
    f(function(_, snip)
      return snip.captures[1]
    end),
    t '\\idotsint_{',
    i(1),
    t '}',
  }, { condition = math_and_not_command }),
}
