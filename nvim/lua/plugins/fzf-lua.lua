local icons = require 'icons'

-- Picker, finder, etc.
return {
    {
        'ibhagwan/fzf-lua',
        cmd = 'FzfLua',
        keys = {
            { ',b', '<cmd>FzfLua buffers<cr>', desc = 'Highlights' },
            { ',t', '<cmd>FzfLua lsp_document_symbols<cr>', desc = 'LSP Document Symbols' },
            { ',f<', '<cmd>FzfLua resume<cr>', desc = 'Resume last command' },
            { ',fb',
                function()
                    require('fzf-lua').lgrep_curbuf {
                        winopts = {
                            height = 0.6,
                            width = 0.8,
                            preview = { vertical = 'up:70%' },
                        },
                    }
                end,
                desc = 'Grep current buffer',
            },
            { ',fc', '<cmd>FzfLua changes<cr>', desc = 'Highlights' },
            { ',fj', '<cmd>FzfLua jumps<cr>', desc = 'Jumps' },
            { ',ff', '<cmd>FzfLua files<cr>', desc = 'Find files' },
            { ',fg', '<cmd>FzfLua live_grep_glob<cr>', desc = 'Grep' },
            { ',fG', '<cmd>FzfLua grep_visual<cr>', desc = 'Grep', mode = 'x' },
            { ',fh', '<cmd>FzfLua help_tags<cr>', desc = 'Help' },
            { ',fr',
                function()
                    -- Read from ShaDa to include files that were already deleted from the buffer list.
                    vim.cmd 'rshada!'
                    require('fzf-lua').oldfiles()
                end,
                desc = 'Recently opened files',
            },
            { 'z=', '<cmd>FzfLua spell_suggest<cr>', desc = 'Spelling suggestions' },
            { 'gD', '<cmd>FzfLua lsp_definitions<cr>', desc = 'Peek definition'},
            { 'gd',
                function()
                    require('fzf-lua').lsp_definitions { jump1 = true }
                end,
                desc = 'Go to definition'
            },
            { 'grr', '<cmd>FzfLua lsp_references<cr>', desc = 'vim.lsp.buf.references()'},
            { 'gy', '<cmd>FzfLua lsp_typedefs<cr>', desc = 'Go to type definition'},
            { ',ld', '<cmd>FzfLua lsp_document_diagnostics<cr>', desc = 'Document diagnostics' },
            --{ '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>', desc = 'Prev diagnostics' },
            --{ ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>', desc = 'Next diagnostics' },
            { ',lD', '<cmd>FzfLua lsp_workspace_diagnostics<cr>', desc = 'Workspace diagnostics' },
            -- fzf stuff 
            { '<C-x><C-f>',
                function() require("fzf-lua").complete_path() end,
                mode = { "n", "v", "i" },
                silent = true,
                desc = "Fuzzy complete path"
            },
            { '<C-x><C-l>',
                function() require("fzf-lua").complete_line() end,
                mode = { "n", "v", "i" },
                silent = true,
                desc = "Fuzzy complete path"
            },
    },
    opts = function()
        local actions = require 'fzf-lua.actions'
            return {
                -- Make stuff better combine with the editor.
                fzf_colors = {
                    bg = { 'bg', 'Normal' },
                    gutter = { 'bg', 'Normal' },
                    info = { 'fg', 'Conditional' },
                    scrollbar = { 'bg', 'Normal' },
                    separator = { 'fg', 'Comment' },
                },
                fzf_opts = {
                    ['--info'] = 'default',
                    ['--layout'] = 'reverse-list',
                },
                keymap = {
                    builtin = {
                        ['<C-/>'] = 'toggle-help',
                        ['<C-a>'] = 'toggle-fullscreen',
                        ['<C-i>'] = 'toggle-preview',
                        ['<C-f>'] = 'preview-page-down',
                        ['<C-b>'] = 'preview-page-up',
                    },
                    fzf = {
                        ['alt-s'] = 'toggle',
                        ['alt-a'] = 'toggle-all',
                    },
                },
                winopts = {
                    height = 0.7,
                    width = 0.8,
                    preview = {
                        scrollbar = false,
                        layout = 'vertical',
                        vertical = 'up:40%',
                    },
                },
                git_icons = false,
                -- Configuration for specific commands.
                files = {
                    winopts = {
                        preview = { hidden = 'hidden' },
                    },
                },
                grep = {
                    header_prefix = icons.misc.search .. ' ',
                },
                helptags = {
                    actions = {
                        -- Open help pages in a vertical split.
                        ['enter'] = actions.help_vert,
                    },
                },
                lsp = {
                    symbols = {
                        symbol_icons = icons.symbol_kinds,
                    },
                },
                oldfiles = {
                    include_current_session = true,
                    winopts = {
                        preview = { hidden = 'hidden' },
                    },
                },
            }
        end,
    },
}
