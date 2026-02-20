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
    end,
}
