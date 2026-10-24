#!/bin/bash
# Verificacao SOMENTE LEITURA: diz se esta box e compativel com a imagem. Nao escreve nada.
# Uso: ./check_compat.sh [serial_adb]      (precisa de adb com root)
set -u
SER="${1:-}"
STOCK=172e9203f1649f9d9c3fdc145141cffaee1e3294b4c200c078fdca2742298fb5
export MSYS_NO_PATHCONV=1
A(){ if [ -n "$SER" ]; then adb -s "$SER" "$@"; else adb "$@"; fi; }
P(){ A shell "getprop $1" </dev/null | tr -d '\r'; }
ok=1; chk(){ if [ "$2" = "$3" ]; then echo "OK    $1: $2"; else echo "FALHA $1: obtido '$2', esperado '$3'"; ok=0; fi; }
A shell "id -u" </dev/null | grep -q '^0' || { echo "FALHA: adb sem root (adb root / modo eng)"; exit 1; }
chk "plataforma" "$(P ro.board.platform)" "cupid"
chk "dispositivo" "$(P ro.product.device)" "titan-p1"
chk "build" "$(P ro.build.display.id)" "titan_p1-eng 10 QP1A.191105.004 eng.akrd6.20210505.131222 test-keys"
chk "super -> particao" "$(A shell 'readlink /dev/block/by-name/super' </dev/null | tr -d '\r')" "/dev/block/nand0p4"
chk "tamanho do super" "$(A shell 'blockdev --getsize64 /dev/block/by-name/super' </dev/null | tr -d '\r')" "2147483648"
echo "Lendo o super inteiro para o hash (2 GB, alguns minutos)..."
H=$(A exec-out "dd if=/dev/block/by-name/super bs=1048576 2>/dev/null" </dev/null | sha256sum | cut -c1-64)
chk "sha256 do super" "$H" "$STOCK"
[ $ok = 1 ] && echo "COMPATIVEL: pode seguir para o README (backup primeiro)." || echo "NAO COMPATIVEL: NAO grave esta imagem nesta box."
