#!/bin/bash
scpserver=192.168.0.43
basename=gitlab
base=/opt/${basename}
#backup_name=1659627879_2022_08_04_14.6.0
backup_name=1678877308_2023_03_15_15.9.0
#1660057686_2022_08_09_14.6.0_gitlab_backup.tar
source ./base.sh
backup() {
    #rm -f -R ./gitlab/backup/*
    log "start backup"
    docker exec -t gitlab_gitlab_ce_1  rm -f -R  /var/opt/gitlab/backups/*
    docker exec -t gitlab_gitlab_ce_1 gitlab-backup create 
   # docker-compose  -f "/root/mntnew/docker-compose.yml" cp    gitlab_ce:/var/opt/gitlab/backups/. ${base}/backup/
   docker cp  gitlab_gitlab_ce_1:/var/opt/gitlab/backups/. ${base}/backup/
    log "finish backup"
}
restore() {
    log "start restore"
    docker cp ${base}/backup/restore/${backup_name}_gitlab_backup.tar gitlab_gitlab_ce_1:/var/opt/gitlab/backups/
    docker exec -it gitlab_gitlab_ce_1 chown git:git /var/opt/gitlab/backups/${backup_name}_gitlab_backup.tar
    docker exec -it gitlab_gitlab_ce_1 gitlab-ctl stop puma
    docker exec -it gitlab_gitlab_ce_1 gitlab-ctl stop sidekiq
    docker exec -it gitlab_gitlab_ce_1 gitlab-ctl status
    docker exec -it gitlab_gitlab_ce_1 gitlab-backup restore BACKUP=${backup_name}
    docker restart gitlab_gitlab_ce_1
    log "finish restore"
}
menu $1
