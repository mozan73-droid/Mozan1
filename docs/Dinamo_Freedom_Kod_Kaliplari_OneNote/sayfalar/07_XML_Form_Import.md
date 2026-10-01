# 07 · XML / form import

## Karakter seti

- Saf **ASCII** tercih et
- Türkçe yol / metin: `Chr(214)`, `Chr(220)` vb. (Ö, Ü…)

```vb
' Örnek: SOĞUTUCU eşlemesi
If InStr(1, s, "SOGUT") > 0 Or InStr(1, s, "S" & Chr(208) & "TC") > 0 Then
	' ...
End If
```

## SELECTVALUE

Harf kullan: **V**, **H** — rakam değil.

## Form GRID (XML / form dili)

```
GRID LEFT=10P TOP=E+1P W=S%90 H=S%74 TABLE=PERSONELLISTESI_SQL HEADERROWHEIGHT=DEFAULT NOEDIT=Y
	EDITTEXT D="TCKIMLIKNO" CAPTION="Sicil ID (TC)" W=120P
	EDITTEXT D="KOD" CAPTION="Kod" W=120P
ENDGRID
BUTTON ... CAPTION="Listele" ID="RUN_MODULE_PROC_NOCALC('cmd_personel_listesi')"
```

- `D=` alan adları SQL alias / tablo alanıyla eşleşmeli
- Buton: `RUN_MODULE_PROC_NOCALC('SubAdi')`

## Alt form yükleme

```vb
Dim Par
Set Par = Nothing
Doc.LoadSubForm_Dyn "FRM_VYSECIM", "EFRM10." & SC_SCRIPTMODULEFILENAME, Par
```

## Import kontrol listesi

1. Mevcut formu **yedekle**
2. XML’i Dinamo form özelleştirme yolundan import et
3. Formu kaydet, ekranı yeniden aç
4. Smoke test (buton → beklenen MsgBox / grid)

## STOK40 örneği (repo)

- Canlı kaynak: `OZAK/STOK40_FO_KOD_GRUP_SECIMI/STOK40.xml`
- Alt form gömülü olabilir (`FRM_VYSECIM`); ayrı kayıt gerekmeyebilir
- Referans kopyalar: `FORM_VYSECIM.xml`, `makro-vy-secim.txt`
