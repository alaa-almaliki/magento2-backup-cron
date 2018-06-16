#!/usr/bin/env bash

# @author Alaa Al-Maliki <alaa.almaliki@gmail.com>
#
#
# This script can be used as a cron to back up magento db, media and code.
# Although it is tested and works without exception,
# the script can not take any responsibility for any issues caused by it's usage.
# Please test locally and thoroughly before using on live server


# If the script is placed to a different directory other than Magento project directory
# uncomment the following line and add the correct path to Magento project directory
# Example: cd /var/www/html/magento2
#cd /path/to/project

PHP=$(which php)

MAGENTO_BIN=$PWD/bin/magento
[[ ! -f ${MAGENTO_BIN} ]] && echo "File $MAGENTO_BIN is not found" && exit 1;

CURRENT_MAINTENANCE_STATUS=$(${PHP} ${MAGENTO_BIN} maintenance:status | grep 'Status:')
[[ ${CURRENT_MAINTENANCE_STATUS} = 'Status: maintenance mode is active' ]] && echo "Can not backup, maintenance is enabled" && exit 0;


# to disable any of the backups, simply assign the variable to false
CAN_BACKUP_DB=true
CAN_BACKUP_MEDIA=true
CAN_BACKUP_CODE=false

BACKUP_DB_DIR=$HOME/backup/db
BACKUP_MEDIA_DIR=$HOME/backup/media
BACKUP_CODE_DIR=$HOME/backup/code

# For cleanup, the number of backups to keep, so to delete the rest as they will take disk space
# default is to keep 3 copies, it can be edited below
BACKUP_TO_KEEP=3

# clean up directories
cleanup()
{
    CLEANUP_DIR=$1
    FILES_TO_KEEP=$(($2+1))
    if [[ -d ${CLEANUP_DIR} ]]; then
        PREVIOUS_DIR=$PWD
        cd ${CLEANUP_DIR}
        NUMBER_OF_FILES=$(ls -1 | wc -l)
        if [[ ${NUMBER_OF_FILES} -gt $2 ]]; then
            ls -tQ | tail -n+${FILES_TO_KEEP} | xargs rm
        fi
        cd ${PREVIOUS_DIR}
    fi
}

# Backup Database
if [[ ${CAN_BACKUP_DB} = true ]]; then
    [[ ! -d ${BACKUP_DB_DIR} ]] && mkdir -p ${BACKUP_DB_DIR}
    DB_PATH=$(${PHP} -f ${MAGENTO_BIN} setup:backup --db |  grep 'DB backup path' | awk 'NF>1{print $NF}')
    mv ${DB_PATH} ${BACKUP_DB_DIR}/
    echo -e "Moved $DB_PATH to $BACKUP_DB_DIR\n"
    cleanup ${BACKUP_DB_DIR} ${BACKUP_TO_KEEP}
fi

# Backup Media
if [[ ${CAN_BACKUP_MEDIA} = true ]]; then
    [[ ! -d ${BACKUP_MEDIA_DIR} ]] && mkdir -p ${BACKUP_MEDIA_DIR}
    MEDIA_PATH=$(${PHP} -f ${MAGENTO_BIN} setup:backup --media |  grep 'Media backup path' | awk 'NF>1{print $NF}')
    mv ${MEDIA_PATH} ${BACKUP_MEDIA_DIR}/
    echo -e "Moved $MEDIA_PATH to $BACKUP_MEDIA_DIR\n"
    cleanup ${BACKUP_MEDIA_DIR} ${BACKUP_TO_KEEP}
fi

# Backup Code
if [[ ${CAN_BACKUP_CODE} = true ]]; then
    [[ ! -d ${BACKUP_CODE_DIR} ]] && mkdir -p ${BACKUP_CODE_DIR}
    CODE_PATH=$(${PHP} -f ${MAGENTO_BIN} setup:backup --code |  grep 'Code backup path' | awk 'NF>1{print $NF}')
    mv ${CODE_PATH} ${BACKUP_CODE_DIR}/
    echo -e "Moved $CODE_PATH to $BACKUP_CODE_DIR\n"
    cleanup ${BACKUP_CODE_DIR} ${BACKUP_TO_KEEP}
fi
