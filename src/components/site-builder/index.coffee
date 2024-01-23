import * as F from "@dashkite/joy/function"
import * as K from "@dashkite/katana/async"
import * as Meta from "@dashkite/joy/metaclass"

import { Resource } from "@dashkite/vega-client"

import * as R from "@dashkite/rio"

import * as Posh from "@dashkite/posh"

import * as Site from "@dashkite/sites-resource"

import configuration from "#configuration"

import html from "./html"
import css from "./css"

setDragImage = do ({ image } = {}) ->
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
          tree = Site.resolve resources
          console.log "TREE", tree
          tree ?= []
          { sizes: [ 20, 60, 20 ], tree, site, branch }
        R.assign "data"
        R.render html
      ]
      R.event "click", [
        R.within "vellum-drawer > .label, .file > .label", [
          F.flow [
            R.call (el ) -> 
              selected: 
                key: el.dataset.key
                type: el.dataset.type
                name: el.dataset.name
              action: "edit"
              page: Site.findPage @data.tree, el.dataset.key
            R.assign "data"
          ]
        ]
      ]
      R.event "mousedown", [
        R.within "input[name='name']", [
          F.flow [
            R.call (el, event ) -> 
              if @data.selected?.key != el.dataset.key
                event.stopPropagation()
                event.preventDefault()
          ]
        ]
      ]
      R.event "dragstart", [
        R.within ".folder, .file", [
          F.flow [
            R.call (el, event ) ->
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
            R.call (el, event ) -> 
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
            R.call (el, event ) -> 
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
            R.call (el, event ) -> 
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
            R.call ({ site, branch }, _, event ) -> 
              event.preventDefault()
              { parent, before } = @drop
              if parent?
                dropped = Site.lookup @data.tree, @dragged.key
                if parent == ""
                  # @data.tree[ detail.key ] = detail
                else
                  newParent = Site.lookup @data.tree, parent
                  newParent.content ?= []
                  oldParent = Site.lookup @data.tree, Site.getRoot dropped.key
                  oldParent.content = oldParent.content.filter ( element ) -> element.key != dropped.key
                  Site.keyChange dropped, parent
                  if before == "placeholder"
                    newParent.content.push dropped
                  else
                    index = newParent.content.findIndex ( element ) -> element.key == before
                    newParent.content.splice index, 0, dropped
                  Site.assign @data.tree, newParent.key, newParent
                  @data.tree = Site.sort @data.tree
                  @data.selected.key = dropped.key
                  @data.page = find_page @data.tree, dropped.key
                resources = Site.traverse @data.tree
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
            R.call (el, event ) -> 
              @dropzone.push el.dataset.key
              event.preventDefault()
          ]
        ]
      ]
      R.event "dragleave", [
        R.within ".label, .placeholder", [
          F.flow [
            R.call (el ) -> 
              el.classList.remove "drop"
          ]
        ]
      ]
      R.event "dragend", [
        R.within ".folder, .file", [
          F.flow [
            R.call (el ) -> 
              el.classList.remove "drag"
          ]
        ]
      ]
      R.event "drop", [
        R.within ".label, .placeholder", [
          F.flow [
            R.call (el ) -> 
              el.classList.remove "drop"
          ]
        ]
      ]
      R.event "dragleave", [
        R.within ".folder", [
          F.flow [
            R.call ( _ ) ->
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
                  parent = Site.lookup @data.tree, @data.selected.key
                  parent.content ?= []
                  parent.content.push detail
                  resources = Site.traverse @data.tree
                else
                  @data.tree[ detail.key ] = detail
                  @data.tree = Site.sort @data.tree
                  resources = Site.traverse @data.tree
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
                parent = Site.lookup @data.tree, @data.selected.key
                parent.content ?= []
                parent.content.push detail
                resources = Site.traverse @data.tree
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
                parent = Site.lookup @data.tree, @data.selected.key
                parent.content ?= []
                parent.content.push detail
                resources = Site.traverse @data.tree
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
                parent = Site.lookup @data.tree, @data.selected.key
                parent.content ?= []
                parent.content.push detail
                resources = Site.traverse @data.tree
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
                parent = Site.lookup @data.tree, @data.selected.key
                parent.content ?= []
                parent.content.push detail
                resources = Site.traverse @data.tree
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
                parent = Site.lookup @data.tree, @data.selected.key
                parent.content ?= []
                parent.content.push detail
                resources = Site.traverse @data.tree
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
                parent = Site.lookup @data.tree, @data.selected.key
                parent.content ?= []
                parent.content.push detail
                resources = Site.traverse @data.tree
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
              Site.keyChange detail, Site.getRoot detail.key
              Site.assign @data.tree, @data.selected.key, detail
              resources = Site.traverse @data.tree
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
              Site.keyChange detail, Site.getRoot detail.key
              Site.assign @data.tree, @data.selected.key, detail
              resources = Site.traverse @data.tree
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
              Site.keyChange detail, Site.getRoot detail.key
              Site.assign @data.tree, @data.selected.key, detail
              resources = Site.traverse @data.tree
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
              Site.keyChange detail, Site.getRoot detail.key
              Site.assign @data.tree, @data.selected.key, detail
              resources = Site.traverse @data.tree
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
              Site.keyChange detail, Site.getRoot detail.key
              Site.assign @data.tree, @data.selected.key, detail
              resources = Site.traverse @data.tree
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
              Site.keyChange detail, Site.getRoot detail.key
              Site.assign @data.tree, @data.selected.key, detail
              resources = Site.traverse @data.tree
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
              Site.keyChange detail, Site.getRoot detail.key
              Site.assign @data.tree, @data.selected.key, detail
              resources = Site.traverse @data.tree
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
            R.call ({ site, branch }, el, _ ) -> 
              gadget = Site.lookup @data.tree, @data.selected.key
              if el.value == ""
                el.value = gadget.name
              else
                if el.value != gadget.name
                  gadget.name = el.value
                  Site.keyChange gadget, Site.getRoot gadget.key
                  Site.assign @data.tree, @data.selected.key, gadget
                  @data.tree = Site.sort @data.tree
                  resources = Site.traverse @data.tree
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
            { target } = Site.lookup @data.tree, @data.selected.key
            if target.startsWith media_origin
              [ , path ] = target.split media_origin
              [ , site_, branch_, address, name ] = path[1..].split "/"
              Resource.delete 
                origin: configuration.sites.origin
                name: "media"
                bindings: { site: site_, branch: branch_, address, name}
          Site.deleteResource @data.tree, @data.selected.key
          resources = if (Object.keys @data.tree).length > 0 then Site.traverse @data.tree else []
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