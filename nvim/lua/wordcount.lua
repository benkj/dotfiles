
local M = {}

local ns = vim.api.nvim_create_namespace("live_text_counter")
local tracked_mark_id = nil

local function filter_and_count(lines)
    local word_count, char_count, valid_lines = 0, 0, 0

    for _, line in ipairs(lines) do
        if not string.match(line, "^%s*[#%%]") then
            valid_lines = valid_lines + 1
            char_count = char_count + #line
            for _ in string.gmatch(line, "%S+") do
                word_count = word_count + 1
            end
        end
    end

    return { words = word_count, chars = char_count, lines = valid_lines }
end

local function update_winbar(bufnr)
    if not tracked_mark_id then return end

    local mark = vim.api.nvim_buf_get_extmark_by_id(bufnr, ns, tracked_mark_id, { details = true })
    if not mark or #mark == 0 then return end

    local start_row, start_col = mark[1], mark[2]
    local end_row, end_col = mark[3].end_row, mark[3].end_col

    local lines = vim.api.nvim_buf_get_text(bufnr, start_row, start_col, end_row, end_col, {})
    local stats = filter_and_count(lines)

    local winbar_str = string.format(
        "%%#LiveCounterBar# 📊 Selection: %d Lines | %d Words | %d Chars %%*",
        stats.lines, stats.words, stats.chars
    )

    vim.api.nvim_set_option_value("winbar", winbar_str, { win = 0 })
end

-- Toggle Function
function M.toggle_region(is_visual)
    local bufnr = vim.api.nvim_get_current_buf()

    -- 1. If it's already pinned, UNPIN IT
    if tracked_mark_id then
        vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
        tracked_mark_id = nil
        vim.api.nvim_set_option_value("winbar", "", { win = 0 })
        print("Live Counter: Unpinned")
        return
    end

    -- 2. If it's NOT pinned, check if we are trying to pin from normal mode
    if not is_visual then
        print("Live Counter: Please select text in visual mode first to pin.")
        return
    end

    -- 3. If we are in visual mode and it's not pinned, PIN IT
    local _, start_row, start_col, _ = unpack(vim.fn.getpos("'<"))
    local _, end_row, end_col, _ = unpack(vim.fn.getpos("'>"))

    -- Convert rows to 0-based indexing
    start_row = start_row - 1
    end_row = end_row - 1

    -- Convert start_col to 0-based indexing safely
    start_col = math.max(0, start_col - 1)

    -- Clamp end_col to the actual line length to prevent "out of range"
    local end_line = vim.api.nvim_buf_get_lines(bufnr, end_row, end_row + 1, false)[1] or ""
    local max_col = #end_line

    -- If end_col is v:maxcol (from Visual Line mode) or past the end, cap it
    if end_col > max_col then
        end_col = max_col
    end

    tracked_mark_id = vim.api.nvim_buf_set_extmark(bufnr, ns, start_row, start_col, {
        end_row = end_row,
        end_col = end_col,
        hl_group = "LiveCounterRegion",
        hl_eol = true,
    })

    update_winbar(bufnr)
    print("Live Counter: Pinned")
end

function M.setup()
    --local p = require('base16-colorscheme').colors
    local p = require('mini.base16').config.palette
    vim.api.nvim_set_hl(0, "LiveCounterRegion", { bg = p.base01, default = true })
    vim.api.nvim_set_hl(0, "LiveCounterBar", { fg = p.base06, bg = p.base0C, bold = true, default = true })

    local group = vim.api.nvim_create_augroup("LiveTextCounter", { clear = true })

    vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
        group = group,
        callback = function(args)
            if tracked_mark_id then
                update_winbar(args.buf)
            end
        end,
    })

    -- Normal mode toggle
    vim.keymap.set("n", ",wc", function()
        M.toggle_region(false)
    end, { desc = "Toggle Live Count" })

    -- Visual mode toggle
    vim.keymap.set("v", ",wc", function()
        -- Escape to normal mode first so Neovim registers the '< and '> marks
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false)
        -- Defer slightly to ensure marks are updated before evaluating
        vim.defer_fn(function() M.toggle_region(true) end, 10)
    end, { desc = "Toggle Live Count" })
end

M.setup()

return M

--[[
local M = {}

-- Global variables to track window state
local word_count_win = nil
local word_count_buf = nil
-- local word_count_ns = vim.api.nvim_create_namespace('word_count')
local autocmd_id = nil
local last_selection = {}

-- Function to count words, characters, and lines
local function count_text(text)
    if not text or text == "" then
        return { words = 0, chars = 0, lines = 0 }
    end

    local words = 0
    local chars = vim.fn.strchars(text)
    local lines = vim.fn.split(text, '\n')

    -- Count words (split by whitespace)
    for _ in text:gmatch("%S+") do
        words = words + 1
    end

    return {
        words = words,
        chars = chars,
        lines = #lines
    }
end

-- Function to get current visual selection
local function get_visual_selection()
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")

    if start_pos[2] == 0 or end_pos[2] == 0 then
        return nil
    end

    local start_row, start_col = start_pos[2] - 1, start_pos[3] - 1
    local end_row, end_col = end_pos[2] - 1, end_pos[3]

    local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row + 1, false)

    if #lines == 0 then
        return nil
    end

    -- Handle single line selection
    if #lines == 1 then
        lines[1] = string.sub(lines[1], start_col + 1, end_col)
    else
        -- Handle multi-line selection
        lines[1] = string.sub(lines[1], start_col + 1)
        lines[#lines] = string.sub(lines[#lines], 1, end_col)
    end

    return table.concat(lines, '\n')
end

-- Function to update the word count display
local function update_word_count()
    if not word_count_win or not vim.api.nvim_win_is_valid(word_count_win) then
        return
    end

    local selection = get_visual_selection()
    if not selection then
        return
    end

    -- Only update if selection changed
    local selection_key = vim.fn.sha256(selection)
    if last_selection.key == selection_key then
        return
    end
    last_selection.key = selection_key

    local counts = count_text(selection)

    local content = {
        string.format("Words: %6d", counts.words),
        string.format("Chars: %6d", counts.chars),
        string.format("Lines: %6d", counts.lines),
    }

    if word_count_buf then
        vim.api.nvim_buf_set_lines(word_count_buf, 0, -1, false, content)
    end
end

-- Function to create the floating window
local function create_word_count_window()
    if word_count_win and vim.api.nvim_win_is_valid(word_count_win) then
        vim.api.nvim_win_close(word_count_win, true)
    end

    -- Create buffer if it doesn't exist
    if not word_count_buf or not vim.api.nvim_buf_is_valid(word_count_buf) then
        word_count_buf = vim.api.nvim_create_buf(false, true)
        --vim.api.nvim_buf_set_option(word_count_buf, 'bufhidden', 'wipe')
        --vim.api.nvim_buf_set_option(word_count_buf, 'filetype', 'wordcount')
        vim.api.nvim_set_option_value('bufhidden', 'wipe', {buf=word_count_buf})
        vim.api.nvim_set_option_value('filetype', 'wordcount', {buf=word_count_buf})
    end

    -- Window configuration
    local width = 14
    local height = 3
    local win_config = {
        relative = 'editor',
        width = width,
        height = height,
        col = vim.o.columns - width - 2,
        row = 2,
        style = 'minimal',
        border = 'rounded',
        focusable = false,
        zindex = 100
    }

    word_count_win = vim.api.nvim_open_win(word_count_buf, false, win_config)

    -- Set window options
    --  vim.api.nvim_win_set_option(word_count_win, 'winhl', 'Normal:NormalFloat,FloatBorder:FloatBorder')

    -- Initial update
    update_word_count()
end

-- Function to set up autocommands for real-time updates
local function setup_autocmds()
    if autocmd_id then
        vim.api.nvim_del_autocmd(autocmd_id)
    end

    autocmd_id = vim.api.nvim_create_autocmd({
        'TextChanged', 'TextChangedI', 'CursorMoved', 'CursorMovedI'
    }, {
        callback = function()
            if word_count_win and vim.api.nvim_win_is_valid(word_count_win) then
                update_word_count()
            end
        end,
        desc = 'Update word count window'
    })
end

-- Function to close the word count window
local function close_word_count_window()
    if word_count_win and vim.api.nvim_win_is_valid(word_count_win) then
        vim.api.nvim_win_close(word_count_win, true)
        word_count_win = nil
    end

    if autocmd_id then
        vim.api.nvim_del_autocmd(autocmd_id)
        autocmd_id = nil
    end

    last_selection = {}
end

-- Main function to toggle word count window
function M.toggle_word_count()
    if word_count_win and vim.api.nvim_win_is_valid(word_count_win) then
        close_word_count_window()
        print("Word count window closed")
    else
        -- Check if there's a visual selection
        local selection = get_visual_selection()
        if not selection then
            print("No text selected. Please make a visual selection first.")
            return
        end

        create_word_count_window()
        setup_autocmds()
        print("Word count window opened")
    end
end

-- Function to show word count window (always open)
function M.show_word_count()
    local selection = get_visual_selection()
    if not selection then
        print("No text selected. Please make a visual selection first.")
        return
    end

    create_word_count_window()
    setup_autocmds()
    print("Word count window opened")
end

-- Function to hide word count window
function M.hide_word_count()
    close_word_count_window()
    print("Word count window closed")
end

-- Create user commands
vim.api.nvim_create_user_command('WordCountToggle', M.toggle_word_count, {
    desc = 'Toggle persistent word count window for selection'
})

vim.api.nvim_create_user_command('WordCountShow', M.show_word_count, {
    desc = 'Show persistent word count window for selection'
})

vim.api.nvim_create_user_command('WordCountHide', M.hide_word_count, {
    desc = 'Hide word count window'
})

-- Set up keymaps
vim.keymap.set('v', ',wc', function()
    -- Exit visual mode first to ensure the selection marks are set
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
    -- Small delay to ensure marks are set
    vim.defer_fn(M.toggle_word_count, 10)
end, { desc = 'Toggle word count window' })
vim.keymap.set('n', ',wc', M.toggle_word_count, { desc = 'Toggle word count window' })

return M
]]--
