import * as Meta from "@dashkite/joy/metaclass"
import * as F from "@dashkite/joy/function"
import * as Type from "@dashkite/joy/type"
import * as I from "@dashkite/joy/iterable"
import * as Text from "@dashkite/joy/text"
import * as R from "@dashkite/rio"
import * as Posh from "@dashkite/posh"
import * as K from "@dashkite/katana/async"
import * as Ks from "@dashkite/katana/sync"
import html from "./html"
import css from "./css"

pct = (x) -> Math.round x * 100
num = (x) -> Text.parseNumber Text.replace /[^\d\.]/g, "", x
val = (p, el) -> (getComputedStyle el)[p]
spct = (x) -> "#{x}%"

class extends R.Handle

  Meta.mixin @, [
    R.tag "dashkite-splitter"
    R.diff
    R.initialize [
      R.shadow
      R.sheets [ css, Posh.component ]
      R.mutate [
        K.read "handle"
        K.push (handle) ->
          for child, i in handle.dom.children
            if child.slot == ""
              child.slot = "pane-#{i}"
            else
              child.slot
        K.poke (panes, handle) ->
          {panes, sizes: JSON.parse handle.dom.dataset.sizes}
        R.render html
      ]
      R.describe [
        K.read "handle"
        Ks.peek (handle, description) ->
          sizes = JSON.parse description.sizes
          panes = handle.dom.querySelectorAll ".pane"
          for pane, i in panes
            pane.style.flexBasis = spct sizes[i]
      ]
      R.event "mousedown", [
        R.matches ".gutter", [
          Ks.poke (event, handle) ->
            parent = event.target.parentNode
            previous = event.target.previousSibling
            next = event.target.nextSibling
            direction = (getComputedStyle parent).flexDirection
            dimension = if direction == "row" then "width" else "height"
            sizes =
              previous: num val dimension, previous
              next: num val dimension, next
            available = sizes.previous + sizes.next
            start = pct (sizes.previous / available)
            handle.drag = { direction, previous, next, start, change: 0 }
        ]
      ]
      R.event "mousemove", [
        Ks.peek (event, handle) ->
          if handle.drag?
            event.stopPropagation()
            event.preventDefault()
            { direction, previous, next, start, change } = handle.drag
            available = if direction == "row"
              handle.dom.offsetWidth
            else
              handle.dom.offsetHeight
            # TODO compute this based on direction
            change += event.movementX
            current = start + (pct (change / available))
            previous.style.flexBasis = spct current
            next.style.flexBasis = spct (100 - current)
            handle.drag.change = change
      ]
      R.event "mouseup", [
        Ks.push (event, handle) -> handle.drag?
        Ks.test Type.isDefined, F.pipe [
          Ks.discard
          Ks.push (event, handle) ->
            if handle.drag?
              { previous, next } = handle.drag
              handle.drag = undefined
              handle.dom.dataset.sizes = JSON.stringify [
                num previous.style.flexBasis
                num next.style.flexBasis
              ]
          R.dispatch "change"
] ] ] ]
