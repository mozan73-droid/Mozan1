# 11 · Repo örnekleri (Mozan1)

Bu sayfa, repodaki canlı örneklere işaret eder. OneNote’ta link olarak tut; kod değişince buradan güncelle.

## OZAK — STOK40 VY seçim (STACK + alt form)

Klasör: `OZAK/STOK40_FO_KOD_GRUP_SECIMI/`

| Dosya | Ne gösterir |
| --- | --- |
| `STOK40.xml` | Import edilecek form + makrolar |
| `makro-vy-secim.txt` | `cmd_VySecim`, STACK seed, Grup map |
| `README.md` | Faz 1 davranış / import adımları |

Kalıplar:

- `CreateTableObject("VYSECIM_STACK=STACK")` + `AddField2`
- `Doc.Select1` ile `STOK00.GK_18`
- `Doc.LoadSubForm_Dyn "FRM_VYSECIM", ...`
- Dinamo tarafında `Frame_Refresh_Controls` kullanımı (XML içinde)

## PDKS — INIT + CopyTable + dashboard SQL

Klasör: `PDKS/`

| Dosya | Ne gösterir |
| --- | --- |
| `PDKS_Puantaj_Personel_Toplam_Makro.vbs` | `INITDOCUMENT`, STACK/NOFILE, çoklu `CopyTable` |
| `PDKS_Dashboard_sql_Duzeltilmis.txt` | Dashboard SQL + Empty/CopyTable |
| `PDKS_Personel_Listesi_Ekran_Makro.txt` | GRID `D=` + Listele butonu |
| `PDKS_Makrolar_Dinamo.txt` | Dinamo modül adları / entegrasyon notları |

Kalıplar:

```vb
Sub INITDOCUMENT
	Set MTABLET = Doc.CreateTransactionalTableObject("MAKROTABLET=STACK(NOFILE)", "IO")
	Set KRT = Doc.CreateTableObject("KRITERLER=STACK", "IO")
	...
End Sub
```

```vb
Set XDOLU = Doc.RunSQLQuery("X_DOLU", sql)
Set X = Doc.GetTableObject("X")
X.Empty
If XDOLU.GetRecCount > 0 Then
	X.CopyTable(XDOLU)
	X.SetCurrentRow 1
End If
```

## OneNote’ta etiket önerisi

- `#dinamo` `#freedom` `#grid` `#sql` `#stack` `#nofile` `#xml`
- Proje: `#ozak` `#pdks` `#stok40`
