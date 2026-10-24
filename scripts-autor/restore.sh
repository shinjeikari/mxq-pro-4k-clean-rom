#!/bin/bash
# Fase 8: devolve o super ao estado do backup (backup/nand0p4_super.img), gravando só blocos de 1MiB que diferem.
# Uso: restore.sh SIM   (exige CONFIRMA do usuário; adb de rede + USBV device mode ligado)
cd "$(dirname "$0")/.."
[ "$1" = "SIM" ] || { echo "ABORTADO: exige argumento SIM (após CONFIRMA do usuário)"; exit 1; }
export MSYS_NO_PATHCONV=1
ADB="$LOCALAPPDATA/Microsoft/WinGet/Packages/Google.PlatformTools_Microsoft.Winget.Source_8wekyb3d8bbwe/platform-tools/adb.exe"
D(){ "$ADB" -s 192.168.2.105:5555 "$@"; }
DEV=/dev/block/by-name/super
IMG=backup/nand0p4_super.img
[ "$(sha256sum $IMG | cut -c1-64)" = 172e9203f1649f9d9c3fdc145141cffaee1e3294b4c200c078fdca2742298fb5 ] || { echo "ERRO: backup corrompido"; exit 2; }
D shell "readlink $DEV" </dev/null | grep -q nand0p4 || { echo "ERRO: super != nand0p4"; exit 2; }
rd(){ D exec-out "dd if=$DEV bs=1048576 skip=$1 count=1 2>/dev/null" </dev/null | sha256sum | cut -c1-64; }
bk(){ dd if=$IMG bs=1048576 skip=$1 count=1 status=none | sha256sum | cut -c1-64; }
for n in $(seq 0 2047); do
  [ "$(rd $n)" = "$(bk $n)" ] && continue
  dd if=$IMG of=out/rc.bin bs=1048576 skip=$n count=1 status=none
  D push out/rc.bin /data/local/tmp/c.bin </dev/null >/dev/null || { echo "ERRO push $n"; exit 4; }
  D shell "dd if=/data/local/tmp/c.bin of=$DEV bs=1048576 seek=$n count=1 conv=notrunc 2>/dev/null; sync" </dev/null
  [ "$(rd $n)" = "$(bk $n)" ] && echo "bloco $n restaurado" || { echo "ERRO verificação bloco $n"; exit 5; }
done
D shell "rm -f /data/local/tmp/c.bin; sync" </dev/null
echo "RESTAURADO. Reinicie: adb reboot"
