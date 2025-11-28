-- Test SQL - 4066 Sicil ID için 26-27 Kasım
-- Bu sorguyu çalıştırıp sonuçları kontrol edin
-- NOT: Giriş ve çıkış terminalleri ayar tablosundan (ZU_P_AYARE ve ZU_P_AYART) dinamik olarak alınır

USE PUNTEKS_2025;
GO

DECLARE @HedefGirisSaati varchar(5) = '07:00';
DECLARE @HedefCikisSaati varchar(5) = '18:00';

SELECT 
    g.Gun,
    g.SicilID,
    MAX(g.PersonelAdi) AS PersonelAdi,
    MAX(g.PersonelSoyadi) AS PersonelSoyadi,
    MAX(g.Gun_Adi) AS Gun_Adi,
    MIN(CASE WHEN g.rn = 1 THEN g.EventTimeDt END) AS IlkGirisTS,
    MAX(CASE WHEN c.rn = 1 THEN c.EventTimeDt END) AS SonCikisTS,
    CAST(LEFT(CONVERT(char(8), MIN(CASE WHEN g.rn = 1 THEN g.EventTimeDt END), 108), 5) AS varchar(5)) AS IlkGiris,
    -- Çıkış saati gösterimi: Ertesi günün 01:30'u ise "25:30" olarak göster
    CASE WHEN MAX(CASE WHEN c.rn = 1 THEN c.EventTimeDt END) IS NOT NULL 
        THEN CASE 
            WHEN CAST(MAX(CASE WHEN c.rn = 1 THEN c.EventTimeDt END) AS time) < '06:00'
            THEN CAST(
                CAST(24 + DATEPART(HOUR, MAX(CASE WHEN c.rn = 1 THEN c.EventTimeDt END)) AS varchar(2)) + ':' +
                RIGHT('0' + CAST(DATEPART(MINUTE, MAX(CASE WHEN c.rn = 1 THEN c.EventTimeDt END)) AS varchar(2)), 2) AS varchar(5)
            )
            ELSE CAST(LEFT(CONVERT(char(8), MAX(CASE WHEN c.rn = 1 THEN c.EventTimeDt END), 108), 5) AS varchar(5))
        END
        ELSE '' 
    END AS SonCikis,
    -- Orijinal çıkış saati (debug için)
    CASE WHEN MAX(CASE WHEN c.rn = 1 THEN c.EventTimeDt END) IS NOT NULL 
        THEN CAST(LEFT(CONVERT(char(8), MAX(CASE WHEN c.rn = 1 THEN c.EventTimeDt END), 108), 5) AS varchar(5)) 
        ELSE '' 
    END AS SonCikis_Orijinal,
    -- Debug: Normalize edilmiş çıkış günü
    MAX(CASE WHEN c.rn = 1 THEN c.Gun_Cikis_Normalize END) AS Gun_Cikis_Normalize,
    MAX(CASE WHEN c.rn = 1 THEN c.Gun_Cikis END) AS Gun_Cikis_Orijinal,
    -- Çalışma Süresi Hesaplamaları
    -- 1. Gerçek süre: Giriş ve çıkış arasındaki gerçek süre (ertesi günün çıkışı dahil)
    DATEDIFF(MINUTE, 
        MIN(CASE WHEN g.rn = 1 THEN g.EventTimeDt END),
        MAX(CASE WHEN c.rn = 1 THEN c.EventTimeDt END)
    ) AS CalismaDakika_Gercek,
    CAST(DATEDIFF(MINUTE, 
        MIN(CASE WHEN g.rn = 1 THEN g.EventTimeDt END),
        MAX(CASE WHEN c.rn = 1 THEN c.EventTimeDt END)
    ) / 60.0 AS DECIMAL(10,2)) AS CalismaSaat_Gercek,
    -- 2. Normalize edilmiş süre: Çıkış ertesi günün 01:30'u ise, normalize edilmiş günün sonuna kadar (23:59:59)
    CASE 
        WHEN MAX(CASE WHEN c.rn = 1 THEN c.EventTimeDt END) IS NOT NULL
        THEN CASE 
            WHEN CAST(MAX(CASE WHEN c.rn = 1 THEN c.EventTimeDt END) AS time) < '06:00'
            -- Çıkış ertesi günün 01:30'u ise, normalize edilmiş günün 23:59:59'una kadar hesapla
            THEN DATEDIFF(MINUTE, 
                MIN(CASE WHEN g.rn = 1 THEN g.EventTimeDt END),
                CAST(CAST(MAX(CASE WHEN c.rn = 1 THEN c.Gun_Cikis_Normalize END) AS varchar(10)) + ' 23:59:59' AS datetime)
            )
            -- Normal çıkış ise gerçek süreyi kullan
            ELSE DATEDIFF(MINUTE, 
                MIN(CASE WHEN g.rn = 1 THEN g.EventTimeDt END),
                MAX(CASE WHEN c.rn = 1 THEN c.EventTimeDt END)
            )
        END
        ELSE NULL
    END AS CalismaDakika_Normalize,
    CASE 
        WHEN MAX(CASE WHEN c.rn = 1 THEN c.EventTimeDt END) IS NOT NULL
        THEN CAST(
            CASE 
                WHEN CAST(MAX(CASE WHEN c.rn = 1 THEN c.EventTimeDt END) AS time) < '06:00'
                THEN DATEDIFF(MINUTE, 
                    MIN(CASE WHEN g.rn = 1 THEN g.EventTimeDt END),
                    CAST(CAST(MAX(CASE WHEN c.rn = 1 THEN c.Gun_Cikis_Normalize END) AS varchar(10)) + ' 23:59:59' AS datetime)
                )
                ELSE DATEDIFF(MINUTE, 
                    MIN(CASE WHEN g.rn = 1 THEN g.EventTimeDt END),
                    MAX(CASE WHEN c.rn = 1 THEN c.EventTimeDt END)
                )
            END / 60.0 AS DECIMAL(10,2)
        )
        ELSE NULL
    END AS CalismaSaat_Normalize,
    -- Hedef saatlerle karşılaştırma
    @HedefGirisSaati AS HedefGiris,
    @HedefCikisSaati AS HedefCikis,
    DATEDIFF(MINUTE, 
        CAST(@HedefGirisSaati AS time),
        CAST(LEFT(CONVERT(char(8), MIN(CASE WHEN g.rn = 1 THEN g.EventTimeDt END), 108), 5) AS time)
    ) AS GecikmeDakika,
    CASE WHEN MAX(CASE WHEN c.rn = 1 THEN c.EventTimeDt END) IS NOT NULL
        THEN DATEDIFF(MINUTE, 
            MAX(CASE WHEN c.rn = 1 THEN c.EventTimeDt END),
            CAST(CAST(g.Gun AS varchar(10)) + ' ' + @HedefCikisSaati AS datetime)
        )
        ELSE NULL
    END AS ErkenCikisDakika
FROM (
    SELECT 
        p.SicilID,
        MAX(p.PersonelAdi) AS PersonelAdi,
        MAX(p.PersonelSoyadi) AS PersonelSoyadi,
        CAST(p.EventTimeDt AS date) AS Gun,
        CASE DATEPART(WEEKDAY, CAST(p.EventTimeDt AS date)) 
            WHEN 1 THEN 'Pazar' 
            WHEN 2 THEN 'Pazartesi' 
            WHEN 3 THEN 'Salı' 
            WHEN 4 THEN 'Çarşamba' 
            WHEN 5 THEN 'Perşembe' 
            WHEN 6 THEN 'Cuma' 
            WHEN 7 THEN 'Cumartesi' 
        END AS Gun_Adi,
        p.EventTimeDt,
        ROW_NUMBER() OVER (PARTITION BY p.SicilID, CAST(p.EventTimeDt AS date) ORDER BY p.EventTimeDt) AS rn 
    FROM dbo.PDKS_HAMDATA_CACHE p WITH (NOLOCK) 
    INNER JOIN dbo.vw_PDKS_Giris_Terminalleri giris ON CAST(p.TerminalID AS varchar(10)) = giris.TerminalID
    WHERE p.SicilID = 4066
      AND CAST(p.EventTimeDt AS date) BETWEEN '2025-11-26' AND '2025-11-27'
    GROUP BY p.SicilID, CAST(p.EventTimeDt AS date), p.EventTimeDt 
) g 
LEFT JOIN (
    SELECT 
        p.SicilID,
        CAST(p.EventTimeDt AS date) AS Gun_Cikis,
        CASE 
            WHEN CONVERT(time, p.EventTimeDt) < '06:00' 
            THEN DATEADD(DAY, -1, CAST(p.EventTimeDt AS date))
            ELSE CAST(p.EventTimeDt AS date) 
        END AS Gun_Cikis_Normalize,
        p.EventTimeDt,
        ROW_NUMBER() OVER (PARTITION BY p.SicilID, 
            CASE 
                WHEN CONVERT(time, p.EventTimeDt) < '06:00' 
                THEN DATEADD(DAY, -1, CAST(p.EventTimeDt AS date))
                ELSE CAST(p.EventTimeDt AS date) 
            END 
            ORDER BY p.EventTimeDt DESC) AS rn 
    FROM dbo.PDKS_HAMDATA_CACHE p WITH (NOLOCK) 
    INNER JOIN dbo.vw_PDKS_Cikis_Terminalleri cikis ON CAST(p.TerminalID AS varchar(10)) = cikis.TerminalID
    WHERE p.SicilID = 4066
      AND CAST(p.EventTimeDt AS date) BETWEEN '2025-11-25' AND '2025-11-28'
    GROUP BY p.SicilID, CAST(p.EventTimeDt AS date), p.EventTimeDt 
) c ON g.SicilID = c.SicilID 
   AND g.Gun = c.Gun_Cikis_Normalize 
WHERE g.EventTimeDt IS NOT NULL 
GROUP BY g.Gun, g.SicilID
ORDER BY g.Gun ASC;

