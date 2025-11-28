-- PDKS Terminal Konfigürasyon Tablosu
-- Bu tablo, cache tablosuna hangi terminallerin alınacağını belirler
-- Yeni terminal eklendiğinde sadece bu tabloyu güncellemek yeterli olur

USE PUNTEKS_2025;
GO

-- ============================================================
-- 1. KONFİGÜRASYON TABLOSU OLUŞTURMA
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'PDKS_TERMINAL_KONFIGURASYON')
BEGIN
    CREATE TABLE dbo.PDKS_TERMINAL_KONFIGURASYON (
        ID int IDENTITY(1,1) PRIMARY KEY,
        TerminalID varchar(10) NOT NULL,
        TerminalYonu varchar(50) NOT NULL,
        TerminalAdi varchar(100) NULL,
        Aktif bit NOT NULL DEFAULT 1,
        OlusturmaTarihi datetime NOT NULL DEFAULT GETDATE(),
        GuncellemeTarihi datetime NULL,
        Aciklama varchar(500) NULL,
        CONSTRAINT UK_PDKS_TERMINAL_KONFIGURASYON UNIQUE (TerminalID, TerminalYonu)
    );
    
    PRINT 'PDKS_TERMINAL_KONFIGURASYON tablosu oluşturuldu.';
END
ELSE
BEGIN
    PRINT 'PDKS_TERMINAL_KONFIGURASYON tablosu zaten mevcut.';
END
GO

-- ============================================================
-- 2. ÖRNEK VERİ EKLEME (MANİSA GİRİŞ ve ÇIKIŞ terminalleri)
-- ============================================================
-- Not: Mevcut terminalleri kontrol edip buraya ekleyin
-- Önce link server'dan hangi terminallerin olduğunu kontrol edin

-- Mevcut kayıtları kontrol et
IF NOT EXISTS (SELECT 1 FROM dbo.PDKS_TERMINAL_KONFIGURASYON)
BEGIN
    -- Örnek: 1093 ve 1094 terminalleri (MANİSA GİRİŞ ve ÇIKIŞ)
    -- Gerçek terminal bilgilerini link server'dan kontrol edip buraya ekleyin
    
    INSERT INTO dbo.PDKS_TERMINAL_KONFIGURASYON (TerminalID, TerminalYonu, TerminalAdi, Aktif, Aciklama)
    VALUES 
        ('1093', 'MANİSA GİRİŞ', 'Manisa Giriş Terminali', 1, 'Manisa giriş terminali'),
        ('1094', 'MANİSA ÇIKIŞ', 'Manisa Çıkış Terminali', 1, 'Manisa çıkış terminali');
    
    PRINT 'Örnek terminal konfigürasyonları eklendi.';
END
ELSE
BEGIN
    PRINT 'Terminal konfigürasyonları zaten mevcut.';
END
GO

-- ============================================================
-- 3. KULLANIM ÖRNEKLERİ
-- ============================================================

-- Tüm aktif terminalleri listele
SELECT * 
FROM dbo.PDKS_TERMINAL_KONFIGURASYON 
WHERE Aktif = 1
ORDER BY TerminalID, TerminalYonu;

-- Yeni terminal ekleme örneği
/*
INSERT INTO dbo.PDKS_TERMINAL_KONFIGURASYON (TerminalID, TerminalYonu, TerminalAdi, Aktif, Aciklama)
VALUES ('1095', 'MANİSA GİRİŞ', 'Yeni Manisa Giriş Terminali', 1, 'Yeni eklenen terminal');
*/

-- Terminal güncelleme örneği
/*
UPDATE dbo.PDKS_TERMINAL_KONFIGURASYON
SET Aktif = 0,
    GuncellemeTarihi = GETDATE(),
    Aciklama = 'Pasif edildi'
WHERE TerminalID = '1093';
*/

-- Terminal silme (soft delete)
/*
UPDATE dbo.PDKS_TERMINAL_KONFIGURASYON
SET Aktif = 0,
    GuncellemeTarihi = GETDATE()
WHERE TerminalID = '1093';
*/

-- ============================================================
-- 4. LINK SERVER'DAN TERMİNALLERİ OTOMATİK AKTARMA
-- ============================================================
-- Link server'daki MANİSA GİRİŞ ve MANİSA ÇIKIŞ terminallerini 
-- otomatik olarak konfigürasyon tablosuna aktarır

-- Mevcut terminalleri link server'dan çek ve konfigürasyon tablosuna ekle
MERGE dbo.PDKS_TERMINAL_KONFIGURASYON AS tgt
USING (
    SELECT DISTINCT
        CAST(TerminalID AS varchar(10)) AS TerminalID,
        TerminalYonu,
        TerminalYonu AS TerminalAdi,
        1 AS Aktif
    FROM [PDKS_LS].[GULERYUZGROUP14885_Meyer].[dbo].[vw_PDKS_OlayDetay_Bolum3ve6]
    WHERE (
        TerminalYonu LIKE '%MANİSA GİRİŞ%' 
        OR TerminalYonu LIKE '%MANİSA ÇIKIŞ%'
        OR TerminalYonu LIKE '%MANISA GIRIS%'
        OR TerminalYonu LIKE '%MANISA CIKIS%'
    )
    AND DATEPART(YEAR, EventTime) >= 2025
) AS src
ON tgt.TerminalID = src.TerminalID 
   AND tgt.TerminalYonu = src.TerminalYonu
WHEN NOT MATCHED THEN
    INSERT (TerminalID, TerminalYonu, TerminalAdi, Aktif, Aciklama)
    VALUES (src.TerminalID, src.TerminalYonu, src.TerminalAdi, src.Aktif, 
            'Link server''dan otomatik aktarıldı')
WHEN MATCHED AND tgt.Aktif = 0 THEN
    UPDATE SET 
        tgt.Aktif = 1,
        tgt.GuncellemeTarihi = GETDATE(),
        tgt.Aciklama = 'Link server''dan otomatik güncellendi';

PRINT 'Link server terminalleri konfigürasyon tablosuna aktarıldı.';

-- Aktarılan terminalleri göster
SELECT * 
FROM dbo.PDKS_TERMINAL_KONFIGURASYON 
WHERE Aktif = 1
ORDER BY TerminalID, TerminalYonu;

GO

