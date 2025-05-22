return {
    "folke/snacks.nvim",
    opts = {
        picker = {
            -- your picker configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        }
    },
    keys = {
        { "<leader>e", function() Snacks.explorer() end, desc = "File Explorer" },
        { "<leader>s", function() Snacks.picker() end, desc = "Snacks picker" },
        { "<leader>b", function() Snacks.picker.buffers() end, desc = "Buffers" },
    }
}
