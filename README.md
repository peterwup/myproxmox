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
* Can be used to do this by hand or make first tests
 
[stop-PBS.sh](https://github.com/peterwup/myproxmox/blob/main/stop-PBS.sh)


[]()
