return {
    'kokusenz/deltaview.nvim',
    cmd = { 'DeltaView', 'DeltaMenu', 'Delta' },
    keys = {
        { ",Dv", "<cmd>DeltaView<cr>", desc = "diff view on current buffer" },
        { ",Dm", "<cmd>DeltaMenu<cr>", desc = "pick edited files for diff view" },
    },
    opts = {
        use_nerdfonts = true, -- you're already using Nerd Font glyphs elsewhere in your config
        line_numbers = false,
        fzf_picker = 'fzf-lua',
        keyconfig = {
            -- navigate between hunks in a diff
            next_hunk = '<Tab>',
            prev_hunk = '<S-Tab>',
            -- open help legend
            help_legend = 'd?',
        },
    },
}
