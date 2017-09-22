#!/bin/bash

HASS_LOGDIR="/home/homeassistant/.homeassistant"
HASS_FILENAME="home-assistant.log"
HASS_LOGFILE=${HASS_LOGDIR}/${HASS_FILENAME}
LOG_CONDITION="Update\sof\sswitch\.[A-Za-z]*\sis\staking\sover\s10\sseconds"
LOG_DATE_TIME=$(date +'%Y-%m-%d_%H:%M:%S')
CP_LOGFILE="cp $HASS_LOGFILE $HASS_LOGDIR/$LOG_DATE_TIME-$HASS_FILENAME" #command to backup the logfile


NO_ERRORS=$(grep -c $LOG_CONDITION $HASS_LOGFILE)


if [ $NO_ERRORS -gt "10" ]
then    echo "error found"
        runuser -l homeassistant -c "$CP_LOGFILE"
        systemctl restart homeassistant@homeassistant.service 
fi
