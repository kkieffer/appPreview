# appPreview
This is a useful bash script to capture and convert videos from the iOS simulator for use on the App Store.

## Capture

```appPreview.sh --capture```

The script tries to capture video from the booted iOS simulator.  CTRL-C terminates the video capture. 
The guidelines require a 15 to 30 second video.  The captured file is called capture.mp4 and placed in the working dir.

## Convert

```appPreview.sh --convert capture.mp4 ipad --landscape```

The video is converted to a format acceptable to the AppStore. The argument following the video file to convert must be either ipad, iphone, or iphonex depending on what resolution you are uploading. In addition to scaling the video, the frame rate is set to 30fps, the H.264 level is set to 4, and the first 0.1 seconds of video are trimmed because the conversion seems to produce a strange artifact on the first frame.  A blank audio track is also added.

If --landscape is given, the video should be in landscape, otherwise the default is portrait.

## Requirements

ffmpeg is required to convert video, with h.264 lib.

1.  Download ffmpeg
2.  ./configure --enable-libx264 
3.  make
4.  sudo make install

To install h.264 lib, use macports:
```port install x264```

