#!/bin/bash
# esvazia system/preinstall (apps reinstalados em todo primeiro boot) e remove TvdFileManager
cd "$(dirname "$0")/.." || exit 1
W=$(pwd)
mountpoint -q "$W/mnt/system" && sudo umount "$W/mnt/system"
sudo mount -o loop,rw "$W/sys/system.img" "$W/mnt/system" || exit 1
S="$W/mnt/system/system"
sudo find "$S/preinstall" -mindepth 1 -delete && echo "preinstall esvaziado"
sudo rm -rf "$S/priv-app/TvdFileManager" && echo "rm TvdFileManager"
ls -A "$S/preinstall" | wc -l
sync; df -k "$W/mnt/system" | tail -1 | awk '{print "livre KB",$4}'
sudo umount "$W/mnt/system"
sudo e2fsck -fn "$W/sys/system.img" 2>&1 | tail -1
losetup -a | grep -c "$W"
