-- PDKS Terminal Ayar View'leri
-- Ayar tablosundan GİRİŞ ve ÇIKIŞ terminallerini dinamik olarak almak için
-- GIRISCIKIS alanına göre filtreleme yapılır

USE PUNTEKS_2025;
GO

-- ============================================================
-- 1. GİRİŞ TERMİNALLERİ VIEW'İ
-- ============================================================
-- Ayar tablosundan GİRİŞ terminallerini alır
-- TerminalID'yi eşitleyip GIRISCIKIS alanındaki değeri doğrudan eşitler
-- GIRISCIKIS = 'GIRIS' olan terminalleri alır

IF EXISTS (SELECT 1 FROM sys.views WHERE name = 'vw_PDKS_Giris_Terminalleri')
    DROP VIEW dbo.vw_PDKS_Giris_Terminalleri;
GO

CREATE VIEW dbo.vw_PDKS_Giris_Terminalleri
AS
SELECT DISTINCT
    CAST(ayart.TerminalID AS varchar(10)) AS TerminalID,
    ayart.TerminalYonu,
    ayart.GIRISCIKIS
FROM dbo.ZU_P_AYARE ayare
LEFT JOIN dbo.ZU_P_AYART ayart ON ayart.EVRAKNO = ayare.EVRAKNO
WHERE ayare.AP10 = 1  -- Aktif olanlar
  AND ayart.TerminalID IS NOT NULL
  AND ayart.GIRISCIKIS = 'GIRIS';
GO

-- ============================================================
-- 2. ÇIKIŞ TERMİNALLERİ VIEW'İ
-- ============================================================
-- Ayar tablosundan ÇIKIŞ terminallerini alır
-- TerminalID'yi eşitleyip GIRISCIKIS alanındaki değeri doğrudan eşitler
-- GIRISCIKIS = 'CIKIS' olan terminalleri alır

IF EXISTS (SELECT 1 FROM sys.views WHERE name = 'vw_PDKS_Cikis_Terminalleri')
    DROP VIEW dbo.vw_PDKS_Cikis_Terminalleri;
GO

CREATE VIEW dbo.vw_PDKS_Cikis_Terminalleri
AS
SELECT DISTINCT
    CAST(ayart.TerminalID AS varchar(10)) AS TerminalID,
    ayart.TerminalYonu,
    ayart.GIRISCIKIS
FROM dbo.ZU_P_AYARE ayare
LEFT JOIN dbo.ZU_P_AYART ayart ON ayart.EVRAKNO = ayare.EVRAKNO
WHERE ayare.AP10 = 1  -- Aktif olanlar
  AND ayart.TerminalID IS NOT NULL
  AND ayart.GIRISCIKIS = 'CIKIS';
GO

-- ============================================================
-- 3. TÜM TERMİNALLER VIEW'İ
-- ============================================================
-- Ayar tablosundan tüm aktif terminalleri alır

IF EXISTS (SELECT 1 FROM sys.views WHERE name = 'vw_PDKS_Tum_Terminaller')
    DROP VIEW dbo.vw_PDKS_Tum_Terminaller;
GO

CREATE VIEW dbo.vw_PDKS_Tum_Terminaller
AS
SELECT DISTINCT
    CAST(ayart.TerminalID AS varchar(10)) AS TerminalID,
    ayart.TerminalYonu,
    ayart.GIRISCIKIS
FROM dbo.ZU_P_AYARE ayare
LEFT JOIN dbo.ZU_P_AYART ayart ON ayart.EVRAKNO = ayare.EVRAKNO
WHERE ayare.AP10 = 1  -- Aktif olanlar
  AND ayart.TerminalID IS NOT NULL;
GO

-- ============================================================
-- 4. KULLANIM ÖRNEKLERİ
-- ============================================================

-- Giriş terminallerini listele
-- SELECT * FROM dbo.vw_PDKS_Giris_Terminalleri;

-- Çıkış terminallerini listele
-- SELECT * FROM dbo.vw_PDKS_Cikis_Terminalleri;

-- Tüm terminalleri listele
-- SELECT * FROM dbo.vw_PDKS_Tum_Terminaller;

-- Giriş terminallerini IN clause'da kullanma
-- SELECT TerminalID FROM dbo.vw_PDKS_Giris_Terminalleri;

-- Çıkış terminallerini IN clause'da kullanma
-- SELECT TerminalID FROM dbo.vw_PDKS_Cikis_Terminalleri;

GO

