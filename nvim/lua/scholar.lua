

FzfScholarly = function(tab)
    local index = 1
    local stuff = {}
    require'fzf-lua'.fzf_exec( function(fzf_cb)
        vim.tbl_map(function(x)
            if x["title"] ~= nil then
                fzf_cb(index .. "####" .. x["title"])
                --fzf_cb(x["title"])
                stuff[index] = x
                index = index + 1
                --stuff[x["title"]] = x
            end
        end, tab)
    end, {
        fzf_opts = {
            ['--delimiter'] = '####',
            ['--with-nth'] = '{2..}',
            ['--preview-window'] = 'nohidden,up,50%',
            ['--preview'] = function(items)
                local contents = {}
                vim.tbl_map(function(str)
                    local x = tonumber(vim.split(str,"####")[1])
                    table.insert(contents, "scholar: " .. vim.inspect(stuff[x]))
                end, items)
                return contents
            end
        },
    }) 
end

vim.keymap.set('n', ',gs', FzfScholarly, {desc = "serch google scholar"})
