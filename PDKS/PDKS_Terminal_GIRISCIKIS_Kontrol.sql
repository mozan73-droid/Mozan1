-- PDKS Terminal GIRISCIKIS Alanı Kontrol Sorgusu
-- Ayar tablosundaki GIRISCIKIS alanını ve view'leri test eder

USE PUNTEKS_2025;
GO

-- ============================================================
-- 1. AYAR TABLOSU KONTROLÜ
-- ============================================================

-- Ayar tablosundaki tüm terminaller ve GIRISCIKIS değerleri
SELECT 
    ayare.AP10 AS Aktif,
    ayart.TerminalID,
    ayart.TerminalYonu,
    ayart.GIRISCIKIS,
    LTRIM(RTRIM(ayart.GIRISCIKIS)) AS GIRISCIKIS_Trim,
    UPPER(LTRIM(RTRIM(ayart.GIRISCIKIS))) AS GIRISCIKIS_Upper
FROM dbo.ZU_P_AYARE ayare
LEFT JOIN dbo.ZU_P_AYART ayart ON ayart.EVRAKNO = ayare.EVRAKNO
WHERE ayare.AP10 = 1
  AND ayart.TerminalID IS NOT NULL
ORDER BY ayart.TerminalID;

-- ============================================================
-- 2. GİRİŞ TERMİNALLERİ KONTROLÜ
-- ============================================================

-- Giriş terminalleri (GIRISCIKIS alanına göre)
SELECT 
    TerminalID,
    TerminalYonu,
    GIRISCIKIS
FROM dbo.vw_PDKS_Giris_Terminalleri
ORDER BY TerminalID;

-- Giriş terminal sayısı
SELECT COUNT(*) AS GirisTerminalSayisi
FROM dbo.vw_PDKS_Giris_Terminalleri;

-- ============================================================
-- 3. ÇIKIŞ TERMİNALLERİ KONTROLÜ
-- ============================================================

-- Çıkış terminalleri (GIRISCIKIS alanına göre)
SELECT 
    TerminalID,
    TerminalYonu,
    GIRISCIKIS
FROM dbo.vw_PDKS_Cikis_Terminalleri
ORDER BY TerminalID;

-- Çıkış terminal sayısı
SELECT COUNT(*) AS CikisTerminalSayisi
FROM dbo.vw_PDKS_Cikis_Terminalleri;

-- ============================================================
-- 4. TÜM TERMİNALLER KONTROLÜ
-- ============================================================

-- Tüm terminaller
SELECT 
    TerminalID,
    TerminalYonu,
    GIRISCIKIS
FROM dbo.vw_PDKS_Tum_Terminaller
ORDER BY TerminalID, GIRISCIKIS;

-- Terminal sayısı
SELECT COUNT(*) AS ToplamTerminalSayisi
FROM dbo.vw_PDKS_Tum_Terminaller;

-- ============================================================
-- 5. GIRISCIKIS DEĞER ANALİZİ
-- ============================================================

-- GIRISCIKIS alanındaki farklı değerler
SELECT 
    UPPER(LTRIM(RTRIM(ayart.GIRISCIKIS))) AS GIRISCIKIS_Deger,
    COUNT(*) AS KayitSayisi,
    STRING_AGG(CAST(ayart.TerminalID AS varchar(10)), ', ') AS TerminalID_Listesi
FROM dbo.ZU_P_AYARE ayare
LEFT JOIN dbo.ZU_P_AYART ayart ON ayart.EVRAKNO = ayare.EVRAKNO
WHERE ayare.AP10 = 1
  AND ayart.TerminalID IS NOT NULL
  AND ayart.GIRISCIKIS IS NOT NULL
GROUP BY UPPER(LTRIM(RTRIM(ayart.GIRISCIKIS)))
ORDER BY GIRISCIKIS_Deger;

-- ============================================================
-- 6. PROBLEM TESPİTİ
-- ============================================================

-- GIRISCIKIS alanı NULL olan terminaller
SELECT 
    ayart.TerminalID,
    ayart.TerminalYonu,
    ayart.GIRISCIKIS
FROM dbo.ZU_P_AYARE ayare
LEFT JOIN dbo.ZU_P_AYART ayart ON ayart.EVRAKNO = ayare.EVRAKNO
WHERE ayare.AP10 = 1
  AND ayart.TerminalID IS NOT NULL
  AND (ayart.GIRISCIKIS IS NULL OR LTRIM(RTRIM(ayart.GIRISCIKIS)) = '')
ORDER BY ayart.TerminalID;

-- Giriş veya çıkış olarak tanımlanmamış terminaller
SELECT 
    ayart.TerminalID,
    ayart.TerminalYonu,
    ayart.GIRISCIKIS
FROM dbo.ZU_P_AYARE ayare
LEFT JOIN dbo.ZU_P_AYART ayart ON ayart.EVRAKNO = ayare.EVRAKNO
WHERE ayare.AP10 = 1
  AND ayart.TerminalID IS NOT NULL
  AND ayart.GIRISCIKIS IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 FROM dbo.vw_PDKS_Giris_Terminalleri g WHERE g.TerminalID = CAST(ayart.TerminalID AS varchar(10))
  )
  AND NOT EXISTS (
      SELECT 1 FROM dbo.vw_PDKS_Cikis_Terminalleri c WHERE c.TerminalID = CAST(ayart.TerminalID AS varchar(10))
  )
ORDER BY ayart.TerminalID;

GO

