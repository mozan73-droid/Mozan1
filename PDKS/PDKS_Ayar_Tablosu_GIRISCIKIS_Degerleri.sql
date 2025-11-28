-- PDKS Ayar Tablosu GIRISCIKIS Değerleri Kontrolü
-- Ayar tablosundaki GIRISCIKIS değerlerini gösterir
-- Bu değerler view'lerde kullanılacaktır

USE PUNTEKS_2025;
GO

-- ============================================================
-- 1. AYAR TABLOSUNDAKİ TÜM GIRISCIKIS DEĞERLERİ
-- ============================================================

SELECT 
    ayare.AP10 AS Aktif,
    ayart.TerminalID,
    ayart.TerminalYonu,
    ayart.GIRISCIKIS AS GIRISCIKIS_Orijinal,
    LTRIM(RTRIM(ayart.GIRISCIKIS)) AS GIRISCIKIS_Trim,
    UPPER(LTRIM(RTRIM(ayart.GIRISCIKIS))) AS GIRISCIKIS_Upper,
    LEN(ayart.GIRISCIKIS) AS GIRISCIKIS_Uzunluk,
    ASCII(LEFT(ayart.GIRISCIKIS, 1)) AS IlkKarakter_ASCII
FROM dbo.ZU_P_AYARE ayare
LEFT JOIN dbo.ZU_P_AYART ayart ON ayart.EVRAKNO = ayare.EVRAKNO
WHERE ayare.AP10 = 1
  AND ayart.TerminalID IS NOT NULL
ORDER BY ayart.GIRISCIKIS, ayart.TerminalID;

-- ============================================================
-- 2. GIRISCIKIS DEĞERLERİNİN GRUPLANMIŞ HALİ
-- ============================================================

SELECT 
    ayart.GIRISCIKIS AS GIRISCIKIS_Orijinal,
    LTRIM(RTRIM(ayart.GIRISCIKIS)) AS GIRISCIKIS_Trim,
    UPPER(LTRIM(RTRIM(ayart.GIRISCIKIS))) AS GIRISCIKIS_Upper,
    COUNT(*) AS KayitSayisi,
    STRING_AGG(CAST(ayart.TerminalID AS varchar(10)), ', ') AS TerminalID_Listesi
FROM dbo.ZU_P_AYARE ayare
LEFT JOIN dbo.ZU_P_AYART ayart ON ayart.EVRAKNO = ayare.EVRAKNO
WHERE ayare.AP10 = 1
  AND ayart.TerminalID IS NOT NULL
  AND ayart.GIRISCIKIS IS NOT NULL
GROUP BY 
    ayart.GIRISCIKIS,
    LTRIM(RTRIM(ayart.GIRISCIKIS)),
    UPPER(LTRIM(RTRIM(ayart.GIRISCIKIS)))
ORDER BY GIRISCIKIS_Upper;

-- ============================================================
-- 3. GİRİŞ TERMİNALLERİ (MEVCUT VIEW'E GÖRE)
-- ============================================================

SELECT 
    TerminalID,
    TerminalYonu,
    GIRISCIKIS
FROM dbo.vw_PDKS_Giris_Terminalleri
ORDER BY TerminalID;

-- ============================================================
-- 4. ÇIKIŞ TERMİNALLERİ (MEVCUT VIEW'E GÖRE)
-- ============================================================

SELECT 
    TerminalID,
    TerminalYonu,
    GIRISCIKIS
FROM dbo.vw_PDKS_Cikis_Terminalleri
ORDER BY TerminalID;

-- ============================================================
-- 5. VIEW'LERDE GÖRÜNMEYEN TERMİNALLER
-- ============================================================

SELECT 
    ayart.TerminalID,
    ayart.TerminalYonu,
    ayart.GIRISCIKIS,
    'Giriş veya Çıkış view''inde görünmüyor' AS Durum
FROM dbo.ZU_P_AYARE ayare
LEFT JOIN dbo.ZU_P_AYART ayart ON ayart.EVRAKNO = ayare.EVRAKNO
WHERE ayare.AP10 = 1
  AND ayart.TerminalID IS NOT NULL
  AND ayart.GIRISCIKIS IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 FROM dbo.vw_PDKS_Giris_Terminalleri g 
      WHERE g.TerminalID = CAST(ayart.TerminalID AS varchar(10))
  )
  AND NOT EXISTS (
      SELECT 1 FROM dbo.vw_PDKS_Cikis_Terminalleri c 
      WHERE c.TerminalID = CAST(ayart.TerminalID AS varchar(10))
  )
ORDER BY ayart.TerminalID;

GO

