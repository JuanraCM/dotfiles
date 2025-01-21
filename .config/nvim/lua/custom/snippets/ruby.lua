local snippets = {
  s(
    { trig = "dbg", desc = "Debug with print statements" },
    fmt(
      [[
        p '##### DEBUG #####'
        p {}
        p '##### DEBUG #####'
      ]],
      { i(1) }
    )
  ),
}

return snippets
