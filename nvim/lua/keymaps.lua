
-- Move around diagnostics
vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.jump({count=-1, float=true})<cr>', { desc = 'Prev diagnostics' })
vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.jump({count=1, float=true})<cr>', { desc = 'Next diagnostics' })
vim.keymap.set('n', ',q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })


-- Move around buffers and tabs
vim.keymap.set('n', '[b', '<cmd>:bprev<cr>',   { desc = 'Prev buffer' })
vim.keymap.set('n', ']b', '<cmd>:bnext<cr>',   { desc = 'Next buffer' })
vim.keymap.set('n', '[t', '<cmd>:tabprev<cr>', { desc = 'Prev tab' })
vim.keymap.set('n', ']t', '<cmd>:tabnext<cr>', { desc = 'Next tab' })


-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })


-- Autocmd to remap arrow keys to visual line navigation in prose files
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "tex", "markdown", "text" },
    callback = function(args)
        -- The 'buffer = args.buf' option restricts the mapping to the current file only
        local opts = { buffer = args.buf, silent = true, noremap = true }

        vim.keymap.set({ "n", "v" }, "<Down>", "gj", opts)
        vim.keymap.set({ "n", "v" }, "<Up>", "gk", opts)
    end,
})

-- Map Alt + Arrow keys to wincmd navigation
do
    local modes = { "n", "i", "v", "t" }
    local opts = { silent = true, noremap = true }

    vim.keymap.set(modes, "<M-Left>",  "<Cmd>wincmd h<CR>", opts)
    vim.keymap.set(modes, "<M-Down>",  "<Cmd>wincmd j<CR>", opts)
    vim.keymap.set(modes, "<M-Up>",    "<Cmd>wincmd k<CR>", opts)
    vim.keymap.set(modes, "<M-Right>", "<Cmd>wincmd l<CR>", opts)
    -- Fix for osx with macos-option-as-alt=true
    vim.keymap.set(modes, "<M-b>",  "<Cmd>wincmd h<CR>", opts)
    vim.keymap.set(modes, "<M-f>", "<Cmd>wincmd l<CR>", opts)
end
