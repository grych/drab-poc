import "phoenix_html"
// import Drab from "drab"

var $ = require('jquery')

global.bootstrap = require("bootstrap")
// global.drab = require("drab")

// import Drab from "web/static/js/drab"

import hljs from "highlight.js"
hljs.configure({
  languages: ['elixir', 'html', 'javascript']
  })
hljs.initHighlightingOnLoad()
// import "drab"
// require('dupa').Dupa.run()
// require('drab').Drab.run('aaa')



