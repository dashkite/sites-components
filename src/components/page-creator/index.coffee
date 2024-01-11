import * as F from "@dashkite/joy/function"
import * as K from "@dashkite/katana/async"
import * as Meta from "@dashkite/joy/metaclass"
import * as R from "@dashkite/rio"
import * as Posh from "@dashkite/posh"
import Registry from "@dashkite/helium"

import { Resource } from "@dashkite/vega-client"

import html from "./html"
import css from "./css"
import waiting from "#templates/waiting"

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
        R.call ( form, { site, root } ) ->
          key = if root == "" then form.name else root + "/" + form.name
          { form..., key, type: "page", slots: {} }
        R.dispatch "change"
      ]
      R.click "a[name='cancel']", [
        R.description
        R.call ({ site, root }) -> 
          if root == "" then action: "" else action: "edit"
        R.dispatch "change"
      ]
    ]
  ]
