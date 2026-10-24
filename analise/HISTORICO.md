# Histórico — MXQ Pro 4K (Allwinner sun50iw9p1)

Registro cronológico do que foi feito e descoberto. Datas no fuso do usuário.

## 2026-10-24

| Etapa | Resultado |
|---|---|
| Detecção | Allwinner H313/H616, Android 10 `eng`/`test-keys`, 1 GB RAM real (kernel informa 16 GB), NAND raw 7,6 GB, partições dinâmicas (`super`), AVB sem enforcement. ADB por rede na porta 5555 só abre com o "USBV device mode" ligado. |
| Backup | 17 partições + cabeçalho do disco lidos com `adb exec-out dd`, SHA-256 verificado. |
| boot.img | Ramdisk só tem first-stage; props `ro.*` não ficam no boot. Reempacotamento com os parâmetros originais saiu idêntico. |
| super | system/vendor/product extraídos por offset da metadata LP, sem `lpunpack`. 14 apps do system e a Gallery2 removidos, `ro.adb.secure=0`, `e2fsck` limpo. |
| Desempenho | CheckJNI desligado (`ro.kernel.android.checkjni=0`), zram reduzido de 75% de 16 GB para 512 MB. |
| Diagnóstico de lentidão | Só 220 MB de RAM disponível, 313 MB em swap. Maior consumidor: `com.device.config.provider` (168 MB), maior que o `system_server`. |
| Análise de apps | 18 APKs de `/data/app` copiados e analisados de forma estática. Ver `ANALISE.md` e `IOCs.md`. |
| Remoção | 17 pacotes removidos com `pm uninstall -k --user 0` (APK e dados mantidos no aparelho; desfazer com `scripts/data_apps_undo.sh`). `com.assisttools` mantido (inconclusivo). |
| Verificação | 20 s depois, nenhum pacote da cadeia voltou. `MemAvailable` passou de ~219 MB para ~452 MB. Launcher e Configurações abrem. |

## Pendente

- Flash do novo `super` (fase 7), sempre com confirmação explícita.
- Factory reset de `/data` após o flash, para eliminar qualquer resíduo (decisão do usuário).
- Bloquear os domínios de `IOCs.md` no roteador.
- Reverter o USB device mode para voltar a usar mouse/teclado USB.

## Para revisar depois (efeitos colaterais da remoção)

- Todos os 18 pacotes foram removidos (17 confirmados/suspeitos + `com.assisttools`, inconclusivo, removido a pedido do usuário).
- A remoção é reversível: `scripts/data_apps_undo.sh` reinstala os 17 a partir do APK que ficou no aparelho. Os APKs também estão em `backup/apps/`.
- Se algo parar de funcionar, anotar aqui qual app/função foi afetado e testar reinstalando só o pacote correspondente.
- Ainda não consultados no VirusTotal: `zxtv.service`, `lssa.service`, `android.tools`, `domain`, `core.rss`, `assistant.setting.*`, `apprmdir`, `google.android.services`, `earn.rewards`, `preference.manager`, `gigglegrove`.
- A classificação desses é por comportamento (permissões, persistência, instalação silenciosa), não por detecção de antivírus.
