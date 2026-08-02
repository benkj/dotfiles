---@type vim.lsp.Config
return {
    cmd = {
        "jetls", "serve",
    },
    filetypes = { "julia" },
    root_markers = { "Project.toml" },
    settings = {
        jetls = {
            full_analysis = {
                debounce = 1.0,
            },
            -- Use JuliaFormatter instead of Runic
            formatter = "JuliaFormatter",
            diagnostic = {
                patterns = {
                },
            },
        },
    },
}
