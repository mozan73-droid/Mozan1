# Faz 1 — VY özellik seçim UI (STOK40)

Import edilebilir Dinamo paketi. **Ana dosya:** `STOK40.xml` (tam form; EFRM10 özelleştirmesi).

## Ne eklendi (Faz 1)

1. FO butonu (`BT1FO` / `DO_SENT_FOCODE_0`) yanına **VY** butonu (Detay 1 + TL Karşılığı / ilgili detay sekmeleri)
2. FOEDIT sağ tık menüsüne **VY Ozellik Secimi**
3. Alt form `FRM_VYSECIM` — STACK grid (`VYSECIM_STACK`: Özellik + Seç E/H)
4. Makrolar (`EFRM10.THISFORM`):
   - `cmd_VySecim` — satır `KOD` → `STOK00.GK_18` kontrolü; yalnız `VY_SECIMI` ise form açılır
   - `VySecim_StackSeed` — 9 özellik satırı (varsayılan Seç=H)
   - `cmd_VySecimOK` — seçilenleri GrupXX map edip **MsgBox** (smoke); **SCFOEN / FOKOD yazılmaz**

## Davranış

| Adım | Sonuç |
| --- | --- |
| VY tıkla, GK_18 ≠ VY_SECIMI | Uyarı, form açılmaz |
| VY tıkla, GK_18 = VY_SECIMI | STACK seçim ekranı |
| Seç = E, Tamam | MsgBox: Grup01…05 listesi; TBD özellikler ayrı satır |
| İptal | Kapanır, yazma yok |

Map: EFO→Grup01, SOGUTUCU→Grup02, HPU→Grup03, PANO→Grup04, IP 67→Grup05; DC MOTOR / SDO / 220 Volt / Oto Inis → TBD.

## Dinamo’ya import (kısa)

1. Dinamo’da **EFRM10 / Form özelleştirme** (veya kullandığınız STOK40 form import yolu) açın.
2. Bu klasördeki **`STOK40.xml`** dosyasını import edin / mevcut STOK40 özelleştirmesinin üzerine alın (önce yedek alın).
3. Formu kaydedip satış siparişi (`STOK40`) ekranını yeniden açın.
4. `GK_18=VY_SECIMI` bir stok satırında FOKOD yanındaki **VY** butonuna basın; özellik seçip **Tamam** → MsgBox smoke doğrulayın.

Notlar:

- `FRM_VYSECIM` **STOK40.xml içinde gömülü** (tıpkı `FRM_ONAYDETAY` gibi); ayrı form kaydı gerekmez.
- `FORM_VYSECIM.xml` ve `makro-vy-secim.txt` referans/kopya; canlı kaynak `STOK40.xml`.
- STACK: `CreateTableObject("VYSECIM_STACK=STACK")` — ZU_XXX / CreateTransactionalTableObject / SetMustEnter / SafePack yok.
- Faz 2: OK sonrası SCFOEN satırları + FO / FOKOD.

## Dosyalar

| Dosya | Açıklama |
| --- | --- |
| `STOK40.xml` | Import edilecek tam form |
| `FORM_VYSECIM.xml` | Alt form metin kopyası |
| `makro-vy-secim.txt` | Faz 1 makro metin kopyası |
| `patch-fo-yani-vy-buton.xml` | FO yanı buton snippet |

## Çift konum (aynı içerik)

- Context: `/cursor/stores/self/docs/faz1-secim-ui/`
- Workspace: `/workspace/OZAK/STOK40_FO_KOD_GRUP_SECIMI/`
