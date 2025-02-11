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
  s(
    { trig = "dbgf", desc = "Debug with log file" },
    fmt(
      [[
        File.open('{}', 'w') do |f|
          f.write("##### DEBUG ##### Time: #{{Time.now}}\n")
          f.write({} + "\n")
          f.write("##### DEBUG ##### Time: #{{Time.now}}\n")
        end
      ]],
      { i(1), i(2) }
    )
  ),
}

return snippets
