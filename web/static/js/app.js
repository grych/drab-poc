import "phoenix_html"

global.bootstrap = require("bootstrap")
// global.drab = require("drab")

// import Drab from "web/static/js/drab"

import hljs from "highlight.js"
hljs.configure({
  languages: ['elixir', 'html', 'javascript']
  })
hljs.initHighlightingOnLoad()


