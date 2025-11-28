-- PDKS_HAMDATA_CACHE Tablosu Kayıt Sayısı Kontrolü
-- COUNT(*) ve SELECT * arasındaki farkı araştırma

USE PUNTEKS_2025;
GO

-- ============================================================
-- 1. TEMEL KONTROLLER
-- ============================================================

-- COUNT(*) ile kayıt sayısı
SELECT COUNT(*) AS KayitSayisi_COUNT
FROM dbo.PDKS_HAMDATA_CACHE;

-- SELECT * ile kayıt sayısı (SSMS'de Results sekmesinde gösterilen)
-- Not: Bu sorgu çok fazla veri döndürebilir, dikkatli kullanın
-- SELECT * FROM dbo.PDKS_HAMDATA_CACHE;

-- COUNT(*) ile DISTINCT ID kontrolü
SELECT 
    COUNT(*) AS ToplamKayit,
    COUNT(DISTINCT ID) AS BenzersizID,
    COUNT(*) - COUNT(DISTINCT ID) AS DuplicateID
FROM dbo.PDKS_HAMDATA_CACHE;

-- ============================================================
-- 2. VIEW KONTROLÜ
-- ============================================================
-- Eğer view kullanıyorsanız, view tanımını kontrol edin

SELECT 
    TABLE_NAME,
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'dbo' 
  AND TABLE_NAME LIKE '%PDKS%'
ORDER BY TABLE_TYPE, TABLE_NAME;

-- View tanımlarını göster
SELECT 
    v.name AS ViewName,
    m.definition AS ViewDefinition
FROM sys.views v
INNER JOIN sys.sql_modules m ON v.object_id = m.object_id
WHERE v.name LIKE '%PDKS%';

-- ============================================================
-- 3. INDEX VE STATISTICS KONTROLÜ
-- ============================================================

-- Index bilgileri
SELECT 
    i.name AS IndexName,
    i.type_desc AS IndexType,
    ps.row_count AS [RowCount],
    ps.reserved_page_count * 8.0 / 1024 AS ReservedMB
FROM sys.indexes i
INNER JOIN sys.dm_db_partition_stats ps ON i.object_id = ps.object_id AND i.index_id = ps.index_id
WHERE i.object_id = OBJECT_ID('dbo.PDKS_HAMDATA_CACHE')
ORDER BY ps.row_count DESC;

-- Statistics bilgileri
SELECT 
    s.name AS StatisticsName,
    s.auto_created,
    s.user_created,
    sp.last_updated,
    sp.rows,
    sp.rows_sampled
FROM sys.stats s
CROSS APPLY sys.dm_db_stats_properties(s.object_id, s.stats_id) sp
WHERE s.object_id = OBJECT_ID('dbo.PDKS_HAMDATA_CACHE')
ORDER BY sp.last_updated DESC;

-- ============================================================
-- 4. DETAYLI ANALİZ
-- ============================================================

-- ID bazlı kontrol (duplicate ID var mı?)
SELECT 
    ID,
    COUNT(*) AS KayitSayisi
FROM dbo.PDKS_HAMDATA_CACHE
GROUP BY ID
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC;

-- NULL ID kontrolü
SELECT 
    COUNT(*) AS NullID_KayitSayisi
FROM dbo.PDKS_HAMDATA_CACHE
WHERE ID IS NULL;

-- Tarih bazlı kayıt sayıları
SELECT 
    CAST(EventTime AS DATE) AS Tarih,
    COUNT(*) AS KayitSayisi
FROM dbo.PDKS_HAMDATA_CACHE
GROUP BY CAST(EventTime AS DATE)
ORDER BY CAST(EventTime AS DATE) DESC;

-- Terminal bazlı kayıt sayıları
SELECT 
    TerminalID,
    TerminalYonu,
    COUNT(*) AS KayitSayisi
FROM dbo.PDKS_HAMDATA_CACHE
GROUP BY TerminalID, TerminalYonu
ORDER BY COUNT(*) DESC;

-- ============================================================
-- 5. STATISTICS GÜNCELLEME
-- ============================================================
-- Eğer statistics eskiyse, güncelleyin

-- Statistics güncelleme (dikkatli kullanın, uzun sürebilir)
/*
UPDATE STATISTICS dbo.PDKS_HAMDATA_CACHE WITH FULLSCAN;
*/

-- ============================================================
-- 6. TABLO BOYUTU KONTROLÜ
-- ============================================================

SELECT 
    t.name AS TableName,
    s.name AS SchemaName,
    p.rows AS [RowCount],
    SUM(a.total_pages) * 8 / 1024 AS TotalSpaceMB,
    SUM(a.used_pages) * 8 / 1024 AS UsedSpaceMB,
    SUM(a.data_pages) * 8 / 1024 AS DataSpaceMB
FROM sys.tables t
INNER JOIN sys.indexes i ON t.object_id = i.object_id
INNER JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE t.name = 'PDKS_HAMDATA_CACHE'
GROUP BY t.name, s.name, p.rows
ORDER BY t.name;

-- ============================================================
-- 7. SSMS SONUÇLARI KONTROLÜ
-- ============================================================
-- SSMS'de "SELECT *" sorgusu çalıştırdığınızda:
-- - Results sekmesinde alt kısımda "X rows" yazısı görünür
-- - Bu sayı gerçek kayıt sayısını gösterir
-- - Eğer bu sayı COUNT(*)'dan farklıysa, bir sorun var demektir

-- Gerçek kayıt sayısını kontrol et (farklı yöntemlerle)
SELECT 
    (SELECT COUNT(*) FROM dbo.PDKS_HAMDATA_CACHE) AS COUNT_Method,
    (SELECT COUNT_BIG(*) FROM dbo.PDKS_HAMDATA_CACHE) AS COUNT_BIG_Method,
    (SELECT SUM(1) FROM dbo.PDKS_HAMDATA_CACHE) AS SUM_Method;

GO

