#!/bin/bash

# config
SOURCE_FOTO="/media/fotos/"
SOURCE_DOCS="/media/documents/"
BACKUP_FOTO_DAILY="/home/fotosync/fotos/daily"
BACKUP_FOTO_MONTH="/home/fotosync/fotos/monthly"
BACKUP_DOCS_DAILY="/home/fotosync/documents/daily"
BACKUP_DOCS_MONTH="/home/fotosync/documents/monthly"
LOGFILE="/home/fotosync/backup.log"
BACKUP_OUT="/home/fotosync/output.log"

# IGNORE_FILES="/home/fotosync/scripts/excludes"

# mount the file systems if not mounted yet
mount $SOURCE_FOTO
mount $SOURCE_DOCS

# abort if any of the commands fail
set -e

# check if another backup is running (such as a previous backup job)
# and exit accordingly
if   pgrep rsync > /dev/null
then  echo $(date)  backup did not start, another backup job is allready running >>$LOGFILE
      exit 1
fi

this_daily=$(date +'%Y-%m-%d') # nicely sortable names for backup
this_month=$(date +'%Y-%m')  # nicely sortable names for backup

echo   > $BACKUP_OUT

################################################
###              FOTO BACKUP                 ###
################################################

# check is SOURCE dir contains files. if not, exit the script
if    ls -1qA $SOURCES_FOTO | grep -q .
then  ! echo $(date) daily foto backup started >> $LOGFILE
else  echo $(date) daily foto backup failed $SOURCES_FOTO is empty >>$LOGFILE
      exit 1
fi

last_foto_month=$(ls -r ${BACKUP_FOTO_MONTH} | head -1) # the last monthly backup dir
last_foto_daily=$(ls -r ${BACKUP_FOTO_DAILY} | head -1) # the last monthly backup dir
foto_to_delete=$(ls -r ${BACKUP_FOTO_DAILY} | tail -n +7)# will keep the last 6 backups

if [ $last_foto_month -ne $this_month ]
then 
     echo $(date) starting monthly foto backup >>$LOGFILE
     ionice -c 3 nice -n +19 rsync -aq --link-dest=${BACKUP_FOTO_MONTH}/${last_foto_month} $SOURCES_FOTO $BACKUP_FOTO_MONTH/${this_month} >> $LOGFILE

elif [ $last_foto_daily -ne $this_daily ]
then 
     echo $(date) starting daily foto backup >>$LOGFILE
     ionice -c 3 nice -n +19 rsync -aq --link-dest=${BACKUP_FOTO_DAILY}/${last_foto_daily} $SOURCES_FOTO $BACKUP_FOTO_DAILY/${this_daily} >> $LOGFILE
     chmod u+w -Rf ${BACKUP_FOTO_DAILY}/*
     [ -z "$foto_to_delete" ] || rm -rf $foto_to_delete

else 
     echo $(date) fotos are up to date >>$LOGFILE
fi

echo $(date) fotos backup finished >> $LOGFILE


################################################
###            DOCUMENT BACKUP               ###
################################################

# check is SOURCE dir contains files. if not, exit the script
if    ls -1qA $SOURCES_DOCS | grep -q .
then  ! echo $(date) daily docs backup started >> $LOGFILE
else  echo $(date) daily docs backup failed $SOURCES_DOCS is empty >>$LOGFILE
      exit 1
fi

last_docs_month=$(ls -r ${BACKUP_DOCS_MONTH} | head -1) # the last monthly backup dir
last_docs_daily=$(ls -r ${BACKUP_DOCS_DAILY} | head -1) # the last monthly backup dir
docs_to_delete=$(ls -r ${BACKUP_DOCS_DAILY} | tail -n +7)# will keep the last 6 backups

if [ $last_docs_month -ne $this_month ]
then 
     echo $(date) starting monthly docs backup >>$LOGFILE
     ionice -c 3 nice -n +19 rsync -aq --link-dest=${BACKUP_DOCS_MONTH}/${last_docs_month} $SOURCES_DOCS $BACKUP_DOCS_MONTH/${this_month} >> $LOGFILE

elif [ $last_foto_daily -ne $this_daily ]
then 
     echo $(date) starting daily docs backup >>$LOGFILE
     ionice -c 3 nice -n +19 rsync -aq --link-dest=${BACKUP_DOCS_DAILY}/${last_docs_daily} $SOURCES_DOCS $BACKUP_DOCS_DAILY/${this_daily} >> $LOGFILE
     chmod u+w -Rf ${BACKUP_DOCS_DAILY}/*
     [ -z "$docs_to_delete" ] || rm -rf $docs_to_delete

else 
     echo $(date) docs are up to date >>$LOGFILE
fi

echo $(date) docs backup finished >> $LOGFILE
