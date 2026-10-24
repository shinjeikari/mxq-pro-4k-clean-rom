# Análise de apps pré-instalados — TV box "MXQ Pro 4K"

Aparelho: Allwinner sun50iw9p1 (H313/H616), Android 10 (build `titan_p1-eng`, `test-keys`), 1 GB RAM real.
Data da análise: 2026-10-24.

## Método e limites

- **Análise estática apenas.** Nenhum APK foi executado ou instalado no PC. Os APKs foram copiados do aparelho com `adb pull` (somente leitura) e inspecionados com `aapt`, `unzip`, `openssl` e `strings`.
- Nenhum domínio foi contatado. As URLs/IPs abaixo foram extraídas das strings dos arquivos `.dex`.
- Os APKs `jiagu` (empacotados) escondem parte do código, então a análise deles é parcial.
- "Malware" aqui significa **comportamento consistente com malware/adware pré-instalado de TV box**: instalação de outros apps sem o usuário, persistência, venda de banda, anúncios, coleta de identificadores. Não atribuí família de malware: seria necessária análise dinâmica.
- Os APKs em si **não** devem ir para o repositório. Use os SHA-256 de `IOCs.md`.

## Cadeia de instalação (quem instalou quem)

Dados do `installerPackageName` no aparelho:

```
com.android.netservice  (sem instalador; instalado em 2023-12-15; versão 3.6.0)
 ├─ com.zxtv.service            (instalado hoje, 2026-10-24)
 ├─ com.lssa.service            (2026-05-23)
 │   └─ com.hopper.rsshub.stb   (2026-08-17)
 ├─ com.device.config.provider  (2026-07-28)
 ├─ com.androidsub.processes    (2026-06-29)
 └─ com.android.domain          (2025-09-18)
     └─ com.android.tools       (2026-08-15)
com.android.assistant.setting.iknew (instalou a si mesmo, 2026-03-10)
 └─ com.core.rss                (2026-06-29)
```

O `netservice` tem as permissões `INSTALL_PACKAGES`, `DELETE_PACKAGES` e `CHANGE_COMPONENT_ENABLED_STATE` e vem instalando apps novos até hoje. Isso significa que um dropper ativo continua baixando e instalando programas no aparelho. Por isso ele é o primeiro a ser removido.

## Resultado por app

Classificação: **Malware** = comportamento de instalador/proxy/acesso remoto/carga oculta; **Adware** = anúncios e rastreio sem função útil; **Inconclusivo** = sem evidência suficiente.

| Pacote | Rótulo | Classe | Evidências principais |
|---|---|---|---|
| com.android.netservice 3.6.0 | Netservice | **Malware (dropper)** | `INSTALL/DELETE_PACKAGES`, `CHANGE_COMPONENT_ENABLED_STATE`, `QUERY_ALL_PACKAGES`, `PACKAGE_USAGE_STATS`, serviço de acessibilidade, DNS-over-HTTPS embutido (contorna o DNS da rede), código de proxy, SDK Adjust, lista `filter_apps.txt`, inicia no boot, assinado com a chave de teste do AOSP. Nome imita o Android. |
| com.android.domain 1.0.6 | Updated | **Malware** | Instala/remove pacotes, `RECORD_AUDIO`, `CAMERA`, `SYSTEM_ALERT_WINDOW`, acessibilidade, DoH, proxy, `nebulasdk`, serviço de mensagens entre apps. Instalado pelo netservice. |
| com.lssa.service 2.0.1 | Assistant | **Malware** | Instala/remove pacotes, localização fina, geolocalização por IP, endpoints `*.tentvs.com` (inclui `upload-sdkuninstall`, que reporta desinstalações), `app.activity.trmaz.xyz:30133`, biblioteca nativa `libnative_encrypt.so`, `Runtime.exec`. Instalou o rsshub. |
| com.zxtv.service 3.0 | Zxtvservice | **Malware (adware + carregador de plugins)** | `WRITE_SECURE_SETTINGS`, `INSTALL_PACKAGES`, `SYSTEM_ALERT_WINDOW`, acessibilidade, `DexClassLoader`, "plugin dinâmico" (`zeasn.dynamic.plugin`), SDK de anúncios `WhaleTV_AD_SDK` embutido, `launcher.akrdinfo.cn:8742`. |
| com.device.config.provider 3.3.2 | DeviceService | **Malware (carregador de carga oculta)** | Maior uso de RAM do aparelho (168 MB). Carrega um blob de `assets/runtime` com `DexClassLoader`, `READ_PRIVILEGED_PHONE_STATE`, alarmes exatos, inicia no boot, assinado com certificado criado em 2026-05-21 (`CN=birch`). Nome imita configuração do sistema. |
| com.androidsub.processes 10.0 | androidsub_service | **Malware** | Empacotado com 360 Jiagu (`libjiagu*.so`) para esconder o código, `KeepAliveService`, `ServiceWatchdogReceiver`, `DauHeartbeatReceiver` (relata que o aparelho está ativo), localização, `DELETE_PACKAGES`, roda com prioridade alta. |
| com.android.tools 3.0 | AppTelecom | **Malware (acesso remoto provável)** | `libterminal_pty.so` (terminal/PTY nativo), `NETWORK_SETTINGS`, `INSTALL/DELETE_PACKAGES`, `NetProbeService`, DoH, IP fixo `40.160.68.219`, acessibilidade. |
| com.hopper.rsshub.stb 2.0.7 | RssHub | **Malware (proxy residencial)** | Pacote `com.android.eapx` com `ProxyJsMonitorService`/`srvh`/`srvj`, `REBOOT`, `QUERY_ALL_PACKAGES`, `DexClassLoader`, SDKs de anúncios, endpoints `optimizerapi.long.tv` e `upload.mytvos.com`, geolocalização por IP. |
| com.core.rss 1.0.2 | RssPlayer | **Malware** | Mesma família "Rss": SDK `szbx` nativo (`libszbx_sdk*.so`), `REBOOT`, inicia no boot, `FirebaseProvider` falso, `WakeServiceReceiver`. Instalado pelo assistant.setting.iknew. |
| com.systemguard.android 1.2.2 | SystemGuard | **Malware (venda de banda)** | Contém `com.honeygain.vobler.lib` (`RewardService`): SDK de venda de banda/proxy residencial, empacotado com Jiagu, assinado por "maysly, Shenzhen". Nome imita um app de segurança. |
| com.android.assistant.setting.iknew / .pro 1.2.8 | Setting Assistant | **Malware** | Dois APKs idênticos (mesma versão 19, dois nomes). `INSTALL/DELETE_PACKAGES`, `CLEAR_APP_CACHE`, geolocalização por IP, `*.tentvs.com`, `ip.tvsetting.com`, inicia no boot. O iknew instalou o `core.rss`. |
| com.kt.pad.apprmdir 1.0 | AppRmDir | **Malware** | Mesmo esqueleto do `com.android.tools` (`ProductService`/`ProductReceiver`/`ConfigurationProvider`), acessibilidade (23 referências), proxy, `chmod`, localização. |
| com.google.android.services 6.0 | GoogleServices | **Malware** | Nome imita o Google, mas o pacote real é `com.google.android.gms`. Inicia no boot, escuta `TIME_TICK` e `PACKAGE_INSTALL`, biblioteca nativa `liblogs.so`, assinado por "sz" (Shenzhen), 100% sem ícone. |
| com.earn.rewards 1.0.1 | Earn Money | **Adware** | App "Earn Money" com Jiagu, Adjust e anúncios; não faz nada útil na TV. |
| com.preference.manager 1.1.2 | Preference Manager | **Adware** | Serviço de download ExoPlayer + AdMob, sem tela, instalado pelo launcher. |
| om.giggle.gigglegrove 1.4.7 | GiggleGrove | **Adware** | Mesmo `com.jack.player.exo` do preference.manager, Jiagu, AdMob/AdServices. |
| com.assisttools 1.2 | (sem rótulo) | **Inconclusivo, mantido** | Sem permissões e sem componentes de serviço. Não removi. |

## O que os apps fazem em conjunto

1. **Persistência e reinstalação:** vários componentes iniciam no boot e se vigiam (`ServiceWatchdog`, `KeepAlive`). O dropper reinstala os outros se um for removido.
2. **Venda da sua conexão:** SDKs de proxy residencial (`eapx`, `honeygain.vobler`) usam seu IP e sua banda para tráfego de terceiros.
3. **Controle remoto:** carga baixada em tempo de execução (`DexClassLoader`), terminal nativo, plugins dinâmicos. O operador pode trocar o comportamento dos apps sem atualização visível.
4. **Rastreio:** IDs do aparelho, MAC, localização aproximada por IP, lista de apps instalados e relatórios de desinstalação enviados a servidores externos.
5. **Anúncios:** SDKs de anúncios e overlays (`SYSTEM_ALERT_WINDOW`).
6. **Evasão:** nomes que imitam o Android/Google, sem ícone, código empacotado (Jiagu), DNS-over-HTTPS próprio.

## Por que isso pôde acontecer

O firmware é um build `eng` com `test-keys` e `ro.adb.secure=1`, mas com `adbd` em root. Apps assinados com a chave de teste do AOSP e com `INSTALL_PACKAGES` conseguem instalar outros apps sem aviso. Isso foi observado, não testado.

Os apps estão em `/data` e **sobrevivem à troca do `super`**. Um flash do ROM sozinho não os remove. Só um `pm uninstall` ou um wipe de `/data` os tira.

## Próximos passos sugeridos

- Remover a cadeia, começando pelo `netservice`, com `pm uninstall -k --user 0`.
- Depois da remoção, reiniciar e conferir `pm list packages -3` para ver se algum pacote voltou.
- Bloquear os domínios no roteador: ver `blocklist.*` (hosts, dnsmasq, AdGuard, IP). Pendente: precisa do login do roteador.
- Considerar um factory reset de `/data` após o novo ROM. Isso não foi feito.

## Verificação externa (VirusTotal, só consulta por hash, 2026-10-24)

Nenhum arquivo foi enviado: consultei as páginas públicas pelos SHA-256 de `IOCs.md`.

| Pacote | Detecções | Rótulo dos antivírus |
|---|---|---|
| com.android.netservice | 14/67 | trojan, downloader, PUA (`trojan.ag1602137/ermz`) |
| com.hopper.rsshub.stb | 14/67 | PUA, hacktool, trojan (`pua.ag1597138/apprisk`) |
| com.device.config.provider | 8/67 | adlibrary, genwrisk (`ag1422485`) |
| com.systemguard.android | 7/66 | adware (`adware.adlibrary/general`) |
| com.androidsub.processes | 4/66 | adware, PUA, empacotado com Jiagu, Riskware.Testkey |

Leitura honesta:
- **Confirmado por vários antivírus como trojan/downloader:** apenas o `com.android.netservice` (14 de 67), o que bate com o comportamento de dropper visto no manifest.
- **Os demais são classificados como adware/PUA/riskware, com poucas detecções.** Não há consenso de "malware" nesses arquivos. O que sustenta a classificação deles aqui é o comportamento (instalação silenciosa, persistência, carga oculta, rastreio), não o veredito dos antivírus.
- Os outros APKs (`zxtv.service`, `lssa.service`, `android.tools`, `domain`, `core.rss` etc.) não foram consultados no VirusTotal.

### Correção sobre "proxy residencial"
- `systemguard.android`: o manifest declara componentes do pacote `com.honeygain.vobler.lib` (`RewardService`, `BootReceiver`). O código está empacotado com Jiagu, então **não consegui ler o comportamento**. A conclusão de "venda de banda" vem dos nomes dos componentes.
- `hopper.rsshub.stb`: o manifest tem `ProxyJsMonitorService` e classes `com.android.eapx.*`. Isso **sugere** um serviço de proxy, mas eu não confirmei no código.
- Para ter certeza seria preciso análise dinâmica (observar o tráfego do aparelho), que não foi feita.
