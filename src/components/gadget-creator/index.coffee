import * as K from "@dashkite/katana/async"
import * as Meta from "@dashkite/joy/metaclass"

import * as R from "@dashkite/rio"

import * as Posh from "@dashkite/posh"

import html from "./html"
import css from "./css"

class extends R.Handle

  Meta.mixin @, [
    R.tag "dashkite-gadget-creator"
    R.diff

    R.initialize [
      R.shadow
      R.sheets [ css, Posh.component ]

      R.activate [
        R.render html
      ]

      # TODO may need to rename some of the `a` tags
      R.click "a", [
        R.attribute "name"
        K.poke Obj.tag "action"
        R.dispatch "change"
      ]

    ]
  ]
