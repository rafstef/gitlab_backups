#!/bin/bash

GITLAB_CONFIGS_DIRECTORY="/var/opt/gitlab/backups/gitlab_configs" 
BACKUP_NAME=$(date +"%Y%m%d_%H%M_gitlab_configs")
GITLAB_BACKUPS_DIRECTORY="/var/opt/gitlab/backups"
LOGS=${GITLAB_BACKUPS_DIRECTORY}/last_backup.log

cd ${GITLAB_BACKUPS_DIRECTORY}

echo "START BACKUP $(date +"DAY %Y%m%d TIME: %H%M")" > ${LOGS} 2>&1

echo "COPY GITLAB CONFIG FILE" >> ${LOGS} 2>&1

mkdir -p ${GITLAB_CONFIGS_DIRECTORY} >> ${LOGS} 2>&1 &&\
	cp /etc/gitlab/gitlab.rb ${GITLAB_CONFIGS_DIRECTORY} >> ${LOGS} 2>&1 &&\
       	cp /etc/gitlab/gitlab-secrets.json ${GITLAB_CONFIGS_DIRECTORY} >> ${LOGS} 2>&1

echo "TAR GITLAB CONFIG FILE - REMOVE TEMP DIR" >> ${LOGS} 2>&1
tar -czvf ${BACKUP_NAME}.tar.gz --absolute-names ${GITLAB_CONFIGS_DIRECTORY} >> ${LOGS} 2>&1 &&\
        rm -rf ${GITLAB_CONFIGS_DIRECTORY} >> ${LOGS} 2>&1

echo "GITLAB BACKUP" >> ${LOGS} 2>&1
gitlab-backup create >> ${LOGS} 2>&1

echo "REMOVE GITLAB CONFIG OLDER THAN ONE WEEK" >> ${LOGS} 2>&1

find ${GITLAB_BACKUPS_DIRECTORY}/*.tar.gz -mtime +7 -exec rm {} \; >> ${LOGS} 2>&1

echo "STOP BACKUP $(date +"DAY: %Y%m%d TIME: %H%M")" >> ${LOGS} 2>&1
