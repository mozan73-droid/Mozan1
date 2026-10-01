# 02 · Tablo nesneleri (NOFILE / STACK)

## Ne zaman hangisi?

| İhtiyaç | Kalıp | Metod |
| --- | --- | --- |
| Çok satırlı grid (STOK29T, SFDC32O, KTT_OTT, KTT_OTE…) | `...(NOFILE)` transactional | `CreateTransactionalTableObject` |
| Tek satır kriter / header (STOK29E, SFDC32E…) | `...(NOFILE)` table | `CreateTableObject` |
| Geçici STACK (bağlı tablo yok) | `NAME=STACK` veya `STACK(NOFILE)` | genelde `CreateTableObject` |

## Hata: 74533[TABLOADI]

Çok satırlı grid için yanlışlıkla `=STACK` kullanınca: **`74533[TABLOADI]`**.

Şema kaynağı **gerçek tablo** olsun; ek alanları `AddField2` ile ekle.

## Çok satırlı grid (doğru)

```vb
Set MTableXOP2 = Doc.CreateTransactionalTableObject("MTABLEX_OP2=SFDC32O(NOFILE)", "IO")
MTableXOP2.AddField2 "OPERATORADI", "CHAR", 50, 0, "L", "", ""
```

## Tek satır (kriter / giriş)

```vb
Set OTOKNTRL = Doc.CreateTableObject("OTOKONTROL=ZU_SFDC32E(NOFILE)", "IO")
```

## STACK (geçici, bağlı kayıt yok)

STACK seçim ekranı, sayaç alanları, basit kriter kutusu:

```vb
Set TblStack = Doc.CreateTableObject("VYSECIM_STACK=STACK", "IO")
TblStack.AddField2 "OZELLIK", "CHAR", 80, 0, "L", "", ""
TblStack.AddField2 "SEC", "CHAR", 1, 0, "L", "", ""
```

veya PDKS INIT örneği:

```vb
Set MTABLET = Doc.CreateTransactionalTableObject("MAKROTABLET=STACK(NOFILE)", "IO")
MTABLET.AddField2 "TerminalID", "CHAR", 4, 0, "L", "", ""

Set KRT = Doc.CreateTableObject("KRITERLER=STACK", "IO")
KRT.AddField2 "TCKIMLIKNO", "CHAR", 20, 0, "L", "", ""

Set MTABLEG = Doc.CreateTableObject("MTABLEGENEL=STACK", "IO")
MTABLEG.AddField2 "ToplamKayitSayisi", "DOUBLE", 3, 0, "R", "", ""
```

## SQL şemalı grid (CRM / MPS_SAT vb.)

Kolon aliasları GRID `D=` alanlarıyla **birebir** eşleşmeli:

```vb
Doc.RunSqlQuery "TABLO", SQL & " WHERE 1=0"
```

## AddField2 imzası (sık)

```vb
Tbl.AddField2 "ALANADI", "CHAR", 50, 0, "L", "", ""
' Tip: CHAR / DOUBLE / ...
' Hiza: "L" sol, "R" sağ
```

## Mevcut tabloyu al

```vb
Set KRT = Doc.GetTableObject("KRITERLER")
Set Tbl = Doc.GetTableObject("STOK40T")
If Tbl Is Nothing Then
	MsgBox "Tablo bulunamadi."
	Exit Sub
End If
```
