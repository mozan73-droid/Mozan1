-- PDKS_HAMDATA_CACHE Duplicate ID Hızlı Kontrol
-- COUNT(*) 24193 ama SELECT * 403918 gösteriyorsa duplicate ID'ler olabilir

USE PUNTEKS_2025;
GO

-- ============================================================
-- 1. HIZLI KONTROL
-- ============================================================

-- Toplam kayıt vs Benzersiz ID
SELECT 
    COUNT(*) AS ToplamKayit,
    COUNT(DISTINCT ID) AS BenzersizID,
    COUNT(*) - COUNT(DISTINCT ID) AS DuplicateID_Sayisi,
    CASE 
        WHEN COUNT(*) - COUNT(DISTINCT ID) > 0 
        THEN 'DUPLICATE ID VAR!'
        ELSE 'Duplicate ID yok'
    END AS Durum
FROM dbo.PDKS_HAMDATA_CACHE;

-- ============================================================
-- 2. DUPLICATE ID DETAYLARI
-- ============================================================

-- En çok duplicate olan ID'ler (ilk 10)
SELECT TOP 10
    ID,
    COUNT(*) AS KayitSayisi,
    MIN(EventTime) AS IlkKayit,
    MAX(EventTime) AS SonKayit
FROM dbo.PDKS_HAMDATA_CACHE
GROUP BY ID
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC;

-- ============================================================
-- 3. SSMS GÖRÜNTÜLEME KONTROLÜ
-- ============================================================

-- SELECT * sorgusu gerçekten kaç kayıt döndürüyor?
-- SSMS'de Results sekmesinin altında "X rows" yazısını kontrol edin
-- Bu sorgu çok fazla veri döndürebilir, dikkatli kullanın!

-- Alternatif: TOP ile kontrol
SELECT TOP 1000 *
FROM dbo.PDKS_HAMDATA_CACHE
ORDER BY ID, EventTime;

-- Kayıt sayısını kontrol et (farklı yöntemlerle)
SELECT 
    (SELECT COUNT(*) FROM dbo.PDKS_HAMDATA_CACHE) AS COUNT_Method,
    (SELECT COUNT_BIG(*) FROM dbo.PDKS_HAMDATA_CACHE) AS COUNT_BIG_Method;

-- ============================================================
-- 4. VIEW KONTROLÜ
-- ============================================================

-- Eğer view kullanıyorsanız, view tanımını kontrol edin
SELECT 
    v.name AS ViewName,
    OBJECT_DEFINITION(v.object_id) AS ViewDefinition
FROM sys.views v
WHERE v.name LIKE '%PDKS%'
   OR OBJECT_DEFINITION(v.object_id) LIKE '%PDKS_HAMDATA_CACHE%';

GO

