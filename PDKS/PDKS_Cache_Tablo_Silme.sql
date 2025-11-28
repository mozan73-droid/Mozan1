-- PDKS_HAMDATA_CACHE Tablosunu Temizleme
-- DİKKAT: Bu sorgu tablodaki TÜM verileri siler!

USE PUNTEKS_2025;
GO

-- ============================================================
-- MEVCUT DURUMU KONTROL ET
-- ============================================================
SELECT 
    COUNT(*) AS ToplamKayit,
    MIN(EventTime) AS IlkKayit,
    MAX(EventTime) AS SonKayit
FROM dbo.PDKS_HAMDATA_CACHE;

-- ============================================================
-- TABLOYU TEMİZLEME
-- ============================================================

-- DELETE kullan (IDENTITY korunur)
DELETE FROM dbo.PDKS_HAMDATA_CACHE;

PRINT 'Silinen kayıt sayısı: ' + CAST(@@ROWCOUNT AS varchar(10));

-- Alternatif: TRUNCATE kullan (daha hızlı ama IDENTITY sıfırlanır)
-- TRUNCATE TABLE dbo.PDKS_HAMDATA_CACHE;

-- ============================================================
-- DOĞRULAMA
-- ============================================================
SELECT COUNT(*) AS KalanKayitSayisi
FROM dbo.PDKS_HAMDATA_CACHE;

IF (SELECT COUNT(*) FROM dbo.PDKS_HAMDATA_CACHE) = 0
BEGIN
    PRINT 'Tablo başarıyla temizlendi.';
END
ELSE
BEGIN
    PRINT 'UYARI: Tablo hala veri içeriyor!';
END

GO

