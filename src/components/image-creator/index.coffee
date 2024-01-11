import * as F from "@dashkite/joy/function"
import * as K from "@dashkite/katana/async"
import * as Meta from "@dashkite/joy/metaclass"
import * as R from "@dashkite/rio"
import * as Posh from "@dashkite/posh"
import Registry from "@dashkite/helium"
import configuration from "#configuration"

import { Resource } from "@dashkite/vega-client"
import { MediaType } from "@dashkite/media-type"

import html from "./html"
import css from "./css"
import waiting from "#templates/waiting"

class extends R.Handle

  Meta.mixin @, [
    R.tag "dashkite-image-creator"
    R.diff
    R.initialize [
      R.shadow
      R.sheets [ css, Posh.component ]
      R.activate [
        R.render html
      ]
      R.click "button", [
        R.validate
      ]
      R.valid [
        R.form
        R.set "form"
        R.call ->
          { @form..., loading: true }
        R.render html
        R.description
        R.call ({ site, root, branch }) ->
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
          { @form..., key, type: "image", target: download }
        R.dispatch "change"
      ]
      R.click "a[name='cancel']", [
        R.call -> 
          action: "create gadget"
        R.dispatch "change"
      ]
    ]
  ]
