import * as F from "@dashkite/joy/function"
import * as K from "@dashkite/katana/async"
import * as Meta from "@dashkite/joy/metaclass"
import * as R from "@dashkite/rio"
import * as Posh from "@dashkite/posh"
import Registry from "@dashkite/helium"

import { Resource } from "@dashkite/vega-client"

import html from "./html"
import css from "./css"
import waiting from "#templates/waiting"

class extends R.Handle

  Meta.mixin @, [
    R.tag "dashkite-gadget-creator"
    R.diff
    R.initialize [
      R.shadow
      R.sheets [ css, Posh.component ]
      R.activate [
        R.description
        R.render html
      ]
      R.click "a[name='add-layout']", [
        R.call ->
          action: "create layout"
        R.dispatch "change"
      ]
      R.click "a[name='add-navigation']", [
        R.call ->
          action: "create navigation"
        R.dispatch "change"
      ]
      R.click "a[name='add-text']", [
        R.call ->
          action: "create text"
        R.dispatch "change"
      ]
      R.click "a[name='add-image']", [
        R.call ->
          action: "create image"
        R.dispatch "change"
      ]
      R.click "a[name='add-link']", [
        R.call ->
          action: "create link"
        R.dispatch "change"
      ]
      R.click "a[name='add-icon']", [
        R.call ->
          action: "create icon"
        R.dispatch "change"
      ]
      R.click "a[name='add-page']", [
        R.call ->
          action: "create nested page"
        R.dispatch "change"
      ]
    ]
  ]
