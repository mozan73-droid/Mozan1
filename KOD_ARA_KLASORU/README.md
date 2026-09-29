# KOD_ARA_KLASORU — cloud aynası

Lokal Windows yolu:

`C:\KOD_ARA_KLASÖRÜ`

Cloud / GitHub yolu (bu klasör):

`KOD_ARA_KLASORU/`

Cloud agent yerel `C:\` diskine erişemez. Dinamo/Freedom örnekleri buraya kopyalanınca agent ve PR’lar bu kopyayı kullanır.

## İlk doldurma (bilgisayarınızda)

### A) ZIP ile (önerilen)

1. `C:\KOD_ARA_KLASÖRÜ` klasörünü ZIP’leyin
2. Bu Cursor sohbetine ZIP’i yükleyin
3. Agent içeriği buraya açıp commit eder

### B) PowerShell senkron

Repo kökünde (bu branch checkout iken):

```powershell
powershell -ExecutionPolicy Bypass -File .\KOD_ARA_KLASORU\Sync-From-Local.ps1
git add KOD_ARA_KLASORU
git commit -m "Sync KOD_ARA_KLASORU from local C:\KOD_ARA_KLASÖRÜ"
git push
```

Varsayılan kaynak: `C:\KOD_ARA_KLASÖRÜ`  
İsteğe bağlı: `-Source "D:\baska\yol"`

## Kurallar

- Bu klasör **referans / arama** içindir; Oracle’a yazma yok
- Büyük binary / gizli bilgi (şifre, connection string) eklemeyin
- Sync sonrası OneNote referansı da bu kopyadan beslenir

## Durum

| Alan | Değer |
| --- | --- |
| Lokal kaynak | `C:\KOD_ARA_KLASÖRÜ` |
| Cloud hedef | `KOD_ARA_KLASORU/` (bu repo) |
| İçerik | Henüz senkron bekleniyor — ZIP yükleyin veya Sync script çalıştırın |
