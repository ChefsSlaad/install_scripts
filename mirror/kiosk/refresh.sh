#!/bin/bash

echo "reloading screen"

export DISPLAY=":0"
BROWSER="chromium"
RELOAD_KEYS="ctrl+F5"

WID=$(xdotool search --onlyvisible --class $BROWSER|head -1)
xdotool windowactivate ${WID}
xdotool key $RELOAD_KEYS

echo "reload done"
