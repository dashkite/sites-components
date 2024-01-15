import * as Meta from "@dashkite/joy/metaclass"

import * as R from "@dashkite/rio"

import * as Posh from "@dashkite/posh"

import html from "./html"
import css from "./css"

class extends R.Handle

  Meta.mixin @, [

    R.tag "dashkite-page-creator"
    R.diff

    R.initialize [
      R.shadow
      R.sheets [ css, Posh.component ]

      R.activate [
        R.render html
      ]

      R.click "button", [
        R.validate
      ]

      R.valid [
        R.description
        R.form
        R.call ( form, { root } ) ->
          key = if root == "" then form.name else root + "/" + form.name
          { form..., key, type: "page", slots: {} }
        R.dispatch "change"
      ]

      R.click "a[name='cancel']", [
        R.description
        R.call ({ root }) -> 
          if root == "" then action: "" else action: "edit"
        R.dispatch "change"
      ]
    ]
  ]
