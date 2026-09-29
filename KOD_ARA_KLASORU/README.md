# KOD_ARA_KLASORU — cloud aynası

Lokal: `C:\KOD_ARA_KLASÖRÜ`  
Cloud/repo: `KOD_ARA_KLASORU/`

**Durum:** Senkronlandı (filtered kod dosyaları). ~150 dosya.

## Klasör haritası

| Klasör | Ne | Örnek dosya |
| --- | --- | --- |
| `dinamo/EFRM10/` | Dinamo form özelleştirme makroları | `OZAK_2026_EFRM10.txt` |
| `dinamo/MAKR8S/` | Dinamo MAKR8S | `OZAK_2026_MAKR8S.txt` |
| `dinamo/PFRM7S/` | Dinamo yazdırma / etiket | `OPR_2026_PFRM7S.txt` |
| `dinamo/REP17S/` | Dinamo rapor | `OZAK_2026_REP17S.txt` |
| `dinamo/RWSTDF/` | Standart satır | `OZAK_2026_RWSTDF.txt` |
| `dinamo/UAPP10/` | Uygulama | `OZAK_2026_UAPP10.txt` |
| `MAKR7S/` | Freedom/eski MAKR7S örnekleri (çok firma) | `OPS_2016_MAKR7S.txt`, `YILDIZ_2014_MAKR7S.txt` |
| `MAKR8S/` | Freedom MAKR8S | `ops_2023_makr8.txt` |
| `PFRM7S/` | Yazdırma örnekleri | `CAVO_2016_PFRM7S.txt` |
| `REP17S/` | Rapor | `BPRS13_REP17S.txt` |

Export özeti: `dinamo/_export_info.txt` (OZAK_2026: MAKR7S=192, PFRM7S=208, …)

## Bu klasörde aranacak kalıplar

**Zorunlu kural:** Dinamo / Freedom ERP kod veya fonksiyon aramalarında agent/geliştirici önce `KOD_ARA_KLASORU/` kullanır  
(Cursor: `.cursor/rules/dinamo-erp-kod-ara.mdc`).


```text
CreateTransactionalTableObject
CreateTableObject
CopyTable / SafePack / SetMustEnter
LoadMacroModule / RECCALC_IAFTERROWCHANGE
Setd7RowsetEventReplace
Frame_Refresh_Controls
RunSqlQuery / Select1 / Select2
LoadSubForm_Dyn
TMPCOPY
```

## Yeniden senkron

```powershell
cd ...\Mozan1
git checkout cursor/dinamo-erp-kod-kaliplari-onenote-2b90
powershell -ExecutionPolicy Bypass -File .\KOD_ARA_KLASORU\Sync-CodeOnly-And-Push.ps1
```

veya ASCII-safe tek satır blok (sohbet geçmişindeki paste).
