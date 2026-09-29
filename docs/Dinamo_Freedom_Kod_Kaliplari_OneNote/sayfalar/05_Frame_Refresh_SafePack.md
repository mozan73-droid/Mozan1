# 05 · Frame_Refresh_Controls & SafePack — KOD_ARA örnekleri

## Frame_Refresh_Controls (yalnızca Dinamo)

Kaynak: `KOD_ARA_KLASORU/dinamo/EFRM10/OZAK_2026_EFRM10.txt`

```vb
Doc.SetFormControlProperty "", "BTN_ONAY_1", "BCKCOL", "YELLOW"
Doc.SetFormControlProperty "", "BTN_ONAY_1", "TXTCOL", "BLACK"
Doc.SetFormControlProperty "", "BTN_ONAY_1", "READONLY", 0
Doc.Frame_Refresh_Controls
```

Onay sonrası:

```vb
Call OnayYetkiKontrol
nret = Doc.Save_Voucher
Doc.Frame_Refresh_Controls
```

`dinamo/MAKR8S/OZAK_2026_MAKR8S.txt` içinde de tekrarlanır.

### Freedom

**ÇAĞIRMA.** Hata: `Doc.Frame_Refresh_Controls` → `0x800A01B6`.

## SafePack

Kaynak örnekler: `MAKR7S/HAK6_2014_MAKR7S.txt`, `OPS_2016_MAKR7S.txt`, `YILDIZ_2014_MAKR7S.txt`, `dinamo/PFRM7S/OPR_2026_PFRM7S.txt`

### Doğru sıra (zorunlu alan var)

```vb
MTableDT.SetMustEnter "DURUS_SEBEBI", "E"
MTableDT.SafePack
KayitSayisi = MTableDT.GetRecCount
```

```vb
KTT_T.SetMustEnter "KOLONNO", "E"
```

```vb
K_Table.SetMustEnter "STOKKODU", "E"
```

### Dinamo etiket / fiş

```vb
S25T.SafePack
For i = 1 To S25T.GetRowCount()
	Doc.StatusBarMessage "Etiket Bilgileri Guncelleniyor : " & i
	' ...
Next
```

```vb
STOK60T.SafePack()
Set S60T = Doc.Select2("XXX_STOK60T_KASA", "STOK60T", "FATURASIZMI<>'E'", "", -1)
```

### Uyarı

Zorunlu alan **yoksa** SafePack tabloyu boşaltabilir. `RunSqlQuery` şemasında SetMustEnter varsayılan gelmez.

STACK seçim ekranları (VYSECIM): genelde SafePack **yok**.
