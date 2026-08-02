return {
    url = "https://codeberg.org/andyg/leap.nvim",
    --[[  keys = {
        { "zs", mode = { "n", "x", "o" }, desc = "Leap Forward to" },
        { "zS", mode = { "n", "x", "o" }, desc = "Leap Backward to" },
        { "gs", mode = { "n", "x", "o" }, desc = "Leap from Windows" },
    }, ]]--
    config = function(_, opts)
        vim.keymap.set({'n', 'x', 'o'}, 's', '<Plug>(leap)')
        vim.keymap.set('n',             'S', '<Plug>(leap-from-window)')

        vim.api.nvim_create_autocmd('ColorScheme', {
            group = vim.api.nvim_create_augroup('LeapBackdrop', {}),
            callback = function()
                if vim.g.colors_name == 'this_color_scheme_needs_backdrop' then
                    require('leap.user').set_backdrop_highlight('Comment')
                end
            end
        })
    end,
}
