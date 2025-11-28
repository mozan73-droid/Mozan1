-- PDKS Ham Veri Liste View'i
-- Veritabanı: PUNTEKS_2025
-- View Adı: vw_PDKS_HAMDATA_Liste
-- Tarih: 2025-11-28

-- View oluşturma scripti (log dosyalarından alınmıştır)
CREATE OR ALTER VIEW dbo.vw_PDKS_HAMDATA_Liste 
AS 
SELECT 
    ID, 
    SicilID, 
    PersonelAdi, 
    PersonelSoyadi, 
    Bolum, 
    TerminalID, 
    TerminalYonu, 
    EventTimeDt, 
    Tarih, 
    Saat, 
    Yil, 
    Ay, 
    Hafta, 
    PDKS, 
    Status 
FROM 
    dbo.PDKS_HAMDATA_CACHE;

-- Not: Eğer EventTimeDt, Tarih, Saat, Yil, Ay, Hafta kolonları 
-- PDKS_HAMDATA_CACHE tablosunda yoksa, bunları hesaplayarak view oluşturulabilir:

/*
CREATE OR ALTER VIEW dbo.vw_PDKS_HAMDATA_Liste 
AS 
SELECT 
    ID, 
    SicilID, 
    PersonelAdi, 
    PersonelSoyadi, 
    Bolum, 
    TerminalID, 
    TerminalYonu, 
    EventTime AS EventTimeDt,
    CAST(EventTime AS DATE) AS Tarih,
    CAST(EventTime AS TIME) AS Saat,
    YEAR(EventTime) AS Yil,
    MONTH(EventTime) AS Ay,
    DATEPART(WEEK, EventTime) AS Hafta,
    PDKS, 
    Status 
FROM 
    dbo.PDKS_HAMDATA_CACHE
WHERE 
    Deleted = 0;
*/

