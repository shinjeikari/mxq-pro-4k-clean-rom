# Imagem limpa para TV Box "MXQ Pro 4K" (Allwinner sun50iw9p1 / H313-H616)

Android 10 enxuto para **uma build específica de fábrica**: sem os apps que vinham com adware/malware, **sem a pasta `/system/preinstall`** (que reinstalava Netflix, YouTube, Kodi, Chrome etc. a cada primeiro boot), sem gerenciador de arquivos e sem o app de OTA do fabricante. Vem só com **TV Bro 2.1.6** (navegador) e **Aurora Store 4.8.4** (loja; a box de fábrica não tinha Play Store). Também: `ro.adb.secure=1`, swap em zram de ~490 MB, CheckJNI desligado e tela de boot preta "Inicializando. Aguarde.".

> **AVISOS GRAVES**
> - **Não oficial, sem garantia.** Um erro pode deixar a box sem boot. **Não existe caminho de recuperação testado** (FEL/PhoenixSuit e boot por cartão SD não foram testados; ver "Se der errado").
> - **Só serve para a build exata abaixo.** "MXQ Pro 4K 5G" é nome usado por vários lotes; outras boxes podem ter firmware/NAND diferentes. O `check_compat.sh` confere e o `flash_release.sh` recusa se não bater.
> - **NÃO ligue a porta USB da box a um computador** (ver `USB_PC_AVISO.md`).
> - **Licença:** a imagem contém o firmware do fabricante e apps do Google (GMS) que já vinham na box. Uso pessoal, por sua conta e risco.
> - O build de fábrica é `eng`/`test-keys` (adbd root, `ro.secure=0`, `ro.debuggable=1`). Esta imagem só exige autorização do adb; não a torna um sistema de produção.

## Build compatível (conferida pelo `check_compat.sh`)
- `ro.board.platform=cupid`, `ro.product.device=titan-p1`
- `ro.build.display.id = titan_p1-eng 10 QP1A.191105.004 eng.akrd6.20210505.131222 test-keys`
- `by-name/super -> nand0p4`, 2147483648 bytes
- **sha256 do super de fábrica: `172e9203f1649f9d9c3fdc145141cffaee1e3294b4c200c078fdca2742298fb5`**

## Passo a passo
1. Computador com `adb`, `xz` e `sha256sum` (Linux, macOS ou Git Bash). Box e PC na mesma rede; na box, ligue "USBV device mode" nas opções de desenvolvedor (isso desativa o mouse/teclado da porta ao lado do AV, a `usbc0`, até desligar). Autorize o adb na tela. **Não ligue a box ao PC por USB.**
2. Confira os arquivos: `sha256sum -c SHA256SUMS`
3. **Verifique a compatibilidade (só leitura):** `./check_compat.sh <ip>:5555` — precisa terminar com `COMPATIVEL`.
4. **Faça backup do seu super (obrigatório):**
   `adb exec-out "dd if=/dev/block/by-name/super bs=1048576" > meu_super_backup.img` e confira que `sha256sum meu_super_backup.img` é igual ao hash de fábrica acima. Guarde o arquivo fora da box.
5. Energia estável (nobreak; nada de tirar da tomada). Grave: `./flash_release.sh SIM <ip>:5555` (descompacta, confere o hash do super atual, grava 35 blocos de 1 MiB, confere cada bloco e a imagem inteira). **Só se terminar com `TUDO OK`:** `adb reboot`.
6. Se aparecer qualquer `ERRO`: **não reinicie**; rode `./restore_backup.sh SIM meu_super_backup.img <ip>:5555`.
7. Depois do boot, os apps listados são só Aurora Store e TV Bro. A imagem não mexe no `/data`: apps instalados antes continuam lá; para uma box realmente limpa, desinstale-os ou apague o `/data` por sua conta.

## Estado dos testes (honesto)
Testado numa única box (a do autor), em 2026-10-24:

| Item | Resultado |
|---|---|
| Gravação dos blocos com o script do autor (`flash_super.sh`, 6 vezes, com conferência por bloco) | OK, a box iniciou sempre |
| `check_compat.sh` na box modificada | recusou (hash diferente), como esperado |
| `restore.sh` (versão do autor: compara 2048 blocos e regrava os que diferem) | OK: a box voltou ao firmware de fábrica e iniciou |
| `check_compat.sh` na box de fábrica restaurada | COMPATÍVEL |
| `flash_release.sh` a partir do `release/` na box de fábrica | OK: `TUDO OK`, 35 blocos verificados, a box iniciou |
| Box após o `flash_release.sh` | `ro.adb.secure=1`, swap 503 MB, ~540 MB de RAM livre, só Aurora e TV Bro no launcher, tela de boot nova |
| `restore_backup.sh` (versão genérica para usuários) | **só checagem de sintaxe**; a lógica é a do `restore.sh` testado |
| Outras boxes / outros firmwares / outros lotes | **nunca testado** |
| Boot por cartão SD, FEL/PhoenixSuit, recovery de fábrica | **nunca testado** |
| USB-peripheral com o PC | **não funciona nesta box** (hardware); ver `USB_PC_AVISO.md` |

## Se der errado (a box não inicia)
O U-Boot (`bootloader`), o `boot` e o `recovery` **não são alterados**: apenas a partição `super` muda. Mesmo assim, se a box não subir o Android, **não há método de recuperação testado**. Hipóteses não verificadas: entrar no recovery de fábrica (`nand0p6`); cartão SD de boot do Allwinner (o slot existe, `sdc0`, mas faltam `boot0`/U-Boot de cartão e o pacote PhoenixSuit completo); FEL por USB (a porta da box não é detectada pelo PC). Por isso o backup do passo 4 é obrigatório.

## O que foi removido / alterado (resumo)
Apps de sistema removidos: Katniss, LiveTv, GoogleTTS, YouTubeLeanback, Tubesky, DragonBox, GalleryTV, Music, EasterEgg, Traceur, WallpaperPicker2, MiracastReceiver, PrintSpooler, BuiltInPrintService, Gallery2, TvdFileManager, Update (OTA); `/system/preinstall` esvaziada. Adicionados: TV Bro, Aurora Store. Propriedades: `ro.adb.secure=1`, CheckJNI desligado. Vendor: `zramsize=3%`. Animação de boot trocada. Nada mais.

## English (short)
Unofficial, cleaned Android 10 image for one specific "MXQ Pro 4K" firmware build (hash above). Tested on a single unit; the flash and restore scripts were verified on it, other units/firmwares are untested, and there is no tested recovery path if it fails to boot. Back up your `super` first; run `check_compat.sh`; never connect the box's USB port to a PC (see `USB_PC_AVISO.md`). Contains OEM firmware and Google apps: personal use, no warranty.
