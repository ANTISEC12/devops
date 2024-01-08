#!/bin/bash
# scpserver=192.168.0.73
# basename=confluence
# base=/root/mntnew/${basename}
backup() {
    log " ${base} Function Not Defined"
}
runJobBackupDaily() {
    log "runjob"
    backup
    rsync -avz ${base}/backup/*.{tar.gz,tar} ${base}/backup/daily/
    rsyncToServerBackupDaily
    # syncs3 "daily"
    removingFilesOlderDaily
    rm ${base}/backup/*.{tar.gz,tar}
}

runJobBackupWeekly() {
    log "runJobBackupweekly"
    backup
    rsync -avz ${base}/backup/*.{tar.gz,tar} ${base}/backup/weekly/
    rsyncToServerBackupWeekly
    syncs3 "weekly"
    removingFilesOlderWeekly
    rm ${base}/backup/*.{tar.gz,tar}
}

runJobBackupTest() {
    log "runjob"
}
restore() {
    log " ${base}  Function Not Defined"
}

rsyncToServerBackupDaily() {
    #check Count Files
    # mkdir $(date +%Y%m%d)
    #removingFilesOlder
    log "rsyncToServerBackupDaily"
    rsync -avz -e ssh ${base}/backup/*.{tar.gz,tar} root@${scpserver}:/backup/${basename}/daily/
}

syncs3() {
    #weekly or  daily
    to=$1
    endpoint=https://s3.ir-thr-at1.arvanstorage.com
    mybucket=bck201
    from=${base}/backup/${1}/
    aws --endpoint-url ${endpoint} s3 sync ${from} s3://${mybucket}/backup/${basename}/${1}/ --exclude '*' --include '*.tar.gz' --include '*.tar'
}

rsyncToServerBackupWeekly() {
    log "rsyncToSerrsyncToServerBackupWeeklyverBackup"
    rsync -avz -e ssh ${base}/backup/*.{tar.gz,tar} root@${scpserver}:/backup/${basename}/weekly/
}
removingFilesOlderDaily() {
    #https://askubuntu.com/questions/589210/removing-files-older-than-7-days
    #timestamp=$(date --date='-8 day')
    #touch -d "${timestamp}" ${base}/backup/some_file.tar.gz
    log "check  Files Older"
    log  "ls ${base}/backup/ | wc -l"
    countFiles=$(ls ${base}/backup/daily | wc -l)
    if [ $countFiles -gt 6 ]; then
        log "removingFilesOlder"
        find ${base}/backup/daily/ -type f -mtime +2 -name '*.tar.gz'
        find ${base}/backup/daily/ -type f -mtime +2 -name '*.tar.gz' -execdir rm -- '{}' \;
        find ${base}/backup/daily/ -type f -mtime +2 -name '*.tar'
        find ${base}/backup/daily/ -type f -mtime +2 -name '*.tar' -execdir rm -- '{}' \;
    fi
}
removingFilesOlderWeekly() {
    #https://askubuntu.com/questions/589210/removing-files-older-than-7-days
    #timestamp=$(date --date='-8 day')
    #touch -d "${timestamp}" ${base}/backup/some_file.tar.gz
    log "check  Files Older"
    countFiles=$(ls ${base}/backup/ | wc -l)
    if [ $countFiles -gt 4 ]; then
        log "removingFilesOlder"
        find ${base}/backup/weekly/ -type f -mtime +14 -name '*.tar.gz'
        find ${base}/backup/weekly/ -type f -mtime +14 -name '*.tar.gz' -execdir rm -- '{}' \;
        find ${base}/backup/weekly/ -type f -mtime +14 -name '*.tar'
        find ${base}/backup/weekly/ -type f -mtime +14 -name '*.tar' -execdir rm -- '{}' \;
    fi
}
log() {
    dt=$(date +"%m-%d-%y %T")
    printf "$dt $basename => $1\n"
}
menu() {

    PS3='Please enter your choice: '
    options=("backup" "scp from server" "restore" "runJobBackupDaily"
        "rsyncToServerBackupDaily" "removingFilesOlderDaily" "rsyncToServerBackupWeekly"
        "removingFilesOlderWeekly"
        "runJobBackupTest"
        "Quit")
    if [ -z "$1" ]; then
        clear
        select inopt in "${options[@]}"; do
            runcase $inopt
        done
    else
        runcase $1
    fi
}

runcase() {
    opt=$1
    case $opt in
    "backup")
	backup
	;;
    "backupDaily")
        backupDaily
        ;;
    "backupWeekly")
        backupWeekly
        ;;
    "runJobBackupDaily")
        runJobBackupDaily
        ;;
    "runJobBackupWeekly")
        runJobBackupWeekly
        ;;
    "removingFilesOlderDaily")
        removingFilesOlderDaily
        ;;
    "rsyncToServerBackupDaily")
        rsyncToServerBackupDaily
        ;;
    "rsyncToServerBackupWeekly")
        rsyncToServerBackupWeekly
        ;;
    "runJobBackupTest")
        runJobBackupTest
        ;;
    "restore")
        restore
        ;;
    "scp from server")
        #todo: fix ${basename}
        rm -f ./backup/*.*
        scp -P 2222 -r root@${scpserver}:${base}/backup/*.* ./backup/
        ls ./backup/
        ;;
    "Quit")
        break
        ;;
    *) echo "invalid option $REPLY" ;;
    esac
}
