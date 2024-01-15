import * as Meta from "@dashkite/joy/metaclass"

import * as R from "@dashkite/rio"
import HTTP from "@dashkite/rio-vega"

import * as Posh from "@dashkite/posh"

import Subscription from "#helpers/subscription"

import  configuration from "#configuration"
{ origin } = configuration

import html from "./html"
import waiting from "./html"
import css from "./css"

class extends R.Handle

  Meta.mixin @, [

    R.tag "dashkite-site-delete"
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
        R.describe
        R.render html
      ]

      R.click "button", [
        R.render waiting
        R.description
        HTTP.delete
        Subscription.delete
        Router.browse ({ workspace }) ->
          name: "sites-home"
          parameters: { workspace }
      ]

      R.click "a[name='cancel']", [
        Router.back
      ]

    ]
  ]
