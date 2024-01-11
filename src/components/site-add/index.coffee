import * as F from "@dashkite/joy/function"
import * as K from "@dashkite/katana/async"
import * as Meta from "@dashkite/joy/metaclass"
import * as R from "@dashkite/rio"
import * as Posh from "@dashkite/posh"
import Router from "@dashkite/rio-oxygen"

import { Resource } from "@dashkite/vega-client"

import configuration from "#configuration"

import html from "./html"

class extends R.Handle

  Meta.mixin @, [
    R.tag "dashkite-site-add"
    R.diff
    R.initialize [
      R.shadow
      R.describe [
        R.render html
        R.focus "input"
        R.description
        K.poke ({ workspace }) ->
          Resource.create 
            origin: configuration.sites.origin
            name: "sites"
        R.set "site_resource"
        R.description
        K.poke ({ workspace }) ->
          Resource.create 
            origin: configuration.workspaces.origin
            name: "subscription-metadata"
            bindings:
              workspace: workspace
              product: "sites"
        R.set "metadata_resource"
      ]
      R.click "button", [
        R.validate
      ]
      R.click "a[name='cancel']", [
        -> history.back()
      ]
      R.valid [
        R.form
        R.set "form"
        R.call ->
          { @form..., loading: true }
        R.render html
        R.call ->
          { address } = await @site_resource.post @form
          metadata = await @metadata_resource.get()
          metadata.addresses ?= []
          metadata.addresses.push address
          @metadata_resource.put metadata
        R.description
        Router.browse ({ workspace }) -> 
          name: "sites-home"
          parameters: { workspace }
      ]
    ]
  ]
