#!/bin/bash

# config
SOURCE_DOCS="/media/documents/Albelli Fotoboeken"
BACKUP_DOCS_DAILY="/home/fotosync/test/daily"
BACKUP_DOCS_MONTH="/home/fotosync/test/monthly"
LOGFILE="/home/fotosync/backup.log"
BACKUP_OUT="/home/fotosync/output.log"
TODAY=$(date +'%Y-%m-%d-%H-%M') # nicely sortable names for backup
THIS_MONTH=$(date +'%Y-%m')  # nicely sortable names for backup

# sample entry of /etc/fstab
# //192.168.1.130/fotos /media/fotos                    cifs    username=foto_sync,password=Foto_1234,uid=1001,x-systemd.automount,noauto,noexec   0       0
# //192.168.1.130/Documents /media/documents            cifs    username=foto_sync,password=Foto_1234,uid=1001,x-systemd.automount,noauto,noexec   0       0

# mount the file systems if not mounted yet

mount $SOURCE_DOCS

# abort if any of the commands fail
set -e

################################################
###              FOTO BACKUP                 ###
################################################

cd ${BACKUP_FOTO_DAILY}

# check is SOURCE dir contains files. if not, exit the script
if    ls -1qA $SOURCE_FOTO | grep -q .
then  ! echo "$(date) foto backup started"
else  echo "$(date) daily foto backup failed $SOURCE_FOTO is empty"
      exit 1
fi

LAST_FOTO_MONTH=$(ls -r ${BACKUP_FOTO_MONTH} | head -1) # the last monthly backup dir
LAST_FOTO_DAILY=$(ls -r ${BACKUP_FOTO_DAILY} | head -1) # the last daily backup dir
FOTO_TO_DELETE=$(ls -r ${BACKUP_FOTO_DAILY} | tail -n +7) # will keep the last 6 backups

LAST_FOTO_PATH_D="${BACKUP_FOTO_DAILY}/${LAST_FOTO_DAILY}"
TODY_FOTO_PATH_D="${BACKUP_FOTO_DAILY}/${TODAY}"
LAST_FOTO_PATH_M="${BACKUP_FOTO_MONTH}/${LAST_FOTO_MONTH}"
TODY_FOTO_PATH_M="${BACKUP_FOTO_MONTH}/${THIS_MONTH}"

# echo "variables"

# echo "SOURCE_FOTO       $SOURCE_FOTO"
# echo "BACKUP_FOTO_DAILY $BACKUP_FOTO_DAILY"
# echo "BACKUP_FOTO_MONTH $BACKUP_FOTO_MONTH"
# echo "LAST_FOTO_PATH    $LAST_FOTO_PATH"
# echo "TODY_FOTO_PATH    $TODY_FOTO_PATH"
# echo "LOGFILE           $LOGFILE"
# echo ""
# echo "LAST_FOTO_MONTH   $LAST_FOTO_MONTH"
# echo "LAST_FOTO_DAILY   $LAST_FOTO_DAILY"
# echo "TODAY             $TODAY"
# echo "THIS_MONTH        $THIS_MONTH"
# echo "FOTO_TO_DELETE    $FOTO_TO_DELETE"

if [ -z "${LAST_FOTO_DAILY}" ]; then
    echo $(date) initial foto backup started >> $LOGFILE
    ionice -c 3 nice -n +19 rsync -a --progress ${SOURCE_FOTO} ${TODY_FOTO_PATH_M}
    ionice -c 3 nice -n +19 rsync -a --link-dest=${TODY_FOTO_PATH_M} ${SOURCE_FOTO} ${TODY_FOTO_PATH_D} >> $BACKUP_OUT
elif [ "${LAST_FOTO_MONTH}" != "${THIS_MONTH}" ]; then
    echo $(date) monthly foto backup started >> $LOGFILE
    ionice -c 3 nice -n +19 rsync -aq --link-dest=${LAST_FOTO_PATH_M} ${SOURCE_FOTO} ${TODY_FOTO_PATH_M} >> $BACKUP_OUT

elif [ "${LAST_FOTO_DAILY}" != "${TODAY}" ]; then
    echo $(date) daily foto backup started >> $LOGFILE
    ionice -c 3 nice -n +19 rsync -aq --link-dest=${LAST_FOTO_PATH_D} ${SOURCE_FOTO} ${TODY_FOTO_PATH_D} >> $BACKUP_OUT

else
    echo "$(date) fotos are up to date" >> $LOGFILE
fi

#chmod u+w -Rf ${BACKUP_FOTO_DAILY}/*
[ -z "$FOTO_TO_DELETE" ] || rm -rf $FOTO_TO_DELETE

echo $(date) docs backup finished  >> $LOGFILE


################################################
###            DOCUMENT BACKUP               ###
################################################

cd ${BACKUP_DOCS_DAILY}

# check is SOURCE dir contains files. if not, exit the script
if    ls -1qA $SOURCE_DOCS | grep -q .
then  ! echo "$(date) docs backup started"
else  echo "$(date) daily docs backup failed $SOURCE_DOCS is empty"
      exit 1
fi

LAST_DOCS_MONTH=$(ls -r ${BACKUP_DOCS_MONTH} | head -1) # the last monthly backup dir
LAST_DOCS_DAILY=$(ls -r ${BACKUP_DOCS_DAILY} | head -1) # the last daily backup dir
DOCS_TO_DELETE=$(ls -r ${BACKUP_DOCS_DAILY} | tail -n +7) # will keep the last 6 backups

LAST_DOCS_PATH_D="${BACKUP_DOCS_DAILY}/${LAST_DOCS_DAILY}"
TODY_DOCS_PATH_D="${BACKUP_DOCS_DAILY}/${TODAY}"
LAST_DOCS_PATH_M="${BACKUP_DOCS_MONTH}/${LAST_DOCS_MONTH}"
TODY_DOCS_PATH_M="${BACKUP_DOCS_MONTH}/${THIS_MONTH}"

echo "variables"

echo "SOURCE_DOCS       $SOURCE_DOCS"
echo "BACKUP_DOCS_DAILY $BACKUP_DOCS_DAILY"
echo "BACKUP_DOCS_MONTH $BACKUP_DOCS_MONTH"
echo "LAST_DOCS_PATH    $LAST_DOCS_PATH"
echo "TODY_DOCS_PATH    $TODY_DOCS_PATH"
echo "LOGFILE           $LOGFILE"
echo ""
echo "LAST_DOCS_MONTH   $LAST_DOCS_MONTH"
echo "LAST_DOCS_DAILY   $LAST_DOCS_DAILY"
echo "TODAY             $TODAY"
echo "THIS_MONTH        $THIS_MONTH"
echo "DOCS_TO_DELETE    $DOCS_TO_DELETE"

if [ -z "${LAST_DOCS_DAILY}" ]; then
    echo $(date) initial documents backup started  >> $LOGFILE
    ionice -c 3 nice -n +19 rsync -a --progress ${SOURCE_DOCS} ${TODY_DOCS_PATH_M}
    ionice -c 3 nice -n +19 rsync -a --link-dest=${TODY_DOCS_PATH_M} ${SOURCE_DOCS} ${TODY_DOCS_PATH_D}
elif [ "${LAST_DOCS_MONTH}" != "${THIS_MONTH}" ]; then
    echo $(date) monthly documents backup started >> $LOGFILE
    ionice -c 3 nice -n +19 rsync -aq --link-dest=${LAST_DOCS_PATH_M} ${SOURCE_DOCS} ${TODY_DOCS_PATH_M}

elif [ "${LAST_DOCS_DAILY}" != "${TODAY}" ]; then
    echo $(date) daily documents backup started >> $LOGFILE
    ionice -c 3 nice -n +19 rsync -aq --link-dest=${LAST_DOCS_PATH_D} ${SOURCE_DOCS} ${TODY_DOCS_PATH_D}

else
    echo $(date) documents are up to date >> $LOGFILE
fi

#chmod u+w -Rf ${BACKUP_DOCS_DAILY}/*
[ -z "$DOCS_TO_DELETE" ] || rm -rf $DOCS_TO_DELETE

echo $(date) docs backup finished >> $LOGFILE
