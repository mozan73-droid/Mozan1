-- ============================================================
-- Günlük Yoklama Raporu - Otomatik E-Posta Servisi
-- ============================================================
-- Veritabanı: PUNTEKS_2025
-- Tablo: PDKS_HAMDATA_CACHE
-- Tarih: 2025-11-28
-- Açıklama: SQL Server üzerinden günlük yoklama raporunu 
--           otomatik olarak e-posta ile gönderen script
-- ============================================================

USE PUNTEKS_2025;
GO

-- ============================================================
-- 1. DATABASE MAIL YAPILANDIRMASI (İlk Kurulum İçin)
-- ============================================================
-- Not: Bu bölüm sadece ilk kurulumda bir kez çalıştırılmalıdır
-- Database Mail zaten yapılandırılmışsa bu bölümü atlayın

/*
-- Database Mail'i etkinleştir
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Database Mail XPs', 1;
RECONFIGURE;

-- Mail Profili Oluştur
EXEC msdb.dbo.sysmail_add_profile_sp
    @profile_name = 'PDKS_Mail_Profile',
    @description = 'PDKS Günlük Yoklama Raporu Mail Profili';

-- Mail Hesabı Oluştur
EXEC msdb.dbo.sysmail_add_account_sp
    @account_name = 'PDKS_Mail_Account',
    @description = 'PDKS Mail Gönderim Hesabı',
    @email_address = 'pdks@punteks.com',  -- Gönderen e-posta adresi
    @display_name = 'Punteks PDKS Sistemi',
    @mailserver_name = 'smtp.gmail.com',  -- SMTP sunucu adresi
    @port = 587,
    @username = 'pdks@punteks.com',      -- SMTP kullanıcı adı
    @password = '********',               -- SMTP şifresi
    @use_default_credentials = 0,
    @enable_ssl = 1;

-- Profil ve Hesabı Bağla
EXEC msdb.dbo.sysmail_add_profileaccount_sp
    @profile_name = 'PDKS_Mail_Profile',
    @account_name = 'PDKS_Mail_Account',
    @sequence_number = 1;
*/

-- ============================================================
-- 2. GÜNLÜK YOKLAMA RAPORU STORED PROCEDURE
-- ============================================================

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_PDKS_GunlukYoklamaMailGonder]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_PDKS_GunlukYoklamaMailGonder];
GO

CREATE PROCEDURE [dbo].[sp_PDKS_GunlukYoklamaMailGonder]
    @Tarih DATE = NULL,
    @AliciMail NVARCHAR(MAX) = NULL,
    @TestModu BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Tarih belirtilmemişse bugünün tarihini kullan
    IF @Tarih IS NULL
        SET @Tarih = CAST(GETDATE() AS DATE);
    
    -- Alıcı mail belirtilmemişse varsayılan mail adresini kullan
    IF @AliciMail IS NULL
        SET @AliciMail = 'mozan73@gmail.com';  -- Varsayılan alıcı
    
    DECLARE @Konu NVARCHAR(500);
    DECLARE @Mesaj NVARCHAR(MAX);
    DECLARE @HTMLBody NVARCHAR(MAX);
    DECLARE @ToplamPersonel INT;
    DECLARE @GelenPersonel INT;
    DECLARE @GelmeyenPersonel INT;
    
    -- Rapor verilerini al
    SELECT 
        @ToplamPersonel = COUNT(DISTINCT p.SicilID),
        @GelenPersonel = COUNT(DISTINCT CASE 
            WHEN p.TerminalYonu LIKE '%GİRİŞ%' OR p.TerminalYonu LIKE '%GIRIS%' 
            THEN p.SicilID 
        END),
        @GelmeyenPersonel = COUNT(DISTINCT p.SicilID) - COUNT(DISTINCT CASE 
            WHEN p.TerminalYonu LIKE '%GİRİŞ%' OR p.TerminalYonu LIKE '%GIRIS%' 
            THEN p.SicilID 
        END)
    FROM dbo.PDKS_HAMDATA_CACHE p
    WHERE CAST(p.EventTime AS DATE) = @Tarih
        AND p.Deleted = 0;
    
    -- Eğer bugün için veri yoksa
    IF @ToplamPersonel = 0
    BEGIN
        SET @Konu = N'PDKS Günlük Yoklama Raporu - ' + FORMAT(@Tarih, 'dd.MM.yyyy') + N' (Veri Yok)';
        SET @Mesaj = N'Merhaba,' + CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10) +
                     N'Tarih: ' + FORMAT(@Tarih, 'dd.MM.yyyy') + CHAR(13) + CHAR(10) +
                     N'Bu tarih için PDKS verisi bulunmamaktadır.';
        
        IF @TestModu = 0
        BEGIN
            EXEC msdb.dbo.sp_send_dbmail
                @profile_name = 'PDKS_Mail_Profile',
                @recipients = @AliciMail,
                @subject = @Konu,
                @body = @Mesaj,
                @body_format = 'TEXT';
        END
        
        RETURN;
    END
    
    -- HTML formatında rapor oluştur
    SET @HTMLBody = N'
    <html>
    <head>
        <style>
            body { font-family: Arial, sans-serif; }
            table { border-collapse: collapse; width: 100%; margin-top: 20px; }
            th { background-color: #4CAF50; color: white; padding: 12px; text-align: left; }
            td { border: 1px solid #ddd; padding: 8px; }
            tr:nth-child(even) { background-color: #f2f2f2; }
            .header { background-color: #2196F3; color: white; padding: 15px; }
            .summary { background-color: #FFC107; padding: 10px; margin: 10px 0; }
        </style>
    </head>
    <body>
        <div class="header">
            <h2>PDKS Günlük Yoklama Raporu</h2>
            <p>Tarih: ' + FORMAT(@Tarih, 'dd.MM.yyyy') + N'</p>
        </div>
        
        <div class="summary">
            <h3>Özet Bilgiler</h3>
            <p><strong>Toplam Personel:</strong> ' + CAST(@ToplamPersonel AS NVARCHAR(10)) + N'</p>
            <p><strong>Gelen Personel:</strong> ' + CAST(@GelenPersonel AS NVARCHAR(10)) + N'</p>
            <p><strong>Gelmeyen Personel:</strong> ' + CAST(@GelmeyenPersonel AS NVARCHAR(10)) + N'</p>
        </div>
        
        <h3>Personel Detay Listesi</h3>
        <table>
            <tr>
                <th>Sicil ID</th>
                <th>Ad Soyad</th>
                <th>Bölüm</th>
                <th>Giriş Saati</th>
                <th>Çıkış Saati</th>
                <th>Çalışma Süresi</th>
                <th>Durum</th>
            </tr>';
    
    -- Personel detaylarını HTML tablosuna ekle
    DECLARE @PersonelDetay NVARCHAR(MAX) = '';
    
    SELECT @PersonelDetay = @PersonelDetay + 
        N'<tr>' +
        N'<td>' + CAST(SicilID AS NVARCHAR(10)) + N'</td>' +
        N'<td>' + ISNULL(PersonelAdi, '') + N' ' + ISNULL(PersonelSoyadi, '') + N'</td>' +
        N'<td>' + ISNULL(CAST(Bolum AS NVARCHAR(10)), '') + N'</td>' +
        N'<td>' + ISNULL(CONVERT(NVARCHAR(5), GirisSaati, 108), '') + N'</td>' +
        N'<td>' + ISNULL(CONVERT(NVARCHAR(5), CikisSaati, 108), '') + N'</td>' +
        N'<td>' + ISNULL(CAST(CalismaSaat AS NVARCHAR(10)), '0') + N' saat</td>' +
        N'<td>' + CASE WHEN GirisSaati IS NOT NULL THEN 'Geldi' ELSE 'Gelmedi' END + N'</td>' +
        N'</tr>'
    FROM (
        SELECT 
            p.SicilID,
            p.PersonelAdi,
            p.PersonelSoyadi,
            p.Bolum,
            MIN(CASE WHEN p.TerminalYonu LIKE '%GİRİŞ%' OR p.TerminalYonu LIKE '%GIRIS%' 
                THEN p.EventTime END) AS GirisSaati,
            MAX(CASE WHEN p.TerminalYonu LIKE '%ÇIKIŞ%' OR p.TerminalYonu LIKE '%CIKIS%' 
                THEN p.EventTime END) AS CikisSaati,
            CAST(DATEDIFF(MINUTE, 
                MIN(CASE WHEN p.TerminalYonu LIKE '%GİRİŞ%' OR p.TerminalYonu LIKE '%GIRIS%' 
                    THEN p.EventTime END),
                MAX(CASE WHEN p.TerminalYonu LIKE '%ÇIKIŞ%' OR p.TerminalYonu LIKE '%CIKIS%' 
                    THEN p.EventTime END)
            ) / 60.0 AS DECIMAL(10,2)) AS CalismaSaat
        FROM dbo.PDKS_HAMDATA_CACHE p
        WHERE CAST(p.EventTime AS DATE) = @Tarih
            AND p.Deleted = 0
        GROUP BY p.SicilID, p.PersonelAdi, p.PersonelSoyadi, p.Bolum
    ) AS PersonelListesi
    ORDER BY PersonelAdi, PersonelSoyadi;
    
    SET @HTMLBody = @HTMLBody + @PersonelDetay + N'
        </table>
        
        <p style="margin-top: 20px; color: #666; font-size: 12px;">
            Bu rapor otomatik olarak oluşturulmuştur.<br>
            Punteks PDKS Sistemi
        </p>
    </body>
    </html>';
    
    SET @Konu = N'PDKS Günlük Yoklama Raporu - ' + FORMAT(@Tarih, 'dd.MM.yyyy');
    
    -- Test modunda sadece mesajı göster
    IF @TestModu = 1
    BEGIN
        PRINT 'TEST MODU - Mail gönderilmeyecek';
        PRINT 'Konu: ' + @Konu;
        PRINT 'Alıcı: ' + @AliciMail;
        PRINT 'Toplam Personel: ' + CAST(@ToplamPersonel AS NVARCHAR(10));
        PRINT 'Gelen Personel: ' + CAST(@GelenPersonel AS NVARCHAR(10));
        RETURN;
    END
    
    -- Mail gönder
    BEGIN TRY
        EXEC msdb.dbo.sp_send_dbmail
            @profile_name = 'PDKS_Mail_Profile',
            @recipients = @AliciMail,
            @subject = @Konu,
            @body = @HTMLBody,
            @body_format = 'HTML';
        
        PRINT 'Mail başarıyla gönderildi: ' + @AliciMail;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT 'Mail gönderilirken hata oluştu: ' + @ErrorMessage;
        THROW;
    END CATCH
END;
GO

-- ============================================================
-- 3. KULLANIM ÖRNEKLERİ
-- ============================================================

-- Bugünün yoklama raporunu gönder
-- EXEC dbo.sp_PDKS_GunlukYoklamaMailGonder;

-- Belirli bir tarihin yoklama raporunu gönder
-- EXEC dbo.sp_PDKS_GunlukYoklamaMailGonder 
--     @Tarih = '2025-11-28',
--     @AliciMail = 'mozan73@gmail.com';

-- Test modunda çalıştır (mail göndermez, sadece konsola yazar)
-- EXEC dbo.sp_PDKS_GunlukYoklamaMailGonder 
--     @Tarih = '2025-11-28',
--     @AliciMail = 'mozan73@gmail.com',
--     @TestModu = 1;

-- ============================================================
-- 4. SQL AGENT JOB İLE OTOMATİK ÇALIŞTIRMA
-- ============================================================
-- Aşağıdaki script SQL Server Agent Job oluşturur
-- Her gün saat 18:00'de otomatik olarak çalışır

/*
USE msdb;
GO

-- Job oluştur
EXEC dbo.sp_add_job
    @job_name = N'PDKS_GunlukYoklamaMailGonder',
    @description = N'PDKS Günlük Yoklama Raporu Otomatik Mail Gönderimi',
    @category_name = N'Database Mail';

-- Job step ekle
EXEC dbo.sp_add_jobstep
    @job_name = N'PDKS_GunlukYoklamaMailGonder',
    @step_name = N'Yoklama Raporu Mail Gönder',
    @subsystem = N'TSQL',
    @database_name = N'PUNTEKS_2025',
    @command = N'EXEC dbo.sp_PDKS_GunlukYoklamaMailGonder;',
    @retry_attempts = 3,
    @retry_interval = 5;

-- Job schedule ekle (Her gün saat 18:00)
EXEC dbo.sp_add_schedule
    @schedule_name = N'PDKS_GunlukYoklama_Schedule',
    @freq_type = 4,  -- Daily
    @freq_interval = 1,  -- Her gün
    @active_start_time = 180000;  -- 18:00:00

-- Job ve Schedule'ı bağla
EXEC dbo.sp_attach_schedule
    @job_name = N'PDKS_GunlukYoklamaMailGonder',
    @schedule_name = N'PDKS_GunlukYoklama_Schedule';

-- Job'a server ekle
EXEC dbo.sp_add_jobserver
    @job_name = N'PDKS_GunlukYoklamaMailGonder',
    @server_name = N'(local)';

-- Job'ı etkinleştir
EXEC dbo.sp_update_job
    @job_name = N'PDKS_GunlukYoklamaMailGonder',
    @enabled = 1;
GO
*/

-- ============================================================
-- 5. MAIL GÖNDERİM DURUMU KONTROLÜ
-- ============================================================

-- Son gönderilen mailleri görüntüle
-- SELECT TOP 10 
--     mailitem_id,
--     recipients,
--     subject,
--     sent_date,
--     sent_status
-- FROM msdb.dbo.sysmail_mailitems
-- WHERE subject LIKE '%PDKS%'
-- ORDER BY sent_date DESC;

-- Mail gönderim hatalarını görüntüle
-- SELECT TOP 10 
--     mailitem_id,
--     recipients,
--     subject,
--     sent_date,
--     sent_status,
--     error_description
-- FROM msdb.dbo.sysmail_mailitems
-- WHERE sent_status = 'failed'
--     AND subject LIKE '%PDKS%'
-- ORDER BY sent_date DESC;

GO

