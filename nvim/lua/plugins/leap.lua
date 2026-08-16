--[[
return {
    url = "https://codeberg.org/andyg/leap.nvim",
    config = function(_, opts)
        vim.keymap.set({'n', 'x', 'o'}, 's', '<Plug>(leap)')
        vim.keymap.set('n',             'S', '<Plug>(leap-from-window)')

        vim.api.nvim_create_autocmd('ColorScheme', {
            group = vim.api.nvim_create_augroup('LeapBackdrop', {}),
            callback = function()
                if vim.g.colors_name == 'this_color_scheme_needs_backdrop' then
                    require('leap.user').set_backdrop_highlight('Comment')
                end
            end
        })
    end,
}
]]-- 
return {
    url = "https://codeberg.org/andyg/leap.nvim",
    config = function(_, opts)
        -- Jump
        vim.keymap.set({ 'n', 'x', 'o' }, 's', '<Plug>(leap)')
        vim.keymap.set('n',               'S', '<Plug>(leap-from-window)')

        -- Visit (remote operations)
        vim.keymap.set({ 'n', 'o' }, 'gl', '<Plug>(leap-visit)')
        vim.keymap.set({ 'n', 'o' }, 'gL', '<Plug>(leap-visit-linewise)')
        vim.keymap.set({ 'x', 'o' }, 'ar', '<Plug>(leap-visit-text-object)')
        vim.keymap.set({ 'x', 'o' }, 'ir', '<Plug>(leap-visit-inner-text-object)')
        vim.keymap.set({ 'o' },      'rr', '<Plug>(leap-visit-line)')

        -- Auto-paste after yanking a remote region
        vim.api.nvim_create_autocmd('User', {
            pattern = 'VisitDone',
            group = vim.api.nvim_create_augroup('VisitorMode', {}),
            callback = function(event)
                if vim.v.operator == 'y' and event.data.register == '"' then
                    vim.cmd('normal! p')
                end
            end,
        })

        -- Treesitter node select (with traversal via n/N)
        vim.keymap.set({ 'x', 'o' }, 'gn', function()
            require('leap.treesitter').select {
                opts = require('leap.user').with_traversal_keys('n', 'N')
            }
        end)

        -- Backdrop dimming — apply for current colorscheme too, not just on change
        local function set_backdrop()
            require('leap.user').set_backdrop_highlight('Comment')
        end
        vim.api.nvim_create_autocmd('ColorScheme', {
            group = vim.api.nvim_create_augroup('LeapBackdrop', {}),
            callback = set_backdrop,
        })
        set_backdrop()
    end,
}
