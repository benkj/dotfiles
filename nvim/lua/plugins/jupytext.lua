return {
    'goerz/jupytext.nvim',
    -- "GCBallesteros/jupytext.nvim", -- Alternative
    -- config = true,
    -- version = '0.2.0',
    opts = {
        jupytext = 'jupytext',
        format = "auto:hydrogen",
        update = true,
        --filetype = require("jupytext").get_filetype,
        --new_template = require("jupytext").default_new_template(),
        sync_patterns = { '*.md', '*.py', '*.jl', '*.R', '*.Rmd', '*.qmd' },
        autosync = true,
        handle_url_schemes = true,
    },
}
