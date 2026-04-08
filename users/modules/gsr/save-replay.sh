#!/bin/sh -e

pkill -f -SIGUSR1 gpu-screen-recorder && sleep 0.5 && systemctl --user restart gsr-replay.service && notify-send -t 1500 -u low -- "gpu screen recorder" "replay saved"