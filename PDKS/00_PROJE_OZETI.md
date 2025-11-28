# PDKS Projesi - Tüm Çalışma Özeti

## Tarih: 2025-11-28

## Yapılan Çalışmalar

### 1. Çalışma Süresi Hesaplama Sorunu Tespiti ve Düzeltme

**Sorun**: PDKS sisteminde çalışma süreleri hatalı hesaplanıyordu. Özellikle gece vardiyasında çıkış saati ertesi günün 01:30'u olduğunda normalize edilmiş günün sonuna kadar hesaplanması gerekiyordu.

**Dosya**: `Test_Sorgu_4066_26-27_Kasim.sql`
- 4066 Sicil ID'li personel için test sorgusu
- Giriş/çıkış saatleri kontrolü
- Çalışma süresi hesaplamaları (gerçek ve normalize edilmiş)
- Çıkış saati gösterimi düzeltildi (ertesi günün 01:30'u → 25:30 olarak gösteriliyor)

### 2. Link Server Terminal Filtreleme Sorunu ve Çözümü

**Sorun**: Link server'dan cache tablosuna veri aktarırken sadece 1093 ve 1094 terminalleri alınıyordu. Yeni terminaller eklendiğinde merge sorgusunu güncellemek gerekiyordu.

**Çözüm**: Ayar tablosu (ZU_P_AYARE ve ZU_P_AYART) kullanılarak dinamik filtreleme yapılıyor.

### 3. Cache Tablosu Kayıt Sayısı Sorunu ve Çözümü

**Sorun**: COUNT(*) sorgusu 24193 kayıt gösterirken, SELECT * sorgusu 403918 kayıt gösteriyordu. Bu farklılık statistics veya duplicate ID'lerden kaynaklanıyor olabilirdi.

**Çözüm**: 
- Statistics kontrolü ve güncelleme scriptleri oluşturuldu
- Duplicate ID kontrolü ve temizleme scriptleri hazırlandı
- Sorun otomatik olarak düzeldi (muhtemelen SQL Server statistics'leri otomatik güncelledi)

**Dosyalar**:
- `PDKS_Cache_Tablo_Kayit_Sayisi_Kontrol.sql`: Detaylı analiz
- `PDKS_Cache_Tablo_Kayit_Sayisi_Kontrol_Basit.sql`: Basit kontrol
- `PDKS_Cache_Duplicate_ID_Hizli_Kontrol.sql`: Hızlı duplicate kontrolü
- `PDKS_Cache_Tablo_Duplicate_ID_Temizleme.sql`: Duplicate temizleme

**Dosyalar**:
- `PDKS_Merge_Sorgu_Duzeltilmis.sql`: Ayar tablosunu kullanan merge sorgusu
- `PDKS_Cache_Tablo_Silme.sql`: Cache tablosunu temizleme scripti
- `PDKS_Terminal_Konfigurasyon_Tablo.sql`: Alternatif konfigürasyon tablosu (opsiyonel)

**Avantajlar**:
- Ayar tablosunda (ZU_P_AYARE.AP10 = 1) aktif olan TerminalID'lere göre filtreleme
- Yeni terminal eklendiğinde sadece ayar tablosunu güncellemek yeterli
- Merge sorgusunu değiştirmeye gerek yok
- Sadece TerminalID'ye göre filtreleme (TerminalYonu dikkate alınmıyor)

## Oluşturulan/Güncellenen Dosyalar

### Ana Dosyalar

1. **Test_Sorgu_4066_26-27_Kasim.sql**
   - Çalışma süresi hesaplama test sorgusu
   - Giriş/çıkış saatleri kontrolü
   - Normalize edilmiş çıkış saati gösterimi

2. **PDKS_Merge_Sorgu_Duzeltilmis.sql** ⭐ (ANA DOSYA)
   - Link server'dan cache tablosuna veri aktarma
   - Ayar tablosu (ZU_P_AYARE ve ZU_P_AYART) kullanıyor
   - Sadece TerminalID'ye göre filtreleme
   - Sadece 2025 ve sonrası veriler alınıyor

3. **PDKS_Terminal_Konfigurasyon_Tablo.sql**
   - PDKS_TERMINAL_KONFIGURASYON tablosu oluşturma
   - Link server'dan otomatik terminal aktarma
   - Terminal yönetimi örnekleri

4. **PDKS_Terminal_Konfigurasyon_README.md**
   - Sistem kullanım kılavuzu
   - Örnek sorgular
   - Sorun giderme

### Yardımcı Dosyalar

5. **Link_Server_Terminal_Kontrol.sql**
   - Link server'da hangi terminallerin olduğunu kontrol etme

6. **PDKS_Cache_Tablo_Doldurma.sql**
   - Cache tablosuna veri aktarma alternatif yöntemleri

7. **PDKS_Cache_Tablo_Silme.sql** ⭐
   - Cache tablosunu temizleme scripti
   - DELETE veya TRUNCATE seçenekleri
   - Doğrulama kontrolleri

8. **PDKS_Cache_Tablo_Kayit_Sayisi_Kontrol.sql** ⭐
   - Cache tablosu kayıt sayısı kontrolü
   - Statistics ve index analizi
   - View kontrolü
   - Tablo boyutu analizi

9. **PDKS_Cache_Tablo_Kayit_Sayisi_Kontrol_Basit.sql**
   - Basit kayıt sayısı kontrolü
   - Duplicate ID kontrolü
   - Tarih ve terminal bazlı analiz

10. **PDKS_Cache_Duplicate_ID_Hizli_Kontrol.sql**
    - Duplicate ID hızlı kontrol
    - SSMS görüntüleme kontrolü
    - View kontrolü

11. **PDKS_Cache_Tablo_Duplicate_ID_Temizleme.sql**
    - Duplicate ID temizleme scripti
    - En son kaydı tutup diğerlerini silme
    - Statistics güncelleme

## Sistem Mimarisi

```
Link Server (PDKS_LS)
    ↓
vw_PDKS_OlayDetay_Bolum3ve6
    ↓
Ayar Tabloları (ZU_P_AYARE + ZU_P_AYART)
    ├── AP10 = 1 (Aktif olanlar)
    └── TerminalID (Filtreleme)
    ↓
MERGE Sorgusu
    ├── EventTime >= '2025-01-01'
    └── KayitZamani >= SonAktarim
    ↓
PDKS_HAMDATA_CACHE
    ↓
PDKS Raporları ve Sorguları
```

## Ayar Tabloları Yapısı

**ZU_P_AYARE** (Ana Ayar Tablosu)
- AP10 = 1 → Aktif ayarlar

**ZU_P_AYART** (Ayar Detay Tablosu)
- EVRAKNO → ZU_P_AYARE ile ilişki
- TerminalID → Filtreleme için kullanılan TerminalID
- TerminalYonu → Bilgi amaçlı (filtrelemede kullanılmıyor)

**Kullanım:**
```sql
SELECT ayart.TerminalID, ayart.TerminalYonu
FROM ZU_P_AYARE ayare
LEFT JOIN ZU_P_AYART ayart ON ayart.EVRAKNO = ayare.EVRAKNO
WHERE ayare.AP10 = 1
  AND ayart.TerminalID IS NOT NULL
```

## Kullanım Senaryoları

### Senaryo 1: Yeni Terminal Ekleme

```sql
-- Ayar tablosuna yeni terminal ekleme
-- ZU_P_AYARE tablosuna yeni kayıt ekleyin (AP10 = 1)
-- ZU_P_AYART tablosuna TerminalID ve TerminalYonu bilgilerini ekleyin
```

### Senaryo 2: Terminal Pasif Etme

```sql
-- Ayar tablosunda terminali pasif etme
UPDATE dbo.ZU_P_AYARE
SET AP10 = 0
WHERE EVRAKNO IN (
    SELECT EVRAKNO 
    FROM dbo.ZU_P_AYART 
    WHERE TerminalID = '1093'
);
```

### Senaryo 3: Cache Tablosunu Temizleme

```sql
-- PDKS_Cache_Tablo_Silme.sql dosyasını çalıştırın
-- Veya direkt:
DELETE FROM dbo.PDKS_HAMDATA_CACHE;
```

### Senaryo 4: Çalışma Süresi Kontrolü

```sql
-- Test_Sorgu_4066_26-27_Kasim.sql dosyasını çalıştırın
-- Belirli bir personel için giriş/çıkış ve çalışma sürelerini kontrol edin
```

### Senaryo 5: Cache Tablosu Kayıt Sayısı Sorunu

```sql
-- Eğer COUNT(*) ve SELECT * farklı sayılar gösteriyorsa:
-- 1. PDKS_Cache_Duplicate_ID_Hizli_Kontrol.sql çalıştırın
-- 2. Duplicate ID'ler varsa PDKS_Cache_Tablo_Duplicate_ID_Temizleme.sql kullanın
-- 3. Statistics güncelleyin: UPDATE STATISTICS dbo.PDKS_HAMDATA_CACHE WITH FULLSCAN;
```

## Önemli Notlar

1. **Terminal Filtreleme**: Ayar tablosundaki (ZU_P_AYARE.AP10 = 1) aktif TerminalID'lere göre filtreleme yapılıyor
2. **Sadece TerminalID**: TerminalYonu dikkate alınmıyor, sadece TerminalID'ye göre filtreleme yapılıyor
3. **2025 Kriteri**: Sadece 2025 ve sonrası veriler alınıyor (EventTime >= '2025-01-01')
4. **Ayar Tablosu**: Yeni terminal eklendiğinde sadece ayar tablosunu güncellemek yeterli, merge sorgusunu değiştirmeye gerek yok
5. **Çalışma Süresi**: Gece vardiyasında çıkış saati normalize edilmiş güne göre hesaplanıyor
6. **Cache Temizleme**: İlk kurulumda veya test sırasında cache tablosunu temizlemek için `PDKS_Cache_Tablo_Silme.sql` kullanılabilir
7. **Kayıt Sayısı Kontrolü**: COUNT(*) ve SELECT * farklı sayılar gösteriyorsa duplicate ID kontrolü yapın
8. **Statistics Güncelleme**: Düzenli olarak statistics'leri güncelleyin (`UPDATE STATISTICS`)

## Sonraki Adımlar

1. ✅ Cache tablosunu temizleyin (`PDKS_Cache_Tablo_Silme.sql`)
2. ✅ Ayar tablosunu kontrol edin (ZU_P_AYARE.AP10 = 1 olan kayıtlar)
3. ✅ Merge sorgusunu SQL Agent Job'a ekleyin/güncelleyin (`PDKS_Merge_Sorgu_Duzeltilmis.sql`)
4. ⏳ Test sorgusunu çalıştırıp sonuçları kontrol edin (`Test_Sorgu_4066_26-27_Kasim.sql`)
5. ⏳ Yeni terminaller için ayar tablosunu güncelleyin

## İletişim

Sorularınız için: mozan73@gmail.com

## Versiyon Geçmişi

- **v2.1 - 2025-11-28 (Güncel)**: Cache Tablosu Kontrol ve Optimizasyon
  - Cache tablosu kayıt sayısı kontrol scriptleri eklendi
  - Duplicate ID kontrolü ve temizleme scriptleri hazırlandı
  - Statistics kontrolü ve güncelleme scriptleri eklendi
  - Kayıt sayısı sorunu çözüldü

- **v2.0 - 2025-11-28**: Ayar Tablosu Entegrasyonu
  - Ayar tabloları (ZU_P_AYARE ve ZU_P_AYART) entegre edildi
  - Sadece TerminalID'ye göre filtreleme yapılıyor
  - 2025 ve sonrası kriteri eklendi
  - Cache tablosu temizleme scripti eklendi

- **v1.0 - 2025-11-28**: İlk versiyon
  - Konfigürasyon tablosu sistemi eklendi
  - Merge sorgusu güncellendi
  - Çalışma süresi hesaplama düzeltmeleri yapıldı

