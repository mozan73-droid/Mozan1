-- PDKS_HAMDATA_CACHE Tablosu Duplicate ID Kontrolü ve Temizleme
-- COUNT(*) 24193 ama SELECT * 403918 gösteriyorsa duplicate ID'ler olabilir

USE PUNTEKS_2025;
GO

-- ============================================================
-- 1. DUPLICATE ID KONTROLÜ
-- ============================================================

-- Aynı ID'ye sahip kayıt sayısı
SELECT 
    COUNT(*) AS ToplamKayit,
    COUNT(DISTINCT ID) AS BenzersizID,
    COUNT(*) - COUNT(DISTINCT ID) AS DuplicateID_Sayisi
FROM dbo.PDKS_HAMDATA_CACHE;

-- Duplicate ID'lerin detaylı listesi
SELECT 
    ID,
    COUNT(*) AS KayitSayisi,
    MIN(EventTime) AS IlkKayit,
    MAX(EventTime) AS SonKayit,
    MIN(KayitZamani) AS IlkAktarim,
    MAX(KayitZamani) AS SonAktarim
FROM dbo.PDKS_HAMDATA_CACHE
GROUP BY ID
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC;

-- En çok duplicate olan ID'ler (ilk 20)
SELECT TOP 20
    ID,
    COUNT(*) AS KayitSayisi
FROM dbo.PDKS_HAMDATA_CACHE
GROUP BY ID
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC;

-- ============================================================
-- 2. DUPLICATE KAYITLARI GÖRÜNTÜLEME
-- ============================================================

-- Belirli bir ID için duplicate kayıtları göster (örnek: en çok duplicate olan)
DECLARE @OrnekID varchar(10) = (
    SELECT TOP 1 ID
    FROM dbo.PDKS_HAMDATA_CACHE
    GROUP BY ID
    HAVING COUNT(*) > 1
    ORDER BY COUNT(*) DESC
);

SELECT *
FROM dbo.PDKS_HAMDATA_CACHE
WHERE ID = @OrnekID
ORDER BY EventTime, KayitZamani;

-- ============================================================
-- 3. DUPLICATE KAYITLARI TEMİZLEME (EN SON KAYDI TUT)
-- ============================================================
-- DİKKAT: Bu sorgu duplicate kayıtları siler, sadece en son kaydı tutar
-- Önce yedek alın!

-- Yedek alma (opsiyonel)
/*
SELECT * 
INTO dbo.PDKS_HAMDATA_CACHE_YEDEK_20251128
FROM dbo.PDKS_HAMDATA_CACHE;
*/

-- Duplicate kayıtları sil (en son kaydı tut)
/*
WITH DuplicateCTE AS (
    SELECT 
        ID,
        ROW_NUMBER() OVER (
            PARTITION BY ID 
            ORDER BY KayitZamani DESC, EventTime DESC
        ) AS rn
    FROM dbo.PDKS_HAMDATA_CACHE
)
DELETE FROM dbo.PDKS_HAMDATA_CACHE
WHERE ID IN (
    SELECT ID 
    FROM DuplicateCTE 
    WHERE rn > 1
);
*/

-- ============================================================
-- 4. STATISTICS GÜNCELLEME
-- ============================================================

-- Tüm statistics'leri güncelle (FULLSCAN ile tam tarama)
-- DİKKAT: Bu işlem uzun sürebilir!
/*
UPDATE STATISTICS dbo.PDKS_HAMDATA_CACHE WITH FULLSCAN;
*/

-- Sadece belirli bir index için statistics güncelle
/*
UPDATE STATISTICS dbo.PDKS_HAMDATA_CACHE IX_PDKS_HAMDATA_CACHE_ID WITH FULLSCAN;
*/

-- ============================================================
-- 5. DOĞRULAMA
-- ============================================================

-- Temizleme sonrası kontrol
SELECT 
    COUNT(*) AS ToplamKayit,
    COUNT(DISTINCT ID) AS BenzersizID,
    COUNT(*) - COUNT(DISTINCT ID) AS DuplicateID_Sayisi
FROM dbo.PDKS_HAMDATA_CACHE;

-- Statistics kontrolü
SELECT 
    s.name AS StatisticsName,
    sp.rows AS EstimatedRows,
    sp.rows_sampled AS SampledRows,
    sp.last_updated
FROM sys.stats s
CROSS APPLY sys.dm_db_stats_properties(s.object_id, s.stats_id) sp
WHERE s.object_id = OBJECT_ID('dbo.PDKS_HAMDATA_CACHE')
ORDER BY sp.last_updated DESC;

GO

