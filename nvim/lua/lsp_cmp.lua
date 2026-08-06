
--[[
vim.lsp.config.julials.setup{
    on_new_config = function(new_config, _)
        local julia = vim.fn.expand("~/.julia/environments/nvim-lspconfig/bin/julia")
        if vim.lsp.config.util.path.is_file(julia) then
            vim.notify("Julia LS Running!")
            new_config.cmd[1] = julia
        end
    end
}
]]

local cmp = require'cmp'

require("luasnip").config.setup {
    enable_autosnippets = true,
    update_events = { "TextChanged", "TextChangedI" },
    snipmate_snippet_parser = {
        override_priority = 1,
    },
    parser_nested_assembler = nil,
    store_selection_keys = "<Tab>",
}

require("luasnip.loaders.from_snipmate").lazy_load({
    paths = {
        "~/.config/nvim/snippets/snipmate/",
    }
})

require("luasnip.loaders.from_lua").lazy_load({
    paths = {
        "~/.config/nvim/snippets/luasnip/",
    }
})

require("luasnip.loaders.from_vscode").lazy_load({
    exclude_filetypes = { "tex", "latex", "plaintex" }
})


local luasnip = require('luasnip')
local lspkind = require('lspkind')

cmp.setup({
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    formatting = {
        format = lspkind.cmp_format({
            mode = 'symbol', 
            maxwidth = 50, 
            ellipsis_char = '...',
        })
    },
    sources = cmp.config.sources({
        { name = 'vimtex', },
        { name = 'nvim_lsp' },
        { name = 'nvim_lsp_signature_help' },
        -- { name = 'latex_symbols' },
        { name = 'luasnip' },
        { name = 'buffer' },
    }),
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
        ["<Tab>"] = cmp.mapping(function(fallback)
            if luasnip.locally_jumpable(1) then
                luasnip.jump(1)
            elseif cmp.visible() then
                local entry = cmp.get_selected_entry()
                if entry then
                    cmp.confirm()
                else
                    cmp.confirm({ select = true })
                end
            elseif luasnip.expandable() then
                luasnip.expand()
            else
                fallback()
            end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if luasnip.locally_jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { "i", "s" }),
        ['<C-u>'] = cmp.mapping.scroll_docs(-4),
        ['<C-d>'] = cmp.mapping.scroll_docs(4),
        ['<C-y>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = false }),
    }),
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
        { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
    }, {
        { name = 'buffer' },
    })
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' }
    }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        { name = 'cmdline' }
    })
})

vim.lsp.config('*', {
    capabilities = require('cmp_nvim_lsp').default_capabilities()
})

vim.lsp.config('harper_ls', {
    filetypes = { 'markdown', 'text', 'latex', 'tex', 'plaintex' },
    settings = {
        ["harper-ls"] = {
            userDictPath = "~/.config/nvim/spell/harper.txt"
        }
    },
})

vim.lsp.enable({'lua_ls','pyright','clangd','texlab','jetls', 'harper_ls'})

local hover = vim.lsp.buf.hover
---@diagnostic disable-next-line: duplicate-set-field
vim.lsp.buf.hover = function()
    return hover {
        border = 'rounded',
        max_height = math.floor(vim.o.lines * 0.5),
        max_width = math.floor(vim.o.columns * 0.4),
    }
end

local signature_help = vim.lsp.buf.signature_help
---@diagnostic disable-next-line: duplicate-set-field
vim.lsp.buf.signature_help = function()
    return signature_help {
        max_height = math.floor(vim.o.lines * 0.5),
        max_width = math.floor(vim.o.columns * 0.4),
    }
end

vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = "Hover"})
vim.keymap.set('n', ',ls', vim.lsp.buf.signature_help, { desc = "Signature Documentation"})

-- 1. Disable virtual text (inline diagnostics) to avoid duplication
vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- 2. Set updatetime to a lower value (e.g., 500-1000ms) for faster triggering
vim.o.updatetime = 500

-- 3. Show diagnostics on CursorHold
--[[
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    local opts = {
      focusable = false,
      close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
      border = 'rounded',
      source = 'always',
      prefix = ' ',
      scope = 'cursor',
    }
    vim.diagnostic.open_float(nil, opts)
  end
})

vim.keymap.set('n', 'gk', function()
  vim.diagnostic.config({ virtual_lines = { current_line = true }, virtual_text = false })

  vim.api.nvim_create_autocmd('CursorMoved', {
    group = vim.api.nvim_create_augroup('line-diagnostics', { clear = true }),
    callback = function()
      vim.diagnostic.config({ virtual_lines = false, virtual_text = true })
      return true
    end,
  })
end)
]]--


vim.keymap.set('n', 'gK', function()
  local config = vim.diagnostic.config()
  vim.diagnostic.config({ virtual_lines = not config.virtual_lines })
end, { desc = 'Toggle diagnostic virtual_lines' })
