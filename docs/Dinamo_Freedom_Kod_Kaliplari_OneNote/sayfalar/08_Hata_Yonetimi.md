# 08 · Hata yönetimi

## Standart kalıp

```vb
On Error Resume Next

Set Tbl = Doc.GetTableObject("STOK40T")
If Tbl Is Nothing Then
	MsgBox "STOK40T satiri bulunamadi."
	Exit Sub
End If

sKod = Trim(Tbl.KOD)
If Err.Number <> 0 Then
	Err.Clear
	sKod = ""
End If

If sKod = "" Then
	MsgBox "Satir stok kodu bos."
	Exit Sub
End If
```

## Kurallar

- `On Error Goto` **kullanma**
- Hata sonrası: `Err.Clear` (eski hata numarası kalmasın)
- Kullanıcıya kısa `MsgBox`; sonra `Exit Sub`
- Nested riskli bloklarda her kritik atamada `Err.Number` kontrol et

## Nothing kontrolleri

```vb
If TblStack Is Nothing Then
	Err.Clear
	Set TblStack = Doc.CreateTableObject("VYSECIM_STACK=STACK", "IO")
End If
If TblStack Is Nothing Then
	MsgBox "VYSECIM_STACK olusturulamadi."
	Exit Sub
End If
```

## SQL / CopyTable sonrası

```vb
If TblDolu.GetRecCount > 0 Then
	TrnTable.CopyTable(TblDolu)
	TrnTable.SetCurrentRow 1
Else
	TrnTable.Empty
End If
TrnTable.Refresh
```
