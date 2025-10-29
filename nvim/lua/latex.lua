vim.g.tex_flavor = "latex"

if vim.fn.has('macunix') == 1 then
    vim.g.vimtex_view_method = 'skim'
else
    vim.g.vimtex_view_method = 'zathura'
end

vim.g.vimtex_compiler_latexmk = {
    backend = 'nvim',
    background = 1,
    build_dir = '',
    callback = 1,
    continuous = 1,
    executable = 'latexmk',
    options = {
        '-pdf',
        '-verbose',
        '-file-line-error',
        '-synctex=1',
        '-interaction=nonstopmode',
    },
}

vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
    pattern = "*.tex",
    callback = function()
        -- Spell
        vim.opt.spell = true
        vim.cmd('syntax on')

        -- Remove diagnotics 
        vim.wo.signcolumn = "no"
        vim.diagnostic.config({virtual_text=false})

        -- Reduce tabs
        vim.bo.tabstop = 2
        vim.bo.shiftwidth = 2

        -- Default keymaps
        vim.keymap.set('n', ',lc', '<cmd>VimtexCompile<cr>', 	{ desc = 'Vimtex Compile' })
        vim.keymap.set('n', ',lx', '<cmd>VimtexClean<cr>', 	    { desc = 'Vimtex Clean' })
        vim.keymap.set('n', ',lv', '<cmd>VimtexView<cr>', 	    { desc = 'Vimtex View' })
        vim.keymap.set('n', ',le', '<cmd>VimtexErrors<cr>', 	{ desc = 'Vimtex Errors' })
        vim.keymap.set('n', ',lt', '<cmd>VimtexTocOpen<cr>', 	{ desc = 'Vimtex Toc Open' })

        -- Convenient to work on multiple lines
        vim.keymap.set('n', '<Up>',   'gk', { buffer = true, silent = true })
        vim.keymap.set('n', '<Down>', 'gj', { buffer = true, silent = true })

        -- Save file with C-Space
        vim.keymap.set({'n','i','v'}, '<c-Space>', function ()
            vim.api.nvim_command('write')
            vim.notify("File saved")
        end, { desc = "Write file", buffer=true })

        vim.keymap.set('n', '§§', ':write<CR>')
        vim.keymap.set('n', '``', ':write<CR>')

        -- Toc
        vim.keymap.set('n', '<Space>', function ()
            return require("vimtex.fzf-lua").run({
                fzf_opts = {
                    ["--with-nth"] = "{3}\t{2}",
                }
            })
        end, { desc = "Vimtex Toc", buffer=true })


        -- Bibtex Floating window
        local function open_bibtex_float()
            local bibfiles = vim.fn['vimtex#bib#files']()

            if not bibfiles or #bibfiles == 0 then
                vim.notify("No BibTeX file found", vim.log.levels.WARN)
                return
            end

            local bibfile = bibfiles[1]

            -- Create a proper file buffer
            local buf = vim.fn.bufadd(bibfile)
            vim.fn.bufload(buf)
            vim.bo[buf].filetype = 'bib'
            vim.bo[buf].tabstop = 2
            vim.bo[buf].shiftwidth = 2

            -- Calculate window size
            local width = math.floor(vim.o.columns * 0.8)
            local height = math.floor(vim.o.lines * 0.8)

            -- Open floating window
            local win = vim.api.nvim_open_win(buf, true, {
                relative = 'editor',
                width = width,
                height = height,
                row = math.floor((vim.o.lines - height) / 2),
                col = math.floor((vim.o.columns - width) / 2),
                style = 'minimal',
                border = 'rounded',
                title = ' ' .. vim.fn.fnamemodify(bibfile, ':t') .. ' ',
                title_pos = 'center',
            })
            vim.wo[win].signcolumn = "no"

            pcall(function()
                vim.treesitter.start(buf, 'bibtex')
            end)

            -- Keymaps 
            vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = buf, silent = true })
            vim.keymap.set('n', 'w', '<cmd>write<CR>', { buffer = buf, silent = true })
            vim.keymap.set('n', '<C-Space>', '<cmd>write<CR>', { buffer = buf, silent = true })

        end

        vim.keymap.set('n', ',lb', open_bibtex_float, { buffer = true, desc = 'Open BibTeX in float' })

        -- Latex Diff
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
            local file = vim.fn.expand("%:f")
            require'fzf-lua'.git_commits({
                prompt = 'Select commits (tab/shift+tab)> ',
                winopts = {
                    preview = { hidden = true },
                },
                -- fzf_opts = { ['--multi'] = '2', },
                fzf_args = "--multi=2",
                actions = {
                    ['enter'] = function(selected)
                        local hash1 = selected[1]:match("^%S+")
                        local hash2 = nil
                        if #selected == 2 then
                            hash2 = selected[2]:match("^%S+")
                        end
                        local diff_file = run_latexdiff_vc(file, hash1, hash2)

                        if diff_file ~= nil then
                            vim.cmd("tabnew")
                            vim.cmd("e " .. diff_file)
                            vim.cmd("VimtexCompileSS")

                            vim.api.nvim_create_autocmd("User", {
                                pattern = "VimtexEventCompileSuccess",
                                once = true,
                                callback = function()
                                    vim.cmd("windo bd")
                                end
                            })
                        end
                    end,
                    ['ctrl-y'] = false,
                },
            })
        end

        vim.keymap.set({'n','i','v'}, ',ld', latexdiff_vc_pick, { desc = "LatexDiff", buffer=true })

        -- Add vimtex motions 
        -- Adapted from https://github.com/lervag/vimtex/wiki/which%E2%80%90key.nvim-support
        local miniclue = require('mini.clue')
        local vimtex_clues = {
            -- Motions
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
            -- Delete surrounding
            { 'dse', desc = 'environment' },
            { 'dsc', desc = 'command' },
            { 'ds$', desc = 'math' },
            { 'dsd', desc = 'delimiter' },
            -- Change surrounding
            { 'cse', desc = 'environment' },
            { 'csc', desc = 'command' },
            { 'cs$', desc = 'math environment' },
            { 'csd', desc = 'delimiter' },
            -- Toggle surrounding
            { 'tsc', desc = 'command' },
            { 'tss', desc = 'star' },
            { 'tse', desc = 'environment' },
            { 'ts$', desc = 'math environment' },
            { 'tsd', desc = 'delimiter' },
            { 'tsD', desc = 'reverse delimiter' },
            { 'tsf', desc = 'fraction' },
            { 'tsb', desc = 'break' },
        }
        vim.list_extend(miniclue.config.triggers, {
            { mode = 'n', keys = 'ds' },
            { mode = 'n', keys = 'cs' },
            { mode = 'n', keys = 'ts' },
        })
        for _, vm in ipairs(vimtex_clues) do
            miniclue.set_mapping_desc("nx", vm[1], vm.desc)
        end
    end
})
