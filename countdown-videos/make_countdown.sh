#!/bin/bash

# Default color is blue if not provided
COLOR=${1:-blue}

FIRST_CHAR=${COLOR:0:1}
FIRST_CHAR_UPPER=$(echo $FIRST_CHAR | tr '[:lower:]' '[:upper:]')

COLOR="BLACK"
FIRST_CHAR_UPPER="K"


# Create a monochrome background video
ffmpeg -f lavfi -i color=c=$COLOR:s=1280x720:d=11 -c:v libx264 -t 11 -pix_fmt yuv420p background.mp4

# Create countdown videos
for i in {9..0}
do
    #ffmpeg -i background.mp4 -vf "drawtext=text='$i':fontcolor=white:fontsize=100:x=(w-text_w)/2:y=(h-text_h)/2:enable='between(t,$((i-1)),$i)'" -c:v libx264 -t 11 -pix_fmt yuv420p -y countdown$i.mp4
    ffmpeg -i background.mp4 -vf "drawtext=text='$FIRST_CHAR_UPPER $i':fontcolor=white:fontsize=100:x=(w-text_w)/2:y=(h-text_h)/2" -c:v libx264 -frames:v 25 -pix_fmt yuv420p -y countdown$i.mp4
done

# Create a file list for concatenation
for i in {9..0}
do
    echo "file 'countdown$i.mp4'" >> mylist.txt
done

# Concatenate the videos
ffmpeg -f concat -safe 0 -i mylist.txt -c copy final_countdown.mp4

# Optional: Clean up intermediate files
rm background.mp4
rm countdown{9..0}.mp4
rm mylist.txt
mv final_countdown.mp4 ${COLOR}_final_countdown.mp4

echo "Countdown video created: ${COLOR}_final_countdown.mp4"

