# 04 · Satır değişimi (Freedom vs Dinamo) — KOD_ARA örnekleri

## Freedom — LoadMacroModule + RECCALC

Kaynak: `KOD_ARA_KLASORU/MAKR7S/OPS_2016_MAKR7S.txt`

`Setd7RowsetEventReplace "AFTERROWCHANGE"` Freedom’da **kullanma** (tercih edilen kalıp aşağıda).

```vb
' Grid tablosuna makro bagla
LST2X.LoadMacroModule("MAKR7S." + "@@@BUMAKRO@@@")

Sub RECCALC_IAFTERROWCHANGE
	Set S40LST = Doc.GetTableObject("STOK40T_LISTESI2")
	Set MTABLE = Doc.GetTableObject("MAKROTABLE")
	StokKodu = S40LST.KOD
	' Satir degisince detay / ozet yenile
End Sub
```

Liste grid örneği:

```vb
LISTETX.LoadMacroModule("MAKR7S." + "@@@BUMAKRO@@@")

Sub RECCALC_IAFTERROWCHANGE
	Set LST = Doc.GetTableObject("LISTET")
	Set MTableT = Doc.GetTableObject("MAKROTABLESP")
	MTableT.Empty
	EvrakNoValue = LST.EVRAKNO
	If EvrakNoValue = "" Then Exit Sub
	' EvrakNoValue ile detay SQL / Select ...
End Sub
```

Hangi grid? `t.getappname` (Freedom) ile ayırt et.

## Dinamo — Setd7RowsetEventReplace

Aynı OPS dosyasında Dinamo tarzı:

```vb
MTableDepo.Setd7RowsetEventReplace _
	"AFTERROWCHANGE", _
	"MAKR7S." & SC_SCRIPTMODULEFILENAME, _
	"MAFTERROWCHANGE"
```

OZAK Dinamo EFRM10 onay UI yenilemesi satır event’ten bağımsız `Frame_Refresh_Controls` kullanır (bkz. sayfa 05 / 12).

## Karşılaştırma

| | Freedom | Dinamo |
| --- | --- | --- |
| Satır değişimi | `LoadMacroModule` + `RECCALC_IAFTERROWCHANGE` | `Setd7RowsetEventReplace "AFTERROWCHANGE", ...` |
| Grid kimliği | `t.getappname` | Event / tablo adı |
| UI yenile | `Refresh` | + `Frame_Refresh_Controls` |

## İskelet (yeni makro)

```vb
' INIT / Makro1 icinde:
Tbl.LoadMacroModule("MAKR7S." + "@@@BUMAKRO@@@")

Sub RECCALC_IAFTERROWCHANGE
	If t.getappname = "MAKROTABLE_OTEOZET" Then
		Call DetayListeDoldur
	End If
End Sub
```
