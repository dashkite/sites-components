import * as Meta from "@dashkite/joy/metaclass"

import * as R from "@dashkite/rio"
import HTTP from "@dashkite/rio-vega"

import * as Posh from "@dashkite/posh"

import  configuration from "#configuration"
{ origin } = configuration

import html from "./html"
import css from "./css"
import waiting from "#templates/waiting"

class extends R.Handle

  Meta.mixin @, [

    R.tag "dashkite-sites-home"
    R.diff

    R.initialize [
      R.shadow
      R.sheets [ css, Posh.component ]

      R.describe [
        HTTP.resource ({ workspace }) ->
          origin: origin
          name: "subscription"
          bindings:
            workspace: workspace
            product: "sites"
      ]

      R.activate [
        R.render waiting
        HTTP.get
        R.render html
      ]
    ]
  ]
