#!/bin/bash
# script um den Backupserver zu stoppen.
# by AME 05/2023
#----------------------- Variablen --------------------------------------------------------------------------------#
# SET-X damit die Ausfuehrung protokolliert wird
# set -x
storeid=backup                                                  # Variable - um welches Storage handelt es sich
mac="00:08:9B:CC:DD:02"                                         # MAC Adresse des PBS-Servers
host="192.168.0.23"                                             # Hostname oder IP des PBS-Servers
remoteuser="admin"                                              # username @ host / for qnap = admin
nic=enp2s0                                                      # Netzwerk-Karte über die WOL läuft
sleep_after_powerdown=5m                                        # Zeit die nach dem power down gewartet werden muß bis das NAS wirklich unten ist
serverDownTimeout=120                                           # max. time we wait after sleep_after_powerdown for the server


######################################################################
#
######################################################################
bring_server_down () {
    
    pvesm set $storeid --disable 1                                   # deaktiviere den Speicher
    ssh $remoteuser@$host -p 22 /sbin/poweroff < /dev/null &         # Backupserver wird heruntergefahren
    sleep $sleep_after_powerdown                                     # give the server the time to stop

    timeout_server_down_start=`date +%s` 
    until [[ "$xact" == "true" ]]; do     
      if ping -c 1 $host &> /dev/null; then      
        xact=true
        return 0                                              
      fi
      
      timeout_server_down_end=`date +%s`
      runtime=$((timeout_server_down_end-timeout_server_down_start))
      if (( runtime > serverDownTimeout )); then
        echo "Fehler: Der Backup-Server konnte nicht heruntegefahren werden."
        return 1
      fi    
      sleep 10s
    done    
}


#----------------------- Programmablauf ---------------------------------------------------------------------------#
echo "der Backup-Server fährt nun runter, das Backup-Storage wird ausgehangen"

bring_server_down 

if [[ "$?" != 0 ]]; then
  echo "Fehler: Der Backup-Server konnte nicht heruntergefahren werden."
  exit 1                                              # gibt`s einen Fehler im Log
else
  echo "Der Backup-Server wurde erfolgreich heruntergefahren."
   exit 0
fi          
