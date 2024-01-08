#!/bin/bash
# Author: Remi Mikalsen
# The original script can be found in https://github.com/remimikalsen/theawesomegarage
#
# Script to back up container volumes
#
# Notes on recovering
#   Stop your container
#   Recover your volumes
#     docker volume create my_volume (unless already created by docker-compose)
#     docker run --rm -v my_volume:/restore -v /local/backup/dir:/backup ubuntu bash -c "cd /restore && yes | rm -rf . && tar -xzf /backup/my_volume.tar”

#    docker run --rm -v my_volume:/restore -v /local/backup/dir:/backup ubuntu bash -c "cd /restore && yes | rm -rf  /restore/* && tar -xzf /backup/my_volume.tar"

#  docker run --rm -v jira:/restore	-v /root/bck:/backup  ubuntu bash -c "cd /restore && yes | rm -rf  /restore/* && tar -xzf /backup/home_gitlab- .tar" 
#   Start your image 


#
# Configuration
#

# To identify the server in emails
HOST=production-server

# Who should receive logs by email
RECIPIENT=your-email@example.com

# Base dir to which make back-ups 
BACKUP_DIR=/docker-volume-backups

# Container > Volumes to back up
declare -A CONTAINER_VOLUMES

# CONTAINER_VOLUMES=(
#   ["passbolt passbolt_db"]="home-server_docker_passbolt_db home-server_docker_passbolt_gpg home-server_docker_passbolt_images"
#   ["nextcloud-db nextcloud-redis nextcloud-app nextcloud-web"]="home-server_docker_nextcloud-db home-server_docker_nextcloud-db-logs home-server_docker_nextcloud-redis home-server_docker_nextcloud-html"
# )

CONTAINER_VOLUMES=(
["jira postgresql"]="jira-bin jira-data jira-postgresqldata"
["confluence-7-13 confluencePostgresql" ]="confluence-install confluence-home confluence-postgres"
)


# Start
#
SECONDS=0
FAILURE=0
MESSAGE="docker volume backup status follows"


for containers in "${!CONTAINER_VOLUMES[@]}"; 
do 

  docker stop ${containers} &> /dev/null

  volumes=( ${CONTAINER_VOLUMES[${containers}]} )
  for volume in "${volumes[@]}";
  do
    docker run --rm -v ${volume}:/volume -v ${BACKUP_DIR}:/backup ubuntu bash -c "cd /volume && tar -zcf /backup/${volume}.tar ." &> /dev/null
    FAILED=$?
    if [ $FAILED != "0" ]
    then
      FAILURE=1
      MESSAGE="${MESSAGE}\n\nFailed backing up:\n${volume}"
    else
      ELAPSED="$(($SECONDS / 3600))h $((($SECONDS / 60) % 60))m $(($SECONDS % 60))s"
      MESSAGE="${MESSAGE}\n\nSuccessfully backed up volume ${volume}. Elapsed ${ELAPSED}"
    fi

  done

  docker start ${containers} &> /dev/null

done

if [ $FAILURE != "0" ]
then
  echo -e "${MESSAGE} ${HOST} - FAILURE in docker volume backup"
else
  echo -e "${MESSAGE} ${HOST} - docker volume backup ran without errors" 
fi
#
# End
#
