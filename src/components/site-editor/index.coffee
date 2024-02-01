import * as Meta from "@dashkite/joy/metaclass"

import * as R from "@dashkite/rio"
import HTTP from "@dashkite/rio-vega"

import * as Posh from "@dashkite/posh"

import  configuration from "#configuration"
{ origin } = configuration

import html from "./html"
import css from "./css"

class extends R.Handle

  Meta.mixin @, [
    R.tag "dashkite-site-editor"
    R.diff

    R.initialize [

      R.shadow
      R.sheets [ css, Posh.component ]

      R.describe [
        HTTP.resource ({ site }) ->
          origin: origin
          name: "site"
          bindings: { site }
      ]

      R.activate [
        HTTP.get
        R.render html
      ]

      R.submit [
        HTTP.get
        R.assign
        R.dispatch "change"
      ]

      R.click "a[name='cancel']", [
        R.reset
      ]
    ]
  ]
