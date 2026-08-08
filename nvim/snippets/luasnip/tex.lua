local ls   = require("luasnip")
local s    = ls.snippet
local i    = ls.insert_node
local f    = ls.function_node
local d    = ls.dynamic_node
local sn   = ls.snippet_node
local t    = ls.text_node
local fmta = require("luasnip.extras.fmt").fmta

local function math()
  return vim.fn["vimtex#syntax#in_mathzone"]() == 1
end

local function env(name) 
    local is_inside = vim.fn['vimtex#env#is_inside'](name)
    return (is_inside[1] > 0 and is_inside[2] > 0)
end

-- for TikZ environments. Note that you will need to define new helper functions with this setup
local function tikz()
    return env("tikzpicture")
end

-- ─── Environments ─────────────────────────────────────────────────────────────
ls.add_snippets("tex", {

  -- fig: caption-mirrored label (live update via update_events)
  s({ trig = "fig",     dscr = "Figure",       wordTrig = true }, fmta([[
\begin{figure}[<>]
	\centering
	\includegraphics[width=<>\textwidth]{<>}
	\caption{<>}
	\label{fig:<>}
\end{figure}]], {
    i(1, "htpb"),
    i(2, "0.9"),
    i(3, "filename"),
    i(4, "caption"),
    f(function(args)
      return args[1][1]:lower():gsub("%s+", "_"):gsub("[^%w_]", "")
    end, { 3 }),
  })),

  -- tab: tabular
  s({ trig = "tab",   dscr = "tabular",        wordTrig = true }, fmta([[
\begin{tabular}{<>}
	<>
\end{tabular}]], { i(1, "c"), i(0) })),

  -- table: full table
  s({ trig = "table", dscr = "Table",          wordTrig = true }, fmta([[
\begin{table}[<>]
	\centering
	\caption{<>}
	\label{tab:<>}
	\begin{tabular}{<>}
		<>
	\end{tabular}
\end{table}]], { i(1, "htpb"), i(2, "caption"), i(3, "label"), i(4, "c"), i(0) })),

})


-- ─── Tikz ─────────────────────────────────────────────────────────────
ls.add_snippets("tex", {
    -- node 
    s({ trig = "node", dscr = "TikZ node", wordTrig = true, condition = tikz, show_condition = tikz },
    fmta([[\node[<>] (<>) at (<>) {<>};
    <>]], {
        i(1, "options"),
        i(2, "name"),
        i(3, "0,0"),
        i(4, "$label$"),
        i(0),
    })),

    -- node relative to another (e.g. "right of=A")
    s({ trig = "nodrel", dscr = "TikZ relative node", condition = tikz, show_condition = tikz },
    fmta([[\node[<>, <> of=<>] (<>) {<>};
    <>]], { i(1, "options"), i(2, "right"), i(3, "ref"), i(4, "name"), i(5, "$label$"), i(0) })),

    -- coo: tikz coordinate
    s({ trig = "coo", dscr = "TikZ coordinate", wordTrig = true, condition = tikz, show_condition = tikz },
    fmta([[\coordinate (<>) at (<>);<>]], { i(1,"name"), i(2, "0,0"), i(0) })),

    -- angle: tikz angle pic
    s({ trig = "angle", dscr = "TikZ angle", wordTrig = true, condition = tikz, show_condition = tikz },
    fmta([[\pic [draw, <<-, "$<>$", angle eccentricity=1.5, angle radius=4mm] {angle = <>--<>--<>};<>]],
    { i(1, "\\phi"), i(2, "a"), i(3,"b"), i(4,"c"), i(0) })),

    -- scope
    s({ trig = "sco", dscr = "TikZ scope", wordTrig = true, condition = tikz, show_condition = tikz },
    fmta([[
    \begin{scope}[shift={(<>,<>)}]
    <>
    \end{scope}]], { i(1, "x"), i(2,"y"), i(0) })),

    -- draw path
    s({ trig = "dr", dscr = "TikZ draw", wordTrig = true, condition = tikz, show_condition = tikz },
    fmta([[\draw[<>] <>;]], { i(1, "options"), i(2, "path") })),

    -- fill
    s({ trig = "fi", dscr = "TikZ fill", wordTrig = true, condition = tikz, show_condition = tikz },
    fmta([[\fill[<>] <>;]], { i(1, "color"), i(2, "path") })),

    -- node on path (inline, e.g. inside a draw command)
    s({ trig = "no", dscr = "TikZ inline node", wordTrig = true, condition = tikz, show_condition = tikz },
    fmta([[node[<>] {<>}]], { i(1, "options"), i(2, "label") })),

    -- foreach
    s({ trig = "for", dscr = "TikZ foreach", wordTrig = true, condition = tikz, show_condition = tikz },
    fmta([[\foreach \<> in {<>} {
        <>
    }]], { i(1, "x"), i(2, "1,...,5"), i(0) })),

    -- matrix of nodes (common in commutative diagrams)
    s({ trig = "mat", dscr = "TikZ matrix of nodes", wordTrig = true, condition = tikz, show_condition = tikz },
    fmta([[
    \matrix[matrix of nodes, <>, row sep=<>, column sep=<>] (<>) {
        <> \\
    };]], { i(1, "options"), i(2, "1em"), i(3, "1em"), i(4, "m"), i(0) })),

    -- arrow between two nodes
    s({ trig = "arr", dscr = "TikZ arrow", wordTrig = true, condition = tikz, show_condition = tikz },
    fmta([[\draw[<>] (<>) -- (<>);]], { i(1, "->"), i(2, "A"), i(3, "B") })),

    -- curved arrow
    s({ trig = "cur", dscr = "TikZ curved arrow", wordTrig = true, condition = tikz, show_condition = tikz },
    fmta([[\draw[<>] (<>) to[bend <>=<>] (<>);]], { i(1, "->"), i(2, "A"), i(3, "left"), i(4, "30"), i(5, "B") })),
})

-- ─── Autosnippets (expand without Tab) ───────────────────────────────────────

local fn_snippets = {}
for _, fn in ipairs({ "sin", "cos", "arccot", "cot", "csc", "ln", "log", "exp", "star", "perp" }) do
    table.insert(fn_snippets, s(
        { trig = fn, dscr = "\\" .. fn, wordTrig = true, condition = math },
        { t("\\" .. fn) }
    ))
end

table.insert(fn_snippets, s({ trig = "rm",  dscr = "\\mathrm{}",        condition = math },
fmta([[\mathrm{<>}<>]], { i(1), i(0) })))

table.insert(fn_snippets, s({ trig = "td",  dscr = "^{} superscript",   condition = math },
fmta([[^{<>}<>]], { i(1), i(0) })))

table.insert(fn_snippets, s({ trig = "^(",  dscr = "^{()} superscript", condition = math },
fmta([[^{(<>)}<>]], { i(1), i(0) })))

-- Autosnippets: expand immediately without Tab
ls.add_snippets("tex", fn_snippets)

ls.add_snippets("tex", {

    s({ trig = "__", dscr = "_{} subscript", condition = math, wordTrig = false },
    fmta([[_{<>}<>]], { i(1), i(0) })),

    s({ trig = "xx", dscr = "\\times", condition = math, wordTrig = false },
    t([[\times ]])),

    -- LaTeX-style quotes: "" -> ``|''
    s({ trig = '""', dscr = "LaTeX-style quotes", wordTrig = false },
    fmta([[``<>'']], { i(1) })),

    -- inverse: "Ainvs" -> "A^{-1}"
    s({ trig = "(%w+)invs", dscr = "^{-1} inverse", regTrig = true, wordTrig = false, condition = math },
    f(function(_, snip) return snip.captures[1] .. "^{-1}" end, {})),

    -- bra: <expr| -> \bra{expr}
    s({ trig = "<(.-)%|", dscr = "\\bra{}", regTrig = true },
    f(function(_, snip)
        return "\\bra{" .. snip.captures[1]:gsub("q","\\psi"):gsub("f","\\phi") .. "}"
    end, {})),

    -- ket: |expr> -> \ket{expr}
    s({ trig = "%|(.-)>", dscr = "\\ket{}", regTrig = true },
    f(function(_, snip)
        return "\\ket{" .. snip.captures[1]:gsub("q","\\psi"):gsub("f","\\phi") .. "}"
    end, {})),

    -- braket: \bra{x}expr> -> \braket{x}{expr}
    s({ trig = "(.-)\\bra{(.-)}([^|]-)>", dscr = "\\braket{}{}", regTrig = true },
    f(function(_, snip)
        local ket = snip.captures[3]:gsub("q","\\psi"):gsub("f","\\phi")
        return snip.captures[1] .. "\\braket{" .. snip.captures[2] .. "}{" .. ket .. "}"
    end, {})),

}, { type = "autosnippets" })


-- dynamic matrix 
local mat = function(args, snip)
    local rows = tonumber(snip.captures[2])
    local cols = tonumber(snip.captures[3])
    local nodes = {}
    local ins_indx = 1
    for j = 1, rows do
        table.insert(nodes, r(ins_indx, tostring(j).."x1", i(1)))
        ins_indx = ins_indx+1
        for k = 2, cols do
            table.insert(nodes, t" & ")
            table.insert(nodes, r(ins_indx, tostring(j).."x"..tostring(k), i(1)))
            ins_indx = ins_indx+1
        end
        table.insert(nodes, t{"\\\\", ""})
    end
    return sn(nil, nodes)
end

-- full snippet
ls.add_snippets("tex", {
    s({ trig='([bBpvV])mat(%d+)x(%d+)([ar])', regTrig=true, name='matrix', dscr='matrix trigger lets go'},
    fmta([[
    \begin{<>}<>
    <>
    \end{<>}]],
    { f(function (_, snip) return snip.captures[1] .. "matrix" end),
    f(function (_, snip) -- augments
        if snip.captures[4] == "a" then
            out = string.rep("c", tonumber(snip.captures[3]) - 1)
            return "[" .. out .. "|c]"
        end
        return ""
    end),
    d(1, mat),
    f(function (_, snip) return snip.captures[1] .. "matrix" end)},
    { delimiters='<>' })),
})
