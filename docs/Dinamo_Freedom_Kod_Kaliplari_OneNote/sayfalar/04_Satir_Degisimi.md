# 04 · Satır değişimi (Freedom vs Dinamo)

## Freedom — LoadMacroModule + RECCALC

`Setd7RowsetEventReplace "AFTERROWCHANGE"` **KULLANMA**.

Grid tablosuna makro modülü bağla; satır değişince `RECCALC_IAFTERROWCHANGE` çalışır.

Hangi grid: `t.getappname`.

```vb
Tbl.LoadMacroModule("MAKR7S." + "@@@BUMAKRO@@@")

Sub RECCALC_IAFTERROWCHANGE
	If t.getappname = "MAKROTABLE_OTEOZET" Then
		Call DetayListeDoldur
	End If
End Sub
```

## Dinamo — Setd7RowsetEventReplace

Dinamo’da satır değişimi için:

```vb
Doc.Setd7RowsetEventReplace "AFTERROWCHANGE", ...
```

(Freedom’da bu yol farklı / kullanılmaz — yukarıdaki LoadMacroModule kalıbını kullan.)

## Pratik kontrol listesi

| Soru | Freedom | Dinamo |
| --- | --- | --- |
| AFTERROWCHANGE event replace? | Hayır | Evet (Setd7…) |
| LoadMacroModule + RECCALC? | Evet | Örnek klasörde doğrula |
| Grid kimliği | `t.getappname` | Event / tablo adına göre |

## Tipik kullanım

Özet grid satırı değişince detay gridini yeniden doldur:

```vb
Sub RECCALC_IAFTERROWCHANGE
	If t.getappname = "MAKROTABLE_OTEOZET" Then
		Call DetayListeDoldur
	End If
End Sub
```
