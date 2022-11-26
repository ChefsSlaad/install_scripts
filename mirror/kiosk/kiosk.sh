#!/bin/bash
xset s noblank
xset s off
xset -dpms
sed -i 's/"exited_cleanly":false/"exited_cleanly":true/' /home/marc/.config/chromium/Default/Preferences
sed -i 's/"exit_type":"Crashed"/"exit_type":"Normal"/' /home/marc/.config/chromium/Default/Preferences

##/usr/bin/chromium-browser --kiosk --noerrdialogs --disable-session-crashed-bubble --disable-infobars --check-for-update-interval=604800  https://de-wagnertjes.nl/lovelace/hall?kiosk


unclutter -idle 0.5 &

