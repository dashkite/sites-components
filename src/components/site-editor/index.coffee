import * as F from "@dashkite/joy/function"
import * as K from "@dashkite/katana/async"
import * as Meta from "@dashkite/joy/metaclass"
import * as R from "@dashkite/rio"
import * as Posh from "@dashkite/posh"
import Router from "@dashkite/rio-oxygen"
import configuration from "#configuration"

import { Resource } from "@dashkite/vega-client"

import html from "./html"
import css from "./css"
import waiting from "#templates/waiting"

class extends R.Handle

  Meta.mixin @, [
    R.tag "dashkite-site-editor"
    R.diff
    R.initialize [
      R.shadow
      R.sheets [ css, Posh.component ]
      R.activate [
        R.description
        K.poke ({ site }) ->
          Resource.create
            origin: configuration.sites.origin
            name: "site"
            bindings: { site }
        R.set "resource"
        R.description
        R.call ({ workspace }) ->
          site = await @resource.get()
          { site..., workspace }
        R.set "data"
        R.render html
      ]
      R.click "button[name='save']", [
        R.validate
      ]
      R.valid [
        R.form
        R.call ( form ) ->
          delete @data.workspace
          @resource.put { @data..., form... }
          undefined
        R.description
        Router.browse ({ workspace }) -> 
          name: "sites-home"
          parameters: { workspace }
      ]
      R.click "a[name='cancel']", [
        -> history.back()
      ]
    ]
  ]
