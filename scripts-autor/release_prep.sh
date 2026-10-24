#!/bin/bash
# imagem de release: ro.adb.secure=1 (mesmo tamanho) em sys/system.img
cd "$(dirname "$0")/.." || exit 1
W=$(pwd)
mountpoint -q "$W/mnt/system" && sudo umount "$W/mnt/system"
sudo mount -o loop,rw "$W/sys/system.img" "$W/mnt/system" || exit 1
P="$W/mnt/system/system/etc/prop.default"
sudo sed -i 's/^ro.adb.secure=0/ro.adb.secure=1/' "$P"
grep -nE "^ro.(secure|debuggable|adb.secure)|usb.config" "$P"
sync; sudo umount "$W/mnt/system"
sudo e2fsck -fn "$W/sys/system.img" 2>&1 | tail -1
losetup -a | grep -c "$W"
