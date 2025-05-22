
-- Move around diagnostics
vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>', { desc = 'Prev diagnostics' })
vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>', { desc = 'Next diagnostics' })


-- Move around buffers
vim.keymap.set('n', '[b', '<cmd>:bprev<cr>', { desc = 'Prev buffer' })
vim.keymap.set('n', ']b', '<cmd>:bnext<cr>', { desc = 'Next buffer' })
