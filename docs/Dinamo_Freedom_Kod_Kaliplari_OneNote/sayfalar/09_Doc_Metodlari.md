# 09 · Doc metodları (cheat sheet + KOD_ARA)

## Tablo

| Metod | Örnek kaynak |
| --- | --- |
| `CreateTableObject("AD=SEMA", "IO")` | STACK kriter |
| `CreateTableObject("AD=SEMA", "TMPCOPY")` | `dinamo/PFRM7S/OPR_2026_PFRM7S.txt` |
| `CreateTransactionalTableObject("AD=TABLO(NOFILE)", "IO")` | `MAKR7S/YILDIZ_2014_MAKR7S.txt` |
| `CreateTransactionalTableObject("AD=STACK", "IO")` | aynı |
| `GetTableObject` / `Empty` / `CopyTable` / `AddRow` / `DeleteRow` | PDKS + KOD_ARA |
| `AddField2` / `Addfield2` | her yerde (yazım varyantı) |
| `SetMustEnter` / `SafePack` | HAK6, OPS |
| `GroupBy` / `GroupBy2` / `Sort` | PFRM etiket |
| `LoadMacroModule` | OPS_2016 Freedom |
| `Setd7RowsetEventReplace` | OPS_2016 / Dinamo |
| `Setd7FieldEvent` | YILDIZ STOK26E AFTERVALIDATE |

## Sorgu

| Metod | Not |
| --- | --- |
| `RunSqlQuery` / `RunSQLQuery` | OZAK MAKR8S SVS00_* |
| `Select1` | tek/filtre — OZAK her yerde |
| `Select2` / `Select2G` | çok satır filtre |
| `GetDBFieldValue` / `GetDbFieldValue` | tek alan |
| `GetUDFValue` | UDF |

## Form / UI

| Metod | Platform |
| --- | --- |
| `Frame_Refresh_Controls` | Dinamo only |
| `SetFormControlProperty` | Dinamo EFRM10 onay butonları |
| `LoadSubForm_Dyn` | FRM_ONAYDETAY, FRM_VYSECIM |
| `Save_Voucher` | evrak kaydet |
| `d7MsgBox` / `MsgBox` | onay diyalog |
| `RunMacro0` / `RunMacro2` | makrolar arası |
| `StatusBarMessage` | uzun döngü |
| `Getd7UserName` | yetki |
| `Bugun` / `Saat` | tarih saat |

## Makro giriş noktaları

| Sub/Function | Ne zaman |
| --- | --- |
| `INITDOCUMENT` / `Makro1` | açılış / şema |
| `cmd_*` | buton |
| `RECCALC_IAFTERROWCHANGE` | Freedom satır |
| `BeforeSave` / `BeforeCommand` | kayıt öncesi (OZAK) |
| `CALC_*` | hesap |

## Buton

```
ID="RUN_MODULE_PROC_NOCALC('cmd_Personel_Listesi')"
```
