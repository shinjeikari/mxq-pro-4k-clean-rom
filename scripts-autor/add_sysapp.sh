#!/bin/bash
# uso: add_sysapp.sh <NomeDir> <apk>  -> sys/system.img: system/app/<NomeDir>/<NomeDir>.apk com labels de MboxLauncher
cd "$(dirname "$0")/.." || exit 1
W=$(pwd); N="$1"; A="$2"
[ -f "$A" ] || { echo "sem apk"; exit 1; }
mountpoint -q "$W/mnt/system" && sudo umount "$W/mnt/system"
sudo mount -o loop,rw "$W/sys/system.img" "$W/mnt/system" || { echo "FALHA mount"; exit 1; }
S="$W/mnt/system/system/app"
sudo mkdir -p "$S/$N"; sudo cp "$A" "$S/$N/$N.apk"
sudo chown 0:0 "$S/$N" "$S/$N/$N.apk"; sudo chmod 755 "$S/$N"; sudo chmod 644 "$S/$N/$N.apk"
sudo python3 - "$S" "$N" <<'PY'
import os,sys
S,N=sys.argv[1:3]; ref=S+"/MboxLauncher"
for s,d in ((ref,S+"/"+N),(ref+"/MboxLauncher.apk",S+"/"+N+"/"+N+".apk")):
    os.setxattr(d,"security.selinux",os.getxattr(s,"security.selinux"))
print("ok",N)
PY
sync; df -k "$W/mnt/system" | tail -1 | awk '{print "livre KB",$4}'
sudo umount "$W/mnt/system"
sudo e2fsck -fn "$W/sys/system.img" 2>&1 | tail -1
losetup -a | grep -c "$W"
