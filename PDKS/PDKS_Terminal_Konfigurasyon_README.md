# PDKS Terminal Konfigürasyon Sistemi

## Genel Bakış

Bu sistem, PDKS cache tablosuna hangi terminallerin alınacağını yönetmek için bir konfigürasyon tablosu kullanır. Yeni terminal eklendiğinde sadece konfigürasyon tablosunu güncellemek yeterli olur, merge sorgusunu değiştirmeye gerek kalmaz.

## Dosyalar

1. **PDKS_Terminal_Konfigurasyon_Tablo.sql**: Konfigürasyon tablosunu oluşturur ve link server'dan terminalleri otomatik aktarır
2. **PDKS_Merge_Sorgu_Duzeltilmis.sql**: Konfigürasyon tablosunu kullanan merge sorgusu

## Kurulum Adımları

### 1. Konfigürasyon Tablosunu Oluşturma

```sql
-- PDKS_Terminal_Konfigurasyon_Tablo.sql dosyasını çalıştırın
-- Bu script:
--   - PDKS_TERMINAL_KONFIGURASYON tablosunu oluşturur
--   - Link server'dan MANİSA GİRİŞ ve MANİSA ÇIKIŞ terminallerini otomatik aktarır
```

### 2. Merge Sorgusunu Güncelleme

```sql
-- PDKS_Merge_Sorgu_Duzeltilmis.sql dosyasındaki merge sorgusunu SQL Agent Job'a ekleyin
-- Artık sorgu konfigürasyon tablosunu kullanıyor
```

## Kullanım

### Yeni Terminal Ekleme

**Yöntem 1: Otomatik (Önerilen)**
```sql
-- Link server'dan otomatik aktarma scriptini çalıştırın
-- PDKS_Terminal_Konfigurasyon_Tablo.sql dosyasının 4. bölümünü çalıştırın
```

**Yöntem 2: Manuel**
```sql
INSERT INTO dbo.PDKS_TERMINAL_KONFIGURASYON 
    (TerminalID, TerminalYonu, TerminalAdi, Aktif, Aciklama)
VALUES 
    ('1095', 'MANİSA GİRİŞ', 'Yeni Manisa Giriş Terminali', 1, 'Yeni eklenen terminal');
```

### Terminal Pasif Etme

```sql
UPDATE dbo.PDKS_TERMINAL_KONFIGURASYON
SET Aktif = 0,
    GuncellemeTarihi = GETDATE(),
    Aciklama = 'Pasif edildi'
WHERE TerminalID = '1093';
```

### Aktif Terminalleri Listeleme

```sql
SELECT * 
FROM dbo.PDKS_TERMINAL_KONFIGURASYON 
WHERE Aktif = 1
ORDER BY TerminalID, TerminalYonu;
```

## Avantajlar

1. **Esneklik**: Yeni terminal eklendiğinde sadece konfigürasyon tablosunu güncellemek yeterli
2. **Bakım Kolaylığı**: Merge sorgusunu değiştirmeye gerek yok
3. **Güvenlik**: TerminalID ve TerminalYonu kombinasyonu unique constraint ile korunuyor
4. **Soft Delete**: Terminalleri silmek yerine pasif edebilirsiniz
5. **Otomatik Aktarım**: Link server'dan terminalleri otomatik olarak aktarabilirsiniz

## Tablo Yapısı

```sql
PDKS_TERMINAL_KONFIGURASYON
├── ID (int, PK, Identity)
├── TerminalID (varchar(10), NOT NULL)
├── TerminalYonu (varchar(50), NOT NULL)
├── TerminalAdi (varchar(100), NULL)
├── Aktif (bit, NOT NULL, DEFAULT 1)
├── OlusturmaTarihi (datetime, NOT NULL, DEFAULT GETDATE())
├── GuncellemeTarihi (datetime, NULL)
└── Aciklama (varchar(500), NULL)

UNIQUE CONSTRAINT: (TerminalID, TerminalYonu)
```

## Notlar

- Konfigürasyon tablosu sadece **aktif** terminalleri merge sorgusuna dahil eder
- TerminalID ve TerminalYonu kombinasyonu unique olmalıdır
- Link server'dan otomatik aktarma scripti sadece MANİSA GİRİŞ ve MANİSA ÇIKIŞ terminallerini alır
- Farklı terminal yönleri için scripti güncelleyebilirsiniz

## Sorun Giderme

### Terminal merge sorgusuna dahil edilmiyor

1. Terminal'in konfigürasyon tablosunda olduğundan emin olun:
   ```sql
   SELECT * FROM dbo.PDKS_TERMINAL_KONFIGURASYON 
   WHERE TerminalID = '1093';
   ```

2. Terminal'in aktif olduğundan emin olun:
   ```sql
   SELECT * FROM dbo.PDKS_TERMINAL_KONFIGURASYON 
   WHERE TerminalID = '1093' AND Aktif = 1;
   ```

3. Link server'da terminal'in mevcut olduğundan emin olun:
   ```sql
   SELECT DISTINCT TerminalID, TerminalYonu
   FROM [PDKS_LS].[GULERYUZGROUP14885_Meyer].[dbo].[vw_PDKS_OlayDetay_Bolum3ve6]
   WHERE TerminalID = '1093';
   ```

## Güncelleme Geçmişi

- **2025-11-28**: İlk versiyon oluşturuldu
  - Konfigürasyon tablosu eklendi
  - Merge sorgusu konfigürasyon tablosunu kullanacak şekilde güncellendi
  - Link server'dan otomatik aktarma scripti eklendi

