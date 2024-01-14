import { resolve, lookup } from "@dashkite/sites-resource"

Gadget =

  get: Fn.pipe [
    HTTP.get
    K.poke resolve
    K.pop lookup
  ]


export default Gadget
export { Gadget }