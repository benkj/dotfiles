_G.LoadJuliaDiagnostics = function(bufnr, error_file)
    local f = io.open(error_file, "r")
    if not f then return 0 end

    local content = f:read("*a")
    f:close()
    os.remove(error_file)

    if content and content ~= "" then
        local ok, err_data = pcall(vim.json.decode, content)
        if ok and err_data.line > 0 then
            local diagnostic = {
                bufnr = bufnr,
                lnum = err_data.line - 1,
                col = 0,
                severity = vim.diagnostic.severity.ERROR,
                message = err_data.msg,
                source = "Julia REPL",
            }

            local ns = vim.api.nvim_create_namespace("julia_repl_errors")
            vim.diagnostic.reset(ns, bufnr)
            vim.diagnostic.set(ns, bufnr, {diagnostic})

            vim.fn.setqflist({}, 'r', {
                title = "Julia REPL Errors",
                items = {{
                    bufnr = bufnr,
                    lnum = err_data.line,
                    text = err_data.msg,
                    type = 'E'
                }}
            })

            -- 1. Find the window that currently holds your source file
            local win_ids = vim.fn.win_findbuf(bufnr)

            if #win_ids > 0 then
                -- 2. Switch focus to the source file window
                vim.api.nvim_set_current_win(win_ids[1])

                -- 3. Open quickfix immediately below this specific window
                vim.cmd("belowright copen")
            else
                -- Fallback just in case the source buffer is hidden
                vim.cmd("copen")
            end
        end
    end
    return 1
end

_G.ClearJuliaDiagnostics = function(bufnr)
    -- 1. Clear inline diagnostics
    local ns = vim.api.nvim_create_namespace("julia_repl_errors")
    vim.diagnostic.reset(ns, bufnr)

    -- 2. Empty the quickfix list
    vim.fn.setqflist({}, 'r', {
        title = "Julia REPL Errors",
        items = {}
    })

    -- 3. Close the quickfix window
    vim.cmd("cclose")

    return 1 -- Neovim remote-expr expects a return value
end

local iron_core = require("iron.core")

function SendToJuliaWithRemoteDiagnostics()
    local bufnr = vim.api.nvim_get_current_buf()
    local filename = vim.api.nvim_buf_get_name(bufnr)
    local servername = vim.v.servername

    if not servername or servername == "" then
        print("Error: Neovim RPC server is not active.")
        return
    end

    -- Get visual selection range
    local _, start_line, _, _ = unpack(vim.fn.getpos("'<"))
    local _, end_line, _, _ = unpack(vim.fn.getpos("'>"))
    local lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)
    local code_block = table.concat(lines, "\n")

    -- Pad the code to match the starting line
    local padding = string.rep("\n", start_line - 1)
    local padded_code = padding .. code_block

    -- Write to a temporary file
    local temp_payload_file = "/tmp/nvim_julia_payload.jl"
    local f = io.open(temp_payload_file, "w")
    if f then
        f:write(padded_code)
        f:close()
    end

    local error_log_file = "/tmp/nvim_julia_error.json"

    -- Construct the Julia execution wrapper
    local julia_command = string.format([[
    try
    isfile("%s") && rm("%s")

    # 🧹 PRE-EXECUTION CLEANUP: Close quickfix and clear errors
    run(ignorestatus(`nvim --server "%s" --remote-expr "v:lua.ClearJuliaDiagnostics(%d)"`))

    include_string(Main, read("%s", String), "%s")
    println("✅ Execution successful.")
    catch e
    st = stacktrace(catch_backtrace())

    err_line = 0
    for frame in st
        if string(frame.file) == "%s"
            err_line = frame.line
            break
        end
    end

    # Write error to JSON
    open("%s", "w") do err_f
    msg = escape_string(sprint(showerror, e))
    write(err_f, "{\"line\": $(err_line), \"msg\": \"$(msg)\"}")
end

# Trigger Neovim to load the new errors
try
expr = "v:lua.LoadJuliaDiagnostics(%d, '%s')"
run(ignorestatus(`nvim --server "%s" --remote-expr "$expr"`))
catch
println("⚠️ Error caught, but failed to notify Neovim remotely.")
        end
    end
    ]], 
    error_log_file, error_log_file, -- for rm()
    servername, bufnr,              -- for ClearJuliaDiagnostics
    temp_payload_file, filename,    -- for include_string
    filename,                       -- for stacktrace check
    error_log_file,                 -- for writing JSON
    bufnr, error_log_file,          -- for the expr string
    servername                      -- for the nvim remote call
)

-- Send to iron.nvim
iron_core.send(nil, julia_command)
end
