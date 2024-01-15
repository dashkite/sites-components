import * as Meta from "@dashkite/joy/metaclass"

import * as R from "@dashkite/rio"
import HTTP from "@dashkite/rio-vega"

# import * as Posh from "@dashkite/posh"

import Subscription from "#helpers/subscription"

import  configuration from "#configuration"
{ origin } = configuration

import html from "./html"
import waiting from "./html"
# import css from "./css"

class extends R.Handle

  Meta.mixin @, [

    R.tag "dashkite-site-add"
    R.diff

    R.initialize [

      R.shadow
      R.describe [
        HTTP.resource
          origin: origin
          name: "sites"
        R.render html
      ]

      R.click "button", [
        R.validate
      ]

      R.click "a[name='cancel']", [
        -> history.back()
      ]

      R.valid [
        R.render waiting
        HTTP.post
        Subscription.update
        R.description
        Router.browse ({ workspace }) -> 
          name: "sites-home"
          parameters: { workspace }
      ]
    ]
  ]
