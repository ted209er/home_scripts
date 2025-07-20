

#!/bin/bash


DEVICE=${1:-/dev/mmcblk0}
OUTFILE=${2:-"sdcard_backup_$(date +%F).img"}

echo "[*] Backing up $DEVICE to $OUTFILE..."
sudo dd if="$DEVICE" of="$OUTFILE" bs=4M status=progress conv=fsync
echo "[*] Backup complete: $OUTFILE"
