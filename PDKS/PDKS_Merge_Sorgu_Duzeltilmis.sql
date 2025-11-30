-- PDKS_HAMDATA_CACHE Tablosunu Link Server'dan Doldurma (MERGE Sorgusu)
-- Tablo: [PDKS_LS].[GULERYUZGROUP14885_Meyer].[dbo].[vw_PDKS_OlayDetay_Bolum3ve6]
-- Cache Tablo: dbo.PDKS_HAMDATA_CACHE

USE PUNTEKS_2025;
GO

-- ============================================================
-- ÖNCE: HANGİ TERMİNALLER MEVCUT? (2025 ve sonrası)
-- ============================================================
-- Bu sorguyu çalıştırıp hangi terminallerin olduğunu görün
SELECT DISTINCT 
    TerminalID,
    TerminalYonu,
    COUNT(*) AS KayitSayisi
FROM [PDKS_LS].[GULERYUZGROUP14885_Meyer].[dbo].[vw_PDKS_OlayDetay_Bolum3ve6]
WHERE EventTime >= '2025-01-01 00:00:00'
  AND DATEPART(YEAR, EventTime) >= 2025
GROUP BY TerminalID, TerminalYonu
ORDER BY TerminalID, TerminalYonu;

-- ============================================================
-- MERGE SORGUSU
-- ============================================================
-- KRİTER: Sadece 2025 ve sonrası veriler alınır
--   - EventTime >= '2025-01-01'
--   - KayitZamani >= SonAktarim veya '2025-01-01' (hangisi büyükse)
--   - Ayar tablosundaki aktif terminallere göre filtreleme (vw_PDKS_Tum_Terminaller view'i kullanılır)

DECLARE @SonAktarim datetime = (
    SELECT ISNULL(MAX(KayitZamani), '19000101')
    FROM dbo.PDKS_HAMDATA_CACHE
);

-- 2025 ve sonrası için minimum tarih
DECLARE @MinTarih datetime = '2025-01-01 00:00:00';

-- Son aktarım tarihi 2025'ten önceyse 2025'i kullan, değilse son aktarım tarihini kullan
DECLARE @BaslangicTarihi datetime = CASE 
    WHEN @SonAktarim < @MinTarih THEN @MinTarih 
    ELSE @SonAktarim 
END;

MERGE dbo.PDKS_HAMDATA_CACHE AS tgt
USING (
    SELECT
        CAST(v.ID AS varchar(10)) AS ID,
        CAST(v.SicilID AS varchar(10)) AS SicilID,
        v.UserID,
        LEFT(v.PersonelAdi, 50) AS PersonelAdi,
        LEFT(v.PersonelSoyadi, 50) AS PersonelSoyadi,
        v.SicilNo,
        CAST(v.Bolum AS varchar(10)) AS Bolum,
        v.Pozisyon,
        CAST(v.TerminalID AS varchar(4)) AS TerminalID,
        LEFT(v.TerminalYonu, 30) AS TerminalYonu,
        v.KartNumarasi,
        CAST(v.CardType AS nvarchar(5)) AS CardType,
        v.EventTime,
        v.EventTime AS EventTimeDt,
        CAST(v.EventTime AS date) AS Tarih,
        CONVERT(char(8), v.EventTime, 108) AS Saat,
        CONVERT(varchar(4), DATEPART(YEAR, v.EventTime)) AS Yil,
        RIGHT('0' + CONVERT(varchar(2), DATEPART(MONTH, v.EventTime)), 2) AS Ay,
        RIGHT('0' + CONVERT(varchar(2), DATEPART(WEEK, v.EventTime)), 2) AS Hafta,
        LEFT(DATENAME(MONTH, v.EventTime), 10) AS Ay_Adi,
        LEFT(DATENAME(WEEKDAY, v.EventTime), 10) AS Gun_Adi,
        CAST(LEFT(v.EventCode, 4) AS varchar(4)) AS EventCode,
        v.FuncCode,
        CAST(v.PDKS AS varchar(1)) AS PDKS,
        LEFT(v.Status, 30) AS Status,
        v.Automatic,
        CAST(v.Deleted AS varchar(10)) AS Deleted,
        v.ReaderID,
        v.UnDelete,
        v.ForeignID,
        v.pdksx,
        v.duzeltme,
        v.mudahale,
        LEFT(v.kayitbilgisi, 10) AS kayitbilgisi,
        LEFT(v.entegrasyonbilgisi, 10) AS entegrasyonbilgisi,
        v.Veri_Gelis,
        v.KayitZamani
    FROM [PDKS_LS].[GULERYUZGROUP14885_Meyer].[dbo].[vw_PDKS_OlayDetay_Bolum3ve6] v
    WHERE EXISTS (
        -- Ayar tablosundaki aktif terminallere göre filtreleme (View kullanarak)
        SELECT 1
        FROM dbo.vw_PDKS_Tum_Terminaller t
        WHERE CAST(t.TerminalID AS varchar(10)) = CAST(v.TerminalID AS varchar(10))
    )
      AND v.EventTime >= @MinTarih  -- Sadece 2025 ve sonrası EventTime
      AND v.KayitZamani >= @BaslangicTarihi  -- Son aktarım veya 2025-01-01'den sonrası
      AND DATEPART(YEAR, v.EventTime) >= 2025  -- Ek kontrol: 2025 ve sonrası
) AS src
    ON tgt.ID = src.ID
WHEN MATCHED THEN UPDATE SET
    tgt.SicilID      = src.SicilID,
    tgt.UserID       = src.UserID,
    tgt.PersonelAdi  = src.PersonelAdi,
    tgt.PersonelSoyadi = src.PersonelSoyadi,
    tgt.SicilNo      = src.SicilNo,
    tgt.Bolum        = src.Bolum,
    tgt.Pozisyon     = src.Pozisyon,
    tgt.TerminalID   = src.TerminalID,
    tgt.TerminalYonu = src.TerminalYonu,
    tgt.KartNumarasi = src.KartNumarasi,
    tgt.CardType     = src.CardType,
    tgt.EventTime    = src.EventTime,
    tgt.EventTimeDt  = src.EventTimeDt,
    tgt.Tarih        = src.Tarih,
    tgt.Saat         = src.Saat,
    tgt.Yil          = src.Yil,
    tgt.Ay           = src.Ay,
    tgt.Hafta        = src.Hafta,
    tgt.Ay_Adi       = src.Ay_Adi,
    tgt.Gun_Adi      = src.Gun_Adi,
    tgt.EventCode    = src.EventCode,
    tgt.FuncCode     = src.FuncCode,
    tgt.PDKS         = src.PDKS,
    tgt.Status       = src.Status,
    tgt.Automatic    = src.Automatic,
    tgt.Deleted      = src.Deleted,
    tgt.ReaderID     = src.ReaderID,
    tgt.UnDelete     = src.UnDelete,
    tgt.ForeignID    = src.ForeignID,
    tgt.pdksx        = src.pdksx,
    tgt.duzeltme     = src.duzeltme,
    tgt.mudahale     = src.mudahale,
    tgt.kayitbilgisi = src.kayitbilgisi,
    tgt.entegrasyonbilgisi = src.entegrasyonbilgisi,
    tgt.Veri_Gelis   = src.Veri_Gelis,
    tgt.KayitZamani  = src.KayitZamani
WHEN NOT MATCHED THEN
    INSERT (
        ID, SicilID, UserID, PersonelAdi, PersonelSoyadi, SicilNo, Bolum, Pozisyon,
        TerminalID, TerminalYonu, KartNumarasi, CardType, EventTime, EventTimeDt,
        Tarih, Saat, Yil, Ay, Hafta, Ay_Adi, Gun_Adi, EventCode, FuncCode, PDKS,
        Status, Automatic, Deleted, ReaderID, UnDelete, ForeignID, pdksx,
        duzeltme, mudahale, kayitbilgisi, entegrasyonbilgisi, Veri_Gelis, KayitZamani
    )
    VALUES (
        src.ID, src.SicilID, src.UserID, src.PersonelAdi, src.PersonelSoyadi, src.SicilNo, src.Bolum, src.Pozisyon,
        src.TerminalID, src.TerminalYonu, src.KartNumarasi, src.CardType, src.EventTime, src.EventTimeDt,
        src.Tarih, src.Saat, src.Yil, src.Ay, src.Hafta, src.Ay_Adi, src.Gun_Adi, src.EventCode, src.FuncCode, src.PDKS,
        src.Status, src.Automatic, src.Deleted, src.ReaderID, src.UnDelete, src.ForeignID, src.pdksx,
        src.duzeltme, src.mudahale, src.kayitbilgisi, src.entegrasyonbilgisi, src.Veri_Gelis, src.KayitZamani
    );

-- Senkron kontrol kaydı ekle
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'PDKS_SENKRON_KONTROL')
BEGIN
    CREATE TABLE dbo.PDKS_SENKRON_KONTROL (
        ID int IDENTITY(1,1) PRIMARY KEY,
        SonGuncelleme datetime NOT NULL,
        KayitSayisi int NULL,
        Durum varchar(50) NULL
    );
END

INSERT INTO dbo.PDKS_SENKRON_KONTROL (SonGuncelleme, KayitSayisi, Durum)
VALUES (GETDATE(), @@ROWCOUNT, 'BASARILI');

GO

