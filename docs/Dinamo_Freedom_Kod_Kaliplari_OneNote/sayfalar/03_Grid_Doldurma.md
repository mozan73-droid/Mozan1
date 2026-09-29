# 03 · Grid doldurma

## Doğru yöntem (CopyTable)

```vb
Set TblDolu = Doc.RunSqlQuery("TABLO_DOLU", SQL)
TrnTable.Empty
TrnTable.CopyTable(TblDolu)
TrnTable.SetCurrentRow 1
TrnTable.Refresh
```

PDKS / dashboard varyantı:

```vb
Set DASHBOARD1SQLDOLU = Doc.RunSQLQuery("DASHBOARD1_SQL_DOLU", sql)
Set DASHBOARD1SQL = Doc.GetTableObject("DASHBOARD1_SQL")
DASHBOARD1SQL.Empty

If DASHBOARD1SQLDOLU.GetRecCount > 0 Then
	DASHBOARD1SQL.CopyTable(DASHBOARD1SQLDOLU)
	Set DASHBOARD1SQLDOLU = Nothing
	DASHBOARD1SQL.SetCurrentRow 1
End If
```

## Ek satır (manuel)

```vb
Tbl.AddRow
Tbl.SetCurrentRow Tbl.RowCount
Tbl.OZELLIK = sOzellik
Tbl.SEC = "H"
```

İndekssiz alan atama: `Tbl.ALAN = deger` (current row).

## Yanlış yöntem

Sadece `CreateTableObject` / `CreateTransactionalTableObject` + `AddRow` ile grid doldurmak → **grid boş kalır**.

İstisna (Freedom): KTT_OTE kaydı yokken `SetRowAID` + For-Next bazen kullanılır; önce örnek klasörde doğrula.

## INITDOCUMENT kalıbı

```vb
Sub INITDOCUMENT
	Set KRT = Doc.CreateTableObject("KRITERLER=STACK", "IO")
	KRT.AddField2 "TCKIMLIKNO", "CHAR", 20, 0, "L", "", ""
	' ... diğer tablolar ...
	Call Personel_Listesi("Makro1")
End Sub

Sub INITDOCUMENT_VALUES
	' Rowsetler oluştuktan sonra değer / özellik
End Sub
```

## Refresh sırası

1. `Empty`
2. `CopyTable` (veya satır ekle)
3. `SetCurrentRow 1`
4. `Refresh`
5. **Dinamo:** gerekirse `Doc.Frame_Refresh_Controls`
6. **Freedom:** Frame_Refresh **çağırma**
