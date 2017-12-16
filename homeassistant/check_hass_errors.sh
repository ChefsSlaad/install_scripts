#!/bin/bash

set -x

HASS_LOGDIR="/home/homeassistant/.homeassistant"
HASS_FILENAME="home-assistant.log"
HASS_LOGFILE=${HASS_LOGDIR}/${HASS_FILENAME}
SCRIPT_LOG="/home/homeassistant/.homeassistant/chk_config.log"

LOG_CONDITION="Update\sof\sswitch\.[A-Za-z]*\sis\staking\sover\s10\sseconds"

LOG_DATE_TIME=$(date +'%Y-%m-%d_%H:%M:%S')
CP_LOGFILE="cp $HASS_LOGFILE $HASS_LOGDIR/$LOG_DATE_TIME-$HASS_FILENAME"

NO_ERRORS=$(grep -c $LOG_CONDITION $HASS_LOGFILE)

#echo $CP_LOGFILE

#runuser homeassistant '$CP_LOGFILE'
echo "$LOG_DATE_TIME hass log check started" >>$SCRIPT_LOG

if [ $NO_ERRORS -gt "10" ];then
        echo "    over 10 errors found in $HASS_FILENAME" >>$SCRIPT_LOG
        runuser -u homeassistant cp ${HASS_LOGFILE} ${HASS_LOGDIR}/${LOG_DATE_TIME}-${HASS_FILENAME} >> $SCRIPT_LOG
        systemctl restart homeassistant@homeassistant.service 
fi
