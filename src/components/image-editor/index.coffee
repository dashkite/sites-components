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
    R.tag "dashkite-image-editor"
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
        R.set "form"
        R.call ->
          loading = false
          if @form.image.name != "" then loading = true
          { @form..., loading }
        R.render html
        R.description
        R.call ({ site, root, branch }) ->
          if @form.image.name != ""
            key = root + "/" + @form.name
            address = await generateAddress()
            { upload, download } = await Resource.post 
              origin: configuration.sites.origin
              name: "media"
              bindings: { site, branch, address, name: @form.image.name }
              content: contentType: @form.image.type
            await fetch upload, 
              method: "PUT"
              headers: "content-type": @form.image.type
              body: await @form.image.arrayBuffer()
            delete @form.image
            @form.target = download
          { @data..., @form... }
        R.dispatch "change"
        R.call ->
          { @form..., loading: false }
        R.render html
      ]
      R.click "a[name='cancel']", [
        R.form.reset
      ]
    ]
  ]
