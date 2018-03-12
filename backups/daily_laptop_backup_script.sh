#!/bin/bash

# config
SOURCE_FOTO="/media/fotos/"
SOURCE_DOCS="/media/documents/"
BACKUP_FOTO_DAILY="/home/fotosync/fotos/daily"
BACKUP_FOTO_MONTH="/home/fotosync/fotos/monthly"
BACKUP_DOCS_DAILY="/home/fotosync/documents/daily"
BACKUP_DOCS_MONTH="/home/fotosync/documents/monthly"
DOCS_TO_IGNORE="{\"My Music\",\"My Pictures\",\"My Videos\"}"
LOGFILE="/home/fotosync/backup.log"
BACKUP_OUT="/home/fotosync/output.log"
docs_return="back-up failed"
foto_return="back-up failed"

TODAY=$(date +'%Y-%m-%d') # nicely sortable names for backup
THIS_MONTH=$(date +'%Y-%m')  # nicely sortable names for backup


# sample entry of /etc/fstab
# //192.168.1.180/fotos /media/fotos                    cifs    vers=1.0,username=foto_sync,password=Foto_1234,uid=1001,x-systemd.automount,noauto,noexec   0       0
# //192.168.1.180/Documents /media/documents            cifs    vers=1.0,username=foto_sync,password=Foto_1234,uid=1001,x-systemd.automount,noauto,noexec   0       0
# mount the file systems if not mounted yet
if grep -qs $SOURCE_DOCS /proc/mounts; then
    mount $SOURCE_DOCS
fi

if grep -qs $SOURCE_FOTO /proc/mounts; then
    mount $SOURCE_FOTO
fi


# abort if any of the commands fail
# set -e

# check if another backup is running (such as monthly backup)
# and exit accordingly
if [ -n "$(pgrep rsync)" ]; then  
    echo $(date) daily backup could not start, a backup job is allready running >>$LOGFILE
    docs_return="in progress"
    foto_return="in progress"
    /home/fotosync/mqtt_send.py "home/server/sync-docs" ${docs_return}
    /home/fotosync/mqtt_send.py "home/server/sync-foto" ${foto_return}
    exit 0
fi

################################################
###              FOTO BACKUP                 ###
################################################

cd ${BACKUP_FOTO_DAILY}

# check is SOURCE dir contains files. if not, exit the script
if ls -1qA $SOURCE_FOTO | grep -q .; then  
    echo "$(date) foto backup started"  >> $LOGFILE
else  echo "$(date) daily docs backup failed $SOURCE_FOTO is empty"  >> $LOGFILE
    foto_return="$SOURCE_FOTO is empty"
    /home/fotosync/mqtt_send.py "home/server/sync-foto" ${foto_return}
    exit 1
fi

LAST_FOTO_MONTH=$(ls -r ${BACKUP_FOTO_MONTH} | head -1) # the last monthly backup dir
FOTO_TO_DELETE=$(ls -r ${BACKUP_FOTO_DAILY} | tail -n +7) # will keep the last 6 backups
LAST_FOTO_DAILY=$(ls -r ${BACKUP_FOTO_DAILY} | head -1) # the last daily backup dir

LAST_FOTO_PATH_D="${BACKUP_FOTO_DAILY}/${LAST_FOTO_DAILY}"
TODY_FOTO_PATH_D="${BACKUP_FOTO_DAILY}/${TODAY}"
LAST_FOTO_PATH_M="${BACKUP_FOTO_MONTH}/${LAST_FOTO_MONTH}"
TODY_FOTO_PATH_M="${BACKUP_FOTO_MONTH}/${THIS_MONTH}"

if [ -z "${LAST_FOTO_DAILY}" ]; then
    echo $(date) initial fotos backup started  >> $LOGFILE
    foto_return="daily backup started"
    ionice -c 3 nice -n +19 rsync -a --progress ${SOURCE_FOTO}/ ${TODY_FOTO_PATH_M}/
    ionice -c 3 nice -n +19 rsync -a --link-dest=${TODY_FOTO_PATH_M}/ ${SOURCE_FOTO}/ ${TODY_FOTO_PATH_D}/ >> $BACKUP_OUT
elif [ "${LAST_FOTO_MONTH}" != "${THIS_MONTH}" ]; then
    echo $(date) monthly fotos backup started >> $LOGFILE
    ionice -c 3 nice -n +19 rsync -aq --link-dest=${LAST_FOTO_PATH_M}/ ${SOURCE_FOTO}/ ${TODY_FOTO_PATH_M}/ >> $BACKUP_OUT
    foto_return="monthly backup started"
elif [ "${LAST_FOTO_DAILY}" != "${TODAY}" ]; then
    echo $(date) daily fotos backup started >> $LOGFILE
    ionice -c 3 nice -n +19 rsync -aq --link-dest=${LAST_FOTO_PATH_D}/ ${SOURCE_FOTO}/ ${TODY_FOTO_PATH_D}/ >> $BACKUP_OUT
    foto_return="daily backup started"
else
    echo $(date) fotos are up to date >> $LOGFILE
    foto_return="fotos are up to date"
fi

chmod --recursive u+w  ${BACKUP_FOTO_DAILY}/*
[ -z "$FOTO_TO_DELETE" ] || rm -rf $FOTO_TO_DELETE

echo $(date) fotos backup finished >> $LOGFILE
/home/fotosync/mqtt_send.py "home/server/sync-foto" ${foto_return}



################################################
###            DOCUMENT BACKUP               ###
################################################

cd ${BACKUP_DOCS_DAILY}

# check is SOURCE dir contains files. if not, exit the script
if ls -1qA $SOURCE_DOCS | grep -q .; then
     echo "$(date) documents backup started" >> $LOGFILE
else echo "$(date) daily docs backup failed $SOURCE_DOCS is empty" >> $LOGFILE
      docs_return="$SOURCE_DOCS is empty"
      /home/fotosync/mqtt_send.py "home/server/sync-docs" ${docs_return}
      exit 1
fi

LAST_DOCS_MONTH=$(ls -r ${BACKUP_DOCS_MONTH} | head -1) # the last monthly backup dir
DOCS_TO_DELETE=$(ls -r ${BACKUP_DOCS_DAILY} | tail -n +7) # will keep the last 6 backups
LAST_DOCS_DAILY=$(ls -r ${BACKUP_DOCS_DAILY} | head -1) # the last daily backup dir

LAST_DOCS_PATH_D="${BACKUP_DOCS_DAILY}/${LAST_DOCS_DAILY}"
TODY_DOCS_PATH_D="${BACKUP_DOCS_DAILY}/${TODAY}"
LAST_DOCS_PATH_M="${BACKUP_DOCS_MONTH}/${LAST_DOCS_MONTH}"
TODY_DOCS_PATH_M="${BACKUP_DOCS_MONTH}/${THIS_MONTH}"

if [ -z "${LAST_DOCS_DAILY}" ]; then
    echo $(date) initial documents backup started  >> $LOGFILE
    ionice -c 3 nice -n +19 rsync -a --progress ${SOURCE_DOCS} ${TODY_DOCS_PATH_M}/
    ionice -c 3 nice -n +19 rsync -a --link-dest=${TODY_DOCS_PATH_M}/ ${SOURCE_DOCS}/ ${TODY_DOCS_PATH_D}/ >> $BACKUP_OUT
    docs_return="initial backup started"
elif [ "${LAST_DOCS_MONTH}" != "${THIS_MONTH}" ]; then
    echo $(date) monthly documents backup started >> $LOGFILE
    ionice -c 3 nice -n +19 rsync -aq --link-dest=${LAST_DOCS_PATH_M}/ ${SOURCE_DOCS} ${TODY_DOCS_PATH_M}/ >> $BACKUP_OUT
    docs_return="monthly backup started"
elif [ "${LAST_DOCS_DAILY}" != "${TODAY}" ]; then
    echo $(date) daily documents backup started >> $LOGFILE
    ionice -c 3 nice -n +19 rsync -aq --exclude=$DOCS_TO_IGNORE --link-dest=${LAST_DOCS_PATH_D}/ ${SOURCE_DOCS}/ ${TODY_DOCS_PATH_D}/ >> $BACKUP_OUT
    docs_return="daily backup started"
else
    echo $(date) documents are up to date >> $LOGFILE
    docs_return="everything up to date"
fi

chmod --recursive u+w ${BACKUP_DOCS_DAILY}/*
[ -z "$DOCS_TO_DELETE" ] || rm -rf $DOCS_TO_DELETE

echo $(date) documents backup finished >> $LOGFILE
/home/fotosync/mqtt_send.py "home/server/sync-docs" ${docs_return}
