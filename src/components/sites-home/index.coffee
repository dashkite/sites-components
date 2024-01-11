import * as F from "@dashkite/joy/function"
import * as K from "@dashkite/katana/async"
import * as Meta from "@dashkite/joy/metaclass"
import * as R from "@dashkite/rio"
import * as Posh from "@dashkite/posh"

import { Resource } from "@dashkite/vega-client"

import configuration from "#configuration"

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
      R.activate [
        K.push -> loading: true
        R.render html
        R.description
        K.poke ({ workspace }) ->
          subscription = await Resource.get
            origin: configuration.workspaces.origin
            name: "subscription"
            bindings:
              workspace: workspace
              product: "sites"
          { subscription, workspace }
        R.render html
      ]
    ]
  ]
