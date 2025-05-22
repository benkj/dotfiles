return {
    'Vigemus/iron.nvim',
    event = "VeryLazy",
    config = function()
        local iron = require("iron.core")
        local view = require("iron.view")
        -- local common = require("iron.fts.common")

        local function julia_format(lines)
            if #lines == 1 then
                return {lines[1] .. '\13'}
            else
                local file = vim.fn.fnamemodify(vim.fn.resolve(vim.fn.expand('%:p')), ':h')  .. "/.jukit_run"
                vim.fn.writefile(lines, file)
                return 'include("' .. file .. '") \n'
            end
        end

        local function python_format(lines)
            if #lines == 1 then
                return {lines[1] .. '\13'}
            else
                local file = vim.fn.fnamemodify(vim.fn.resolve(vim.fn.expand('%:p')), ':h')  .. "/.jukit_run.py"
                vim.fn.writefile(lines, file)
                return '%load ' .. file .. '\n\13'
            end
        end

        local cell_marker = '#[| ]%%'
        local nc = require("notebook-cells")

        iron.setup {
            config = {
                scratch_repl = false,  -- Whether a repl should be discarded or not
                -- close_window_on_exit = true, -- Automatically closes the repl window on process end
                scope = require("iron.scope").singleton, -- only 1 repl per file type
                repl_definition = {
                    python = {
                        command = { "ipython3" },
                        --format = common.bracketed_paste_python,
                        format = python_format,
                        block_dividers = { "# %%", "#%%", "#|%%--%%|", "# |%%--%%|"},
                    },
                    julia = {
                        command = { "julia", "-t", "16" },
                        format = julia_format,
                        block_dividers = { "# %%", "#%%", "#|%%--%%|", "# |%%--%%|"},
                    }
                },
                repl_open_cmd = {
                    view.split.horizontal.botright(10),
                    view.split.vertical.botright(50)
                },
            },
            keymaps = {
                toggle_repl = ",rr", -- toggles the repl open and closed.
                toggle_repl_with_cmd_1 = ",rv",
                toggle_repl_with_cmd_2 = ",rh",
                restart_repl = ",rR", -- calls `IronRestart` to restart the repl
                send_motion = "<c-c><c-m>",
                visual_send = "<space>",
                send_file = "<c-c><c-s>",
                -- send_line = "<cr>",
                -- send_paragraph = "<leader>sp",
                -- send_until_cursor = "<leader>su",
                -- send_mark = "<leader>sm",
                send_code_block = "<c-c><space>",
                send_code_block_and_move = "<c-space>",
                --mark_motion = ",im",
                --mark_visual = ",im",
                --remove_mark = ",iM",
                cr = "<c-c><c-n>",
                interrupt = "<c-c><c-c>",
                exit = ",rq",
                clear = ",rc",
            },
            highlight = {
                italic = true
            },
            ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
        }

        vim.keymap.set({'n','v'}, '[h', function() nc.move_cell("u",cell_marker) end, {desc = "Move to upper cell"})
        vim.keymap.set({'n','v'}, ']h', function() nc.move_cell("d",cell_marker) end, {desc = "Move to lower cell"})
        vim.keymap.set({'n','i','v'}, '<c-c><c-f>', '<cmd>IronFocus<cr>', { desc = "Iron focus"} )
        vim.keymap.set({'n','i','v'}, '<c-c><c-h>', '<cmd>IronHide<cr>',  { desc = "Iron hide"} )
        vim.keymap.set('n', '<c-up>', "[h[hjzz",  { desc = "previous cell", remap=true} )
        vim.keymap.set('n', '<c-down>', "]hjzz",  { desc = "next cell", remap=true} )
        vim.keymap.set('i', '<c-c><c-a>', '<c-o>0# %%<cr><c-w>',  { desc = "Add cell"} )
        vim.keymap.set('n', '<c-c><c-a>', '<esc>i# %%<esc>',  { desc = "Add cell"} )
        vim.keymap.set('n', '<c-c><c-d>', 'vahx',  { desc = "Delete cell", remap=true} )
        vim.keymap.set('n', '<c-c><c-up>', function() nc.myswap_cell("u",cell_marker) end, {desc = "Move cell up"})
        vim.keymap.set('n', '<c-c><c-down>', function() nc.myswap_cell("d",cell_marker) end, {desc = "Move cell down"})
        --vim.keymap.set('n', '<c-c><c-up>', 'vah"hx[h"hP',  { desc = "Move cell up", remap=true, buffer=true} )
        --vim.keymap.set('n', '<c-c><c-down>', 'vah"hx]h"hP',  { desc = "Move cell down", remap=true, buffer=true} )
        vim.keymap.set('i', ';;', '<c-o>:lua require("iron.core").send_line()<cr>', {desc="Send line"})
        vim.keymap.set('n', '<space>', ':lua require("iron.core").send_line()<cr>j', {desc="Send line"})
        vim.keymap.set('i', '<c-c><space>', '<c-o>:lua require("iron.core").send_code_block()<cr>', {desc="Send code block"})
    end,
}
