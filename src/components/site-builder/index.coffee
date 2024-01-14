import * as F from "@dashkite/joy/function"
import * as K from "@dashkite/katana/async"
import * as Meta from "@dashkite/joy/metaclass"
import * as R from "@dashkite/rio"
import * as Posh from "@dashkite/posh"
import * as Text from "@dashkite/joy/text"
import Registry from "@dashkite/helium"
import configuration from "#configuration"
import { Resource } from "@dashkite/vega-client"
import { resolve, traverse, lookup, key_change, 
  insert, get_root, delete_resource, assign, sort, find_page } from "@dashkite/sites-resource"

import html from "./html"
import css from "./css"
import waiting from "#templates/waiting"

setDragImage = do ({ image, origin } = {}) ->
  ( event ) ->
    unless image?
      image = new Image()
      image.src = configuration.media.circle
    event.dataTransfer.setDragImage image, 10, 10

class extends R.Handle

  Meta.mixin @, [
    R.tag "dashkite-site-builder"
    R.diff
    R.initialize [
      R.shadow
      R.sheets [ css, Posh.component ]
      R.observe "data", [
        R.render html
      ]
      R.describe [
        K.push -> []
        R.set "dropzone"
        K.push -> {}
        R.set "dragged"
        K.push -> {}
        R.set "drop"
        R.description
        K.poke ({ site, branch }) -> 
          resources = await Resource.get 
            origin: configuration.sites.origin
            name: "branch"
            bindings: { site, branch }
          tree = resolve resources
          console.log "TREE", tree
          tree ?= []
          { sizes: [ 20, 60, 20 ], tree, site, branch }
        R.assign "data"
        R.render html
      ]
      R.event "click", [
        R.within "vellum-drawer > .label, .file > .label", [
          F.flow [
            R.call (el, event, handle) -> 
              selected: 
                key: el.dataset.key
                type: el.dataset.type
                name: el.dataset.name
              action: "edit"
              page: find_page @data.tree, el.dataset.key
            R.assign "data"
          ]
        ]
      ]
      R.event "mousedown", [
        R.within "input[name='name']", [
          F.flow [
            R.call (el, event, handle) -> 
              if @data.selected?.key != el.dataset.key
                event.stopPropagation()
                event.preventDefault()
          ]
        ]
      ]
      R.event "dragstart", [
        R.within ".folder, .file", [
          F.flow [
            R.call (el, event, handle) ->
              el.classList.add "drag"
              event.target.focus()
              await setDragImage event
              key: el.dataset.key
              type: el.dataset.type
            R.set "dragged"
          ]
        ]
      ]
      R.event "dragover", [
        R.within "vellum-drawer > .label", [
          F.flow [
            R.call (el, event, handle) -> 
              if @dragged?.key?
                if !( @dropzone.includes @dragged.key ) && el.dataset.key != @dragged.key
                  if el.dataset.type == "navigation"
                    if @dragged.type == "link"
                      drawer = el.parentNode
                      toggle = drawer.shadowRoot.getElementById "toggle"
                      toggle.checked = true
                    if @dragged.type != "page"
                      el.classList.add "drop"
                      @drop.parent = el.dataset.parentKey
                      @drop.before = el.dataset.key
                      event.preventDefault()
                  else
                    if @dragged.type != "page"
                      drawer = el.parentNode
                      toggle = drawer.shadowRoot.getElementById "toggle"
                      toggle.checked = true
                    if el.dataset.type != "page" && @dragged.type != "page"
                      el.classList.add "drop"
                      @drop.parent = el.dataset.parentKey
                      @drop.before = el.dataset.key
                      event.preventDefault()
          ]
        ]
      ]
      R.event "dragover", [
        R.within ".file > .label", [
          F.flow [
            R.call (el, event, handle) -> 
              if @dragged?.key?
                if !( @dropzone.includes @dragged.key ) && @dragged.type != "page" && el.dataset.key != @dragged.key
                  if !( el.dataset.parentType == "navigation" && @dragged.type != "link" )
                    el.classList.add "drop"
                    @drop.parent = el.dataset.parentKey
                    @drop.before = el.dataset.key
                    event.preventDefault()
          ]
        ]
      ]
      R.event "dragover", [
        R.within ".placeholder", [
          F.flow [
            R.call (el, event, handle) -> 
              if @dragged?.key?
                if !( @dropzone.includes @dragged.key ) && el.dataset.key != @dragged.key
                  if @dragged.type != "page"
                    if !( el.dataset.parentType == "navigation" && @dragged.type != "link" )
                      el.classList.add "drop"
                      @drop.parent = el.dataset.parentKey
                      @drop.before = "placeholder"
                      event.preventDefault()
          ]
        ]
      ]
      R.event "drop", [
        R.within ".folder", [
          F.flow [
            R.description
            R.call ({ site, branch }, el, event ) -> 
              event.preventDefault()
              { parent, before } = @drop
              if parent?
                dropped = lookup @data.tree, @dragged.key
                if parent == ""
                  # @data.tree[ detail.key ] = detail
                else
                  new_parent = lookup @data.tree, parent
                  new_parent.content ?= []
                  old_parent = lookup @data.tree, get_root dropped.key
                  old_parent.content = old_parent.content.filter ( element ) -> element.key != dropped.key
                  key_change dropped, parent
                  if before == "placeholder"
                    new_parent.content.push dropped
                  else
                    index = new_parent.content.findIndex ( element ) -> element.key == before
                    new_parent.content.splice index, 0, dropped
                  assign @data.tree, new_parent.key, new_parent
                  @data.tree = sort @data.tree
                  @data.selected.key = dropped.key
                  @data.page = find_page @data.tree, dropped.key
                resources = traverse @data.tree
                Resource.put 
                  origin: configuration.sites.origin
                  name: "branch"
                  bindings: { site, branch }
                  content: resources
                undefined
          ]
        ]
      ]
      R.event "dragenter", [
        R.within ".folder", [
          F.flow [
            R.call (el, event, handle) -> 
              @dropzone.push el.dataset.key
              event.preventDefault()
          ]
        ]
      ]
      R.event "dragleave", [
        R.within ".label, .placeholder", [
          F.flow [
            R.call (el, event, handle) -> 
              el.classList.remove "drop"
          ]
        ]
      ]
      R.event "dragend", [
        R.within ".folder, .file", [
          F.flow [
            R.call (el, event, handle) -> 
              el.classList.remove "drag"
          ]
        ]
      ]
      R.event "drop", [
        R.within ".label, .placeholder", [
          F.flow [
            R.call (el, event, handle) -> 
              el.classList.remove "drop"
          ]
        ]
      ]
      R.event "dragleave", [
        R.within ".folder", [
          F.flow [
            R.call (el, event, handle) ->
              @dropzone = @dropzone.filter ( key ) -> key != event.target.dataset.key
          ]
        ]
      ]
      R.event "change", [
        R.within "dashkite-page-creator", [
          F.flow [
            R.description
            R.call ({ site, branch }, el, { detail } ) ->
              if detail.action?
                @data.action = detail.action
              else
                resources = undefined
                if (detail.key.split "/").length > 1
                  parent = lookup @data.tree, @data.selected.key
                  parent.content ?= []
                  parent.content.push detail
                  resources = traverse @data.tree
                else
                  @data.tree[ detail.key ] = detail
                  @data.tree = sort @data.tree
                  resources = traverse @data.tree
                Resource.put 
                  origin: configuration.sites.origin
                  name: "branch"
                  bindings: { site, branch }
                  content: resources
                @data.selected = 
                  key: detail.key
                  type: "page"
                  name: detail.name
                @data.page = detail.key
                @data.action = "edit"
          ]
        ]
      ]
      R.event "change", [
        R.within "dashkite-gadget-creator", [
          F.flow [
            R.call ( el, { detail } ) ->
              @data.action = detail.action
          ]
        ]
      ]
      R.event "change", [
        R.within "dashkite-layout-creator", [
          F.flow [
            R.description
            R.call ({ site, branch }, el, { detail } ) ->
              if detail.action?
                @data.action = detail.action
              else
                parent = lookup @data.tree, @data.selected.key
                parent.content ?= []
                parent.content.push detail
                resources = traverse @data.tree
                @data.action = "edit"
                Resource.put 
                  origin: configuration.sites.origin
                  name: "branch"
                  bindings: { site, branch }
                  content: resources
                undefined
          ]
        ]
      ]
      R.event "change", [
        R.within "dashkite-navigation-creator", [
          F.flow [
            R.description
            R.call ({ site, branch }, el, { detail } ) ->
              if detail.action?
                @data.action = detail.action
              else
                parent = lookup @data.tree, @data.selected.key
                parent.content ?= []
                parent.content.push detail
                resources = traverse @data.tree
                @data.action = "edit"
                Resource.put 
                  origin: configuration.sites.origin
                  name: "branch"
                  bindings: { site, branch }
                  content: resources
                undefined
          ]
        ]
      ]
      R.event "change", [
        R.within "dashkite-text-creator", [
          F.flow [
            R.description
            R.call ({ site, branch }, el, { detail } ) ->
              if detail.action?
                @data.action = detail.action
              else
                parent = lookup @data.tree, @data.selected.key
                parent.content ?= []
                parent.content.push detail
                resources = traverse @data.tree
                @data.action = "edit"
                Resource.put 
                  origin: configuration.sites.origin
                  name: "branch"
                  bindings: { site, branch }
                  content: resources
                undefined
          ]
        ]
      ]
      R.event "change", [
        R.within "dashkite-image-creator", [
          F.flow [
            R.description
            R.call ({ site, branch }, el, { detail } ) ->
              if detail.action?
                @data.action = detail.action
              else
                parent = lookup @data.tree, @data.selected.key
                parent.content ?= []
                parent.content.push detail
                resources = traverse @data.tree
                @data.action = "edit"
                Resource.put 
                  origin: configuration.sites.origin
                  name: "branch"
                  bindings: { site, branch }
                  content: resources
                undefined
          ]
        ]
      ]
      R.event "change", [
        R.within "dashkite-link-creator", [
          F.flow [
            R.description
            R.call ({ site, branch }, el, { detail } ) ->
              if detail.action?
                @data.action = detail.action
              else
                parent = lookup @data.tree, @data.selected.key
                parent.content ?= []
                parent.content.push detail
                resources = traverse @data.tree
                @data.action = "edit"
                Resource.put 
                  origin: configuration.sites.origin
                  name: "branch"
                  bindings: { site, branch }
                  content: resources
                undefined
          ]
        ]
      ]
      R.event "change", [
        R.within "dashkite-icon-creator", [
          F.flow [
            R.description
            R.call ({ site, branch }, el, { detail } ) ->
              if detail.action?
                @data.action = detail.action
              else
                parent = lookup @data.tree, @data.selected.key
                parent.content ?= []
                parent.content.push detail
                resources = traverse @data.tree
                @data.action = "edit"
                Resource.put 
                  origin: configuration.sites.origin
                  name: "branch"
                  bindings: { site, branch }
                  content: resources
                undefined
          ]
        ]
      ]
      R.event "change", [
        R.within "dashkite-page-editor", [
          F.flow [
            R.description
            R.call ({ site, branch }, el, { detail } ) ->
              key_change detail, get_root detail.key
              assign @data.tree, @data.selected.key, detail
              resources = traverse @data.tree
              Resource.put 
                origin: configuration.sites.origin
                name: "branch"
                bindings: { site, branch }
                content: resources
              @data.selected.key = detail.key 
          ]
        ]
      ]
      R.event "change", [
        R.within "dashkite-layout-editor", [
          F.flow [
            R.description
            R.call ({ site, branch }, el, { detail } ) ->
              key_change detail, get_root detail.key
              assign @data.tree, @data.selected.key, detail
              resources = traverse @data.tree
              Resource.put 
                origin: configuration.sites.origin
                name: "branch"
                bindings: { site, branch }
                content: resources
              @data.selected.key = detail.key 
          ]
        ]
      ]
      R.event "change", [
        R.within "dashkite-navigation-editor", [
          F.flow [
            R.description
            R.call ({ site, branch }, el, { detail } ) ->
              key_change detail, get_root detail.key
              assign @data.tree, @data.selected.key, detail
              resources = traverse @data.tree
              Resource.put 
                origin: configuration.sites.origin
                name: "branch"
                bindings: { site, branch }
                content: resources
              @data.selected.key = detail.key 
          ]
        ]
      ]
      R.event "change", [
        R.within "dashkite-text-editor", [
          F.flow [
            R.description
            R.call ({ site, branch }, el, { detail } ) ->
              key_change detail, get_root detail.key
              assign @data.tree, @data.selected.key, detail
              resources = traverse @data.tree
              Resource.put 
                origin: configuration.sites.origin
                name: "branch"
                bindings: { site, branch }
                content: resources
              @data.selected.key = detail.key 
          ]
        ]
      ]
      R.event "change", [
        R.within "dashkite-image-editor", [
          F.flow [
            R.description
            R.call ({ site, branch }, el, { detail } ) ->
              key_change detail, get_root detail.key
              assign @data.tree, @data.selected.key, detail
              resources = traverse @data.tree
              Resource.put 
                origin: configuration.sites.origin
                name: "branch"
                bindings: { site, branch }
                content: resources
              @data.selected.key = detail.key 
          ]
        ]
      ]
      R.event "change", [
        R.within "dashkite-link-editor", [
          F.flow [
            R.description
            R.call ({ site, branch }, el, { detail } ) ->
              key_change detail, get_root detail.key
              assign @data.tree, @data.selected.key, detail
              resources = traverse @data.tree
              Resource.put 
                origin: configuration.sites.origin
                name: "branch"
                bindings: { site, branch }
                content: resources
              @data.selected.key = detail.key 
          ]
        ]
      ]
      R.event "change", [
        R.within "dashkite-icon-editor", [
          F.flow [
            R.description
            R.call ({ site, branch }, el, { detail } ) ->
              key_change detail, get_root detail.key
              assign @data.tree, @data.selected.key, detail
              resources = traverse @data.tree
              Resource.put 
                origin: configuration.sites.origin
                name: "branch"
                bindings: { site, branch }
                content: resources
              @data.selected.key = detail.key 
          ]
        ]
      ]
      R.event "focusout", [
        R.within "input[name='name']", [
          F.flow [
            R.description
            R.call ({ site, branch }, el, event ) -> 
              gadget = lookup @data.tree, @data.selected.key
              if el.value == ""
                el.value = gadget.name
              else
                if el.value != gadget.name
                  gadget.name = el.value
                  key_change gadget, get_root gadget.key
                  assign @data.tree, @data.selected.key, gadget
                  @data.tree = sort @data.tree
                  resources = traverse @data.tree
                  Resource.put 
                    origin: configuration.sites.origin
                    name: "branch"
                    bindings: { site, branch }
                    content: resources
                  undefined
          ]
        ]
      ]
      R.click "a[name='add-page']", [
        R.call ->
          action: "create page"
        R.assign "data"
      ]
      R.click "a[name='add-child']", [
        R.call ->
          action: "create gadget"
        R.assign "data"
      ]
      R.click "a[name='delete']", [
        R.description
        R.call ({ site, branch }) ->
          if @data.selected.type == "image"
            { target } = lookup @data.tree, @data.selected.key
            if target.startsWith media_origin
              [ prefix, path ] = target.split media_origin
              [ root, site_, branch_, address, name ] = path[1..].split "/"
              Resource.delete 
                origin: configuration.sites.origin
                name: "media"
                bindings: { site: site_, branch: branch_, address, name}
          delete_resource @data.tree, @data.selected.key
          resources = if (Object.keys @data.tree).length > 0 then traverse @data.tree else []
          Resource.put 
            origin: configuration.sites.origin
            name: "branch"
            bindings: { site, branch }
            content: resources
          selected: undefined
          action: ""
        R.assign "data"
      ]
      R.click "a[name='disabled-add-child']", [
        -> ""
      ]
       R.click "a[name='disabled-delete']", [
        -> ""
      ]
      R.click "a[name='disabled-add-page']", [
        -> ""
      ]
      # R.event "change", [
      #   R.matches "vellum-splitter", [
      #       # TODO save event detail (sizes) to project
      #   ]
      # ]
    ]
  ]