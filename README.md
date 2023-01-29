# RealityKit-Maker

## Small repository for test of the macos realitykit




### App:

Load a "movie" and convert it into an "AR Model" (usdz) file.
-- See documentation folder for a demonstration

### Some details - but outdated maybe

- current  code creates a uiview,
- allows to select a file / folder and
- either shows the usdz file or
- converts a image folder  (if folder is selected) or
- converts a movie into separate images, if a movie file is selected
- opens model files directly

### Good sample image is kermit 
  https://github.com/snavely/bundler_sfm/tree/master/examples/kermit

Artistic stuff can be very easily made using a timelapse movie (see ![example-bone](/assets/appView-2.png))
The tool currently limits movies to 100 frames (if needed spread over the entire movie by skipping some frames) ![example-bone](/assets/appView.png)




### TODO
 postprocess (drag/resize/rotate model before saving it)
 Add mask manipulator for images
 fix why images loaded using a folder work differently than if I use my media-provider
   - gravity not yet loaded, but that cannot really be it
   - heic depth not yet laoded, but that also cannot be it
   


