#!/bin/bash
# Script to start the server
# based on the script of dremeier and Kochi1316
# https://forum.proxmox.com/threads/proxmox-backup-server-pbs-automatisch-via-wol-starten-und-stoppen.127266/
# 
# the used program etherwake was not installed on my PVE: apt install etherwake
#
# by AME 05/2023
#    PH  05/2024
#----------------------- Variablen --------------------------------------------------------------------------------#
# SET-X damit die Ausfuehrung protokolliert wird
set -x
#

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
nic=enp2s0                                                      # network interface for WOL
TimeoutTimes=120                                                # time out time in [s] for different things
storeid=backup                                                  # Identifier of the storage which shall be used for the backup
storagetype=cifs                                                # type of the storage "dir" or "cifs" ... 

                                                              

#----------------------- Subroutines ---------------------------------------------------------------------------#

##############################################################################
#
# Check if we can reach the server by ping 
# If this is the case the next check will be if the storage is available
# Returns:
#       2 = down = server is not reachable by ping
#       1 = inactive = server is reachable by ping but backup storage is not mounted
#       0 = active = server is up and storeg is mounted
is_server_up () {
    if ping -c 1 $host &> /dev/null; then      # send ping to the server and check if server is available
        echo "Backup server is available"
        # check if storage is up
        com=$(pvesm status --storage $storeid | tail -1); 
        [[ "$com" =~ ($storeid+ +)($storagetype+ +)(active|disabled) ]];
        if [ "${BASH_REMATCH[3]}" == "active" ]; then  
            # server is up and storage is active
            return 0
        else
            # server is up, but starage is not available
            return 1
        fi
    else
        # server is down and storage is not available
        return 2
    fi
}

#----------------------- Main program  ---------------------------------------------------------------------------#

#################################

# fist check if server is up or stoarage is not active
is_server_up
if [[ "$?" -ne 0 ]]; then
    # server is not up or storage is not active
    # start the server by WOL  
    /usr/sbin/etherwake -i $nic $mac  
    
    # First fix wait time which shall be determine manually at the begining
    sleep $sleep_after_wakeup
    
    # start mesauring time here, first sleep is not part of timeout
    start_timemeasuring=$(date +%s)
    
    # next wait for the server coming ip until timeout time 
    until [[ "$act" == "true" ]]; do
        is_server_up
        if [ "$?" -le 1 ]; then
          runtime=$(($(date +%s)-start_timemeasuring))
          echo "Backupserver is up now after $runtime seconds"
          act=true
        else
          /usr/sbin/etherwake -i $nic $mac
          stop_timemeasuring=$(date +%s)
          runtime=$((stop_timemeasuring-start_timemeasuring))
          if [ $runtime -gt $TimeoutTimes ]; then  
            echo "Timeout: Not able to bring backupserver up after $TimeoutTimes seconds"
            exit 1
          fi
          sleep 10s
        fi
    done
    
    act=false
    # now enable the backup storage
    pvesm set $storeid --disable 0          
    
    # again start time measuring 
    start_timemeasuring=$(date +%s)
    
    until [[ "$act" == "true" ]]; do
        is_server_up
        if [ "$?" -eq 0 ]; then
            runtime=$(($(date +%s)-start_timemeasuring))
            echo "Backup storage is up now after $runtime seconds"
            act=true
        else
          runtime=$(($(date +%s)-start_timemeasuring))
          if [ $runtime -gt $TimeoutTimes ]; then  
            echo "Timeout: Not able to bring backup storage up after $TimeoutTimes seconds"
            exit 1
          fi
          sleep 10s
        fi
        
    done                
fi
exit 0
