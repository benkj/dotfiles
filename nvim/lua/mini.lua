-- Mini Files

require('mini.files').setup({
  mappings = {
    close       = 'q',
    go_in       = '<Right>',
    go_in_plus  = '<CR>',
    go_out      = '<Left>',
    go_out_plus = 'H',
    mark_goto   = "'",
    mark_set    = 'm',
    reset       = '<BS>',
    reveal_cwd  = '@',
    show_help   = 'g?',
    synchronize = 'w',
    trim_left   = '<',
    trim_right  = '>',
  },

  -- General options
  options = {
    -- Whether to delete permanently or move into module-specific trash
    permanent_delete = true,
    -- Whether to use for editing directories
    use_as_default_explorer = true,
  },

  -- Customization of explorer windows
  windows = {
    -- Maximum number of windows to show side by side
    max_number = math.huge,
    -- Whether to show preview of file/directory under cursor
    preview = false,
    -- Width of focused window
    width_focus = 50,
    -- Width of non-focused window
    width_nofocus = 15,
    -- Width of preview window
    width_preview = 25,
  },
})

vim.keymap.set('n', ',mf', '<CMD>lua MiniFiles.open()<CR>', {silent = true })
vim.keymap.set('n', '<C-F>', function()
    local bufname = vim.api.nvim_buf_get_name(0)
    local path = vim.fn.fnamemodify(bufname, ':p')

    -- Noop if the buffer isn't valid.
    if path and vim.uv.fs_stat(path) then
        require('mini.files').open(bufname, false)
    end
end, 
{ desc = 'File explorer',}
)


-- Mini AI
--

local notebook_cell_miniai_spec = function(opts)
    return require("notebook-cells").miniai_spec(opts,'#[| ]%%')
end

local gen_spec = require('mini.ai').gen_spec
require('mini.ai').setup({
    custom_textobjects = {
      -- Tweak argument to be recognized only inside `()` between `;`
      a = gen_spec.argument({ brackets = { '%b()' }, separator = ';' }),

      -- Tweak function call to not detect dot in function name
      --f = gen_spec.function_call({ name_pattern = '[%w_]' }),

      f = gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }),
      c = gen_spec.treesitter({ a = '@class.outer', i = '@class.inner' }),
      b = gen_spec.treesitter({ a = '@block.outer', i = '@block.inner' }),

      h = notebook_cell_miniai_spec,

      -- Make `|` select both edges in non-balanced way
      ['|'] = gen_spec.pair('|', '|', { type = 'non-balanced' }),
    }
})


-- Mini Hi Patterns
--

local hipatterns = require('mini.hipatterns')
hipatterns.setup({
    highlighters = {
        notebook  = {
            pattern = '^#[ |]%%%%.*',
            -- group = 'MiniHipatternsNote', 
            group = hipatterns.compute_hex_color_group('#568bbf', 'bg'),
            extmark_opts = { line_hl_group = 'MiniHipatternsNote' },
            -- extmark_opts = { line_hl_group = hipatterns.compute_hex_color_group('#568bbf', 'line') }
        },
        hex_color = hipatterns.gen_highlighter.hex_color(),
    }
})


-- Mini Notifier

require('mini.notify').setup()



-- Mini Surround 

require('mini.surround').setup({
    -- Add custom surroundings to be used on top of builtin ones. For more
    -- information with examples, see `:h MiniSurround.config`.
    custom_surroundings = nil,

    -- Module mappings. Use `''` (empty string) to disable one.
    mappings = {
        add = 'sa', -- Add surrounding in Normal and Visual modes
        delete = 'sd', -- Delete surrounding
        find = 'sf', -- Find surrounding (to the right)
        find_left = 'sF', -- Find surrounding (to the left)
        highlight = 'sh', -- Highlight surrounding
        replace = 'sr', -- Replace surrounding
        update_n_lines = 'sn', -- Update `n_lines`

        suffix_last = 'l', -- Suffix to search with "prev" method
        suffix_next = 'n', -- Suffix to search with "next" method
    },

    -- Number of lines within which surrounding is searched
    n_lines = 100,
})


-- Mini Clue 

local miniclue = require 'mini.clue'
-- Some builtin keymaps that I don't use and that I don't want mini.clue to show.
--for _, lhs in ipairs { '[%', ']%', 'g%' } do
--    vim.keymap.del('n', lhs)
--end

-- Add a-z/A-Z marks.
local function mark_clues()
    local marks = {}
    vim.list_extend(marks, vim.fn.getmarklist(vim.api.nvim_get_current_buf()))
    vim.list_extend(marks, vim.fn.getmarklist())

    return vim.iter(marks)
    :map(function(mark)
        local key = mark.mark:sub(2, 2)

        -- Just look at letter marks.
        if not string.match(key, '^%a') then
            return nil
        end

        -- For global marks, use the file as a description.
        -- For local marks, use the line number and content.
        local desc
        if mark.file then
            desc = vim.fn.fnamemodify(mark.file, ':p:~:.')
        elseif mark.pos[1] and mark.pos[1] ~= 0 then
            local line_num = mark.pos[2]
            local lines = vim.fn.getbufline(mark.pos[1], line_num)
            if lines and lines[1] then
                desc = string.format('%d: %s', line_num, lines[1]:gsub('^%s*', ''))
            end
        end

        if desc then
            return { mode = 'n', keys = string.format('`%s', key), desc = desc }
        end
    end)
    :totable()
end

-- Clues for recorded macros.
local function macro_clues()
    local res = {}
    for _, register in ipairs(vim.split('abcdefghijklmnopqrstuvwxyz', '')) do
        local keys = string.format('"%s', register)
        local ok, desc = pcall(vim.fn.getreg, register)
        if ok and desc ~= '' then
            ---@cast desc string
            desc = string.format('register: %s', desc:gsub('%s+', ' '))
            table.insert(res, { mode = 'n', keys = keys, desc = desc })
            table.insert(res, { mode = 'v', keys = keys, desc = desc })
        end
    end

    return res
end

miniclue.setup({
    triggers = {
        -- Builtins.
        { mode = 'n', keys = 'g' },
        { mode = 'x', keys = 'g' },
        { mode = 'n', keys = '`' },
        { mode = 'x', keys = '`' },
        { mode = 'n', keys = '"' },
        { mode = 'x', keys = '"' },
        { mode = 'i', keys = '<C-r>' },
        { mode = 'c', keys = '<C-r>' },
        { mode = 'n', keys = '<C-w>' },
        { mode = 'n', keys = '<C-c>' },
        { mode = 'i', keys = '<C-x>' },
        { mode = 'n', keys = 'z' },
        -- Leader triggers.
        { mode = 'n', keys = '<leader>' },
        { mode = 'x', keys = '<leader>' },
        { mode = 'n', keys = ',' },
        { mode = 'x', keys = ',' },
        -- Moving between stuff.
        { mode = 'n', keys = '[' },
        { mode = 'n', keys = ']' },
    },
    clues = {
        -- Leader/movement groups.
        { mode = 'n', keys = '[', desc = '+prev' },
        { mode = 'n', keys = ']', desc = '+next' },
        -- Builtins.
        miniclue.gen_clues.builtin_completion(),
        miniclue.gen_clues.g(),
        miniclue.gen_clues.marks(),
        miniclue.gen_clues.registers(),
        miniclue.gen_clues.windows(),
        miniclue.gen_clues.z(),
        -- Custom extras.
        mark_clues,
        macro_clues,
    },
    window = {
        delay = 500,
        scroll_down = '<C-d>',
        scroll_up = '<C-u>',
        config = function(bufnr)
            local max_width = 0
            for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
                max_width = math.max(max_width, vim.fn.strchars(line))
            end

            -- Keep some right padding.
            max_width = max_width + 2

            return {
                border = 'rounded',
                -- Dynamic width capped at 45.
                width = math.min(45, max_width),
            }
        end,
    },
})


