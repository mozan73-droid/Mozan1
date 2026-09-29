# 01 · Genel kurallar

## Goto yok

Freedom ve Dinamo makro dilinde **`Goto` / `GoTo` yoktur**.

| Yasak | Doğru alternatif |
| --- | --- |
| `GoTo Etiket` | `If` / `Else` / `Exit Sub` / `Exit Function` |
| `On Error Goto 0` | `On Error Resume Next` + `Err.Number` / `Err.Clear` |

```vb
On Error Resume Next
' ... riskli çağrı ...
If Err.Number <> 0 Then
	Err.Clear
	' fallback
	Exit Sub
End If
```

## Akış kontrolü

- Erken çıkış: `Exit Sub` / `Exit Function`
- Koşullu dallanma: `If` / `ElseIf` / `Else` / `End If`
- Döngü: `For` / `Next`, `Do While` / `Loop` (Goto ile etiket atlama yok)

## Oracle

Oracle veritabanına **doğrudan müdahale yok** (bağlantı, INSERT/UPDATE/DELETE, DDL).

İzinli:

- Freedom / Dinamo **makro XML** içinde `SELECT` / `RunSqlQuery` (kullanıcı import eder)
- Kullanıcının verdiği sorgu sonucunu yorumlamak

## Makro örnek klasörü

Yeni özellik (grafik, form kontrolü, kalıp) yazmadan önce:

`C:\KOD_ARA_KLASÖRÜ`

Benzer Dinamo/Freedom kullanımını bulup takip et.

## Parçalı kod notları

- Parçalı kod: **SRNUM** ile birleştir
- **UAPP10T2**’de `FORMKODU` yok
- **RWSTDF** anahtar: `ITEMCODE`
