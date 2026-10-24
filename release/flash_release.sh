#!/bin/bash
# Grava a imagem limpa na partição super da TV Box (Allwinner sun50iw9p1, "MXQ Pro 4K").
# Uso:  ./flash_release.sh SIM [serial_adb]      (Linux, macOS ou Git Bash; precisa de adb, xz, sha256sum)
# Só grava se o super atual for IDÊNTICO ao firmware de fábrica testado. Grava apenas os blocos de blocks.txt.
set -u
cd "$(dirname "$0")" || exit 1
[ "${1:-}" = "SIM" ] || { echo "ABORTADO: passe SIM como 1o argumento (leia o README antes)."; exit 1; }
SER="${2:-}"
STOCK=172e9203f1649f9d9c3fdc145141cffaee1e3294b4c200c078fdca2742298fb5
CLEAN=5e1fa9fe99fda13f632252634b391f57225953d5975a94aa9242d2fa864b4d8a
DEV=/dev/block/by-name/super
export MSYS_NO_PATHCONV=1
A(){ if [ -n "$SER" ]; then adb -s "$SER" "$@"; else adb "$@"; fi; }
sum(){ sha256sum | cut -c1-64; }
[ -f super_clean.img ] || { echo "descompactando..."; xz -dk super_clean.img.xz || exit 1; }
[ "$(sum < super_clean.img)" = "$CLEAN" ] || { echo "ERRO: super_clean.img corrompido"; exit 2; }
A shell "readlink $DEV" </dev/null | grep -q nand0p4 || { echo "ERRO: by-name/super nao e nand0p4; esta box nao e compativel"; exit 3; }
A shell "id -u" </dev/null | grep -q '^0' || { echo "ERRO: adb sem root"; exit 3; }
echo "Lendo o super atual para conferir (2 GB, alguns minutos)..."
CUR=$(A exec-out "dd if=$DEV bs=1048576 2>/dev/null" </dev/null | sum)
echo "super atual: $CUR"
if [ "$CUR" = "$CLEAN" ]; then echo "Ja esta com a imagem limpa. Nada a fazer."; exit 0; fi
[ "$CUR" = "$STOCK" ] || { echo "ERRO: o firmware desta box NAO e o de fabrica testado. Nada foi gravado."; exit 4; }
echo "Firmware de fabrica confirmado. Gravando blocos..."
for n in $(cat blocks.txt); do
  dd if=super_clean.img of=c.bin bs=1048576 skip=$n count=1 status=none
  A push c.bin /data/local/tmp/c.bin </dev/null >/dev/null || { echo "ERRO push $n"; exit 5; }
  A shell "dd if=/data/local/tmp/c.bin of=$DEV bs=1048576 seek=$n count=1 conv=notrunc 2>/dev/null; sync" </dev/null
  W=$(A exec-out "dd if=$DEV bs=1048576 skip=$n count=1 2>/dev/null" </dev/null | sum)
  [ "$W" = "$(sum < c.bin)" ] && echo "bloco $n ok" || { echo "ERRO verificacao do bloco $n. NAO reinicie; veja o README (restauracao)."; exit 6; }
done
rm -f c.bin; A shell "rm -f /data/local/tmp/c.bin; sync" </dev/null
echo "Conferindo imagem inteira..."
END=$(A exec-out "dd if=$DEV bs=1048576 2>/dev/null" </dev/null | sum)
[ "$END" = "$CLEAN" ] && echo "TUDO OK. Reinicie: adb reboot" || { echo "ERRO: hash final diferente. NAO reinicie."; exit 7; }
