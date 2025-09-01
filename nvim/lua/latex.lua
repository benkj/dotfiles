
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

-- Save with C-Space, useful in vimtex to update the compiler

vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
    pattern = "*.tex",
    callback = function()
        vim.keymap.set({'n','i','v'}, '<c-Space>', function ()
            vim.api.nvim_command('write')
            vim.notify("File saved")
        end, { desc = "Write file", buffer=true })

        local git_latexdiff_pick = function() 
            local actions = require'fzf-lua'.actions
            require'fzf-lua'.git_commits({
                prompt = 'Select commits (tab/shift+tab)> ',
                winopts = {
                    preview = { hidden = true },
                },
                fzf_opts = {
                    ['--multi'] = '2', -- allow 2 selections
                },
                actions = {
                    ['enter'] = function(selected)
                        if #selected ~= 2 then
                            vim.notify("Please select two commits")
                            return
                        end

                        -- Extract the commit hashes
                        local hash1 = selected[1]:match("^%S+")
                        local hash2 = selected[2]:match("^%S+")

                        vim.cmd("new")  -- open a new buffer for logs
                        local bufnr = vim.api.nvim_get_current_buf()
                        local win = vim.api.nvim_get_current_win()

                        vim.fn.jobstart( { 'git-latexdiff',
                            '--main', vim.fn.expand("%:f"), hash2, hash1
                        }, {
                            stdout_buffered = false,
                            stderr_buffered = false,
                            on_stdout = function(_, data, _)
                                if data and #data > 0 then
                                    vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, data)
                                    local line_count = vim.api.nvim_buf_line_count(bufnr)
                                    vim.api.nvim_win_set_cursor(win, {line_count, 0})
                                end
                            end,
                            on_stderr = function(_, data, _)
                                if data and #data > 0 then
                                    vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, data)
                                    local line_count = vim.api.nvim_buf_line_count(bufnr)
                                    vim.api.nvim_win_set_cursor(win, {line_count, 0})
                                end
                            end,
                            detach = true,
                        })
                    end,
                    ['ctrl-y'] = false,
                },
            })
        end

        vim.keymap.set({'n','i','v'}, ',ld', git_latexdiff_pick, { desc = "LatexDiff", buffer=true })
    end
})
