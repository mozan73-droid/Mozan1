Sub Puantaj_Personel_Toplam(Nereden)
	Set KRT = Doc.GetTableObject("KRITERLER")
	' Normal mesai dakikasını HEDEFGIRISSAAT ve HEDEFCIKISSAAT'e göre hesapla
	NormalMesaiDakika = "450"  ' Varsayılan değer
	If Trim(KRT.HEDEFGIRISSAAT) <> "" And Trim(KRT.HEDEFCIKISSAAT) <> "" Then
		' Saat formatını parse et (HH:MM)
		HedefGiris = Trim(KRT.HEDEFGIRISSAAT)
		HedefCikis = Trim(KRT.HEDEFCIKISSAAT)
		' Saat ve dakikayı ayır
		If InStr(HedefGiris, ":") > 0 And InStr(HedefCikis, ":") > 0 Then
			GirisParcala = Split(HedefGiris, ":")
			CikisParcala = Split(HedefCikis, ":")
			If UBound(GirisParcala) >= 1 And UBound(CikisParcala) >= 1 Then
				GirisSaat = CInt(GirisParcala(0))
				GirisDakika = CInt(GirisParcala(1))
				CikisSaat = CInt(CikisParcala(0))
				CikisDakika = CInt(CikisParcala(1))
				' Toplam dakikaya çevir
				GirisToplamDakika = (GirisSaat * 60) + GirisDakika
				CikisToplamDakika = (CikisSaat * 60) + CikisDakika
				' Farkı hesapla
				If CikisToplamDakika > GirisToplamDakika Then
					NormalMesaiDakika = CStr(CikisToplamDakika - GirisToplamDakika)
				Else
					' Gece vardiyası durumu (ertesi güne geçiyor)
					NormalMesaiDakika = CStr((24 * 60) - GirisToplamDakika + CikisToplamDakika)
				End If
			End If
		End If
	End If
    sql = ""
    sql = sql & "SELECT " & vbCrLf
    sql = sql & "    p.TCKIMLIKNO AS SicilID," & vbCrLf
    sql = sql & "    MAX(per.AD) AS PersonelAdi," & vbCrLf
    sql = sql & "    MAX(per.SOYAD) AS PersonelSoyadi," & vbCrLf
    sql = sql & "    COUNT(DISTINCT g.Gun) AS ToplamCalismaGunu," & vbCrLf
    sql = sql & "    SUM(CASE " & vbCrLf
    sql = sql & "        WHEN g.IlkGiris IS NOT NULL AND c.SonCikis IS NOT NULL" & vbCrLf
    sql = sql & "        THEN DATEDIFF(minute, g.IlkGiris, c.SonCikis)" & vbCrLf
    sql = sql & "        ELSE 0" & vbCrLf
    sql = sql & "    END) AS ToplamCalismaDakika," & vbCrLf
    sql = sql & "    CAST(SUM(CASE " & vbCrLf
    sql = sql & "        WHEN g.IlkGiris IS NOT NULL AND c.SonCikis IS NOT NULL" & vbCrLf
    sql = sql & "        THEN DATEDIFF(minute, g.IlkGiris, c.SonCikis)" & vbCrLf
    sql = sql & "        ELSE 0" & vbCrLf
    sql = sql & "    END) / 60 AS varchar(10)) + ':' + " & vbCrLf
    sql = sql & "    RIGHT('0' + CAST(SUM(CASE " & vbCrLf
    sql = sql & "        WHEN g.IlkGiris IS NOT NULL AND c.SonCikis IS NOT NULL" & vbCrLf
    sql = sql & "        THEN DATEDIFF(minute, g.IlkGiris, c.SonCikis)" & vbCrLf
    sql = sql & "        ELSE 0" & vbCrLf
    sql = sql & "    END) % 60 AS varchar(2)), 2) AS ToplamCalismaSaat," & vbCrLf
    sql = sql & "    SUM(CASE " & vbCrLf
    sql = sql & "        WHEN DATEPART(WEEKDAY, g.Gun) NOT IN (1, 7) " & vbCrLf
    sql = sql & "         AND g.IlkGiris IS NOT NULL AND c.SonCikis IS NOT NULL" & vbCrLf
    sql = sql & "         AND DATEDIFF(minute, g.IlkGiris, c.SonCikis) > " & NormalMesaiDakika & " " & vbCrLf
    sql = sql & "        THEN DATEDIFF(minute, g.IlkGiris, c.SonCikis) - " & NormalMesaiDakika & vbCrLf
    sql = sql & "        ELSE 0" & vbCrLf
    sql = sql & "    END) AS ToplamFazlaMesaiDakika," & vbCrLf
    sql = sql & "    CAST(SUM(CASE " & vbCrLf
    sql = sql & "        WHEN DATEPART(WEEKDAY, g.Gun) NOT IN (1, 7) " & vbCrLf
    sql = sql & "         AND g.IlkGiris IS NOT NULL AND c.SonCikis IS NOT NULL" & vbCrLf
    sql = sql & "         AND DATEDIFF(minute, g.IlkGiris, c.SonCikis) > " & NormalMesaiDakika & " " & vbCrLf
    sql = sql & "        THEN DATEDIFF(minute, g.IlkGiris, c.SonCikis) - " & NormalMesaiDakika & vbCrLf
    sql = sql & "        ELSE 0" & vbCrLf
    sql = sql & "    END) / 60 AS varchar(10)) + ':' + " & vbCrLf
    sql = sql & "    RIGHT('0' + CAST(SUM(CASE " & vbCrLf
    sql = sql & "        WHEN DATEPART(WEEKDAY, g.Gun) NOT IN (1, 7) " & vbCrLf
    sql = sql & "         AND g.IlkGiris IS NOT NULL AND c.SonCikis IS NOT NULL" & vbCrLf
    sql = sql & "         AND DATEDIFF(minute, g.IlkGiris, c.SonCikis) > " & NormalMesaiDakika & " " & vbCrLf
    sql = sql & "        THEN DATEDIFF(minute, g.IlkGiris, c.SonCikis) - " & NormalMesaiDakika & vbCrLf
    sql = sql & "        ELSE 0" & vbCrLf
    sql = sql & "    END) % 60 AS varchar(2)), 2) AS ToplamFazlaMesaiSaat," & vbCrLf
    sql = sql & "    SUM(CASE " & vbCrLf
    sql = sql & "        WHEN DATEPART(WEEKDAY, g.Gun) NOT IN (1, 7) " & vbCrLf
    sql = sql & "         AND g.IlkGiris IS NOT NULL AND c.SonCikis IS NOT NULL" & vbCrLf
    sql = sql & "        THEN " & NormalMesaiDakika & vbCrLf
    sql = sql & "        ELSE 0" & vbCrLf
    sql = sql & "    END) AS ToplamNormalMesaiDakika," & vbCrLf
    sql = sql & "    CAST(SUM(CASE " & vbCrLf
    sql = sql & "        WHEN DATEPART(WEEKDAY, g.Gun) NOT IN (1, 7) " & vbCrLf
    sql = sql & "         AND g.IlkGiris IS NOT NULL AND c.SonCikis IS NOT NULL" & vbCrLf
    sql = sql & "        THEN " & NormalMesaiDakika & vbCrLf
    sql = sql & "        ELSE 0" & vbCrLf
    sql = sql & "    END) / 60 AS varchar(10)) + ':' + " & vbCrLf
    sql = sql & "    RIGHT('0' + CAST(SUM(CASE " & vbCrLf
    sql = sql & "        WHEN DATEPART(WEEKDAY, g.Gun) NOT IN (1, 7) " & vbCrLf
    sql = sql & "         AND g.IlkGiris IS NOT NULL AND c.SonCikis IS NOT NULL" & vbCrLf
    sql = sql & "        THEN " & NormalMesaiDakika & vbCrLf
    sql = sql & "        ELSE 0" & vbCrLf
    sql = sql & "    END) % 60 AS varchar(2)), 2) AS ToplamNormalMesaiSaat," & vbCrLf
    sql = sql & "    SUM(CASE " & vbCrLf
    sql = sql & "        WHEN DATEPART(WEEKDAY, g.Gun) IN (1, 7) " & vbCrLf
    sql = sql & "         AND g.IlkGiris IS NOT NULL AND c.SonCikis IS NOT NULL" & vbCrLf
    sql = sql & "        THEN " & NormalMesaiDakika & vbCrLf
    sql = sql & "        ELSE 0" & vbCrLf
    sql = sql & "    END) AS ToplamHaftaTatilDakika," & vbCrLf
    sql = sql & "    CAST(SUM(CASE " & vbCrLf
    sql = sql & "        WHEN DATEPART(WEEKDAY, g.Gun) IN (1, 7) " & vbCrLf
    sql = sql & "         AND g.IlkGiris IS NOT NULL AND c.SonCikis IS NOT NULL" & vbCrLf
    sql = sql & "        THEN " & NormalMesaiDakika & vbCrLf
    sql = sql & "        ELSE 0" & vbCrLf
    sql = sql & "    END) / 60 AS varchar(10)) + ':' + " & vbCrLf
    sql = sql & "    RIGHT('0' + CAST(SUM(CASE " & vbCrLf
    sql = sql & "        WHEN DATEPART(WEEKDAY, g.Gun) IN (1, 7) " & vbCrLf
    sql = sql & "         AND g.IlkGiris IS NOT NULL AND c.SonCikis IS NOT NULL" & vbCrLf
    sql = sql & "        THEN " & NormalMesaiDakika & vbCrLf
    sql = sql & "        ELSE 0" & vbCrLf
    sql = sql & "    END) % 60 AS varchar(2)), 2) AS ToplamHaftaTatilSaat," & vbCrLf
    sql = sql & "    SUM(CASE " & vbCrLf
    sql = sql & "        WHEN DATEPART(WEEKDAY, g.Gun) IN (1, 7) " & vbCrLf
    sql = sql & "         AND g.IlkGiris IS NOT NULL AND c.SonCikis IS NOT NULL" & vbCrLf
    sql = sql & "         AND DATEDIFF(minute, g.IlkGiris, c.SonCikis) > " & NormalMesaiDakika & " " & vbCrLf
    sql = sql & "        THEN DATEDIFF(minute, g.IlkGiris, c.SonCikis) - " & NormalMesaiDakika & vbCrLf
    sql = sql & "        ELSE 0" & vbCrLf
    sql = sql & "    END) AS ToplamHTFazlaMesaiDakika," & vbCrLf
    sql = sql & "    CAST(SUM(CASE " & vbCrLf
    sql = sql & "        WHEN DATEPART(WEEKDAY, g.Gun) IN (1, 7) " & vbCrLf
    sql = sql & "         AND g.IlkGiris IS NOT NULL AND c.SonCikis IS NOT NULL" & vbCrLf
    sql = sql & "         AND DATEDIFF(minute, g.IlkGiris, c.SonCikis) > " & NormalMesaiDakika & " " & vbCrLf
    sql = sql & "        THEN DATEDIFF(minute, g.IlkGiris, c.SonCikis) - " & NormalMesaiDakika & vbCrLf
    sql = sql & "        ELSE 0" & vbCrLf
    sql = sql & "    END) / 60 AS varchar(10)) + ':' + " & vbCrLf
    sql = sql & "    RIGHT('0' + CAST(SUM(CASE " & vbCrLf
    sql = sql & "        WHEN DATEPART(WEEKDAY, g.Gun) IN (1, 7) " & vbCrLf
    sql = sql & "         AND g.IlkGiris IS NOT NULL AND c.SonCikis IS NOT NULL" & vbCrLf
    sql = sql & "         AND DATEDIFF(minute, g.IlkGiris, c.SonCikis) > " & NormalMesaiDakika & " " & vbCrLf
    sql = sql & "        THEN DATEDIFF(minute, g.IlkGiris, c.SonCikis) - " & NormalMesaiDakika & vbCrLf
    sql = sql & "        ELSE 0" & vbCrLf
    sql = sql & "    END) % 60 AS varchar(2)), 2) AS ToplamHTFazlaMesaiSaat," & vbCrLf
    sql = sql & "    CASE " & vbCrLf
    sql = sql & "        WHEN COUNT(DISTINCT g.Gun) > 0" & vbCrLf
    sql = sql & "        THEN CAST(SUM(CASE " & vbCrLf
    sql = sql & "            WHEN g.IlkGiris IS NOT NULL AND c.SonCikis IS NOT NULL" & vbCrLf
    sql = sql & "            THEN DATEDIFF(minute, g.IlkGiris, c.SonCikis)" & vbCrLf
    sql = sql & "            ELSE 0" & vbCrLf
    sql = sql & "        END) / COUNT(DISTINCT g.Gun) AS int)" & vbCrLf
    sql = sql & "        ELSE 0" & vbCrLf
    sql = sql & "    END AS OrtalamaGunlukCalismaDakika" & vbCrLf
    sql = sql & "FROM (" & vbCrLf
    sql = sql & "    SELECT " & vbCrLf
    sql = sql & "        v.TCKIMLIKNO_PDKS AS TCKIMLIKNO" & vbCrLf
    sql = sql & "    FROM dbo.VW_PERSM0_PDKS v WITH (NOLOCK)" & vbCrLf
    sql = sql & "    WHERE 1=1 " & vbCrLf
    If Trim(KRT.SicilID) <> "" Then 
        sql = sql & "      AND LTRIM(RTRIM(CAST(v.TCKIMLIKNO AS varchar))) = '" & Trim(KRT.SicilID) & "'" & vbCrLf
    End If
    sql = sql & "    GROUP BY v.TCKIMLIKNO_PDKS" & vbCrLf
    sql = sql & ") p" & vbCrLf
    sql = sql & "INNER JOIN dbo.VW_PERSM0_PDKS per ON p.TCKIMLIKNO = per.TCKIMLIKNO_PDKS " & vbCrLf
    sql = sql & "LEFT JOIN (" & vbCrLf
    sql = sql & "    SELECT " & vbCrLf
    sql = sql & "        LTRIM(RTRIM(CAST(p.SicilNo AS varchar))) AS TCKIMLIKNO," & vbCrLf
    sql = sql & "        CAST(p.EventTimeDt AS date) AS Gun," & vbCrLf
    sql = sql & "        MIN(p.EventTimeDt) AS IlkGiris" & vbCrLf
    sql = sql & "    FROM dbo.PDKS_HAMDATA_CACHE p WITH (NOLOCK)" & vbCrLf
    sql = sql & "    INNER JOIN dbo.vw_PDKS_Giris_Terminalleri giris ON CAST(p.TerminalID AS varchar(10)) = giris.TerminalID " & vbCrLf
    sql = sql & "    INNER JOIN dbo.VW_PERSM0_PDKS per ON LTRIM(RTRIM(CAST(p.SicilNo AS varchar))) = per.TCKIMLIKNO_PDKS " & vbCrLf
    sql = sql & "    WHERE 1=1 " & vbCrLf
    If Trim(KRT.KRTTARIH1) <> "" Then 
        sql = sql & "      AND CAST(p.EventTimeDt AS date) >= '" & KRT.KRTTARIH1 & "'" & vbCrLf
    End If
    If Trim(KRT.KRTTARIH2) <> "" Then 
        sql = sql & "      AND CAST(p.EventTimeDt AS date) <= '" & KRT.KRTTARIH2 & "'" & vbCrLf
    End If
    If Trim(KRT.AY) <> "" Then 
        sql = sql & "      AND p.Ay = '" & Trim(KRT.AY) & "'" & vbCrLf
    End If
    If Trim(KRT.SicilID) <> "" Then 
        sql = sql & "      AND LTRIM(RTRIM(CAST(p.SicilNo AS varchar))) = '" & Trim(KRT.SicilID) & "'" & vbCrLf
    End If
    sql = sql & "    GROUP BY p.SicilNo, CAST(p.EventTimeDt AS date)" & vbCrLf
    sql = sql & ") g ON LTRIM(RTRIM(CAST(p.TCKIMLIKNO AS varchar))) = LTRIM(RTRIM(CAST(g.TCKIMLIKNO AS varchar))) COLLATE Turkish_CI_AS" & vbCrLf
    sql = sql & "LEFT JOIN (" & vbCrLf
    sql = sql & "    SELECT " & vbCrLf
    sql = sql & "        LTRIM(RTRIM(CAST(p.SicilNo AS varchar))) AS TCKIMLIKNO," & vbCrLf
    sql = sql & "        CAST(p.EventTimeDt AS date) AS Gun," & vbCrLf
    sql = sql & "        MAX(p.EventTimeDt) AS SonCikis" & vbCrLf
    sql = sql & "    FROM dbo.PDKS_HAMDATA_CACHE p WITH (NOLOCK)" & vbCrLf
    sql = sql & "    INNER JOIN dbo.vw_PDKS_Cikis_Terminalleri cikis ON CAST(p.TerminalID AS varchar(10)) = cikis.TerminalID " & vbCrLf
    sql = sql & "    INNER JOIN dbo.VW_PERSM0_PDKS per ON LTRIM(RTRIM(CAST(p.SicilNo AS varchar))) = per.TCKIMLIKNO_PDKS " & vbCrLf
    sql = sql & "    WHERE 1=1 " & vbCrLf
    ' Çıkış için tarih filtreleri (ertesi günü de kapsamak için genişletilmiş)
    If Trim(KRT.KRTTARIH1) <> "" Then 
        sql = sql & "      AND CAST(p.EventTimeDt AS date) >= DATEADD(DAY, -1, '" & KRT.KRTTARIH1 & "')" & vbCrLf
    End If
    If Trim(KRT.KRTTARIH2) <> "" Then 
        sql = sql & "      AND CAST(p.EventTimeDt AS date) <= DATEADD(DAY, 1, '" & KRT.KRTTARIH2 & "')" & vbCrLf
    End If
    If Trim(KRT.AY) <> "" Then 
        sql = sql & "      AND p.Ay = '" & Trim(KRT.AY) & "'" & vbCrLf
    End If
    If Trim(KRT.SicilID) <> "" Then 
        sql = sql & "      AND LTRIM(RTRIM(CAST(p.SicilNo AS varchar))) = '" & Trim(KRT.SicilID) & "'" & vbCrLf
    End If
    sql = sql & "    GROUP BY p.SicilNo, CAST(p.EventTimeDt AS date)" & vbCrLf
    sql = sql & ") c ON LTRIM(RTRIM(CAST(p.TCKIMLIKNO AS varchar))) = LTRIM(RTRIM(CAST(c.TCKIMLIKNO AS varchar))) COLLATE Turkish_CI_AS " & vbCrLf
    sql = sql & "   AND (" & vbCrLf
    sql = sql & "       -- Aynı gün çıkış " & vbCrLf
    sql = sql & "       g.Gun = c.Gun " & vbCrLf
    sql = sql & "       OR " & vbCrLf
    sql = sql & "       -- Ertesi gün çıkış (gece vardiyası kontrolü zaman kontrolü ile yapılacak) " & vbCrLf
    sql = sql & "       c.Gun = DATEADD(DAY, 1, g.Gun) " & vbCrLf
    sql = sql & "   )" & vbCrLf
    sql = sql & "GROUP BY p.TCKIMLIKNO" & vbCrLf
    sql = sql & "HAVING COUNT(DISTINCT g.Gun) > 0" & vbCrLf
    sql = sql & "ORDER BY MAX(per.AD) ASC, MAX(per.SOYAD) ASC;" & vbCrLf
    If Nereden = "Makro1" Then 
        Set PUANTAJTOPLAMSQL = Doc.RunSQLQuery("PUANTAJTOPLAM_SQL", sql)
        Exit Sub
    End If
    Set PUANTAJTOPLAMSQLDOLU = Doc.RunSQLQuery("PUANTAJTOPLAM_SQL_DOLU", sql)
    Set PUANTAJTOPLAMSQL = Doc.GetTableObject("PUANTAJTOPLAM_SQL")
    PUANTAJTOPLAMSQL.Empty
    If PUANTAJTOPLAMSQLDOLU.GetRecCount = 0 Then
        Msgbox "Kayıt Bulunamadı...(msg:858)"
        Exit Sub
    End If
    PUANTAJTOPLAMSQL.CopyTable(PUANTAJTOPLAMSQLDOLU)
    Set PUANTAJTOPLAMSQLDOLU = Nothing 
    PUANTAJTOPLAMSQL.SetCurrentRow 1	
    Call SonGuncellemeZamani("Puantaj_Personel_Toplam")	
End Sub
