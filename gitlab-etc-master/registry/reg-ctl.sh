#!/bin/bash
scpserver=94.101.185.31
backup(){
    docker compose stop registry
    docker compose run --rm registry-backup
    docker compose start registry
}
restore(){
    docker compose stop registry
    docker compose run --rm registry-restore
    docker compose start registry
}
menu(){
clear
PS3='Please enter your choice: '
options=("backup" "scp from server" "restore" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "backup")
          backup
            ;;
        "scp from server")
            rm -f ./backup/*.*
            scp -P 2222 -r root@${scpserver}:/home/ubuntu/mnt/registry/backup/*.* ./backup/
            ls ./backup/
            ;;
        "restore")
            restore
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
}
menu
