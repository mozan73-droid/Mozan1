-- PDKS_HAMDATA_CACHE Tablosu Kayıt Sayısı Kontrolü (Basit Versiyon)

USE PUNTEKS_2025;
GO

-- ============================================================
-- 1. TEMEL KAYIT SAYISI KONTROLLERİ
-- ============================================================

-- COUNT(*) ile kayıt sayısı
SELECT COUNT(*) AS KayitSayisi_COUNT
FROM dbo.PDKS_HAMDATA_CACHE;

-- COUNT_BIG(*) ile kayıt sayısı (büyük tablolar için)
SELECT COUNT_BIG(*) AS KayitSayisi_COUNT_BIG
FROM dbo.PDKS_HAMDATA_CACHE;

-- Benzersiz ID kontrolü
SELECT 
    COUNT(*) AS ToplamKayit,
    COUNT(DISTINCT ID) AS BenzersizID,
    COUNT(*) - COUNT(DISTINCT ID) AS DuplicateID_Sayisi
FROM dbo.PDKS_HAMDATA_CACHE;

-- ============================================================
-- 2. DUPLICATE ID KONTROLÜ
-- ============================================================

-- Aynı ID'ye sahip birden fazla kayıt var mı?
SELECT TOP 10
    ID,
    COUNT(*) AS KayitSayisi
FROM dbo.PDKS_HAMDATA_CACHE
GROUP BY ID
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC;

-- ============================================================
-- 3. TABLO BOYUTU (sys.partitions)
-- ============================================================

SELECT 
    OBJECT_NAME(object_id) AS TableName,
    SUM(rows) AS EstimatedRowCount
FROM sys.partitions
WHERE object_id = OBJECT_ID('dbo.PDKS_HAMDATA_CACHE')
  AND index_id IN (0, 1)  -- Heap veya clustered index
GROUP BY object_id;

-- ============================================================
-- 4. TARİH BAZLI KONTROL
-- ============================================================

SELECT 
    CAST(EventTime AS DATE) AS Tarih,
    COUNT(*) AS KayitSayisi
FROM dbo.PDKS_HAMDATA_CACHE
GROUP BY CAST(EventTime AS DATE)
ORDER BY CAST(EventTime AS DATE) DESC;

-- ============================================================
-- 5. TERMINAL BAZLI KONTROL
-- ============================================================

SELECT 
    TerminalID,
    COUNT(*) AS KayitSayisi
FROM dbo.PDKS_HAMDATA_CACHE
GROUP BY TerminalID
ORDER BY COUNT(*) DESC;

GO

