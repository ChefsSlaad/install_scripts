#!/bin/bash

xset s noblank
xset s off
xset -dpms

sed -i 's/"exited_cleanly":false/"exited_cleanly":true/' /home/pi/.config/chromium/Default/Preferences
sed -i 's/"exit_type":"Crashed"/"exit_type":"Normal"/' /home/pi/.config/chromium/Default/Preferences

/usr/bin/chromium-browser --noerrdialogs --disable-infobars --kiosk https://de-wagnertjes.duckdns.org/lovelace/hall?kiosk &


while true; do
   xdotool key f5 
   sleep 21600 #six hours
done

