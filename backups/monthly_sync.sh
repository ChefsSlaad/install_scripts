#!/bin/bash

# config
SOURCES_FOTO="/media/fotos/"
SOURCES_DOCS="/media/documents"
BACKUP_FOTO_DIR="/home/fotosync/fotos/monthly"
BACKUP_DOCS_DIR="/home/fotosync/documents/monthly"
LOGFILE="/home/fotosync/logfile"
IGNORE_FILES="MY*"

# abort if any of the commands fail
set -e

mount $SOURCES_FOTO
mount $SOURCES_DOCS

todays=$(date +'%Y-%m') # nicely sortable names for backups



#####################
#    backup Fotos   #
#####################


cd $BACKUP_FOTO_DIR
last=$(ls -r | head -1)

if [ $todays == $last ]
then echo ${BACKUP_FOTO_DIR}/$last allready complete >> $LOGFILE
     exit 0
fi

# check is SOURCE dir contains files. if not, exit the script
if    ls -1qA $SOURCES_FOTO | grep -q .
then  ! echo $(date) monthly foto backup started >> $LOGFILE
else  echo $(date) monthly foto backup failed $SOURCES_FOTO is empty >> $LOGFILE
      exit 1
fi

ionice -c 3 nice -n +19 rsync -aq --link-dest=${BACKUP_FOTO_DIR}/${last} $SOURCES_FOTO $BACKUP_FOTO_DIR/${todays} >> $LOGFILE

echo $(date) monthly foto backup complete >> $LOGFILE


##############################################
##           DOCUMENTS BACKUP               ##
##############################################
cd $BACKUP_DOCS_DIR
last=$(ls -r | head -1)

if [ $todays == $last ]
then echo ${BACKUP_DOCS_DIR}/$last allready complete >>$LOGFILE
     exit 0
fi

# check is SOURCE dir contains files. if not, exit the script
if    ls -1qA $SOURCES_DOCS | grep -q .
then  ! echo $(date) monthly documents backup started >> $LOGFILE
else  echo $(date) monthly documents backup failed $SOURCES_DOCS is empty >> $LOGFILE
      exit 1
fi

ionice -c 3 nice -n +19 rsync -aq  --exclude '${IGNORE_FILES}' --link-dest=${BACKUP_DOCS_DIR}/${last} $SOURCES_DOCS $BACKUP_DOCS_DIR/${todays} >> $LOGFILE

echo $(date) monthly documents backup complete >> $LOGFILE
