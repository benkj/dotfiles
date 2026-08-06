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
                -- put your config here
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
