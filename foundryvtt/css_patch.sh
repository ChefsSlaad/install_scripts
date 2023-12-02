#!/bin/sh

CSS_PATH="resources/app/public/css/foundry2.css"
CSS_URL="https://github.com/ChefsSlaad/install_scripts/blob/ec4adc02eda799dd8e3a9fdae4fe8053d916e91c/foundryvtt/css_patch.css"

log "Downloading CSS from $CSS_URL"
curl -s -o /tmp/foundry_login.css $CSS_URL

log "Applying CSS patch"
cat /tmp/foundry_login.css >> $CSS_PATH
