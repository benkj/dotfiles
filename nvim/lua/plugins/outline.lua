return {
    "hedyhli/outline.nvim",
    lazy = true,
    cmd = { "Outline", "OutlineOpen" },
    keys = { -- Example mapping to toggle outline
        { ",o", "<cmd>Outline<CR>", desc = "Toggle outline" },
    },
    opts = {
        -- Your setup opts here
        outline_window = {
            position = 'left',
            width = 20,
        },
    },
}
