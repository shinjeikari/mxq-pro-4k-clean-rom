#!/bin/bash
# bootanimation.zip minima: fundo preto + "Inicializando. Aguarde." (681x300, PNG, zip sem compressao)
cd "$(dirname "$0")/.." || exit 1
W=$(pwd)
python3 -c "import PIL" 2>/dev/null || sudo apt-get install -y -qq python3-pil >/dev/null 2>&1
mkdir -p out/bootanim
python3 - <<'PY'
from PIL import Image, ImageDraw, ImageFont
import zipfile, io
w,h=681,300
img=Image.new("RGB",(w,h),(0,0,0)); d=ImageDraw.Draw(img)
f=ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",40)
t="Inicializando. Aguarde."
b=d.textbbox((0,0),t,font=f); d.text(((w-(b[2]-b[0]))//2-b[0],(h-(b[3]-b[1]))//2-b[1]),t,font=f,fill=(255,255,255))
buf=io.BytesIO(); img.save(buf,"PNG")
with zipfile.ZipFile("out/bootanim/bootanimation.zip","w",zipfile.ZIP_STORED) as z:
    z.writestr("desc.txt","681 300 1\np 0 0 part0\n")
    z.writestr("part0/0000.png",buf.getvalue())
img.save("out/bootanim/preview.png")
PY
unzip -l out/bootanim/bootanimation.zip | tail -4
sudo mount -o loop,rw "$W/sys/system.img" "$W/mnt/system" || exit 1
M="$W/mnt/system/system/media/bootanimation.zip"
sudo cp -a "$M" "$W/out/bootanim/bootanimation.orig.zip"
sudo cp out/bootanim/bootanimation.zip "$M"; sudo chown 0:0 "$M"; sudo chmod 644 "$M"
sudo setfattr -n security.selinux -v 'u:object_r:system_file:s0' "$M" 2>/dev/null || sudo python3 -c "import os,sys;os.setxattr('$M','security.selinux',b'u:object_r:system_file:s0\x00')"
ls -l "$M"
sync; sudo umount "$W/mnt/system"
sudo e2fsck -fn "$W/sys/system.img" 2>&1 | tail -1
losetup -a | grep -c "$W"
