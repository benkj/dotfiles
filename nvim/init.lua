vim.cmd([[
let g:python_support_python2_require = 0
let g:python3_host_prog = "/home/benkj/.venvs/nvim/bin/python3"
" let g:jukit_mappings_ext_enabled = ["py", "jl", "ipynb"]
]])


local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup(
{
    -- General
    'lervag/vimtex',
    'SirVer/ultisnips',
    'honza/vim-snippets',
    -- 'kylechui/nvim-surround',
    -- 'akinsho/bufferline.nvim',
    -- 'ludovicchabant/vim-gutentags',
    'kyazdani42/nvim-web-devicons',
    'JuliaEditorSupport/julia-vim',
    'nvim-lualine/lualine.nvim',
    { 'echasnovski/mini.nvim', version = '*' },
    'nvim-tree/nvim-web-devicons',
    { "junegunn/fzf", build = "./install --all" },
    "junegunn/fzf.vim",
    --  LSP and treesitter
    {"nvim-treesitter/nvim-treesitter", build = ":TSUpdate"},
    {"nvim-treesitter/nvim-treesitter-textobjects"},
    'neovim/nvim-lspconfig',
    'onsails/lspkind.nvim',
    'ray-x/lsp_signature.nvim',
    -- 'stevearc/aerial.nvim',
    -- CMP
    'hrsh7th/nvim-cmp',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-nvim-lsp-signature-help',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-cmdline',
    -- 'kdheepak/cmp-latex-symbols',
    'quangnguyen30192/cmp-nvim-ultisnips',
    'micangl/cmp-vimtex',
    'f3fora/cmp-spell',
    'RRethy/base16-nvim',
    "rebelot/kanagawa.nvim",
    --    {'luk400/vim-jukit', lazy=false},
    {import = "plugins"}
})

require("defaults")
require("lsp_cmp")
require("ts")
require("statusline")
--require("jukit")
require("mini")
require("keymaps")
require("latex")
require("scholar")
require("wordcount")


