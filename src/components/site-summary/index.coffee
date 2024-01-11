import * as F from "@dashkite/joy/function"
import * as K from "@dashkite/katana/async"
import * as Meta from "@dashkite/joy/metaclass"
import * as R from "@dashkite/rio"
import * as Posh from "@dashkite/posh"

import { Resource } from "@dashkite/vega-client"

import configuration from "#configuration"

import html from "./html"
import css from "./css"

class extends R.Handle

  Meta.mixin @, [
    R.tag "dashkite-site-summary"
    R.diff
    R.initialize [
      R.shadow
      R.sheets [ css, Posh.component ]
      R.describe [
        K.push -> loading: true
        R.render html
        R.description
        K.poke ({ workspace, site }) ->
          site_object = await Resource.get 
            origin: configuration.sites.origin
            name: "site"
            bindings: { site }
          { workspace, site_object... }
        R.render html
      ]
    ]
  ]
