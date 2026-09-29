# Yerel OneNote’a aktarma

Bu cloud agent sizin bilgisayarınızdaki OneNote’a **doğrudan yazamaz**. Aşağıdaki yöntemlerden birini lokal Windows’ta çalıştırın.

## Yöntem A — PowerShell (önerilen, otomatik)

**Gerekli:** OneNote masaüstü (2016 / Microsoft 365). UWP “OneNote for Windows 10” COM desteklemez.

1. Bu klasörü bilgisayarınıza alın (repo pull veya PR dosyaları).
2. OneNote’u bir kez açıp hesabınıza giriş yapın.
3. PowerShell’de:

```powershell
cd ...\docs\Dinamo_Freedom_Kod_Kaliplari_OneNote
powershell -ExecutionPolicy Bypass -File .\Import-To-Local-OneNote.ps1
```

Script şunu oluşturur:

- Defter: **Dinamo Freedom Kod Kaliplari**
- Bölüm: **Kod Kaliplari**
- Sayfalar: `00_README` + `sayfalar/*.md` (11 kalıp sayfası)

Varsayılan yol: `%USERPROFILE%\Documents\OneNote Notebooks\Dinamo Freedom Kod Kaliplari`

## Yöntem B — Word → OneNote

1. `Dinamo_Freedom_Kod_Kaliplari.docx` dosyasını Word’de açın.
2. **Dosya → Paylaş / Gönder → OneNote** (veya Yazdır → Send to OneNote).
3. Hedef defter/bölümü seçin.

## Yöntem C — HTML kopyala

1. `ONENOTE_NOTEBOOK.html` dosyasını tarayıcıda açın.
2. Her `h1` bölümünü OneNote’ta ayrı sayfaya yapıştırın.

## Sorun giderme

| Belirti | Çözüm |
| --- | --- |
| `OneNote COM baslatilamadi` | Masaüstü OneNote kurulu mu? UWP değil. |
| Defter görünmüyor | OneNote’ta Dosya → Aç → Notebooks klasörü |
| Sayfalar boş | Script’i tekrar çalıştırın; mevcut başlıklar atlanır |
| ExecutionPolicy | `-ExecutionPolicy Bypass` ile çalıştırın |
