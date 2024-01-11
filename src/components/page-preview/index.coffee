import * as F from "@dashkite/joy/function"
import * as K from "@dashkite/katana/async"
import * as Ks from "@dashkite/katana/sync"
import * as Time from "@dashkite/joy/time"
import * as Meta from "@dashkite/joy/metaclass"
import * as R from "@dashkite/rio"
import * as Posh from "@dashkite/posh"
import Registry from "@dashkite/helium"

import { Resource } from "@dashkite/vega-client"
import { resolve, lookup } from "@dashkite/sites-resource"

import html from "./html"
import css from "./css"
import waiting from "#templates/waiting"
import configuration from "#configuration"

poll = ({ interval, event }) ->
  F.pipe [
    Ks.read "handle"
    Ks.pop ( handle ) -> 
      do ->
        loop
          await Time.sleep interval
          handle.root.dispatchEvent new CustomEvent event,
            detail: handle
            bubbles: true
            cancelable: false
            composed: true  
      undefined
  ]

getPage = ({ site, branch, page }) ->
  path = page.split "/"
  html: await Resource.get 
    origin: configuration.sites.origin
    name: "page"
    bindings: { site, branch, path }

$html = null

class extends R.Handle

  Meta.mixin @, [
    R.tag "dashkite-page-preview"
    R.diff
    R.initialize [
      R.shadow
      R.sheets [ css, Posh.component ]
      R.describe [
        K.poke getPage
        K.peek ({ html }) -> $html = html
        R.render html
      ]
      poll { interval: 5000, event: "refresh" }
      R.event "refresh", [
        F.flow [
          R.description
          K.poke getPage
          # we don't call render here because diffHTML appears
          # to be doing a diff against the iframe's content
          # see link below for reference
          # TODO is there a way to mark the node to only check attr?
          #      check with tbranyen
          R.call ({ html }) ->
            iframe = @shadow.querySelector "iframe"
            if html != $html
              $html = html
              iframe.srcdoc = html
        ]
      ]
    ]
  ]

# diffHTML check for ownerDocument, which exists for iframes
# https://github.com/tbranyen/diffhtml/blob/8ec3742ae1a33e39da740c7ed01cdc078eddabc8/packages/diffhtml/lib/tree/create.js#L62