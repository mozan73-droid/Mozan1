-- PDKS Puantaj Personel Toplam Sorgusu
-- Veritabanı: PUNTEKS_2025
-- Tablo: PDKS_HAMDATA_CACHE
-- Tarih: 2025-11-28

-- Günlük Personel Puantaj Toplamları
-- Her personel için günlük giriş-çıkış saatleri ve toplam çalışma süresi

SELECT 
    p.SicilID,
    p.PersonelAdi + ' ' + p.PersonelSoyadi AS PersonelAdSoyad,
    p.SicilNo,
    p.Bolum,
    CAST(p.EventTime AS DATE) AS Tarih,
    MIN(CASE WHEN giris.TerminalID IS NOT NULL 
             THEN CAST(p.EventTime AS TIME) END) AS GirisSaati,
    MAX(CASE WHEN cikis.TerminalID IS NOT NULL 
             THEN CAST(p.EventTime AS TIME) END) AS CikisSaati,
    DATEDIFF(MINUTE, 
        MIN(CASE WHEN giris.TerminalID IS NOT NULL 
                 THEN p.EventTime END),
        MAX(CASE WHEN cikis.TerminalID IS NOT NULL 
                 THEN p.EventTime END)
    ) AS CalismaDakika,
    CAST(DATEDIFF(MINUTE, 
        MIN(CASE WHEN giris.TerminalID IS NOT NULL 
                 THEN p.EventTime END),
        MAX(CASE WHEN cikis.TerminalID IS NOT NULL 
                 THEN p.EventTime END)
    ) / 60.0 AS DECIMAL(10,2)) AS CalismaSaat,
    COUNT(DISTINCT CASE WHEN giris.TerminalID IS NOT NULL 
                        THEN p.ID END) AS GirisSayisi,
    COUNT(DISTINCT CASE WHEN cikis.TerminalID IS NOT NULL 
                        THEN p.ID END) AS CikisSayisi
FROM 
    dbo.PDKS_HAMDATA_CACHE p
    LEFT JOIN dbo.vw_PDKS_Giris_Terminalleri giris ON CAST(p.TerminalID AS varchar(10)) = giris.TerminalID
    LEFT JOIN dbo.vw_PDKS_Cikis_Terminalleri cikis ON CAST(p.TerminalID AS varchar(10)) = cikis.TerminalID
WHERE 
    p.Deleted = 0
    AND p.Status IS NOT NULL
    AND CAST(p.EventTime AS DATE) >= DATEADD(DAY, -30, GETDATE()) -- Son 30 gün
GROUP BY 
    p.SicilID,
    p.PersonelAdi,
    p.PersonelSoyadi,
    p.SicilNo,
    p.Bolum,
    CAST(p.EventTime AS DATE)
ORDER BY 
    CAST(p.EventTime AS DATE) DESC,
    p.PersonelAdi,
    p.PersonelSoyadi;

-- Aylık Personel Puantaj Özeti
SELECT 
    p.SicilID,
    p.PersonelAdi + ' ' + p.PersonelSoyadi AS PersonelAdSoyad,
    p.SicilNo,
    p.Bolum,
    YEAR(p.EventTime) AS Yil,
    MONTH(p.EventTime) AS Ay,
    COUNT(DISTINCT CAST(p.EventTime AS DATE)) AS CalisilanGun,
    SUM(DATEDIFF(MINUTE, 
        MIN(CASE WHEN giris.TerminalID IS NOT NULL 
                 THEN p.EventTime END),
        MAX(CASE WHEN cikis.TerminalID IS NOT NULL 
                 THEN p.EventTime END)
    )) AS ToplamCalismaDakika,
    CAST(SUM(DATEDIFF(MINUTE, 
        MIN(CASE WHEN giris.TerminalID IS NOT NULL 
                 THEN p.EventTime END),
        MAX(CASE WHEN cikis.TerminalID IS NOT NULL 
                 THEN p.EventTime END)
    )) / 60.0 AS DECIMAL(10,2)) AS ToplamCalismaSaat
FROM 
    dbo.PDKS_HAMDATA_CACHE p
    LEFT JOIN dbo.vw_PDKS_Giris_Terminalleri giris ON CAST(p.TerminalID AS varchar(10)) = giris.TerminalID
    LEFT JOIN dbo.vw_PDKS_Cikis_Terminalleri cikis ON CAST(p.TerminalID AS varchar(10)) = cikis.TerminalID
WHERE 
    p.Deleted = 0
    AND p.Status IS NOT NULL
    AND p.EventTime >= DATEADD(MONTH, -3, GETDATE()) -- Son 3 ay
GROUP BY 
    p.SicilID,
    p.PersonelAdi,
    p.PersonelSoyadi,
    p.SicilNo,
    p.Bolum,
    YEAR(p.EventTime),
    MONTH(p.EventTime)
ORDER BY 
    YEAR(p.EventTime) DESC,
    MONTH(p.EventTime) DESC,
    p.PersonelAdi,
    p.PersonelSoyadi;

