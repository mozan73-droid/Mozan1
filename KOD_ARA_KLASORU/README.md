# KOD_ARA_KLASORU — cloud aynası

Lokal Windows yolu:

`C:\KOD_ARA_KLASÖRÜ`

Cloud / GitHub yolu (bu klasör):

`KOD_ARA_KLASORU/`

Cloud agent yerel `C:\` diskine erişemez. Dinamo/Freedom örnekleri buraya kopyalanınca agent ve PR’lar bu kopyayı kullanır.

## İlk doldurma (bilgisayarınızda)

### A) Sohbet 10MB limiti — önerilen: git push (limitsiz pratikte)

Repo kökünde, bu branch’teyken:

```powershell
git checkout cursor/dinamo-erp-kod-kaliplari-onenote-2b90
powershell -ExecutionPolicy Bypass -File .\KOD_ARA_KLASORU\Sync-CodeOnly-And-Push.ps1
```

Bu script yalnızca `.txt .vbs .bas .xml .sql .md …` kod dosyalarını alır (pdf/exe/resim yok), `KOD_ARA_KLASORU/` içine koyar ve **commit + push** eder. Cloud agent hemen kullanır.

### B) Küçük ZIP (sohbete Attach, max ~10MB)

```powershell
powershell -ExecutionPolicy Bypass -File .\KOD_ARA_KLASORU\Sync-CodeOnly-And-Push.ps1 -ZipOnly
```

Masaüstünde `KOD_ARA_kod.zip` oluşur. 10MB altındaysa sohbete Attach edin.

### C) Tam klasör kopyası (ağır dosyalar dahil)

```powershell
powershell -ExecutionPolicy Bypass -File .\KOD_ARA_KLASORU\Sync-From-Local.ps1
git add KOD_ARA_KLASORU
git commit -m "Sync KOD_ARA_KLASORU from local"
git push
```

Tam ZIP sohbete **yüklenemez** (10MB limit) — push kullanın.

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
