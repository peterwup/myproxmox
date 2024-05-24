A set of scripts for PROXMOX


[cleanup.sh](https://github.com/peterwup/myproxmox/blob/main/cleanup.sh)
* script to clean up proxmox things like logged data or old kernel files ....
* I found it somwhere on github
* I just use it in simulation mode and check what it would do and do it partly by hand

[getscript.sh](https://github.com/peterwup/myproxmox/blob/main/getscripts.sh)
* script to download all the scripts from github to proxmox
* push them at the right position
* set the "executable" flags to them for all users

[prox_config_backup.sh](https://github.com/peterwup/myproxmox/blob/main/prox_config_backup.sh)
* script I found on github
* script will backup the proxmox configuration data (like /etc/*)
* set the right destination path for me

[start-PBS.sh](https://github.com/peterwup/myproxmox/blob/main/start-PBS.sh)
* based on the script https://forum.proxmox.com/threads/proxmox-backup-server-pbs-automatisch-via-wol-starten-und-stoppen.127266/
* start a remote NAS
* wait till it is up
* enable the backup volumn
* can be use to do it manualy or for test purpose
 
[stop-PBS.sh](https://github.com/peterwup/myproxmox/blob/main/stop-PBS.sh)
* based on the script https://forum.proxmox.com/threads/proxmox-backup-server-pbs-automatisch-via-wol-starten-und-stoppen.127266/
* disable the backup volumn
* stop the NAS
* wait till the NAS is down.
* can be use to do it manualy or for test purpose

[vzdump-hook-script](https://github.com/peterwup/myproxmox/blob/main/vzdump-hook-script)
* based on the script https://forum.proxmox.com/threads/proxmox-backup-server-pbs-automatisch-via-wol-starten-und-stoppen.127266/
* hook script which is called from Proxmox while backup
* this script will get active
  * at **job-init** so at the begin of the backup process before the backup has startet
  * at this point the backup will be prepared
  * NAS will be started
  * backup volumn will be enabled
  * script wait till this is ready or will come to a timeout and stop the complete backup
  * at **job-end** where all backups are ready
  * at this point the script will be disable the backup volumn and bring down the NAS
 * starting the NAS will be doen by wake on lan (WOL)
 * stopping the NAS will be done by a ssh session 

[vzdump-hook-script-with](https://github.com/peterwup/myproxmox/blob/main/vzdump-hook-script-with)
* same as above, but in addition at **job-end** prox_config_backup.sh is called
