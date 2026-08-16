-- Highlight, edit, and navigate code.
return {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    dependencies = {
        {
            "nvim-treesitter/nvim-treesitter-textobjects",
            branch = "main",
            init = function()
                -- Disable entire built-in ftplugin mappings to avoid conflicts.
                -- See https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.
                vim.g.no_plugin_maps = true
            end,
            config = function()
                require("nvim-treesitter-textobjects").setup({
                    move = {
                        enable = true,
                        set_jumps = true, -- Add movements to jump list (ctrl-o / ctrl-i)
                    },
                })

                local move = require("nvim-treesitter-textobjects.move")

                -- Next / Previous function mappings
                vim.keymap.set({ "n", "x", "o" }, "]f", function()
                    move.goto_next_start("@function.outer", "textobjects")
                end, { desc = "Next function start" })

                vim.keymap.set({ "n", "x", "o" }, "[f", function()
                    move.goto_previous_start("@function.outer", "textobjects")
                end, { desc = "Previous function start" })

                -- Next / Previous class mappings
                --[[
                vim.keymap.set({ "n", "x", "o" }, "]c", function()
                    move.goto_next_start("@class.outer", "textobjects")
                end, { desc = "Next class start" })

                vim.keymap.set({ "n", "x", "o" }, "[c", function()
                    move.goto_previous_start("@class.outer", "textobjects")
                end, { desc = "Previous class start" })
                ]]--
            end,
        },
    },
    build = ':TSUpdate',
    config = function(_, opts)
        require('nvim-treesitter').setup(opts)

        -- Make sure that the following are installed:
        require('nvim-treesitter').install {
            'bash',
            'c',
            'cpp',
            'fish',
            'gitcommit',
            'html',
            'json',
            'json5',
            'julia',
            'latex',
            'lua',
            'markdown',
            'markdown_inline',
            'python',
            'query',
            'regex',
            'toml',
            'vim',
            'vimdoc',
        }
    end,
}
