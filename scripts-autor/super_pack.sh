#!/bin/bash
# fase 5: super_mod.img = cópia do super original + system/vendor/product editados, mesmos offsets/tamanhos
cd "$(dirname "$0")/.." || exit 1
mkdir -p out
O=out/super_mod.img
[ "$(stat -c %s sys/system.img)" = 1237651456 ] && [ "$(stat -c %s sys/vendor.img)" = 149659648 ] && [ "$(stat -c %s sys/product.img)" = 115494912 ] || { echo "TAMANHO ERRADO"; exit 1; }
cp backup/nand0p4_super.img $O
dd if=sys/system.img  of=$O bs=4096 seek=256    conv=notrunc status=none
dd if=sys/vendor.img  of=$O bs=4096 seek=302592 conv=notrunc status=none
dd if=sys/product.img of=$O bs=4096 seek=339200 conv=notrunc status=none
ls -l $O backup/nand0p4_super.img
echo "== metadata/lp intacto"; cmp -n 1048576 $O backup/nand0p4_super.img && echo META_OK
python3 scripts/lp_parse.py $O
sha256sum $O | cut -c1-16
echo SUPER_DONE
