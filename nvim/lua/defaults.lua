-- Enable mouse support in all modes
vim.opt.mouse = "a"

-- Enable syntax highlighting 
-- vim.cmd.syntax("enable")
-- vim.cmd.syntax("on")

-- Use the system clipboard
vim.opt.clipboard:append("unnamedplus")

-- note that you must keep noinsert in completeopt, the others are optional
vim.opt.completeopt = { "noinsert", "menuone", "noselect" }
vim.opt.shortmess:append("c")

-- Indentation settings
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- Wrap long lines at words.
vim.o.linebreak = true

-- C-indenting options
vim.opt.cinoptions = "g0,l1,t0"

vim.wo.number = true
vim.wo.relativenumber = true

-- Disable horizontal scrolling.
vim.o.mousescroll = 'ver:3,hor:0'

-- Use rounded borders for floating windows.
vim.o.winborder = 'rounded'

-- restore previos position 
vim.api.nvim_create_autocmd({'BufWinEnter'}, {
  --group = 'userconfig',
  desc = 'return cursor to where it was last time closing the file',
  pattern = '*',
  command = 'silent! normal! g`"zv',
})

vim.opt.diffopt:append('inline:word')

-- DiffOrig command 
vim.api.nvim_create_user_command('DiffOrig', function()
    local scratch_buffer = vim.api.nvim_create_buf(false, true)
    local current_ft = vim.bo.filetype
    vim.cmd('vertical sbuffer' .. scratch_buffer)
    vim.bo[scratch_buffer].filetype = current_ft
    vim.cmd('read ++edit #') -- load contents of previous buffer into scratch_buffer
    vim.cmd.normal('1G"_d_') -- delete extra newline at top of scratch_buffer without overriding register
    vim.cmd.diffthis() -- scratch_buffer
    vim.cmd.wincmd('p')
    vim.cmd.diffthis() -- current buffer
end, {})

vim.keymap.set('n', ',d', '<cmd>:DiffOrig<cr>', { desc = 'Difference from saved file' })

