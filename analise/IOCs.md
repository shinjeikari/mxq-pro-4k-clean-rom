# IOCs - MXQ Pro 4K (Allwinner H313/H616), análise de 2026-10-24

## SHA-256 dos APKs
54a9649ce848be2b29967179d462f8a6a6f5023498c1a9731101addff4c9aa96  com.android.assistant.setting.iknew
7943320c8ae3530e019b0bef2b6fb330f43bf34c8807b926209aca5d28faef99  com.android.assistant.setting.pro
5b029abe4ad2cd6dfa18064899b50190e00ce0f50bac57cbd849502ab3108f30  com.android.domain
33feb99dfca28f97aed5ef1cbcb1c9ebfe215fcb8c54c56cd79a7efcfac1e77f  com.android.netservice
9c453951e5fcf17edc7b656c5601e08b4961361c446ba5f4f1d0c2e13e3af9dc  com.android.tools
2c1fd37bfe7cf8241a42a8ecadc25c2068d93ddfe46c1f6a0ea1411bac4710f4  com.androidsub.processes
10dda4882e4ad735e521fb65a680dd7bbd5b898aa91e3041885be55f2163f9be  com.assisttools
d070fd928b8ae06e6532232904c6bbac0bdc21ce078e90295c5c1cbc11de5e97  com.core.rss
2fd339424dafbac3438a6e233ad9e8bb73572cbdc863eb5ff71dcb8cb545b6db  com.device.config.provider
c7f2f3f226dca3262e2c1744b5ed1a41a3d39c60936bd0e9f28a2c8b7f44640c  com.earn.rewards
341af9d96845efd9d61a6bf94d25fd12aa6bdf9d389986ddb216ca739863ee5e  com.google.android.services
e795f898552ca40c06ecf31330918d803793003da0aa6d69260a4536db7b5519  com.hopper.rsshub.stb
b64a401fe6051cf942802435a1f001601d66fa6e6debbf7395eaf6055f3af4de  com.kt.pad.apprmdir
a0113e5c2670c118067568f3cf24871f747efb98f08771baca8652b51b133a49  com.lssa.service
4cdac09608dc6f800bafc92dcfd9ad3c8e30918b6a305fed445c6205741f7ed9  com.preference.manager
72ecfc98f979bb1b15c4c277ee847a6a476749ef03db62c832a69980d64fbe24  com.systemguard.android
d153e727b9d08b1524136b17e26d019aa36022906da047ca7fc41150bba68399  com.zxtv.service
83e527a139e9b881329d4de9e45b47207981baf954635f3409d54581f45f5fe1  om.giggle.gigglegrove

## Domínios / hosts embutidos no código (extraídos de strings dos dex; não foram contatados)
- *.tentvs.com (channel-sdk, helper-sdk, timestamp-sdk, upload-sdk, upload-sdkuninstall, ip, l-helper, channel) — lssa.service, assistant.setting.*
- app.activity.trmaz.xyz:30133 — lssa.service
- ip.tvsetting.com — assistant.setting.*
- launcher.akrdinfo.cn:8742 — zxtv.service
- *.zeasn.tv (acc-saas, bd, ntp, acc-recommend...) — zxtv.service (SDK de anúncios "WhaleTV_AD_SDK")
- optimizerapi.long.tv, upload.mytvos.com — hopper.rsshub.stb
- 40.160.68.219 — com.android.tools
- f.m.suning.com/api/ct.do (consulta de hora/IP) e serviços de geolocalização por IP (ip-api.com, ipinfo.io, ifconfig.co, freeipapi.com, api.ip2location.io, freegeoip.app)
- DNS-over-HTTPS embutido (dns.google, cloudflare-dns.com, dns.alidns.com, doh.pub) e DNS 8.8.8.8/114.114.114.114/223.5.5.5 — netservice, domain, tools: contornam o DNS do roteador
## Certificados de assinatura
- Chave de TESTE pública do AOSP (CN=Android, android@android.com, 2008): netservice, domain, lssa.service, androidsub.processes, assistant.setting.*, preference.manager, gigglegrove. Qualquer um pode assinar com ela.
- CN=birch/O=runtime (cert criado 21/05/2026): device.config.provider
- CN=zhou/O=maysly, Shenzhen (2023): systemguard.android
- CN=earnmoney (2024): earn.rewards
- CN=sz, Shenzhen (2023): google.android.services
## Nomes de classes/SDK indicativos
- com.android.eapx.* (srvh/srvj, ProxyJsMonitorService) — hopper.rsshub.stb (serviço de proxy)
- com.honeygain.vobler.lib.* (RewardService) — systemguard.android (SDK de venda de banda/proxy residencial)
- com.zeasn.* (ad.connector, dynamic.plugin, plugin.installation) — zxtv.service
- com.ik.nebulasdk — domain
- libjiagu*.so (packer 360 Jiagu: oculta o código) — androidsub.processes, systemguard, earn.rewards, gigglegrove
- libterminal_pty.so (terminal/PTY nativo) — com.android.tools
