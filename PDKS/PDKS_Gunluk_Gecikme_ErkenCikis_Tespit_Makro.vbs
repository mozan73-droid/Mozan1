' ============================================================
' PDKS Günlük Gecikme - Erken Çıkış Tespit Makrosu
' ============================================================
' Dinamo ERP VBScript Makrosu
' Tarih: 2025-11-28
' Açıklama: Gecikme ve erken çıkış tespiti yapar
'           Gece vardiyası (ertesi gün 06:00'dan önce çıkış) desteği var
' ============================================================

Sub cmd_Gunluk_Gecikme_ErkenCikis_Tespit
    Call Gunluk_Gecikme_ErkenCikis_Tespit("cmd_Gunluk_Gecikme_ErkenCikis_Tespit")
End Sub

'------------------------------------------------

Sub Gunluk_Gecikme_ErkenCikis_Tespit(Nereden)

	Set KRT = Doc.GetTableObject("KRITERLER")

	' Hedef saatler varsayılan değerler
	If Trim(KRT.HEDEFGIRISSAAT) = "" Then
		KRT.HEDEFGIRISSAAT = "07:00" 
	End If

	If Trim(KRT.HEDEFCIKISSAAT) = "" Then
		KRT.HEDEFCIKISSAAT = "18:00"
	End If

	' Tarih aralığı varsayılan değerler
	If Trim(KRT.KRTTARIH1) = "" Then
		KRT.KRTTARIH1 = Doc.Bugun
	End If

	If Trim(KRT.KRTTARIH2) = "" Then
		KRT.KRTTARIH2 = Doc.Bugun
	End If

	HedefGirisSaati = Trim(KRT.HEDEFGIRISSAAT)
	HedefCikisSaati = Trim(KRT.HEDEFCIKISSAAT)

	' SQL sorgusu oluştur
	sql = ""
	sql = sql & "SELECT " & vbCrLf
	sql = sql & "    g.Gun," & vbCrLf
	sql = sql & "    g.SicilID," & vbCrLf
	sql = sql & "    MAX(g.PersonelAdi) AS PersonelAdi," & vbCrLf
	sql = sql & "    MAX(g.PersonelSoyadi) AS PersonelSoyadi," & vbCrLf
	sql = sql & "    MAX(g.Gun_Adi) AS Gun_Adi," & vbCrLf
	sql = sql & "    MIN(CASE WHEN g.rn = 1 THEN g.EventTimeDt END) AS IlkGirisTS," & vbCrLf
	sql = sql & "    MAX(CASE WHEN c.rn = 1 THEN c.EventTimeDt END) AS SonCikisTS," & vbCrLf
	sql = sql & "    CAST(LEFT(CONVERT(char(8), MIN(CASE WHEN g.rn = 1 THEN g.EventTimeDt END), 108), 5) AS varchar(5)) AS IlkGiris," & vbCrLf
	sql = sql & "    CAST(LEFT(CONVERT(char(8), MAX(CASE WHEN c.rn = 1 THEN c.EventTimeDt END), 108), 5) AS varchar(5)) AS SonCikis," & vbCrLf
	sql = sql & "    CASE " & vbCrLf
	sql = sql & "        WHEN MIN(CASE WHEN g.rn = 1 THEN g.EventTimeDt END) > " & vbCrLf
	sql = sql & "             CAST(CONVERT(varchar(10), g.Gun, 120) + ' " & HedefGirisSaati & ":00' AS datetime) " & vbCrLf
	sql = sql & "        THEN 'VAR' ELSE 'YOK' " & vbCrLf
	sql = sql & "    END AS GecikmeDurumu," & vbCrLf
	sql = sql & "    CASE " & vbCrLf
	sql = sql & "        WHEN MIN(CASE WHEN g.rn = 1 THEN g.EventTimeDt END) > " & vbCrLf
	sql = sql & "             CAST(CONVERT(varchar(10), g.Gun, 120) + ' " & HedefGirisSaati & ":00' AS datetime) " & vbCrLf
	sql = sql & "        THEN DATEDIFF(minute, " & vbCrLf
	sql = sql & "             CAST(CONVERT(varchar(10), g.Gun, 120) + ' " & HedefGirisSaati & ":00' AS datetime), " & vbCrLf
	sql = sql & "             MIN(CASE WHEN g.rn = 1 THEN g.EventTimeDt END)) " & vbCrLf
	sql = sql & "        ELSE 0 " & vbCrLf
	sql = sql & "    END AS GecikmeDakika," & vbCrLf
	sql = sql & "    CASE " & vbCrLf
	sql = sql & "        WHEN MAX(CASE WHEN c.rn = 1 THEN c.Gun_Cikis END) > g.Gun " & vbCrLf
	sql = sql & "             AND CONVERT(time, MAX(CASE WHEN c.rn = 1 THEN c.EventTimeDt END)) < '06:00' THEN " & vbCrLf
	sql = sql & "            CASE " & vbCrLf
	sql = sql & "                WHEN DATEADD(DAY, 1, CAST(CONVERT(varchar(10), g.Gun, 120) + ' ' + CONVERT(varchar(5), MAX(CASE WHEN c.rn = 1 THEN c.EventTimeDt END), 108) AS datetime)) < " & vbCrLf
	sql = sql & "                     CAST(CONVERT(varchar(10), g.Gun, 120) + ' " & HedefCikisSaati & ":00' AS datetime) " & vbCrLf
	sql = sql & "                THEN 'VAR' ELSE 'YOK' " & vbCrLf
	sql = sql & "            END " & vbCrLf
	sql = sql & "        ELSE " & vbCrLf
	sql = sql & "            CASE " & vbCrLf
	sql = sql & "                WHEN CAST(CONVERT(varchar(10), g.Gun, 120) + ' ' + CONVERT(varchar(5), MAX(CASE WHEN c.rn = 1 THEN c.EventTimeDt END), 108) AS datetime) < " & vbCrLf
	sql = sql & "                     CAST(CONVERT(varchar(10), g.Gun, 120) + ' " & HedefCikisSaati & ":00' AS datetime) " & vbCrLf
	sql = sql & "                THEN 'VAR' ELSE 'YOK' " & vbCrLf
	sql = sql & "            END " & vbCrLf
	sql = sql & "    END AS ErkenCikisDurumu," & vbCrLf
	sql = sql & "    CASE " & vbCrLf
	sql = sql & "        WHEN MAX(CASE WHEN c.rn = 1 THEN c.Gun_Cikis END) > g.Gun " & vbCrLf
	sql = sql & "             AND CONVERT(time, MAX(CASE WHEN c.rn = 1 THEN c.EventTimeDt END)) < '06:00' THEN " & vbCrLf
	sql = sql & "            CASE " & vbCrLf
	sql = sql & "                WHEN DATEADD(DAY, 1, CAST(CONVERT(varchar(10), g.Gun, 120) + ' ' + CONVERT(varchar(5), MAX(CASE WHEN c.rn = 1 THEN c.EventTimeDt END), 108) AS datetime)) < " & vbCrLf
	sql = sql & "                     CAST(CONVERT(varchar(10), g.Gun, 120) + ' " & HedefCikisSaati & ":00' AS datetime) " & vbCrLf
	sql = sql & "                THEN DATEDIFF(minute, " & vbCrLf
	sql = sql & "                     DATEADD(DAY, 1, CAST(CONVERT(varchar(10), g.Gun, 120) + ' ' + CONVERT(varchar(5), MAX(CASE WHEN c.rn = 1 THEN c.EventTimeDt END), 108) AS datetime)), " & vbCrLf
	sql = sql & "                     CAST(CONVERT(varchar(10), g.Gun, 120) + ' " & HedefCikisSaati & ":00' AS datetime)) " & vbCrLf
	sql = sql & "                ELSE 0 " & vbCrLf
	sql = sql & "            END " & vbCrLf
	sql = sql & "        ELSE " & vbCrLf
	sql = sql & "            CASE " & vbCrLf
	sql = sql & "                WHEN CAST(CONVERT(varchar(10), g.Gun, 120) + ' ' + CONVERT(varchar(5), MAX(CASE WHEN c.rn = 1 THEN c.EventTimeDt END), 108) AS datetime) < " & vbCrLf
	sql = sql & "                     CAST(CONVERT(varchar(10), g.Gun, 120) + ' " & HedefCikisSaati & ":00' AS datetime) " & vbCrLf
	sql = sql & "                THEN DATEDIFF(minute, " & vbCrLf
	sql = sql & "                     CAST(CONVERT(varchar(10), g.Gun, 120) + ' ' + CONVERT(varchar(5), MAX(CASE WHEN c.rn = 1 THEN c.EventTimeDt END), 108) AS datetime), " & vbCrLf
	sql = sql & "                     CAST(CONVERT(varchar(10), g.Gun, 120) + ' " & HedefCikisSaati & ":00' AS datetime)) " & vbCrLf
	sql = sql & "                ELSE 0 " & vbCrLf
	sql = sql & "            END " & vbCrLf
	sql = sql & "    END AS ErkenCikisDakika " & vbCrLf
	sql = sql & "FROM (" & vbCrLf
	sql = sql & "    SELECT " & vbCrLf
	sql = sql & "        p.SicilID," & vbCrLf
	sql = sql & "        MAX(p.PersonelAdi) AS PersonelAdi," & vbCrLf
	sql = sql & "        MAX(p.PersonelSoyadi) AS PersonelSoyadi," & vbCrLf
	sql = sql & "        CAST(p.EventTimeDt AS date) AS Gun," & vbCrLf
	sql = sql & "        CASE DATEPART(WEEKDAY, CAST(p.EventTimeDt AS date)) " & vbCrLf
	sql = sql & "            WHEN 1 THEN 'Pazar' " & vbCrLf
	sql = sql & "            WHEN 2 THEN 'Pazartesi' " & vbCrLf
	sql = sql & "            WHEN 3 THEN 'Salı' " & vbCrLf
	sql = sql & "            WHEN 4 THEN 'Çarşamba' " & vbCrLf
	sql = sql & "            WHEN 5 THEN 'Perşembe' " & vbCrLf
	sql = sql & "            WHEN 6 THEN 'Cuma' " & vbCrLf
	sql = sql & "            WHEN 7 THEN 'Cumartesi' " & vbCrLf
	sql = sql & "        END AS Gun_Adi," & vbCrLf
	sql = sql & "        p.EventTimeDt," & vbCrLf
	sql = sql & "        ROW_NUMBER() OVER (PARTITION BY p.SicilID, CAST(p.EventTimeDt AS date) ORDER BY p.EventTimeDt) AS rn " & vbCrLf
	sql = sql & "    FROM dbo.PDKS_HAMDATA_CACHE p WITH (NOLOCK) " & vbCrLf
	sql = sql & "    WHERE p.TerminalID = '1093' " & vbCrLf

	' Tarih filtreleri
	If Trim(KRT.KRTTARIH1) <> "" Then 
		sql = sql & "      AND CAST(p.EventTimeDt AS date) >= '" & KRT.KRTTARIH1 & "' " & vbCrLf
	End If

	If Trim(KRT.KRTTARIH2) <> "" Then 
		sql = sql & "      AND CAST(p.EventTimeDt AS date) <= '" & KRT.KRTTARIH2 & "' " & vbCrLf
	End If

	If Trim(KRT.AY) <> "" Then 
		sql = sql & "      AND p.Ay = '" & Trim(KRT.AY) & "' " & vbCrLf
	End If

	If Trim(KRT.SicilID) <> "" Then 
		sql = sql & "      AND LTRIM(RTRIM(CAST(p.SicilID AS varchar))) = '" & Trim(KRT.SicilID) & "' " & vbCrLf
	End If

	sql = sql & "    GROUP BY p.SicilID, CAST(p.EventTimeDt AS date), p.EventTimeDt " & vbCrLf
	sql = sql & ") g " & vbCrLf
	sql = sql & "LEFT JOIN (" & vbCrLf
	sql = sql & "    SELECT " & vbCrLf
	sql = sql & "        p.SicilID," & vbCrLf
	sql = sql & "        CAST(p.EventTimeDt AS date) AS Gun_Cikis," & vbCrLf
	sql = sql & "        p.EventTimeDt," & vbCrLf
	sql = sql & "        ROW_NUMBER() OVER (PARTITION BY p.SicilID, CAST(p.EventTimeDt AS date) ORDER BY p.EventTimeDt DESC) AS rn " & vbCrLf
	sql = sql & "    FROM dbo.PDKS_HAMDATA_CACHE p WITH (NOLOCK) " & vbCrLf
	sql = sql & "    WHERE p.TerminalID = '1094' " & vbCrLf

	' Çıkış için tarih filtreleri (ertesi günü de kapsamak için genişletilmiş)
	If Trim(KRT.KRTTARIH1) <> "" Then 
		sql = sql & "      AND CAST(p.EventTimeDt AS date) >= DATEADD(DAY, -1, '" & KRT.KRTTARIH1 & "') " & vbCrLf
	End If

	If Trim(KRT.KRTTARIH2) <> "" Then 
		sql = sql & "      AND CAST(p.EventTimeDt AS date) <= DATEADD(DAY, 1, '" & KRT.KRTTARIH2 & "') " & vbCrLf
	End If

	If Trim(KRT.AY) <> "" Then 
		sql = sql & "      AND p.Ay = '" & Trim(KRT.AY) & "' " & vbCrLf
	End If

	If Trim(KRT.SicilID) <> "" Then 
		sql = sql & "      AND LTRIM(RTRIM(CAST(p.SicilID AS varchar))) = '" & Trim(KRT.SicilID) & "' " & vbCrLf
	End If

	sql = sql & "    GROUP BY p.SicilID, CAST(p.EventTimeDt AS date), p.EventTimeDt " & vbCrLf
	sql = sql & ") c ON g.SicilID = c.SicilID " & vbCrLf
	sql = sql & "   AND (" & vbCrLf
	sql = sql & "       -- Aynı gün çıkış " & vbCrLf
	sql = sql & "       g.Gun = c.Gun_Cikis " & vbCrLf
	sql = sql & "       OR " & vbCrLf
	sql = sql & "       -- Ertesi gün 06:00'dan önce çıkış (gece vardiyası) - giriş gününe bağla " & vbCrLf
	sql = sql & "       (c.Gun_Cikis = DATEADD(DAY, 1, g.Gun) AND CONVERT(time, c.EventTimeDt) < '06:00') " & vbCrLf
	sql = sql & "   ) " & vbCrLf
	sql = sql & "WHERE g.EventTimeDt IS NOT NULL AND c.EventTimeDt IS NOT NULL " & vbCrLf
	sql = sql & "GROUP BY g.Gun, g.SicilID " & vbCrLf
	sql = sql & "HAVING (MIN(CASE WHEN g.rn = 1 THEN g.EventTimeDt END) > CAST(CONVERT(varchar(10), g.Gun, 120) + ' " & HedefGirisSaati & ":00' AS datetime)) " & vbCrLf
	sql = sql & "    OR (" & vbCrLf
	sql = sql & "        (MAX(CASE WHEN c.rn = 1 THEN c.Gun_Cikis END) > g.Gun " & vbCrLf
	sql = sql & "         AND CONVERT(time, MAX(CASE WHEN c.rn = 1 THEN c.EventTimeDt END)) < '06:00' " & vbCrLf
	sql = sql & "         AND DATEADD(DAY, 1, CAST(CONVERT(varchar(10), g.Gun, 120) + ' ' + CONVERT(varchar(5), MAX(CASE WHEN c.rn = 1 THEN c.EventTimeDt END), 108) AS datetime)) < " & vbCrLf
	sql = sql & "             CAST(CONVERT(varchar(10), g.Gun, 120) + ' " & HedefCikisSaati & ":00' AS datetime)) " & vbCrLf
	sql = sql & "        OR " & vbCrLf
	sql = sql & "        (MAX(CASE WHEN c.rn = 1 THEN c.Gun_Cikis END) = g.Gun " & vbCrLf
	sql = sql & "         AND CAST(CONVERT(varchar(10), g.Gun, 120) + ' ' + CONVERT(varchar(5), MAX(CASE WHEN c.rn = 1 THEN c.EventTimeDt END), 108) AS datetime) < " & vbCrLf
	sql = sql & "             CAST(CONVERT(varchar(10), g.Gun, 120) + ' " & HedefCikisSaati & ":00' AS datetime)) " & vbCrLf
	sql = sql & "    ) " & vbCrLf
	sql = sql & "ORDER BY g.Gun DESC, MAX(g.PersonelAdi), MAX(g.PersonelSoyadi); " & vbCrLf

	' Makro1 modunda sadece tablo yapısını oluştur
	If Nereden = "Makro1" Then 
		Set GECERKENTESPIT_SQL = Doc.RunSQLQuery("GECERKENTESPIT_SQL", sql)
		Exit Sub
	End If

	' Normal modda veri çek
	Set GECERKENTESPIT_SQLDOLU = Doc.RunSQLQuery("GECERKENTESPIT_SQL_DOLU", sql)
	Set GECERKENTESPIT_SQL = Doc.GetTableObject("GECERKENTESPIT_SQL")
	GECERKENTESPIT_SQL.Empty

	If GECERKENTESPIT_SQLDOLU.GetRecCount = 0 Then
		Msgbox "Kayıt Bulunamadı...(msg:858)"
		Exit Sub
	End If

	GECERKENTESPIT_SQL.CopyTable(GECERKENTESPIT_SQLDOLU)
	Set GECERKENTESPIT_SQLDOLU = Nothing 

	GECERKENTESPIT_SQL.SetCurrentRow 1	
	Call SonGuncellemeZamani("Gunluk_Gecikme_ErkenCikis_Tespit")	

End Sub

'-------------------------------------------------------

