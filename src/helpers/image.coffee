import * as Fn from "@dashkite/joy/function"
import * as Obj from "@dashkite/joy/object"
import HTTP from "@dashkite/rio-vega"

# This doesn't seem to be used
# import { MediaType } from "@dashkite/media-type"
# i think image.type has the content-type

Image = Fn.flow [
  K.push generateAddress
  K.poke Obj.tag "address"
  # set content type somehow?
  HTTP.post
  # get upload URL from response
  # TODO how do we set this as the resource for the upload?
  # set body to image.arrayBuffer()
  HTTP.put

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