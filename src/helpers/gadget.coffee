import { resolve, lookup } from "@dashkite/sites-resource"

Gadget =

  # TODO this needs to get the key from the description
  # in order to perform the lookup
  get: Fn.pipe [
    HTTP.get
    K.poke resolve
    K.pop lookup
  ]

export default Gadget
export { Gadget }