#!/bin/bash
# Grava SÓ os 15 blocos de 1MiB alterados do super (delta). Uso: flash_super.sh SIM
# Roda no Git Bash. Pré-checa que o device ainda == backup antes de gravar; relê e confere depois.
cd "$(dirname "$0")/.."
[ "$1" = "SIM" ] || { echo "ABORTADO: exige argumento SIM (após CONFIRMA do usuário)"; exit 1; }
export MSYS_NO_PATHCONV=1
ADB="$LOCALAPPDATA/Microsoft/WinGet/Packages/Google.PlatformTools_Microsoft.Winget.Source_8wekyb3d8bbwe/platform-tools/adb.exe"
D(){ "$ADB" -s 192.168.2.105:5555 "$@"; }
DEV=/dev/block/by-name/super
D shell "readlink $DEV" </dev/null | grep -q nand0p4 || { echo "ERRO: super != nand0p4"; exit 2; }
rd(){ D exec-out "dd if=$DEV bs=1048576 skip=$1 count=1 2>/dev/null" </dev/null | sha256sum | cut -c1-64; }
bk(){ dd if=backup/nand0p4_super.img bs=1048576 skip=$1 count=1 status=none | sha256sum | cut -c1-64; }
nw(){ sha256sum out/delta/chunk_$1.bin | cut -c1-64; }
pv(){ sha256sum out/delta_prev/chunk_$1.bin 2>/dev/null | cut -c1-64; }
N=$(cat out/delta/delta.txt)
echo "== pré-check (device == backup) =="
for n in $N; do r=$(rd $n); [ "$r" = "$(bk $n)" ] || [ "$r" = "$(pv $n)" ] || [ "$r" = "$(nw $n)" ] || { echo "ERRO: bloco $n nao e backup/delta1/novo; nada gravado"; exit 3; }; done
echo "== gravando =="
for n in $N; do
  [ "$(rd $n)" = "$(nw $n)" ] && { echo "bloco $n ja ok"; continue; }
  D push out/delta/chunk_$n.bin /data/local/tmp/c.bin </dev/null >/dev/null || { echo "ERRO push $n"; exit 4; }
  D shell "dd if=/data/local/tmp/c.bin of=$DEV bs=1048576 seek=$n count=1 conv=notrunc 2>/dev/null; sync" </dev/null
  [ "$(rd $n)" = "$(nw $n)" ] && echo "bloco $n ok" || { echo "ERRO verificação bloco $n -> rode restore"; exit 5; }
done
D shell "rm -f /data/local/tmp/c.bin; sync" </dev/null
echo "TODOS OS BLOCOS OK. Reinicie: adb reboot"
