#!/bin/bash
#
wget https://raw.githubusercontent.com/peterwup/myproxmox/main/start-PBS.sh
wget https://raw.githubusercontent.com/peterwup/myproxmox/main/stop-PBS.sh
wget https://raw.githubusercontent.com/peterwup/myproxmox/main/vzdump-hook-script
#
#mv vzdump-hook-script /usr/local/bin/vzdump-hook-script
#chmod a+x /usr/local/bin/vzdump-hook-script
#
chmod a+x stop-PBS.sh
chmod a+x start-PBS.sh
