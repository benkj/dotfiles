local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
  -- internal page link
  s("lnk", fmt("[{}]({})", { i(1, "text"), i(2, "page.qmd") })),

  -- external URL link
  s("url", fmt("[{}](https://{})", { i(1, "text"), i(2) })),

  -- code block
  s("cb", fmt("```{}\n{}\n```", { i(1, "python"), i(2) })),

  -- inline math
  s("im", fmt("${}$", { i(1) })),

  -- display math
  s("dm", fmt("$$\n{}\n$$", { i(1) })),

  -- qmd front matter
  s("fm", fmt([[
---
title: "{}"
date: {}
---]], { i(1, "Title"), i(2, "2026-08-10") })),

  -- quarto callout blocks
  s("note", fmt("::: {{.callout-note}}\n{}\n:::", { i(1) })),
  s("warn", fmt("::: {{.callout-warning}}\n{}\n:::", { i(1) })),

  -- figure with caption
  s("fig", fmt("![]({}){{fig-cap=\"{}\"}}", { i(1, "path"), i(2, "caption") })),

  -- theorem environment (quarto has native support)
  s("thm", fmt("::: {{#thm-{}}}\n## {}\n{}\n:::", { i(1, "label"), i(2, "Title"), i(3) })),

  -- proof
  s("prf", fmt("::: {{.proof}}\n{}\n:::", { i(1) })),
}
