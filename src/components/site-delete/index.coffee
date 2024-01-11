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
    R.tag "dashkite-site-delete"
    R.diff
    R.initialize [
      R.shadow
      R.sheets [ css, Posh.component ]
      R.describe [
        R.description
        K.poke ({ site }) ->
          Resource.create 
            origin: configuration.sites.origin
            name: "site"
            bindings: { site }
        R.set "resource"
        R.description
        K.poke ({ workspace }) ->
          Resource.create 
            origin: configuration.workspaces.origin
            name: "subscription-metadata"
            bindings: { workspace, product: "sites" }
        R.set "metadata_resource"
        R.render html
      ]
      R.click "button", [
        R.call ->
          { loading: true }
        R.render html
        R.description
        R.call ({ workspace, site }) ->
          await @resource.delete()
          metadata = await @metadata_resource.get()
          metadata.addresses = metadata.addresses.filter ( address ) ->
            address != site
          @metadata_resource.put metadata
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
