-- PDKS_HAMDATA_CACHE Tablosunu Link Server'dan Doldurma
-- Tablo: [PDKS_LS].[GULERYUZGROUP14885_Meyer].[dbo].[vw_PDKS_OlayDetay_Bolum3ve6]
-- Cache Tablo: dbo.PDKS_HAMDATA_CACHE

USE PUNTEKS_2025;
GO

-- ============================================================
-- 1. MEVCUT DURUM KONTROLÜ
-- ============================================================
-- Cache tablosunda hangi terminaller var?
SELECT DISTINCT 
    TerminalID,
    COUNT(*) AS KayitSayisi,
    MIN(EventTime) AS IlkKayit,
    MAX(EventTime) AS SonKayit
FROM dbo.PDKS_HAMDATA_CACHE
WHERE Deleted = 0
GROUP BY TerminalID
ORDER BY TerminalID;

-- ============================================================
-- 2. LINK SERVER'DA HANGİ TERMİNALLER VAR?
-- ============================================================
SELECT DISTINCT 
    TerminalID,
    COUNT(*) AS ToplamKayit
FROM [PDKS_LS].[GULERYUZGROUP14885_Meyer].[dbo].[vw_PDKS_OlayDetay_Bolum3ve6]
GROUP BY TerminalID
ORDER BY TerminalID;

-- ============================================================
-- 3. CACHE TABLOSUNA VERİ AKTARMA (TÜM TERMİNALLER)
-- ============================================================
-- Not: Bu sorgu sadece yeni kayıtları ekler (ID kontrolü ile)
-- Eğer tüm verileri yeniden yüklemek istiyorsanız, önce tabloyu temizleyin

-- Seçenek 1: Sadece yeni kayıtları ekle (ID kontrolü ile)
INSERT INTO dbo.PDKS_HAMDATA_CACHE (
    ID, SicilID, UserID, PersonelAdi, PersonelSoyadi, SicilNo, 
    Bolum, Pozisyon, TerminalID, TerminalYonu, KartNumarasi, 
    CardType, EventTime, EventCode, FuncCode, PDKS, Status, 
    Automatic, Deleted, ReaderID, UnDelete, ForeignID, pdksx, 
    duzeltme, mudahale, kayitbilgisi, entegrasyonbilgisi, 
    Veri_Gelis, KayitZamani
)
SELECT 
    ID, SicilID, UserID, PersonelAdi, PersonelSoyadi, SicilNo,
    Bolum, Pozisyon, TerminalID, TerminalYonu, KartNumarasi,
    CardType, EventTime, EventCode, FuncCode, PDKS, Status,
    Automatic, 0 AS Deleted, ReaderID, UnDelete, ForeignID, pdksx,
    duzeltme, mudahale, kayitbilgisi, entegrasyonbilgisi,
    Veri_Gelis, KayitZamani
FROM [PDKS_LS].[GULERYUZGROUP14885_Meyer].[dbo].[vw_PDKS_OlayDetay_Bolum3ve6] ls
WHERE NOT EXISTS (
    SELECT 1 
    FROM dbo.PDKS_HAMDATA_CACHE c 
    WHERE c.ID = ls.ID
);

-- Seçenek 2: Sadece belirli terminalleri ekle (1093 ve 1094 dışındakileri de eklemek için)
-- TerminalID filtresini kaldırın veya istediğiniz terminalleri ekleyin
/*
INSERT INTO dbo.PDKS_HAMDATA_CACHE (
    ID, SicilID, UserID, PersonelAdi, PersonelSoyadi, SicilNo, 
    Bolum, Pozisyon, TerminalID, TerminalYonu, KartNumarasi, 
    CardType, EventTime, EventCode, FuncCode, PDKS, Status, 
    Automatic, Deleted, ReaderID, UnDelete, ForeignID, pdksx, 
    duzeltme, mudahale, kayitbilgisi, entegrasyonbilgisi, 
    Veri_Gelis, KayitZamani
)
SELECT 
    ID, SicilID, UserID, PersonelAdi, PersonelSoyadi, SicilNo,
    Bolum, Pozisyon, TerminalID, TerminalYonu, KartNumarasi,
    CardType, EventTime, EventCode, FuncCode, PDKS, Status,
    Automatic, 0 AS Deleted, ReaderID, UnDelete, ForeignID, pdksx,
    duzeltme, mudahale, kayitbilgisi, entegrasyonbilgisi,
    Veri_Gelis, KayitZamani
FROM [PDKS_LS].[GULERYUZGROUP14885_Meyer].[dbo].[vw_PDKS_OlayDetay_Bolum3ve6] ls
WHERE TerminalID IN ('1093', '1094', 'DIGER_TERMINAL_ID_LER')  -- Buraya eksik terminalleri ekleyin
  AND NOT EXISTS (
    SELECT 1 
    FROM dbo.PDKS_HAMDATA_CACHE c 
    WHERE c.ID = ls.ID
);
*/

-- ============================================================
-- 4. GÜNCELLEME (Eğer kayıtlar güncellenmişse)
-- ============================================================
-- Link server'daki veriler güncellenmişse cache'i güncelle
/*
UPDATE c
SET 
    c.PersonelAdi = ls.PersonelAdi,
    c.PersonelSoyadi = ls.PersonelSoyadi,
    c.TerminalYonu = ls.TerminalYonu,
    c.EventTime = ls.EventTime,
    c.Status = ls.Status,
    c.Deleted = 0
FROM dbo.PDKS_HAMDATA_CACHE c
INNER JOIN [PDKS_LS].[GULERYUZGROUP14885_Meyer].[dbo].[vw_PDKS_OlayDetay_Bolum3ve6] ls
    ON c.ID = ls.ID
WHERE c.Deleted = 0;
*/

-- ============================================================
-- 5. EVENTTIME KOLONU KONTROLÜ
-- ============================================================
-- Link server tablosunda EventTime kolonu var mı? EventTimeDt mi?
-- Eğer EventTimeDt ise sorguyu buna göre güncelleyin
/*
SELECT TOP 10 
    COLUMN_NAME,
    DATA_TYPE
FROM [PDKS_LS].[GULERYUZGROUP14885_Meyer].[INFORMATION_SCHEMA].[COLUMNS]
WHERE TABLE_SCHEMA = 'dbo' 
  AND TABLE_NAME = 'vw_PDKS_OlayDetay_Bolum3ve6'
  AND COLUMN_NAME LIKE '%Time%'
ORDER BY ORDINAL_POSITION;
*/

GO

