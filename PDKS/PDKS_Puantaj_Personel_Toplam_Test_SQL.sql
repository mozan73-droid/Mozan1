-- Puantaj_Personel_Toplam Fonksiyonu SQL Kodu
-- Test için: NormalMesaiDakika = 450, Tarih/Ay/SicilID filtrelerini ihtiyacınıza göre düzenleyin
-- NOT: PM0_ (sıfır ile) kullanılıyor, PMO_ (O harfi ile) değil

DECLARE @NormalMesaiDakika INT = 450;  -- Varsayılan değer (7.5 saat = 450 dakika)
DECLARE @KRTTARIH1 DATE = NULL;  -- Örnek: '2024-11-01'
DECLARE @KRTTARIH2 DATE = NULL;  -- Örnek: '2024-11-30'
DECLARE @AY VARCHAR(2) = NULL;  -- Örnek: '11'
DECLARE @SicilID VARCHAR(20) = NULL;  -- Örnek: '12345678901'

SELECT 
    p.TCKIMLIKNO AS SicilID,
    MAX(per.AD) AS PersonelAdi,
    MAX(per.SOYAD) AS PersonelSoyadi,
    COUNT(DISTINCT g.Gun) AS ToplamCalismaGunu,
    SUM(CASE 
        WHEN g.IlkGiris IS NOT NULL AND c.SonCikis IS NOT NULL
        THEN DATEDIFF(minute, g.IlkGiris, c.SonCikis)
        ELSE 0
    END) AS ToplamCalismaDakika,
    CAST(SUM(CASE 
        WHEN g.IlkGiris IS NOT NULL AND c.SonCikis IS NOT NULL
        THEN DATEDIFF(minute, g.IlkGiris, c.SonCikis)
        ELSE 0
    END) / 60 AS varchar(10)) + ':' + 
    RIGHT('0' + CAST(SUM(CASE 
        WHEN g.IlkGiris IS NOT NULL AND c.SonCikis IS NOT NULL
        THEN DATEDIFF(minute, g.IlkGiris, c.SonCikis)
        ELSE 0
    END) % 60 AS varchar(2)), 2) AS ToplamCalismaSaat,
    SUM(CASE 
        WHEN DATEPART(WEEKDAY, g.Gun) NOT IN (1, 7) 
         AND g.IlkGiris IS NOT NULL AND c.SonCikis IS NOT NULL
         AND DATEDIFF(minute, g.IlkGiris, c.SonCikis) > @NormalMesaiDakika 
        THEN DATEDIFF(minute, g.IlkGiris, c.SonCikis) - @NormalMesaiDakika
        ELSE 0
    END) AS ToplamFazlaMesaiDakika,
    CAST(SUM(CASE 
        WHEN DATEPART(WEEKDAY, g.Gun) NOT IN (1, 7) 
         AND g.IlkGiris IS NOT NULL AND c.SonCikis IS NOT NULL
         AND DATEDIFF(minute, g.IlkGiris, c.SonCikis) > @NormalMesaiDakika 
        THEN DATEDIFF(minute, g.IlkGiris, c.SonCikis) - @NormalMesaiDakika
        ELSE 0
    END) / 60 AS varchar(10)) + ':' + 
    RIGHT('0' + CAST(SUM(CASE 
        WHEN DATEPART(WEEKDAY, g.Gun) NOT IN (1, 7) 
         AND g.IlkGiris IS NOT NULL AND c.SonCikis IS NOT NULL
         AND DATEDIFF(minute, g.IlkGiris, c.SonCikis) > @NormalMesaiDakika 
        THEN DATEDIFF(minute, g.IlkGiris, c.SonCikis) - @NormalMesaiDakika
        ELSE 0
    END) % 60 AS varchar(2)), 2) AS ToplamFazlaMesaiSaat,
    SUM(CASE 
        WHEN DATEPART(WEEKDAY, g.Gun) NOT IN (1, 7) 
         AND g.IlkGiris IS NOT NULL AND c.SonCikis IS NOT NULL
        THEN @NormalMesaiDakika
        ELSE 0
    END) AS ToplamNormalMesaiDakika,
    CAST(SUM(CASE 
        WHEN DATEPART(WEEKDAY, g.Gun) NOT IN (1, 7) 
         AND g.IlkGiris IS NOT NULL AND c.SonCikis IS NOT NULL
        THEN @NormalMesaiDakika
        ELSE 0
    END) / 60 AS varchar(10)) + ':' + 
    RIGHT('0' + CAST(SUM(CASE 
        WHEN DATEPART(WEEKDAY, g.Gun) NOT IN (1, 7) 
         AND g.IlkGiris IS NOT NULL AND c.SonCikis IS NOT NULL
        THEN @NormalMesaiDakika
        ELSE 0
    END) % 60 AS varchar(2)), 2) AS ToplamNormalMesaiSaat,
    SUM(CASE 
        WHEN DATEPART(WEEKDAY, g.Gun) IN (1, 7) 
         AND g.IlkGiris IS NOT NULL AND c.SonCikis IS NOT NULL
        THEN @NormalMesaiDakika
        ELSE 0
    END) AS ToplamHaftaTatilDakika,
    CAST(SUM(CASE 
        WHEN DATEPART(WEEKDAY, g.Gun) IN (1, 7) 
         AND g.IlkGiris IS NOT NULL AND c.SonCikis IS NOT NULL
        THEN @NormalMesaiDakika
        ELSE 0
    END) / 60 AS varchar(10)) + ':' + 
    RIGHT('0' + CAST(SUM(CASE 
        WHEN DATEPART(WEEKDAY, g.Gun) IN (1, 7) 
         AND g.IlkGiris IS NOT NULL AND c.SonCikis IS NOT NULL
        THEN @NormalMesaiDakika
        ELSE 0
    END) % 60 AS varchar(2)), 2) AS ToplamHaftaTatilSaat,
    SUM(CASE 
        WHEN DATEPART(WEEKDAY, g.Gun) IN (1, 7) 
         AND g.IlkGiris IS NOT NULL AND c.SonCikis IS NOT NULL
         AND DATEDIFF(minute, g.IlkGiris, c.SonCikis) > @NormalMesaiDakika 
        THEN DATEDIFF(minute, g.IlkGiris, c.SonCikis) - @NormalMesaiDakika
        ELSE 0
    END) AS ToplamHTFazlaMesaiDakika,
    CAST(SUM(CASE 
        WHEN DATEPART(WEEKDAY, g.Gun) IN (1, 7) 
         AND g.IlkGiris IS NOT NULL AND c.SonCikis IS NOT NULL
         AND DATEDIFF(minute, g.IlkGiris, c.SonCikis) > @NormalMesaiDakika 
        THEN DATEDIFF(minute, g.IlkGiris, c.SonCikis) - @NormalMesaiDakika
        ELSE 0
    END) / 60 AS varchar(10)) + ':' + 
    RIGHT('0' + CAST(SUM(CASE 
        WHEN DATEPART(WEEKDAY, g.Gun) IN (1, 7) 
         AND g.IlkGiris IS NOT NULL AND c.SonCikis IS NOT NULL
         AND DATEDIFF(minute, g.IlkGiris, c.SonCikis) > @NormalMesaiDakika 
        THEN DATEDIFF(minute, g.IlkGiris, c.SonCikis) - @NormalMesaiDakika
        ELSE 0
    END) % 60 AS varchar(2)), 2) AS ToplamHTFazlaMesaiSaat,
    CASE 
        WHEN COUNT(DISTINCT g.Gun) > 0
        THEN CAST(SUM(CASE 
            WHEN g.IlkGiris IS NOT NULL AND c.SonCikis IS NOT NULL
            THEN DATEDIFF(minute, g.IlkGiris, c.SonCikis)
            ELSE 0
        END) / COUNT(DISTINCT g.Gun) AS int)
        ELSE 0
    END AS OrtalamaGunlukCalismaDakika
FROM (
    SELECT 
        LTRIM(RTRIM(CAST(p.TCKIMLIKNO AS varchar))) AS TCKIMLIKNO
    FROM dbo.PERSM0 p WITH (NOLOCK)
    CROSS JOIN dbo.ZU_P_AYARE ayar WITH (NOLOCK)
    WHERE 1=1 
      AND (ayar.PM0_AP10 IS NULL OR LTRIM(RTRIM(CAST(ayar.PM0_AP10 AS varchar))) = '' OR p.AP10 = ayar.PM0_AP10) 
      AND (ayar.PM0_STATU IS NULL OR LTRIM(RTRIM(CAST(ayar.PM0_STATU AS varchar))) = '' OR p.STATU = ayar.PM0_STATU) 
      AND (ayar.PM0_GK1 IS NULL OR LTRIM(RTRIM(CAST(ayar.PM0_GK1 AS varchar))) = '' OR p.GK_1 = ayar.PM0_GK1) 
      -- SicilID filtresi (ihtiyaca göre açın)
      -- AND LTRIM(RTRIM(CAST(p.TCKIMLIKNO AS varchar))) = @SicilID
    GROUP BY p.TCKIMLIKNO
) p
INNER JOIN dbo.PERSM0 per ON LTRIM(RTRIM(CAST(p.TCKIMLIKNO AS varchar))) = LTRIM(RTRIM(CAST(per.TCKIMLIKNO AS varchar)))
LEFT JOIN (
    SELECT 
        LTRIM(RTRIM(CAST(p.SicilNo AS varchar))) AS TCKIMLIKNO,
        CAST(p.EventTimeDt AS date) AS Gun,
        MIN(p.EventTimeDt) AS IlkGiris
    FROM dbo.PDKS_HAMDATA_CACHE p WITH (NOLOCK)
    INNER JOIN dbo.vw_PDKS_Giris_Terminalleri giris ON CAST(p.TerminalID AS varchar(10)) = giris.TerminalID 
    INNER JOIN dbo.PERSM0 per ON LTRIM(RTRIM(CAST(p.SicilNo AS varchar))) = LTRIM(RTRIM(CAST(per.TCKIMLIKNO AS varchar))) COLLATE Turkish_CI_AS 
    CROSS JOIN dbo.ZU_P_AYARE ayar WITH (NOLOCK) 
    WHERE 1=1 
      AND (ayar.PM0_AP10 IS NULL OR LTRIM(RTRIM(CAST(ayar.PM0_AP10 AS varchar))) = '' OR per.AP10 = ayar.PM0_AP10) 
      AND (ayar.PM0_STATU IS NULL OR LTRIM(RTRIM(CAST(ayar.PM0_STATU AS varchar))) = '' OR per.STATU = ayar.PM0_STATU) 
      AND (ayar.PM0_GK1 IS NULL OR LTRIM(RTRIM(CAST(ayar.PM0_GK1 AS varchar))) = '' OR per.GK_1 = ayar.PM0_GK1) 
      -- Tarih filtreleri (ihtiyaca göre açın)
      -- AND CAST(p.EventTimeDt AS date) >= @KRTTARIH1
      -- AND CAST(p.EventTimeDt AS date) <= @KRTTARIH2
      -- AND p.Ay = @AY
      -- AND LTRIM(RTRIM(CAST(p.SicilNo AS varchar))) = @SicilID
    GROUP BY p.SicilNo, CAST(p.EventTimeDt AS date)
) g ON LTRIM(RTRIM(CAST(p.TCKIMLIKNO AS varchar))) = LTRIM(RTRIM(CAST(g.TCKIMLIKNO AS varchar))) COLLATE Turkish_CI_AS
LEFT JOIN (
    SELECT 
        LTRIM(RTRIM(CAST(p.SicilNo AS varchar))) AS TCKIMLIKNO,
        CAST(p.EventTimeDt AS date) AS Gun,
        MAX(p.EventTimeDt) AS SonCikis
    FROM dbo.PDKS_HAMDATA_CACHE p WITH (NOLOCK)
    INNER JOIN dbo.vw_PDKS_Cikis_Terminalleri cikis ON CAST(p.TerminalID AS varchar(10)) = cikis.TerminalID 
    INNER JOIN dbo.PERSM0 per ON LTRIM(RTRIM(CAST(p.SicilNo AS varchar))) = LTRIM(RTRIM(CAST(per.TCKIMLIKNO AS varchar))) COLLATE Turkish_CI_AS 
    CROSS JOIN dbo.ZU_P_AYARE ayar WITH (NOLOCK) 
    WHERE 1=1 
      AND (ayar.PM0_AP10 IS NULL OR LTRIM(RTRIM(CAST(ayar.PM0_AP10 AS varchar))) = '' OR per.AP10 = ayar.PM0_AP10) 
      AND (ayar.PM0_STATU IS NULL OR LTRIM(RTRIM(CAST(ayar.PM0_STATU AS varchar))) = '' OR per.STATU = ayar.PM0_STATU) 
      AND (ayar.PM0_GK1 IS NULL OR LTRIM(RTRIM(CAST(ayar.PM0_GK1 AS varchar))) = '' OR per.GK_1 = ayar.PM0_GK1) 
      -- Çıkış için tarih filtreleri (ertesi günü de kapsamak için genişletilmiş) (ihtiyaca göre açın)
      -- AND CAST(p.EventTimeDt AS date) >= DATEADD(DAY, -1, @KRTTARIH1)
      -- AND CAST(p.EventTimeDt AS date) <= DATEADD(DAY, 1, @KRTTARIH2)
      -- AND p.Ay = @AY
      -- AND LTRIM(RTRIM(CAST(p.SicilNo AS varchar))) = @SicilID
    GROUP BY p.SicilNo, CAST(p.EventTimeDt AS date)
) c ON LTRIM(RTRIM(CAST(p.TCKIMLIKNO AS varchar))) = LTRIM(RTRIM(CAST(c.TCKIMLIKNO AS varchar))) COLLATE Turkish_CI_AS 
   AND (
       -- Aynı gün çıkış 
       g.Gun = c.Gun 
       OR 
       -- Ertesi gün çıkış (gece vardiyası kontrolü zaman kontrolü ile yapılacak) 
       c.Gun = DATEADD(DAY, 1, g.Gun) 
   )
GROUP BY p.TCKIMLIKNO
HAVING COUNT(DISTINCT g.Gun) > 0
ORDER BY MAX(per.AD) ASC, MAX(per.SOYAD) ASC;
