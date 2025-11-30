Sub INITDOCUMENT
	Set MTABLET = Doc.CreateTransactionalTableObject("MAKROTABLET=STACK(NOFILE)", "IO")
	MTABLET.AddField2 "TerminalID","CHAR",4,0,"L","",""
	MTABLET.AddField2 "TerminalYonu","CHAR",50,0,"L","",""
	Set KRT = Doc.CreateTableObject("KRITERLER=STACK", "IO")
	KRT.AddField2 "TCKIMLIKNO","CHAR",20,0,"L","",""
	Set MTABLEG = Doc.CreateTableObject("MTABLEGENEL=STACK", "IO")
	MTABLEG.AddField2 "ToplamKayitSayisi","DOUBLE",3,0,"R","",""
	Call Personel_Listesi("Makro1")
	Set ZUPAYARE = Doc.GetTableObject("ZU_P_AYARE")
	ZUPAYARE.PMO_AP10 = ""
	ZUPAYARE.PMO_STATU = ""
	ZUPAYARE.PMO_GK1 = ""
End Sub
Sub INITDOCUMENT_VALUES
' - INITDOCUMENT ve programın standart metodları ile Rowsetlerin tümü yaratıldıktan sonra burada değer atanabilir veya özelliği değiştirilebilir
'
'	Mesela aşağıdaki komutla satır eklenemez çıkartılamaz şekle getirilebilir.
'   Dim RS1
'   Set RS1=Doc.GetRowSetObject("XXXX")
'	RS1.SetRowAID 0,0,0
End Sub
Sub CALC_BIRSEYLER_HESAPLA
	Doc.MsgBox("KTM Kullanıcı Modül Tanımındaki Makroların İçindeki CALC_BIRSEYLER_HESAPLA Sub Çağrıldı")
End Sub
'------------------------------------------------
Sub giris_cikis_data(Nereden)
	Set KRT = Doc.GetTableObject("KRITERLER")
	If Nereden = "Makro1" Then
		KRT.KRTTARIH1 = Doc.Bugun
		KRT.KRTTARIH2 = Doc.Bugun
	End If
	If (Trim(KRT.KRTTARIH1) <> "" or  Trim(KRT.KRTTARIH2) <> "") and Trim(KRT.AY) <> "" Then
		msgbox "Tarih ve Ay Kriterleri Aynı Anda Kullanılamaz." 
		Exit Sub
	End If
    sql = ""
    sql = sql & "SELECT " & vbCrLf
	sql = sql & "    g.Gun," & vbCrLf
	sql = sql & "    g.TCKIMLIKNO AS SicilNo," & vbCrLf
	sql = sql & "    MAX(g.PersonelAdi) AS PersonelAdi," & vbCrLf
	sql = sql & "    MAX(g.PersonelSoyadi) AS PersonelSoyadi," & vbCrLf
	sql = sql & "    MAX(g.Gun_Adi) AS Gun_Adi," & vbCrLf
	sql = sql & "    CASE " & vbCrLf
	sql = sql & "        WHEN MIN(CASE WHEN g.rn = 1 THEN g.EventTimeDt END) IS NULL THEN '' " & vbCrLf
	sql = sql & "        ELSE LEFT(CONVERT(char(8), MIN(CASE WHEN g.rn = 1 THEN g.EventTimeDt END), 108), 5) " & vbCrLf
	sql = sql & "    END AS IlkGiris," & vbCrLf
	sql = sql & "    CASE " & vbCrLf
	sql = sql & "        WHEN MAX(CASE WHEN c.rn = 1 THEN c.EventTimeDt END) IS NULL THEN '' " & vbCrLf
	sql = sql & "        ELSE LEFT(CONVERT(char(8), MAX(CASE WHEN c.rn = 1 THEN c.EventTimeDt END), 108), 5) " & vbCrLf
	sql = sql & "    END AS SonCikis," & vbCrLf
	sql = sql & "    COUNT(DISTINCT g.EventTimeDt) AS GirisAdedi," & vbCrLf
	sql = sql & "    COUNT(DISTINCT c.EventTimeDt) AS CikisAdedi," & vbCrLf
	sql = sql & "    MAX(g.STIME) AS STIME," & vbCrLf
	sql = sql & "    MAX(g.ETIME) AS ETIME," & vbCrLf
	sql = sql & "    MAX(g.VARDIYA) AS VARDIYA," & vbCrLf
	sql = sql & "    MAX(g.HESAPSABLONU) AS HESAPSABLONU" & vbCrLf
	sql = sql & "FROM (" & vbCrLf
	sql = sql & "    SELECT " & vbCrLf
	sql = sql & "        v.TCKIMLIKNO_PDKS AS TCKIMLIKNO," & vbCrLf
	sql = sql & "        MAX(v.AD) AS PersonelAdi," & vbCrLf
	sql = sql & "        MAX(v.SOYAD) AS PersonelSoyadi," & vbCrLf
	sql = sql & "        CAST(p.EventTimeDt AS date) AS Gun," & vbCrLf
	sql = sql & "        CASE DATEPART(WEEKDAY, CAST(p.EventTimeDt AS date))" & vbCrLf
	sql = sql & "            WHEN 1 THEN 'Pazar'" & vbCrLf
	sql = sql & "            WHEN 2 THEN 'Pazartesi'" & vbCrLf
	sql = sql & "            WHEN 3 THEN 'Salı'" & vbCrLf
	sql = sql & "            WHEN 4 THEN 'Çarşamba'" & vbCrLf
	sql = sql & "            WHEN 5 THEN 'Perşembe'" & vbCrLf
	sql = sql & "            WHEN 6 THEN 'Cuma'" & vbCrLf
	sql = sql & "            WHEN 7 THEN 'Cumartesi'" & vbCrLf
	sql = sql & "        END AS Gun_Adi," & vbCrLf
	sql = sql & "        p.EventTimeDt," & vbCrLf
	sql = sql & "        MAX(v.STIME) AS STIME," & vbCrLf
	sql = sql & "        MAX(v.ETIME) AS ETIME," & vbCrLf
	sql = sql & "        MAX(v.VARDIYA) AS VARDIYA," & vbCrLf
	sql = sql & "        MAX(v.HESAPSABLONU) AS HESAPSABLONU," & vbCrLf
	sql = sql & "        ROW_NUMBER() OVER (PARTITION BY p.SicilNo, CAST(p.EventTimeDt AS date) ORDER BY p.EventTimeDt) AS rn" & vbCrLf
	sql = sql & "    FROM dbo.PDKS_HAMDATA_CACHE p WITH (NOLOCK)" & vbCrLf
	sql = sql & "    INNER JOIN dbo.vw_PDKS_Giris_Terminalleri giris ON CAST(p.TerminalID AS varchar(10)) = giris.TerminalID " & vbCrLf
	sql = sql & "    INNER JOIN dbo.VW_PERSM0_PDKS v ON LTRIM(RTRIM(CAST(p.SicilNo AS varchar))) = v.TCKIMLIKNO_PDKS" & vbCrLf
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
	If Trim(KRT.SicilNo) <> "" Then 
		sql = sql & "      AND LTRIM(RTRIM(CAST(p.SicilNo AS varchar))) = '" & Trim(KRT.SicilNo) & "'" & vbCrLf
	End If
	sql = sql & "    GROUP BY p.SicilNo, CAST(p.EventTimeDt AS date), p.EventTimeDt, v.TCKIMLIKNO_PDKS" & vbCrLf
	sql = sql & ") g" & vbCrLf
	sql = sql & "LEFT JOIN (" & vbCrLf
	sql = sql & "    SELECT " & vbCrLf
	sql = sql & "        v.TCKIMLIKNO_PDKS AS TCKIMLIKNO," & vbCrLf
	sql = sql & "        CAST(p.EventTimeDt AS date) AS Gun," & vbCrLf
	sql = sql & "        p.EventTimeDt," & vbCrLf
	sql = sql & "        ROW_NUMBER() OVER (PARTITION BY p.SicilNo, CAST(p.EventTimeDt AS date) ORDER BY p.EventTimeDt DESC) AS rn" & vbCrLf
	sql = sql & "    FROM dbo.PDKS_HAMDATA_CACHE p WITH (NOLOCK)" & vbCrLf
	sql = sql & "    INNER JOIN dbo.vw_PDKS_Cikis_Terminalleri cikis ON CAST(p.TerminalID AS varchar(10)) = cikis.TerminalID " & vbCrLf
	sql = sql & "    INNER JOIN dbo.VW_PERSM0_PDKS v ON LTRIM(RTRIM(CAST(p.SicilNo AS varchar))) = v.TCKIMLIKNO_PDKS" & vbCrLf
	sql = sql & "    WHERE 1=1 " & vbCrLf
	If Trim(KRT.KRTTARIH1) <> "" Then 
		sql = sql & "      AND CAST(p.EventTimeDt AS date) >= DATEADD(DAY, -1, '" & KRT.KRTTARIH1 & "')" & vbCrLf
	End If
	If Trim(KRT.KRTTARIH2) <> "" Then 
		sql = sql & "      AND CAST(p.EventTimeDt AS date) <= DATEADD(DAY, 1, '" & KRT.KRTTARIH2 & "')" & vbCrLf
	End If
	If Trim(KRT.AY) <> "" Then 
		sql = sql & "      AND p.Ay = '" & Trim(KRT.AY) & "'" & vbCrLf
	End If
	If Trim(KRT.SicilNo) <> "" Then 
		sql = sql & "      AND LTRIM(RTRIM(CAST(p.SicilNo AS varchar))) = '" & Trim(KRT.SicilNo) & "'" & vbCrLf
	End If
	sql = sql & "    GROUP BY p.SicilNo, CAST(p.EventTimeDt AS date), p.EventTimeDt, v.TCKIMLIKNO_PDKS" & vbCrLf
	sql = sql & ") c ON g.TCKIMLIKNO = c.TCKIMLIKNO " & vbCrLf
	sql = sql & "   AND (" & vbCrLf
	sql = sql & "       -- Aynı gün çıkış " & vbCrLf
	sql = sql & "       g.Gun = c.Gun " & vbCrLf
	sql = sql & "       OR " & vbCrLf
	sql = sql & "       -- Ertesi gün çıkış (gece vardiyası kontrolü zaman kontrolü ile yapılacak) " & vbCrLf
	sql = sql & "       c.Gun = DATEADD(DAY, 1, g.Gun) " & vbCrLf
	sql = sql & "   )" & vbCrLf
	sql = sql & "GROUP BY g.Gun, g.TCKIMLIKNO, g.STIME, g.ETIME, g.VARDIYA, g.HESAPSABLONU" & vbCrLf
	sql = sql & "ORDER BY g.Gun ASC, MAX(g.PersonelAdi) ASC, MAX(g.PersonelSoyadi) ASC;" & vbCrLf
	If Nereden = "Makro1" Then 
		Set GUNLUKSQL = Doc.RunSQLQuery("GUNLUK_SQL", sql)
		Exit Sub
	End If
	Set GUNLUKSQLDOLU = Doc.RunSQLQuery("GUNLUK_SQL_DOLU", sql)
	Set GUNLUKSQL = Doc.GetTableObject("GUNLUK_SQL")
	GUNLUKSQL.Empty
	If GUNLUKSQLDOLU.GetRecCount = 0 Then
		Msgbox "Kayıt Bulunamadı...(msg:858)"
		Exit Sub
	End If
	GUNLUKSQL.CopyTable(GUNLUKSQLDOLU)
	Set GUNLUKSQLDOLU = Nothing 
	GUNLUKSQL.SetCurrentRow 1	
	Call SonGuncellemeZamani("giris_cikis_data")	
End Sub
'------------------------------------------------
Sub giris_cikis_data_detay(Nereden)
	Set KRT = Doc.GetTableObject("KRITERLER")
	If Nereden = "Makro1" Then
		KRT.KRTTARIH1 = Doc.Bugun
		KRT.KRTTARIH2 = Doc.Bugun
	End If
	If (Trim(KRT.KRTTARIH1) <> "" or  Trim(KRT.KRTTARIH2) <> "") and Trim(KRT.AY) <> "" Then
		msgbox "Tarih ve Ay Kriterleri Aynı Anda Kullanılamaz." 
		Exit Sub
	End If
	sql = ""
	sql = sql & "SELECT " & vbCrLf
	sql = sql & "    CAST(p.EventTimeDt AS date) AS Gun," & vbCrLf
	sql = sql & "    CASE DATEPART(WEEKDAY, CAST(p.EventTimeDt AS date))" & vbCrLf
	sql = sql & "        WHEN 1 THEN 'Pazar'" & vbCrLf
	sql = sql & "        WHEN 2 THEN 'Pazartesi'" & vbCrLf
	sql = sql & "        WHEN 3 THEN 'Salı'" & vbCrLf
	sql = sql & "        WHEN 4 THEN 'Çarşamba'" & vbCrLf
	sql = sql & "        WHEN 5 THEN 'Perşembe'" & vbCrLf
	sql = sql & "        WHEN 6 THEN 'Cuma'" & vbCrLf
	sql = sql & "        WHEN 7 THEN 'Cumartesi'" & vbCrLf
	sql = sql & "    END AS Gun_Adi," & vbCrLf
	sql = sql & "    LTRIM(RTRIM(CAST(p.SicilNo AS varchar))) AS SicilNo," & vbCrLf
	sql = sql & "    MAX(v.AD) AS PersonelAdi," & vbCrLf
	sql = sql & "    MAX(v.SOYAD) AS PersonelSoyadi," & vbCrLf
	sql = sql & "    'GIRIS' AS HareketTipi," & vbCrLf
	sql = sql & "    CAST(LEFT(CONVERT(char(8), p.EventTimeDt, 108), 5) AS varchar(5)) AS HareketSaati," & vbCrLf
	sql = sql & "    p.EventTimeDt," & vbCrLf
	sql = sql & "    CAST(p.TerminalID AS varchar(10)) AS TerminalID," & vbCrLf
	sql = sql & "    p.TerminalYonu," & vbCrLf
	sql = sql & "    MAX(v.STIME) AS STIME," & vbCrLf
	sql = sql & "    MAX(v.ETIME) AS ETIME," & vbCrLf
	sql = sql & "    MAX(v.VARDIYA) AS VARDIYA," & vbCrLf
	sql = sql & "    MAX(v.HESAPSABLONU) AS HESAPSABLONU," & vbCrLf
	sql = sql & "    ROW_NUMBER() OVER (PARTITION BY p.SicilNo, CAST(p.EventTimeDt AS date) ORDER BY p.EventTimeDt) AS SiraNo" & vbCrLf
	sql = sql & "FROM dbo.PDKS_HAMDATA_CACHE p WITH (NOLOCK)" & vbCrLf
	sql = sql & "INNER JOIN dbo.vw_PDKS_Giris_Terminalleri giris ON CAST(p.TerminalID AS varchar(10)) = giris.TerminalID " & vbCrLf
	sql = sql & "INNER JOIN dbo.VW_PERSM0_PDKS v ON LTRIM(RTRIM(CAST(p.SicilNo AS varchar))) = v.TCKIMLIKNO_PDKS COLLATE Turkish_CI_AS " & vbCrLf
	sql = sql & "WHERE 1=1 " & vbCrLf
	If Trim(KRT.KRTTARIH1) <> "" Then 
		sql = sql & "  AND CAST(p.EventTimeDt AS date) >= '" & KRT.KRTTARIH1 & "'" & vbCrLf
	End If
	If Trim(KRT.KRTTARIH2) <> "" Then 
		sql = sql & "  AND CAST(p.EventTimeDt AS date) <= '" & KRT.KRTTARIH2 & "'" & vbCrLf
	End If
	If Trim(KRT.AY) <> "" Then 
		sql = sql & "  AND p.Ay = '" & Trim(KRT.AY) & "'" & vbCrLf
	End If
	If Trim(KRT.SicilNo) <> "" Then 
		sql = sql & "  AND LTRIM(RTRIM(CAST(p.SicilNo AS varchar))) = '" & Trim(KRT.SicilNo) & "'" & vbCrLf
	End If
	sql = sql & "GROUP BY p.SicilNo, CAST(p.EventTimeDt AS date), p.EventTimeDt, p.TerminalID, p.TerminalYonu" & vbCrLf
	sql = sql & "UNION ALL" & vbCrLf
	sql = sql & "SELECT " & vbCrLf
	sql = sql & "    CAST(p.EventTimeDt AS date) AS Gun," & vbCrLf
	sql = sql & "    CASE DATEPART(WEEKDAY, CAST(p.EventTimeDt AS date))" & vbCrLf
	sql = sql & "        WHEN 1 THEN 'Pazar'" & vbCrLf
	sql = sql & "        WHEN 2 THEN 'Pazartesi'" & vbCrLf
	sql = sql & "        WHEN 3 THEN 'Salı'" & vbCrLf
	sql = sql & "        WHEN 4 THEN 'Çarşamba'" & vbCrLf
	sql = sql & "        WHEN 5 THEN 'Perşembe'" & vbCrLf
	sql = sql & "        WHEN 6 THEN 'Cuma'" & vbCrLf
	sql = sql & "        WHEN 7 THEN 'Cumartesi'" & vbCrLf
	sql = sql & "    END AS Gun_Adi," & vbCrLf
	sql = sql & "    LTRIM(RTRIM(CAST(p.SicilNo AS varchar))) AS SicilNo," & vbCrLf
	sql = sql & "    MAX(v.AD) AS PersonelAdi," & vbCrLf
	sql = sql & "    MAX(v.SOYAD) AS PersonelSoyadi," & vbCrLf
	sql = sql & "    'CIKIS' AS HareketTipi," & vbCrLf
	sql = sql & "    CAST(LEFT(CONVERT(char(8), p.EventTimeDt, 108), 5) AS varchar(5)) AS HareketSaati," & vbCrLf
	sql = sql & "    p.EventTimeDt," & vbCrLf
	sql = sql & "    CAST(p.TerminalID AS varchar(10)) AS TerminalID," & vbCrLf
	sql = sql & "    p.TerminalYonu," & vbCrLf
	sql = sql & "    MAX(v.STIME) AS STIME," & vbCrLf
	sql = sql & "    MAX(v.ETIME) AS ETIME," & vbCrLf
	sql = sql & "    MAX(v.VARDIYA) AS VARDIYA," & vbCrLf
	sql = sql & "    MAX(v.HESAPSABLONU) AS HESAPSABLONU," & vbCrLf
	sql = sql & "    ROW_NUMBER() OVER (PARTITION BY p.SicilNo, CAST(p.EventTimeDt AS date) ORDER BY p.EventTimeDt DESC) AS SiraNo" & vbCrLf
	sql = sql & "FROM dbo.PDKS_HAMDATA_CACHE p WITH (NOLOCK)" & vbCrLf
	sql = sql & "INNER JOIN dbo.vw_PDKS_Cikis_Terminalleri cikis ON CAST(p.TerminalID AS varchar(10)) = cikis.TerminalID " & vbCrLf
	sql = sql & "INNER JOIN dbo.VW_PERSM0_PDKS v ON LTRIM(RTRIM(CAST(p.SicilNo AS varchar))) = v.TCKIMLIKNO_PDKS COLLATE Turkish_CI_AS " & vbCrLf
	sql = sql & "WHERE 1=1 " & vbCrLf
	If Trim(KRT.KRTTARIH1) <> "" Then 
		sql = sql & "  AND CAST(p.EventTimeDt AS date) >= DATEADD(DAY, -1, '" & KRT.KRTTARIH1 & "')" & vbCrLf
	End If
	If Trim(KRT.KRTTARIH2) <> "" Then 
		sql = sql & "  AND CAST(p.EventTimeDt AS date) <= DATEADD(DAY, 1, '" & KRT.KRTTARIH2 & "')" & vbCrLf
	End If
	If Trim(KRT.AY) <> "" Then 
		sql = sql & "  AND p.Ay = '" & Trim(KRT.AY) & "'" & vbCrLf
	End If
	If Trim(KRT.SicilNo) <> "" Then 
		sql = sql & "  AND LTRIM(RTRIM(CAST(p.SicilNo AS varchar))) = '" & Trim(KRT.SicilNo) & "'" & vbCrLf
	End If
	sql = sql & "GROUP BY p.SicilNo, CAST(p.EventTimeDt AS date), p.EventTimeDt, p.TerminalID, p.TerminalYonu" & vbCrLf
	sql = sql & "ORDER BY Gun ASC, SicilNo ASC, EventTimeDt ASC;" & vbCrLf
	If Nereden = "Makro1" Then 
		Set GUNLUKDETAYSQL = Doc.RunSQLQuery("GUNLUK_DETAY_SQL", sql)
		Exit Sub
	End If
	Set GUNLUKDETAYSQLDOLU = Doc.RunSQLQuery("GUNLUK_DETAY_SQL_DOLU", sql)
	Set GUNLUKDETAYSQL = Doc.GetTableObject("GUNLUK_DETAY_SQL")
	GUNLUKDETAYSQL.Empty
	If GUNLUKDETAYSQLDOLU.GetRecCount = 0 Then
		Msgbox "Kayıt Bulunamadı...(msg:858)"
		Exit Sub
	End If
	GUNLUKDETAYSQL.CopyTable(GUNLUKDETAYSQLDOLU)
	Set GUNLUKDETAYSQLDOLU = Nothing 
	GUNLUKDETAYSQL.SetCurrentRow 1	
	Call SonGuncellemeZamani("giris_cikis_data_detay")	
End Sub
'------------------------------------------------
Sub Toplam_Devamsizlik(Nereden)
    Set KRT = Doc.GetTableObject("KRITERLER")
    sql = ""
    sql = sql & "SELECT " & vbCrLf
    sql = sql & "    p.TCKIMLIKNO AS SicilID," & vbCrLf
    sql = sql & "    MAX(p.Ad) AS PersonelAdi," & vbCrLf
    sql = sql & "    MAX(p.Soyad) AS PersonelSoyadi," & vbCrLf
    sql = sql & "    COUNT(DISTINCT t.Tarih) AS ToplamGun," & vbCrLf
    sql = sql & "    SUM(CASE WHEN g.IlkGiris IS NULL AND c.SonCikis IS NULL THEN 1 ELSE 0 END) AS TamDevamsizGun," & vbCrLf
    sql = sql & "    SUM(CASE WHEN g.IlkGiris IS NULL THEN 1 ELSE 0 END) AS GirisYokGun," & vbCrLf
    sql = sql & "    SUM(CASE WHEN c.SonCikis IS NULL THEN 1 ELSE 0 END) AS CikisYokGun," & vbCrLf
    sql = sql & "    SUM(CASE WHEN g.IlkGiris IS NOT NULL AND c.SonCikis IS NOT NULL THEN 1 ELSE 0 END) AS TamGun" & vbCrLf
    sql = sql & "FROM (" & vbCrLf
    sql = sql & "    SELECT DISTINCT " & vbCrLf
    sql = sql & "        CAST(p.EventTimeDt AS date) AS Tarih" & vbCrLf
    sql = sql & "    FROM dbo.PDKS_HAMDATA_CACHE p WITH (NOLOCK)" & vbCrLf
    sql = sql & "    WHERE 1=1 " & vbCrLf
    sql = sql & "      AND DATEPART(WEEKDAY, CAST(p.EventTimeDt AS date)) NOT IN (1, 7)" & vbCrLf
    If Trim(KRT.KRTTARIH1) <> "" Then 
        sql = sql & "      AND CAST(p.EventTimeDt AS date) >= '" & KRT.KRTTARIH1 & "'" & vbCrLf
    End If
    If Trim(KRT.KRTTARIH2) <> "" Then 
        sql = sql & "      AND CAST(p.EventTimeDt AS date) <= '" & KRT.KRTTARIH2 & "'" & vbCrLf
    End If
    If Trim(KRT.AY) <> "" Then 
        sql = sql & "      AND p.Ay = '" & Trim(KRT.AY) & "'" & vbCrLf
    End If
    sql = sql & ") t" & vbCrLf
    sql = sql & "CROSS JOIN (" & vbCrLf
    sql = sql & "    SELECT " & vbCrLf
    sql = sql & "        LTRIM(RTRIM(CAST(p.TCKIMLIKNO AS varchar))) AS TCKIMLIKNO," & vbCrLf
    sql = sql & "        MAX(p.Ad) AS PersonelAdi," & vbCrLf
    sql = sql & "        MAX(p.Soyad) AS PersonelSoyadi" & vbCrLf
    sql = sql & "    FROM dbo.PERSM0 p WITH (NOLOCK)" & vbCrLf
    sql = sql & "    WHERE 1=1 " & vbCrLf
    sql = sql & "      AND p.AP10 = 1 " & vbCrLf
    sql = sql & "      AND p.STATU = 1 " & vbCrLf
    sql = sql & "      AND p.GK_1 IN ('MNS') " & vbCrLf
    If Nereden <> "Makro1" Then
    If Trim(KRT.SicilID) <> "" Then 
            sql = sql & "      AND LTRIM(RTRIM(CAST(p.TCKIMLIKNO AS varchar))) = '" & Trim(KRT.SicilID) & "'" & vbCrLf
        End If
    End If
    sql = sql & "    GROUP BY p.TCKIMLIKNO" & vbCrLf
    sql = sql & ") p" & vbCrLf
    sql = sql & "LEFT JOIN (" & vbCrLf
    sql = sql & "    SELECT " & vbCrLf
    sql = sql & "        LTRIM(RTRIM(CAST(p.SicilNo AS varchar))) AS TCKIMLIKNO," & vbCrLf
    sql = sql & "        CAST(p.EventTimeDt AS date) AS Tarih," & vbCrLf
    sql = sql & "        MIN(p.EventTimeDt) AS IlkGiris" & vbCrLf
    sql = sql & "    FROM dbo.PDKS_HAMDATA_CACHE p WITH (NOLOCK)" & vbCrLf
    sql = sql & "    INNER JOIN dbo.vw_PDKS_Giris_Terminalleri giris ON CAST(p.TerminalID AS varchar(10)) = giris.TerminalID " & vbCrLf
    sql = sql & "    WHERE 1=1 " & vbCrLf
    sql = sql & "      AND DATEPART(WEEKDAY, CAST(p.EventTimeDt AS date)) NOT IN (1, 7)" & vbCrLf
    If Trim(KRT.KRTTARIH1) <> "" Then 
        sql = sql & "      AND CAST(p.EventTimeDt AS date) >= '" & KRT.KRTTARIH1 & "'" & vbCrLf
    End If
    If Trim(KRT.KRTTARIH2) <> "" Then 
        sql = sql & "      AND CAST(p.EventTimeDt AS date) <= '" & KRT.KRTTARIH2 & "'" & vbCrLf
    End If
    If Trim(KRT.AY) <> "" Then 
        sql = sql & "      AND p.Ay = '" & Trim(KRT.AY) & "'" & vbCrLf
    End If
    sql = sql & "    GROUP BY p.SicilNo, CAST(p.EventTimeDt AS date)" & vbCrLf
    sql = sql & ") g ON LTRIM(RTRIM(CAST(p.TCKIMLIKNO AS varchar))) = LTRIM(RTRIM(CAST(g.TCKIMLIKNO AS varchar))) AND t.Tarih = g.Tarih" & vbCrLf
    sql = sql & "LEFT JOIN (" & vbCrLf
    sql = sql & "    SELECT " & vbCrLf
    sql = sql & "        LTRIM(RTRIM(CAST(p.SicilNo AS varchar))) AS TCKIMLIKNO," & vbCrLf
    sql = sql & "        CAST(p.EventTimeDt AS date) AS Tarih," & vbCrLf
    sql = sql & "        MAX(p.EventTimeDt) AS SonCikis" & vbCrLf
    sql = sql & "    FROM dbo.PDKS_HAMDATA_CACHE p WITH (NOLOCK)" & vbCrLf
    sql = sql & "    INNER JOIN dbo.vw_PDKS_Cikis_Terminalleri cikis ON CAST(p.TerminalID AS varchar(10)) = cikis.TerminalID " & vbCrLf
    sql = sql & "    WHERE 1=1 " & vbCrLf
    sql = sql & "      AND DATEPART(WEEKDAY, CAST(p.EventTimeDt AS date)) NOT IN (1, 7)" & vbCrLf
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
    sql = sql & "    GROUP BY p.SicilNo, CAST(p.EventTimeDt AS date)" & vbCrLf
    sql = sql & ") c ON LTRIM(RTRIM(CAST(p.TCKIMLIKNO AS varchar))) = LTRIM(RTRIM(CAST(c.TCKIMLIKNO AS varchar))) " & vbCrLf
    sql = sql & "   AND (" & vbCrLf
    sql = sql & "       -- Aynı gün çıkış " & vbCrLf
    sql = sql & "       t.Tarih = c.Tarih " & vbCrLf
    sql = sql & "       OR " & vbCrLf
    sql = sql & "       -- Ertesi gün çıkış (gece vardiyası kontrolü zaman kontrolü ile yapılacak) " & vbCrLf
    sql = sql & "       c.Tarih = DATEADD(DAY, 1, t.Tarih) " & vbCrLf
    sql = sql & "   )" & vbCrLf
    sql = sql & "GROUP BY p.TCKIMLIKNO, p.Ad, p.Soyad" & vbCrLf
    sql = sql & "HAVING SUM(CASE WHEN g.IlkGiris IS NULL OR c.SonCikis IS NULL THEN 1 ELSE 0 END) > 0" & vbCrLf
    sql = sql & "ORDER BY TamDevamsizGun DESC, GirisYokGun DESC, p.Ad, p.Soyad;" & vbCrLf
    If Nereden = "Makro1" Then 
        Set TOPLAMDEVAMSIZLIKSQL = Doc.RunSQLQuery("TOPLAMDEVAMSIZLIK_SQL", sql)
        Exit Sub
    End If
    Set TOPLAMDEVAMSIZLIKSQLDOLU = Doc.RunSQLQuery("TOPLAMDEVAMSIZLIK_SQL_DOLU", sql)	
    Set TOPLAMDEVAMSIZLIKSQL = Doc.GetTableObject("TOPLAMDEVAMSIZLIK_SQL")
    TOPLAMDEVAMSIZLIKSQL.Empty
    If TOPLAMDEVAMSIZLIKSQLDOLU.GetRecCount = 0 Then
        Msgbox "Kayıt Bulunamadı...(msg:858)"
        Exit Sub
    End If
    TOPLAMDEVAMSIZLIKSQL.CopyTable(TOPLAMDEVAMSIZLIKSQLDOLU)
    Set TOPLAMDEVAMSIZLIKSQLDOLU = Nothing 
    TOPLAMDEVAMSIZLIKSQL.SetCurrentRow 1	
    Call SonGuncellemeZamani("Toplam_Devamsizlik")	
End Sub
'------------------------------------------------
Sub cmd_Personel_Listesi
	Call Personel_Listesi("cmd_Personel_Listesi")
End Sub
'------------------------------------------------
Sub Personel_Listesi(Nereden)
	Set ZUPAYARE = Doc.GetTableObject("ZU_P_AYARE")
	sql = ""
	sql = sql & "SELECT " & vbCrLf
	sql = sql & "    LTRIM(RTRIM(CAST(v.TCKIMLIKNO AS varchar))) AS TCKIMLIKNO," & vbCrLf
	sql = sql & "    v.KOD," & vbCrLf
	sql = sql & "    v.AD," & vbCrLf
	sql = sql & "    v.SOYAD," & vbCrLf
	sql = sql & "    v.AD_SOYAD," & vbCrLf
	sql = sql & "    v.PERS00_KOD," & vbCrLf
	sql = sql & "    v.YAS," & vbCrLf
	sql = sql & "    v.DOGUM_TARIHI," & vbCrLf
	sql = sql & "    v.CINSIYET," & vbCrLf
	sql = sql & "    v.TELEFON_CEP," & vbCrLf
	sql = sql & "    v.EMAIL_1," & vbCrLf
	sql = sql & "    v.DEPARTMAN," & vbCrLf
	sql = sql & "    v.GOREV," & vbCrLf
	sql = sql & "    v.ISEGIRISTARIHI," & vbCrLf
	sql = sql & "    v.ISTENCIKISTARIHI," & vbCrLf
	sql = sql & "    v.STATU," & vbCrLf
	sql = sql & "    v.AP10," & vbCrLf
	sql = sql & "    v.GK_1," & vbCrLf
	sql = sql & "    v.MEDENI_DURUMU," & vbCrLf
	sql = sql & "    v.OGRENIM," & vbCrLf
	sql = sql & "    v.ADRES1," & vbCrLf
	sql = sql & "    v.NF_IL," & vbCrLf
	sql = sql & "    v.NF_ILCE" & vbCrLf
	sql = sql & "FROM dbo.VW_PERSM0_PDKS v WITH (NOLOCK)" & vbCrLf
    If Nereden = "Makro1" Then 
	    sql = sql & "WHERE 1=0 " & vbCrLf
		Set PERSONELLISTESISQL = Doc.RunSQLQuery("PERSONELLISTESI_SQL", sql)
        Exit Sub
    End If
	sql = sql & " WHERE 1=1 " & vbCrLf
	If Trim(ZUPAYARE.TCKIMLIKNO) <> "" Then sql = sql & "  AND LTRIM(RTRIM(CAST(v.TCKIMLIKNO AS varchar))) = '"& Trim(ZUPAYARE.TCKIMLIKNO) &"' " & vbCrLf
	sql = sql & "ORDER BY v.AD_SOYAD ASC;" & vbCrLf
	Set PERSONELLISTESISQLDOLU = Doc.RunSQLQuery("PERSONELLISTESI_SQL_DOLU", sql)
	Set PERSONELLISTESISQL = Doc.GetTableObject("PERSONELLISTESI_SQL")
	PERSONELLISTESISQL.Empty
	If PERSONELLISTESISQLDOLU.GetRecCount = 0 Then
        Msgbox "Kayıt Bulunamadı...(msg:858)"
	Exit Sub
	End If
	PERSONELLISTESISQL.CopyTable(PERSONELLISTESISQLDOLU)
	Set PERSONELLISTESISQLDOLU = Nothing 
	PERSONELLISTESISQL.SetCurrentRow 1	
	Set MTABLEG = Doc.GetTableObject("MTABLEGENEL")
	MTABLEG.ToplamKayitSayisi = PERSONELLISTESISQL.GetRecCount
End Sub
'-------------------------------------------------------------------------------------------------------------
Sub cmd_terminal_listele
	SQL = "SELECT TerminalID, TerminalYonu FROM dbo.PDKS_HAMDATA_CACHE "
	SQL = SQL & " GROUP BY TerminalID, TerminalYonu "
	SQL = SQL & " ORDER BY TerminalID "
	Set TERMINALSQL = Doc.RunSQLQuery("TERMINAL_SQL", SQL)
	If TERMINALSQL.GetRecCount = 0 Then
		MsgBox "Kayıt Bulunamadı...(msg:111)"
		Exit Sub
	End If
	Set MTABLET = Doc.GetTableObject("MAKROTABLET")
	MTABLET.Empty
	For i = 1 To TERMINALSQL.GetRecCount
		SatirNo = MTABLET.AddRow
		MTABLET.SetCurrentRow SatirNo
		MTABLET.TerminalID = TERMINALSQL.TerminalID(i)
		MTABLET.TerminalYonu = TERMINALSQL.TerminalYonu(i)
	Next
	MTABLET.SetCurrentRow 1
End Sub
'------------------------------------
Sub cmd_terminal_ekle
	Set MTABLET = Doc.GetTableObject("MAKROTABLET")
	Set ZUPAYART = Doc.GetTableObject("ZU_P_AYART")
	If Trim(MTABLET.TerminalID) = "" Then
		msgbox "Terminal ID Bulunamadı.."
		Exit Sub
	End If
	Set ZUPAYARTSTACK = Doc.Select2("sfsdfs", "ZU_P_AYART", "TerminalID='"& MTABLET.TerminalID &"' ", "", -1)
	If ZUPAYARTSTACK.GetRecCount > 0 Then
		msgbox "Daha Önce Eklenmiş."
		Exit Sub
	End If
	SatirNo = ZUPAYART.AddRow
	ZUPAYART.SetCurrentRow SatirNo
	ZUPAYART.TerminalID = MTABLET.TerminalID
	ZUPAYART.TerminalYonu = MTABLET.TerminalYonu
	ZUPAYART.SetCurrentRow 1
End Sub
'------------------------------------
Sub cmd_terminal_cikar
	Set MTABLET = Doc.GetTableObject("MAKROTABLET")
	Set ZUPAYART = Doc.GetTableObject("ZU_P_AYART")
	If Trim(ZUPAYART.TerminalID) = "" Then
		msgbox "Terminal ID Bulunamadı.."
		Exit Sub
	End If
	ZUPAYART.DeleteRow(ZUPAYART.GetCurrentRow) 
	ZUPAYART.SetCurrentRow 1
End Sub
'------------------------------------------------
Sub PDKS_Dashboard_sql(Nereden)
	Set KRT = Doc.GetTableObject("KRITERLER")
	Set KRT2 = Doc.GetTableObject("KRITERLER2")
	KontrolDk = KRT2.HAREKET_DK
	'1) Şu anda içeride/dışarıda olan kişi sayıları
	sql = "SELECT Durum, COUNT(*) AS PersonelSayisi" & vbCrLf
	sql = sql & "FROM (" & vbCrLf
	sql = sql & "    SELECT" & vbCrLf
	sql = sql & "        p.SicilNo AS SicilID," & vbCrLf
	sql = sql & "        CASE" & vbCrLf
	sql = sql & "            WHEN EXISTS (SELECT 1 FROM dbo.vw_PDKS_Cikis_Terminalleri c WHERE CAST(p.TerminalID AS varchar(10)) = c.TerminalID) THEN 'DISARIDA'" & vbCrLf
	sql = sql & "            WHEN EXISTS (SELECT 1 FROM dbo.vw_PDKS_Giris_Terminalleri g WHERE CAST(p.TerminalID AS varchar(10)) = g.TerminalID) THEN 'ICERDE'" & vbCrLf
	sql = sql & "            ELSE 'BILINMIYOR'" & vbCrLf
	sql = sql & "        END AS Durum," & vbCrLf
	sql = sql & "        ROW_NUMBER() OVER (" & vbCrLf
	sql = sql & "            PARTITION BY p.SicilNo" & vbCrLf
	sql = sql & "            ORDER BY p.EventTimeDt DESC" & vbCrLf
	sql = sql & "        ) AS rn" & vbCrLf
	sql = sql & "    FROM dbo.PDKS_HAMDATA_CACHE p WITH (NOLOCK)" & vbCrLf
	sql = sql & "    INNER JOIN dbo.VW_PERSM0_PDKS v ON LTRIM(RTRIM(CAST(p.SicilNo AS varchar))) = v.TCKIMLIKNO_PDKS" & vbCrLf
	sql = sql & "    WHERE 1=1 " & vbCrLf
	sql = sql & "    AND CAST(p.EventTimeDt AS date) = '"& Doc.Bugun &"' " & vbCrLf
	sql = sql & ") x" & vbCrLf
	sql = sql & "WHERE x.rn = 1" & vbCrLf
	sql = sql & "GROUP BY x.Durum" & vbCrLf
	'2) Son X dakikadaki olay listesi (canlı akış)
	sql2 = "SELECT  " & vbCrLf
	sql2 = sql2 & "    p.EventTimeDt, " & vbCrLf
	sql2 = sql2 & "    CAST(LEFT(CONVERT(char(8), p.EventTimeDt, 108), 5) AS varchar(5)) AS HareketSaati, " & vbCrLf
	sql2 = sql2 & "    p.PersonelAdi, " & vbCrLf
	sql2 = sql2 & "    p.PersonelSoyadi, " & vbCrLf
	sql2 = sql2 & "    p.Bolum, " & vbCrLf
	sql2 = sql2 & "    p.TerminalID, " & vbCrLf
	sql2 = sql2 & "    p.TerminalYonu, " & vbCrLf
	sql2 = sql2 & "    CASE " & vbCrLf
	sql2 = sql2 & "        WHEN cikis.TerminalID IS NOT NULL THEN 'DISARIDA' " & vbCrLf
	sql2 = sql2 & "        WHEN giris.TerminalID IS NOT NULL THEN 'ICERDE' " & vbCrLf
	sql2 = sql2 & "        ELSE 'BILINMIYOR' " & vbCrLf
	sql2 = sql2 & "    END AS Durum " & vbCrLf
	sql2 = sql2 & "    FROM dbo.PDKS_HAMDATA_CACHE p WITH (NOLOCK) " & vbCrLf
	sql2 = sql2 & "    INNER JOIN dbo.VW_PERSM0_PDKS v ON LTRIM(RTRIM(CAST(p.SicilNo AS varchar))) = v.TCKIMLIKNO_PDKS " & vbCrLf
	sql2 = sql2 & "    LEFT JOIN dbo.vw_PDKS_Giris_Terminalleri giris ON CAST(p.TerminalID AS varchar(10)) = giris.TerminalID " & vbCrLf
	sql2 = sql2 & "    LEFT JOIN dbo.vw_PDKS_Cikis_Terminalleri cikis ON CAST(p.TerminalID AS varchar(10)) = cikis.TerminalID " & vbCrLf
	sql2 = sql2 & "    WHERE EXISTS (SELECT 1 FROM dbo.vw_PDKS_Tum_Terminaller t WHERE CAST(t.TerminalID AS varchar(10)) = CAST(p.TerminalID AS varchar(10))) " & vbCrLf
	'3) Terminal bazlı günlük toplamlar
	sql3 = "SELECT " & vbCrLf
	sql3 = sql3 & "    p.TerminalID, " & vbCrLf
	sql3 = sql3 & "    p.TerminalYonu, " & vbCrLf
	sql3 = sql3 & "    CASE " & vbCrLf
	sql3 = sql3 & "        WHEN cikis.TerminalID IS NOT NULL THEN 'CIKIS' " & vbCrLf
	sql3 = sql3 & "        WHEN giris.TerminalID IS NOT NULL THEN 'GIRIS' " & vbCrLf
	sql3 = sql3 & "        ELSE 'BILINMIYOR' " & vbCrLf
	sql3 = sql3 & "    END AS TerminalTipi, " & vbCrLf
	sql3 = sql3 & "    COUNT(*) AS OlaySayisi " & vbCrLf
	sql3 = sql3 & "    FROM dbo.PDKS_HAMDATA_CACHE p WITH (NOLOCK) " & vbCrLf
	sql3 = sql3 & "    INNER JOIN dbo.VW_PERSM0_PDKS v ON LTRIM(RTRIM(CAST(p.SicilNo AS varchar))) = v.TCKIMLIKNO_PDKS " & vbCrLf
	sql3 = sql3 & "    LEFT JOIN dbo.vw_PDKS_Giris_Terminalleri giris ON CAST(p.TerminalID AS varchar(10)) = giris.TerminalID " & vbCrLf
	sql3 = sql3 & "    LEFT JOIN dbo.vw_PDKS_Cikis_Terminalleri cikis ON CAST(p.TerminalID AS varchar(10)) = cikis.TerminalID " & vbCrLf
	sql3 = sql3 & "    WHERE EXISTS (SELECT 1 FROM dbo.vw_PDKS_Tum_Terminaller t WHERE CAST(t.TerminalID AS varchar(10)) = CAST(p.TerminalID AS varchar(10))) " & vbCrLf
	If Nereden = "Makro1" Then 
		'1- Şu anda içeride/dışarıda olan kişi sayıları
		Set DASHBOARD1SQL = Doc.RunSQLQuery("DASHBOARD1_SQL", sql)
		'2-Son X dakikadaki olay listesi (canlı akış)
		If KontrolDk = 0 Then
			KontrolDk = 5
		End If
		sql2 = sql2 & " AND p.EventTimeDt >= DATEADD(minute, -" & KontrolDk & ", GETDATE()) " & vbCrLf
		sql2 = sql2 & " ORDER BY p.EventTimeDt DESC; " & vbCrLf
		Set DASHBOARD2SQL = Doc.RunSQLQuery("DASHBOARD2_SQL", sql2)
		'3) Terminal bazlı günlük toplamlar
		sql3 = sql3 & "    AND CAST(p.EventTimeDt AS date) = '"& Doc.Bugun &"' " & vbCrLf
		sql3 = sql3 & "    GROUP BY p.TerminalID, p.TerminalYonu, " & vbCrLf
		sql3 = sql3 & "        CASE " & vbCrLf
		sql3 = sql3 & "            WHEN cikis.TerminalID IS NOT NULL THEN 'CIKIS' " & vbCrLf
		sql3 = sql3 & "            WHEN giris.TerminalID IS NOT NULL THEN 'GIRIS' " & vbCrLf
		sql3 = sql3 & "            ELSE 'BILINMIYOR' " & vbCrLf
		sql3 = sql3 & "        END " & vbCrLf
		sql3 = sql3 & "    ORDER BY p.TerminalID; " & vbCrLf
		Set DASHBOARD3SQL = Doc.RunSQLQuery("DASHBOARD3_SQL", sql3)
	    Exit Sub
	End If
	'1-Şu anda içeride/dışarıda olan kişi sayıları
	Set DASHBOARD1SQLDOLU = Doc.RunSQLQuery("DASHBOARD1_SQL_DOLU", sql)	
	Set DASHBOARD1SQL = Doc.GetTableObject("DASHBOARD1_SQL")
	DASHBOARD1SQL.Empty
	If DASHBOARD1SQLDOLU.GetRecCount > 0 Then
		DASHBOARD1SQL.CopyTable(DASHBOARD1SQLDOLU)
		Set DASHBOARD1SQLDOLU = Nothing 
		DASHBOARD1SQL.SetCurrentRow 1
	End If
	'-------------------------------------------------
	'2- Son X dakikadaki giriş çıkışlar
	If KontrolDk = 0 Then
		KontrolDk = 10
	End If
	sql2 = sql2 & " AND p.EventTimeDt >= DATEADD(minute, -" & KontrolDk & ", GETDATE()) " & vbCrLf
	sql2 = sql2 & " ORDER BY p.EventTimeDt DESC; " & vbCrLf
	Set DASHBOARD2SQLDOLU = Doc.RunSQLQuery("DASHBOARD2_SQL_DOLU", sql2)	
	Set DASHBOARD2SQL = Doc.GetTableObject("DASHBOARD2_SQL")
	DASHBOARD2SQL.Empty
	If DASHBOARD2SQLDOLU.GetRecCount > 0 Then
		DASHBOARD2SQL.CopyTable(DASHBOARD2SQLDOLU)
		Set DASHBOARD2SQLDOLU = Nothing 
		DASHBOARD2SQL.SetCurrentRow 1
	End If
	'-------------------------------------------------
	'3- Terminal bazlı günlük toplamlar
	sql3 = sql3 & "    AND CAST(p.EventTimeDt AS date) = '"& Doc.Bugun &"' " & vbCrLf
	sql3 = sql3 & "    GROUP BY p.TerminalID, p.TerminalYonu, " & vbCrLf
	sql3 = sql3 & "        CASE " & vbCrLf
	sql3 = sql3 & "            WHEN cikis.TerminalID IS NOT NULL THEN 'CIKIS' " & vbCrLf
	sql3 = sql3 & "            WHEN giris.TerminalID IS NOT NULL THEN 'GIRIS' " & vbCrLf
	sql3 = sql3 & "            ELSE 'BILINMIYOR' " & vbCrLf
	sql3 = sql3 & "        END " & vbCrLf
	sql3 = sql3 & "    ORDER BY p.TerminalID; " & vbCrLf
	Set DASHBOARD3SQLDOLU = Doc.RunSQLQuery("DASHBOARD3_SQL_DOLU", sql3)	
	Set DASHBOARD3SQL = Doc.GetTableObject("DASHBOARD3_SQL")
	DASHBOARD3SQL.Empty
	If DASHBOARD3SQLDOLU.GetRecCount > 0 Then
		DASHBOARD3SQL.CopyTable(DASHBOARD3SQLDOLU)
		Set DASHBOARD3SQLDOLU = Nothing 
		DASHBOARD3SQL.SetCurrentRow 1
	End If
	Call SonGuncellemeZamani("PDKS_Dashboard_sql")
End Sub
Sub Gunluk_Yoklama_Raporu(Nereden)
	Set KRT = Doc.GetTableObject("KRITERLER")
	Bugun = Doc.Bugun
	' Tarih kriteri: KRTTARIH1 varsa onu kullan, yoksa bugünü kullan
	If Trim(KRT.KRTTARIH1) <> "" Then
		RaporTarihi = Trim(KRT.KRTTARIH1)
	Else
		RaporTarihi = Bugun
	End If
	sql = ""
	sql = sql & "SELECT " & vbCrLf
	sql = sql & "    Kategori," & vbCrLf
	sql = sql & "    SicilID," & vbCrLf
	sql = sql & "    PersonelAdi," & vbCrLf
	sql = sql & "    PersonelSoyadi," & vbCrLf
	sql = sql & "    IlkGiris," & vbCrLf
	sql = sql & "    GecikmeDakika," & vbCrLf
	sql = sql & "    STIME," & vbCrLf
	sql = sql & "    ETIME," & vbCrLf
	sql = sql & "    GIRIS_TOL_DK," & vbCrLf
	sql = sql & "    CIKIS_TOL_DK," & vbCrLf
	sql = sql & "    HESAPSABLONU" & vbCrLf
	sql = sql & "FROM (" & vbCrLf
	sql = sql & "    SELECT " & vbCrLf
	sql = sql & "        'TOLERANS_ASAN_GEC_GELENLER' AS Kategori," & vbCrLf
	sql = sql & "        p.SicilNo AS SicilID," & vbCrLf
	sql = sql & "        MAX(v.AD) AS PersonelAdi," & vbCrLf
	sql = sql & "        MAX(v.SOYAD) AS PersonelSoyadi," & vbCrLf
	sql = sql & "        CAST(LEFT(CONVERT(char(8), MIN(g.EventTimeDt), 108), 5) AS varchar(5)) AS IlkGiris," & vbCrLf
	sql = sql & "        DATEDIFF(minute, CAST(CONVERT(varchar(10), CAST('" & RaporTarihi & "' AS date), 120) + ' ' + v.STIME AS datetime), MIN(g.EventTimeDt)) AS GecikmeDakika," & vbCrLf
	sql = sql & "        MAX(v.STIME) AS STIME," & vbCrLf
	sql = sql & "        MAX(v.ETIME) AS ETIME," & vbCrLf
	sql = sql & "        MAX(v.GIRIS_TOL_DK) AS GIRIS_TOL_DK," & vbCrLf
	sql = sql & "        MAX(v.CIKIS_TOL_DK) AS CIKIS_TOL_DK," & vbCrLf
	sql = sql & "        MAX(v.HESAPSABLONU) AS HESAPSABLONU" & vbCrLf
	sql = sql & "    FROM dbo.PDKS_HAMDATA_CACHE p WITH (NOLOCK)" & vbCrLf
	sql = sql & "    INNER JOIN dbo.VW_PERSM0_PDKS v ON LTRIM(RTRIM(CAST(p.SicilNo AS varchar))) = v.TCKIMLIKNO_PDKS" & vbCrLf
	sql = sql & "    INNER JOIN (" & vbCrLf
	sql = sql & "        SELECT " & vbCrLf
	sql = sql & "            p.SicilNo AS SicilID," & vbCrLf
	sql = sql & "            CAST(p.EventTimeDt AS date) AS Gun," & vbCrLf
	sql = sql & "            MIN(p.EventTimeDt) AS EventTimeDt" & vbCrLf
	sql = sql & "        FROM dbo.PDKS_HAMDATA_CACHE p WITH (NOLOCK)" & vbCrLf
	sql = sql & "        INNER JOIN dbo.VW_PERSM0_PDKS v ON LTRIM(RTRIM(CAST(p.SicilNo AS varchar))) = v.TCKIMLIKNO_PDKS" & vbCrLf
	sql = sql & "        INNER JOIN dbo.vw_PDKS_Giris_Terminalleri giris ON CAST(p.TerminalID AS varchar(10)) = giris.TerminalID " & vbCrLf
	sql = sql & "        WHERE CAST(p.EventTimeDt AS date) = '" & RaporTarihi & "'" & vbCrLf
	sql = sql & "        GROUP BY p.SicilNo, CAST(p.EventTimeDt AS date)" & vbCrLf
	sql = sql & "    ) g ON LTRIM(RTRIM(CAST(p.SicilNo AS varchar))) = g.SicilID AND CAST(p.EventTimeDt AS date) = g.Gun" & vbCrLf
	sql = sql & "    INNER JOIN dbo.vw_PDKS_Giris_Terminalleri giris ON CAST(p.TerminalID AS varchar(10)) = giris.TerminalID " & vbCrLf
	sql = sql & "    WHERE CAST(p.EventTimeDt AS date) = '" & RaporTarihi & "'" & vbCrLf
	sql = sql & "    GROUP BY p.SicilNo, v.STIME, v.GIRIS_TOL_DK" & vbCrLf
	sql = sql & "    HAVING MAX(v.GIRIS_TOL_DK) IS NOT NULL" & vbCrLf
	sql = sql & "      AND DATEDIFF(minute, CAST(CONVERT(varchar(10), CAST('" & RaporTarihi & "' AS date), 120) + ' ' + v.STIME AS datetime), MIN(g.EventTimeDt)) > MAX(v.GIRIS_TOL_DK)" & vbCrLf
	sql = sql & "    UNION ALL" & vbCrLf
	sql = sql & "    SELECT " & vbCrLf
	sql = sql & "        'ERKEN_CIKANLAR' AS Kategori," & vbCrLf
	sql = sql & "        p.SicilNo AS SicilID," & vbCrLf
	sql = sql & "        MAX(v.AD) AS PersonelAdi," & vbCrLf
	sql = sql & "        MAX(v.SOYAD) AS PersonelSoyadi," & vbCrLf
	sql = sql & "        CAST(LEFT(CONVERT(char(8), MAX(c.SonCikis), 108), 5) AS varchar(5)) AS IlkGiris," & vbCrLf
	sql = sql & "        DATEDIFF(minute, MAX(c.SonCikis), DATEADD(minute, -MAX(v.CIKIS_TOL_DK), CAST(CONVERT(varchar(10), CAST('" & RaporTarihi & "' AS date), 120) + ' ' + v.ETIME AS datetime))) AS GecikmeDakika," & vbCrLf
	sql = sql & "        MAX(v.STIME) AS STIME," & vbCrLf
	sql = sql & "        MAX(v.ETIME) AS ETIME," & vbCrLf
	sql = sql & "        MAX(v.GIRIS_TOL_DK) AS GIRIS_TOL_DK," & vbCrLf
	sql = sql & "        MAX(v.CIKIS_TOL_DK) AS CIKIS_TOL_DK," & vbCrLf
	sql = sql & "        MAX(v.HESAPSABLONU) AS HESAPSABLONU" & vbCrLf
	sql = sql & "    FROM dbo.PDKS_HAMDATA_CACHE p WITH (NOLOCK)" & vbCrLf
	sql = sql & "    INNER JOIN dbo.VW_PERSM0_PDKS v ON LTRIM(RTRIM(CAST(p.SicilNo AS varchar))) = v.TCKIMLIKNO_PDKS" & vbCrLf
	sql = sql & "    INNER JOIN (" & vbCrLf
	sql = sql & "        SELECT " & vbCrLf
	sql = sql & "            p.SicilNo AS SicilID," & vbCrLf
	sql = sql & "            CAST(p.EventTimeDt AS date) AS Gun," & vbCrLf
	sql = sql & "            MAX(p.EventTimeDt) AS SonCikis" & vbCrLf
	sql = sql & "        FROM dbo.PDKS_HAMDATA_CACHE p WITH (NOLOCK)" & vbCrLf
	sql = sql & "        INNER JOIN dbo.VW_PERSM0_PDKS v ON LTRIM(RTRIM(CAST(p.SicilNo AS varchar))) = v.TCKIMLIKNO_PDKS" & vbCrLf
	sql = sql & "        INNER JOIN dbo.vw_PDKS_Cikis_Terminalleri cikis ON CAST(p.TerminalID AS varchar(10)) = cikis.TerminalID " & vbCrLf
	sql = sql & "        WHERE CAST(p.EventTimeDt AS date) = '" & RaporTarihi & "'" & vbCrLf
	sql = sql & "        GROUP BY p.SicilNo, CAST(p.EventTimeDt AS date)" & vbCrLf
	sql = sql & "    ) c ON LTRIM(RTRIM(CAST(p.SicilNo AS varchar))) = c.SicilID AND CAST(p.EventTimeDt AS date) = c.Gun" & vbCrLf
	sql = sql & "    INNER JOIN dbo.vw_PDKS_Cikis_Terminalleri cikis ON CAST(p.TerminalID AS varchar(10)) = cikis.TerminalID " & vbCrLf
	sql = sql & "    WHERE CAST(p.EventTimeDt AS date) = '" & RaporTarihi & "'" & vbCrLf
	sql = sql & "    GROUP BY p.SicilNo, v.ETIME, v.CIKIS_TOL_DK" & vbCrLf
	sql = sql & "    HAVING MAX(v.CIKIS_TOL_DK) IS NOT NULL" & vbCrLf
	sql = sql & "      AND MAX(c.SonCikis) < DATEADD(minute, -MAX(v.CIKIS_TOL_DK), CAST(CONVERT(varchar(10), CAST('" & RaporTarihi & "' AS date), 120) + ' ' + v.ETIME AS datetime))" & vbCrLf
	sql = sql & "    UNION ALL" & vbCrLf
	sql = sql & "    SELECT " & vbCrLf
	sql = sql & "        'GIRIS_YAPMAYANLAR' AS Kategori," & vbCrLf
	sql = sql & "        v.TCKIMLIKNO_PDKS AS SicilID," & vbCrLf
	sql = sql & "        v.AD AS PersonelAdi," & vbCrLf
	sql = sql & "        v.SOYAD AS PersonelSoyadi," & vbCrLf
	sql = sql & "        CAST(LEFT(CONVERT(char(8), MAX(c.SonCikis), 108), 5) AS varchar(5)) AS IlkGiris," & vbCrLf
	sql = sql & "        NULL AS GecikmeDakika," & vbCrLf
	sql = sql & "        v.STIME AS STIME," & vbCrLf
	sql = sql & "        v.ETIME AS ETIME," & vbCrLf
	sql = sql & "        v.GIRIS_TOL_DK AS GIRIS_TOL_DK," & vbCrLf
	sql = sql & "        v.CIKIS_TOL_DK AS CIKIS_TOL_DK," & vbCrLf
	sql = sql & "        v.HESAPSABLONU AS HESAPSABLONU" & vbCrLf
	sql = sql & "    FROM dbo.VW_PERSM0_PDKS v WITH (NOLOCK)" & vbCrLf
	sql = sql & "    LEFT JOIN (" & vbCrLf
	sql = sql & "        SELECT " & vbCrLf
	sql = sql & "            p.SicilNo AS SicilID," & vbCrLf
	sql = sql & "            MAX(p.EventTimeDt) AS SonCikis" & vbCrLf
	sql = sql & "        FROM dbo.PDKS_HAMDATA_CACHE p WITH (NOLOCK)" & vbCrLf
	sql = sql & "        INNER JOIN dbo.vw_PDKS_Cikis_Terminalleri cikis ON CAST(p.TerminalID AS varchar(10)) = cikis.TerminalID " & vbCrLf
	sql = sql & "        WHERE CAST(p.EventTimeDt AS date) = '" & RaporTarihi & "'" & vbCrLf
	sql = sql & "        GROUP BY p.SicilNo" & vbCrLf
	sql = sql & "    ) c ON LTRIM(RTRIM(CAST(c.SicilID AS varchar))) = v.TCKIMLIKNO_PDKS COLLATE Turkish_CI_AS" & vbCrLf
	sql = sql & "    WHERE NOT EXISTS (" & vbCrLf
	sql = sql & "        SELECT 1" & vbCrLf
	sql = sql & "        FROM dbo.PDKS_HAMDATA_CACHE p WITH (NOLOCK)" & vbCrLf
	sql = sql & "        INNER JOIN dbo.vw_PDKS_Giris_Terminalleri giris ON CAST(p.TerminalID AS varchar(10)) = giris.TerminalID " & vbCrLf
	sql = sql & "        WHERE CAST(p.EventTimeDt AS date) = '" & RaporTarihi & "'" & vbCrLf
	sql = sql & "          AND LTRIM(RTRIM(CAST(p.SicilNo AS varchar))) = v.TCKIMLIKNO_PDKS COLLATE Turkish_CI_AS" & vbCrLf
	sql = sql & "    )" & vbCrLf
	sql = sql & "      AND c.SonCikis IS NOT NULL" & vbCrLf
	sql = sql & "    GROUP BY v.TCKIMLIKNO_PDKS, v.AD, v.SOYAD, v.STIME, v.ETIME, v.GIRIS_TOL_DK, v.CIKIS_TOL_DK, v.HESAPSABLONU" & vbCrLf
	sql = sql & "    UNION ALL" & vbCrLf
	sql = sql & "    SELECT " & vbCrLf
	sql = sql & "        'CIKIS_YAPMAYANLAR' AS Kategori," & vbCrLf
	sql = sql & "        g.SicilID," & vbCrLf
	sql = sql & "        MAX(v.AD) AS PersonelAdi," & vbCrLf
	sql = sql & "        MAX(v.SOYAD) AS PersonelSoyadi," & vbCrLf
	sql = sql & "        CAST(LEFT(CONVERT(char(8), MIN(g.EventTimeDt), 108), 5) AS varchar(5)) AS IlkGiris," & vbCrLf
	sql = sql & "        NULL AS GecikmeDakika," & vbCrLf
	sql = sql & "        MAX(v.STIME) AS STIME," & vbCrLf
	sql = sql & "        MAX(v.ETIME) AS ETIME," & vbCrLf
	sql = sql & "        MAX(v.GIRIS_TOL_DK) AS GIRIS_TOL_DK," & vbCrLf
	sql = sql & "        MAX(v.CIKIS_TOL_DK) AS CIKIS_TOL_DK," & vbCrLf
	sql = sql & "        MAX(v.HESAPSABLONU) AS HESAPSABLONU" & vbCrLf
	sql = sql & "    FROM (" & vbCrLf
	sql = sql & "        SELECT " & vbCrLf
	sql = sql & "            p.SicilNo AS SicilID," & vbCrLf
	sql = sql & "            CAST(p.EventTimeDt AS date) AS Gun," & vbCrLf
	sql = sql & "            MIN(p.EventTimeDt) AS EventTimeDt" & vbCrLf
	sql = sql & "        FROM dbo.PDKS_HAMDATA_CACHE p WITH (NOLOCK)" & vbCrLf
	sql = sql & "        INNER JOIN dbo.VW_PERSM0_PDKS v ON LTRIM(RTRIM(CAST(p.SicilNo AS varchar))) = v.TCKIMLIKNO_PDKS" & vbCrLf
	sql = sql & "        INNER JOIN dbo.vw_PDKS_Giris_Terminalleri giris ON CAST(p.TerminalID AS varchar(10)) = giris.TerminalID " & vbCrLf
	sql = sql & "        WHERE CAST(p.EventTimeDt AS date) = '" & RaporTarihi & "'" & vbCrLf
	sql = sql & "        GROUP BY p.SicilNo, CAST(p.EventTimeDt AS date)" & vbCrLf
	sql = sql & "    ) g" & vbCrLf
	sql = sql & "    INNER JOIN dbo.VW_PERSM0_PDKS v ON g.SicilID = v.TCKIMLIKNO_PDKS" & vbCrLf
	sql = sql & "    LEFT JOIN (" & vbCrLf
	sql = sql & "        SELECT " & vbCrLf
	sql = sql & "            p.SicilNo AS SicilID," & vbCrLf
	sql = sql & "            CAST(p.EventTimeDt AS date) AS Gun" & vbCrLf
	sql = sql & "        FROM dbo.PDKS_HAMDATA_CACHE p WITH (NOLOCK)" & vbCrLf
	sql = sql & "        INNER JOIN dbo.vw_PDKS_Cikis_Terminalleri cikis ON CAST(p.TerminalID AS varchar(10)) = cikis.TerminalID " & vbCrLf
	sql = sql & "        WHERE CAST(p.EventTimeDt AS date) = '" & RaporTarihi & "'" & vbCrLf
	sql = sql & "        GROUP BY p.SicilNo, CAST(p.EventTimeDt AS date)" & vbCrLf
	sql = sql & "    ) c ON g.SicilID = c.SicilID AND g.Gun = c.Gun" & vbCrLf
	sql = sql & "    WHERE c.SicilID IS NULL" & vbCrLf
	sql = sql & "    GROUP BY g.SicilID" & vbCrLf
	sql = sql & "    UNION ALL" & vbCrLf
	sql = sql & "    SELECT " & vbCrLf
	sql = sql & "        'VARDIYA_DISI_KART_BASANLAR' AS Kategori," & vbCrLf
	sql = sql & "        p.SicilNo AS SicilID," & vbCrLf
	sql = sql & "        MAX(v.AD) AS PersonelAdi," & vbCrLf
	sql = sql & "        MAX(v.SOYAD) AS PersonelSoyadi," & vbCrLf
	sql = sql & "        CAST(LEFT(CONVERT(char(8), MIN(p.EventTimeDt), 108), 5) AS varchar(5)) AS IlkGiris," & vbCrLf
	sql = sql & "        CASE " & vbCrLf
	sql = sql & "            WHEN CAST(MIN(p.EventTimeDt) AS time) < CAST(MAX(v.STIME) AS time) " & vbCrLf
	sql = sql & "            THEN DATEDIFF(minute, CAST(MIN(p.EventTimeDt) AS time), CAST(MAX(v.STIME) AS time)) * -1 " & vbCrLf
	sql = sql & "            WHEN CAST(MIN(p.EventTimeDt) AS time) >= CAST(MAX(v.ETIME) AS time) " & vbCrLf
	sql = sql & "            THEN DATEDIFF(minute, CAST(MAX(v.ETIME) AS time), CAST(MIN(p.EventTimeDt) AS time)) " & vbCrLf
	sql = sql & "            ELSE NULL " & vbCrLf
	sql = sql & "        END AS GecikmeDakika," & vbCrLf
	sql = sql & "        MAX(v.STIME) AS STIME," & vbCrLf
	sql = sql & "        MAX(v.ETIME) AS ETIME," & vbCrLf
	sql = sql & "        MAX(v.GIRIS_TOL_DK) AS GIRIS_TOL_DK," & vbCrLf
	sql = sql & "        MAX(v.CIKIS_TOL_DK) AS CIKIS_TOL_DK," & vbCrLf
	sql = sql & "        MAX(v.HESAPSABLONU) AS HESAPSABLONU" & vbCrLf
	sql = sql & "    FROM dbo.PDKS_HAMDATA_CACHE p WITH (NOLOCK)" & vbCrLf
	sql = sql & "    INNER JOIN dbo.VW_PERSM0_PDKS v ON LTRIM(RTRIM(CAST(p.SicilNo AS varchar))) = v.TCKIMLIKNO_PDKS" & vbCrLf
	sql = sql & "    WHERE CAST(p.EventTimeDt AS date) = '" & RaporTarihi & "'" & vbCrLf
	sql = sql & "      AND (" & vbCrLf
	sql = sql & "          (EXISTS (SELECT 1 FROM dbo.vw_PDKS_Giris_Terminalleri g WHERE CAST(p.TerminalID AS varchar(10)) = g.TerminalID) AND (CAST(p.EventTimeDt AS time) < CAST(v.STIME AS time) OR CAST(p.EventTimeDt AS time) > CAST(v.ETIME AS time)))" & vbCrLf
	sql = sql & "          OR" & vbCrLf
	sql = sql & "          (EXISTS (SELECT 1 FROM dbo.vw_PDKS_Cikis_Terminalleri c WHERE CAST(p.TerminalID AS varchar(10)) = c.TerminalID) AND (CAST(p.EventTimeDt AS time) < CAST(v.STIME AS time) OR CAST(p.EventTimeDt AS time) > CAST(v.ETIME AS time)))" & vbCrLf
	sql = sql & "      )" & vbCrLf
	sql = sql & "      AND CAST(p.EventTimeDt AS time) <> CAST(v.STIME AS time)" & vbCrLf
	sql = sql & "      AND CAST(p.EventTimeDt AS time) <> CAST(v.ETIME AS time)" & vbCrLf
	sql = sql & "    GROUP BY p.SicilNo, CAST(LEFT(CONVERT(char(8), p.EventTimeDt, 108), 5) AS varchar(5)), v.STIME, v.ETIME" & vbCrLf
	sql = sql & "    HAVING " & vbCrLf
	sql = sql & "        CASE " & vbCrLf
	sql = sql & "            WHEN CAST(MIN(p.EventTimeDt) AS time) < CAST(MAX(v.STIME) AS time) " & vbCrLf
	sql = sql & "            THEN DATEDIFF(minute, CAST(MIN(p.EventTimeDt) AS time), CAST(MAX(v.STIME) AS time)) * -1 " & vbCrLf
	sql = sql & "            WHEN CAST(MIN(p.EventTimeDt) AS time) >= CAST(MAX(v.ETIME) AS time) " & vbCrLf
	sql = sql & "            THEN DATEDIFF(minute, CAST(MAX(v.ETIME) AS time), CAST(MIN(p.EventTimeDt) AS time)) " & vbCrLf
	sql = sql & "            ELSE NULL " & vbCrLf
	sql = sql & "        END <> 0" & vbCrLf
	sql = sql & ") AS Sonuc " & vbCrLf
	If Nereden = "Makro1" Then 
		sql = sql & " WHERE 1=0 " & vbCrLf
		sql = sql & "ORDER BY Kategori, PersonelAdi, PersonelSoyadi;" 
		Set GUNLUKYOKLAMASQL = Doc.RunSQLQuery("GUNLUKYOKLAMA_SQL", sql)   'TÜMÜ
		Set GUNLUKYOKLAMASQL_GY = Doc.RunSQLQuery("GUNLUKYOKLAMA_SQL_GY", sql)   'GIRIS YAPMAYANLAR
		Set GUNLUKYOKLAMASQL_CY = Doc.RunSQLQuery("GUNLUKYOKLAMA_SQL_CY", sql)   'CIKIS YAPMAYANLAR
		Set GUNLUKYOKLAMASQL_TA = Doc.RunSQLQuery("GUNLUKYOKLAMA_SQL_TA", sql)   'TOLERANS_ASAN_GEC_GELENLER
		Set GUNLUKYOKLAMASQL_EC = Doc.RunSQLQuery("GUNLUKYOKLAMA_SQL_EC", sql)   'ERKEN_CIKANLAR
		Set GUNLUKYOKLAMASQL_VD = Doc.RunSQLQuery("GUNLUKYOKLAMA_SQL_VD", sql)   'VARDIYA_DISI_KART_BASANLAR
        Exit Sub
    End If
	'************************************************
	Set GUNLUKYOKLAMASQLDOLU_GY = Doc.RunSQLQuery("GUNLUKYOKLAMA_SQL_DOLU_GY", sql & " WHERE Kategori = 'GIRIS_YAPMAYANLAR' ORDER BY Kategori, PersonelAdi, PersonelSoyadi;" )
	Set GUNLUKYOKLAMASQL_GY = Doc.GetTableObject("GUNLUKYOKLAMA_SQL_GY")
	GUNLUKYOKLAMASQL_GY.Empty
	GUNLUKYOKLAMASQL_GY.CopyTable(GUNLUKYOKLAMASQLDOLU_GY)
	Set GUNLUKYOKLAMASQLDOLU_GY = Nothing 
	GUNLUKYOKLAMASQL_GY.SetCurrentRow 1	
	'************************************************
	Set GUNLUKYOKLAMASQLDOLU_CY = Doc.RunSQLQuery("GUNLUKYOKLAMA_SQL_DOLU_CY", sql & " WHERE Kategori = 'CIKIS_YAPMAYANLAR' ORDER BY Kategori, PersonelAdi, PersonelSoyadi;" )
	Set GUNLUKYOKLAMASQL_CY = Doc.GetTableObject("GUNLUKYOKLAMA_SQL_CY")
	GUNLUKYOKLAMASQL_CY.Empty
	GUNLUKYOKLAMASQL_CY.CopyTable(GUNLUKYOKLAMASQLDOLU_CY)
	Set GUNLUKYOKLAMASQLDOLU_CY = Nothing 
	GUNLUKYOKLAMASQL_CY.SetCurrentRow 1	
	'************************************************
	Set GUNLUKYOKLAMASQLDOLU_TA = Doc.RunSQLQuery("GUNLUKYOKLAMA_SQL_DOLU_TA", sql & " WHERE Kategori = 'TOLERANS_ASAN_GEC_GELENLER' ORDER BY Kategori, PersonelAdi, PersonelSoyadi;" )
	Set GUNLUKYOKLAMASQL_TA = Doc.GetTableObject("GUNLUKYOKLAMA_SQL_TA")
	GUNLUKYOKLAMASQL_TA.Empty
	GUNLUKYOKLAMASQL_TA.CopyTable(GUNLUKYOKLAMASQLDOLU_TA)
	Set GUNLUKYOKLAMASQLDOLU_TA = Nothing 
	GUNLUKYOKLAMASQL_TA.SetCurrentRow 1	
	'************************************************
	Set GUNLUKYOKLAMASQLDOLU_EC = Doc.RunSQLQuery("GUNLUKYOKLAMA_SQL_DOLU_EC", sql & " WHERE Kategori = 'ERKEN_CIKANLAR' ORDER BY Kategori, PersonelAdi, PersonelSoyadi;" )
	Set GUNLUKYOKLAMASQL_EC = Doc.GetTableObject("GUNLUKYOKLAMA_SQL_EC")
	GUNLUKYOKLAMASQL_EC.Empty
	GUNLUKYOKLAMASQL_EC.CopyTable(GUNLUKYOKLAMASQLDOLU_EC)
	Set GUNLUKYOKLAMASQLDOLU_EC = Nothing 
	GUNLUKYOKLAMASQL_EC.SetCurrentRow 1	
	'************************************************
	Set GUNLUKYOKLAMASQLDOLU_VD = Doc.RunSQLQuery("GUNLUKYOKLAMA_SQL_DOLU_VD", sql & " WHERE Kategori = 'VARDIYA_DISI_KART_BASANLAR' ORDER BY Kategori, PersonelAdi, PersonelSoyadi;" )
	Set GUNLUKYOKLAMASQL_VD = Doc.GetTableObject("GUNLUKYOKLAMA_SQL_VD")
	GUNLUKYOKLAMASQL_VD.Empty
	GUNLUKYOKLAMASQL_VD.CopyTable(GUNLUKYOKLAMASQLDOLU_VD)
	Set GUNLUKYOKLAMASQLDOLU_VD = Nothing 
	GUNLUKYOKLAMASQL_VD.SetCurrentRow 1	
	'************************************************
	Set GUNLUKYOKLAMASQLDOLU = Doc.RunSQLQuery("GUNLUKYOKLAMA_SQL_DOLU", sql & " ORDER BY Kategori, PersonelAdi, PersonelSoyadi;" )
	Set GUNLUKYOKLAMASQL = Doc.GetTableObject("GUNLUKYOKLAMA_SQL")
	GUNLUKYOKLAMASQL.Empty
	GUNLUKYOKLAMASQL.CopyTable(GUNLUKYOKLAMASQLDOLU)
	Set GUNLUKYOKLAMASQLDOLU = Nothing 
	GUNLUKYOKLAMASQL.SetCurrentRow 1	
	'************************************************
	Call SonGuncellemeZamani("Gunluk_Yoklama_Raporu")	
End Sub
'------------------------------------------------
Sub hamdata_listele_sql(Nereden)
	Set KRT = Doc.GetTableObject("KRITERLER")
	sql = " SELECT "
	sql = sql & " *, "
	sql = sql & " CASE DATEPART(WEEKDAY, CAST(EventTimeDt AS date)) "
	sql = sql & "     WHEN 1 THEN 'Pazar' "
	sql = sql & "     WHEN 2 THEN 'Pazartesi' "
	sql = sql & "     WHEN 3 THEN 'Salı' "
	sql = sql & "     WHEN 4 THEN 'Çarşamba' "
	sql = sql & "     WHEN 5 THEN 'Perşembe' "
	sql = sql & "     WHEN 6 THEN 'Cuma' "
	sql = sql & "     WHEN 7 THEN 'Cumartesi' "
	sql = sql & " END AS Gun_Adi "
	sql = sql & " FROM PDKS_HAMDATA_CACHE "
	If Nereden = "Makro1" Then 
		sql = sql & VBCRLF & " WHERE 1=0 "
		Set HAMDATASQL = Doc.RunSQLQuery("HAMDATA_SQL", sql)
		Exit Sub
	End If
	sql = sql & " WHERE 1=1 "
	If Trim(KRT.SicilNo) <> "" Then sql = sql & " AND SicilNo = '"& Trim(KRT.SicilNo) &"'  "
	If Trim(KRT.Yil) <> "" Then sql = sql & " AND Yil = '"& Trim(KRT.Yil) &"'  "
	If Trim(KRT.Ay) <> "" Then sql = sql & " AND Ay = '"& KRT.Ay &"'  "
	If Trim(KRT.KRTTARIH1) <> "" Then sql = sql & " AND Tarih >= '"& KRT.KRTTARIH1 &"'  "
	If Trim(KRT.KRTTARIH2) <> "" Then sql = sql & " AND Tarih <= '"& KRT.KRTTARIH2 &"'  "
	sql = sql & " ORDER BY SicilNo, TerminalID, EventTimeDt  "
	Set HAMDATADOLUSQL = Doc.RunSQLQuery("HAMDATA_DOLU_SQL", sql)	
	Set HAMDATASQL = Doc.GetTableObject("HAMDATA_SQL")
	HAMDATASQL.Empty
	If HAMDATADOLUSQL.GetRecCount = 0 Then
		Msgbox "Kayıt Bulunamadı...(msg:888)"
        Exit Sub
    End If
	HAMDATASQL.CopyTable(HAMDATADOLUSQL)
	Set HAMDATADOLUSQL = Nothing 
	HAMDATASQL.SetCurrentRow 1	
	Call SonGuncellemeZamani("hamdata_listele_sql")	
End Sub
