#!/bin/bash

# config

SOURCE_DOCS="/media/documents/School"
BACKUP_DOCS_DAILY="/home/fotosync/test/daily"
BACKUP_DOCS_MONTH="/home/fotosync/test/monthly"
LOGFILE="/home/fotosync/test_backup.log"
BACKUP_OUT="/home/fotosync/test_output.log"

# IGNORE_FILES="/home/fotosync/scripts/excludes"

# mount the file systems if not mounted yet
mount $SOURCE_DOCS

# abort if any of the commands fail
set -e

# check if another backup is running (such as a previous backup job)
# and exit accordingly

if   pgrep rsync > /dev/null
then  echo $(date)  backup did not start, another backup job is allready running >>$LOGFILE
      exit 1
fi

today=$(date +'%Y-%m-%d-%H-%M') # nicely sortable names for backup
this_month=$(date +'%Y-%m')  # nicely sortable names for backup

echo   >> $BACKUP_OUT



################################################
###            DOCUMENT BACKUP               ###
################################################

# check is SOURCE dir contains files. if not, exit the script
if    ls -1qA $SOURCES_DOCS | grep -q .
then  ! echo $(date) docs backup started >> $LOGFILE
else  echo $(date) daily docs backup failed $SOURCES_DOCS is empty >>$LOGFILE
      exit 1
fi

last_docs_month=$(ls -r ${BACKUP_DOCS_MONTH} | head -1) # the last monthly backup dir
last_docs_daily=$(ls -r ${BACKUP_DOCS_DAILY} | head -1) # the last daily backup dir
docs_to_delete=$(ls -r ${BACKUP_DOCS_DAILY} | tail -n +7) # will keep the last 6 backups


echo "variables"
echo "last_docs_month   $last_docs_month"
echo "last_docs_daily   $last_docs_daily"
echo "docs_to_delete    $docs_to_delete"
echo "today             $today"
echo "this_month        $this_month"

echo "SOURCE_DOCS       $SOURCE_DOCS"
echo "BACKUP_DOCS_DAILY $BACKUP_DOCS_DAILY"
echo "BACKUP_DOCS_MONTH $BACKUP_DOCS_MONTH"
echo "LOGFILE           $LOGFILE"
 
#echo "contents of SOURCE_DOCS"
#ls -l $SOURCE_DOCS 


if [ "$last_docs_month" != "$this_month" ]; then
     echo $(date) starting monthly docs backup >>$LOGFILE
     mkdir ${BACKUP_DOCS_MONTH}/${this_month}
     ionice -c 3 nice -n +19 rsync -av --link-dest=${BACKUP_DOCS_MONTH}/${last_docs_month} $SOURCES_DOCS ${BACKUP_DOCS_MONTH}/${this_month} >> $BACKUP_OUT

elif [ "$last_docs_daily" != "$today" ]; then
     echo $(date) starting daily docs backup >>$LOGFILE
     echo starting backup
     mkdir ${BACKUP_DOCS_DAILY}/${today}
     ionice -c 3 nice -n +19 rsync -av --link-dest=${BACKUP_DOCS_DAILY}/${last_docs_daily} ${SOURCES_DOCS} ${BACKUP_DOCS_DAILY}/${today}
     chmod u+w -Rf ${BACKUP_DOCS_DAILY}/*
     [ -z "$docs_to_delete" ] || rm -rf $docs_to_delete

else 
     echo $(date) docs are up to date >>$LOGFILE
fi

echo $(date) docs backup finished >> $LOGFILE
