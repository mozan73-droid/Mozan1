# PDKS Terminal Genişletme - Dokümantasyon

## Tarih: 2025-11-28

## Genel Bakış

1093 ve 1094 TerminalID'leri hardcoded olarak kullanılıyordu. Artık tüm terminaller ayar tablosundan (ZU_P_AYARE ve ZU_P_AYART) dinamik olarak alınıyor.

## Oluşturulan View'ler

### 1. vw_PDKS_Giris_Terminalleri
Ayar tablosundan GİRİŞ terminallerini alır. **GIRISCIKIS** alanına göre filtreleme yapılır.

```sql
SELECT * FROM dbo.vw_PDKS_Giris_Terminalleri;
```

**Filtreleme Kriteri**: `GIRISCIKIS = 'GİRİŞ'` veya `'GIRIS'` veya benzeri değerler

### 2. vw_PDKS_Cikis_Terminalleri
Ayar tablosundan ÇIKIŞ terminallerini alır. **GIRISCIKIS** alanına göre filtreleme yapılır.

```sql
SELECT * FROM dbo.vw_PDKS_Cikis_Terminalleri;
```

**Filtreleme Kriteri**: `GIRISCIKIS = 'ÇIKIŞ'` veya `'CIKIS'` veya benzeri değerler

### 3. vw_PDKS_Tum_Terminaller
Ayar tablosundan tüm aktif terminalleri alır.

```sql
SELECT * FROM dbo.vw_PDKS_Tum_Terminaller;
```

## Güncellenen Dosyalar

### 1. PDKS_Terminal_Ayar_View.sql ⭐ (YENİ)
- View'leri oluşturan script
- İlk kurulumda bu dosyayı çalıştırın

### 2. Test_Sorgu_4066_26-27_Kasim.sql
**Önceki**: `WHERE p.TerminalID = '1093'` ve `WHERE p.TerminalID = '1094'`  
**Şimdi**: `INNER JOIN dbo.vw_PDKS_Giris_Terminalleri` ve `INNER JOIN dbo.vw_PDKS_Cikis_Terminalleri`

### 3. PDKS_Dashboard_sql_Duzeltilmis.txt
**Önceki**: 
```vb
WHEN p.TerminalID = '1094' THEN 'DISARIDA'
WHEN p.TerminalID = '1093' THEN 'ICERDE'
```

**Şimdi**:
```vb
WHEN EXISTS (SELECT 1 FROM dbo.vw_PDKS_Cikis_Terminalleri c WHERE CAST(p.TerminalID AS varchar(10)) = c.TerminalID) THEN 'DISARIDA'
WHEN EXISTS (SELECT 1 FROM dbo.vw_PDKS_Giris_Terminalleri g WHERE CAST(p.TerminalID AS varchar(10)) = g.TerminalID) THEN 'ICERDE'
```

### 4. PDKS_Gunluk_Gecikme_ErkenCikis_Tespit_Makro.vbs
**Önceki**: `WHERE p.TerminalID = '1093'` ve `WHERE p.TerminalID = '1094'`  
**Şimdi**: `INNER JOIN dbo.vw_PDKS_Giris_Terminalleri` ve `INNER JOIN dbo.vw_PDKS_Cikis_Terminalleri`

## Kurulum Adımları

### 1. View'leri Oluşturma

```sql
-- PDKS_Terminal_Ayar_View.sql dosyasını çalıştırın
-- Bu script 3 view oluşturur:
--   - vw_PDKS_Giris_Terminalleri
--   - vw_PDKS_Cikis_Terminalleri
--   - vw_PDKS_Tum_Terminaller
```

### 2. Ayar Tablosunu Kontrol Etme

```sql
-- Ayar tablosunda hangi terminaller var?
SELECT 
    ayart.TerminalID, 
    ayart.TerminalYonu,
    ayart.GIRISCIKIS
FROM ZU_P_AYARE ayare
LEFT JOIN ZU_P_AYART ayart ON ayart.EVRAKNO = ayare.EVRAKNO
WHERE ayare.AP10 = 1
  AND ayart.TerminalID IS NOT NULL;
```

### 3. View'leri Test Etme

```sql
-- Giriş terminalleri
SELECT * FROM dbo.vw_PDKS_Giris_Terminalleri;

-- Çıkış terminalleri
SELECT * FROM dbo.vw_PDKS_Cikis_Terminalleri;

-- Tüm terminaller
SELECT * FROM dbo.vw_PDKS_Tum_Terminaller;
```

## Avantajlar

1. **Dinamik Filtreleme**: Yeni terminal eklendiğinde sadece ayar tablosunu güncellemek yeterli
2. **Merkezi Yönetim**: Tüm terminal tanımları ayar tablosunda
3. **Kolay Bakım**: Sorguları değiştirmeye gerek yok
4. **Esneklik**: Giriş/çıkış terminalleri otomatik olarak ayrılıyor

## Yeni Terminal Ekleme

1. Ayar tablosuna terminal ekleyin:
   ```sql
   -- ZU_P_AYARE tablosuna kayıt ekleyin (AP10 = 1)
   -- ZU_P_AYART tablosuna TerminalID, TerminalYonu ve GIRISCIKIS ekleyin
   -- GIRISCIKIS değeri: 'GİRİŞ' veya 'ÇIKIŞ' olmalı
   ```

2. View'ler otomatik olarak yeni terminali alacaktır (view'ler her sorgu çalıştığında yeniden hesaplanır)

3. Tüm sorgular otomatik olarak yeni terminali kullanacaktır

**Örnek**:
```sql
-- Giriş terminali ekleme
INSERT INTO ZU_P_AYART (EVRAKNO, TerminalID, TerminalYonu, GIRISCIKIS)
VALUES (123, '1095', 'MANİSA GİRİŞ', 'GİRİŞ');

-- Çıkış terminali ekleme
INSERT INTO ZU_P_AYART (EVRAKNO, TerminalID, TerminalYonu, GIRISCIKIS)
VALUES (124, '1096', 'MANİSA ÇIKIŞ', 'ÇIKIŞ');
```

## Önemli Notlar

- View'ler her sorgu çalıştığında yeniden hesaplanır (dinamik)
- Ayar tablosunda `AP10 = 1` olan kayıtlar aktif kabul edilir
- **GIRISCIKIS** alanına göre giriş/çıkış terminalleri ayrılır
  - Giriş: `GIRISCIKIS = 'GİRİŞ'` veya `'GIRIS'` veya benzeri
  - Çıkış: `GIRISCIKIS = 'ÇIKIŞ'` veya `'CIKIS'` veya benzeri
- View'ler oluşturulduktan sonra tüm sorgular otomatik olarak güncel terminalleri kullanır
- **GIRISCIKIS** alanı büyük/küçük harf duyarsız ve trim edilmiş olarak kontrol edilir

## Sorun Giderme

### View'ler çalışmıyor

```sql
-- View tanımlarını kontrol edin
SELECT OBJECT_DEFINITION(OBJECT_ID('dbo.vw_PDKS_Giris_Terminalleri'));
```

### Terminal görünmüyor

```sql
-- Ayar tablosunu kontrol edin
SELECT * FROM ZU_P_AYARE WHERE AP10 = 1;
SELECT * FROM ZU_P_AYART;
```

### View'leri yeniden oluşturma

```sql
-- PDKS_Terminal_Ayar_View.sql dosyasını tekrar çalıştırın
```

## Versiyon Geçmişi

- **v1.1 - 2025-11-28**: GIRISCIKIS Alanı Desteği
  - View'ler GIRISCIKIS alanını kullanacak şekilde güncellendi
  - TerminalYonu yerine GIRISCIKIS alanına göre filtreleme yapılıyor
  - Büyük/küçük harf duyarsız ve trim edilmiş kontrol eklendi

- **v1.0 - 2025-11-28**: İlk versiyon
  - View'ler oluşturuldu
  - Test sorgusu güncellendi
  - Dashboard sorgusu güncellendi
  - Makro güncellendi

