-- =============================================
-- PDKS Dashboard SQL Test Sorguları
-- =============================================

-- 1) Şu anda içeride/dışarıda olan kişi sayıları
SELECT Durum, COUNT(*) AS PersonelSayisi
FROM (
    SELECT
        p.SicilNo AS SicilID,
        CASE
            WHEN EXISTS (SELECT 1 FROM dbo.vw_PDKS_Cikis_Terminalleri c WHERE CAST(p.TerminalID AS varchar(10)) = c.TerminalID) THEN 'DISARIDA'
            WHEN EXISTS (SELECT 1 FROM dbo.vw_PDKS_Giris_Terminalleri g WHERE CAST(p.TerminalID AS varchar(10)) = g.TerminalID) THEN 'ICERDE'
            ELSE 'BILINMIYOR'
        END AS Durum,
        ROW_NUMBER() OVER (
            PARTITION BY p.SicilNo
            ORDER BY p.EventTimeDt DESC
        ) AS rn
    FROM dbo.PDKS_HAMDATA_CACHE p WITH (NOLOCK)
    INNER JOIN dbo.PERSM0 per ON LTRIM(RTRIM(CAST(p.SicilNo AS varchar))) = LTRIM(RTRIM(CAST(per.TCKIMLIKNO AS varchar))) COLLATE Turkish_CI_AS
    CROSS JOIN dbo.ZU_P_AYARE ayar WITH (NOLOCK)
    WHERE 1=1 
      AND (ayar.PMO_AP10 IS NULL OR LTRIM(RTRIM(CAST(ayar.PMO_AP10 AS varchar))) = '' OR per.AP10 = ayar.PMO_AP10) 
      AND (ayar.PMO_STATU IS NULL OR LTRIM(RTRIM(CAST(ayar.PMO_STATU AS varchar))) = '' OR per.STATU = ayar.PMO_STATU) 
      AND (ayar.PMO_GK1 IS NULL OR LTRIM(RTRIM(CAST(ayar.PMO_GK1 AS varchar))) = '' OR per.GK_1 = ayar.PMO_GK1) 
    AND CAST(p.EventTimeDt AS date) = CAST(GETDATE() AS date)
) x
WHERE x.rn = 1
GROUP BY x.Durum;

-- =============================================

-- 2) Son X dakikadaki olay listesi (canlı akış)
-- KontrolDk değerini burada değiştirebilirsiniz (örn: 10 dakika)
DECLARE @KontrolDk INT = 10;

SELECT  
    p.EventTimeDt, 
    CAST(LEFT(CONVERT(char(8), p.EventTimeDt, 108), 5) AS varchar(5)) AS HareketSaati, 
    p.PersonelAdi, 
    p.PersonelSoyadi, 
    p.Bolum, 
    p.TerminalID, 
    p.TerminalYonu, 
    CASE 
        WHEN cikis.TerminalID IS NOT NULL THEN 'DISARIDA' 
        WHEN giris.TerminalID IS NOT NULL THEN 'ICERDE' 
        ELSE 'BILINMIYOR' 
    END AS Durum 
    FROM dbo.PDKS_HAMDATA_CACHE p WITH (NOLOCK) 
    INNER JOIN dbo.PERSM0 per ON LTRIM(RTRIM(CAST(p.SicilNo AS varchar))) = LTRIM(RTRIM(CAST(per.TCKIMLIKNO AS varchar))) COLLATE Turkish_CI_AS 
    CROSS JOIN dbo.ZU_P_AYARE ayar WITH (NOLOCK) 
    LEFT JOIN dbo.vw_PDKS_Giris_Terminalleri giris ON CAST(p.TerminalID AS varchar(10)) = giris.TerminalID 
    LEFT JOIN dbo.vw_PDKS_Cikis_Terminalleri cikis ON CAST(p.TerminalID AS varchar(10)) = cikis.TerminalID 
    WHERE EXISTS (SELECT 1 FROM dbo.vw_PDKS_Tum_Terminaller t WHERE CAST(t.TerminalID AS varchar(10)) = CAST(p.TerminalID AS varchar(10))) 
    AND (ayar.PMO_AP10 IS NULL OR LTRIM(RTRIM(CAST(ayar.PMO_AP10 AS varchar))) = '' OR per.AP10 = ayar.PMO_AP10) 
    AND (ayar.PMO_STATU IS NULL OR LTRIM(RTRIM(CAST(ayar.PMO_STATU AS varchar))) = '' OR per.STATU = ayar.PMO_STATU) 
    AND (ayar.PMO_GK1 IS NULL OR LTRIM(RTRIM(CAST(ayar.PMO_GK1 AS varchar))) = '' OR per.GK_1 = ayar.PMO_GK1) 
    AND p.EventTimeDt >= DATEADD(minute, -@KontrolDk, GETDATE()) 
    ORDER BY p.EventTimeDt DESC;

-- =============================================

-- 3) Terminal bazlı günlük toplamlar
SELECT 
    p.TerminalID, 
    p.TerminalYonu, 
    CASE 
        WHEN cikis.TerminalID IS NOT NULL THEN 'CIKIS' 
        WHEN giris.TerminalID IS NOT NULL THEN 'GIRIS' 
        ELSE 'BILINMIYOR' 
    END AS TerminalTipi, 
    COUNT(*) AS OlaySayisi 
    FROM dbo.PDKS_HAMDATA_CACHE p WITH (NOLOCK) 
    INNER JOIN dbo.PERSM0 per ON LTRIM(RTRIM(CAST(p.SicilNo AS varchar))) = LTRIM(RTRIM(CAST(per.TCKIMLIKNO AS varchar))) COLLATE Turkish_CI_AS 
    CROSS JOIN dbo.ZU_P_AYARE ayar WITH (NOLOCK) 
    LEFT JOIN dbo.vw_PDKS_Giris_Terminalleri giris ON CAST(p.TerminalID AS varchar(10)) = giris.TerminalID 
    LEFT JOIN dbo.vw_PDKS_Cikis_Terminalleri cikis ON CAST(p.TerminalID AS varchar(10)) = cikis.TerminalID 
    WHERE EXISTS (SELECT 1 FROM dbo.vw_PDKS_Tum_Terminaller t WHERE CAST(t.TerminalID AS varchar(10)) = CAST(p.TerminalID AS varchar(10))) 
    AND (ayar.PMO_AP10 IS NULL OR LTRIM(RTRIM(CAST(ayar.PMO_AP10 AS varchar))) = '' OR per.AP10 = ayar.PMO_AP10) 
    AND (ayar.PMO_STATU IS NULL OR LTRIM(RTRIM(CAST(ayar.PMO_STATU AS varchar))) = '' OR per.STATU = ayar.PMO_STATU) 
    AND (ayar.PMO_GK1 IS NULL OR LTRIM(RTRIM(CAST(ayar.PMO_GK1 AS varchar))) = '' OR per.GK_1 = ayar.PMO_GK1) 
    AND CAST(p.EventTimeDt AS date) = CAST(GETDATE() AS date) 
    GROUP BY p.TerminalID, p.TerminalYonu, 
        CASE 
            WHEN cikis.TerminalID IS NOT NULL THEN 'CIKIS' 
            WHEN giris.TerminalID IS NOT NULL THEN 'GIRIS' 
            ELSE 'BILINMIYOR' 
        END 
    ORDER BY p.TerminalID;

