# PDKS Projesi - Dosya Listesi ve Kullanım Kılavuzu

## 📁 Dosya Yapısı

### ⭐ Ana Dosyalar (Öncelikli)

1. **PDKS_Merge_Sorgu_Duzeltilmis.sql** ⭐⭐⭐
   - **Açıklama**: Link server'dan cache tablosuna veri aktarma merge sorgusu
   - **Kullanım**: SQL Agent Job'a eklenir, otomatik çalışır
   - **Özellikler**:
     - Ayar tablosu (ZU_P_AYARE ve ZU_P_AYART) kullanır
     - Sadece TerminalID'ye göre filtreleme
     - 2025 ve sonrası veriler alınır
     - Son aktarım tarihini takip eder

2. **PDKS_Cache_Tablo_Silme.sql** ⭐⭐
   - **Açıklama**: Cache tablosunu temizleme scripti
   - **Kullanım**: İlk kurulumda veya test sırasında çalıştırılır
   - **Özellikler**: DELETE veya TRUNCATE seçenekleri

3. **Test_Sorgu_4066_26-27_Kasim.sql** ⭐
   - **Açıklama**: Çalışma süresi hesaplama test sorgusu
   - **Kullanım**: Belirli personel için giriş/çıkış kontrolü
   - **Özellikler**: Normalize edilmiş çıkış saati gösterimi

### 📋 Yardımcı Dosyalar

4. **Link_Server_Terminal_Kontrol.sql**
   - Link server'da hangi terminallerin olduğunu kontrol eder

5. **PDKS_Cache_Tablo_Doldurma.sql**
   - Cache tablosuna veri aktarma alternatif yöntemleri

6. **PDKS_Cache_Tablo_Temizleme.sql**
   - Detaylı cache tablosu temizleme (eski versiyon)

7. **PDKS_Terminal_Konfigurasyon_Tablo.sql**
   - Alternatif konfigürasyon tablosu (opsiyonel, şu an kullanılmıyor)

8. **PDKS_Terminal_Konfigurasyon_README.md**
   - Konfigürasyon tablosu kullanım kılavuzu (opsiyonel)

### 📊 Rapor ve Analiz Dosyaları

9. **PDKS_Puantaj_Personel_Toplam.sql**
   - Personel puantaj sorguları
   - Günlük ve aylık raporlar

10. **PDKS_Gunluk_Yoklama_Mail_Servisi.sql**
    - Günlük yoklama raporu otomatik mail servisi
    - Stored procedure ve SQL Agent Job

11. **vw_PDKS_HAMDATA_Liste.sql**
    - PDKS ham veri liste view'i

### 📝 Dokümantasyon

12. **00_PROJE_OZETI.md** ⭐⭐
    - Tüm projenin detaylı özeti
    - Sistem mimarisi
    - Versiyon geçmişi

13. **PDKS_Yoklama_Mail_README.txt**
    - Mail servisi kullanım kılavuzu

14. **PDKS_HAMDATA_CACHE_columns.txt**
    - Cache tablosu kolon bilgileri

### 🔧 Diğer Dosyalar

15. **PDKS_Dashboard_sql_Duzeltilmis.txt**
    - Dashboard SQL sorguları (VBScript formatında)

16. **PDKS_Gunluk_Gecikme_ErkenCikis_Tespit_Makro.vbs**
    - Gecikme ve erken çıkış tespit makrosu

17. **PDKS_Makrolar_Dinamo.txt**
    - Dinamo makroları

18. **PDKS_Makrolar.txt**
    - Genel makrolar

19. **pdks.txt**
    - Örnek veri dosyası

## 🚀 Hızlı Başlangıç

### 1. İlk Kurulum

```sql
-- 1. Cache tablosunu temizle
-- PDKS_Cache_Tablo_Silme.sql dosyasını çalıştırın

-- 2. Ayar tablosunu kontrol et
SELECT ayart.TerminalID, ayart.TerminalYonu
FROM ZU_P_AYARE ayare
LEFT JOIN ZU_P_AYART ayart ON ayart.EVRAKNO = ayare.EVRAKNO
WHERE ayare.AP10 = 1
  AND ayart.TerminalID IS NOT NULL;

-- 3. Merge sorgusunu SQL Agent Job'a ekle
-- PDKS_Merge_Sorgu_Duzeltilmis.sql dosyasını kullanın
```

### 2. Günlük Kullanım

- Merge sorgusu SQL Agent Job olarak otomatik çalışır
- Cache tablosu otomatik olarak güncellenir
- Raporlar cache tablosundan veri çeker

### 3. Yeni Terminal Ekleme

```sql
-- Ayar tablosuna yeni terminal ekleyin
-- ZU_P_AYARE tablosuna kayıt ekleyin (AP10 = 1)
-- ZU_P_AYART tablosuna TerminalID ve TerminalYonu ekleyin
-- Merge sorgusu otomatik olarak yeni terminali alacaktır
```

## 📌 Önemli Notlar

- **Ayar Tablosu**: ZU_P_AYARE.AP10 = 1 olan kayıtlar aktif kabul edilir
- **Terminal Filtreleme**: Sadece TerminalID'ye göre filtreleme yapılır
- **Tarih Kriteri**: Sadece 2025 ve sonrası veriler alınır
- **Son Aktarım**: Merge sorgusu son aktarım tarihini takip eder

## 📞 İletişim

Sorularınız için: mozan73@gmail.com

## 📅 Son Güncelleme

**Tarih**: 2025-11-28  
**Versiyon**: v2.0

