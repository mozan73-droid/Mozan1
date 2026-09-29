# 09 · Doc metodları (cheat sheet)

## Tablo yaşam döngüsü

| Metod | Ne işe yarar |
| --- | --- |
| `Doc.CreateTableObject("AD=SEMA", "IO")` | Tek satır / STACK / E tablosu |
| `Doc.CreateTransactionalTableObject("AD=SEMA(NOFILE)", "IO")` | Çok satırlı grid |
| `Doc.GetTableObject("AD")` | Mevcut tablo |
| `Tbl.AddField2 ...` | Alan ekle |
| `Tbl.Empty` | Satırları temizle |
| `Tbl.CopyTable(Kaynak)` | Doldur |
| `Tbl.AddRow` / `SetCurrentRow` / `Refresh` | Satır + UI |
| `Tbl.SetMustEnter "ALAN", "E"` | Zorunlu alan |
| `Tbl.LoadMacroModule(...)` | Freedom satır event makrosu |
| `Tbl.GetRecCount` / `Tbl.RowCount` | Kayıt sayısı |

## Sorgu

| Metod | Not |
| --- | --- |
| `Doc.RunSqlQuery` / `RunSQLQuery` | Sonuç tablosu |
| `Doc.Select1` | Filtreli küçük sonuç |
| `Doc.Bugun` | Bugünün tarihi (kriter/SQL) |

## Form / UI

| Metod | Platform |
| --- | --- |
| `Doc.LoadSubForm_Dyn` | Alt form |
| `Doc.Frame_Refresh_Controls` | **Sadece Dinamo** |
| `Doc.MsgBox` / `MsgBox` | Uyarı |
| `Doc.Setd7RowsetEventReplace` | **Dinamo** satır event |

## Makro giriş noktaları (sık)

| Sub | Ne zaman |
| --- | --- |
| `INITDOCUMENT` | Form açılış — tablo yarat |
| `INITDOCUMENT_VALUES` | Rowset sonrası değer |
| `cmd_...` | Buton (`RUN_MODULE_PROC_NOCALC`) |
| `RECCALC_IAFTERROWCHANGE` | Freedom satır değişimi |
| `CALC_...` | Hesap / KTM callback |

## Buton bağlama

```
ID="RUN_MODULE_PROC_NOCALC('cmd_VySecim')"
```
