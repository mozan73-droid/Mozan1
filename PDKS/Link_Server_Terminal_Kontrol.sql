-- Link Server Tablosunda Mevcut Terminallerin Kontrolü
-- Tablo: [PDKS_LS].[GULERYUZGROUP14885_Meyer].[dbo].[vw_PDKS_OlayDetay_Bolum3ve6]

-- 1. Tüm terminalleri listele
SELECT 
    TerminalID,
    TerminalYonu,
    COUNT(*) AS KayitSayisi,
    MIN(EventTime) AS IlkKayit,
    MAX(EventTime) AS SonKayit
FROM [PDKS_LS].[GULERYUZGROUP14885_Meyer].[dbo].[vw_PDKS_OlayDetay_Bolum3ve6]
GROUP BY TerminalID, TerminalYonu
ORDER BY TerminalID, TerminalYonu;

-- 2. Sadece terminal ID'leri listele (benzersiz)
SELECT DISTINCT 
    TerminalID,
    COUNT(*) AS ToplamKayit
FROM [PDKS_LS].[GULERYUZGROUP14885_Meyer].[dbo].[vw_PDKS_OlayDetay_Bolum3ve6]
GROUP BY TerminalID
ORDER BY TerminalID;

-- 3. Son 7 günün verilerini kontrol et
SELECT 
    TerminalID,
    TerminalYonu,
    COUNT(*) AS KayitSayisi,
    CAST(EventTime AS DATE) AS Tarih
FROM [PDKS_LS].[GULERYUZGROUP14885_Meyer].[dbo].[vw_PDKS_OlayDetay_Bolum3ve6]
WHERE EventTime >= DATEADD(DAY, -7, GETDATE())
GROUP BY TerminalID, TerminalYonu, CAST(EventTime AS DATE)
ORDER BY CAST(EventTime AS DATE) DESC, TerminalID;

