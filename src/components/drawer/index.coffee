import * as Meta from "@dashkite/joy/metaclass"
import * as R from "@dashkite/rio"
import * as Posh from "@dashkite/posh"

import html from "./html"
import css from "./css"

class extends R.Handle

  Meta.mixin @, [
    R.tag "dashkite-drawer"
    R.diff
    R.initialize [
      R.shadow
      R.sheets [ css, Posh.component ]
      R.activate [
        R.description
        R.render html
      ]
      R.event "click", [
        R.within "input#toggle", [ 
          R.stop
        ]
      ]
    ] 
  ]
