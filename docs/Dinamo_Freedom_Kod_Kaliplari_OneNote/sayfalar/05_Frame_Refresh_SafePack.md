# 05 · Frame_Refresh_Controls & SafePack

## Frame_Refresh_Controls

`Doc.Frame_Refresh_Controls` **yalnızca Dinamo**’da vardır.

| Platform | Davranış |
| --- | --- |
| Dinamo | Grid doldurduktan sonra çağır |
| Freedom | **ÇAĞIRMA** |

Freedom’da çağırırsan:

`Nesne bu ozellik veya yontemi desteklemiyor: 'Doc.Frame_Refresh_Controls'` (`0x800A01B6`)

```vb
' Dinamo
TrnTable.CopyTable(TblDolu)
TrnTable.SetCurrentRow 1
TrnTable.Refresh
Doc.Frame_Refresh_Controls

' Freedom — sadece Refresh yeterli
TrnTable.CopyTable(TblDolu)
TrnTable.SetCurrentRow 1
TrnTable.Refresh
```

## SafePack

Zorunlu alan yoksa `SafePack` tabloyu **boşaltır**.

| Durum | SafePack |
| --- | --- |
| Zorunlu alan var (`SetMustEnter "ALAN", "E"`) | Kullan |
| Zorunlu alan yok | **Kullanma** |

`RunSqlQuery` ile açılan grid şemasında zorunlu alan varsayılan gelmez. SafePack kullanacaksan önce:

```vb
Tbl.SetMustEnter "ALAN", "E"
' ... sonra SafePack ...
```

## STACK seçim formları

Geçici STACK (ör. VYSECIM): genelde **SetMustEnter / SafePack yok**.

```vb
' CreateTableObject("VYSECIM_STACK=STACK")
' ZU_XXX / CreateTransactionalTableObject / SetMustEnter / SafePack yok
```
