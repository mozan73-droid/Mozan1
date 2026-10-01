# 12 ? KOD_ARA kaynak haritas? + canl? ?rnekler

Kaynak: repo `KOD_ARA_KLASORU/` (= lokal `C:\KOD_ARA_KLAS?R?` filtered kopya).

## Nerede ne ara?

| Kal?p | ?nce bak |
| --- | --- |
| Dinamo `Frame_Refresh_Controls`, onay, alt form | `dinamo/EFRM10/OZAK_2026_EFRM10.txt` |
| Dinamo Select1 / RunSqlQuery / BeforeSave | `dinamo/MAKR8S/OZAK_2026_MAKR8S.txt` |
| Dinamo TMPCOPY + CopyTable + SafePack (etiket) | `dinamo/PFRM7S/OPR_2026_PFRM7S.txt` |
| Freedom `LoadMacroModule` + `RECCALC_IAFTERROWCHANGE` | `MAKR7S/OPS_2016_MAKR7S.txt` |
| Freedom `Setd7RowsetEventReplace AFTERROWCHANGE` | `MAKR7S/OPS_2016_MAKR7S.txt` (~21594) |
| `CreateTransactionalTableObject` + NOFILE + AddField2 | `MAKR7S/YILDIZ_2014_MAKR7S.txt` |
| `SetMustEnter` + `SafePack` | `MAKR7S/HAK6_2014_MAKR7S.txt`, `OPS_2016_MAKR7S.txt` |

## ?rnek 1 ? Freedom sat?r de?i?imi (LoadMacroModule)

`MAKR7S/OPS_2016_MAKR7S.txt`:

```vb
LST2X.LoadMacroModule("MAKR7S." + "@@@BUMAKRO@@@")

Sub RECCALC_IAFTERROWCHANGE
	Set S40LST = Doc.GetTableObject("STOK40T_LISTESI2")
	Set MTABLE = Doc.GetTableObject("MAKROTABLE")
	StokKodu = S40LST.KOD
	' ... detay doldur ...
End Sub
```

Ba?ka kullan?m:

```vb
LISTETX.LoadMacroModule("MAKR7S." + "@@@BUMAKRO@@@")

Sub RECCALC_IAFTERROWCHANGE
	Set LST = Doc.GetTableObject("LISTET")
	Set MTableT = Doc.GetTableObject("MAKROTABLESP")
	MTableT.Empty
	EvrakNoValue = LST.EVRAKNO
	If EvrakNoValue = "" Then Exit Sub
	' ...
End Sub
```

## ?rnek 2 ? Dinamo AFTERROWCHANGE (Setd7)

Ayn? OPS dosyas?nda Dinamo tarz? event:

```vb
MTableDepo.Setd7RowsetEventReplace "AFTERROWCHANGE", "MAKR7S." & SC_SCRIPTMODULEFILENAME, "MAFTERROWCHANGE"
```

Freedom?da tercih: LoadMacroModule + RECCALC. Dinamo?da Setd7 s?k g?r?l?r.

## ?rnek 3 ? NOFILE transactional + AddField2

`MAKR7S/YILDIZ_2014_MAKR7S.txt`:

```vb
Set MTableT = Doc.CreateTransactionalTableObject("MAKROTABLEMG=STOK01(NOFILE)", "IO")
MTableT.Addfield2 "SELECTED", "CHAR", 1, 0, "L", "", ""
MTableT.Addfield2 "STOK_MIKTAR1", "DOUBLE", 12, 3, "R", "", ""
MTableT.Addfield2 "ONAYLANAN_MIKTAR", "DOUBLE", 12, 3, "R", "", ""

Set ESL_ET = Doc.CreateTransactionalTableObject("ESL_LIST_XXX=CRHESLE(NOFILE)", "IO")

Set MTableT = Doc.CreateTransactionalTableObject("MAKROTABLET=STOK26T(NOFILE)", "IO")
MTableT.Addfield2 "MT_PROJEKODU", "CHAR", 24, 0, "L", "", ""
```

STACK varyant?:

```vb
Set MTableT = Doc.CreateTransactionalTableObject("MAKROTABLET=STACK", "IO")
MTableT.Addfield2 "OP_NO", "CHAR", 10, 0, "L", "", ""
MTableT.Addfield2 "KOD", "CHAR", 24, 0, "L", "F2=DO_BRW('STOK00')", ""
```

## ?rnek 4 ? TMPCOPY + CopyTable (Dinamo PFRM)

`dinamo/PFRM7S/OPR_2026_PFRM7S.txt`:

```vb
Doc.CreateTableObject "XXXSTOK20T25=STOK20T", "TMPCOPY"
Set S20T = Doc.GetTableObject("XXXSTOK20T25")

Doc.CreateTableObject "YYYSTOK20T25=STOK20T", "TMPCOPY"
Set S20T1 = Doc.GetTableObject("YYYSTOK20T25")
S20T1.CopyTable(S20T)
S20T.GroupBy("SF_VRI_NUM2+SF_VRI_NUM1")
S20T.Sort("SERINO")
```

## ?rnek 5 ? SafePack + SetMustEnter

```vb
' HAK6
MTableDT.SetMustEnter "DURUS_SEBEBI", "E"
MTableDT.SafePack

' OPS ? zorunlu kolon
KTT_T.SetMustEnter "KOLONNO", "E"

' OPS ? kumulatif
K_Table.SetMustEnter "STOKKODU", "E"
```

Zorunlu alan yokken SafePack tabloyu bo?altabilir ? dikkat.

## ?rnek 6 ? Dinamo Frame_Refresh + LoadSubForm

`dinamo/EFRM10/OZAK_2026_EFRM10.txt`:

```vb
Doc.SetFormControlProperty "", "BTN_ONAY_1", "BCKCOL", "YELLOW"
Doc.Frame_Refresh_Controls

Sub cmd_Onaydetayi
	Dim Par
	Set Par = Nothing
	Doc.LoadSubForm_Dyn "FRM_ONAYDETAY", "EFRM10." & SC_SCRIPTMODULEFILENAME, Par
End Sub
```

Freedom?da `Frame_Refresh_Controls` yok.

## ?rnek 7 ? Select1 + RunSqlQuery (OZAK MAKR8S)

```vb
Set U12 = Doc.Select1("de443d44t", "UDEFT12", _
	"KOD='" & Doc.Getd7UserName() & "'&OZEL_HAK_KODU='" & HakKodu & "'", "", -1)
If U12.GetRowCount() > 0 Then OzelHakVarMi = True

Set SVS00SQLOZET = Doc.RunSQLQuery("SVS00_SQL_OZET", SQL)
```

## Arama ipucu (ripgrep / Cursor)

```text
path:KOD_ARA_KLASORU CreateTransactionalTableObject
path:KOD_ARA_KLASORU/dinamo Frame_Refresh_Controls
path:KOD_ARA_KLASORU/MAKR7S LoadMacroModule
```
