
My_vimtex_fzf_toc = function()
    return require("vimtex.fzf-lua").run({
        fzf_opts = {
            ["--with-nth"] = "{3}\t{2}",
        }
    })
end

vim.cmd([[
" LaTeX configuration

fun SetLatexStuff()
    " autocmd Filetype tex  colorscheme base16-harmonic-dark
    set tabstop=2
    set shiftwidth=2

    " remove diagnostics
    set signcolumn=no
    lua vim.diagnostic.config({virtual_text=false})

    set spell
    syntax on

    nmap ,lc :VimtexCompile<cr>
    nmap ,lv :VimtexView<cr>
    nmap ,le :VimtexErrors<cr>

    " TOC
    nnoremap ,lt :call vimtex#fzf#run()<cr>
    "nnoremap ,lt :lua require("vimtex.fzf-lua").run()<cr>
    nnoremap <buffer> <space> :lua My_vimtex_fzf_toc()<cr>

    " convenient write
    nmap §§ :write<CR>
    nmap `` :write<CR>

    " use extended words
    " noremap  <buffer> <silent> w W
    " noremap  <buffer> <silent> b B
    " noremap  <buffer> <silent> e E
endfun

autocmd Filetype tex call SetLatexStuff()

noremap  <buffer> <silent> <Up>   gk
noremap  <buffer> <silent> <Down> gj

let g:tex_flavor = "latex"

if has('macunix')
    let g:vimtex_view_method='skim'
endif
if has('unix')
    let g:vimtex_view_method='zathura'
end

let g:vimtex_compiler_latexmk = {
	\ 'backend' : 'nvim',
        \ 'background' : 1,
        \ 'build_dir' : '',
        \ 'callback' : 1,
        \ 'continuous' : 1,
        \ 'executable' : 'latexmk',
        \ 'options' : [
        \   '-pdf',
        \   '-verbose',
        \   '-file-line-error',
        \   '-synctex=1',
        \   '-interaction=nonstopmode',
        \ ],
        \}

]])
