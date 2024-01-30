import * as Meta from "@dashkite/joy/metaclass"
import * as Obj from "@dashkite/joy/object"

import * as K from "@dashkite/katana/async"

import * as R from "@dashkite/rio"

import * as Posh from "@dashkite/posh"

import Image from "#helpers/image"

import html from "./html"
import waiting from "./waiting"
import css from "./css"

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

      R.submit [
        R.render waiting
        R.form
        R.description
        R.assign
        Image.upload
        K.poke Obj.tag "target"
        R.assign
        K.poke ({ name, key, target }) ->
          { name, key, type: "image", target }
        R.dispatch "change"
      ]

      R.click "a[name='cancel']", [
        # TODO is this how we want to do this?
        #      why not Route.back?
        K.push -> action: "create gadget"
        R.dispatch "change"
      ]
    ]
  ]
