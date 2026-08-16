return {
    "quarto-dev/quarto-nvim",
    ft = { "quarto", "qmd" },
    dependencies = {
        "jmbuhr/otter.nvim",
    },
    opts = {
        lspFeatures = { enabled = false },
        codeRunner = { enabled = false },
    },
    keys = {
        { "<leader>qp", "<cmd>QuartoPreview<cr>", desc = "Quarto Preview" },
        { "<leader>qq", "<cmd>QuartoClosePreview<cr>", desc = "Quarto Close Preview" },
    },
    config = function(_, opts)
        require("quarto").setup(opts)

        vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
            pattern = "*.qmd",
            callback = function()
                vim.b.vimtex_enabled = 1
                vim.bo.filetype = "markdown"
            end,
        })
    end,
}
