# Dinamo & Freedom ERP — Kod Kalıpları (OneNote Referans)

Bu klasör, **Dinamo ERP** ve **Freedom ERP** makro çalışmalarında en sık kullanılan kod kalıplarının OneNote’a aktarılabilir referans kaynağıdır.

## OneNote defter yapısı (önerilen)

| Bölüm | Sayfa dosyası |
| --- | --- |
| 00 · Nasıl kullanılır | bu dosya |
| 01 · Genel kurallar | `sayfalar/01_Genel_Kurallar.md` |
| 02 · Tablo nesneleri (NOFILE / STACK) | `sayfalar/02_Tablo_Nesneleri.md` |
| 03 · Grid doldurma | `sayfalar/03_Grid_Doldurma.md` |
| 04 · Satır değişimi (Freedom vs Dinamo) | `sayfalar/04_Satir_Degisimi.md` |
| 05 · Frame_Refresh & SafePack | `sayfalar/05_Frame_Refresh_SafePack.md` |
| 06 · SQL kalıpları | `sayfalar/06_SQL_Kaliplari.md` |
| 07 · XML / form import | `sayfalar/07_XML_Form_Import.md` |
| 08 · Hata yönetimi | `sayfalar/08_Hata_Yonetimi.md` |
| 09 · Doc metodları (cheat sheet) | `sayfalar/09_Doc_Metodlari.md` |
| 10 · Dinamo vs Freedom farkları | `sayfalar/10_Dinamo_vs_Freedom.md` |
| 11 · Repo örnekleri | `sayfalar/11_Repo_Ornekleri.md` |

Tek dosya HTML (kopyala-yapıştır için): `ONENOTE_NOTEBOOK.html`

## OneNote’a aktarma

**Yerel Windows OneNote (otomatik):** `YEREL_ONENOTE_AKTAR.md` → `OneNote-Aktar.cmd` veya `Import-To-Local-OneNote.ps1`

### A) HTML’den kopyala-yapıştır

1. `ONENOTE_NOTEBOOK.html` dosyasını tarayıcıda açın.
2. OneNote’ta yeni bir defter oluşturun: **Dinamo Freedom Kod Kaliplari**.
3. Her `<h1>` başlığını ayrı sayfa yapın; bölüm içeriğini kopyalayıp yapıştırın.
4. Kod blokları OneNote’ta monospace kalır (gerekirse “Code” biçimi uygulayın).

### B) Sayfa sayfa Markdown

1. `sayfalar/` altındaki her `.md` dosyasını açın.
2. İçeriği OneNote sayfasına yapıştırın (OneNote Markdown’ı kısmen taşır; başlık + kod için HTML yolu daha temizdir).

### C) Word aracılığıyla

1. Hazır dosya: `Dinamo_Freedom_Kod_Kaliplari.docx`
2. Word’de açın → **Dosya → Gönder / Paylaş → OneNote**.

## Kaynak önceliği

1. Bu referans + proje kuralları (`.cursor/rules/dinamo-erp-kod-ara.mdc`)
2. Makro örnek klasörü: **`KOD_ARA_KLASORU/`** (lokal `C:\KOD_ARA_KLASÖRÜ`) — Dinamo/ERP aramalarda zorunlu ilk kaynak
3. Repo örnekleri: `OZAK/`, `PDKS/`

## Önemli yasaklar (özet)

- **Goto / GoTo / On Error Goto** yok
- Makro SQL’de **WITH (CTE)** yok
- Oracle’a doğrudan bağlanma / yazma yok (yalnızca makro XML içinde SELECT / RunSqlQuery)
- Freedom’da **Frame_Refresh_Controls** yok
- Freedom’da **Setd7RowsetEventReplace "AFTERROWCHANGE"** yok
