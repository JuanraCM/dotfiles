local function nodes_blueprinter(args)
  local fulltext = table.concat(args[1])
  local _, nodecount = fulltext:gsub("{}", "")
  local nodes = {}

  for pos = 1, nodecount do
    table.insert(
      nodes,
      c(pos, {
        t(("i(%s)"):format(pos)),
        t(('i(%s, "placeholder")'):format(pos)),
        t('t("text")'),
        t("f(fn)"),
        t("f(fn, { pos })"),
      })
    )

    table.insert(nodes, t(", "))
  end

  table.remove(nodes)

  return sn(nil, nodes)
end

local snippets = {
  s(
    { trig = "snip", desc = "Snippet blueprint" },
    fmt(
      [===[
        s(
          {{ trig = "{}", desc = "{}" }},
          fmt(
            [[
              {}
            ]],
            {{ {} }}
          )
        )
      ]===],
      { i(1), i(2), i(3), d(4, nodes_blueprinter, { 3 }) }
    )
  ),
}

return snippets
