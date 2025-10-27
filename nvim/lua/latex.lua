
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
    " nnoremap ,lt :call vimtex#fzf#run()<cr>
    "nnoremap ,lt :lua require("vimtex.fzf-lua").run()<cr>
    nnoremap ,lt :VimtexTocOpen<cr>
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

        -- Save file with C-Space
        vim.keymap.set({'n','i','v'}, '<c-Space>', function ()
            vim.api.nvim_command('write')
            vim.notify("File saved")
        end, { desc = "Write file", buffer=true })

        -- Convenient git-latexdiff wrapper
        local git_latexdiff_pick = function() 
            local actions = require'fzf-lua'.actions
            local file = vim.fn.expand("%:f")
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

                        vim.notify(vim.inspect({ 'git-latexdiff',
                            '--main', file, hash2, hash1
                        }))

                        vim.fn.jobstart( { 'git-latexdiff', '--main', file, hash2, hash1 }, {
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
                        return nil
                    end,
                    ['ctrl-y'] = false,
                },
            })
        end

        local function run_latexdiff_vc(file, rev1, rev2)
            if rev1 == nil then
                return nil
            end
            local cmd = "latexdiff-vc --git --force -r " .. rev1
            if rev2 ~= nil then
                cmd = cmd .. " -r "  .. rev2
            end
            cmd = cmd .. " " .. file

            local handle = io.popen(cmd .. " 2>&1")
            if not handle then
                vim.notify("Failed to execute latexdiff-vc", vim.log.levels.ERROR)
                return nil
            end

            local output = handle:read("*a")
            local success = handle:close()

            if not success then
                vim.notify("latexdiff-vc failed:\n" .. output, vim.log.levels.ERROR)
                return nil
            end

            local diff_file = output:match("Generated difference file%s+(.-)%s*\n")

            if diff_file then
                vim.notify("Generated: " .. diff_file, vim.log.levels.INFO)
                return diff_file
            else
                vim.notify("Could not parse generated filename from output", vim.log.levels.WARN)
                return nil
            end
        end

        local latexdiff_vc_pick = function()
            local actions = require'fzf-lua'.actions
            local file = vim.fn.expand("%:f")
            require'fzf-lua'.git_commits({
                prompt = 'Select commits (tab/shift+tab)> ',
                winopts = {
                    preview = { hidden = true },
                },
                fzf_opts = {
                    -- ['--multi'] = '2', -- allow 2 selections
                },
                fzf_args = "--multi=2",
                actions = {
                    ['enter'] = function(selected)
                        local hash1 = selected[1]:match("^%S+")
                        local hash2 = nil
                        if #selected == 2 then
                            hash2 = selected[2]:match("^%S+")
                        end
                        local diff_file = run_latexdiff_vc(file, hash1, hash2)

                        vim.cmd("tabnew")
                        vim.cmd("e " .. diff_file)

                        return nil
                    end,
                    ['ctrl-y'] = false,
                },
            })
        end


        vim.keymap.set({'n','i','v'}, ',lD', git_latexdiff_pick, { desc = "LatexDiff", buffer=true })
        vim.keymap.set({'n','i','v'}, ',ld', latexdiff_vc_pick, { desc = "LatexDiff", buffer=true })

        -- Add vimtex motions 
        local miniclue = require('mini.clue')
        local vimtex_motions = {
            { "]]", desc = "Next end of a section" },
            { "][", desc = "Next beginning of a section" },
            { "[]", desc = "Previous end of a section" },
            { "[[", desc = "Previous beginning of a section" },
            { "]m", desc = "Next start of an environment `\\begin`" },
            { "]M", desc = "Next end of an environment `\\end`" },
            { "[m", desc = "Previous start of an environment `\\begin`" },
            { "[M", desc = "Previous end of an environment `\\end`" },
            { "]n", desc = "Next start of a math zone" },
            { "]N", desc = "Next end of a math zone" },
            { "[n", desc = "Previous start of a math zone" },
            { "[N", desc = "Previous end of a math zone" },
            { "]r", desc = "Next start of a frame environment" },
            { "]R", desc = "Next end of a frame environment" },
            { "[r", desc = "Previous start of a frame environment" },
            { "[R", desc = "Previous end of a frame environment" },
            { "]/", desc = "Next start of a LaTeX comment" },
            { "]*", desc = "Next end of a LaTeX comment" },
            { "[/", desc = "Previous start of a LaTeX comment" },
            { "[*", desc = "Previous end of a LaTeX comment" },
        }
        for _, vm in ipairs(vimtex_motions) do
            miniclue.set_mapping_desc("nxo", vm[1], vm.desc)
        end
    end
})
