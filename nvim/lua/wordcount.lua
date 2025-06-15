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

