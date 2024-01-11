import * as F from "@dashkite/joy/function"
import * as K from "@dashkite/katana/async"
import * as Meta from "@dashkite/joy/metaclass"
import * as R from "@dashkite/rio"
import * as Posh from "@dashkite/posh"
import Registry from "@dashkite/helium"
import configuration from "#configuration"

import { Resource } from "@dashkite/vega-client"
import { resolve, lookup } from "@dashkite/sites-resource"

import html from "./html"
import css from "./css"
import waiting from "#templates/waiting"

class extends R.Handle

  Meta.mixin @, [
    R.tag "dashkite-page-editor"
    R.diff
    R.initialize [
      R.shadow
      R.sheets [ css, Posh.component ]
      R.describe [
        K.poke ({ site, branch, key }) ->
          resources = await Resource.get 
            origin: configuration.sites.origin
            name: "branch"
            bindings: { site, branch }
          tree = resolve resources
          lookup tree, key
        R.set "data"
        R.render html
      ]
      R.click "button", [
        R.validate
      ]
      R.valid [
        R.form
        R.call ( form ) ->
          { @data..., form... }
        R.dispatch "change"
      ]
      R.click "a[name='cancel']", [
        R.form.reset
      ]
    ]
  ]
