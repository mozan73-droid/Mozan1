-- Giriş Yapmayanlar Listesi SQL Kodu
-- RaporTarihi değişkenini ihtiyacınıza göre değiştirin

DECLARE @RaporTarihi DATE = '2024-11-30';  -- Örnek tarih, ihtiyacınıza göre değiştirin

SELECT 
    'GIRIS_YAPMAYANLAR' AS Kategori,
    v.TCKIMLIKNO_PDKS AS SicilID,
    v.AD AS PersonelAdi,
    v.SOYAD AS PersonelSoyadi,
    NULL AS IlkGiris,
    NULL AS GecikmeDakika,
    v.STIME AS STIME,
    v.ETIME AS ETIME,
    v.HESAPSABLONU AS HESAPSABLONU
FROM dbo.VW_PERSM0_PDKS v WITH (NOLOCK)
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.PDKS_HAMDATA_CACHE p WITH (NOLOCK)
    INNER JOIN dbo.vw_PDKS_Giris_Terminalleri giris ON CAST(p.TerminalID AS varchar(10)) = giris.TerminalID 
    WHERE CAST(p.EventTimeDt AS date) = @RaporTarihi
      AND LTRIM(RTRIM(CAST(p.SicilNo AS varchar))) = v.TCKIMLIKNO_PDKS COLLATE Turkish_CI_AS
)
ORDER BY v.AD, v.SOYAD;

