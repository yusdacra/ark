#!/bin/sh -e

TMPFILE="/tmp/gsr-clip"
SHOT_DIR="$HOME/shots"
mkdir -p "$SHOT_DIR"

OUTFILE="$SHOT_DIR/$(date '+%Y-%m-%d_%H-%M-%S').mp4"
pkill -f -SIGINT gpu-screen-recorder && sleep 0.3 && mv -f $TMPFILE $OUTFILE && notify-send -t 1500 -u low -- "gpu screen recorder" "recording saved" && exit 0

AREA=$(slurp -d -f "%wx%h+%x+%y") || exit 0
gpu-screen-recorder -w "$AREA" -f 60 -a default_output -k av1 -c mp4 -bm cbr -q 16000 -o "$TMPFILE" > /tmp/gsr-screen.log 2>&1 &
notify-send -t 1500 -u low -- "gpu screen recorder" "recording area"
