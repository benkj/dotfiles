
vim.cmd([[

set mouse=a

set termguicolors

colorscheme base16-harmonic-dark

syntax enable
syntax on 

set clipboard+=unnamedplus

" note that you must keep noinsert in completeopt, the others are optional
set completeopt=noinsert,menuone,noselect
set shortmess+=c

set tabstop=4
set shiftwidth=4
set expandtab

" Windows movements 

tnoremap <A-Left>  <C-\><C-n><C-w>h
tnoremap <A-Down>  <C-\><C-n><C-w>j
tnoremap <A-Up>    <C-\><C-n><C-w>k
tnoremap <A-Right> <C-\><C-n><C-w>l

nnoremap <A-Left>  <Esc><C-w>h
nnoremap <A-Down>  <Esc><C-w>j
nnoremap <A-Up>    <Esc><C-w>k
nnoremap <A-Right> <Esc><C-w>l

inoremap <A-Left>  <Esc><C-w>h
inoremap <A-Down>  <Esc><C-w>j
inoremap <A-Up>    <Esc><C-w>k
inoremap <A-Right> <Esc><C-w>l


]])


vim.wo.number = true
vim.wo.relativenumber = true

-- Disable horizontal scrolling.
vim.o.mousescroll = 'ver:3,hor:0'

-- Use rounded borders for floating windows.
vim.o.winborder = 'rounded'

-- color of the relative numbers
vim.api.nvim_set_hl(0, 'LineNr', { fg = "#405c79"})


-- restore previos position 
vim.api.nvim_create_autocmd({'BufWinEnter'}, {
  --group = 'userconfig',
  desc = 'return cursor to where it was last time closing the file',
  pattern = '*',
  command = 'silent! normal! g`"zv',
})


-- from https://github.com/echasnovski/mini.base16/blob/main/lua/mini/base16.lua
local hi = function(group, args)
  -- NOTE: using `string.format` instead of gradually growing string with `..`
  -- is faster. Crude estimate for this particular case: whole colorscheme
  -- loading decreased from ~3.6ms to ~3.0ms, i.e. by about 20%.
  local command
  if args.link ~= nil then
    command = string.format('highlight! link %s %s', group, args.link)
  else
    command = string.format(
      'highlight %s guifg=%s guibg=%s gui=%s guisp=%s blend=%s',
      group,
      args.fg or 'NONE',
      args.bg or 'NONE',
      args.attr or 'NONE',
      args.sp or 'NONE',
      args.blend or 'NONE'
    )
  end
  vim.cmd(command)
end

local p = require('base16-colorscheme').colors

hi('BufferLineBuffer',              {fg=p.base04, bg=nil,      attr=nil,    sp=nil})
hi('BufferLineBufferVisible',       {fg=p.base04, bg=nil,      attr=nil,    sp=nil})
hi('BufferLineFill',                {link='Normal'})
hi('BufferLineBackground',          {fg=p.base02, bg=p.base00, attr=nil,    sp=nil}) 
hi('BufferLineSeparator',           {fg=p.base00, bg=p.base00, attr=nil,    sp=nil}) 
