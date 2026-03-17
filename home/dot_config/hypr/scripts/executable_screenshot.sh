#!/bin/bash
activewindow=$(hyprctl activewindow -j | jq '.initialTitle' | sed 's/"//g')
timestamp=$(date +"%F_%H%M%S")

# Check if homedata directory exists
if [ ! -d ~/homedata/home ]; then
  notify-send -u critical "Screenshot Error" "Directory ~/homedata/home does not exist. rclone is probably not running."
  exit 1
fi

folder=~/homedata/home/Daniel/Screenshots/$(date +"%Y-%m")
mkdir -p $folder
flameshot gui -p $folder/${activewindow}_${timestamp} \
  -c
# grimblast --notify --freeze copysave area
