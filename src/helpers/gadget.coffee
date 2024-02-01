import * as Fn from "@dashkite/joy/function"
import * as K from "@dashkite/katana/async"
import HTTP from "@dashkite/rio-vega"
import { resolve, lookup } from "@dashkite/sites-resource"

Gadget =

  # TODO this needs to get the key from the description
  # in order to perform the lookup
  get: HTTP.get [
    HTTP.json [
      K.poke resolve
      K.pop lookup
    ]
  ]

export default Gadget
export { Gadget }