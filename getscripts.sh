#!/bin/bash
#
wget https://raw.githubusercontent.com/peterwup/myproxmox/main/start-PBS.sh  -O ~/start-PBS.sh --backups=0
wget https://raw.githubusercontent.com/peterwup/myproxmox/main/stop-PBS.sh -O ~/stop-PBS.sh --backups=0
wget https://raw.githubusercontent.com/peterwup/myproxmox/main/vzdump-hook-script -O /usr/local/bin/vzdump-hook-script --backups=0
wget https://raw.githubusercontent.com/peterwup/myproxmox/main/prox_config_backup.sh -O ~/prox_config_backup.sh --backups=0
wget https://raw.githubusercontent.com/peterwup/myproxmox/main/cleanup.sh -O ~/cleanup.sh --backups=0
#
# mv vzdump-hook-script /usr/local/bin/vzdump-hook-script 
chmod a+x /usr/local/bin/vzdump-hook-script
#
chmod a+x stop-PBS.sh
chmod a+x start-PBS.sh
chmod a+x prox_config_backup.sh
chmod a+x cleanup.sh
