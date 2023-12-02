#!/bin/sh

CSS_PATH="resources/app/public/css/foundry2.css"
CSS_URL="https://raw.githubusercontent.com/ChefsSlaad/install_scripts/master/foundryvtt/css_patch.css"

log "Downloading CSS from $CSS_URL"
curl -s -o /tmp/foundry_login.css $CSS_URL

log "Applying CSS patch"
cat /tmp/foundry_login.css >> $CSS_PATH
