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

#----------------------- Programmablauf ---------------------------------------------------------------------------#
echo "der Backup-Server fährt nun runter, das Backup-Storage wird ausgehangen"
#sleep 2s
pvesm set $storeid --disable 1                                  # der Storage wir disabled umd die syslog nicht zu zu müllen
ssh $remoteuser@$host -p 22 "/sbin/poweroff < /dev/null &"
echo "stop host"
date

while  ping -q -c 1 $host &> /dev/null -ne 0 ; do
        sleep 10
        date
done
echo "Server ist down"

exit 0
