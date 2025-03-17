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
  s(
    { trig = "csvf", desc = "Write into a CSV file" },
    fmt(
      [[
        CSV.open('{}.csv', '{}') do |csv|
          csv << {}

          {}
        end
      ]],
      { i(1), i(2), i(3), i(4) }
    )
  ),
}

return snippets
