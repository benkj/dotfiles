

require('nvim-treesitter.parsers').get_parser_configs().asm = {
    ignore_install = { "latex" },
    highlight = {
         enable = true,
         disable = { "latex" },
       },
}
 

require'nvim-treesitter.configs'.setup {
    ensure_installed = { "c", "lua", "vim", "vimdoc", "query", 
    "markdown", "markdown_inline", "python", "julia" },

    ignore_install = { "latex" },

    highlight = {
        enable = true,
        disable = { "latex", "julia", "python" },
    },
}

