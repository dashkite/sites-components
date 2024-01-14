# This doesn't seem to be used
# import { MediaType } from "@dashkite/media-type"
# TODO where does this belong?
Image =
  # upload: K.push ({ site, root, branch, name, image }) ->
  upload: K.push ({ site, branch, image }) ->
    # TODO how is this used?
    # key = root + "/" + name
    address = await generateAddress()
    { upload, download } = await Resource.post 
      origin: configuration.sites.origin
      name: "media"
      bindings: { site, branch, address, name: image.name }
      content: contentType: image.type
    await fetch upload, 
      method: "PUT"
      headers: "content-type": image.type
      body: await image.arrayBuffer()
    # return the download URL
    download

export default Image
export { Image }