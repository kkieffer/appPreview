#!/bin/bash

#
# This script offers two features, --capture or --convert
#
#  When run in capture:   appPreview.sh --capture
#
#  The script tries to capture video from the booted iOS simulator.  CTRL-C terminates the video capture.
#  The guidelines require a 15 to 30 second video.  The captured file is called capture.mp4 and placed in the working dir.
#
#  When run in convert:   appPreview.sh --convert capture.mp4 ipad --landscape
#
#  The video is converted to a format acceptable to the AppStore. The argument following the video file to convert must
#  be either ipad, iphone, or iphonex depending on what resolution you are uploading. If --landscape is given, the video
#  is in landscape, otherwise the default is portrait.
#
#  ffmpeg is required to convert video, with h.264 lib.
#	1.  Download ffmpeg
#   2.  ./configure --enable-libx264 
#	3.  make, sudo make install
#
#   To install h.264 lib, use macports:
#	port install x264
#
#
#   The 0.1 seconds of video are trimmed because the conversion seems to produce a strange artifact on the first frame
#


function count {

	cnt=0
	while [[ 1 == 1 ]]; do 
		sleep 1
		cnt=$((cnt + 1))
		echo "Captured $cnt sec"
	done
	

}


if [[ -z "$1" ]]; then

        echo "usage: appPreview --capture or --convert <file> <ipad or iphone or iphonex> options: --landscape"
        exit 0

fi

if [[ "$1" == "--capture" ]]; then
		
	echo "Capture video in 3 seconds...(CTRL-C to finish)"
	videofile="capture.mp4"
	
	sleep 3
	echo "Capture Started, Ctrl-C to finish"	
	count &	
	xcrun simctl io booted recordVideo $videofile --codec h264 --force
	
	kill $!
	exit 0
	
fi

if [[ "$1" != "--convert" ]]; then
	echo "Must specify --capture or --convert"
	exit 0
fi


height=0
width=0

#Default dimensions are in portrait

if [[ "$3" == "ipad" ]]; then
	
	width=1200
	height=1600

elif [[ "$3" == "iphone" ]]; then

	width=1080
	height=1920

elif [[ "$3" == "iphonex" ]]; then

	width=886
	height=1920
	
fi

if [[ width == 0 || height == 0 ]]; then
	echo "Missing ipad or iphone or iphonex"
    exit 0
fi


if [[ "$4" == "--landscape" ]]; then
	ratio="$height:$width"
else
	ratio="$width:$height"
fi

ratiolabel=$(sed 's|:|x|g' <<< $ratio)
echo "Converted Ratio will be $ratiolabel"

videofile="$2"
rescaleFile="/tmp/Rescale-$ratiolabel-capture.mp4"
withAudioFile="Audio+Rescale-$ratiolabel-$videofile"



echo "Converting..."
sleep 1


ffmpeg -ss 00:00:00.1 -i $videofile -vf scale=$ratio,setsar=1:1 -c:v libx264 -crf 1 -profile:v high -level:v 4.0 -r 30 -c:a copy $rescaleFile

ffmpeg -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 -i $rescaleFile -shortest -c:v copy -c:a aac $withAudioFile

#rm $videofile
rm $rescaleFile

echo "Complete -> File is: $withAudioFile"





