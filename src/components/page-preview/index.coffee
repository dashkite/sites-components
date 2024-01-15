import * as Meta from "@dashkite/joy/metaclass"

import * as R from "@dashkite/rio"
import HTTP from "@dashkite/rio-vega"

import * as Posh from "@dashkite/posh"

import  configuration from "#configuration"
{ origin } = configuration

import html from "./html"
import css from "./css"

Preview =

  # we don't call render here because diffHTML appears
  # to be doing a diff against the iframe's content [^1]
  
  # TODO is there a way to mark the node to only check attr?
  #      check with tbranyen
  update: R.call ({ html }) ->
    iframe = @shadow.querySelector "iframe"
    if html != iframe.srcdoc
      iframe.srcdoc = html

class extends R.Handle

  Meta.mixin @, [
    R.tag "dashkite-page-preview"
    R.diff
    R.initialize [
      R.shadow
      R.sheets [ css, Posh.component ]
      R.describe [
        HTTP.resource ({ site, branch, page }) ->
          path = page.split "/"
          origin: origin
          name: "page"
          bindings: { site, branch, path }
      ]
      R.activate [
        HTTP.get
        R.render html
      ]

      R.poll interval, [
        HTTP.get
        Preview.update        
      ]
    ]
  ]

# [^1]: diffHTML check for ownerDocument, which exists for iframes
# https://github.com/tbranyen/diffhtml/blob/8ec3742ae1a33e39da740c7ed01cdc078eddabc8/packages/diffhtml/lib/tree/create.js#L62