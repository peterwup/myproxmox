#!/bin/bash
# script um den Backupserver zu starten.
# by AME 05/2023
#----------------------- Variablen --------------------------------------------------------------------------------#
# SET-X damit die Ausfuehrung protokolliert wird
#set -x
storeid=backup                                                  # Variable - um welches Storage handelt es sich
mac="00:08:9B:CC:DD:02"                                         # MAC Adresse des PBS-Servers
host="192.168.0.23"                                             # Hostname oder IP des PBS-Servers
remoteuser="admin"                                                                                      # username @ host / for qnap = admin
nic=enp2s0                                                      # Netzwerk-Karte über die WOL läuft
serverTimeout=300                                                                                               # maximum time till we assume that the server will not respond in seconds
storagetype=dir                                                                                                 # type of the storage "dir" or "" ... 
sleep_after_wakeup=8m                                           # Zeit die nach dem wakeup des servers gewartet wird bevor es weiter gehen soll
                                                                                                                                # mein QNAS brauch locker 5 Minuten bevor es nach dem start erreichbar ist

#----------------------- Programmablauf ---------------------------------------------------------------------------#

#
#
# Check if we can reach the server by ping and if the backup storage is mounted
# Returns:
#               2 = down = server is not reachable by ping
#       1 = inactive = server is reachable by ping but backup storage is not mounted
#       0 = active = server is up and storeg is mounted
is_server_up () {
    # cheks if the server is reachable and if the backup storage is mounted
        if ping -c 1 $host &> /dev/null; then                           # prüfe, ob der Backup-Server schon läuft
        echo "Der Backupserver läuft bereits"
                com=$(pvesm status --storage $storeid | tail -1);
        [[ "$com" =~ ($storeid+ +)($storagetype+ +)(active|disabled) ]];
                if [ "${BASH_REMATCH[3]}" == "active" ]; then  
                  return 0
                else
                  return 1
                fi
    else
                return 2
        fi
}

#################################

is_server_up
if [[ "$?" != 0 ]]; then
        # start the server by WOL
    /usr/sbin/etherwake -i $nic $mac     
    # wait till the server will be up
    sleep $sleep_after_wakeup
    pvesm set $storeid --disable 0          # der Storage wird enabled

        timeout_wakeup_start=`date +%s`                 # Startzeit die für das timeout benötigt wird. 
        until [[ "$act" == "true" ]]; do                                     # arbeite die loop-schleife ab bis die variable "ack" wahr ist
                is_server_up
                if [ "$?" == 0 ]; then
                  echo "Backup-Server ist jetzt erreichbar"
                  act=true
                  exit 0
                fi

                timeout_wakeup_end=`date +%s`                                                           # aktueller Zeitstempel in s
                runtime=$((timeout_wakeup_end-timeout_wakeup_start))            # wieviel Zeit ist vergangen in s 

                if (( runtime > serverTimeout )); then                     # wenn der Server nach serverTimeout sec. nicht erreichbar ist exit 1 e>
                        echo "ERROR Backup-Server ist nicht erreichbar"
                        sleep 1s
                        exit 1
                fi

                sleep 10s       
        done
fi
exit 0
