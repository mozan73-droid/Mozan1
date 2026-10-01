# 06 · SQL kalıpları (makro içi)

## WITH (CTE) yok

Makro SQL’de **`WITH` desteklenmez**.

Kullan: `EXISTS`, alt sorgu, `UNION`, türetilmiş tablo (`FROM (SELECT ...) x`).

```vb
' Yanlış
sql = "WITH x AS (SELECT ...) SELECT * FROM x"

' Doğru
sql = "SELECT Durum, COUNT(*) AS PersonelSayisi FROM (" & vbCrLf
sql = sql & "    SELECT ... FROM dbo.TABLO p WITH (NOLOCK) ..." & vbCrLf
sql = sql & ") x WHERE x.rn = 1 GROUP BY x.Durum"
```

Not: SQL Server’daki `WITH (NOLOCK)` tablo hint’idir; CTE `WITH` değildir — kullanılabilir.

## Turkish_BIN / büyük-küçük harf

```vb
sql = sql & " AND UPPER(kolon) LIKE '%KELIME%'"
```

## RunSqlQuery / RunSQLQuery

```vb
Set Tbl = Doc.RunSqlQuery("TABLO_ADI", SQL)
' veya
Set Tbl = Doc.RunSQLQuery("TABLO_ADI", SQL)
```

Şema-only (kolon üret):

```vb
Doc.RunSqlQuery "TABLO", SQL & " WHERE 1=0"
```

## Select1 (tek/küçük sonuç)

```vb
Set TblGk = Doc.Select1("vygk18", "STOK00", "KOD='" & Replace(sKod, "'", "''") & "'", "", -1)
If Not TblGk Is Nothing Then
	If TblGk.GetRecCount > 0 Then
		sGk18 = Trim(TblGk.GK_18(1))
	End If
End If
```

## SQL birleştirme kalıbı

```vb
sql = ""
sql = sql & "SELECT " & vbCrLf
sql = sql & "    g.Gun," & vbCrLf
sql = sql & "    g.TCKIMLIKNO AS SicilNo" & vbCrLf
sql = sql & "FROM dbo.TABLO g WITH (NOLOCK)" & vbCrLf
sql = sql & "WHERE 1=1 "
If Trim(KRT.TCKIMLIKNO) <> "" Then
	sql = sql & " AND g.TCKIMLIKNO = '" & Replace(Trim(KRT.TCKIMLIKNO), "'", "''") & "'"
End If
```

## Alias = GRID D=

`SELECT` kolon alias’ları form GRID `D="ALAN"` ile aynı olmalı; aksi halde grid boş/yanlış bağlanır.

## Oracle notu

Makro XML içinden `SELECT` / `RunSqlQuery` yazılabilir (kullanıcı import eder). Agent/araç ile Oracle’a bağlanıp yazma **yasak**.
