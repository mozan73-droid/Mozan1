PDKS Günlük Yoklama Mail Servisi - Kullanım Kılavuzu
=====================================================
Tarih: 2025-11-28
Versiyon: 1.0

GENEL BİLGİLER:
---------------
Bu sistem, SQL Server üzerinden günlük yoklama raporunu otomatik olarak 
e-posta ile gönderen bir servistir.

DOSYALAR:
---------
1. PDKS_Gunluk_Yoklama_Mail_Servisi.sql
   - Ana stored procedure ve yapılandırma scriptleri
   - Database Mail kurulumu
   - SQL Agent Job oluşturma

2. PDKS_Puantaj_Personel_Toplam.sql
   - Personel puantaj sorguları
   - Günlük ve aylık raporlar

KURULUM ADIMLARI:
----------------

1. DATABASE MAIL YAPILANDIRMASI
   -----------------------------
   - SQL Server Management Studio'yu açın
   - Management > Database Mail > Configure Database Mail
   - Veya script içindeki Database Mail yapılandırma bölümünü çalıştırın
   
   Gerekli Bilgiler:
   - SMTP Sunucu: smtp.gmail.com (veya kendi SMTP sunucunuz)
   - Port: 587 (veya 465 SSL için)
   - Kullanıcı Adı: E-posta adresiniz
   - Şifre: E-posta şifreniz veya uygulama şifresi
   - SSL: Etkin

2. STORED PROCEDURE KURULUMU
   ---------------------------
   - PDKS_Gunluk_Yoklama_Mail_Servisi.sql dosyasını açın
   - Stored procedure bölümünü (Bölüm 2) çalıştırın
   - sp_PDKS_GunlukYoklamaMailGonder oluşturulacak

3. TEST ÇALIŞTIRMA
   ----------------
   -- Test modunda çalıştır (mail göndermez)
   EXEC dbo.sp_PDKS_GunlukYoklamaMailGonder 
       @Tarih = '2025-11-28',
       @AliciMail = 'mozan73@gmail.com',
       @TestModu = 1;

4. MANUEL MAIL GÖNDERME
   ---------------------
   -- Bugünün raporunu gönder
   EXEC dbo.sp_PDKS_GunlukYoklamaMailGonder;
   
   -- Belirli bir tarihin raporunu gönder
   EXEC dbo.sp_PDKS_GunlukYoklamaMailGonder 
       @Tarih = '2025-11-28',
       @AliciMail = 'mozan73@gmail.com';

5. OTOMATİK ÇALIŞTIRMA (SQL AGENT JOB)
   ------------------------------------
   - SQL Server Agent'in çalıştığından emin olun
   - Script içindeki SQL Agent Job bölümünü (Bölüm 4) çalıştırın
   - Job her gün saat 18:00'de otomatik çalışacak
   - Job adı: PDKS_GunlukYoklamaMailGonder

PARAMETRELER:
------------
@Tarih DATE = NULL
    - Rapor tarihi (NULL ise bugün kullanılır)
    - Format: 'YYYY-MM-DD' veya 'YYYYMMDD'

@AliciMail NVARCHAR(MAX) = NULL
    - Mail gönderilecek e-posta adresi
    - NULL ise varsayılan: 'mozan73@gmail.com'
    - Birden fazla adres için virgülle ayırın: 'mail1@test.com,mail2@test.com'

@TestModu BIT = 0
    - 1: Test modu (mail göndermez, sadece konsola yazar)
    - 0: Normal mod (mail gönderir)

RAPOR İÇERİĞİ:
--------------
- Özet Bilgiler:
  * Toplam Personel Sayısı
  * Gelen Personel Sayısı
  * Gelmeyen Personel Sayısı

- Personel Detay Listesi:
  * Sicil ID
  * Ad Soyad
  * Bölüm
  * Giriş Saati
  * Çıkış Saati
  * Çalışma Süresi (saat)
  * Durum (Geldi/Gelmedi)

SORUN GİDERME:
--------------

1. Mail Gönderilmiyor
   - Database Mail'in yapılandırıldığından emin olun
   - SMTP ayarlarını kontrol edin
   - SQL Server Agent'in çalıştığını kontrol edin
   - Mail gönderim loglarını kontrol edin:
     SELECT * FROM msdb.dbo.sysmail_mailitems 
     WHERE subject LIKE '%PDKS%' 
     ORDER BY sent_date DESC;

2. Hata Mesajları
   - Mail gönderim hatalarını görüntüle:
     SELECT * FROM msdb.dbo.sysmail_mailitems 
     WHERE sent_status = 'failed' 
     AND subject LIKE '%PDKS%';

3. Veri Bulunamıyor
   - PDKS_HAMDATA_CACHE tablosunda veri olduğundan emin olun
   - Tarih formatını kontrol edin
   - Deleted = 0 olan kayıtların olduğunu kontrol edin

GÜNCELLEMELER:
-------------
- 2025-11-28: İlk versiyon oluşturuldu
  * Stored procedure eklendi
  * HTML formatında rapor eklendi
  * SQL Agent Job scripti eklendi

İLETİŞİM:
---------
Sorularınız için: mozan73@gmail.com

NOTLAR:
-------
- Mail gönderimi için SQL Server Database Mail özelliği gereklidir
- Gmail kullanıyorsanız "Uygulama Şifresi" kullanmanız gerekebilir
- SMTP port ayarlarını firewall'dan geçirmeniz gerekebilir
- Büyük personel listeleri için mail boyutu sınırlarını kontrol edin

