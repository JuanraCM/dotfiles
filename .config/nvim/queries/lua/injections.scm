; Highlight LuaSnip fmt code template
((function_call
  name: _ @fmt_call
  arguments: (arguments
    (string
      content: _ @injection.content)))
  (#eq? @fmt_call "fmt")
  (#set-lang-from-filename!))
