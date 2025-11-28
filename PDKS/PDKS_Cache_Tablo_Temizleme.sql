-- PDKS_HAMDATA_CACHE Tablosunu Temizleme
-- DİKKAT: Bu sorgu tablodaki TÜM verileri siler!

USE PUNTEKS_2025;
GO

-- ============================================================
-- ÖNCE: MEVCUT DURUMU KONTROL ET
-- ============================================================
SELECT 
    COUNT(*) AS ToplamKayit,
    MIN(EventTime) AS IlkKayit,
    MAX(EventTime) AS SonKayit,
    MIN(KayitZamani) AS IlkAktarim,
    MAX(KayitZamani) AS SonAktarim
FROM dbo.PDKS_HAMDATA_CACHE;

-- Terminal bazlı kayıt sayıları
SELECT 
    TerminalID,
    TerminalYonu,
    COUNT(*) AS KayitSayisi
FROM dbo.PDKS_HAMDATA_CACHE
GROUP BY TerminalID, TerminalYonu
ORDER BY TerminalID, TerminalYonu;

-- ============================================================
-- TABLOYU TEMİZLEME
-- ============================================================

-- SEÇENEK 1: TRUNCATE (Hızlı, IDENTITY sıfırlar)
-- DİKKAT: TRUNCATE kullanırsanız IDENTITY değeri sıfırlanır
-- TRUNCATE TABLE dbo.PDKS_HAMDATA_CACHE;

-- SEÇENEK 2: DELETE (Yavaş ama IDENTITY korunur)
-- Tüm kayıtları sil
DELETE FROM dbo.PDKS_HAMDATA_CACHE;

-- Silinen kayıt sayısını göster
PRINT 'Silinen kayıt sayısı: ' + CAST(@@ROWCOUNT AS varchar(10));

-- ============================================================
-- SONRA: TABLONUN BOŞ OLDUĞUNU DOĞRULA
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

