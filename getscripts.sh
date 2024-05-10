#!/bin/bash
#
wget https://github.com/peterwup/myproxmox/blob/main/start-PBS.sh
wget https://github.com/peterwup/myproxmox/blob/main/stop-PBS.sh
wget https://github.com/peterwup/myproxmox/blob/main/vzdump-hook-script
#
mv vzdump-hook-script /usr/local/bin/vzdump-hook-script
chmod a+x /usr/local/bin/vzdump-hook-script
#
chmod a+x stop-PBS.sh
chmod a+x start-PBS.sh
