#!/bin/bash
# gera out/delta/chunk_<N>.bin (1MiB) para cada bloco que difere + delta.txt
cd "$(dirname "$0")/.."
rm -rf out/delta; mkdir -p out/delta
cmp -l backup/nand0p4_super.img out/super_mod.img | awk '{print int(($1-1)/1048576)}' | sort -nu > out/delta/delta.txt
while read n; do dd if=out/super_mod.img of=out/delta/chunk_$n.bin bs=1048576 skip=$n count=1 status=none; done < out/delta/delta.txt
( cd out/delta && sha256sum chunk_*.bin > SHA256SUMS )
wc -l < out/delta/delta.txt
