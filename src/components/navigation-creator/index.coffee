import * as Meta from "@dashkite/joy/metaclass"

import * as R from "@dashkite/rio"

import * as Posh from "@dashkite/posh"

import html from "./html"
import css from "./css"

class extends R.Handle

  Meta.mixin @, [
    R.tag "dashkite-navigation-creator"
    R.diff
    R.initialize [
      R.shadow
      R.sheets [ css, Posh.component ]
      R.activate [
        R.render html
      ]

      R.submit [
        R.description
        R.form
        R.call ( form, { root }) ->
          key = root + "/" + form.name
          { form..., key, type: "navigation" }
        R.dispatch "change"
      ]
      R.click "a[name='cancel']", [
        R.call -> 
          action: "create gadget"
        R.dispatch "change"
      ]
    ]
  ]
