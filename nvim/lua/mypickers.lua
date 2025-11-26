-- Set spelling 
vim.keymap.set('n', ',s', function()
  require('fzf-lua').fzf_exec({ 'it', 'en' }, {
    prompt = 'Select language> ',
    actions = {
      ['default'] = function(selected)
        if selected and selected[1] then
          vim.opt.spelllang = selected[1]
          vim.opt.spell = true
        end
      end,
    },
    winopts = {
        height = 0.15,
        width  = 0.20,
        row    = 0.9,
        col    = 0.1,
    },
})
end, { desc = 'Select auditory communication for spelling' })


-- Get synonyms
local function get_synonyms_wordnet(word)
    local handle = io.popen(string.format("wn '%s' -synsn -synsv -synsa -synsr 2>/dev/null", word))
    if not handle then
        return {}
    end

    local output = handle:read("*a")
    handle:close()

    if output == "" then
        return {}
    end

    local synonyms = {}
    local seen = {}

    for line in output:gmatch("[^\r\n]+") do
        if line:match("=>") then
            local syn_part = line:match("=>%s*(.+)")
            if syn_part then
                for syn in syn_part:gmatch("([^,]+)") do
                    syn = syn:gsub("%s*%-%-.*", "")
                    syn = syn:gsub("%s*%b()", "")
                    syn = syn:gsub("^%s*", "")
                    syn = syn:gsub("%s*$", "")
                    syn = syn:gsub("%s+", " ")

                    if syn ~= "" and syn ~= word and not seen[syn] then
                        table.insert(synonyms, syn)
                        seen[syn] = true
                    end
                end
            end
        end
    end

    return synonyms
end

local function show_synonyms_fzf()
    local word = vim.fn.expand("<cword>")

    if word == "" then
        vim.notify("No word under cursor", vim.log.levels.WARN)
        return
    end

    local synonyms = get_synonyms_wordnet(word)

    if #synonyms == 0 then
        vim.notify("No synonyms found for: " .. word, vim.log.levels.INFO)
        return
    end

    require('fzf-lua').fzf_exec(synonyms, {
        prompt = string.format('Synonyms for "%s"> ', word),
        fzf_opts = {
            ['--preview'] = string.format("wn {} -over 2>/dev/null || echo 'No definition found for: {}'"),
            ['--preview-window'] = 'up:50%:wrap',
            ['--header'] = 'Enter: replace | Ctrl-Y: yank',
        },
        actions = {
            ['default'] = function(selected)
                if selected and selected[1] then
                    vim.cmd(string.format('normal! ciw%s', selected[1]))
                end
            end,
            ['ctrl-y'] = function(selected)
                if selected and selected[1] then
                    vim.fn.setreg('+', selected[1])
                    vim.notify('Copied: ' .. selected[1], vim.log.levels.INFO)
                end
            end,
        },
    })
end

vim.keymap.set('n', ',ws', show_synonyms_fzf, { desc = 'Show synonyms (WordNet)' })
