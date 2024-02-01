import * as Fn from "@dashkite/joy/function"
import * as K from "@dashkite/katana/async"
import * as Obj from "@dashkite/joy/object"
import HTTP from "@dashkite/rio-vega"

# This doesn't seem to be used
# import { MediaType } from "@dashkite/media-type"
# i think image.type has the content-type

Image = 
  upload: 
    Fn.flow [
      # K.push Address.generate
      K.poke Obj.tag "address"
      # set content type somehow?
      HTTP.post [ 
        # get upload URL from response
        HTTP.json [
          K.pop ({ upload }) ->
            # TODO fetch -- see below
        ]
      ]
    ]


# upload: K.push ({ site, root, branch, name, image }) ->
#   # TODO how is this used?
#   key = root + "/" + name
#   address = await generateAddress()
#   { upload, download } = await Resource.post 
#     origin: configuration.sites.origin
#     name: "media"
#     bindings: { site, branch, address, name: image.name }
#     content: contentType: image.type
#   await fetch upload, 
#     method: "PUT"
#     headers: "content-type": image.type
#     body: await image.arrayBuffer()
#   # return the download URL
#   download

export default Image
export { Image }