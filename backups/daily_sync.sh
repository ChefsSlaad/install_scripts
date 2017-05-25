#!/bin/bash

# config
SOURCES_FOTO="/media/fotos/"
SOURCES_DOCS="/media/documents/"
BACKUP_FOTO_DIR="/home/fotosync/fotos/daily"
BACKUP_FOTO_LYNC="/home/fotosync/fotos/monthly"
BACKUP_DOCS_DIR="/home/fotosync/documents/daily"
BACKUP_DOCS_LYNC="/home/fotosync/documents/monthly"
LOGFILE="/home/fotosync/logfile"
BACKUP_OUT="/home/fotosync/output"
IGNORE_FILES="MY*"
# IGNORE_FILES="/home/fotosync/scripts/excludes"

# mount the file systems if not mounted yet
mount $SOURCES_FOTO
mount $SOURCES_DOCS

# abort if any of the commands fail
set -e


# check if anothe backup is running (such as monthly backup)
# and exit accordingly
if   pgrep rsync > /dev/null
then  echo $(date) daily backup could not start, a backup job is allready running >>$LOGFILE
      exit 1
fi

# check is SOURCE dir contains files. if not, exit the script
if    ls -1qA $SOURCES_FOTO | grep -q .
then  ! echo $(date) daily foto backup started >> $LOGFILE
else  echo $(date) daily foto backup failed $SOURCES_FOTO is empty >>$LOGFILE
      exit 1
fi


todays=$(date +'%Y-%m-%d') # nicely sortable names for backups

echo   > $BACKUP_OUT

################################################
###              FOTO BACKUP                 ###
################################################

cd $BACKUP_FOTO_LYNC
last=$(ls -r | head -1)

cd $BACKUP_FOTO_DIR
to_delete=$(ls -r | tail -n +7) # will keep the last 6 backups

ionice -c 3 nice -n +19 rsync -aq --link-dest=${BACKUP_FOTO_LYNC}/${last} $SOURCES_FOTO $BACKUP_FOTO_DIR/${todays} >> $LOGFILE

# now we're safe to remove the old one(s)
# [ -z "$to_delete" ] = test if length $to_delete is ZERO OR remove dir in $to_delete

[ -z "$to_delete" ] || rm -rf $to_delete
chmod u+w -Rf *

echo $(date) daily fotos backup complete >> $LOGFILE


################################################
###            DOCUMENT BACKUP               ###
################################################

if    ls -1qA $SOURCES_DOCS | grep -q .
then  ! echo $(date) daily documents backup started >> $LOGFILE
else  echo $(date) daily documents backup failed $SOURCES_FOTO is empty >>$LOGFILE
      exit 1
fi

cd $BACKUP_DOCS_LYNC
last=$(ls -r | head -1)

cd $BACKUP_DOCS_DIR
to_delete=$(ls -r | tail -n +7) # will keep the last 6 backups

ionice -c 3 nice -n +19 rsync -av --exclude '${IGNORE_FILES}' --link-dest=${BACKUP_DOCS_LYNC}/${last} $SOURCES_DOCS $BACKUP_DOCS_DIR/${todays} >> $BACKUP_OUT
# ionice -c 3 nice -n +19 rsync -av --exclude-from '${IGNORE_FILES}' --link-dest=${BACKUP_DOCS_LYNC}/${last} $SOURCES_DOCS $BACKUP_DOCS_DIR/${todays} >> $BACKUP_OUT

# now we're safe to remove the old one(s)
[ -z "$to_delete" ] || rm -rf $to_delete
chmod u+w -Rf *

echo $(date) daily documents backup complete >> $LOGFILE
