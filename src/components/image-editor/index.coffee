import * as Meta from "@dashkite/joy/metaclass"

import * as R from "@dashkite/rio"
import HTTP from "@dashkite/rio-vega"

import * as Posh from "@dashkite/posh"

import Gadget from "#helpers/gadget"

import html from "./html"
import css from "./css"


class extends R.Handle

  Meta.mixin @, [

    R.tag "dashkite-image-editor"
    R.diff

    R.initialize [
      R.shadow
      R.sheets [ css, Posh.component ]

      R.describe [
        HTTP.resource ({ site, branch }) ->
          origin: configuration.sites.origin
          name: "branch"
          bindings: { site, branch }
      ]

      R.activate [
        R.description
        Gadget.get
        R.render html
      ] 

      R.click "button", [
        R.validate
      ]
      R.valid [
        R.render waiting
        R.form
        R.set "form"
        R.call ->
          loading = false
          if @form.image.name != "" then loading = true
          { @form..., loading }
        R.render html
        R.description
        # R.call ({ site, root, branch }) ->
        R.call ({ site, branch }) ->
          if @form.image.name != ""
            # key = root + "/" + @form.name
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
