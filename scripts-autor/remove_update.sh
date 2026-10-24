#!/bin/bash
cd "$(dirname "$0")/.." || exit 1
W=$(pwd)
mountpoint -q "$W/mnt/system" && sudo umount "$W/mnt/system"
sudo mount -o loop,rw "$W/sys/system.img" "$W/mnt/system" || exit 1
ls "$W/mnt/system/system/app/Update"
sudo rm -rf "$W/mnt/system/system/app/Update" && echo "rm Update"
sync; sudo umount "$W/mnt/system"
sudo e2fsck -fn "$W/sys/system.img" 2>&1 | tail -1
losetup -a | grep -c "$W"
