-- Vim theme
-- vim.opt.termguicolors = true
--vim.cmd.colorscheme("base16-harmonic-dark")
-- From https://github.com/RRethy/base16-nvim/blob/master/colors/base16-harmonic-dark.vim
local palette = {
    base00 = '#0b1c2c',
    base01 = '#223b54',
    base02 = '#405c79',
    base03 = '#627e99',
    base04 = '#aabcce',
    base05 = '#cbd6e2',
    base06 = '#e5ebf1',
    base07 = '#f7f9fb',
    base08 = '#bf8b56',
    base09 = '#bfbf56',
    base0A = '#8bbf56',
    base0B = '#56bf8b',
    base0C = '#568bbf',
    base0D = '#8b56bf',
    base0E = '#bf568b',
    base0F = '#bf5656'
}

require('mini.base16').setup({
    palette = palette,
    use_cterm = true,
    plugins = {
        default = true,
        --['nvim-mini/mini.nvim'] = false,
        ['ggandor/leap.nvim'] = true,
        --['hrsh7th/nvim-cmp'] = false,
        ['ibhagwan/fzf-lua'] = true,
        ['nvim-lualine/lualine.nvim'] = true,
    },
})

local lualine_theme = require('lualine.themes.auto')
lualine_theme.normal.a.bg = palette.base0D

for _, mode in ipairs({ 'normal', 'insert', 'visual', 'replace', 'command', 'inactive' }) do
    if lualine_theme[mode] and lualine_theme[mode].b then
        lualine_theme[mode].b.bg = palette.base01
    end
end

require('lualine').setup({
    options = {
        icons_enabled = true,
        theme = lualine_theme,
    }
})

vim.api.nvim_set_hl(0, "MiniHipatternsCell", { bg = palette.base0C, fg = palette.base0C})
vim.api.nvim_set_hl(0, "FloatBorder", { bg = palette.base00, fg = palette.base05})
vim.api.nvim_set_hl(0, "FloatTitle", { bg = palette.base00, fg = palette.base0D})
vim.api.nvim_set_hl(0, "NormalFloat", { bg = palette.base00, fg = palette.base05})
for _, cs in ipairs({ "MiniClueNextKey", "MiniClueSeparator","MiniFilesTitle", "MiniFilesTitleFocused", "MiniFilesDirectory", "MiniClueTitle"}) do
    vim.api.nvim_set_hl(0, cs, { bg = palette.base00, fg = palette.base0C})
end
--[[vim.api.nvim_set_hl(0, "MiniClueNextKey", { bg = palette.base00, fg = palette.base0C})
vim.api.nvim_set_hl(0, "MiniClueSeparator", { bg = palette.base00, fg = palette.base0C})
vim.api.nvim_set_hl(0, "MiniFilesTitle", { bg = palette.base00, fg = palette.base0C})
vim.api.nvim_set_hl(0, "MiniFilesTitleFocused", { bg = palette.base00, fg = palette.base0C})
]]--

-- Leap 
vim.api.nvim_set_hl(0, 'LeapLabel', { fg = palette.base00, bg = palette.base08, bold = true })
vim.api.nvim_set_hl(0, 'LeapMatch', { fg = palette.base08, bold = true, underline = true })

-- color of the relative numbers
local mode_colors = {
    n = palette.base0D,
    i = palette.base0B,
    v = palette.base0C,
    V = palette.base0C,
    ["\22"] = palette.base0C,
    R = palette.base09,
    c = palette.base08,
    t = palette.base08,
}

local function set_linenr_color()
    local mode = vim.fn.mode()
    local color = mode_colors[mode] or mode_colors.n
    vim.api.nvim_set_hl(0, "LineNr", { bg = color, fg = palette.base00, bold = true })
end

vim.api.nvim_create_autocmd({ "ModeChanged", "InsertEnter", "InsertLeave" }, {
    callback = set_linenr_color,
})

-- also set once on startup

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

--local p = require('base16-colorscheme').colors
local p = palette

hi('BufferLineBuffer',              {fg=p.base04, bg=nil,      attr=nil,    sp=nil})
hi('BufferLineBufferVisible',       {fg=p.base04, bg=nil,      attr=nil,    sp=nil})
hi('BufferLineFill',                {link='Normal'})
hi('BufferLineBackground',          {fg=p.base02, bg=p.base00, attr=nil,    sp=nil})
hi('BufferLineSeparator',           {fg=p.base00, bg=p.base00, attr=nil,    sp=nil})

hi('DiffviewDiffAdd',               {bg=p.base0B})
hi('DiffviewDiffText',              {bg=p.base0C})
-- hi('DiffviewDiffChange',            {bg=p.base08})
hi('DiffviewDiffChange',            {bg="#37222c"})

