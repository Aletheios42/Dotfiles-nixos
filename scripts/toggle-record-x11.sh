#!/usr/bin/env bash

if pgrep ffmpeg; then
    pkill ffmpeg
else
    ffmpeg -f x11grab -i "$(slop -f "%wx%h+%x+%y")" "@carpeta_grabaciones@/$(date +%s).mp4" &
fi
