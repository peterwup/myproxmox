#!/bin/bash
# script um den Backupserver zu stoppen.
# by AME 05/2023
#----------------------- Variablen --------------------------------------------------------------------------------#
# SET-X damit die Ausfuehrung protokolliert wird
# set -x
# Data for QNAS  / this NAS is very slow. It need minimum 5 minutes after WOL till it is available and 4 minutes after power down till it is not longer reachable
#mac="00:08:9B:CC:DD:02"                                         # MAC Adresse  of the backup server
#host="192.168.0.23"                                             # Hostname oder IP of the backup server
#remoteuser="admin"                                              # username @ host / for qnap = admin
#sleep_after_wakeup=8m                                           # Sleep time after a Wake On LAN which is typically needed. You have to check for your devide
#sleep_after_powerdown=5m                                        # Sleep time after a shut down which is typically needed you have to check for your device


# data for openmediavault NAS
mac="4C:52:62:1D:0E:DE"
host="192.168.100.240"
remoteuser="root"                                               # username @ host / for qnap = admin
sleep_after_wakeup=1m                                           # Sleep time after a Wake On LAN which is typically needed. You have to check for your devide
sleep_after_powerdown=1m                                        # Sleep time after a shut down which is typically needed you have to check for your device

# general data 
nic=vmbr0                                                       # network interface for WOL
TimeoutTimes=120                                                # time out time in [s] for different things
storeid=backup                                                  # Identifier of the storage which shall be used for the backup
storagetype=cifs                                                # type of the storage "dir" or "cifs" ... 


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
        # server still up
        echo "server still up"
      else
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
