# 10 · Dinamo vs Freedom — farklar

Hızlı referans tablosu. Ayrıntılar ilgili sayfalarda.

| Konu | Dinamo | Freedom |
| --- | --- | --- |
| `Goto` | Yok | Yok |
| `Frame_Refresh_Controls` | Var — grid sonrası çağır | **Yok** — çağırma (0x800A01B6) |
| Satır değişimi | `Setd7RowsetEventReplace "AFTERROWCHANGE"` | `LoadMacroModule` + `RECCALC_IAFTERROWCHANGE` |
| Çok satırlı NOFILE | `CreateTransactionalTableObject` | Aynı mantık; örnek klasörde doğrula |
| SafePack | Zorunlu alan varsa | Aynı kural |
| SQL CTE (`WITH`) | Desteklenmez | Desteklenmez |
| Oracle doğrudan yazma | Yasak (agent) | Yasak (agent) |

## Ortak doğru kalıplar

1. Grid: `RunSqlQuery` → `Empty` → `CopyTable` → `SetCurrentRow` → `Refresh`
2. Hata: `On Error Resume Next` + `Err.Number` / `Err.Clear`
3. Şema: gerçek tablo + `AddField2`; çok satırda yanlış `=STACK` → 74533
4. GRID `D=` = SQL alias

## Platform seçerken

Yeni makro yazarken önce hedefi netleştir:

- Dinamo mı Freedom mı?
- Grid mi kriter mi?
- Satır değişiminde detay yenilenecek mi?

Sonra `C:\KOD_ARA_KLASÖRÜ` içinde aynı platformdan örnek aç.
