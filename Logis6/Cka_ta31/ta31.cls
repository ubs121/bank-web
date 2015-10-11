VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "ta31"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit
Option Compare Text

Private d3 As New d3
Private pick As New pick

Private g_trans_info_array() As String


Public Function ta3131(logentry As String, nrec() As String, parms As String) As String
' TA3131 PRINT MONTHLY BUILDING STATISTICS REPORT
Dim statsby As String, Fd As Integer
Dim Td As Integer, Fees As String, Fcnt As Integer, File_Desc, I As Integer, Fc As String, px As String, Types As String, maxt
Dim Stats As String, Assess As String, Ward As String, typ As String
Dim value As Currency, Feevalue As Currency, Pos As Integer, pos2 As Integer, Maxw As Integer, Gtot As String, Stot As String
Dim Stot2 As String, K As Integer, desc As String
Dim J As Integer
Dim kk As Integer, sentence As String, total_items As Long, plan_id As String
Dim plans_rec As String, Attr As Integer
Dim rderr As Integer, temp As String, mylist() As String, pick_cnt As Long, cols As Integer
Dim database As String, temp2 As String, tempcur As Currency, Mm As Integer, ncols As Integer
'???fees have to be int(+.5)
     database = pick.extract(logentry, 2, 0, 0)
     
     Fd = CInt(pick.extract(parms, 1, 0, 0)) 'iconv
     Td = CInt(pick.extract(parms, 2, 0, 0)) 'iconv
     statsby = pick.extract(parms, 3, 0, 0)
     Fees = pick.extract(parms, 4, 0, 0)
     Fcnt = pick.dcount(Fees, Chr(253))
     
     ReDim nrec(10)
     nrec(3) = Format$(Now, "DD MMM YY")

     If statsby = "bl_work" Then Attr = 4 Else Attr = 5
     maxt = d3.d3_select(logentry, "SSELECT " & statsby & " BY a0", mylist(), pick_cnt, 0, 0) - 1
     For kk = 0 To maxt
        If d3.d3_readstr(database, desc, statsby, mylist(kk)) = 0 Then
           Types = pick.Insert(Types, 1, 1, -1, mylist(kk))
           Types = pick.Insert(Types, 1, 2, -1, desc)
        End If
     Next kk

40   sentence = "SELECT PLANS WITH 19 >= """ & Fd & """ AND WITH 19 <= """ & Td & """"

300  Stats = ""
     database = pick.extract(logentry, 2, 0, 0)

   total_items = d3.d3_select(logentry, sentence, mylist(), pick_cnt, 0, 0) - 1
   If total_items = -1 Then
      nrec(5) = "<TH>No items found for selection " & sentence
      Exit Function
   End If

   For kk = 0 To total_items
     plan_id = mylist(kk)
     If d3.d3_readstr(database, plans_rec, "PLANS", plan_id) <> 0 Then GoTo 310
     If pick.extract(plans_rec, 19, 0, 0) = "" Then GoTo 310
     If pick.extract(plans_rec, 30, 0, 0) <> "" Then GoTo 310
     Assess = pick.extract(plans_rec, 1, 0, 0)
     If d3.d3_readstr(database, Ward, "PROPERTY", Assess, 38) <> 0 Then Ward = ""
     If Ward = "" Then Ward = Assess & " ward missing from assessment"
     typ = pick.extract(plans_rec, Attr, 1, 0)
     If statsby = "bl_structure" Then
        If d3.d3_readstr(database, typ, "BL_BUILDING", typ, 3) <> 0 Then typ = ""
     End If
     If typ = "" Then typ = typ & " missing"
     temp = pick.extract(plans_rec, 16, 0, 0)
     If IsNumeric(temp) Then value = CCur(temp) Else value = 0
     Feevalue = 0
     For I = 1 To Fcnt
        Fc = pick.extract(Fees, 1, I, 0)
        If pick.locate(Fc, plans_rec, 22, 1, 0, Pos, "") <> 0 Then
        'LOCATE(FC,PLANS_REC,22,1,0,POS,"") ELSE POS=0
           temp = pick.extract(plans_rec, 23, Pos, 0)
           If IsNumeric(temp) Then Feevalue = Feevalue + CCur(temp)
        End If
     Next I
     If pick.locate(Ward, Stats, 1, 1, 0, Pos, "AL") = 0 Then
        Stats = pick.Insert(Stats, 1, Pos, 0, Ward)
        Stats = pick.Insert(Stats, 2, Pos, 0, pick.extract(Types, 1, 1, 0))
        Stats = pick.Insert(Stats, 3, Pos, 0, "0")
        Stats = pick.Insert(Stats, 4, Pos, 0, "0")
        Stats = pick.Insert(Stats, 5, Pos, 0, "0")
     End If
     If pick.locate(typ, Stats, 2, Pos, 1, pos2, "") = 0 Then pos2 = maxt
     'LOCATE(typ,STATS,2,POS,0,POS2,"") ELSE POS2=MAXT
     temp = pick.extract(Stats, 3, Pos, pos2)
     If IsNumeric(temp) Then temp = CStr(CCur(temp)) + 1 Else temp = "1"
     Stats = pick.Replace(Stats, 3, Pos, pos2, temp)
     temp = pick.extract(Stats, 4, Pos, pos2)
     If IsNumeric(temp) Then tempcur = CCur(temp) Else tempcur = 0
     tempcur = tempcur + value
     Stats = pick.Replace(Stats, 4, Pos, pos2, CStr(tempcur))
     temp = pick.extract(Stats, 5, Pos, pos2)
     If IsNumeric(temp) Then tempcur = CCur(temp) Else tempcur = 0
     tempcur = tempcur + Feevalue
     Stats = pick.Replace(Stats, 5, Pos, pos2, CStr(tempcur))
310  Next kk
     GoSub 900
     nrec(5) = "<TH colspan=" & ncols + 1 & ">Building Statistics from " & Format(pick.date_pick_to_vb(Fd), "dd mmm yy") & " to " & Format(pick.date_pick_to_vb(Td), "dd mmm yy")
     Exit Function
'
900  Maxw = pick.dcount(pick.extract(Stats, 1, 0, 0), Chr(253))
     Gtot = "": Stot = "": Stot2 = ""
     nrec(4) = "": ncols = 0
     If Fcnt Then cols = 3 Else cols = 2

        nrec(2) = "<TH>Type of " & Mid(statsby, 4) 'remove bl_ in front of file name
        nrec(1) = "<TH>Wards"

        ncols = cols
        For K = 1 To Maxw
           If d3.d3_readstr(database, desc, "AREA", pick.extract(Stats, 1, K, 0), 1) <> 0 Then desc = pick.extract(Stats, 1, K, 0)
           ncols = ncols + cols
           nrec(1) = nrec(1) & "<TH colspan=" & cols & ">" & desc
           nrec(2) = nrec(2) & "<TH>Value"
           If Fcnt Then nrec(2) = nrec(2) & "<TH>Fees"
           nrec(2) = nrec(2) & "<TH>Number"
        Next K
        nrec(1) = nrec(1) & "<TH colspan=" & cols & ">All Wards"
        nrec(2) = nrec(2) & "<TH>Value"
        If Fcnt Then nrec(2) = nrec(2) & "<TH>Fees"
        nrec(2) = nrec(2) & "<TH>Number"
        For J = 1 To maxt
           nrec(4) = nrec(4) & "<TR CLASS=""mm""><TD>" & pick.extract(Types, 1, 2, J)
           For K = 1 To Maxw
              temp = pick.extract(Stats, 4, K, J)
              If IsNumeric(temp) Then temp = Format(CCur(temp) / 100, "#.00") Else temp = "&nbsp;"
              nrec(4) = nrec(4) & "<TD align=right>" & temp
              If Fcnt Then
                 temp = pick.extract(Stats, 5, K, J)
                 If IsNumeric(temp) Then temp = CStr(Int(CCur(temp) / 100 + 0.5)) Else temp = "&nbsp;"
                 nrec(4) = nrec(4) & "<TD align=right>" & temp
              End If
              nrec(4) = nrec(4) & "<TD align=right>" & "&nbsp;" & pick.extract(Stats, 3, K, J)
              For Mm = 1 To 3
                 temp = pick.extract(Stot, Mm, J, 0)
                 Select Case Mm
                    Case 1: temp2 = pick.extract(Stats, 4, K, J)
                    Case 2: temp2 = pick.extract(Stats, 3, K, J)
                    Case 3: temp2 = pick.extract(Stats, 5, K, J)
                 End Select
                 If IsNumeric(temp) Then
                    If IsNumeric(temp2) Then
                       tempcur = CCur(temp2) + CCur(temp)
                    Else
                       tempcur = CCur(temp)
                    End If
                 Else
                    If IsNumeric(temp2) Then tempcur = CCur(temp2) Else tempcur = 0
                 End If
                 Stot = pick.Replace(Stot, Mm, J, 0, CStr(tempcur))
                 
                 temp = pick.extract(Gtot, Mm, K, 0)
                 Select Case Mm
                    Case 1: temp2 = pick.extract(Stats, 4, K, J)
                    Case 2: temp2 = pick.extract(Stats, 3, K, J)
                    Case 3: temp2 = pick.extract(Stats, 5, K, J)
                 End Select
                 If IsNumeric(temp) Then
                    If IsNumeric(temp2) Then
                       tempcur = CCur(temp2) + CCur(temp)
                    Else
                       tempcur = CCur(temp)
                    End If
                 Else
                    If IsNumeric(temp2) Then tempcur = CCur(temp2) Else tempcur = 0
                 End If
                 Gtot = pick.Replace(Gtot, Mm, K, 0, CStr(tempcur))
              Next Mm
           Next K
           temp = pick.extract(Stot, 1, J, 0)
           If IsNumeric(temp) Then temp = Format(CCur(temp) / 100, "#.00") Else temp = "&nbsp;"
           nrec(4) = nrec(4) & "<TD align=right>" & temp
           If Fcnt Then
              temp = pick.extract(Stot, 3, J, 0)
              If IsNumeric(temp) Then temp = CStr(Int(CCur(temp) / 100 + 0.5)) Else temp = "&nbsp;"
              nrec(4) = nrec(4) & "<TD align=right>" & temp
           End If
           nrec(4) = nrec(4) & "<TD align=right>" & "&nbsp;" & pick.extract(Stot, 2, J, 0)
        Next J
        nrec(4) = nrec(4) & "<TR CLASS=totals><TD>" & "Totals"
        For K = 1 To Maxw
           temp = pick.extract(Gtot, 1, K, 0)
           If IsNumeric(temp) Then temp = Format(CCur(temp) / 100, "#.00") Else temp = "&nbsp;"
           nrec(4) = nrec(4) & "<TD align=right>" & temp
           If Fcnt Then
              temp = pick.extract(Gtot, 3, K, 0)
              If IsNumeric(temp) Then temp = CStr(Int(CCur(temp) / 100 + 0.5)) Else temp = "&nbsp;"
              nrec(4) = nrec(4) & "<TD align=right>" & temp
           End If
           nrec(4) = nrec(4) & "<TD align=right>" & "&nbsp;" & pick.extract(Gtot, 2, K, 0)
           For Mm = 1 To 3
              temp = pick.extract(Stot2, Mm, 0, 0)
              If IsNumeric(temp) Then tempcur = CCur(temp) Else tempcur = 0
              If IsNumeric(pick.extract(Gtot, Mm, K, 0)) Then tempcur = tempcur + CCur(pick.extract(Gtot, Mm, K, 0))
              Stot2 = pick.Replace(Stot2, Mm, 0, 0, CStr(tempcur))
           Next Mm
        Next K
        temp = pick.extract(Stot2, 1, 0, 0)
        If IsNumeric(temp) Then temp = Format(CCur(temp) / 100, "#.00") Else temp = "&nbsp;"
        nrec(4) = nrec(4) & "<TD align=right>" & temp
        If Fcnt Then
           temp = pick.extract(Stot2, 3, 0, 0)
           If IsNumeric(temp) Then temp = CStr(Int(CCur(temp) / 100 + 0.5)) Else temp = "&nbsp;"
           nrec(4) = nrec(4) & "<TD align=right>" & temp
        End If
        nrec(4) = nrec(4) & "<TD align=right>" & "&nbsp;" & pick.extract(Stot2, 2, 0, 0)

     Return

End Function


Public Function ta3133(logentry As String, nrec() As String, parms As String) As String
' TA3133 PRINT MONTHLY BUILDING REVENUE REPORT
Dim Date1 As String, date2 As String, Ct As Integer, sct As Integer
Dim Fees As String, Fcnt As Integer, Fc As String, I As Integer, Addr As String
Dim Iprog As Currency, Totv As Currency, Totf As Currency, Stotv As Currency, Stotf As Currency, Save_Ward As String
Dim Assess As String, typ As String, Ward As String, Client_Rec As String, typ_desc As String
Dim value As Currency, Fmax As Integer, Fee_Amt As Currency, J As Integer
Dim plan_id As String, plan_rec As String, need_and As Integer, ctr As Integer
Dim mylist() As String, pick_cnt As Long, database As String, total_items As Long
Dim temp As String, rderr As Integer, Msg As String, kk As Integer, plans_rec As String

     ReDim nrec(19)
     Date1 = pick.extract(parms, 1, 0, 0)
     If Date1 <> "" Then Date1 = Format(pick.date_pick_to_vb(Date1), "dd mmm yyyy")
     date2 = pick.extract(parms, 2, 0, 0)
     If date2 <> "" Then date2 = Format(pick.date_pick_to_vb(date2), "dd mmm yyyy")
     temp = pick.extract(parms, 3, 0, 0)
     If IsNumeric(temp) Then Iprog = CCur(temp) Else Iprog = -1
     Fees = pick.extract(parms, 4, 0, 0)
     Fcnt = pick.dcount(Fees, Chr(253))
     
     nrec(19) = "Print Building Valuation Revenue for applications completed "
     If Date1 <> "" Then nrec(19) = nrec(19) & " from " & Date1
     If date2 <> "" Then nrec(19) = nrec(19) & " to " & date2

     Ct = 0: Totv = 0: Totf = 0
     sct = 0: Stotv = 0: Stotf = 0
     Save_Ward = ""

     Msg = "SSELECT PLANS BY WARD BY BTYPE ": need_and = 0
     If Date1 <> "" Then Msg = Msg & "WITH APPLIC.DATE >= """ & Date1 & """": need_and = 1
     If date2 <> "" Then
        If need_and Then Msg = Msg & " AND "
        Msg = Msg & " WITH APPLIC.DATE <= """ & date2 & """": need_and = 1
     End If

     database = pick.extract(logentry, 2, 0, 0)

   total_items = d3.d3_select(logentry, Msg, mylist(), pick_cnt, 0, 0) - 1
   ctr = 0
   
   For kk = 0 To total_items
     plan_id = mylist(kk)
     If d3.d3_readstr(database, plans_rec, "PLANS", plan_id) <> 0 Then plans_rec = ""
     If pick.extract(plans_rec, 19, 0, 0) = "" Then GoTo 180
     Assess = pick.extract(plans_rec, 1, 0, 0)
     typ = pick.extract(plans_rec, 5, 1, 0)
     'If Typ = "" Then GoTo 180
     If d3.d3_readstr(database, Ward, "PROPERTY", Assess, 38) <> 0 Then Ward = ""
     If Ward <> "" Then
        If d3.d3_readstr(database, Ward, "AREA", Ward, 1) <> 0 Then Ward = ""
     End If
     If Ward = "" Then Ward = "assess " & Assess & " no ward"
     If d3.d3_readstr(database, Client_Rec, "CLIENT", Assess) <> 0 Then Client_Rec = ""
     Call srclient(Client_Rec, Assess, "", "", "", "", "", "", "", "", "", "", "", "", "", 2, "", Addr, "")
     If Save_Ward <> Ward Then
        If Save_Ward <> "" Then
           GoSub 200
        End If
        Save_Ward = Ward
        sct = 0: Stotv = 0: Stotf = 0
     End If
     If d3.d3_readstr(database, typ_desc, "bl_building", typ, 1) <> 0 Then typ_desc = ""
     If typ_desc = "" Then typ_desc = typ & " missing"
     temp = pick.extract(plans_rec, 16, 0, 0)
     If IsNumeric(temp) Then value = CCur(temp) Else value = 0
     Fmax = pick.dcount(pick.extract(plans_rec, 22, 0, 0), Chr(253))
     Fee_Amt = 0
     For I = 1 To Fmax
        Fc = pick.extract(plans_rec, 22, I, 0)
        If Fees = "" Then
           temp = pick.extract(plans_rec, 23, I, J)
           If IsNumeric(temp) Then Fee_Amt = Fee_Amt + CCur(temp)
        Else
           For J = 1 To Fcnt
              If Fc = pick.extract(Fees, 1, J, 0) Then
                 temp = pick.extract(plans_rec, 23, I, 0)
                 If IsNumeric(temp) Then Fee_Amt = Fee_Amt + CCur(temp)
              End If
           Next J
        End If
     Next I
     ctr = ctr + 1
     nrec(1) = pick.Replace(nrec(1), 1, ctr, 0, plan_id)
     nrec(2) = pick.Replace(nrec(2), 1, ctr, 0, Addr)
     nrec(3) = pick.Replace(nrec(3), 1, ctr, 0, typ_desc)
     nrec(4) = pick.Replace(nrec(4), 1, ctr, 0, CStr(value))
     nrec(5) = pick.Replace(nrec(5), 1, ctr, 0, CStr(Fee_Amt))
     nrec(6) = pick.Replace(nrec(6), 1, ctr, 0, Ward)
     nrec(7) = pick.Replace(nrec(7), 1, ctr, 0, "1")
     Stotv = Stotv + value: Stotf = Stotf + Fee_Amt: sct = sct + 1
180:
   Next kk
   
   GoSub 200
   ctr = ctr + 1
   nrec(1) = pick.Replace(nrec(1), 1, ctr, 0, " ")
   nrec(2) = pick.Replace(nrec(2), 1, ctr, 0, "Period total (" & Ct & ")")
   nrec(4) = pick.Replace(nrec(4), 1, ctr, 0, CStr(Totv))
   nrec(5) = pick.Replace(nrec(5), 1, ctr, 0, CStr(Totf))
   If Iprog <> -1 Then
      nrec(8) = CStr(Iprog + Totv)
      'ctr = ctr + 1
      'nrec(1) = pick.Replace(nrec(1), 1, ctr, 0, " ")
      'nrec(2) = pick.Replace(nrec(2), 1, ctr, 0, "Progressive total")
      'nrec(4) = pick.Replace(nrec(4), 1, ctr, 0, CStr(Iprog + Totv))
      rderr = d3.d3_writestr(database, "DICT PLANS", "@3133", CStr(Iprog + Totv))
   End If
   Exit Function

200  'ctr = ctr + 1
     'nrec(1) = pick.Replace(nrec(1), 1, ctr, 0, " ")
     'nrec(2) = pick.Replace(nrec(2), 1, ctr, 0, "Ward " & Save_Ward & " total (" & sct & ")")
     'nrec(4) = pick.Replace(nrec(4), 1, ctr, 0, CStr(Stotv))
     'nrec(5) = pick.Replace(nrec(5), 1, ctr, 0, CStr(Stotf))
     Ct = Ct + sct: Totv = Totv + Stotv: Totf = Totf + Stotf
     Return

End Function




Public Function TA3135(logentry As String)
' TA3135 RAISE FEES FOR BUILDING LICENCES
Dim totamt As Long, Client_No As String, Assess As String
Dim Name As String, I As Integer, J As Integer, Fc As String, Build As String, GL As String, Amt As String
Dim database As String, plans_rec As String, the_rec As String
Dim mylist() As String
Dim pick_cnt As Long
Dim total_items As Integer
Dim kk As Integer
Dim Td_Rec As String
Dim Line1 As String
Dim Line2 As String

    database = pick.extract(logentry, 2, 0, 0)
    total_items = d3.d3_select(logentry, "SSELECT PLANS", mylist(), pick_cnt, 0, 0)
    totamt = 0

    the_rec = "<TH>Plan<TH>Builder<TH>Assess"
    
    For kk = 0 To total_items - 1
        If d3.d3_readstr(database, plans_rec, "PLANS", mylist(kk)) = 0 Then
            If pick.extract(plans_rec, 19, 0, 0) <> "" And pick.extract(plans_rec, 20, 0, 0) = "" Then
                Assess = pick.extract(plans_rec, 1, 0, 0)
                Client_No = pick.extract(plans_rec, 2, 0, 0)
                Line1 = "<TR Class=mm>"
                Line2 = "<TR Class=mm><TD colspan=4 align=right>Amount"
                If d3.d3_readstr(database, Td_Rec, "TDEBTOR", Client_No) <> 0 Then
                    Assess = "Applicant (debtor) number " & Client_No & " does not exist for Plans No_ " & mylist(kk) ' PLAN_ID
                    Line1 = Line1 & "<TD colspan=3>" & Assess & "<TD align=right>Fee Codes"
                Else
                    If d3.d3_readstr(database, Td_Rec, "CLIENT", Client_No) <> 0 Then
                        Name = ""
                    Else
                        Name = pick.extract(Td_Rec, 1, 0, 0)
                    End If
                    Line1 = Line1 & "<TD><A HREF=/prospect/asp/bi.asp?fn=plans&tn=plans&item=" & mylist(kk) & _
                        ">" & mylist(kk) & "</a><TD><A HREF=/prospect/asp/bi.asp?fn=client&tn=client&item=" & _
                        Client_No & ">" & Name & "</a><TD>" & Assess & "<TD align=right>Fee Codes"
                    I = 1: J = 1
                    Do While pick.extract(plans_rec, 22, I, 1) <> ""
                        J = 1
                        Do While pick.extract(plans_rec, 22, I, J) <> ""
                            Fc = pick.extract(plans_rec, 22, I, J)
                            If d3.d3_readstr(database, Build, "BUILD.CODES", "@C_" & Fc) <> 0 Then Build = ""
                            GL = pick.extract(Build, 1, 1, 2)
                            If GL <> "NO" Then
                                Amt = pick.extract(plans_rec, 23, I, J)
                                If Amt <> "0" Then
                                    totamt = totamt + CLng(Amt)
                                    Line1 = Line1 & "<TD align=right>" & Fc
                                    Line2 = Line2 & "<TD align=right>" & pick.oconv(Amt, "MD2")
                                End If
                            End If
                            J = J + 1
                        Loop
                        I = I + 1
                    Loop
                End If
                the_rec = the_rec & Line1 & vbCrLf & Line2 & vbCrLf
            End If
        End If
    Next kk
    the_rec = the_rec & "<TR Class=mm><TD colspan=4 align=right><STRONG>Total Amount<TD align=right><STRONG>" & pick.oconv(CStr(totamt), "MD2")
    TA3135 = the_rec
    
End Function




Public Function ta3148(logentry As String, nrec() As String, parms As String) As String
' TA3148 - Building Licence Application Reporting

Dim Yr As Integer, Date1 As String, date2 As String, id As String, Prec As String
Dim Mm As Integer, sentence As String, database As String, kk As Integer, tot As Currency
Dim mylist() As String, pick_cnt As Long, total_items As Long, Stats As String, Yy As Integer
Dim temp As String, rderr As Integer, I As Integer

     Yr = pick.extract(parms, 1, 0, 0)
     If Yr > 2050 Then ta3148 = "": Exit Function
     If Yr < 1990 Then ta3148 = "": Exit Function
     
     ReDim nrec(15)
     
     Date1 = "01 JAN " & Mid$(Yr, 3, 2): date2 = "31 DEC " & Mid$(Yr, 3, 2)
     nrec(15) = "All approved applications between " & Date1 & " and " & date2
     sentence = "SSELECT PLANS BY COMPLETE.DATE WITH COMPLETE.DATE >= """ & Date1 & """ AND WITH COMPLETE.DATE <= """ & date2 & """"

     database = pick.extract(logentry, 2, 0, 0)

     total_items = d3.d3_select(logentry, sentence, mylist(), pick_cnt, 0, 0) - 1
     Stats = ""
     For kk = 0 To total_items
       id = mylist(kk)
       If d3.d3_readstr(database, Prec, "PLANS", id) <> 0 Then GoTo 180
       If pick.extract(Prec, 19, 0, 0) = "" Then GoTo 180
       Mm = Month(pick.date_pick_to_vb(pick.extract(Prec, 19, 0, 0)))
       temp = pick.extract(Stats, Mm, 0, 0)
       If IsNumeric(temp) Then tot = CCur(temp) + 1 Else tot = 1
       Stats = pick.Replace(Stats, Mm, 0, 0, CStr(tot))
180: Next kk

        tot = 0
        nrec(1) = pick.Replace(nrec(1), 1, 1, 0, CStr(Yr))
        For Yy = 1 To 12
           nrec(Yy + 1) = pick.Replace(nrec(Yy + 1), 1, 1, 0, " " & pick.extract(Stats, Yy, 0, 0))
           tot = tot + pick.extractcur(Stats, Yy, 0, 0)
        Next Yy
        Stats = pick.Replace(Stats, 13, 0, 0, CStr(tot))
        nrec(14) = pick.Replace(nrec(14), 1, 1, 0, CStr(tot))
        rderr = d3.d3_writestr(database, "plans.stats", CStr(Yr), Stats)
 
        kk = 1
        For Yy = Yr - 1 To Yr - 10 Step -1
           If d3.d3_readstr(database, Stats, "PLANS.STATS", CStr(Yy)) <> 0 Then Stats = ""
           kk = kk + 1
           nrec(1) = pick.Replace(nrec(1), 1, kk, 0, CStr(Yy))
           For I = 1 To 13
              nrec(I + 1) = pick.Replace(nrec(I + 1), 1, kk, 0, " " & pick.extract(Stats, I, 0, 0))
           Next I
        Next Yy

End Function




Public Function ta3156(template_path As String, logentry As String, parms As String) As String
' TA3156 DATA TRANSFER FOR ABS MONTH BUILDING APPROVALS
Dim Date1 As String, date2 As String, database As String
Dim codes As String, Lga As String, Sla As String, Cdc As String
Dim plan_id As String, plans As String
Dim Idate As String, Apdate As String, Assess As String
Dim Wkt As String, ABSCODE As String, Bt As String, Btype As String, Btdesc As String, Wt As String, Rt As String, Ft As String, Dw As String, St As String
Dim Area As String, value As Currency
Dim Crec As String, Prec As String, Lot As String, Lotarea As String, Vg As String, St_No As String, Street As String, Suburb As String, Ppc As String, Owner As String
Dim Orec As String, Oname As String, Ost_No As String, Ostreet As String, Osuburb As String, Oaddr As String, Opc As String, Oph As String, Builder As String
Dim Brec As String, Bname As String, Bst_No As String, Bstreet As String, Bsuburb As String, Baddr As String, Bpc As String, Bph As String, Breg As String
Dim Doi As String, Ped As String, Frt As String, Owntyp As String, Detach As String, Ndd As String, Bca1 As String, Bca2 As String, Bca3 As String
Dim fnum As Integer, rderr As Integer, Msg As String, need_and As Integer, mylist() As String, pick_cnt As Long
Dim total_items As Long, kk As Integer, Ans As String
Dim temp As String, cdattr As Integer, nrec As String, the_drive As String

     the_drive = Left(template_path, InStr(template_path, "\prospect\") - 1) & "/"

     database = pick.extract(logentry, 2, 0, 0)

     If UBound(g_trans_info_array) = 0 Then
        g_trans_info_array(0) = "TRANS.INFO"
        rderr = d3.d3_readmat(database, g_trans_info_array(), "DICT TRANS.J")
     End If
     If UBound(g_trans_info_array) < 125 Then ReDim Preserve g_trans_info_array(125)
     temp = Mid(g_trans_info_array(125), 23, 3)
     If IsNumeric(temp) Then cdattr = CInt(temp) Else cdattr = 0
     
     Date1 = pick.extract(parms, 1, 0, 0)
     If Date1 <> "" Then Date1 = Format(pick.date_pick_to_vb(Date1), "dd mmm yyyy")
     date2 = pick.extract(parms, 2, 0, 0)
     If date2 <> "" Then date2 = Format(pick.date_pick_to_vb(date2), "dd mmm yyyy")
     Lga = pick.extract(parms, 3, 0, 0)
     Sla = pick.extract(parms, 4, 0, 0)
     
     fnum = FreeFile
     nrec = the_drive & "prospect_site/mergefiles/abs" & Format(Now, "ddmmmyy") & ".txt"
     Open nrec For Output Access Write As #fnum
     'Write #fnum, "Asset", "Description", "Group", "Location", "Price", "Date", "Type", "Rate", "Freq", "Current Dep'd Value", "Depreciation Amount", "Depreciated Value", "Total Depreciation", "Class"
     
     codes = Lga
     codes = pick.Replace(codes, 2, 0, 0, Sla)
     rderr = d3.d3_writestr(database, "DICT PLANS", "@ABS", codes)

     Msg = "SSELECT PLANS BY KEY ": need_and = 0
     If Date1 <> "" Then Msg = Msg & "WITH APPLIC.DATE >= """ & Date1 & """": need_and = 1
     If date2 <> "" Then
        If need_and Then Msg = Msg & " AND "
        Msg = Msg & " WITH APPLIC.DATE <= """ & date2 & """": need_and = 1
     End If

   total_items = d3.d3_select(logentry, Msg, mylist(), pick_cnt, 0, 0) - 1
   ta3156 = nrec & Chr(8) & total_items
   
   For kk = 0 To total_items
     plan_id = mylist(kk)
     If d3.d3_readstr(database, plans, "PLANS", plan_id) <> 0 Then plans = ""
     If pick.extract(plans, 19, 0, 0) = "" Then GoTo 180
     Apdate = Format(pick.date_pick_to_vb(pick.extract(plans, 19, 0, 0)), "ddmmyyyy") 'oconv(Pick.extract(plans, 19, 0, 0), "D4/")
     'Apdate = Mid$(Apdate, 1, 2) & Mid$(Apdate, 4, 2) & Mid$(Apdate, 7, 4)
     Assess = pick.extract(plans, 1, 0, 0)
     Wkt = pick.extract(plans, 4, 1, 0)
     If d3.d3_readstr(database, ABSCODE, "BL_WORK", Wkt, 2) <> 0 Then ABSCODE = ""
     If ABSCODE <> "" Then Wkt = ABSCODE
     Bt = pick.extract(plans, 5, 1, 0)
     If d3.d3_readstr(database, Btype, "Bl_building", Bt) <> 0 Then Btype = ""
     ABSCODE = pick.extract(Btype, 2, 0, 0): Btdesc = pick.extract(Btype, 1, 0, 0)
     If ABSCODE <> "" Then Bt = ABSCODE
     Bt = "000" & Bt
     Wt = pick.extract(plans, 10, 1, 0)
     If d3.d3_readstr(database, ABSCODE, "BL_WALL", Wt, 2) <> 0 Then ABSCODE = ""
     If ABSCODE <> "" Then Wt = ABSCODE
     Wt = "00" & Wt
     Rt = pick.extract(plans, 11, 1, 0)
     If d3.d3_readstr(database, ABSCODE, "BL_ROOF", Rt, 2) <> 0 Then ABSCODE = ""
     If ABSCODE <> "" Then Rt = ABSCODE
     Rt = "00" & Rt
     Ft = pick.extract(plans, 12, 1, 0)
     If d3.d3_readstr(database, ABSCODE, "BL_FLOOR", Ft, 2) <> 0 Then ABSCODE = ""
     If ABSCODE <> "" Then Ft = ABSCODE
     Ft = "00" & Ft
     Dw = "000" & pick.extract(plans, 9, 0, 0)
     St = "00" & pick.extract(plans, 14, 0, 0)
     Area = String$(6, "0") & pick.extract(plans, 13, 0, 0)
     value = String$(9, "0") & pick.extract(plans, 16, 0, 0)
     If d3.d3_readstr(database, Crec, "CLIENT", Assess) <> 0 Then Crec = ""
     If d3.d3_readstr(database, Prec, "PROPERTY", Assess) <> 0 Then Prec = ""
     If cdattr <> 0 Then Cdc = pick.extract(Prec, cdattr, 0, 0)
     Lot = pick.extract(Prec, 1, 0, 0): Lotarea = String$(9, "0") & pick.extract(Prec, 7, 1, 0)
     Vg = pick.extract(Prec, 25, 0, 0)
     St_No = pick.field(pick.extract(Crec, 2, 1, 0), " ", 1)
     Street = pick.trimm(pick.field(pick.extract(Crec, 2, 1, 0), " ", 2) & " " & pick.field(pick.extract(Crec, 2, 1, 0), " ", 3))
     St_No = pick.field(St_No, "LOT", 1)
     If Not (IsNumeric(St_No)) Then
        Street = pick.extract(Crec, 2, 1, 0)
        St_No = ""
     End If
     Suburb = pick.extract(Crec, 3, 1, 0)
     If Suburb = "" Then Suburb = pick.extract(Crec, 4, 1, 0)
     Ppc = pick.extract(Crec, 5, 1, 0)
     Owner = pick.extract(Crec, 35, 1, 0)
     If d3.d3_readstr(database, Orec, "CLIENT", Owner) <> 0 Then Orec = ""
     Oname = pick.extract(Orec, 1, 0, 0)
     Ost_No = pick.field(pick.extract(Orec, 2, 1, 0), " ", 1)
     Ostreet = pick.trimm(pick.field(pick.extract(Orec, 2, 1, 0), " ", 2) & " " & pick.field(pick.extract(Orec, 2, 1, 0), " ", 3))
     If Not (IsNumeric(Ost_No)) Then
        Ostreet = pick.extract(Orec, 2, 1, 0)
        Ost_No = ""
     End If
     Osuburb = pick.extract(Orec, 3, 1, 0)
     If Osuburb = "" Then Osuburb = pick.extract(Orec, 4, 1, 0)
     Oaddr = pick.trimm(pick.extract(Orec, 2, 1, 0) & " " & pick.extract(Orec, 3, 1, 0) & " " & pick.extract(Orec, 4, 1, 0))
     Opc = pick.extract(Orec, 5, 1, 0): Oph = pick.extract(Orec, 9, 1, 0)
     Builder = pick.extract(plans, 2, 0, 0)
     If d3.d3_readstr(database, Brec, "CLIENT", Builder) <> 0 Then Brec = ""
     Bname = pick.extract(Brec, 1, 0, 0)
     Bst_No = pick.field(pick.extract(Brec, 2, 1, 0), " ", 1)
     Bstreet = pick.trimm(pick.field(pick.extract(Brec, 2, 1, 0), " ", 2) & " " & pick.field(pick.extract(Brec, 2, 1, 0), " ", 3))
     If Not (IsNumeric(Bst_No)) Then
        Bstreet = pick.extract(Brec, 2, 1, 0)
        Bst_No = ""
     End If
     Bsuburb = pick.extract(Brec, 3, 1, 0)
     If Bsuburb = "" Then Bsuburb = pick.extract(Brec, 4, 1, 0)
     Baddr = pick.trimm(pick.extract(Brec, 2, 1, 0) & " " & pick.extract(Brec, 3, 1, 0) & " " & pick.extract(Brec, 4, 1, 0))
     Bpc = pick.extract(Brec, 5, 1, 0): Bph = pick.extract(Brec, 9, 1, 0)
     Breg = pick.extract(plans, 3, 0, 0)
     If d3.d3_readstr(database, Brec, "CLIENT", pick.extract(plans, 2, 0, 0)) <> 0 Then Brec = ""
     temp = pick.extract(plans, 44, 0, 0)
     If IsNumeric(temp) Then Doi = temp Else Doi = "0"
     Ped = "000" & pick.extract(plans, 46, 0, 0)
     Frt = pick.extract(plans, 45, 1, 0)
     If d3.d3_readstr(database, ABSCODE, "BL_FRAME", Frt, 2) <> 0 Then ABSCODE = ""
     If ABSCODE <> "" Then Frt = ABSCODE
     Frt = "00" & Frt
     Owntyp = pick.extract(plans, 79, 0, 0): If Owntyp = "" Then Owntyp = 1
     Detach = pick.extract(plans, 80, 0, 0): If Detach = "" Then Detach = "D"
     Ndd = "000" & pick.extract(plans, 81, 0, 0)
     Bca1 = pick.extract(plans, 82, 1, 0): Bca2 = pick.extract(plans, 82, 2, 0): Bca3 = pick.extract(plans, 82, 3, 0)

     Ans = "5" & Right(Space(4) & Lga, 4) & Right(Space(4) & Sla, 4) & Left(plan_id & Space(20), 20)
     Ans = Ans & Space(3) & Left(Apdate & Space(8), 8) & Right(Space(7) & (String$(7, "0") & Cdc), 7) & Space(7) & Left(pick.extract(Lot, 1, 1, 0) & Space(10), 10) & Space(8) & Left(St_No & Space(10), 10) & Left(Street & Space(30), 30) & Left(Suburb & Space(30), 30) & Left(Ppc & Space(4), 4) & Space(4) & Left(Owntyp & Space(1), 1) & Left(Wkt & Space(1), 1) & Right(Space(3) & Bt, 3) & Left(Btdesc & Space(250), 250) & Right(Space(3) & Dw, 3) & Right(Space(2) & Wt, 2) & Right(Space(2) & Rt, 2) & Right(Space(2) & Ft, 2) & Right(Space(2) & Frt, 2) & Right(Space(6) & Area, 6) & Right(Space(6) & Lotarea, 6) & Right(Space(9) & value, 9) & Left(Detach & Space(1), 1) & Left(Doi & Space(1), 1) & Right(Space(3) & Ped, 3) & Right(Space(2) & St, 2) & Right(Space(3) & Ndd, 3) & Right(Space(8) & (String$(8, "0") & Assess), 8) & Left(Oname & Space(30), 30) & Left(Ost_No & Space(10), 10) & Left(Ostreet & Space(30), 30) & Left(Osuburb & Space(30), 30) & Left(Opc & Space(4), 4)
     Ans = Ans & Left(Oph & Space(14), 14) & Left(Bname & Space(36), 36) & Left(Bst_No & Space(10), 10) & Left(Bstreet & Space(36), 36) & Left(Bsuburb & Space(30), 30) & Left(Bpc & Space(4), 4) & Left(Bph & Space(14), 14) & Left(Breg & Space(10), 10) & Space(10) & Left(Bca1 & Space(6), 6) & Left(Bca2 & Space(6), 6) & Left(Bca3 & Space(6), 6) & Space(59)
     Print #fnum, Ans
180:
  Next kk
  Close #fnum

End Function

Public Function ta3148a(logentry As String, nrec() As String, parms As String) As String
' TA3148 - Building Licence Application Reporting

Dim Date1 As String, date2 As String, Msg As String, nx As Integer, desc As String
Dim Wtype As String, Btype As String, Fees As String, Fcnt As Integer
Dim Atr As Integer, temp As String, maxj As Integer, Fc As String, need_and As Integer
Dim Stat As String, Hdr3 As String, id As String, J As Integer, K As Integer, I As Integer, Maxi As Integer
Dim Status As String, Xstatus As String, Prec As String, Assess As String, Proprec As String, Lot As String, Ward As String, clrec As String
Dim Paddr As String, Own As String, Builder As String, Owner As String, Wt As String, Bt As String
Dim value As Currency, Totfees As Currency, Totdeps As Currency, kk As Integer, seq As String
Dim mylist() As String, pick_cnt As Long, database As String, total_items As Long

     ReDim nrec(20)
     Date1 = pick.extract(parms, 1, 0, 0)
     If Date1 <> "" Then Date1 = Format(pick.date_pick_to_vb(Date1), "dd mmm yyyy")
     date2 = pick.extract(parms, 2, 0, 0)
     If date2 <> "" Then date2 = Format(pick.date_pick_to_vb(date2), "dd mmm yyyy")
     Wtype = pick.extract(parms, 3, 0, 0)
     Btype = pick.extract(parms, 4, 0, 0)
     Fees = pick.extract(parms, 5, 0, 0)
     Fcnt = pick.dcount(Fees, Chr(253))
     Stat = pick.extract(parms, 6, 0, 0)
     nrec(19) = Mid(Stat, 3)
     Stat = Left(Stat, 1)
     If Stat = "B" Or Stat = "J" Then
        If Stat = "B" Then Stat = "A" Else Stat = "I"
        Atr = 71
     Else
        Atr = 20
     End If
'60   If Mid$(Pick.extract(Trans_Info, 125, 0, 0), 19, 1) Then
'        Atr = 71: Txt = "Applications approved but not issued": Txt2 = "Applications issued but not started"
'     Else
'        Atr = 20: Txt = "Applications approved but fees not raised": Txt2 = "Applications where fees raised but not started"
'     End If
     
     If Date1 <> "" Then nrec(19) = nrec(19) & " from " & Date1
     If date2 <> "" Then nrec(19) = nrec(19) & " to " & date2

     If Wtype <> "" Then
        If d3.d3_readstr(database, desc, "BL_WORK", Wtype, 1) <> 0 Then desc = Wtype
        nrec(19) = nrec(19) & " and for work type " & desc
     End If
     If Btype <> "" Then
        If d3.d3_readstr(database, desc, "BL_WORK", Btype, 1) <> 0 Then desc = Btype
        nrec(19) = nrec(19) & " and for building type " & desc
     End If

     Msg = "SSELECT PLANS BY APPLIC.DATE ": need_and = 0
     If Date1 <> "" Then Msg = Msg & "WITH APPLIC.DATE >= """ & Date1 & """": need_and = 1
     If date2 <> "" Then
        If need_and Then Msg = Msg & " AND "
        Msg = Msg & " WITH APPLIC.DATE <= """ & date2 & """": need_and = 1
     End If
     
     If Wtype <> "" Then
        If need_and Then Msg = Msg & " AND "
        Msg = Msg & "WITH WT = "" & WTYPE & "" ": need_and = 1
     End If
     If Btype <> "" Then
        If need_and Then Msg = Msg & " AND "
        Msg = Msg & "WITH BT = "" & BTYPE & "" ": need_and = 1
     End If
     nrec(20) = Msg
     
     database = pick.extract(logentry, 2, 0, 0)
     total_items = d3.d3_select(logentry, Msg, mylist(), pick_cnt, 0, 0) - 1

     For kk = 0 To total_items
       id = mylist(kk)
       If d3.d3_readstr(database, Prec, "PLANS", id) <> 0 Then GoTo 180
       If id = "" Then GoTo 180

       If pick.extract(Prec, 30, 0, 0) <> "" Then Status = "X": Xstatus = "Cancelled": GoTo 120
       If pick.extract(Prec, 19, 0, 0) = "" Then Status = "P": Xstatus = "Pending": GoTo 120
       If pick.extract(Prec, Atr, 0, 0) = "" Then
          Status = "A"
          If Atr = 71 Then Xstatus = "Approved not issued" Else Xstatus = "Approved fees not raised"
          GoTo 120
       End If
       If pick.extract(Prec, 31, 0, 0) = "" Then
          Status = "I"
          If Atr = 71 Then Xstatus = "Issued not started" Else Xstatus = "Fees raised not started"
          GoTo 120
       End If
       If pick.extract(Prec, 36, 0, 0) = "" Then Status = "S": Xstatus = "Construction started": GoTo 120
       Status = "C": Xstatus = "Construction complete"
120:

       If Stat = "N" Then
          If Status = "X" Then GoTo 180
       Else
          If Stat = "Z" Then
             If Status = "X" Or Status = "P" Then GoTo 180
          Else
             If Status <> Stat Then GoTo 180
          End If
       End If

     Assess = pick.extract(Prec, 1, 0, 0)
     If d3.d3_readstr(database, Proprec, "PROPERTY", Assess) <> 0 Then Proprec = ""
     Lot = pick.extract(Proprec, 1, 1, 0)
     If d3.d3_readstr(database, Ward, "area", pick.extract(Proprec, 38, 0, 0)) <> 0 Then Ward = ""
     Ward = pick.extract(Ward, 1, 0, 0)
     If d3.d3_readstr(database, clrec, "CLIENT", Assess) <> 0 Then clrec = ""
     Paddr = pick.trimm(pick.extract(clrec, 2, 1, 0) & " " & pick.extract(clrec, 3, 1, 0) & " " & pick.extract(clrec, 4, 1, 0))
     Own = pick.extract(clrec, 35, 1, 0)
     If d3.d3_readstr(database, clrec, "CLIENT", pick.extract(Prec, 2, 0, 0)) <> 0 Then clrec = ""
     Builder = pick.trimm(pick.extract(clrec, 6, 0, 0) & " " & pick.extract(clrec, 1, 0, 0))
     If pick.extract(Prec, 53, 0, 0) <> "" Then
        Owner = pick.extract(Prec, 53, 0, 0)
     Else
        If d3.d3_readstr(database, clrec, "CLIENT", Own) <> 0 Then clrec = ""
        Owner = pick.trimm(pick.extract(clrec, 6, 0, 0) & " " & pick.extract(clrec, 1, 0, 0))
     End If
     If Wtype <> "" Then Wt = Wtype Else Wt = pick.extract(Prec, 4, 1, 0)
     If Btype <> "" Then Bt = Btype Else Bt = pick.extract(Prec, 5, 1, 0)
     temp = pick.extract(Prec, 16, 0, 0)
     If IsNumeric(temp) Then value = CCur(temp) Else value = 0
     Totfees = 0: Totdeps = 0
     Maxi = pick.dcount(pick.extract(Prec, 22, 0, 0), Chr(253))
     For I = 1 To Maxi
        maxj = pick.dcount(pick.extract(Prec, 22, I, 0), Chr(252))
        For J = 1 To maxj
           Fc = pick.extract(Prec, 22, I, J)
           If Fees = "" Then
              temp = pick.extract(Prec, 23, I, J)
              If IsNumeric(temp) Then Totfees = Totfees + CCur(temp)
           Else
              For K = 1 To Fcnt
                 If Fc = pick.extract(Fees, 1, K, 0) Then
                    temp = pick.extract(Prec, 23, I, J)
                    If IsNumeric(temp) Then Totfees = Totfees + CCur(temp)
                 End If
              Next K
           End If
160     Next J
     Next I
     seq = pick.extract(Prec, 17, 0, 0)
     If pick.locate(seq, nrec(4), 1, 1, 0, nx, "ar") <> 0 Then
     End If
     'LOCATE(SEQ,NREC,4,1,0,NX,"AR") ELSE NULL
     nrec(4) = pick.Insert(nrec(4), 1, nx, 0, seq)
     nrec(1) = pick.Insert(nrec(1), 1, nx, 0, id)
     nrec(2) = pick.Insert(nrec(2), 1, nx, 0, Wt)
     nrec(3) = pick.Insert(nrec(3), 1, nx, 0, Bt)
     nrec(5) = pick.Insert(nrec(5), 1, nx, 0, Paddr)
     nrec(6) = pick.Insert(nrec(6), 1, nx, 0, Builder)
     nrec(7) = pick.Insert(nrec(7), 1, nx, 0, Owner)
     nrec(8) = pick.Insert(nrec(8), 1, nx, 0, pick.extract(Prec, 19, 0, 0))
     'Status = Mid$(Pick.extract(Mlev, Xstatus + 1, 0, 0), 5, 99)
     nrec(9) = pick.Insert(nrec(9), 1, nx, 0, Xstatus)
     nrec(10) = pick.Insert(nrec(10), 1, nx, 0, CStr(value))
     nrec(11) = pick.Insert(nrec(11), 1, nx, 0, Ward)
     nrec(12) = pick.Insert(nrec(12), 1, nx, 0, CStr(Totfees))
     nrec(13) = pick.Insert(nrec(13), 1, nx, 0, pick.extract(Prec, 10, 0, 0))
     nrec(14) = pick.Insert(nrec(14), 1, nx, 0, pick.extract(Prec, 11, 0, 0))
     nrec(15) = pick.Insert(nrec(15), 1, nx, 0, pick.extract(Prec, 12, 0, 0))
     temp = pick.extract(Prec, 32, 0, 0)
     nrec(16) = pick.Insert(nrec(16), 1, nx, 0, Replace(temp, Chr(253), ","))
     nrec(17) = pick.Insert(nrec(17), 1, nx, 0, pick.extract(Prec, 57, 1, 0))
     nrec(18) = pick.Insert(nrec(18), 1, nx, 0, pick.extract(Prec, 58, 1, 0))
180: Next kk

End Function

Public Function TA3157(template_path As String, logentry As String, parms As String, sentence As String) As String
' TA3157 DATA TRANSFER FOR ABS MONTH BUILDING COMMENCEMENTS
Dim Lga As String, AppDate As String, database As String, ComDate As String
Dim mylist() As String, plan_id As String, plans As String, Ans As String
Dim fnum As Integer, total_items As Integer, kk As Integer, pick_cnt As Long, Status As Integer
Dim temp As String, nrec As String, the_drive As String

    the_drive = Left(template_path, InStr(template_path, "\prospect\") - 1) & "/"
        
    Lga = pick.extract(parms, 1, 0, 0)          ' LGA
    AppDate = pick.extract(parms, 2, 0, 0)      ' Approval period YYMM
    
    fnum = FreeFile
    nrec = the_drive & "prospect_site/mergefiles/abs" & Format(Now, "ddmmmyy") & ".txt"
    Open nrec For Output Access Write As #fnum
    
    database = pick.extract(logentry, 2, 0, 0)
    
    total_items = d3.d3_select(logentry, Replace(sentence, Chr(8), """"), mylist(), pick_cnt, 0, 0)
    TA3157 = nrec & Chr(8) & total_items
    
    For kk = 0 To total_items - 1
        plan_id = mylist(kk)
        If d3.d3_readstr(database, plans, "PLANS", plan_id) = 0 Then
            If pick.extract(plans, 30, 0, 0) = "" Then
                If pick.extract(plans, 31, 0, 0) = "" Then
                    ComDate = String$(8, "0")
                    Status = 2
                Else
                    ComDate = Format(pick.date_pick_to_vb(pick.extract(plans, 31, 0, 0)), "ddmmyy")
                    Status = 1
                End If
            Else
                ComDate = Format(pick.date_pick_to_vb(pick.extract(plans, 30, 0, 0)), "ddmmyy")
                Status = 3
            End If
            Ans = "5" & Right(Space(4) & Lga, 4) & Left(plan_id & Space(20), 20) & Right(Space(4) & _
                AppDate, 4) & Left(ComDate & Space(6), 6) & Left(Status & Space(1), 1) & Space(4)
            Print #fnum, Ans
        End If
    Next kk
    Close #fnum
End Function




Public Function TA3158(template_path As String, logentry As String, parms As String, sentence As String) As String
' TA3158 DATA TRANSFER FOR BRB MONTH BUILDING LICENCES
Dim fnum As Integer, total_items As Integer, kk As Integer
Dim database As String, mylist() As String, plans As String, plan_id As String
Dim Assess As String, Btype As String, desc As String, Area As String, value As String
Dim Orec As String, Brec As String, Own As String, Ans As String
Dim pick_cnt As Long, temp As String, nrec As String, the_drive As String

    the_drive = Left(template_path, InStr(template_path, "\prospect\") - 1) & "/"
    
    fnum = FreeFile
    nrec = the_drive & "prospect_site/mergefiles/brb" & Format(Now, "ddmmmyy") & ".txt"
    Open nrec For Output Access Write As #fnum
    
    database = pick.extract(logentry, 2, 0, 0)
    
    total_items = d3.d3_select(logentry, Replace(sentence, Chr(8), """"), mylist(), pick_cnt, 0, 0)
    TA3158 = nrec & Chr(8) & total_items
    
    For kk = 0 To total_items - 1
        plan_id = mylist(kk)
        If d3.d3_readstr(database, plans, "PLANS", plan_id) = 0 Then
            Assess = pick.extract(plans, 1, 0, 0)
            Btype = pick.extract(plans, 5, 1, 0)
            If d3.d3_readstr(database, desc, "Bl_building", Btype, 1) <> 0 Then desc = ""
            Area = pick.extract(plans, 13, 0, 0)
            If IsNumeric(Area) Then
                Area = CStr(CCur(Area) * 100)
            End If
            Area = String$(7, "0") & Area
            value = String$(8, "0") & pick.extract(plans, 16, 0, 0)
            If d3.d3_readstr(database, Own, "CLIENT", Assess, 35) <> 0 Then Own = ""
            If d3.d3_readstr(database, Orec, "CLIENT", pick.extract(Own, 1, 1, 0)) <> 0 Then Orec = ""
            If d3.d3_readstr(database, Brec, "CLIENT", pick.extract(plans, 2, 0, 0)) <> 0 Then Brec = ""
            Ans = Left(plan_id & Space(10), 10) & Left(pick.extract(plans, 3, 0, 0) & Space(4), 4) & _
                Left(pick.extract(Orec, 1, 0, 0) & Space(40), 40) & Left(pick.extract(Orec, 7, 0, 0) & _
                Space(20), 20) & Left(pick.extract(Orec, 2, 1, 0) & Space(30), 30) & _
                Left(Trim(pick.extract(Orec, 3, 1, 0) & " " & pick.extract(Orec, 4, 1, 0) & " " & _
                pick.extract(Orec, 5, 1, 0)) & Space(30), 30) & Left(pick.extract(Brec, 1, 0, 0) & _
                Space(40), 40) & Left(pick.extract(Brec, 7, 0, 0) & Space(20), 20) & _
                Left(pick.extract(Brec, 2, 1, 0) & Space(30), 30) & Left(Trim(pick.extract(Brec, 3, 1, 0) & " " & _
                pick.extract(Brec, 4, 1, 0) & " " & pick.extract(Brec, 5, 1, 0)) & Space(30), 30) & _
                Left(pick.extract(desc, 1, 1, 0) & Space(30), 30) & Right(Space(8) & value, 8) & _
                Right(Space(7) & Area, 7)
            Print #fnum, Ans
        End If
    Next kk
    Close #fnum
End Function





Public Function TA3159(template_path As String, logentry As String, parms As String, sentence As String) As String

' TA3159 DATA TRANSFER FOR CRA MONTH BUILDING APPROVALS
' CRA - CONTRUCTION RESEARCH OF AUSTRALIA

Dim nrec As String
Dim fnum As Integer, total_items As Integer, kk As Integer
Dim database As String, mylist() As String, plans As String, plan_id As String
Dim Assess As String, Wkt As String, Bt As String, Wt As String, Rt As String, Ft As String
Dim Dw As String, St As String, value As String, Lot As String
Dim Cd As String, Ppc As String, Owner As String, Oname As String, Opc As String
Dim Builder As String, Bname As String, Bpc As String
Dim Crec As String, Prec As String, Orec As String, Brec As String, Complete As String
Dim Ans As String, temp As String
Dim pick_cnt As Long, the_drive As String

    the_drive = Left(template_path, InStr(template_path, "\prospect\") - 1) & "/"
    
    fnum = FreeFile
    nrec = the_drive & "prospect_site/mergefiles/cra" & Format(Now, "ddmmmyy") & ".txt"
    Open nrec For Output Access Write As #fnum
    
    database = pick.extract(logentry, 2, 0, 0)
    
    total_items = d3.d3_select(logentry, sentence, mylist(), pick_cnt, 0, 0)
    TA3159 = nrec & Chr(8) & total_items
    
    For kk = 0 To total_items - 1
        plan_id = mylist(kk)
        If d3.d3_readstr(database, plans, "PLANS", plan_id) = 0 Then
            Assess = pick.extract(plans, 1, 0, 0)
            If d3.d3_readstr(database, Crec, "CLIENT", Assess) <> 0 Then Crec = ""
            If d3.d3_readstr(database, Prec, "PROPERTY", Assess) <> 0 Then Prec = ""
            Owner = pick.extract(Crec, 35, 1, 0)
            If d3.d3_readstr(database, Orec, "CLIENT", Owner) <> 0 Then Orec = ""
            Builder = pick.extract(plans, 2, 0, 0)
            If d3.d3_readstr(database, Brec, "CLIENT", Builder) <> 0 Then Brec = ""
            Oname = pick.extract(Orec, 1, 0, 0)
            Opc = pick.extract(Orec, 5, 1, 0)
            Bname = pick.extract(Brec, 1, 0, 0)
            Bpc = pick.extract(Brec, 5, 1, 0)
            Ppc = pick.extract(Crec, 5, 1, 0)
            Lot = pick.extract(Prec, 1, 1, 0)
            Cd = pick.extract(Prec, 125, 0, 0)
            If d3.d3_readstr(database, Wkt, "Bl_work", pick.extract(plans, 4, 1, 0), 1) <> 0 Then Wkt = ""
            If d3.d3_readstr(database, Bt, "Bl_building", pick.extract(plans, 5, 1, 0), 1) <> 0 Then Bt = ""
            If d3.d3_readstr(database, Wt, "Bl_wall", pick.extract(plans, 10, 1, 0), 1) <> 0 Then Wt = pick.extract(plans, 10, 1, 0)
            If d3.d3_readstr(database, Rt, "Bl_roof", pick.extract(plans, 11, 1, 0), 1) <> 0 Then Rt = pick.extract(plans, 11, 1, 0)
            If d3.d3_readstr(database, Ft, "Bl_floor", pick.extract(plans, 12, 1, 0), 1) <> 0 Then Ft = pick.extract(plans, 12, 1, 0)
            Dw = String$(5, "0") & pick.extract(plans, 9, 0, 0)
            St = String$(5, "0") & pick.extract(plans, 14, 0, 0)
            value = String$(10, "0") & pick.extract(plans, 16, 0, 0)
            Complete = pick.date_pick_to_vb(pick.extract(plans, 19, 0, 0))
            Ans = Left(plan_id & Space(20), 20) & Left(Oname & Space(30), 30) & _
                Left(pick.extract(Orec, 2, 1, 0) & Space(30), 30) & Left(pick.extract(Orec, 3, 1, 0) & Space(30), 30) & _
                Left(pick.extract(Orec, 4, 1, 0) & Space(30), 30) & Left(Opc & Space(10), 10) & _
                Left(Bname & Space(30), 30) & Left(pick.extract(Brec, 2, 1, 0) & Space(30), 30) & _
                Left(pick.extract(Brec, 3, 1, 0) & Space(30), 30) & Left(pick.extract(Brec, 4, 1, 0) & Space(30), 30) & _
                Left(Bpc & Space(10), 10)
            Ans = Ans & Left(pick.extract(Crec, 2, 1, 0) & Space(30), 30) & _
                Left(pick.extract(Crec, 3, 1, 0) & Space(30), 30) & Left(pick.extract(Crec, 4, 1, 0) & Space(30), 30) & _
                Left(Ppc & Space(10), 10) & Left(Lot & Space(10), 10) & Left(Cd & Space(10), 10)
            Ans = Ans & Left(Wkt & Space(30), 30) & Left(Bt & Space(30), 30) & Left(Wt & Space(30), 30) & _
                Left(Rt & Space(30), 30) & Left(Ft & Space(30), 30) & Right(Space(5) & Dw, 5) & _
                Right(Space(5) & St, 5) & Right(Space(10) & value, 10) & Left(Complete & Space(10), 10) & Space(20)
            Print #fnum, Ans
        End If
    Next kk
    Close #fnum
End Function

Public Function TA3140(logentry As String, parms As String) As String
' RAISE FEES FOR BUILDING, SIGN, DEMOLITION LICENCES
Dim which_file As String, pr_which_file As String, Prefix As String
Dim Assess As String, plan_id As String, plans_rec As String
Dim Td_Rec As String, Client_No As String, I As Integer
Dim temp As String, tempcur As Currency, tempcur2 As Currency
Dim Haslimit As String, Allowb4 As String, Onlythis As String
Dim Tr_Cr As String, Tr_Dr As String, database As String, rderr As Integer
Dim debt_cont As String, Cr_Rec As String, Cred_Cont As String, Tj_Rec As String
Dim cancel As Integer
Dim Strvm As String, Cl_Fg As String, Plan_Ids As String, T_Name As String, Cr_Relation As Integer
Dim Tjdata() As String, checking As Integer
Dim posn As Integer
Dim Fdate As Integer, Ln, Adate As String, Ann, Yy, Trinvdate As Integer, Tr_Inv_Date As Integer
Dim Tr_Inv_Ref2, Tamt As Currency, Maxi As Integer, maxj As Integer, J As Integer, Fc As String, Amt As Currency, CODE, field
Dim Name As String, Build As String, GL As String, Tr_Inv_Ref As String, Narr As String, Tjac As String, Tjjob As String, Tjcd As String, Tjcost As Currency
Dim Tjnarr As String, Comm As Currency, Comgl As String, Ugl As String
Dim Ll As Integer, Glac As String, Tj_Key As String, tj_tno As String
Dim Gst As String, billto As String
Dim Orec As String, bill_client As String
Dim minimum As Currency, percent As Currency, Factor As Currency
Dim gstamt As Currency, gstcomm As Currency
Dim gstrates As String, gstrate As Currency, gstaccs As String
Dim nrec() As String

'ta3120 FILE='SIGNS'; XREF.ATTR=64; PREFIX='SL'; TEXT='Sign'
'ta3121 FILE='DEMOLITIONS'; XREF.ATTR=65; PREFIX='DL'; TEXT='Demolition'
'ta3140 FILE='PLANS'; XREF.ATTR=51; PREFIX='BL'; TEXT='Building'

     ReDim nrec(3)
     database = pick.extract(logentry, 2, 0, 0)
     temp = d3.execute_tcl(logentry, "WHO", "")
     tj_tno = Right("000" & pick.field(temp, " ", 1), 3)
      
     which_file = "PLANS": pr_which_file = "PR." & which_file
     Prefix = "BL"
     plan_id = pick.extract(parms, 1, 0, 0)
     Fdate = pick.extractint(parms, 2, 0, 0)

     If UBound(g_trans_info_array) = 0 Then
        g_trans_info_array(0) = "TRANS.INFO"
        rderr = d3.d3_readmat(database, g_trans_info_array(), "DICT TRANS.J")
     End If
     If UBound(g_trans_info_array) < 106 Then ReDim Preserve g_trans_info_array(106)

     Haslimit = Mid(g_trans_info_array(125), 18, 1)
     If Haslimit = "" Then Haslimit = "0"
     Allowb4 = Mid(g_trans_info_array(125), 16, 1)
     If Allowb4 = "" Then Allowb4 = "0"
     If which_file = "PLANS" Then
        If d3.d3_readstr(database, Onlythis, "DICT PLANS", "@CLASS") <> 0 Then Onlythis = ""
     Else
        Allowb4 = ""
     End If

     If d3.d3_readstr(database, gstrates, "gst.control", "gst.rate") <> 0 Then gstrates = ""
     If d3.d3_readstr(database, gstaccs, "gst.control", "gst.accs") <> 0 Then gstaccs = ""
     temp = pick.extract(gstrates, 1, 0, 0)
     If IsNumeric(temp) Then gstrate = CCur(temp) Else gstrate = 0
     
     Tr_Cr = 39: Tr_Dr = 64

     If d3.d3_readstr(database, plans_rec, "PLANS", plan_id) <> 0 Then
        TA3140 = "Fees not raised. " & "Plan " & plan_id & " does not exist"
        Exit Function
     End If
     Assess = pick.extract(plans_rec, 1, 0, 0) 'property assess
     Client_No = pick.extract(plans_rec, 2, 0, 0) 'applicant debtor
     If Client_No = "" Then
        T_Name = "TBA"
     Else
        If d3.d3_readstr(database, T_Name, "CLIENT", Client_No) <> 0 Then T_Name = ""
     End If
     If Mid(T_Name, 1, 3) = "TBA" Then
        TA3140 = "Fees not raised. " & "Plan " & plan_id & "Applicant is " & Client_No & " cannot raise fees"
        Exit Function
     End If
     cancel = 0
     If pick.extract(plans_rec, 20, 0, 0) <> "" Then
        If pick.extract(plans_rec, 30, 0, 0) <> "" Then
           If pick.extract(plans_rec, 30, 0, 0) = pick.ICONV(Format$(Now, "DD MMM YY"), "D2") Then cancel = 1: GoTo 30
           TA3140 = "Fees not raised. " & "Plan " & plan_id & " Fees raised on " & pick.oconv(pick.extract(plans_rec, 20, 0, 0), "D2") & " and then cancelled on " & pick.oconv(pick.extract(plans_rec, 30, 0, 0), "D2")
        Else
           TA3140 = "Fees not raised. " & "Plan " & plan_id & " Fees raised on " & pick.oconv(pick.extract(plans_rec, 20, 0, 0), "D2")
        End If
        Exit Function
     End If
     If pick.extract(plans_rec, 19, 0, 0) = "" Then
        TA3140 = "Fees not raised. " & "Plan " & plan_id & " Fees are not complete"
        Exit Function
     End If
30:
'     If Allowb4 And Onlythis <> "" Then
'        READV CLS FROM TDEBTOR_DATA,CLIENT_NO,21 ELSE CLS=""
'        If Cls <> Onlythis Then
'           PRINT @(43,2) & BELL & CL & : CLS$=CL: LNS$=22: MSG$="Fees only raised for debtor with class of " & PICK.EXTRACT(CLASS,ONLYTHIS,0,0) & " ! ": CALL SRIP(0,LNS$,MSG$,JUNK,CLS$,"","","","")
'           GoTo 20
'        End If
'     End If
     If cancel Then
        nrec(1) = "Fees originally raised on the " & pick.oconv(pick.extract(plans_rec, 20, 0, 0), "D2") & " and cancelled today. Re-raising fees" & vbCrLf
     End If
     Adate = ""
     If Mid$(Prefix, 1, 1) <> "S" Then GoTo 60
'************this only for sign licences looking at date paid upto compared to fdate
'     Ln = 11
'     READV ANN FROM BUILD_CODES_DATA,"@ST_" & PICK.EXTRACT(PLANS_REC,4,0,0),2 ELSE ANN=""
'     If Ann <> "Y" Then
'        PRINT @(0,9) & "No annual fee for sign type " & PICK.EXTRACT(PLANS_REC,4,0,0) &
'        GoTo 60
'     End If
'     Yy = Mid$(Ans, 8, 2) + 1
'     Yy = Right(Space(2) & ("00" & Yy), 2)
'     Ans2 = Mid$(Ans, 1, 7) & Yy
'     Ans2 = oconv(ICONV(Ans2, "D2") - 1, "D2")
'
'50   Msg$ = "Fees paid to date &  ": Cls$ = CL: Lns$ = 9: Call SRIP(0, Lns$, Msg$, Ans, Cls$, Ans2, "", "D_ENDIF_", "")
'
'     If Ans = "" Then Ans = Ans2
'     If Ans = "ENDIF" Then GoTo 20
'     Adate = ICONV(Ans, "D2")
'     If Adate <= ICONV(Format$(Now, "DD MMM YY"), "D2") Or Adate <= Fdate Then Printer.Print BELL;: GoTo 50
'
'60   Cls$ = "": Lns$ = Ln: Call SRIP(0, Lns$, "OK to continue (Y/N)? ", Ans, Cls$, "", "", "", "")
'
60:  ReDim Tjdata(10)

     Trinvdate = Fdate
     Tr_Inv_Date = Fdate
     Tr_Inv_Ref2 = Prefix & plan_id

     If Haslimit <> "0" Then checking = 1 Else checking = 2
325:
     Maxi = pick.dcount(pick.extract(plans_rec, 22, 0, 0), Chr(253))
     For I = 1 To Maxi
        maxj = pick.dcount(pick.extract(plans_rec, 22, I, 0), Chr(252))
        For J = 1 To maxj
           Fc = pick.extract(plans_rec, 22, I, J)
           If Fc = "" Then GoTo 340
           If d3.d3_readstr(database, Build, "bl_fee", Fc) <> 0 Then Build = ""
           temp = pick.extract(Build, 10, 0, 0)
           If IsNumeric(temp) Then minimum = CCur(temp) Else minimum = 0
           temp = pick.extract(Build, 8, 0, 0)
           If IsNumeric(temp) Then percent = CCur(temp) Else percent = 0
           temp = pick.extract(Build, 8, 0, 0)
           If IsNumeric(temp) Then Factor = CCur(temp) Else Factor = 0

           Amt = 0
           Select Case pick.extract(Build, 7, 0, 0)
              Case "V" '16
                 temp = pick.extract(Build, 16, 0, 0)
                 If IsNumeric(temp) Then Amt = CCur(temp) Else Amt = 0
                 Amt = Amt * percent * Factor
                 If Amt < minimum Then Amt = minimum
              Case "A" '13
                 temp = pick.extract(Build, 13, 0, 0)
                 If IsNumeric(temp) Then Amt = CCur(temp) Else Amt = 0
                 Amt = Amt * percent * Factor
                 If Amt < minimum Then Amt = minimum
              Case "$"
                 temp = pick.extract(plans_rec, 23, I, J)
                 If IsNumeric(temp) Then Amt = CCur(temp) Else Amt = 0
           End Select
           If Amt = 0 Then GoTo 340
           Gst = pick.extract(Build, 12, 0, 0) 'will be Y if GST to be added
           If Gst = "y" Then
              gstamt = gstrate * Amt / 10000
              Amt = Amt + gstamt
           End If

           GL = pick.extract(Build, 3, 0, 0)
           If GL = "" Then GL = Fc & "feecode missing"
           If GL = "NO" Then GoTo 340
           
           temp = pick.extract(Build, 4, 0, 0) 'commission
           If IsNumeric(temp) Then Comm = CCur(temp) Else Comm = 0
           If pick.extract(Build, 6, 0, 0) = "Y" Then 'gst on commission
              gstcomm = gstrate * Comm / 10000
              Comm = Comm + gstcomm
           End If
           If Amt <= Comm Then GoTo 340
           
           Comgl = pick.extract(Build, 5, 0, 0)
           
           billto = pick.extract(Build, 13, 0, 0) 'A=applicant, O=owner, P=property
           bill_client = Client_No
           Select Case billto
              Case "a": bill_client = Assess
              Case "o": bill_client = Client_No
              Case "p"
                 If d3.d3_readstr(database, Orec, "CLIENT", Assess) <> 0 Then Orec = ""
                 bill_client = pick.extract(Orec, 35, 1, 0) 'first owner
           End Select

           If checking <> 0 Then
              If pick.locate(bill_client, nrec(2), 1, 1, 0, posn, "") = 0 Then
                 nrec(2) = pick.Insert(nrec(2), 1, posn, 0, bill_client)
                 nrec(3) = pick.Insert(nrec(3), 1, posn, 0, "0")
              End If
              temp = pick.extract(nrec(3), 1, posn, 0)
              If IsNumeric(temp) Then tempcur = CCur(temp) Else tempcur = 0
              tempcur = tempcur + Amt
              nrec(3) = pick.Replace(nrec(3), 1, posn, 0, CStr(tempcur))
              GoTo 340
           End If
           
           If d3.d3_readstr(database, Td_Rec, "TDEBTOR", bill_client) <> 0 Then
              TA3140 = "Fees not raised. " & "Plan " & plan_id & ". Debtor " & Client_No & " does not exist"
              Exit Function
           End If
'$INSERT I.LOG.UPDATE "|TDEBTOR|":CLIENT.NO 318 TD.REC
           Tr_Inv_Ref = Tr_Inv_Ref2 & "*" & Fc
           Narr = Assess
           Call SR310(database, CStr(Trinvdate), bill_client, Td_Rec, Tr_Inv_Ref, Tr_Inv_Date, CStr(Amt), Tr_Dr, Narr, Cr_Relation, "", debt_cont, "", g_trans_info_array(14))
           Tjac = debt_cont: Tjjob = 0: Tjcd = Tr_Dr: Tjcost = Amt - gstamt: Tjnarr = Tr_Inv_Ref
           GoSub 777
           Tjac = pick.extract(gstaccs, 2, 0, 0): Tjjob = 0: Tjcd = Tr_Dr: Tjcost = gstamt: Tjnarr = Tr_Inv_Ref
           GoSub 777
           
           Amt = Amt - Comm
           gstamt = gstamt - gstcomm
                      
           If InStr(GL, ".") = 0 Then
330           If d3.d3_readstr(database, Cr_Rec, "CREDITOR", GL) <> 0 Then Cr_Rec = "" '???ignoreUgl = "creditor account " & Gl & " is missing in program 3140": Release CREDITOR_DATA, Gl: GoTo 332
'$INSERT I.LOG.UPDATE '|CREDITOR|':CLIENT.NO2 330 CR.REC
              Call SR340(logentry, Trinvdate, GL, Cr_Rec, Tr_Inv_Ref, Tr_Inv_Date, "", Amt, 0, "", "", 0, 0, Tr_Cr, Narr, Cr_Relation, "", "", "", Cred_Cont)
              rderr = d3.d3_writestr(database, "creditor", GL, Cr_Rec)
              Ugl = Cred_Cont
           Else
              Ugl = GL
           End If
332        Tjac = Ugl: Tjjob = 0: Tjcd = Tr_Cr: Tjcost = Amt - gstamt: Tjnarr = Tr_Inv_Ref
           GoSub 777
           Tjac = pick.extract(gstaccs, 1, 0, 0): Tjjob = 0: Tjcd = Tr_Cr: Tjcost = gstamt: Tjnarr = Tr_Inv_Ref
           GoSub 777
           If Comm <> 0 Then
              Tjac = Comgl: Tjjob = 0: Tjcd = Tr_Cr: Tjcost = Comm - gstcomm: Tjnarr = Tr_Inv_Ref
              GoSub 777
              Tjac = pick.extract(gstaccs, 1, 0, 0): Tjjob = 0: Tjcd = Tr_Cr: Tjcost = gstcomm: Tjnarr = Tr_Inv_Ref
              GoSub 777
           End If
340     Next J
     Next I
     If checking <> 0 Then
        Maxi = pick.dcount(nrec(2), Chr(253))
        For I = 1 To Maxi
           billto = pick.extract(nrec(2), 1, I, 0)
           If d3.d3_readstr(database, Td_Rec, "TDEBTOR", billto) <> 0 Then
              TA3140 = "Plan " & plan_id & ". Fees can NOT be raised. Debtor " & billto & " does not exist "
              Exit Function
           End If
           If billto = 1 Then
              temp = pick.extract(Td_Rec, 3, 0, 0)
              If IsNumeric(temp) Then tempcur = CCur(temp) Else tempcur = 0
              tempcur = tempcur + CCur(pick.extract(nrec(3), 1, I, 0))
              temp = pick.extract(Td_Rec, 29, 0, 0)
              If IsNumeric(temp) Then tempcur2 = CCur(temp) * 100 Else tempcur2 = 0
              If tempcur > tempcur2 And tempcur2 <> 0 Then
                 TA3140 = "Plan " & plan_id & ". Fees can NOT be raised. Debtor " & billto & " credit limit will be exceeded"
                 Exit Function
              End If
           End If
        Next I
        checking = 0
        GoTo 325
     End If

400  rderr = d3.d3_writestr(database, "tdebtor", Client_No, Td_Rec)
410  If d3.d3_readstr(database, plans_rec, "PLANS", plan_id) <> 0 Then
        TA3140 = "Fees not raised. " & "Plan " & plan_id & " does not exist"
        Exit Function
'$INSERT I.QU.REC
     End If
'$INSERT I.LOG.UPDATE "|PLANS|":PLAN.ID 410 PLANS.REC
     plans_rec = pick.Replace(plans_rec, 20, 0, 0, CStr(Fdate))
     If Adate <> "" Then plans_rec = pick.Replace(plans_rec, 43, 0, 0, Adate)
     If pick.extract(plans_rec, 30, 0, 0) <> "" Then
        plans_rec = pick.Replace(plans_rec, 24, 0, 0, "")
        plans_rec = pick.Replace(plans_rec, 30, 0, 0, "")
     End If
     rderr = d3.d3_writestr(database, which_file, plan_id, plans_rec)
     If Allowb4 = 0 Then
        rderr = d3.d3_writestr(database, pr_which_file, plan_id, "")
     End If
     If Tjdata(1) <> "" Then GoSub 900
     temp = "Fees raised for plan " & plan_id & Chr(8) & nrec(1)
     Maxi = pick.dcount(nrec(2), Chr(253))
     For I = 1 To Maxi
        rderr = d3.d3_readstr(database, T_Name, "CLIENT", pick.extract(nrec(2), 1, I, 0), 1)
        If IsNumeric(pick.extract(nrec(3), 1, I, 0)) Then tempcur = CCur(pick.extract(nrec(3), 1, I, 0)) / 100 Else tempcur = 0
        temp = temp & Chr(8) & "Invoiced debtor " & pick.extract(nrec(2), 1, I, 0) & " " & T_Name & " for $" & Format(tempcur, "#.00")
     Next I
     TA3140 = temp
     Exit Function
'
777 For Ll = 1 To 9999
      Glac = pick.extract(Tjdata(3), 1, Ll, 0)
      If Glac = "" Then GoTo 779
      If Glac = Tjac Then
       If pick.extract(Tjdata(1), 1, Ll, 0) = Tjcd And pick.extract(Tjdata(6), 1, Ll, 0) = Tjnarr And pick.extract(Tjdata(2), 1, Ll, 0) = Tjjob Then
         temp = pick.extract(Tjdata(4), 1, Ll, 0)
         If IsNumeric(temp) Then tempcur = CCur(temp) Else tempcur = 0
         Tjdata(4) = pick.Replace(Tjdata(4), 1, Ll, 0, CStr(tempcur + Tjcost))
         GoTo 780
       End If
      End If
    Next Ll
779 Tjdata(3) = pick.Insert(Tjdata(3), 1, -1, 0, Tjac)
    Tjdata(6) = pick.Insert(Tjdata(6), 1, -1, 0, Tjnarr)
    Tjdata(2) = pick.Insert(Tjdata(2), 1, -1, 0, Tjjob)
    Tjdata(1) = pick.Insert(Tjdata(1), 1, -1, 0, Tjcd)
    Tjdata(4) = pick.Insert(Tjdata(4), 1, -1, 0, CStr(Tjcost))
780 Return
'
900  Tjdata(7) = Tr_Inv_Date
950  Tj_Key = Replace(Timer, ".", "") & tj_tno
     If d3.d3_readstr(database, Tj_Rec, "TRANS.J", Tj_Key) <> 0 Then GoTo 960
     'Release TRANS_J_DATA, Tj_Key
     GoTo 950
960
'$INSERT I.LOG.ADD "|TRANS.J|":TJ.KEY 950
     Tjdata(0) = Tj_Key
     rderr = d3.d3_writemat(database, "trans.j", Tjdata())
     Return

End Function

Public Sub srclient(Client_Rec As String, Client_No As String, Name As String, Adr1 As String, Adr2 As String, Adr3 As String, pcode As String, Initials As String, GIVEN As String, title As String, Ptel As String, Btel As String, Telx As String, property As String, Ntype As String, Atype As String, Nameline As String, Addrline As String, Mail As String)

Dim res As Integer
'  subroutine to return name and address details for CLIENTS   *
'  ---------------------------------------------------------   *
'  NTYPE : name types               NAMELINE                   *
'  -----                            --------                   *
'    1     given surname       e.g. JOHN SMITH                 *
'    2     title given surname      MR JOHN SMITH              *
'    3     title initial surname    MR J SMITH                 *
'    4     initial surname          J SMITH                    *
'    5     surname initials         SMITH J                    *
'                                                              *
'  ATYPE : address types            ADDRLINE                   *
'  -----                            --------                   *
'    1     number street            10 LORD ST                 *
'    2     number street suburb     10 LORD ST, PERTH          *
'    3     no. street sub. state    10 LORD ST, PERTH, WA      *
'    4     no. str. sub. st. pcode  10 LORD ST, PERTH, WA 6000 *
'                                                              *
    Name = pick.extract(Client_Rec, 1, 0, 0)
    Initials = pick.extract(Client_Rec, 6, 0, 0)
    GIVEN = pick.extract(Client_Rec, 7, 0, 0)
    title = pick.extract(Client_Rec, 8, 0, 0)
    Btel = pick.extract(Client_Rec, 9, 1, 0)
    Ptel = pick.extract(Client_Rec, 9, 2, 0)
    Telx = pick.extract(Client_Rec, 9, 3, 0)
    property = pick.extract(Client_Rec, 28, 0, 0)
'
    If Mail = "0" Then
       If pick.extract(Client_Rec, 5, 2, 0) <> "" Then res = 2 Else res = 1
    Else
       res = 1
    End If
'
    Adr1 = pick.extract(Client_Rec, 2, res, 0)
    Adr2 = pick.extract(Client_Rec, 3, res, 0)
    Adr3 = pick.extract(Client_Rec, 4, res, 0)
    pcode = pick.extract(Client_Rec, 5, res, 0)
    If pcode <> "" Then pcode = pcode
'
    Nameline = Name
    If property = "1" Then
       GIVEN = ""
    Else
       If GIVEN <> "" Then
          If Ntype = 1 Or Ntype = 2 Then Nameline = GIVEN & " " & Nameline
       End If
       If Initials <> "" Then
          Select Case Ntype
             Case 3, 4: Nameline = Initials & " " & Nameline
             Case 5: Nameline = Nameline & " " & Initials
          End Select
       End If
       If title <> "" Then
          If Ntype = 2 Or Ntype = 3 Then Nameline = title & " " & Nameline
       End If
    End If
'
    Addrline = Adr1
    If Atype <> 1 Then
       If Adr2 <> "" Then Addrline = Addrline & ", " & Adr2
    End If
    If Atype <> 1 And Atype <> 2 Then
       If Adr3 <> "" Then Addrline = Addrline & ", " & Adr3
    End If
    If Atype = 4 Then
       If pcode <> "" Then Addrline = Addrline & " " & pcode
    End If

End Sub

Private Sub Class_Initialize()

ReDim g_trans_info_array(0)

End Sub



Public Function ta194(logentry As String, sentence As String, parms As String) As String
' TA194 REPORT ON OUTSTANDING INVOICES
Dim Rel As String
Dim gtotal As Currency, grun_bal As Currency
Dim gdisc As Currency, gpps As Currency
Dim total_items As Long, kk As Long, Tr_Ref As String
Dim Client_No As String, cr_sec As String
Dim Name As String, GIVEN As String
Dim pclient As String, Cr_Cur_Bal As Currency, run_bal As Currency, Totdisc As Currency, bal_missed As Currency, totpps As Currency
Dim tr_desc As String, foundtrans As Integer, Tr_Narr As String
Dim Usa As String, Chq As String, chq2 As String
Dim cr_terms As String, cr_related As Integer, Discflag As String, cr_ppsno As String, CR_PPS_RATE As Currency
Dim cr_rel_msg As String, Pps_Flg As String, rderr As Integer
Dim relate As String, temp As String
Dim st_po As String, po_total As Currency, rel_total As Currency, rel_disc As Currency, rel_pps As Currency
Dim Client_Rec As String, Cr_Rec As String, Inz As Integer
Dim cr_post As String, tr_type As Integer, TR_BAL As Currency, Tr_Amt As Currency
Dim pcr_related As String, DEF_DISCOUNTS As String, Tr_Disc As Currency
Dim usebal As Currency, Tr_Payment As Currency, balmsg As String
Dim maxn As Integer, Ii As Integer, Mulnarr As String
Dim Disc_Apply As String, pps_apply As String, Openitem As String
Dim Msg As String, great_amt As Currency, draw_amt As Currency
Dim mylist() As String, mycreditors() As String, pick_cnt As Long, led As String, DISC_DATE As Integer, Due_Date As Integer
Dim ff As Integer, fff As Integer, SETONLY As String, datedue As Integer, datedue_str As String
Dim useterms As String, Newterms As String, REMFLAG As String
Dim ACCOUNT As String, Cphead As String, no_auto_sel As String
Dim lastrec As String, Last As Integer, chq_req_rec As String, tj_tno As String
Dim AUTHOR As String, rec As String
Dim Tr_Date As Integer, tr_date_str As String, Disc_Apply_Date As String
Dim Tr_Pps As String, startr As Integer, tjdate As Integer, trec As String
Dim cr_author As String, cr_remit As String, cr_discount As String
Dim Yespay As Integer, Mm As Long, run_amt As Currency, Narr As String
Dim database As String, trid As String
Dim fso, textfile

      On Error GoTo ta194_error
      
      database = pick.extract(logentry, 2, 0, 0)
     
      If d3.d3_readstr(database, ACCOUNT, "DICT RR.LOG", "4", 2, 1, 1) <> 0 Then ACCOUNT = ""
      temp = d3.execute_tcl(logentry, "WHO", "")
      tj_tno = Right("000" & pick.field(temp, " ", 1), 3)
      
      Due_Date = CInt(pick.extract(parms, 1, 0, 0))
      temp = pick.extract(parms, 2, 0, 0)
      If IsNumeric(temp) Then DISC_DATE = CInt(temp) Else DISC_DATE = -1
      SETONLY = pick.extract(parms, 3, 0, 0)
      temp = pick.extract(parms, 4, 0, 0)
      If IsNumeric(temp) Then draw_amt = CCur(temp) Else draw_amt = -1
      temp = pick.extract(parms, 5, 0, 0)
      If IsNumeric(temp) Then great_amt = CCur(temp) Else great_amt = -1
      tjdate = CInt(pick.extract(parms, 6, 0, 0)) 'ledger date for chqs
      led = pick.extract(parms, 7, 0, 0) '"Do you want to print ledger numbers on report (Y/N)? "
      temp = pick.extract(parms, 8, 0, 0)
      If IsNumeric(temp) Then startr = CInt(temp) Else startr = -1
       
      If UBound(g_trans_info_array) = 0 Then
         g_trans_info_array(0) = "TRANS.INFO"
         rderr = d3.d3_readmat(database, g_trans_info_array(), "DICT TRANS.J")
      End If
      If UBound(g_trans_info_array) < 113 Then ReDim Preserve g_trans_info_array(113)
      AUTHOR = g_trans_info_array(25): If AUTHOR = "" Then AUTHOR = "0"
      Usa = g_trans_info_array(106): If Usa = "1" Then Chq = "Check": chq2 = "check" Else Chq = "Cheque": chq2 = "cheque"
      Discflag = pick.extract(g_trans_info_array(38), 1, 2, 0): If Discflag = "" Then Discflag = "0"
      Newterms = pick.extract(g_trans_info_array(38), 1, 3, 0): If Newterms = "" Then Newterms = "0"
      Openitem = Mid((g_trans_info_array(49)), 4, 1): If Openitem = "" Or Openitem = " " Then Openitem = "0"
      
      REMFLAG = Mid$((g_trans_info_array(49)), 1, 1)
      If Not (IsNumeric(REMFLAG)) Then REMFLAG = "0"
      no_auto_sel = Mid$(g_trans_info_array(49), 13, 1)
      If Not (IsNumeric(no_auto_sel)) Then REMFLAG = "0"
      cr_sec = Mid(g_trans_info_array(49), 18, 1): If cr_sec = "" Then cr_sec = "0"
      Pps_Flg = pick.extract(g_trans_info_array(113), 1, 1, 0): If Pps_Flg = "" Then Pps_Flg = "0"
       
      ta194 = d3.rtf_open(logentry, fso, textfile, ".asp")
      temp = "<TABLE cellspacing=1 cellpadding=1 border=1 WIDTH=95%><TR CLASS=top><TH COLSPAN=14 ALIGN=CENTER>194 Report on Outstanding Invoices as at " & Now & " due to " & pick.oconv(CStr(Due_Date), "D2")
      If startr <> -1 Then temp = temp & "COMMENCING FROM " & Format(startr, "dd mmm yy") & " "
      If DISC_DATE <> -1 Then
         temp = temp & "<TR CLASS=top><TH COLSPAN=14 ALIGN=CENTER>Discounts Calculated as at " & pick.oconv(CStr(DISC_DATE), "D2")
         If SETONLY = "Y" Then temp = temp & ". Only items with settlement discount" Else temp = temp & ". All items with or without settlement discount"
      End If
      textfile.WriteLine (temp)
      temp = ""
      If draw_amt <> -1 Then temp = "<TR CLASS=top><TH COLSPAN=14 ALIGN=CENTER>WITH PAYMENT NOT EXCEEDING " & Format(draw_amt / 100, "#.00") & ". "
      If great_amt <> -1 Then
         If draw_amt = -1 Then temp = "<TR CLASS=top><TH COLSPAN=14 ALIGN=CENTER>"
         temp = temp & "WITH PAYMENT IN EXCESS OF " & Format(great_amt / 100, "#.00") & ". "
      End If
      temp = temp & "<TR CLASS=TOP><TH>Rel<TH>Client<TH>Name<TH>Reference<TH>Type<TH>Date<TH>Due<TH>Amount<TH>Balance<TH>Discount<TH>PPS Tax<TH>Net Due<TH>Narrative"
      If led = "Y" Then temp = temp & "<TH>G/L Accounts"
      textfile.WriteLine (temp)

'      Call SR190(PROG, TJ_TNO, HEAD, msg, BRK(), BRKCT, CR_SELECTED, ENTRY_NO, PASS_TEXT)
'      Call SR210(Line, RPFLAG, DUE_DATE, today_date, CHQ2, DRAW_AMT, TJDATE, VFDATE, VTDATE, DISCFLAG, disc_date, GREAT_AMT, 0, 0, SUFNDS, SETONLY, CR_SELECTED, "0", OPENITEM, STARTR)
       
      If no_auto_sel = "0" Then    ' store auto selection, if reqd
30      If d3.d3_readstr(database, lastrec, "DICT CHQ.REQ", "@194") <> 0 Then lastrec = "X"
        temp = pick.extract(lastrec, 2, 0, 0)
        If IsNumeric(temp) Then Last = CInt(temp) Else Last = 0
        Last = Last + 1: lastrec = pick.Replace(lastrec, 2, 0, 0, CStr(Last))
        rderr = d3.d3_writestr(database, "DICT CHQ.REQ", "@194", lastrec)
        temp = "@194-" & Last
50      If d3.d3_readstr(database, chq_req_rec, "DICT CHQ.REQ", temp) <> 0 Then GoTo 75
        'Release CHQ_REQ_DICT, last
        GoTo 30
75      rec = "PROC" & tj_tno & Chr(254) & Msg
        rderr = d3.d3_writestr(database, "DICT CHQ.REQ", CStr(Last), rec)
      End If

      If d3.d3_readstr(database, relate, "DICT CLIENT", "@CR_RELATION") <> 0 Then relate = ""
      st_po = "": po_total = 0: rel_total = 0: gtotal = 0: rel_disc = 0: gdisc = 0: rel_pps = 0
      gpps = 0: grun_bal = 0
   
      sentence = Replace(sentence, Chr(8), """")
      total_items = d3.d3_select(logentry, sentence, mycreditors(), pick_cnt, 0, 0) - 1
      If total_items = 0 Then ta194 = Chr(8) & "No creditors for " & sentence: Exit Function
   
      sentence = "sselect cr_trans by a1 by trdate with trbal # ""0"" "
      total_items = d3.d3_select(logentry, sentence, mylist(), pick_cnt, 0, 0) - 1
      If total_items = 0 Then ta194 = Chr(8) & "No transactions for " & sentence: Exit Function
      
      pclient = Chr(8)
      run_bal = 0: Totdisc = 0: totpps = 0: run_amt = 0
      
      For kk = 0 To total_items
         trid = mylist(kk)
         If d3.d3_readstr(database, trec, "CR_TRANS", trid) <> 0 Then trec = ""
         Client_No = pick.extract(trec, 1, 0, 0)
         If Client_No = pclient Then GoTo 112
         For Mm = 0 To UBound(mycreditors)
            If Client_No = mycreditors(Mm) Then GoTo 112
         Next Mm
         GoTo 890 ' creditor not wanted
      
112:  If pclient = Chr(8) Then pclient = Client_No
      If Client_No <> pclient Then GoSub client_subtotal

      If d3.d3_readstr(database, Client_Rec, "CLIENT", Client_No) <> 0 Then Client_Rec = ""
      If d3.d3_readstr(database, Cr_Rec, "CREDITOR", Client_No) <> 0 Then Cr_Rec = ""
      Rel = pick.extract(Cr_Rec, 3, 0, 0): If Rel = "" Then Rel = "0"
'      If cr_sec And pick.extract(operator, 4, 0, 0) <> "" Then
'         FOR III=1 TO 999 UNTIL OPERATOR=PICK.REPLACE(OPERATOR,4,1,III,"")
'            REL2 = pick.extract(operator, 4, 1, iii)
'            If rel = REL2 Then GoTo 215
'         Next iii
'         GoTo 890
'      End If
215   Name = pick.extract(Client_Rec, 1, 1, 0)
      GIVEN = pick.extract(Client_Rec, 7, 0, 0)
      
'
' BEGIN PRINT OF TRANSACTIONSt
'
      Cr_Cur_Bal = pick.extractcur(Cr_Rec, 1, 0, 0)
      
      cr_terms = pick.extract(Cr_Rec, 2, 0, 0)
      If cr_terms = "" Then cr_terms = "30"
      foundtrans = 0
      cr_post = pick.extract(Cr_Rec, 15, 0, 0)
      temp = pick.extractint(Cr_Rec, 3, 0, 0)
      If IsNumeric(temp) Then cr_related = CInt(temp) Else cr_related = 1
      pcr_related = temp
      If Discflag <> "0" Then DEF_DISCOUNTS = pick.extract(Cr_Rec, 30, 0, 0)
      cr_ppsno = pick.extract(Cr_Rec, 37, 1, 0)
      CR_PPS_RATE = 0
      If Pps_Flg <> "0" Then
         If d3.d3_readstr(database, temp, "PPS.PAYEE", cr_ppsno, 9) <> 0 Then temp = ""
         If IsNumeric(temp) Then CR_PPS_RATE = CCur(temp) Else CR_PPS_RATE = 0
      End If
      cr_rel_msg = pick.extract(relate, cr_related + 1, 0, 0)
      If cr_rel_msg <> "" Then cr_rel_msg = "(" & cr_rel_msg & ")"

      cr_author = pick.extract(trec, 10, 0, 0)
      cr_remit = pick.extract(trec, 11, 0, 0)
      cr_discount = pick.extract(trec, 15, 0, 0)
      Tr_Pps = pick.extract(trec, 17, 0, 0) ''''**** NOTE TR.PPS CAN CONTAIN Y\override amt
      Tr_Date = pick.extractint(trec, 2, 0, 0)
      tr_type = pick.extractint(trec, 3, 0, 0)
      Tr_Ref = pick.extract(trec, 4, 0, 0)
      Tr_Amt = pick.extractcur(trec, 5, 0, 0)
      TR_BAL = pick.extractcur(trec, 6, 0, 0)
      Tr_Narr = pick.extract(trec, 7, 0, 0)
'
      If Openitem = "0" And tr_type >= 50 Then GoTo 890
      If tr_type >= 50 Then TR_BAL = -TR_BAL: Tr_Amt = -Tr_Amt
      If Openitem = "0" And TR_BAL <= 0 Then GoTo 890
      If Newterms <> "0" Then
         useterms = pick.extract(trec, 16, 0, 0)
         If useterms = "" Then useterms = cr_terms
      Else
         useterms = cr_terms
      End If
      If IsNumeric(useterms) Then datedue = Tr_Date + CInt(useterms) Else datedue = Tr_Date
      If datedue > Due_Date Then GoTo 890
      Disc_Apply = "": Tr_Disc = 0: Disc_Apply_Date = ""
      pps_apply = ""
'
      Call SR211(database, AUTHOR, cr_author, Tr_Payment, Tr_Amt, TR_BAL, Discflag, tr_type, DISC_DATE, Tr_Date, cr_discount, DEF_DISCOUNTS, Tr_Disc, REMFLAG, cr_remit, Yespay, SETONLY, Disc_Apply, Disc_Apply_Date, Pps_Flg, CR_PPS_RATE, Tr_Pps)
'
      If Yespay = 0 Then GoTo 890
      If Disc_Apply_Date <> "" Then
'           DISC_APPLY_DATE = "by " & oconv(tr_date + DISC_APPLY_DATE, "D2")
      End If
         If Disc_Apply <> "" Then
'           DISC_APPLY=SPACE(40+ADJ) & ("Discount of " & DISC_APPLY & "% if paid " & DISC_APPLY_DATE) "L<>40" & OCONV(-TR_DISC,"MD2") "R2<>10"
'           IF pick.extract(TR_PPS,1,1,1) = "" THEN DISC_APPLY=DISC_APPLY & " " & OCONV(TR_PAYMENT,"MD2") "R2<>10"
         End If
         If pick.extract(Tr_Pps, 1, 1, 1) <> "" Then
'           PPS_APPLY=SPACE(40+ADJ) & "Prescribed Payments tax  " "L<>40" & OCONV(pick.extract(-TR_PPS,1,1,1),"MD2") "R2<>10" & " " & OCONV(TR_PAYMENT,"MD2") "R2<>10"
         End If
         If Openitem <> "0" And startr <> -1 And Tr_Date < startr Then
           bal_missed = bal_missed + TR_BAL
           GoTo 890
         End If

      tr_desc = ""
      If tr_type <> 0 Then tr_desc = pick.extract(g_trans_info_array(3), 1, tr_type, 0)
      If tr_desc = "" Then tr_desc = CStr(tr_type)
      foundtrans = 1
      If Pps_Flg <> "0" Then usebal = TR_BAL Else usebal = Tr_Payment
      run_bal = run_bal + usebal: Totdisc = Totdisc + Tr_Disc: run_amt = run_amt + Tr_Amt
      totpps = totpps + pick.extractcur(Tr_Pps, 1, 1, 1)
'
      rel_total = rel_total + TR_BAL: rel_disc = rel_disc + Tr_Disc
      rel_pps = rel_pps + pick.extractcur(Tr_Pps, 1, 1, 1)
      tr_date_str = Format(Tr_Date, "dd mmm yy"): tr_date_str = Mid$(tr_date_str, 1, 2) & Mid$(tr_date_str, 4, 3) & Mid$(tr_date_str, 8, 2)
      datedue_str = Format(datedue, "dd mmm yy"): datedue_str = Mid$(datedue_str, 1, 2) & Mid$(datedue_str, 4, 3) & Mid$(datedue_str, 8, 2)
      temp = "<TR><TD>" & pcr_related
      temp = temp & "<TD>" & pclient & "<TD> " & Name & " " & GIVEN & "<TD>" & Tr_Ref & "<TD>" & tr_desc & "<TD NOWRAP>" & pick.oconv(CStr(Tr_Date), "D2") & "<TD NOWRAP>" & pick.oconv(CStr(datedue), "D2") & "<TD align=right>" & Format(Tr_Amt / 100, "#.00")
      temp = temp & "<TD align=right>" & Format(usebal / 100, "#.00") & "<TD align=right>" & Format(Tr_Disc / 100, "#.00") & "<TD align=right>" & Format(-pick.extractcur(Tr_Pps, 1, 1, 1) / 100, "#.00")
      temp = temp & "<TD align=right>" & Format(Tr_Payment / 100, "#.00")
      If Tr_Amt <> TR_BAL And (Disc_Apply <> "" Or pps_apply <> "") Then
        balmsg = "Previously paid " & Format((TR_BAL - Tr_Amt) / 100, "#.00")
      Else
        balmsg = ""
      End If
      'If pps_apply <> "" Then Tr_Narr = pps_apply & Chr(253) & Tr_Narr
      'If Disc_Apply <> "" Then Tr_Narr = Disc_Apply & Chr(253) & Tr_Narr
      'If balmsg <> "" Then Tr_Narr = balmsg & Chr(253) & Tr_Narr
      temp = temp & "<TD>"
      For Ii = 1 To pick.dcount(Tr_Narr, Chr(252))
          Narr = pick.extract(Tr_Narr, 1, 1, Ii)
          If Narr <> "" Then
             If Ii <> 1 Then Narr = "<BR>" & Narr
             temp = temp & Narr
          End If
      Next Ii
      If led = "Y" And tr_type = 25 Then temp = temp & "<TD>" & Replace(pick.extract(trec, 8, 0, 0), Chr(252), ",")
      textfile.WriteLine (temp)
890:
   Next kk
   
     GoSub client_subtotal
     temp = "<TR><TD colspan=7><B>Grand Totals for payment by " & pick.oconv(CStr(Due_Date), "d2") & "</B><TD align=right nowrap><B>" & Format(gtotal / 100, "#.00") & "</B><TD align=right nowrap><B>" & Format(grun_bal / 100, "#.00") & "</B><TD align=right nowrap><B>" & Format(-gdisc / 100, "#.00") & "</B><TD align=right nowrap><B>" & Format(-gpps / 100, "#.00") & "</B><TD align=right nowrap><B>" & Format((grun_bal - gdisc - gpps) / 100, "#.00") & "</B>"
     textfile.WriteLine (temp)

     textfile.WriteLine ("</TABLE>")
     textfile.WriteLine ("</BODY>")
     textfile.WriteLine ("</HTML>")
     textfile.Close
     Set textfile = Nothing
     Set fso = Nothing
     Exit Function

client_subtotal:
     temp = "<TR><TD><B>" & pcr_related & "</B><TD><B>" & pclient & "</B><TD><B>" & Name & " " & GIVEN & "</B>"
     pclient = Client_No
     If run_bal = 0 Then Return
     If foundtrans = 0 Then
        If Openitem <> "0" And bal_missed Then
'          PMSG=PMSG & PCLIENT "R<>7" & " " & NAME & " " & GIVEN
'          GoTo 226
        End If
        Return
     End If
       
     temp = temp & "<TD colspan=4><B>Totals for payment by " & pick.oconv(CStr(Due_Date), "d2") & "</B><TD align=right nowrap><B>" & Format(run_amt / 100, "#.00") & "</B><TD align=right nowrap><B>" & Format(run_bal / 100, "#.00") & "</B><TD align=right nowrap><B>" & Format(-Totdisc / 100, "#.00") & "</B><TD align=right nowrap><B>" & Format(-totpps / 100, "#.00") & "</B><TD align=right nowrap><B>" & Format((run_bal - Totdisc - totpps) / 100, "#.00") & "</B>"
        
     Msg = ""
226  If Openitem <> "0" And run_bal <= 0 Then Msg = "NO PAYMENT will be paid"
     If draw_amt <> -1 And run_bal > draw_amt Then
        Msg = "NO PAYMENT as greater than " & Format(draw_amt / 100, "#.00")
        run_bal = 0
     End If
     If great_amt <> -1 And run_bal <= great_amt Then
        Msg = "NO PAYMENT as less than " & Format(great_amt / 100, "#.00")
        run_bal = 0
     End If
     temp = temp & "<TD>" & Msg
     textfile.WriteLine (temp)
     If run_bal > 0 Then
        gtotal = gtotal + run_amt
        gdisc = gdisc + Totdisc
        gpps = gpps + totpps
        grun_bal = grun_bal + run_bal
     End If
'
     If Openitem <> "0" And bal_missed Then
        temp = "<TR><TD colspan=7>** Balance of transactions prior to " & pick.oconv(CStr(startr), "D2") & " and NOT reported = " & "<TD>" & Format(bal_missed / 100, "#.00") & " **"
        textfile.WriteLine (temp)
     End If
     run_bal = 0: Totdisc = 0: bal_missed = 0: totpps = 0
     Return
    
ta194_error:
   ta194 = Chr(8) & Err & "-" & Error(Err)
   Exit Function
   
End Function
Public Function ta1465(logentry As String, sentence As String, parms As String)

' TA1465 PRINT ASSET REGISTER

Dim Yrbegin As Integer, Grp, bylocn, soils As Integer
Dim run_type As String
Dim Totsonly As String, desc As String
Dim St_Price As Currency
Dim St_Open_Bal As Currency, St_Ytd_Depn As Currency, St_Depd_Val As Currency, St_Ltd_Depn As Currency, T_Price As Currency
Dim T_Open_Bal As Currency, T_Ytd_Depn As Currency, T_Depd_Val As Currency, T_Ltd_Depn As Currency, D_Price As Currency, D_Open_Bal As Currency
Dim D_Ytd_Depn As Currency, D_Depd_Val As Currency, D_Ltd_Depn As Currency, Ct_Price As Currency, Ct_Open_Bal As Currency
Dim Ct_Ytd_Depn As Currency, Ct_Depd_Val As Currency, Ct_Ltd_Depn As Currency, Cd_Price As Currency, Cd_Open_Bal As Currency
Dim Cd_Ytd_Depn As Currency, Cd_Depd_Val As Currency, Cd_Ltd_Depn As Currency, Cl_Ytd_Depn As Currency, Clt_Ytd_Depn As Currency
Dim St_Code As String, St_Group As String, St_Type As String
Dim Gt_Price As Currency, Gt_Open_Bal As Currency, Gt_Ytd_Depn As Currency, Gt_Depd_Val As Currency, Gt_Ltd_Depn As Currency
Dim Class_Array As String, Class_Cnt As Integer
Dim Temp_St_Group As String, Total_Str As String, Total_Class As String, Total_Cnt As Integer, Locn As String
Dim Locn_Desc As String, Ccode As String, tcode As String, Type_Desc As String, Class_Desc As String, Gl_Ac_Desc As String
Dim depd_val As Currency, Pos As Integer, Ltd_Depn As Currency, Open_Bal As Currency, Dis_Open As Currency, Price As Currency
Dim Ytd_Depn As Currency, Assetno As String, Tot_Pos As Integer, Proj As String
Dim dd As Integer, sorting As String, indx As Integer, Ass As String, grp_num As String, Ans As String
Dim fso, textfile, kk As Integer, temp As String, database As String, rderr As Integer
Dim total_items As Long, pick_cnt As Long, mylist() As String, row As Integer
'
      database = pick.extract(logentry, 2, 0, 0)
      
      If UBound(g_trans_info_array) = 0 Then
         g_trans_info_array(0) = "TRANS.INFO"
         rderr = d3.d3_readmat(database, g_trans_info_array(), "DICT TRANS.J")
      End If
      If UBound(g_trans_info_array) < 130 Then ReDim Preserve g_trans_info_array(130)
      
      Yrbegin = pick.extractint(g_trans_info_array(8), 1, 1, 0)
      'Grp = Mid$((pick.extract(Trans_Info, 73, 0, 0)), 2, 1) + 0
      'Bylocn = Mid$(pick.extract(Trans_Info, 73, 0, 0), 4, 1) + 0 ' 1=LOCN BY GROUP 2 LOCN BY CLASS
      'Special_Grp = Mid$(pick.extract(Trans_Info, 73, 0, 0), 7, 1) + 0
      temp = Mid$(g_trans_info_array(73), 10, 1)
      If IsNumeric(temp) Then soils = CInt(temp) Else soils = 0
'
      run_type = "A"
      dd = pick.extractint(parms, 1, 0, 0)
      Totsonly = pick.extract(parms, 2, 0, 0)
      sorting = pick.extract(parms, 3, 0, 0)
      Select Case sorting
         Case "BY LOCN BY PROJECT BY GROUP BY ASSET.NO": bylocn = 1: soils = 1
         Case "BY LOCN BY GROUP BY ASSET.NO": bylocn = 1
         Case "BY LOCN BY CLASS BY ASSET.NO": bylocn = 2
         Case "BY GL.ACC BY ASSET.NO": bylocn = 0: Grp = 0
         Case "BY TYPE BY CLASS BY GROUP BY PUR_DATE BY ASSET.NO": bylocn = 0: Grp = 1
      End Select
      sentence = Replace(sentence, Chr(8), """") & " " & sorting
'
      'If Bylocn Then
      '   If Soils Then
      '      Sel = "LOCN BY PROJECT BY GROUP"
      '   Else
      '      If Bylocn = 1 Then Sel = "LOCN BY GROUP" Else Sel = "LOCN BY CLASS"
      '   End If
      'Else
      '   If Grp Then
      '       Sel = "TYPE BY CLASS BY GROUP BY PUR_DATE"
      '   Else
      '       Sel = "GL_ACC"
      '   End If
      'End If
      'Sent = "SSELECT ASSET BY " & Sel & " BY ASSET_NO" & Xx

      'If Grp And Bylocn = 0 Then H_TEXT4A = "GROUP " Else H_TEXT4A = Space(6)
      ''If Soils Then H_Text4b = "EQTY " Else H_Text4b = "LOC`N"
      'H_Text1a = "FOR MONTH OF "
      'H_Text1b = HEADP$
      'H_Text2 = "ACCUMULATED DEPRECIATION GENERAL LEDGER ACCOUNT "
      'H_TEXT3  = "ASSET" & SPACE(40) & "PURCHASE     PURCHASE     CURRENT      DEPRECIATION    DEPREC"N    LIFE_T_D_   "
      'H_Text4 = "NO_       DESCRIPTION" & Space(12) & H_TEXT4A & H_Text4b & "   DATE        PRICE     DEP`D VALUE   TYPE RATE FREQ   CURR_ YR_    DEPREC`N  "
      'If Bylocn Then
      '   If Soils Then
      '      T_Text = "TOTAL PROJECT "
      '      If d3.d3_readstr(Projects, "DICT LOCATION", "@PROJECT") <> 0 Then Projects = ""
      '   Else
      '      T_Text = "TOTAL LOCATION "
      '   End If
      '   Ct_Text = "TOTAL CURRENT ASSETS COMPANY "
      '   Ct_Text1 = "TOTAL DISPOSED ASSETS COMPANY "
      '   Ct_Text2 = "TOTAL ASSETS COMPANY "
      '   If Bylocn = 2 Then ST_TEXT = "TOTAL CLASS " Else ST_TEXT = "TOTALS GROUP "
      'Else
      '   If Grp Then T_Text = "TOTAL CLASS " Else T_Text = "TOTALS G/L A/C "
      'End If
      'Gt_Text = "TOTAL FOR ALL CURRENT ASSETS "
      'Gt_Text1 = "TOTAL FOR ALL DISPOSED ASSETS "
      'Gt_Text2 = "TOTAL FOR ALL ASSETS "
      St_Price = 0: St_Open_Bal = 0: St_Ytd_Depn = 0: St_Depd_Val = 0: St_Ltd_Depn = 0
      T_Price = 0: T_Open_Bal = 0: T_Ytd_Depn = 0: T_Depd_Val = 0: T_Ltd_Depn = 0
      D_Price = 0: D_Open_Bal = 0: D_Ytd_Depn = 0: D_Depd_Val = 0: D_Ltd_Depn = 0
      Ct_Price = 0: Ct_Open_Bal = 0: Ct_Ytd_Depn = 0: Ct_Depd_Val = 0: Ct_Ltd_Depn = 0
      Cd_Price = 0: Cd_Open_Bal = 0: Cd_Ytd_Depn = 0: Cd_Depd_Val = 0: Cd_Ltd_Depn = 0
      Cl_Ytd_Depn = 0: Clt_Ytd_Depn = 0
'
      St_Code = "": St_Group = "": St_Type = ""
      Gt_Price = 0: Gt_Open_Bal = 0: Gt_Ytd_Depn = 0: Gt_Depd_Val = 0: Gt_Ltd_Depn = 0
      If run_type = "A" Then indx = 0 Else indx = 7

      ta1465 = d3.rtf_open(logentry, fso, textfile, ".asp")
      temp = "<TABLE cellspacing=1 cellpadding=1 border=1 WIDTH=95%><TR CLASS=top><TD colspan=14 align=center>Asset Register as at " & Now & " to " & pick.oconv(CStr(dd), "D2") & "<TR CLASS=TOP><TH><TH><TH><TH><TH><TH><TH><TH colspan=5>Depreciation<TH colspan=3>Disposal<TR class=top><TH>Asset<TH>Description<TH>Group<TH>Location<TH>Purchase Date<TH>Purchase Price<TH>Current Depreciated Value<TH>Type<TH>Rate<TH>Freq<TH>Current Year<TH>Life to Date<TH>Date<TH>Price<TH>Reference"
      textfile.WriteLine (temp)
'
      Class_Array = "": Class_Cnt = 0
      If bylocn = 2 Then
         Temp_St_Group = "": Total_Str = ""
         Total_Class = "": Total_Cnt = 0
         'C_Text = "TOTAL FOR ALL CLASS "
      End If

   total_items = d3.d3_select(logentry, sentence, mylist(), pick_cnt, 0, 0) - 1

   For kk = 0 To total_items
      Assetno = mylist(kk)
      If d3.d3_readstr(database, Ass, "ASSET", Assetno) <> 0 Then GoTo 290
      Locn = pick.extract(Ass, 4, 0, 0)
      If soils Then Locn = Locn & "," & pick.extract(Ass, 61, 0, 0)
      If bylocn Then
         If bylocn = 1 Or soils Then
            If Locn <> St_Code Or pick.extract(Ass, 37, 0, 0) <> St_Group Then ' TEST FOR CHANGE IN LOCATION
                If St_Group <> "" Then GoSub 940
                St_Group = pick.extract(Ass, 37, 0, 0)
                If Locn <> St_Code Then
                   If St_Code <> "" Then GoSub 950       ' PRINT PRIOR TOTAL
                   St_Code = Locn
                   If d3.d3_readstr(database, Locn_Desc, "LOCATION", pick.field(St_Code, ",", 1), 1) <> 0 Then Locn_Desc = "** INVALID LOCATION **"
                   GoSub 900                  ' PRINT NEW PAGE HEADINGS
                End If
            End If
         Else
            'If Special_Grp Then
            '   If d3.d3_readstr(database, Ccode, "ASSET.GROUP", pick.extract(ass, 37, 0, 0), 2) <> 0 Then Ccode = "*** INVALID CLASS ***"
            'Else
               Ccode = pick.extract(Ass, 97, 0, 0): If Ccode = "" Then Ccode = "?"
            'End If
            If Locn <> St_Code Or Ccode <> St_Group Then   ' TEST FOR CHANGE IN LOCATION
                If St_Group <> "" Then
                   GoSub 940
                   GoSub 300                 ' STORE CLASS TOTAL IN ARRAY
                   Temp_St_Group = St_Group
                End If
                St_Group = Ccode
                If Locn <> St_Code Then
                   If St_Code <> "" Then GoSub 950      ' PRINT PRIOR TOTAL
                   If Mid$(Locn, 1, 2) <> Mid$(St_Code, 1, 2) Then
                      If St_Code <> "" Then
                          If Temp_St_Group <> "" Then GoSub 310: St_Group = Ccode
                      End If
                      If St_Code <> "" Then GoSub 960 ' PRINT COMPANY TOTAL
                   End If
                   St_Code = Locn
                   If d3.d3_readstr(database, Locn_Desc, "LOCATION", St_Code, 1) <> 0 Then Locn_Desc = "** INVALID LOCATION **"
                   GoSub 900                  ' PRINT NEW PAGE HEADINGS
                End If
            End If
        End If
      Else
         If Grp Then
            'If Special_Grp Then
            '   If d3.d3_readstr(database, Ccode, "ASSET.GROUP", pick.extract(ass, 37, 0, 0), 2) <> 0 Then Ccode = "*** INVALID CLASS ***"
            'Else
               Ccode = pick.extract(Ass, 97, 0, 0): If Ccode = "" Then Ccode = "?"
            'End If
            If d3.d3_readstr(database, tcode, "ASSET.CODES", "@C." & Ccode, 3) <> 0 Then tcode = ""
            If tcode = "" Then tcode = "?"
            If tcode <> St_Type Then
               If St_Type <> "" Then
                  GoSub 950
                  GoSub 955
               End If
               St_Type = tcode
               If d3.d3_readstr(database, Type_Desc, "ASSET.CODES", "@T." & St_Code, 2) <> 0 Then Type_Desc = ""
               St_Code = Ccode
               If d3.d3_readstr(database, Class_Desc, "ASSET.CODES", "@C." & St_Code, 2) <> 0 Then Class_Desc = ""
               GoSub 900
            Else
               If Ccode <> St_Code Then
                  If St_Code <> "" Then GoSub 950          ' PRINT PRIOR TOTAL
                  St_Code = Ccode
                  If d3.d3_readstr(database, Class_Desc, "ASSET.CODES", "@C." & St_Code, 2) <> 0 Then Class_Desc = ""
                  GoSub 900          ' PRINT NEW PAGE HEADINGS
               End If
            End If
         Else
            If pick.extract(Ass, 1, 0, 0) <> St_Code Then           ' TEST FOR CHANGE IN GL A/C NUMBER
                If St_Code <> "" Then GoSub 950       ' PRINT PRIOR TOTAL
                St_Code = pick.extract(Ass, 1, 0, 0)
                If d3.d3_readstr(database, Gl_Ac_Desc, "ASSET.CODES", St_Code, 2) <> 0 Then Gl_Ac_Desc = "** INVALID GL A/C **"
                GoSub 900                  ' PRINT NEW PAGE HEADINGS
            End If
         End If
     End If
'
      If run_type = "A" Then Price = pick.extractcur(Ass, 6, 0, 0) Else Price = pick.extractcur(Ass, 22, 0, 0)
      If pick.locate(CStr(dd), Ass, 11, 1, 0, Pos, "DR") = 0 Then Pos = 1
      depd_val = pick.extractcur(Ass, 12 + indx, Pos, 0)
      Ltd_Depn = Price - depd_val
      Ltd_Depn = Ltd_Depn / 100
      depd_val = depd_val / 100
      Open_Bal = pick.extractcur(Ass, 13 + indx, 0, 0)
      Dis_Open = Open_Bal
      If pick.extractint(Ass, 5, 0, 0) > Yrbegin And Open_Bal = 0 Then Open_Bal = Price
      Price = Price / 100
      Dis_Open = Dis_Open / 100
      Ytd_Depn = Open_Bal / 100 - depd_val
      grp_num = pick.extract(Ass, 37, 0, 0)
      If Totsonly = "N" Then
'        PRINT ASSETNO'L#9':' ':ASS<3,1>'L#22':GRP.NUM"R#6":SPACE(1):LOCN'R#4':SPACE(1):pick.oconv(ASS<5>,'D2'):PRICE'R2$,#13':ASS<2>'R#12':SPACE(4):ASS<7+INDX>"L#2":pick.oconv(ASS<8+INDX>,'MD2')'R2#6':ASS<9+INDX>"R#2":DIS.OPEN'R2$,#14':DEPD.VAL'R2$,#13':YTD.DEPN'R2$,#13'
         If soils Then Ans = pick.extract(Ass, 63, 0, 0) Else Ans = Locn
         desc = pick.extract(Ass, 3, 0, 0)
         For row = Len(desc) To 1 Step -1
            If Mid(desc, row, 1) <> Chr(253) Then Exit For
            desc = Left(desc, row - 1)
         Next row
         desc = Replace(desc, Chr(253), "<BR>")
         temp = "<TR><TD>" & Assetno & "<TD>" & desc & "<TD>" & grp_num & "<TD>" & Ans & "<TD>" & pick.oconv(pick.extract(Ass, 5, 0, 0), "D2") & "<TD align=right>" & Price & "<TD align=right>" & depd_val & "<TD>" & pick.extract(Ass, 7 + indx, 0, 0) & "<TD align=right>" & pick.oconv(pick.extract(Ass, 8 + indx, 0, 0), "MD2") & "<TD align=right>" & pick.extract(Ass, 9 + indx, 0, 0) & "<TD align=right>" & Ytd_Depn & "<TD align=right>" & FormatCurrency(Ltd_Depn, 2)
         If pick.extractint(Ass, 23, 0, 0) <= dd And pick.extractint(Ass, 23, 0, 0) <> 0 Then
            temp = temp & "<TD>" & pick.oconv(pick.extract(Ass, 23, 0, 0), "D2") & "<TD align=right>" & pick.oconv(pick.extract(Ass, 24, 0, 0), "MD2") & "<TD>" & pick.extract(Ass, 25, 0, 0)
         End If
         textfile.WriteLine (temp)
      End If
'
      If pick.extract(Ass, 23, 0, 0) <> "" Then
         If pick.extractint(Ass, 23, 0, 0) <= dd Then
            Cd_Price = Cd_Price + Price
            Cd_Open_Bal = Cd_Open_Bal + Dis_Open
            Cd_Ytd_Depn = Cd_Ytd_Depn + Ytd_Depn
            Cd_Depd_Val = Cd_Depd_Val + depd_val
            Cd_Ltd_Depn = Cd_Ltd_Depn + Ltd_Depn
            D_Price = D_Price + Price
            D_Open_Bal = D_Open_Bal + Dis_Open
            D_Ytd_Depn = D_Ytd_Depn + Ytd_Depn
            D_Depd_Val = D_Depd_Val + depd_val
            D_Ltd_Depn = D_Ltd_Depn + Ltd_Depn
'
            Cl_Ytd_Depn = Cl_Ytd_Depn + Ytd_Depn
            Clt_Ytd_Depn = Clt_Ytd_Depn + Ytd_Depn
'
            GoTo 200
         End If
      End If
'
      St_Price = St_Price + Price
      St_Open_Bal = St_Open_Bal + Dis_Open
      St_Ytd_Depn = St_Ytd_Depn + Ytd_Depn
      St_Depd_Val = St_Depd_Val + depd_val
      St_Ltd_Depn = St_Ltd_Depn + Ltd_Depn
      T_Price = T_Price + Price
      T_Open_Bal = T_Open_Bal + Dis_Open
      T_Ytd_Depn = T_Ytd_Depn + Ytd_Depn
      T_Ltd_Depn = T_Ltd_Depn + Ltd_Depn
      T_Depd_Val = T_Depd_Val + depd_val
      Ct_Price = Ct_Price + Price
      Ct_Open_Bal = Ct_Open_Bal + Dis_Open
      Ct_Ytd_Depn = Ct_Ytd_Depn + Ytd_Depn
      Ct_Depd_Val = Ct_Depd_Val + depd_val
      Ct_Ltd_Depn = Ct_Ltd_Depn + Ltd_Depn
200
290  Next kk
     

         If bylocn Then
            GoSub 940
            GoSub 300                    ' STORE CLASS TOTAL IN ARRAY
         End If
         GoSub 950                       ' PRINT GL A/C TOTAL
         If Grp Then GoSub 955
         If bylocn = 2 Then
            GoSub 310                    ' MOVE CLASS TOTAL TO PRINT FIELD
            GoSub 960                    ' PRINT COMPANY TOTAL
         End If
'
         If bylocn = 2 Then GoSub 330    ' PRINT GRAND CLASS TOTALS
         'Printer.Print Space(20); Left(Gt_Text & Space(32), 32); Right(Space(14) & Gt_Price, 14); Right(Space(14) & Gt_Depd_Val, 14); Space(16); Right(Space(13) & Gt_Ytd_Depn, 13); Right(Space(13) & Gt_Ltd_Depn, 13)
         'Printer.Print Space(20); Left(Gt_Text1 & Space(32), 32); Right(Space(14) & D_Price, 14); Right(Space(14) & D_Depd_Val, 14); Space(16); Right(Space(13) & D_Ytd_Depn, 13); Right(Space(13) & D_Ltd_Depn, 13)
         Gt_Price = Gt_Price + D_Price
         Gt_Open_Bal = Gt_Open_Bal + D_Open_Bal
         Gt_Depd_Val = Gt_Depd_Val + D_Depd_Val
         Gt_Ytd_Depn = Gt_Ytd_Depn + D_Ytd_Depn
         Gt_Ltd_Depn = Gt_Ltd_Depn + D_Ltd_Depn
'        PRINT SPACE(58):STR('-',8):SPACE(31):STR('-',9):SPACE(2):STR('-',11):SPACE(4):STR('-',8)
         'Printer.Print Space(58); String$(8, "-"); Space(5); String$(9, "-"); Space(20); String$(9, "-"); Space(4); String$(9, "-")
         'Printer.Print Space(20); Left(Gt_Text2 & Space(32), 32); Right(Space(14) & Gt_Price, 14); Right(Space(14) & Gt_Depd_Val, 14); Space(16); Right(Space(13) & Gt_Ytd_Depn, 13); Right(Space(13) & Gt_Ltd_Depn, 13)

     textfile.WriteLine ("</TABLE>")
     textfile.WriteLine ("</BODY>")
     textfile.WriteLine ("</HTML>")
     textfile.Close
     Set textfile = Nothing
     Set fso = Nothing
     Exit Function
'
' Store Class Total Details in dynamic array
'
300: Class_Cnt = Class_Cnt + 1
     Class_Array = pick.Replace(Class_Array, Class_Cnt, 1, 0, St_Group)
     Class_Array = pick.Replace(Class_Array, Class_Cnt, 2, 0, CStr(St_Price))
     Class_Array = pick.Replace(Class_Array, Class_Cnt, 3, 0, CStr(St_Open_Bal))
     Class_Array = pick.Replace(Class_Array, Class_Cnt, 4, 0, CStr(St_Depd_Val))
     Class_Array = pick.Replace(Class_Array, Class_Cnt, 5, 0, CStr(St_Ytd_Depn))
     Class_Array = pick.Replace(Class_Array, Class_Cnt, 6, 0, CStr(St_Ltd_Depn))
     St_Price = 0: St_Open_Bal = 0: St_Ytd_Depn = 0: St_Depd_Val = 0: St_Ltd_Depn = 0
     Return
'
' Move Class Total Details from dynamic array to print fields
'
310: For row = 1 To Class_Cnt
        St_Group = pick.extract(Class_Array, row, 1, 0)
        St_Price = pick.extract(Class_Array, row, 2, 0)
        St_Open_Bal = pick.extract(Class_Array, row, 3, 0)
        St_Depd_Val = pick.extract(Class_Array, row, 4, 0)
        St_Ytd_Depn = pick.extract(Class_Array, row, 5, 0)
        St_Ltd_Depn = pick.extract(Class_Array, row, 6, 0)
        GoSub 940
        GoSub 320       ' ACCUMULATE GRAND TOTALS
        St_Price = 0: St_Open_Bal = 0: St_Ytd_Depn = 0: St_Depd_Val = 0: St_Ltd_Depn = 0
     Next row
     Class_Cnt = 0: Class_Array = ""
     Return
'
' Accumulate Grand Totals
'
320:    If pick.locate(St_Group, Total_Str, 1, 1, 0, Tot_Pos, "") = 0 Then
           Tot_Pos = 0
           Total_Cnt = Total_Cnt + 1
           Total_Str = pick.Replace(Total_Str, 1, Total_Cnt, 0, St_Group)
           Total_Class = pick.Replace(Total_Class, Total_Cnt, 1, 0, St_Group)
           Total_Class = pick.Replace(Total_Class, Total_Cnt, 2, 0, CStr(St_Price))
           Total_Class = pick.Replace(Total_Class, Total_Cnt, 3, 0, CStr(St_Open_Bal))
           Total_Class = pick.Replace(Total_Class, Total_Cnt, 4, 0, CStr(St_Depd_Val))
           Total_Class = pick.Replace(Total_Class, Total_Cnt, 5, 0, CStr(St_Ytd_Depn))
           Total_Class = pick.Replace(Total_Class, Total_Cnt, 6, 0, CStr(St_Ltd_Depn))
        End If
        If Tot_Pos Then
           Total_Class = pick.Replace(Total_Class, Tot_Pos, 2, 0, pick.extractcur(Total_Class, Tot_Pos, 2, 0) + St_Price)
           Total_Class = pick.Replace(Total_Class, Tot_Pos, 3, 0, pick.extractcur(Total_Class, Tot_Pos, 3, 0) + St_Open_Bal)
           Total_Class = pick.Replace(Total_Class, Tot_Pos, 4, 0, pick.extractcur(Total_Class, Tot_Pos, 4, 0) + St_Depd_Val)
           Total_Class = pick.Replace(Total_Class, Tot_Pos, 5, 0, pick.extractcur(Total_Class, Tot_Pos, 5, 0) + St_Ytd_Depn)
           Total_Class = pick.Replace(Total_Class, Tot_Pos, 6, 0, pick.extractcur(Total_Class, Tot_Pos, 6, 0) + St_Ltd_Depn)
        End If
     Return
'
' Print Grand Class Total
'
330: For row = 1 To Total_Cnt
        St_Group = pick.extract(Total_Class, row, 1, 0)
        St_Price = pick.extract(Total_Class, row, 2, 0)
        St_Open_Bal = pick.extract(Total_Class, row, 3, 0)
        St_Depd_Val = pick.extract(Total_Class, row, 4, 0)
        St_Ytd_Depn = pick.extract(Total_Class, row, 5, 0)
        St_Ltd_Depn = pick.extract(Total_Class, row, 6, 0)
        'Printer.Print Space(20); Left((C_Text & St_Group) & Space(32), 32); Right(Space(14) & St_Price, 14); Right(Space(14) & St_Depd_Val, 14);
        'Printer.Print  SPACE(16); Right(Space() & ST_YTD_DEPN,); Right(Space() & ST_LTD_DEPN,);
'       PRINT ST.YTD.DEPN'R2$,#13'
     Next row
'    PRINT SPACE(58):STR('-',8):SPACE(31):STR('-',9):SPACE(2):
     Return
'
940: temp = "<TR class=totals><TD><TD>TOTAL FOR GROUP<TD>" & St_Group & "<TD><TD><TD align=right>" & FormatCurrency(St_Price, 2) & "<TD align=right>" & FormatCurrency(St_Depd_Val, 2) & "<TD><TD><TD><TD align=right>" & FormatCurrency(St_Ytd_Depn, 2) & "<TD align=right>" & FormatCurrency(St_Ltd_Depn, 2)
     textfile.WriteLine (temp)
     If bylocn <> 2 Then
        St_Open_Bal = 0: St_Depd_Val = 0: St_Ytd_Depn = 0: St_Price = 0: St_Ltd_Depn = 0
     End If
     Return
'
'--- S/R 950: ROUTINE TO PRINT TOTAL FOR GL ACCOUNT
950: temp = "<TR class=totals><TD colspan=4><TD align=right>" & FormatCurrency(St_Price, 2) & "<TD align=right>" & FormatCurrency(St_Depd_Val, 2) & "<TD align=right>" & FormatCurrency(St_Ytd_Depn, 2) & "<TD align=right>" & FormatCurrency(St_Ltd_Depn, 2)
     textfile.WriteLine (temp)
      'If Soils Then Txt = T_Text & field(St_Code, ",", 2) Else Txt = T_Text & St_Code
      'Printer.Print Space(20); Left(Txt & Space(32), 32); Right(Space(14) & T_Price, 14); Right(Space(14) & T_Depd_Val, 14); Space(16); Right(Space(13) & T_Ytd_Depn, 13); Right(Space(13) & T_Ltd_Depn, 13)
      If Cl_Ytd_Depn Then
         'Printer.Print Space(20); Left("TOTAL DISPOSED ASSETS" & Space(32), 32); Space(44); Right(Space(13) & Cl_Ytd_Depn, 13)
         Cl_Ytd_Depn = 0
      End If
      Gt_Price = Gt_Price + T_Price
      Gt_Open_Bal = Gt_Open_Bal + T_Open_Bal
      Gt_Ytd_Depn = Gt_Ytd_Depn + T_Ytd_Depn
      Gt_Depd_Val = Gt_Depd_Val + T_Depd_Val
      Gt_Ltd_Depn = Gt_Ltd_Depn + T_Ltd_Depn
      T_Price = 0: T_Open_Bal = 0: T_Ytd_Depn = 0: T_Depd_Val = 0: T_Ltd_Depn = 0
      Return
'
'--- S/R 955: ROUTINE TO PRINT TOTAL FOR CLASS TYPE
955:  'Printer.Print Space(58); String$(8, "-"); Space(5); String$(9, "-"); Space(20); String$(9, "-"); Space(4); String$(9, "-")
      'Printer.Print Space(20); Left(("TOTAL CLASS TYPE " & St_Type) & Space(32), 32); Right(Space(14) & Ct_Price, 14); Right(Space(14) & Ct_Depd_Val, 14); Space(16); Right(Space(13) & Ct_Ytd_Depn, 13); Right(Space(13) & Ct_Ltd_Depn, 13)
      If Clt_Ytd_Depn Then
         'Printer.Print Space(20); Left(("TOTAL DISPOSED ASSETS FOR " & St_Type) & Space(35), 35); Space(41); Right(Space(13) & Clt_Ytd_Depn, 13)
         Clt_Ytd_Depn = 0
      End If
      Ct_Price = 0: Ct_Open_Bal = 0: Ct_Ytd_Depn = 0: Ct_Depd_Val = 0: Ct_Ltd_Depn = 0
      Return
'
'--- S/R 960: ROUTINE TO PRINT TOTAL FOR COMPANY
960:  'Printer.Print Space(20); Left((Ct_Text & " " & Mid$(St_Code, 1, 2)) & Space(32), 32); Right(Space(14) & Ct_Price, 14); Right(Space(14) & Ct_Depd_Val, 14); Space(16); Right(Space(13) & Ct_Ytd_Depn, 13); Right(Space(13) & Ct_Ltd_Depn, 13)
      'Printer.Print Space(20); Left((Ct_Text1 & " " & Mid$(St_Code, 1, 2)) & Space(32), 32); Right(Space(14) & Cd_Price, 14); Right(Space(14) & Cd_Depd_Val, 14); Space(16); Right(Space(13) & Cd_Ytd_Depn, 13); Right(Space(13) & Ct_Ltd_Depn, 13)
      Ct_Price = Ct_Price + Cd_Price
      Ct_Open_Bal = Ct_Open_Bal + Cd_Open_Bal
      Ct_Depd_Val = Ct_Depd_Val + Cd_Depd_Val
      Ct_Ytd_Depn = Ct_Ytd_Depn + Cd_Ytd_Depn
      Ct_Ltd_Depn = Ct_Ltd_Depn + Cd_Ltd_Depn
      'Printer.Print Space(58); String$(8, "-"); Space(5); String$(9, "-"); Space(20); String$(9, "-"); Space(4); String$(9, "-")
      'Printer.Print Space(20); Left((Ct_Text2 & " " & Mid$(St_Code, 1, 2)) & Space(32), 32); Right(Space(14) & Ct_Price, 14); Right(Space(14) & Ct_Depd_Val, 14); Space(16); Right(Space(13) & Ct_Ytd_Depn, 13); Right(Space(13) & Ct_Ltd_Depn, 13)
      Ct_Price = 0: Ct_Open_Bal = 0: Ct_Ytd_Depn = 0: Ct_Depd_Val = 0: Ct_Ltd_Depn = 0
      Cd_Price = 0: Cd_Open_Bal = 0: Cd_Ytd_Depn = 0: Cd_Depd_Val = 0: Cd_Ltd_Depn = 0
      Return
'
'--- S/R 900: ROUTINE TO PRINT NEW PAGE
900:  'If run_type = "A" Then H_TEXT1C = "(ACCOUNTING)" Else H_TEXT1C = "(TAXATION)"
      'Printer.Print H_Text1b; " "; H_Text1a; TAB_MTH(Mth_No); Space(5); Left(H_TEXT1C & Space(15), 15); Space(30); pick.oconv(ICONV(Format$(Now, "DD MMM YY"), "D2"), "D2"); " PAGE "; Page_Cnt
      'Printer.Print  String$(LEN(H_TEXT1B,"-")
      If bylocn Then
         'If Soils Then
         '   Proj = field(St_Code, ",", 2)
         '   LOCATE(PROJ,PROJECTS,1,1,0,POS,"") ELSE NULL
         '   Title = pick.extract(Projects, 2, Pos, 0)
         '   If pick.extract(Projects, 3, Pos, 0) <> "" Then Title = Title & " (Completion Date " & pick.oconv(pick.extract(Projects, 3, Pos, 0), "D2") & ")"
         '   Printer.Print Space(10); "LOCATION "; field(St_Code, ",", 1); " "; Locn_Desc; " PROJECT "; Proj; " "; Title
         'Else
            'Printer.Print Space(10); "LOCATION "; St_Code; " "; Locn_Desc
         'End If
         'length = Len(St_Code) + Len(Locn_Desc) + 4
         'If Soils Then length = length + Len(Proj) + Len(title) + 4
         'Printer.Print Space(18); String$(length, "-")
      Else
         If Grp = 0 Then
            'Printer.Print Space(10); H_Text2; St_Code; " "; Gl_Ac_Desc
            'length = Len(St_Code) + Len(Gl_Ac_Desc) + 4
            'Printer.Print Space(57); String$(length, "-")
         Else
            'Printer.Print Space(10); "CLASS "; St_Code; Space(2); Class_Desc
            'Printer.Print  SPACE(15); String$(LEN(ST_CODE,"-")LEN(CLASS_DESC)+4)
         End If
      End If
      'Printer.Print H_Text3
      'Printer.Print H_Text4
      'If Grp And Bylocn = 0 Then GRPUN = "-----" Else GRPUN = Space(5)
      'Printer.Print String$(5, "-"); Space(5); String$(11, "-"); Space(12); GRPUN; Space(1); String$(5, "-"); Space(1); String$(8, "-"); Space(5); String$(8, "-"); Space(3); String$(11, "-"); Space(3); "---- ---- ----"; Space(3); String$(9, "-"); Space(2); String$(11, "-")
      Return

End Function


Public Function SR1455A(logentry As String, realrun As Integer, sentence As String, parms As String)

' TA1455A ENTERED VIA TA1455 - DEPRECIATION RUN
'              OR VIA TA1454 - DEPRECIATION RUN FOR PRIOR YEARS
'              OR VIA TA1460 - WHAT IF
'
'sr1455a,0,sselect asset by locn by group, OR could be by locn by class OR by class by group by pur.date OR by locn

Dim d1 As Integer
Dim notax As Integer, run_type As String
Dim eoms As String, last_date As Integer, pos2 As Integer
Dim nodep As String, summonly As String, prev_depd_val As Currency
Dim Sel As String
Dim temp As String, acc_pers As Integer
Dim end_last_year As Integer, end_first_prd As Integer, FUTURE As Integer, prior As Integer
Dim Ass() As String, Gg As Integer
Dim total_items As Long, cnt As Integer, pick_cnt As Long, mylist() As String, J As Long
Dim depn_freq As String, dep_per_yr As Integer, dep_mths As Integer
Dim tempcur As Currency
Dim class_code As String, depd_val As Currency
Dim resid As Currency, residual As Integer, open_val As Currency, days_flag As Integer
Dim I As Integer, depn_date As String, First As String, last_depn As String, posn As Integer, Pos As Integer
Dim depn_rate As Currency, pur_price As Currency, depn As Currency
Dim post_depns As String, post_dates As String, cycle As Integer
Dim Tjpp As Integer, Tj_Rec As String, Tjac As String, Tjjob As String, Tjcd As String, Tjcost As String, Tjp As Integer
Dim p_depn As String, Count As Integer, p_date As String, Tj_Key As String, tot_depn As Currency
Dim cents As String, Amt As Currency
Dim diy As Integer, dip As Integer, indx As Integer
Dim gc As Integer, Glac As String, tempd
Dim database As String, rderr As Integer, Cls As String, subl As String
Dim fso, textfile, nrec() As String, sorting As String
Dim bylocn As Integer, soils As Integer, Grp As Integer

    database = pick.extract(logentry, 2, 0, 0)
    
    If UBound(g_trans_info_array) = 0 Then
       g_trans_info_array(0) = "TRANS.INFO"
       posn = d3.d3_readmat(database, g_trans_info_array(), "DICT TRANS.J")
    End If
    If UBound(g_trans_info_array) < 151 Then ReDim Preserve g_trans_info_array(151)
    
    If realrun <> 0 Then
       If realrun = 1 Then
          eoms = g_trans_info_array(8) & Chr(253) & g_trans_info_array(7) & Chr(253) & g_trans_info_array(33)
       Else
          eoms = g_trans_info_array(9) & Chr(253) & g_trans_info_array(8)
       End If
    Else
       eoms = g_trans_info_array(9) & Chr(253) & g_trans_info_array(8) & Chr(253) & g_trans_info_array(7) & Chr(253) & g_trans_info_array(33)
    End If
    
    d1 = pick.extractint(parms, 1, 0, 0)
    nodep = pick.extract(parms, 2, 0, 0)
    summonly = pick.extract(parms, 4, 0, 0)
    run_type = "A"

    sorting = pick.extract(parms, 3, 0, 0)
    Select Case sorting
       Case "BY LOCN BY PROJECT BY GROUP BY ASSET.NO": bylocn = 1: soils = 1
       Case "BY LOCN BY GROUP BY ASSET.NO": bylocn = 1
       Case "BY LOCN BY CLASS BY ASSET.NO": bylocn = 2
       Case "BY GL.ACC BY ASSET.NO": bylocn = 0: Grp = 0
       Case "BY TYPE BY CLASS BY GROUP BY PUR_DATE BY ASSET.NO": bylocn = 0: Grp = 1
    End Select
    sentence = sentence & " " & sorting
      
    If realrun Then
       If d1 < pick.extractint(g_trans_info_array(34), 1, 9, 0) Or d1 > pick.extractint(g_trans_info_array(34), 1, 10, 0) Then
          SR1455A = Chr(8) & "Date must be a month end and must be within date range entered in 599"
          Exit Function
       End If
    End If
    
    SR1455A = d3.rtf_open(logentry, fso, textfile, ".asp")
    temp = "<TABLE cellspacing=1 cellpadding=1 border=1 WIDTH=95%><TR CLASS=top><TD COLSPAN=9 ALIGN=CENTER>Asset Depreciation to " & pick.oconv(CStr(d1), "D2") & "    as at " & Now
    temp = temp & "<TR class=top><TH>Asset<TH>Description<TH>Group<TH>Location<TH>Price<TH>Date<TH>Type<TH>Rate<TH>Freq<TH>Current Dep'd Value<TH>Depreciation Amount<TH>Depreciated Value<TH>Total Depreciation<TH>Class"
    textfile.WriteLine (temp)
    
    cents = pick.extract(g_trans_info_array(151), 1, 3, 0) ': If cents = "" Then MD2 = "MD2": MD2CONV = "MD2": cents = 2: DOL = "$" Else MD2 = "MD02": MD2CONV = "MD20": DOL = ""
    acc_pers = CInt(g_trans_info_array(5))       ' ACC_ PERIODS PER YEAR
    temp = Mid$(g_trans_info_array(73), 1, 1)
    If IsNumeric(temp) Then notax = CInt(temp) Else notax = 0
    temp = Mid$(g_trans_info_array(73), 6, 1)
    If IsNumeric(temp) Then residual = CInt(temp) Else residual = 0
    temp = Mid$(g_trans_info_array(73), 3, 1)
    If IsNumeric(temp) Then days_flag = CInt(temp) Else days_flag = 0
     
'    If realrun = 0 And Not (DAYS_FLAG) Then     ' SET UP 10 YEAR MTH ENDS
'       For X = 1 To 10
'          For i = 1 To ACC_PERS
'             ODATE = OCONV(pick.extract(TRANS_INFO, 33, i, 0), "D")
'             dd = Mid$(ODATE, 1, 2): mm = Mid$(ODATE, 4, 3): YY = Mid$(ODATE, 8, 4): YY = YY + X
'95           NDATE = dd & " " & mm & " " & YY
'             IDATE = ICONV(NDATE, "D2")
'             If IDATE = "" Then dd = dd - 1: GoTo 95
'             eoms = pick.Insert(eoms, 1, -1, 0, IDATE)
'          Next i
'       Next X
'    End If
    I = pick.dcount(pick.extract(eoms, 1, 0, 0), Chr(253))
    last_date = CInt(pick.extract(eoms, 1, I, 0))

    If d1 > CInt(g_trans_info_array(7)) Then     ' DEPN IN FUTURE YEAR ?
       end_last_year = CInt(g_trans_info_array(7))
       end_first_prd = CInt(pick.extract(g_trans_info_array(33), 1, 1, 0))
       FUTURE = 1: prior = 0
    Else
       'LN = LN + 2
       If d1 <= CInt(pick.extract(g_trans_info_array(8), 1, 1, 0)) Then
65      ' Call SRIP(0, LN, "Previous END-of-year (for reducing balance) ", PY_DATE, CLEARS, "", "", "D_ENDIF", "")
          'IF PY_DATE = "ENDIF" THEN PRINT ERASE & : RETURN
          'D2 = ICONV(PY_DATE, "D2")
          'LOCATE(D2,EOMS,1,1,0,POS2,"") ELSE PRINT BELL & : GOTO 65
          'IF D2>=D1 THEN PRINT BELL & : GOTO 65
          'ENDIF_LAST_YEAR = pick.extract(eoms, 1, POS2, 0)
          'ENDIF_FIRST_PRD = pick.extract(eoms, 1, POS2 + 1, 0)
          'future = 0: prior = 1
       Else
          end_last_year = CInt(pick.extract(g_trans_info_array(8), 1, 1, 0))
          end_first_prd = CInt(pick.extract(g_trans_info_array(8), 1, 2, 0))
          FUTURE = 0: prior = 0
       End If
    End If
'
    cnt = 0
    total_items = d3.d3_select(logentry, sentence, mylist(), pick_cnt, 0, 0)
    If run_type = "T" Then I = 7 Else I = 0
    
 For J = 0 To total_items - 1
    post_depns = "":  post_dates = ""
    cycle = 0
'
     ReDim Ass(0): Ass(0) = mylist(J)
     If d3.d3_readmat(database, Ass(), "ASSET") <> 0 Then GoTo 100
     If UBound(Ass) < 97 Then ReDim Preserve Ass(97)
     If Ass(23) <> "" And run_type <> "T" Then GoTo 7000   ' ASSET DISPOSED

     depn_freq = Ass(9 + I)
     Select Case depn_freq
       Case "M": dep_per_yr = acc_pers: dep_mths = 1
       Case "Q": dep_per_yr = 4:   dep_mths = 3
       Case "H": dep_per_yr = 2:   dep_mths = 6
       Case "Y": dep_per_yr = 1:   dep_mths = acc_pers
       Case Else: GoTo 7000 'error
     End Select
'
     depn_date = pick.extract(Ass(10 + I), 1, 1, 0) ' FIRST DEP"N
     If depn_date <> "" Then                        ' FIRST DEP`N
        last_depn = depn_date
        First = "Y"
     Else
        last_depn = pick.extract(Ass(10 + I), 1, 2, 0)
        First = "N"
     End If
'
' IF FULL VALUE DEPRECIATION, THEN DEPRECIATE AT END OF MONTH OF PURCHASE
    If Ass(7 + I) = "3" Then
        If IsNumeric(Ass(5)) Then tempcur = CCur(Ass(5)) Else tempcur = 0
        If tempcur > end_last_year Then last_depn = Ass(5) Else depn_date = end_first_prd:  GoTo 175
    End If
'
    posn = pick.locate(last_depn, eoms, 1, 1, 0, Pos, "AR")
    If pick.extract(eoms, 1, Pos, 0) = "" Then
       depn_date = "99999"
       GoTo 175
    End If
'
160 If Ass(7 + I) <> "3" Then
        If First = "Y" Then GoTo 175
        Pos = Pos + dep_mths
     End If
     If d1 > last_date Then depn_date = "99999" Else depn_date = pick.extract(eoms, 1, Pos, 0)

175 If CCur(depn_date) > d1 Then GoTo 7000        ' NOT DUE FOR DEP`N

    temp = pick.extract(Ass(12 + I), 1, 1, 0)
    If IsNumeric(temp) Then depd_val = CCur(temp) Else depd_val = 0
    open_val = depd_val
    If residual <> 0 Then
       If run_type = "A" Then temp = Ass(42) Else temp = Ass(43)
       If IsNumeric(temp) Then resid = CCur(temp) Else resid = 0
       resid = resid / 100
    Else
       resid = 0
    End If
    If nodep = "N" Then
       If depd_val <= resid Then GoTo 7000
    End If
    prev_depd_val = depd_val
'
    depd_val = depd_val / 100
    temp = Ass(8 + I)
    If IsNumeric(temp) Then depn_rate = CCur(temp) / 100 Else depn_rate = 0
    If run_type = "A" Then temp = Ass(6) Else temp = Ass(22)
    If IsNumeric(temp) Then pur_price = CCur(temp) Else pur_price = 0
'
200 Select Case Ass(7 + I)
       Case "1"              ' STRAIGHT LINE DEPRECIATION
          depn = pur_price / 100 * depn_rate
       Case "2"   ' REDUCING BALANCE DEPRECIATION
          depn = depd_val * depn_rate
       Case "3"  ' FULL VALUE DEPRECIATION
         If prev_depd_val < pur_price Then depn = prev_depd_val * dep_per_yr Else depn = pur_price * dep_per_yr
       Case "4"   ' YEAR REST REDUCING BALANCE
          If FUTURE Or prior Then
             posn = pick.locate(CStr(end_last_year), Ass(11 + I), 1, 1, 0, pos2, "")
             If posn = 0 Then pos2 = 0
             If pos2 Then temp = pick.extract(Ass(12 + I), 1, pos2, 0) Else temp = "0"
             If IsNumeric(temp) Then depn = CCur(temp) Else depn = 0
             If depn = 0 Then
                temp = Ass(13 + I)   ' YEAR OPENING BAL
                If IsNumeric(temp) Then depn = CCur(temp) Else depn = 0
             End If
          Else
             temp = Ass(13 + I)   ' YEAR OPENING BAL
             If IsNumeric(temp) Then depn = CCur(temp) Else depn = 0
          End If
          If IsNumeric(Ass(5)) Then tempcur = CCur(Ass(5)) Else tempcur = 0
          If tempcur > end_last_year Then depn = pur_price
          depn = depn / 100 * depn_rate

       Case Else
          depn = 0
    End Select

    depn = depn / 100
    If days_flag <> 0 Then
       If depn_date > CInt(g_trans_info_array(7)) Then
          diy = CInt(pick.extract(g_trans_info_array(33), 1, acc_pers, 0)) - CInt(g_trans_info_array(7))
       Else
          If depn_date > CInt(pick.extract(g_trans_info_array(8), 1, 1, 0)) Then
             diy = CInt(g_trans_info_array(7)) - pick.extract(g_trans_info_array(8), 1, 0, 0)
          Else
             diy = CInt(pick.extract(g_trans_info_array(8), 1, 1, 0)) - CInt(pick.extract(g_trans_info_array(9), 1, 0, 0))
          End If
       End If
       If diy + 0 = 0 Then diy = 365
       dip = depn_date - last_depn
       depn = depn / (diy / dip)
    Else
       depn = depn / dep_per_yr
    End If
    If cents = "" Then
       depn = Int(depn * 100 + 0.5) / 100
    Else
       depn = Int(depn + 0.5)
    End If
    'depn = pick.OCONV(pick.ICONV(depn, MD2CONV), MD2CONV)
    depd_val = depd_val - depn
    If residual Then
       If run_type = "A" Then temp = Ass(42) Else temp = Ass(43)
       If IsNumeric(temp) Then resid = temp / 100 Else resid = 0
    Else
       resid = 0
    End If
    If depd_val < resid Then
       If depd_val + depn <= resid Then
          depd_val = depd_val + depn: depn = 0
       Else
         depn = depn + depd_val - resid   ' OUTSTANDING DEP`N VALUE
         depd_val = resid
      End If
    End If
    depd_val = depd_val * 100    ' STORE IN CENTS
    depd_val = Int(depd_val)

    post_depns = pick.Insert(post_depns, -1, 0, 0, CStr(Int(depn * 100)))
    post_dates = pick.Insert(post_dates, -1, 0, 0, depn_date)

    If pick.extract(Ass(10 + I), 1, 1, 0) <> "" Then
       Ass(10 + I) = pick.Replace(Ass(10 + I), 1, 1, 0, "")
    End If
    Ass(10 + I) = pick.Replace(Ass(10 + I), 1, 2, 0, CStr(depn_date))
    Ass(11 + I) = pick.Insert(Ass(11 + I), 1, 1, 0, depn_date)
    Ass(12 + I) = pick.Insert(Ass(12 + I), 1, 1, 0, CStr(depd_val))
    last_depn = depn_date
'
    Pos = Pos + dep_mths
    depn_date = pick.extract(eoms, 1, Pos, 0)
    If depn_date = "" Then depn_date = "99999"
    cycle = cycle + 1
    If run_type = "T" And Ass(23) <> "" Then
       If CCur(Ass(23)) < CCur(depn_date) Then GoTo 210
    End If
    If depn_date <= d1 And Ass(7 + I) <> "3" Then
       depd_val = depd_val / 100
       GoTo 200
    End If

210 depn = prev_depd_val - depd_val
'
    If realrun = 0 Then GoTo 6900
'    CALL PICKWT(ASSET_DATA, asset, 3, ass, 0)
'
    If run_type = "A" And prior = 0 Then
       For Count = 1 To 999
           p_depn = pick.extract(post_depns, Count, 0, 0)      ' DEP`N AMOUNT TO POST
           If p_depn = "" Then GoTo 6100
           If p_depn Then
               p_date = pick.extract(post_dates, Count, 0, 0)
               'tj_key = TNO & p_date & "1455"
6000           If d3.d3_readstr(database, Tj_Rec, "TRANS.J", Tj_Key) <> 0 Then Tj_Rec = "": GoTo 6010
'$INSERT I.LOG.UPDATE '|TRANS.J|':TJ.KEY 6000 TJ.REC
               GoTo 6020
6010:
'$INSERT I.LOG.ADD '|TRANS.J|':TJ.KEY 6000
'
6020        If Ass(2) = "" Then Ass(2) = "Exp_ acct missing"
               If Ass(1) = "" Then Ass(1) = "Prov_ acct missing"
               Tjac = Ass(2)
               Tjjob = "0"
               Tjcd = 63
               Tjcost = p_depn
               GoSub 7777
               Tjac = Ass(1)
               Tjcd = 38
               GoSub 7777
               'tj_rec = pick.REPLACE(tj_rec, 6, 0, 0, "ASSET DEPN " & OCONV(p_date, "D2"))
               Tj_Rec = pick.Replace(Tj_Rec, 7, 0, 0, p_date)
               'Call PICKWT(TRANS_J_DATA, tj_key, 3, tj_rec, 0)
           End If
       Next Count
     End If
6100:
'$INSERT I.QU
6900 depn = depn / 100
     depd_val = depd_val / 100         ' VALUES STORED IN CENTS
     pur_price = pur_price / 100
     tot_depn = pur_price - depd_val
     If summonly = "N" Then
        cnt = cnt + 1
        temp = "<TR><TD>" & mylist(J) & "<TD>" & Ass(3) & "<TD>" & Ass(37) & "<TD>" & Ass(4) & "<TD align=right>" & FormatCurrency(pur_price, 2) & "<TD>" & pick.oconv(Ass(5), "D2") & "<TD>" & Ass(7 + I) & "<TD>" & FormatCurrency(depn_rate, 2) & "<TD>" & Ass(9 + I) & "<TD>" & FormatCurrency(open_val, 2) & "<TD>" & FormatCurrency(depn, 2) & "<TD>" & FormatCurrency(depd_val, 2) & "<TD>" & FormatCurrency(tot_depn, 2) & "<TD>" & Ass(97)
        textfile.WriteLine (temp)
        'Print ((ASSETNO & Space(8 - Len(ASSETNO))) & " " & ass(pick.extract(3), 1, 1)); "L<>29" & grp_code; "R<>6" & " " & ass(4); "R<>4"
        '& pur_price; R2_14 & " " & OCONV(ass(5), "D2") & Space(3) & ass(7 + i) & " " & depn_rate; "R2<>5"
        '& Space(3) & ass(9 + i) & OCONV(open_val, MD2); R2_14 & depn; R2_12 & depd_val; R2_14 &
        'tot_depn; R2_14
     End If
     GoSub 8000                      ' BUILD GL SUMMARY DETAILS
100  Next J ' GET ANOTHER ASSET
     For Gg = 0 To 3 Step 3
        For Count = 1 To pick.dcount(nrec(14 + Gg), Chr(253))
           temp = "<TR><TD>" & pick.extract(nrec(14 + Gg), 1, Count, 0) & "<TD align=right>" & pick.extractcur(nrec(14 + Gg), 1, Count, 0) & "<TD align=right>" & pick.extractcur(nrec(14 + Gg), 1, Count, 0)
           textfile.WriteLine (temp)
       Next Count
     Next Gg
     textfile.WriteLine ("</TABLE>")
     textfile.WriteLine ("</BODY>")
     textfile.WriteLine ("</HTML>")
     textfile.Close
     Set textfile = Nothing
     Set fso = Nothing
     Exit Function
'
7000: ' If realrun Then
 '        Release ASSET_DATA, asset
'$INSERT I.QU
     'End If
     GoTo 100
7777 Tjpp = 1
7778 For Tjp = Tjpp To 999
        If pick.extract(Tj_Rec, 3, Tjp, 0) = Tjac Then GoTo 7779
        If pick.extract(Tj_Rec, 3, Tjp, 0) = "" Then
           Tj_Rec = pick.Insert(Tj_Rec, 3, -1, 0, Tjac)
           Tj_Rec = pick.Insert(Tj_Rec, 2, -1, 0, Tjjob)
           Tj_Rec = pick.Insert(Tj_Rec, 1, -1, 0, Tjcd)
           Tj_Rec = pick.Insert(Tj_Rec, 4, -1, 0, Tjcost)
           Return
        End If
     Next Tjp
7779 If pick.extract(Tj_Rec, 1, Tjp, 0) <> Tjcd Or pick.extract(Tj_Rec, 2, Tjp, 0) <> Tjjob Then Tjpp = Tjpp + 1: GoTo 7778
     Tj_Rec = pick.Replace(Tj_Rec, 4, Tjp, 0, pick.extract(Tj_Rec, 4, Tjp, 0) + Tjcost)
     Return
'
'--- S/R 8000:  ROUTINE TO BUILD DETAILS FOR GL POSTING SUMMARY
'
8000 ReDim nrec(20)
     For Count = 1 To pick.dcount(post_depns, Chr(254))
        p_depn = pick.extract(post_depns, Count, 0, 0)
        If p_depn = "" Then Return
        If Not IsNumeric(p_depn) Then Return
        If p_depn <> 0 Then
         For Gg = 0 To 3 Step 3
'** BUILD DEPRECIATION POSTING DETAILS ***
           If Gg = 0 Then Glac = Ass(2) Else Glac = Ass(1)
           posn = pick.locate(Glac, nrec(14 + Gg), 1, 1, 0, indx, "")
           If posn = 0 Then indx = 0
           If indx <> 0 Then
               Amt = pick.extractcur(nrec(15 + Gg), 1, indx, 0)
               gc = CInt(pick.extract(nrec(16 + Gg), 1, indx, 0))
               nrec(15 + Gg) = pick.Replace(nrec(15 + Gg), 1, indx, 0, CStr(Amt + CCur(p_depn))) ' UPDATE TOTALS)
               nrec(16 + Gg) = pick.Replace(nrec(16 + Gg), 1, indx, 0, CStr(gc + 1))
           Else
               nrec(14 + Gg) = pick.Insert(nrec(14 + Gg), 1, -1, 0, Glac) ' NEW POSTING A/C
               nrec(15 + Gg) = pick.Insert(nrec(15 + Gg), 1, -1, 0, p_depn)
               nrec(16 + Gg) = pick.Insert(nrec(16 + Gg), 1, -1, 0, "1")
           End If
         Next Gg
       End If
     Next Count
     Return

End Function



Private Sub SR211(database As String, AUTHOR, cr_author As String, Tr_Payment As Currency, Tr_Amt As Currency, TR_BAL As Currency, Discflag, tr_type As Integer, DISC_DATE, Tr_Date, cr_discount As String, DEF_DISCOUNTS, Tr_Disc As Currency, REMFLAG, cr_remit As String, Yespay As Integer, SETONLY, Disc_Apply, Disc_Apply_Date, Pps_Flg, CR_PPS_RATE As Currency, Tr_Pps As String)

Dim Tr_Paid
Dim Nodays, Discounts As String, pp, Jj As Integer
Dim Prev_Pps, Balance, Paid_So_Far
'
' DETERMINE WHETHER TO PAY OR NOT
' SETS YESPAY=1 OR 0. SETS TR.PAYMENT AND TR.DISC
'
' Also calculates PPS for payment
' -on ENTRY TR.PPS will either contain a "Y" to indicate PPS is applicable
' -and not yet applied (with optional s/v 2 containing over-ride amount)
' -or will contain an amount of indicate PPS is applicable - part payment
' -or contain a null to indicate NO PPS to be applied.
' -on EXIT, TR.PPS will contain amount of PPS calculated or null
' -if no PPS applicable
' NOTE: PPS will be returned in WHOLE dollars with cents truncated
'**** TR.PPS IS SUB.VALUED 1=Y or null 2=override total invoice amount
'
     Yespay = 1: Tr_Disc = 0
'
     If AUTHOR Then
        If AUTHOR = 2 And pick.extract(cr_author, 1, 0, 0) = "" Then GoTo 100
        If AUTHOR = 1 And pick.extractcur(cr_author, 1, 0, 0) <> 0 Then GoTo 100
        Tr_Payment = pick.extractcur(cr_author, 1, 0, 0)
        If TR_BAL >= 0 Then
           Tr_Paid = Tr_Amt - TR_BAL
           If Tr_Paid >= Tr_Payment Then
              Tr_Payment = 0
           Else
              Tr_Payment = Tr_Payment - Tr_Paid
           End If
        End If
        If Tr_Payment = 0 Then
          If TR_BAL <> 0 Then GoTo 700 Else GoTo 600
        End If
     Else
100     If Discflag = 0 Then GoTo 400
        If tr_type <> 25 Then GoTo 400
        If Tr_Amt <> TR_BAL Then GoTo 400   ' no discount on part payments
        Nodays = DISC_DATE - Tr_Date
        Discounts = pick.extract(cr_discount, 1, 0, 0)
        If Discounts = "" Then
           Discounts = DEF_DISCOUNTS
           If Mid$(Discounts, 1, 1) <> "0" Then GoTo 400
        Else
           If Mid$(Discounts, 1, 1) <> "0" Then GoTo 400
           Discounts = Mid$(Discounts, 1, 1) & Chr(253) & Mid$(Discounts, 3, 99)
200        pp = InStr(Discounts, ",")
           If pp Then Discounts = Mid$(Discounts, 1, pp - 1) & Chr(252) & Mid$(Discounts, pp + 1, 99): GoTo 200
300        pp = InStr(Discounts, " ")
           If pp Then Discounts = Mid$(Discounts, 1, pp - 1) & Chr(253) & Mid$(Discounts, pp + 1, 99): GoTo 300
        End If
        For Jj = 1 To 3
           If pick.extract(Discounts, 1, Jj + 1, 1) + 0 = 0 Then GoTo 400
           If Nodays <= pick.extract(Discounts, 1, Jj + 1, 2) Or pick.extract(Discounts, 1, Jj + 1, 2) = "" Then
              Disc_Apply = pick.extract(Discounts, 1, Jj + 1, 1): Disc_Apply_Date = pick.extract(Discounts, 1, Jj + 1, 2)
              Tr_Disc = TR_BAL / 100 * Disc_Apply
              Tr_Payment = Int(TR_BAL - Tr_Disc + 0.5)
              Tr_Disc = TR_BAL - Tr_Payment
              GoTo 500
           End If
        Next Jj
400     Tr_Payment = TR_BAL
500     If Tr_Payment = 0 Then
600       If REMFLAG Or pick.extract(cr_remit, 1, 0, 0) <> "" Then GoTo 700
        End If
     End If
     If Discflag Then
        If Tr_Disc = 0 And SETONLY = "Y" Then GoTo 700
     End If
'
     If Pps_Flg Then     ' PPS system
       If pick.extract(Tr_Pps, 1, 1, 1) <> "" Then     ' PPS to apply
         Prev_Pps = 0
         If pick.extract(Tr_Pps, 1, 1, 1) <> "Y" Then Prev_Pps = pick.extract(Tr_Pps, 1, 1, 1) ' previous PPS
         Balance = Tr_Payment + Prev_Pps + Tr_Disc
         If pick.extract(Tr_Pps, 1, 1, 2) <> "" Then ' test against PPS over-ride
           Paid_So_Far = Tr_Amt - TR_BAL - Prev_Pps - Tr_Disc
           If Balance + Paid_So_Far > pick.extract(Tr_Pps, 1, 1, 2) Then
             Balance = pick.extract(Tr_Pps, 1, 1, 2) - Paid_So_Far
             If Balance < 0 Then Balance = 0
           End If
         End If
         Tr_Pps = pick.Replace(Tr_Pps, 1, 1, 1, Int((Balance * CR_PPS_RATE / 100) + 0.5))
         Tr_Pps = pick.Replace(Tr_Pps, 1, 1, 1, Int(pick.extract(Tr_Pps, 1, 1, 1) / 100) * 100) ' truncate cents)
         Tr_Payment = Tr_Payment - pick.extract(Tr_Pps, 1, 1, 1)
       End If
     Else
       Tr_Pps = ""
     End If
     Exit Sub      ' to calling program **
'
700  Yespay = 0  ' NOT available for payment

End Sub

Public Function sr(database As String, parms As String, datum As String) As String

' SR.  PICK routines rewritten

Dim Am As String, Vm As String, which_file As String
Dim which_id As String, which_atr As String
Dim attr_has_data As String, Cls() As String, codes As String, cnt As Integer
Dim I As Integer, srnum As String
Dim rderr As Integer, temp As String, glacct As String

     Am = Chr$(254): Vm = Chr$(253)
     
srnum = pick.field(parms, "!", 1)
parms = Mid(parms, Len(srnum) + 2)

Select Case srnum
   Case "sr_26" ' Initally used to validate units in @STOCKUNITS of TRANS.J
     which_file = pick.field(parms, "!", 1)
     which_id = pick.field(parms, "!", 2)
     which_atr = pick.field(parms, "!", 3)
     attr_has_data = pick.field(parms, "!", 4) '* attribute must have data - attr=0
     If which_atr = "" Then which_atr = "1"
     ReDim Cls(0): Cls(0) = which_id
     rderr = d3.d3_readmat(database, Cls(), which_file)
     codes = ""
     If which_atr <> "0" Then
        If UBound(Cls) < which_atr Then cnt = 0 Else cnt = pick.dcount(Cls(which_atr), Vm)
        For I = 1 To cnt
           If datum = pick.extract(Cls(which_atr), 1, I, 0) Then sr = pick.extract(Cls(attr_has_data), 1, I, 0): Exit Function 'mc 6may99
           'codes = pick.insert(codes, 1, -1, 0, temparr.brExtractStr( which_atr, i, 0))
           'codes = pick.insert(codes, 2, -1, 0, temparr.brExtractStr( 1, i, 0))
        Next I
     Else
        If attr_has_data = "1" Then
           If IsNumeric(datum) Then I = CInt(datum) Else I = 0
           If which_id = "@RELATE" Then I = I + 1
           If I = 0 Then I = 1
           If UBound(Cls) < I Then sr = "" Else sr = Cls(I)
           Exit Function
        End If
        cnt = UBound(Cls)
        For I = 1 To cnt
           If UBound(Cls) < I Then temp = "" Else temp = Cls(I)
           If datum = pick.extract(temp, 1, 1, 0) Then sr = pick.extract(temp, 1, 2, 0): Exit Function
        Next I
     End If
     'IF DATUM[1,1]='?' THEN DATUM='?'
     'IF DATUM='?' THEN
     '   FDESC='Codes' & VM & VM & 1 & VM & VM & VM & VM & 1 & VM & VM & 1
     '   CALL SR.HELP (15,'',CODES,FDESC,DATUM)
     '   LOCATE DATUM IN CODES<1,1> SETTING POS ELSE NULL
     '   PARMS=CODES<2,POS> & ',1'
     '   Return
     'End
     sr = datum
   Case "sr_31" 'Get description for bank account number passed
     If datum <> "" And Not IsNumeric(datum) Then
        sr = "Invalid bank account number " & datum
        Exit Function
     End If
     If datum = "0" Then sr = "Invalid bank account number " & datum: Exit Function
     If UBound(g_trans_info_array) = 0 Then
        g_trans_info_array(0) = "TRANS.INFO"
        rderr = d3.d3_readmat(database, g_trans_info_array(), "DICT TRANS.J")
     End If
     If UBound(g_trans_info_array) < 31 Then ReDim Preserve g_trans_info_array(31)
     If datum = "1" Or datum = "" Then
        glacct = g_trans_info_array(4)
     Else
        glacct = pick.extract(g_trans_info_array(31), 1, CInt(datum) - 1, 0)
     End If
     If glacct = "" Then sr = "Invalid bank account number " & datum: Exit Function
     ReDim Cls(0): Cls(0) = glacct
     rderr = d3.d3_readmat(database, Cls(), "GEN.L")
     If UBound(Cls) < 2 Then sr = glacct Else sr = pick.extract(Cls(2), 1, 1, 0)
   Case "sr_5420"
 'datum is the entire item data. When extracting remember to add 1 to the number of the required attr
Dim Amount As String, i_rate As String, i_type As String, i_date As String
Dim m_date As Integer, i_rest As String, principal As Currency
Dim Factor As Single, divisor As Currency, no_of_changes As Integer, interest As Currency
Dim rte As Integer, typ As String, rest As String, flag As String, yield_calc As String
Dim today, sub_amount As Currency, rate As String, start_date As String
Dim sub_interest As Currency, end_date As Currency, period As Currency
Dim compound As Currency, simple As Double, fraction As Currency

        flag = "0"
        interest = 0
        Amount = pick.extract(datum, 3, 0, 0)
        i_rate = pick.extract(datum, 6, 0, 0)
        i_type = pick.extract(datum, 7, 1, 0)
        i_date = pick.extract(datum, 8, 0, 0)
        m_date = pick.extractcur(datum, 5, 0, 0)
'
'   THIS SUBROUTINE CALCULATES THE INTEREST DUE TO DATE FOR ITEMS IN
'   THE INVESTMENT REGISTER.
'   THE INTEREST TYPE CAN BE 'SIMPLE' OR 'COMPOUND' - IN THE LATTER CASE
'   A 'REST' PERIOD IS USED
'
    interest = 0
    no_of_changes = pick.dcount(i_rate, Chr(253))
    typ = pick.extract(i_type, 1, 0, 0)
    If typ = "C" Then rest = i_rest Else rest = ""
    If flag = "1" Then yield_calc = "1" Else yield_calc = ""
'
    Select Case rest
       Case "F": Factor = 0.0384: divisor = 14
       Case "M": Factor = 0.0833: divisor = 30.4167
       Case "Q": Factor = 0.25: divisor = 91.25
       Case "H": Factor = 0.5: divisor = 182.5
       Case Else: Factor = 1: divisor = 365
    End Select
'
    principal = pick.extractcur(Amount, 1, no_of_changes, 0)
    I = pick.date_vb_to_pick(CStr(Date), today, 0)
    If m_date <> 0 Then
       If m_date < CInt(today) Then today = CVar(m_date)
       If m_date > CInt(today) And yield_calc = "1" Then today = CVar(m_date)
    End If

    For I = no_of_changes To 1 Step -1
       sub_amount = pick.extractcur(Amount, 1, I, 0)
       If I <> no_of_changes Then
          principal = sub_amount
       End If
       rate = pick.extract(i_rate, 1, I, 0)
       start_date = pick.extract(i_date, 1, I, 0)
       If CInt(start_date) > CInt(today) Then
          sub_interest = 0
          GoTo sr_900
       End If
       If I = 1 Then end_date = CCur(today) Else end_date = pick.extractcur(i_date, 1, I - 1, 0)
       period = end_date - CCur(start_date)
       If period < 0 Then
          sub_interest = 0
          GoTo sr_900
       End If
       If typ = "C" Then
          compound = Int(period / divisor)
          simple = period - (compound * divisor)
       Else
          compound = 0
          simple = period
       End If
       If compound <> 0 Then
          fraction = ((rate * Factor) / 10000) + 1
          principal = principal * (fraction ^ compound)
       End If
       If simple > 0 Then
          fraction = ((rate / 365) * simple * principal) / 10000
          fraction = Int(fraction + 0.5)
          principal = principal + fraction
       End If
'
       sub_interest = principal - sub_amount
sr_900:
       interest = interest + sub_interest
    Next I
    sr = Format(interest / 100, "#.00")
End Select

End Function


Public Sub SR310(database As String, LEDG_DATE As String, Client_No As String, Cr_Rec As String, Tr_Inv_Ref As String, Tr_Inv_Date As Integer, USE_INV_AMT As String, Tr_Code As String, Tr_Narr As String, Cr_Relation As Integer, TR_CUST_REF As String, debt_cont As String, mdb_name As String, debtor_controls As String)

Dim Sze As Currency, Tr_Cash As String, Ii As Integer
Dim temp As String, tempcur As Currency
Dim Tr_Inv_Amt As Currency, Tr_Inv_Bal As Currency, Stmnt_Date As String, Cr_Ovfno As Integer, overflow As String
Dim Cr_No_Trans As Integer, Cr_Cur_Bal As Currency, Cashamtot As Currency
Dim Cashused_Ref As String, Cashused_Amt As String, Cashused_Dte As String, Days_To_Pay As Currency, Days_Ct_Pay As Currency
Dim Days_Used As Currency, Cashrefs As String, Cashpos As Integer, Cashid As String, Cashamt As Currency, Cashp As Integer
Dim Ddtes As String, max As Integer, Cashtyp As Integer, Casha As Currency, Cashdte As Integer, Cashldte As String, Cashofo As Integer
Dim Ovf_Key As String, Tran As String, Cdtes As String, Ovf_No As Integer, Oflow_Dates As String, Cr_Tdate As String, I As Integer
Dim First_Unpaid As Currency, Sec_Ovf As String, H2 As Integer, Half As Integer, V As Integer, Ovf As String
Dim M As Integer, rderr As Integer, dcs() As String
'
' Standard routine to add DEBIT to debtors account
'
'  or a CREDIT that is to be left unallocated
'    (where USE.INV.AMT < 0 and TR.CODE must be credit code)
'
' Can also post Credit transaction with zero balance outstanding which
' in effect is only adding the transaction without affecting the balance
' or credit allocations of the debtor's account
' i.e. USE.INV.AMT m/v 2 is set with 0 (zero)
' e.g. used in library system to post refund
'
'    If USE.INV.AMT<1,3> set, implies want transaction created but treat
'    as already statemented (where USE.INV.AMT<1,3> = statement date)

     Sze = 2000 'MC 11AUG99
     Tr_Cash = 31
     Tr_Inv_Amt = pick.extractcur(USE_INV_AMT, 1, 1, 0)
     Tr_Inv_Bal = pick.extractcur(USE_INV_AMT, 1, 2, 0) '0 and null are not the same for this call!!
     If pick.extract(USE_INV_AMT, 1, 2, 0) <> "0" Then Tr_Inv_Bal = Tr_Inv_Amt
     Stmnt_Date = pick.extract(USE_INV_AMT, 1, 3, 0)
'
     Cr_Ovfno = pick.extractint(Cr_Rec, 27, 0, 0)
     If d3.d3_readstr(database, overflow, "TD.OFLOW", Cr_Ovfno & "*" & Client_No) <> 0 Then overflow = ""
     Cr_No_Trans = pick.extractint(overflow, 1, 0, 0)
     If Len(overflow) > Sze And Cr_No_Trans > 1 Then GoSub 8900
     
      Cr_Cur_Bal = pick.extractcur(Cr_Rec, 3, 0, 0)
      Cr_Relation = pick.extractint(Cr_Rec, 23, 0, 0) + 1
      If mdb_name <> "" Then
         ReDim dcs(0): dcs(0) = Cr_Relation
         rderr = d3.d3_readmat(database, dcs(), mdb_name & "\glcontrols")
         If UBound(dcs) < 1 Then debt_cont = "missing debtor control" Else debt_cont = dcs(1)
      Else
         debt_cont = pick.extract(debtor_controls, 1, Cr_Relation, 0)
         If debt_cont = "" Then debt_cont = pick.extract(debtor_controls, 1, 1, 0)
      End If
      If Left(debt_cont, 1) = "." Then debt_cont = (Cr_Relation - 1) & debt_cont
      Cashamtot = 0
      Cashused_Ref = "": Cashused_Amt = "": Cashused_Dte = ""
      Days_To_Pay = 0: Days_Ct_Pay = 0: Days_Used = 0
'
      If Tr_Inv_Bal = 0 Then Cashamtot = Tr_Inv_Amt: GoTo 500
'
50    Cashrefs = pick.extract(Cr_Rec, 49, 0, 0)
      If Cashrefs = "" Then GoTo 500 Else max = pick.dcount(Cashrefs, Chr(253))
      For Cashpos = 1 To max
         If pick.extract(Cashrefs, 1, Cashpos, 0) <> "" And Mid(Tr_Inv_Ref, 1, Len(pick.extract(Cashrefs, 1, Cashpos, 0))) = pick.extract(Cashrefs, 1, Cashpos, 0) Then GoTo 54
      Next Cashpos
      GoTo 500
54    Cashid = pick.extract(Cr_Rec, 50, Cashpos, 0)
      Cashamt = pick.extractcur(Cr_Rec, 51, Cashpos, 0)
      If Cashamt > Tr_Inv_Amt - Cashamtot Then Cashamt = Tr_Inv_Amt - Cashamtot
      For Cashp = 49 To 51
         Cr_Rec = pick.delet(Cr_Rec, Cashp, Cashpos, 0)
      Next Cashp
'
' update cash receipt, as now have invoice
'
      Ddtes = CStr(Tr_Inv_Date)
      If LEDG_DATE <> "" And LEDG_DATE <> CStr(Tr_Inv_Date) Then Ddtes = Ddtes & "/" & LEDG_DATE

      Cashrefs = pick.extract(Cr_Rec, 12, 0, 0)
      If pick.locate(Cashid, Cashrefs, 1, 1, 0, Cashp, "") = 0 Then GoTo 100
      Cashtyp = pick.extractint(Cr_Rec, 11, Cashp, 0)
      If Cashtyp >= 50 Then GoTo 100
      Casha = pick.extractcur(Cr_Rec, 13, Cashp, 0)
      Casha = Casha - pick.extractcur(Cr_Rec, 16, Cashp, 0)
      If Cashamt > -Casha Then Cashamt = -Casha
      If Cashamt <= 0 Then GoTo 100
      tempcur = pick.extractcur(Cr_Rec, 16, Cashp, 0)
      Cr_Rec = pick.Replace(Cr_Rec, 16, Cashp, 0, tempcur - Cashamt)
      Cr_Rec = pick.Insert(Cr_Rec, 26, Cashp, -1, Tr_Inv_Ref)
      Cr_Rec = pick.Insert(Cr_Rec, 30, Cashp, -1, CStr(Cashamt))
      Cr_Rec = pick.Insert(Cr_Rec, 42, Cashp, -1, Ddtes)
      temp = pick.extract(Cr_Rec, 14, Cashp, 0)
      If IsNumeric(temp) Then Cashdte = CCur(temp) Else Cashdte = 0
      Cashldte = pick.extract(Cr_Rec, 32, Cashp, 0)
      GoTo 200
'
' GO THRU OVERFLOWS FOR REFERENCE
'
100   For Cashofo = Cr_Ovfno To 1 Step -1
         Ovf_Key = Cashofo & "*" & Client_No
         If d3.d3_readstr(database, Tran, "TD.OFLOW", Ovf_Key) <> 0 Then GoTo 180 'Release TD_OFLOW_DATA, Ovf_Key: GoTo 180
         Cashrefs = pick.extract(Tran, 3, 0, 0)
         If pick.locate(Cashid, Cashrefs, 1, 1, 0, Cashp, "") = 0 Then GoTo 180 'Release TD_OFLOW_DATA, Ovf_Key: GoTo 180
         temp = pick.extract(Tran, 2, Cashp, 0)
         If IsNumeric(temp) Then Cashtyp = CInt(temp) Else Cashtyp = 0
         If Cashtyp >= 50 Then GoTo 180 'Release TD_OFLOW_DATA, Ovf_Key: GoTo 180
'$INSERT I.LOG.UPDATE '|TD.OFLOW|':OVF.KEY ? TRAN   *
         Casha = pick.extractcur(Tran, 4, Cashp, 0)
         Casha = Casha - pick.extractcur(Tran, 6, Cashp, 0)
         If Cashamt > -Casha Then Cashamt = -Casha
         If Cashamt <= 0 Then GoTo 180 'Release TD_OFLOW_DATA, Ovf_Key: GoTo 180
         tempcur = pick.extractcur(Tran, 6, Cashp, 0)
         Tran = pick.Replace(Tran, 6, Cashp, 0, tempcur - Cashamt)
         Tran = pick.Insert(Tran, 9, Cashp, -1, Tr_Inv_Ref)
         Tran = pick.Insert(Tran, 10, Cashp, -1, CStr(Cashamt))
         Tran = pick.Insert(Tran, 12, Cashp, -1, Ddtes)
         rderr = d3.d3_writestr(database, "td.oflow", Cashofo & "*" & Client_No, Tran)
         temp = pick.extract(Tran, 5, Cashp, 0)
         If IsNumeric(temp) Then Cashdte = CCur(temp) Else Cashdte = 0
         Cashldte = pick.extract(Tran, 11, Cashp, 0)
         GoTo 200
180   Next Cashofo
      GoTo 50
'
200   tempcur = pick.extractcur(Cr_Rec, 22, 0, 0)
      Cr_Rec = pick.Replace(Cr_Rec, 22, 0, 0, tempcur - Cashamt)
      Cashamtot = Cashamtot + Cashamt
      Cashused_Ref = pick.Insert(Cashused_Ref, 1, 1, -1, Cashid)
      Cashused_Amt = pick.Insert(Cashused_Amt, 1, 1, -1, CStr(Cashamt))
      Cdtes = CStr(Cashdte)
      If Cashldte <> "" And Cashldte <> CStr(Cashdte) Then Cdtes = Cdtes & "/" & Cashldte
      Cashused_Dte = pick.Insert(Cashused_Dte, 1, 1, -1, Cdtes)
      If Cashtyp = CInt(Tr_Cash) Then
         Days_Used = 1
         Days_To_Pay = Days_To_Pay + Tr_Inv_Date - Cashdte
         Days_Ct_Pay = Days_Ct_Pay + 1
      End If
      GoTo 50
'
'    GET RECORD FOR INSERTION OF TRANSACTION
'
500
     If Cr_Ovfno = 0 Then
        Ovf_No = 1
     Else
         Oflow_Dates = pick.extract(Cr_Rec, 28, 0, 0)
         If pick.locate(CStr(Tr_Inv_Date), Oflow_Dates, 1, 1, 0, I, "DR") = 0 Then
         End If
         Ovf_No = Cr_Ovfno - I + 2   'WILL BE CR_OVFNO + 1 FOR MASTER_ OK
         If Ovf_No = 0 Then          ' 0 MEANS BEFORE FIRST TRANSACTION *
            Ovf_No = 1
            Cr_Rec = pick.Replace(Cr_Rec, 28, Cr_Ovfno + 1, 0, CStr(Tr_Inv_Date))
         End If
         If Ovf_No > Cr_Ovfno Then Ovf_No = Cr_Ovfno
      End If

         Ovf_Key = Ovf_No & "*" & Client_No
         If d3.d3_readstr(database, Tran, "TD.OFLOW", Ovf_Key) <> 0 Then
            '???ignore If Ovf_No <> Cr_Ovfno + 1 Then GoTo 9100
'$INSERT I.LOG.ADD '|TD.OFLOW|':OVF.KEY ? TRAN   *
            Tran = ""
            GoTo 560
         End If
'$INSERT I.LOG.UPDATE '|TD.OFLOW|':OVF.KEY ? TRAN   *
560      Cr_No_Trans = pick.extractint(Tran, 1, 0, 0)
         Cr_Tdate = pick.extract(Tran, 5, 0, 0)

      For I = 1 To Cr_No_Trans
         If Tr_Inv_Date < CInt(pick.extract(Cr_Tdate, 1, I, 0)) Then GoTo 570
      Next I
'
570   If Cr_Ovfno = 0 Then
          Cr_Rec = pick.Replace(Cr_Rec, 28, 0, 0, Tr_Inv_Date & Chr(253) & Tr_Inv_Date)
          Cr_Rec = pick.Replace(Cr_Rec, 27, 0, 0, "1")
      End If
         Tran = pick.Replace(Tran, 1, 0, 0, CStr(Cr_No_Trans + 1))
         Tran = pick.Insert(Tran, 2, I, 0, Tr_Code)
         Tran = pick.Insert(Tran, 3, I, 0, Tr_Inv_Ref)
         Tran = pick.Insert(Tran, 4, I, 0, CStr(Tr_Inv_Amt))
         Tran = pick.Insert(Tran, 5, I, 0, CStr(Tr_Inv_Date))
         Tran = pick.Insert(Tran, 6, I, 0, CStr(Cashamtot))
         Tran = pick.Insert(Tran, 7, I, 0, Tr_Narr)
         Tran = pick.Insert(Tran, 8, I, 0, TR_CUST_REF)
         Tran = pick.Insert(Tran, 9, I, 0, Cashused_Ref)
         Tran = pick.Insert(Tran, 10, I, 0, Cashused_Amt)
         Tran = pick.Insert(Tran, 11, I, 0, LEDG_DATE)
         Tran = pick.Insert(Tran, 12, I, 0, Cashused_Dte)
         Tran = pick.Insert(Tran, 13, I, 0, Stmnt_Date)
         Tran = pick.Insert(Tran, 14, I, 0, "")
         rderr = d3.d3_writestr(database, "td.oflow", Ovf_Key, Tran)
      If Ovf_No = Cr_Ovfno Then
         Cr_Rec = pick.Replace(Cr_Rec, 28, 1, 0, pick.extract(Tran, 5, Cr_No_Trans + 1, 0))
      End If
      Cr_Rec = pick.Replace(Cr_Rec, 3, 0, 0, CStr(Cr_Cur_Bal + Tr_Inv_Bal))
      If Tr_Inv_Bal < 0 Then
        temp = pick.extract(Cr_Rec, 22, 0, 0)
        If IsNumeric(temp) Then tempcur = CCur(temp) Else tempcur = 0
        Cr_Rec = pick.Replace(Cr_Rec, 22, 0, 0, tempcur - Tr_Inv_Amt)
      End If
      If Days_Used Then
         Days_To_Pay = Int(Days_To_Pay / Days_Ct_Pay + 0.5)
         Cr_Rec = pick.Insert(Cr_Rec, 20, 1, 0, CStr(Days_To_Pay))
         Cr_Rec = pick.delet(Cr_Rec, 20, 11, 0)
      End If
'
      First_Unpaid = pick.extractcur(Cr_Rec, 53, 0, 0) ' first unpaid trans
      If Tr_Inv_Date < First_Unpaid Then
        If Tr_Inv_Amt - Cashamtot <> 0 Then
          Cr_Rec = pick.Replace(Cr_Rec, 53, 0, 0, CStr(Tr_Inv_Date))
        End If
      End If
'
      Exit Sub
'
' CREATE OVERFLOW
'
8900  Sec_Ovf = "": H2 = 0
      Half = Int(Cr_No_Trans / 2) ' IF HALF = 0 THEN GOTO 8980
      H2 = Cr_No_Trans - Half
      temp = pick.extract(Sec_Ovf, 1, 0, 0)
      If IsNumeric(temp) Then H2 = H2 + CInt(temp)
      Sec_Ovf = pick.Replace(Sec_Ovf, 1, 0, 0, CStr(H2))
      For V = 2 To 14
         Ovf = pick.extract(overflow, V, 0, 0): M = pick.Index(Ovf, Chr(253), Half)
         If M = 0 Then M = 32260         '* NO VALUES STORED **
         Sec_Ovf = pick.Insert(Sec_Ovf, V, 1, 0, Mid(Ovf, M + 1, 32260))
         overflow = pick.Replace(overflow, V, 0, 0, Mid(Ovf, 1, M - 1))
      Next V
      Cr_No_Trans = Half
'
8980  overflow = pick.Replace(overflow, 1, 0, 0, CStr(Cr_No_Trans))
      rderr = d3.d3_writestr(database, "td.oflow", Cr_Ovfno & "*" & Client_No, overflow)
      Cr_Ovfno = Cr_Ovfno + 1
      rderr = d3.d3_writestr(database, "td.oflow", Cr_Ovfno & "*" & Client_No, Sec_Ovf)
      Cr_Rec = pick.Insert(Cr_Rec, 28, 2, 0, pick.extract(Sec_Ovf, 5, 1, 0))
      Cr_Rec = pick.Replace(Cr_Rec, 27, 0, 0, CStr(Cr_Ovfno))
      Cr_Rec = pick.Replace(Cr_Rec, 28, 1, 0, pick.extract(Sec_Ovf, 5, Cr_No_Trans, 0))
      Return

End Sub
Public Sub SR340(logentry As String, LEDG_DATE As Integer, Client_No As String, Cr_Rec As String, Tr_Inv_Ref As String, Tr_Inv_Date As Integer, Remit_Chq As String, Tr_Inv_Amt As Currency, tr_discount As Currency, std_disc As String, Due_Date As String, tr_bal_owing As Currency, pps As Currency, Tr_Code As String, Tr_Narr As String, Cr_Relation As Integer, Gl_Post As String, Gl_Post_Amt As String, GL_POST_LDATE As String, Cred_Cont As String)

Dim sentence As String, pick_cnt As Long, mylist2() As String, mylist() As String
Dim rrec As String, tempint As Integer, acode As String, tempcur As Currency, temp As String
Dim crbal As Currency, overflow As String, database As String, total_items As Currency, kk As Integer

Dim AUTHOR As String, Disc_Acct As String, Discflag As String
Dim Newterms As String, Openitem As String, Pps_Flg As String, Tr_Chq_Req As String
Dim bal_owing As Currency, Use_Amt As Currency, Dd_Amt_Used As Currency
Dim Dd_Bal As Currency, I As Integer, Unique As String
Dim Xx As Integer, Rrdtes As String, rderr As Integer, Ans As String
'
' ALLOCATE CREDIT TO CREDITORS ACCOUNT
' OR ALLOCATE DEBIT WHERE TRANSACTIONS TO BE POSTED ARE ALREADY KNOWN
'   TR.INV.AMT WILL BE NEGATIVE AND BALANCE LEFT IN USE.INV.AMT<1,5>
'
'
      database = pick.extract(logentry, 2, 0, 0)
      
      AUTHOR = g_trans_info_array(25)
      If AUTHOR = "" Then AUTHOR = "0"
      Disc_Acct = pick.extract(g_trans_info_array(38), 1, 1, 0)
      Discflag = pick.extract(g_trans_info_array(38), 1, 2, 0)
      If Discflag = "" Then Discflag = "0"
      Newterms = pick.extract(g_trans_info_array(38), 1, 3, 0)
      If Newterms = "" Then Newterms = "0"
      Openitem = Mid(g_trans_info_array(49), 4, 1)
      If Openitem = "" Or Openitem = " " Then Openitem = "0"
      Pps_Flg = pick.extract(g_trans_info_array(113), 1, 1, 0)
      If Pps_Flg = "" Then Pps_Flg = "0"
      If AUTHOR = "1" Then acode = "0" Else acode = ""
      Tr_Chq_Req = "51"
'
      temp = pick.extract(Cr_Rec, 3, 0, 0)
      If IsNumeric(temp) Then Cr_Relation = CInt(temp) + 1 Else Cr_Relation = 1
      If Cr_Relation = 1 Then Cred_Cont = g_trans_info_array(12) Else Cred_Cont = pick.extract(g_trans_info_array(13), 1, Cr_Relation - 1, 0)
      If Cred_Cont = "" Then Cred_Cont = g_trans_info_array(12)
      If pick.extract(Cred_Cont, 1, 1, 2) <> "" Then
         If (CInt(Tr_Code) >= 50 And Tr_Code <> "56" And Tr_Code <> "60") Or (Tr_Code = "26" Or Tr_Code = "27" Or Tr_Code = "36" Or Tr_Code = "30") Then Cred_Cont = pick.extract(Cred_Cont, 1, 1, 1) Else Cred_Cont = pick.extract(Cred_Cont, 1, 1, 2)
      End If
      If Left(Cred_Cont, 1) = "." Then Cred_Cont = (Cr_Relation - 1) & Cred_Cont
      bal_owing = Tr_Inv_Amt
      Use_Amt = Tr_Inv_Amt
      If Tr_Inv_Amt < 0 Then
         bal_owing = tr_bal_owing
         Use_Amt = -Use_Amt
         If Discflag <> "0" Then
           Use_Amt = Use_Amt - tr_discount
           tr_discount = 0
         End If
         If Pps_Flg <> "0" Then
           Use_Amt = Use_Amt - pps
           pps = 0
         End If
      End If
      temp = pick.extract(Cr_Rec, 1, 0, 0)
      If IsNumeric(temp) Then crbal = CCur(temp) Else crbal = 0
      If crbal < 0 And Tr_Inv_Amt > 0 And Openitem = "0" Then
         If Tr_Inv_Amt + crbal >= 0 Then
            bal_owing = Tr_Inv_Amt + crbal
         Else
            bal_owing = 0
         End If
' NOW FIND DEBIT THAT HAS BEEN USED & PUT ALLOCATION DETAILS ON IT
         Dd_Amt_Used = -crbal
         If Tr_Inv_Amt < Dd_Amt_Used Then Dd_Amt_Used = Tr_Inv_Amt
' START ON OVERFLOWS FROM FIRST.UNPAID ONE ONLY
         sentence = "sselect cr_trans with a1 = """ & Client_No & """ and with tr_bal # ""0"" by a2"
         total_items = d3.d3_select(logentry, sentence, mylist(), pick_cnt, 0, 0) - 1
         For kk = 0 To total_items
            If d3.d3_readstr(database, overflow, "CR.TRANS", mylist(kk)) <> 0 Then GoTo 495
            temp = pick.extract(overflow, 3, 0, 0)
            If IsNumeric(temp) Then tempcur = CCur(temp) Else tempcur = 0
            If tempcur < 50 Then GoTo 495
            temp = pick.extract(overflow, 6, 0, 0)
            If IsNumeric(temp) Then Dd_Bal = CCur(temp) Else Dd_Bal = 0
            If Dd_Bal = 0 Then GoTo 495
'$INSERT I.LOG.UPDATE '|CR_TRANS|':TRID ? OVERFLOW   *
            If Dd_Bal >= Dd_Amt_Used Then
               overflow = pick.Replace(overflow, 6, 0, 0, CStr(Dd_Bal - Dd_Amt_Used))
               overflow = pick.Insert(overflow, 9, 1, 1, CStr(Dd_Amt_Used))
               Dd_Amt_Used = 0
450            overflow = pick.Insert(overflow, 8, 1, 1, Tr_Inv_Ref)
               temp = CStr(Tr_Inv_Date)
               If LEDG_DATE <> Tr_Inv_Date Then temp = temp & "/" & LEDG_DATE
               overflow = pick.Insert(overflow, 13, 1, 1, temp)
               GoTo 490
            Else
               overflow = pick.Replace(overflow, 6, 0, 0, 0)
               overflow = pick.Replace(overflow, 9, 1, 1, CStr(Dd_Bal))
               Dd_Amt_Used = Dd_Amt_Used - Dd_Bal
               GoTo 450
            End If
490         rderr = d3.d3_writestr(database, "CR_TRANS", mylist(kk), overflow)
            If Dd_Amt_Used = 0 Then GoTo 500
495:     Next kk
      End If
'
' IF DID NOT FIND ALL OF AMOUNT NOTHING CAN BE DONE ABOUT IT
'
500      overflow = Client_No
         overflow = pick.Insert(overflow, 2, 1, 0, CStr(Tr_Inv_Date))
         overflow = pick.Insert(overflow, 3, 1, 0, Tr_Code)
         overflow = pick.Insert(overflow, 4, 1, 0, Tr_Inv_Ref)
         overflow = pick.Insert(overflow, 5, 1, 0, CStr(Use_Amt))
         overflow = pick.Insert(overflow, 6, 1, 0, CStr(bal_owing))
         overflow = pick.Insert(overflow, 7, 1, 0, Tr_Narr)
         overflow = pick.Insert(overflow, 8, 1, 0, Gl_Post)
         overflow = pick.Insert(overflow, 9, 1, 0, Gl_Post_Amt)
         If AUTHOR <> "0" Then overflow = pick.Insert(overflow, 10, 1, 0, acode)
         overflow = pick.Insert(overflow, 11, 1, 0, Remit_Chq)
         overflow = pick.Insert(overflow, 12, 1, 0, CStr(LEDG_DATE))
         overflow = pick.Insert(overflow, 13, 1, 0, GL_POST_LDATE)
         If Disc_Acct <> "" Then
            If tr_discount <> 0 Then temp = CStr(tr_discount) Else temp = ""
            overflow = pick.Insert(overflow, 14, 1, 0, temp)
         End If
         If Discflag <> "0" Then overflow = pick.Insert(overflow, 15, 1, 0, std_disc)
         If Newterms <> "0" Then overflow = pick.Insert(overflow, 16, 1, 0, Due_Date)
         If Pps_Flg <> "0" Then
            If pps <> 0 Then temp = CStr(pps) Else temp = ""
            overflow = pick.Insert(overflow, 17, 1, 0, temp)
         End If
2001     Unique = Timer()
         If d3.d3_readstr(database, temp, "CR.TRANS", Unique) <> 0 Then GoTo 2002
'         Release CR_TRANS_DATA, Unique
         GoTo 2001
2002
'$INSERT I.LOG.ADD '|CR_TRANS|':UNIQUE 2001
         rderr = d3.d3_writestr(database, "CR_TRANS", Unique, overflow)

      If (Tr_Code = "65" And Tr_Inv_Amt > 0) Then
         Cr_Rec = pick.Replace(Cr_Rec, 1, 0, 0, crbal - Tr_Inv_Amt)
      Else
         Cr_Rec = pick.Replace(Cr_Rec, 1, 0, 0, crbal + Tr_Inv_Amt)
      End If
      If Tr_Code = Tr_Chq_Req Then
         temp = pick.extract(Cr_Rec, 26, 1, 0)
         If IsNumeric(temp) Then tempint = CInt(temp) Else tempint = 0
         If Tr_Inv_Date >= tempint Then Cr_Rec = pick.Replace(Cr_Rec, 26, 0, 0, Tr_Inv_Date & Chr(253) & Tr_Inv_Ref & Chr(253) & Use_Amt)
      End If
'
      If Remit_Chq = "" Then
        Ans = pick.extract(Cr_Rec, 29, 0, 0)
        If IsNumeric(Ans) Then tempint = CInt(Ans) Else tempint = -1
        If tempint = -1 Or Tr_Inv_Date < tempint Then Cr_Rec = pick.Replace(Cr_Rec, 29, 0, 0, CStr(Tr_Inv_Date))
      End If
'
      If bal_owing = Use_Amt Then
         temp = pick.extract(Cr_Rec, 27, 0, 0)
         If IsNumeric(temp) Then tempint = CInt(temp) Else tempint = 0
         If Tr_Inv_Date < tempint Then Cr_Rec = pick.Replace(Cr_Rec, 27, 0, 0, CStr(Tr_Inv_Date))
         GoTo 590
      End If
      temp = pick.extract(Cr_Rec, 1, 0, 0)
      If IsNumeric(temp) Then crbal = CCur(temp) Else crbal = 0
      If crbal = 0 And Openitem = "0" Then Cr_Rec = pick.Replace(Cr_Rec, 27, 0, 0, "99999"): GoTo 590
'
' FIND FIRST UNPAID -----
'
       Xx = 1: GoSub 7000
'
590   If Tr_Code = Tr_Chq_Req Then     ' CHEQUE REQUEST ?
' RESET DATE OF FIRST TRANS NOT YET APPEARED ON REMIT ADVICE
         Xx = 2: GoSub 7000
      End If
      Exit Sub                             '* TO CALLING PROGRAM **
'
'
' S/R TO RESET "FIRST" DATE  (UNPAID OR UNREMITTED)
'
7000    If Xx = 1 Then
           sentence = "sselect cr_trans with a1 = """ & Client_No & """ and with tr_bal # ""0"" by a2"
        Else
           sentence = "sselect cr_trans with a1 = """ & Client_No & """ and with a11 = ""0"" by a2"
        End If
        If d3.d3_select(logentry, sentence, mylist2(), pick_cnt, 0, 0) = 0 Then
           If Xx = 2 Then Cr_Rec = pick.Replace(Cr_Rec, 29, 0, 0, 99999)
           Return
        End If
        If d3.d3_readstr(database, rrec, "CR.TRANS", mylist2(0)) <> 0 Then Return
        Rrdtes = pick.extract(rrec, 2, 0, 0)
        If Xx = 1 Then     ' FIRST UNPAID DATE TEST
           Cr_Rec = pick.Replace(Cr_Rec, 27, 0, 0, Rrdtes)
        Else
           Cr_Rec = pick.Replace(Cr_Rec, 29, 0, 0, Rrdtes) ' FIRST UNREMITTED DATE TEST
        End If
        Return

End Sub


Public Function debtors_invoice(logentry As String, tbl_name As String, transfile As String, id, old_rec As String, the_rec As String, transrecbefore As String, transrec As String, action As String) As String
'
' add debtors invoice
'
Dim database As String, username As String, how As Integer
Dim Acct As String, desc As String, conversion As String, ACCOUNT As String, searchfile As String
Dim wterr As String, mdb_name As String, lines() As String, rec() As String, errfile As String
Dim wrec() As String, max As Integer, kk As Integer, Pos As Integer, Total As Currency, totalgst As Currency
Dim inv_code As String, rderr As Integer, rd() As String, File As String, last_invoice As Integer
Dim sentence As String, No_recs As Integer, pick_cnt As Long, ids() As String, Invid As String, I As Integer
Dim clrec() As String

database = pick.extract(logentry, 2, 0, 0)
username = pick.extract(logentry, 3, 0, 0)

Pos = InStr(tbl_name, ".mdb\")
If Pos <> 0 Then
    mdb_name = Left(tbl_name, Pos + 3)
    errfile = Mid(tbl_name, Pos + 5)
    how = 1
Else
    mdb_name = tbl_name
    errfile = tbl_name
    how = 0
End If

wterr = "0" 'this means all was okay
If action = "D" Or action = "W" Then
    wterr = d3.d3_delete(database, tbl_name, CStr(id))
    If wterr <> "0" Then GoTo finish
    sentence = "Select * from " & transfile & " where Id = " & Chr(34) & id & Chr(34)
    No_recs = d3.msa_select(mdb_name, sentence, ids, pick_cnt, 0, 0)
    If No_recs > 0 Then
    For I = 0 To No_recs - 1
        Invid = ids(I)
        wterr = d3.d3_delete("", mdb_name & "\" & transfile, Invid)
        If wterr <> "0" Then GoTo finish
    Next I
    End If
    If action = "D" Then
        debtors_invoice = wterr
        Exit Function
    End If
End If

'action = "W" - updating existing item
'action = "A" - adding new item

If how = 1 Then
   'If transrec = "" Then GoTo entry
   
If transrec = "" Then debtors_invoice = "Cannot update null invoice/credit note": Exit Function

If action = "W" Then GoTo UpdateInvoice

If id <> "=" Then debtors_invoice = "invoice numbers cannot be entered manually": Exit Function

File = mdb_name & "\inv_codes"
inv_code = pick.field(the_rec, Chr(8), 34)
ReDim rd(0)
rd(0) = inv_code
rderr = d3.d3_readmat(database, rd, File)
If rderr <> 0 Then debtors_invoice = "Invoice code not found!": Exit Function
If rd(2) = "" Then last_invoice = 0 Else last_invoice = CInt(rd(2))
last_invoice = last_invoice + 1
id = inv_code & last_invoice

UpdateInvoice:

   rec = Split(CStr(id) & Chr(8) & the_rec, Chr(8))
   lines = Split(transrec, Chr(8))
   max = UBound(lines)
   
    For kk = 0 To max Step 10
        Acct = lines(kk)
        If Acct <> "" Then
           ' pos = InStr(Acct, ".")
            'If pos <> 0 Then
           '     Desc = d3.conv_translate(database, "TACCOUNTDESC", Acct) 'mco
           ' Else
                desc = d3.conv_translate(database, "TSTOCKDESC", Acct) 'mco
           ' End If
            ReDim wrec(16)
            'If UCase(Left(Acct, 3)) = "JOB" Then Acct = Mid(Acct, 4)
            wrec(1) = id
            wrec(2) = CStr(kk / 10 + 1)
            wrec(4) = Acct                'Account
            wrec(5) = lines(kk + 8)       'Amount
            Total = Total + CCur(wrec(5))
            wrec(6) = lines(kk + 1)       'Desc
            wrec(7) = lines(kk + 6)       'Qty
            wrec(8) = lines(kk + 2)       'Cost
            wrec(9) = lines(kk + 7)       'Price
            wrec(10) = lines(kk + 3)      'GST Code
            wrec(11) = lines(kk + 9)      'GSt
            totalgst = totalgst + CCur(wrec(11))
            wrec(12) = lines(kk + 5)      'GSt Account
            If wrec(12) = "" Then
               ReDim clrec(0): clrec(0) = wrec(10)
               rderr = d3.d3_readmat(database, clrec(), mdb_name & "\gst")
               If UBound(clrec) > 1 Then wrec(12) = clrec(2) ' read account
            End If
            wrec(13) = desc      'Account Desc original
            wrec(14) = CCur(wrec(5)) + CCur(wrec(11))
            wrec(0) = id & "_" & CStr(kk / 10 + 1)
                    
            wterr = d3.d3_writemat(database, transfile, wrec())
            If wterr <> "0" Then debtors_invoice = wterr: Exit Function
        End If
    Next kk

If action = "D" Then GoTo finish

rec(6) = totalgst
rec(8) = Total
rec(16) = Total + totalgst

ReDim clrec(0): clrec(0) = rec(3)
rderr = d3.d3_readmat(database, clrec(), "CLIENT")
If UBound(clrec) < 7 Then ReDim Preserve clrec(7)
rec(9) = clrec(1) 'name
rec(10) = clrec(6) 'initials
rec(11) = clrec(7) 'given
rec(12) = pick.extract(clrec(2), 1, 1, 0)
rec(13) = pick.extract(clrec(3), 1, 1, 0)
rec(14) = pick.extract(clrec(4), 1, 1, 0)
rec(15) = pick.extract(clrec(5), 1, 1, 0)

wterr = d3.d3_writemat(database, tbl_name, rec())
If wterr <> "0" Then debtors_invoice = wterr: Exit Function

If action = "A" Then
    Pos = InStr(id, inv_code)
    If Pos <> 0 Then rd(2) = Mid(id, Pos + 2)
    wterr = d3.d3_writemat(database, File, rd())
End If

finish:

debtors_invoice = wterr '& "=" & DateValue(rec(21)) & "=" & rec(21)

End If

End Function

Public Function supplier_invoice(logentry As String, tbl_name As String, transfile As String, id, old_rec As String, the_rec As String, transrecbefore As String, transrec As String, action As String) As String
'
' add debtors invoice
'
Dim database As String, username As String, how As Integer
Dim Acct As String, desc As String, conversion As String, ACCOUNT As String, searchfile As String
Dim wterr As String, mdb_name As String, lines() As String, rec() As String, errfile As String
Dim wrec() As String, max As Integer, kk As Integer, Pos As Integer, Total As Currency, totalgst As Currency
Dim inv_code As String, rderr As Integer, rd() As String, File As String, last_invoice As Integer
Dim sentence As String, No_recs As Integer, pick_cnt As Long, ids() As String, Invid As String, I As Integer
Dim clrec() As String

database = pick.extract(logentry, 2, 0, 0)
username = pick.extract(logentry, 3, 0, 0)

Pos = InStr(tbl_name, ".mdb\")
If Pos <> 0 Then
    mdb_name = Left(tbl_name, Pos + 3)
    errfile = Mid(tbl_name, Pos + 5)
    how = 1
Else
    mdb_name = tbl_name
    errfile = tbl_name
    how = 0
End If

wterr = "0" 'this means all was okay
If action = "D" Or action = "W" Then
    wterr = d3.d3_delete(database, tbl_name, CStr(id))
    If wterr <> "0" Then GoTo finish
    sentence = "Select * from " & transfile & " where Id = " & Chr(34) & id & Chr(34)
    No_recs = d3.msa_select(mdb_name, sentence, ids, pick_cnt, 0, 0)
    If No_recs > 0 Then
    For I = 0 To No_recs - 1
        Invid = ids(I)
        wterr = d3.d3_delete("", mdb_name & "\" & transfile, Invid)
        If wterr <> "0" Then GoTo finish
    Next I
    End If
    If action = "D" Then
        supplier_invoice = wterr
        Exit Function
    End If
End If

'action = "W" - updating existing item
'action = "A" - adding new item

If how = 1 Then
   'If transrec = "" Then GoTo entry
   
If transrec = "" Then supplier_invoice = "Cannot update null invoice/credit note": Exit Function

If action = "W" Then GoTo UpdateInvoice

If id <> "=" Then supplier_invoice = "invoice numbers cannot be entered manually": Exit Function

File = mdb_name & "\inv_codes"
inv_code = pick.field(the_rec, Chr(8), 34)
ReDim rd(0)
rd(0) = inv_code
rderr = d3.d3_readmat(database, rd, File)
If rderr <> 0 Then supplier_invoice = "Invoice code not found!": Exit Function
If rd(2) = "" Then last_invoice = 0 Else last_invoice = CInt(rd(2))
last_invoice = last_invoice + 1
id = inv_code & last_invoice

UpdateInvoice:

   rec = Split(CStr(id) & Chr(8) & the_rec, Chr(8))
   lines = Split(transrec, Chr(8))
   max = UBound(lines)
   
    For kk = 0 To max Step 10
        Acct = lines(kk)
        If Acct <> "" Then
            Pos = InStr(Acct, ".")
            If Pos <> 0 Then
                If UCase(Left(Acct, 3)) = "JOB" Then
                    searchfile = "job.l"
                    conversion = "Tjob.l;2"
                    ACCOUNT = Mid(Acct, 4)
                Else
                    searchfile = "gen.l"
                    conversion = "Tgen.l;2"
                    ACCOUNT = Acct
                End If
            Else
                searchfile = "stock"
                conversion = "Tstock;1"
                ACCOUNT = Acct
            End If
            desc = d3.conv_out(database, "", 0, conversion, ACCOUNT)
            ReDim wrec(25)
            'If UCase(Left(Acct, 3)) = "JOB" Then Acct = Mid(Acct, 4)
            wrec(1) = id
            wrec(2) = CStr(kk / 10 + 1)
            wrec(4) = Acct                'Account
            wrec(5) = lines(kk + 8)       'Amount
            Total = Total + CCur(wrec(5))
            wrec(6) = lines(kk + 1)       'Desc
            wrec(7) = lines(kk + 6)       'Qty
            wrec(8) = lines(kk + 2)       'Cost
            wrec(9) = lines(kk + 7)       'Price
            wrec(10) = lines(kk + 3)      'GST Code
            wrec(11) = lines(kk + 9)      'GSt
            totalgst = totalgst + CCur(wrec(11))
            'wrec(12) = lines(kk + 5)      'GSt Account
            'If wrec(12) = "" Then
            '   ReDim clrec(0): clrec(0) = wrec(10)
            '   rderr = d3.d3_readmat(database, clrec(), mdb_name & "\gst")
            '   If UBound(clrec) > 1 Then wrec(12) = clrec(2) ' read account
            'End If
            'wrec(13) = Desc      'Account Desc original
            'wrec(14) = CCur(wrec(5)) + CCur(wrec(11))
            wrec(0) = id & "_" & CStr(kk / 10 + 1)
                    
            wterr = d3.d3_writemat(database, transfile, wrec())
            If wterr <> "0" Then supplier_invoice = wterr: Exit Function
        End If
    Next kk

If action = "D" Then GoTo finish

rec(32) = totalgst
rec(8) = Total
'rec(16) = Total + totalgst

'ReDim clrec(0): clrec(0) = rec(3)
'rderr = d3.d3_readmat(database, clrec(), "CLIENT")
'If UBound(clrec) < 7 Then ReDim Preserve clrec(7)
'rec(9) = clrec(1) 'name
'rec(10) = clrec(6) 'initials
'rec(11) = clrec(7) 'given
'rec(12) = pick.extract(clrec(2), 1, 1, 0)
'rec(13) = pick.extract(clrec(3), 1, 1, 0)
'rec(14) = pick.extract(clrec(4), 1, 1, 0)
'rec(15) = pick.extract(clrec(5), 1, 1, 0)

wterr = d3.d3_writemat(database, tbl_name, rec())
If wterr <> "0" Then supplier_invoice = wterr: Exit Function

If action = "A" Then
    Pos = InStr(id, inv_code)
    If Pos <> 0 Then rd(2) = Mid(id, Pos + 2)
    wterr = d3.d3_writemat(database, File, rd())
End If

finish:

supplier_invoice = wterr '& "=" & DateValue(rec(21)) & "=" & rec(21)

End If

End Function


Public Function debtors_maint_invoice(logentry As String, tbl_name As String, id, the_rec As String, old_rec As String, old_trans_rec As String, trans_rec As String, action As String) As String

Dim rec As String, max As Integer, kk As Integer, wrec() As String, Mrec() As String, daterec() As String
Dim database As String, Cde As String, username As String
Dim wterr As String, mdb_name As String
Dim mthends() As String, dte As String
Dim Acceptclose As String, vfdate, vtdate, Start_Year As String, curryear As Integer
Dim the_mth As Integer, thisyr As String, suffix As String, DebtorId As String, AgrId As String

database = pick.extract(logentry, 2, 0, 0)
username = pick.extract(logentry, 3, 0, 0)
kk = InStr(tbl_name, ".mdb\")
mdb_name = Left(tbl_name, kk + 3)

debtors_maint_invoice = "0" 'this means all was okay
AgrId = CStr(id)

wrec = Split(trans_rec, Chr(8))
Mrec = Split(AgrId & Chr(8) & the_rec, Chr(8))
max = UBound(wrec) - 1

DebtorId = Mrec(19)
AgrId = DebtorId & "*" & AgrId
Mrec(0) = AgrId
id = AgrId

If action = "D" Then
   ReDim testrec(0): testrec(0) = AgrId
   debtors_maint_invoice = d3.d3_delete(database, tbl_name, AgrId)
   Exit Function
End If

'action = "W" - updating existing item
'action = "A" - adding new item
   
   'get_month_ends(mdb_name, curryear, mthends(), Start_Year, Vfdate, Vtdate, "", Acceptclose)
   'dte = wrec(0) 'date of debtors_maint_invoice
   
   'If DateDiff("d", dte, Vfdate) >= 0 Or DateDiff("d", Vtdate, dte) >= 0 Then
   '     debtors_maint_invoice = "debtors_maint_invoice date " & dte & " must be between " & Vfdate & " and " & Vtdate
   '     Exit Function
   'End If
   
   'Call get_the_mth(dte, mthends(), curryear, the_mth, thisyr, suffix)
    
   For kk = 0 To max Step 2
    If wrec(kk) <> "" Then
      ReDim daterec(4)
      daterec(1) = AgrId
      daterec(2) = CStr((kk) / 2)
      daterec(3) = wrec(kk) 'date
      daterec(4) = wrec(kk + 1) 'amount
      daterec(0) = AgrId & "_" & daterec(2)
      wterr = d3.d3_writemat(database, mdb_name & "\maint_rates", daterec())
      If wterr <> "0" Then debtors_maint_invoice = wterr: Exit Function
    End If
   Next kk

   ReDim Preserve Mrec(23)
   Mrec(21) = Date
   Mrec(22) = Time
   Mrec(23) = username
   wterr = d3.d3_writemat(database, tbl_name, Mrec())
   debtors_maint_invoice = wterr
   
End Function


Public Function ta2479(logentry As String, template_path As String, pass_parms As String)

' TA2479 GENERATE INVOICES FOR RECURRING INVOICE AGREEMENTS

Dim Cr_Invoice As String, Dr_Invoice As String, vfdate, vtdate, Pro_Rata_Flg As Integer
Dim Desc_Flg, Def, Idate, Ldate, Def_Batch
Dim NO_BATCH, Wantpr, cnt, Upto_Date, ICODE As String, Freq As String
Dim New_Upto, qty As Currency, INVNO, Dates(), Rates(), Gst_Rates(), gst_codes()
Dim Gst_Lrate, Gst_Lattr, Lrate, Lattr, value, Gst_Value
Dim Narr1() As String, Narr2() As String, Narr3() As String, Narr4() As String, Narr5() As String
Dim I, rpos, rate, Gst_Rate As String, GST_CODE, Days, val, St_Lval, Gval, At_Base
Dim Pr_Base, At_Top, Pr_Top, R_Amt_Mult, Factor, eom, Amt_Mult
Dim Client_No, glacct, Mnarr, IREC() As String, N1, Gst_Lamt, Lamt, N2 As String, Mww
Dim Mw, desc, Ct, F1, Batches_Rec
Dim Date1, norec() As String, wrec() As String
Dim sentence As String, mylist() As String, pick_cnt As Long, total_items As Long
Dim sentence2 As String, mylist2() As String, pick_cnt2 As Long, total_items2 As Long
Dim mdb_name As String, the_rec() As String, rderr As Integer
Dim year_rec() As String, mthends() As String, kk As Integer, database As String, username As String
Dim cka_gl As Object, result As String, temp As String, the_mth As Integer, wterr As Integer
Dim daterec() As String, Mrec() As String, RR As Integer, id As String, Prec() As String
Dim parms() As String, Pos As Integer, the_drive As String, tbl_name As String

      database = pick.extract(logentry, 2, 0, 0)
      username = pick.extract(logentry, 3, 0, 0)
      
      the_drive = Left(template_path, InStr(template_path, "\prospect\") - 1) & "\"
      mdb_name = the_drive & "ckashare\debtors\debtors.mdb"
      tbl_name = mdb_name & "\maint"

      ReDim the_rec(0)
      the_rec(0) = "DATES"
      rderr = d3.d3_readmat("", the_rec(), mdb_name & "\CONTROL_DEBTOR")
      If rderr <> 0 Then ta2479 = Chr(8) & "Cannot read " & mdb_name & "\CONTROL_DEBTOR item DATES": Exit Function
      If UBound(the_rec) < 3 Then ReDim Preserve the_rec(3)
      vfdate = the_rec(2) 'for debtors
      vtdate = the_rec(3) 'for debtors
    
      Set cka_gl = CreateObject("cka_gl.gl")
      result = cka_gl.get_month_ends(Replace(mdb_name, "debtors", "gen_l"), mthends(), year_rec()) 'using for g/l date range check and want mthends
      If Left(result, 1) = Chr(8) Then ta2479 = result: Exit Function
      Set cka_gl = Nothing
      
      Cr_Invoice = "25"
      Dr_Invoice = "50"
      Pro_Rata_Flg = 0 'Pro_Rata_Flg = Mid$(pick.extract(TRANS_INFO, 83, 0, 0), 1, 1) + 0
'
     'Desc_Flg = Mid$(pick.extract(TRANS_INFO, 83, 0, 0), 2, 1) + 0
'
     parms = Split(pass_parms, Chr(8))
     Date1 = parms(0)
     Idate = DateValue(parms(1))
     If DateDiff("d", Idate, vfdate) >= 0 Or DateDiff("d", vtdate, Idate) >= 0 Then 'means idate < vfdate
        ta2479 = Chr(8) & "Invoice Date " & Idate & " must be between " & vfdate & " and " & vtdate & " (" & DateDiff("d", Idate, vfdate) & "=" & DateDiff("d", vtdate, Idate) & ")"
        Exit Function
     End If
     Ldate = parms(2)
     If DateDiff("d", Ldate, year_rec(2)) >= 0 Or DateDiff("d", year_rec(3), Ldate) >= 0 Then 'means idate < year_rec(2)
        ta2479 = Chr(8) & "Ledger Date " & Ldate & " must be between " & year_rec(2) & " and " & year_rec(3)
        Exit Function
     End If

     NO_BATCH = parms(3)
     Wantpr = parms(4)
     
     database = pick.extract(logentry, 2, 0, 0)

     sentence = "select * from maint order by inv_code, client" ' BY TYPE BY FULL_NAME"
     total_items = d3.msa_select(mdb_name, sentence, mylist, pick_cnt, 0, 0) - 1
     If total_items < 0 Then
        ta2479 = Chr(8) & "No items found for selection " & sentence
        Exit Function
     End If
'
   For kk = 0 To total_items
     ReDim Mrec(0): Mrec(0) = mylist(kk)
110  rderr = d3.d3_readmat(database, Mrec(), tbl_name)
     If rderr <> 0 Then GoTo 9000
'$INSERT I.LOG.UPDATE '|MAINT|':ID 110 MREC
     Upto_Date = Mrec(7)
      
     If DateDiff("d", Upto_Date, Date1) < 0 Or DateDiff("d", Upto_Date, Mrec(6)) <= 0 Then
     'If Upto_Date > date1 Or Upto_Date >= mrec(6) Then
120     'Release MAINT_DATA, Id
'$INSERT I.QU
        GoTo 9000
     End If
     ICODE = Mrec(2)
'
     Freq = Mrec(8)
     If Freq = "M" Then Freq = "1": GoTo 130
     If Freq = "Q" Then Freq = "3": GoTo 130
     If Freq = "H" Then Freq = "6": GoTo 130
     If Freq = "A" Then Freq = "12": GoTo 130
     If Freq = "F" Then Freq = "14D"
     If Len(Freq) < 1 Then GoTo 120
     If Mid$(Freq, Len(Freq), 1) = "D" Then
        New_Upto = Mid$(Upto_Date + Freq, 1, Len(Freq) - 1)
        GoTo 160
     End If
     'Printer.Print Id; " *** ERROR *** FREQUENCY "; Freq; " IS INVALID_ NO INVOICE GENERATED"
     GoTo 120
130  For the_mth = 1 To UBound(mthends)
        If DateDiff("d", mthends(the_mth), Upto_Date) = 0 Then GoTo 140
     Next the_mth
     'Printer.Print Id; " *** ERROR *** BILLED TO DATE NOT FOUND_ NO INVOICE GENERATED"
     GoTo 120
        
140  If UBound(mthends) < the_mth + CInt(Freq) Then
        New_Upto = DateAdd("m", CDbl(Freq), Upto_Date)
        'Call SR_M(Upto_Date & Chr(253) & Freq, New_Upto)
     Else
        New_Upto = mthends(the_mth + CInt(Freq))
     End If
160:
     If Pro_Rata_Flg Then '???And (match(Freq, "1N0N")) = 0 Then
        If New_Upto > Mrec(6) Then GoTo 120
     End If
     'If mrec(18) = "Y" And New_Upto > date1 Then GoTo 120 'WCC
     If Mrec(18) = "Y" And DateDiff("d", Date1, New_Upto) > 0 Then GoTo 120  'WCC 'means date1 < NEW_UPTO
     If New_Upto > Mrec(6) Then 'WCC
        Mrec(7) = Mrec(6)
     Else  'WCC
        Mrec(7) = New_Upto
     End If 'WCC
     If IsNumeric(Mrec(17)) Then qty = CCur(Mrec(17)) Else qty = 1
'
170  ReDim norec(0): norec(0) = ICODE
     rderr = d3.d3_readmat(database, norec(), mdb_name & "\inv_codes")
'$INSERT I.LOG.UPDATE 'DICT|INVOICE|@':ICODE:'NO' 170 INVNO
     If IsNumeric(norec(2)) Then norec(2) = norec(2) + 1 Else norec(2) = 1
     wterr = d3.d3_writemat(database, mdb_name & "\inv_codes", norec())
     INVNO = ICODE & norec(2)
     ReDim IREC(0): IREC(0) = INVNO
     If d3.d3_readmat(database, IREC(), mdb_name & "\invoice") = 0 Then GoTo 170 'try again
'
     ReDim daterec(3)
     daterec(0) = Mrec(0) & "_" & INVNO
     daterec(1) = Mrec(0)
     daterec(2) = INVNO
     daterec(3) = Idate
     wterr = d3.d3_writemat(database, mdb_name & "\maint_invoices", daterec())
     If wterr <> "0" Then ta2479 = wterr: Exit Function
     
     wterr = d3.d3_writemat(database, tbl_name, Mrec())
     
     sentence2 = "select * from maint_rates where id = '" & Mrec(0) & "' order by date"
     total_items2 = d3.msa_select(mdb_name, sentence2, mylist2, pick_cnt2, 0, 0, 1, 0, Chr(8)) - 1
     For RR = 0 To total_items2 - 1
        ReDim Preserve Dates(RR): Dates(RR) = pick.field(mylist2(RR), Chr(8), 4) 'date
        ReDim Preserve Rates(RR): Rates(RR) = pick.field(mylist2(RR), Chr(8), 5) 'amount
        ReDim Preserve gst_codes(RR): gst_codes(RR) = pick.field(mylist2(RR), Chr(8), 6) 'gst code
        ReDim Preserve Gst_Rates(RR): Gst_Rates(RR) = pick.field(mylist2(RR), Chr(8), 7) 'gst amt
     Next RR
'
     '???Dates = pick.extract(Mrec, 4, 0, 0)
     '???Rates = pick.extract(Mrec, 9, 0, 0)
     '???Gst_Rates = pick.extract(Mrec, 14, 0, 0)
     Gst_Lrate = "": Gst_Lattr = 0: Lrate = "": Lattr = 0:  value = 0: Gst_Value = 0
     ReDim Narr1(0): ReDim Narr2(0): ReDim Narr3(0): ReDim Narr4(0): ReDim Narr5(0)
     If Mid$(Freq, Len(Freq), 1) = "D" Then
        For I = Upto_Date + 1 To New_Upto
           For rpos = 0 To UBound(Dates)
              If DateDiff("d", Dates(rpos), I) <= 0 Then Exit For
           Next rpos
           'LOCATE(I,DATES,1,1,0,RPOS,"AR") ELSE NULL
           If rpos = 1 Then rpos = 2
           rate = Rates(rpos - 1)
           Gst_Rate = Gst_Rates(rpos - 1)
           GST_CODE = gst_codes(rpos - 1)
           If rate = Lrate And Lattr <> 0 And Gst_Rate = Gst_Lrate Then
175           ReDim Preserve Narr1(Lattr): ReDim Preserve Narr2(Lattr): ReDim Preserve Narr3(Lattr): ReDim Preserve Narr4(Lattr): ReDim Preserve Narr5(Lattr)
              If IsNumeric(Narr1(Lattr)) Then Narr1(Lattr) = CInt(Narr1(Lattr)) + 1 Else Narr1(Lattr) = 1
              Narr2(Lattr) = I
              Narr3(Lattr) = Lrate
              Narr4(Lattr) = Gst_Lrate
           Else
              Gst_Lrate = Gst_Rate
              Lrate = rate
              Lattr = Lattr + 1
              GoTo 175
           End If
        Next I
        value = 0: Gst_Value = 0
        For I = 1 To 9999
           Days = Narr1(I)
           If Days = "" Then GoTo 178
           val = Int(Days / Mid$(Freq, 1, Len(Freq) - 1) * Narr3(I) + 0.5) * qty
           St_Lval = Int(Days / Mid$(Freq, 1, Len(Freq) - 1) * Narr3(I) + 0.5)
           St_Lval = St_Lval / 100
           Gval = Int(Days / Mid$(Freq, 1, Len(Freq) - 1) * Narr4(I) + 0.5) * qty
           value = value + val
           Gst_Value = Gst_Value + Gval
        Next I
178
     Else
        At_Base = 0: Pr_Base = 0: At_Top = 0: Pr_Top = 0
        R_Amt_Mult = ""
        If Mrec(16) = "P" Then  'WCC
           Factor = 1 'WCC
        Else 'WCC
           Factor = Freq 'WCC
        End If 'WCC
        For I = the_mth + 1 To the_mth + Factor 'WCC
           If Mrec(16) = "P" Then 'WCC
              eom = New_Upto
           Else 'WCC
              eom = mthends(I)
           End If 'WCC
           For rpos = 0 To UBound(Dates)
              If DateDiff("d", Dates(rpos), eom - 2) <= 0 Then Exit For
           Next rpos
           'LOCATE(EOM-2,DATES,1,1,0,RPOS,"AR") ELSE NULL  'WCC
           If rpos = 1 Then rpos = 2
           rate = Rates(rpos - 1)
           Gst_Rate = Gst_Rates(rpos - 1)
           GST_CODE = gst_codes(rpos - 1)
           If rate = Lrate And Lattr <> 0 And Gst_Rate = Gst_Lrate = 0 Then
              Gst_Lrate = Gst_Rate
              Lrate = rate
              Lattr = Lattr + 1
           End If
           'If Pro_Rata_Flg Then
           '   If At_Top Then GoTo 185
           '   If Eom < Mrec(5) Then GoTo 185
           '   Amt_Mult = 1
           '   If Eom > Mrec(6) Then
           '      At_Top = 1
           '      Amt_Mult = (Mrec(6) - pick.extract(Eoms, 1, I - 1, 0)) / (Eom - pick.extract(Eoms, 1, I - 1, 0))
           '      Pr_Top = 1
           '      If pick.extract(Eoms, 1, I - 1, 0) < Mrec(5) Then Amt_Mult = 0
           '   End If
           '   If At_Base = 0 Then
           '      At_Base = 1
           '      If pick.extract(Eoms, 1, I - 1, 0) < Mrec(5) Then
           '         Amt_Mult = (Eom - Mrec(5) + 1) / (Eom - pick.extract(Eoms, 1, I - 1, 0))
           '         Pr_Base = 1
           '         GoTo 184
           '      End If
           '   End If
           'Else
              Amt_Mult = 1
           'End If
184        val = Int((Amt_Mult * Lrate) + 0.5) * qty: Gval = Int((Amt_Mult * Gst_Lrate) + 0.5) * qty
           St_Lval = Int((Amt_Mult * Lrate) + 0.5)
           St_Lval = St_Lval / 100
           value = value + val: Gst_Value = Gst_Value + Gval
           If R_Amt_Mult <> "" And R_Amt_Mult <> Amt_Mult Then Lattr = Lattr + 1
           R_Amt_Mult = Amt_Mult
           ReDim Preserve Narr1(Lattr): ReDim Preserve Narr2(Lattr): ReDim Preserve Narr3(Lattr): ReDim Preserve Narr4(Lattr): ReDim Preserve Narr5(Lattr)
           Narr1(Lattr) = Narr1(Lattr) + 1
           Narr2(Lattr) = eom
           Narr3(Lattr) = Int((Amt_Mult * Lrate) + 0.5)
           Narr4(Lattr) = Int((Amt_Mult * Gst_Lrate) + 0.5)
           Narr5(Lattr) = ""
           If Amt_Mult <> 1 Then
              If Pr_Base Then
                 Narr5(Lattr) = "PRO-RATA from " & pick.oconv(Mrec(5), "D2") & " to " & pick.oconv(Mrec(6), "D2")
                 Pr_Base = 0
              End If
              If Pr_Top Then
                 Narr5(Lattr) = "PRO-RATA from " & pick.oconv(Mrec(5), "D2") & " to " & pick.oconv(Mrec(6), "D2")
                 Pr_Top = 0
              End If
           End If
185     Next I
     End If
'
     Client_No = pick.field(Mrec(0), "*", 1)
     glacct = Mrec(11)
     Mnarr = Mrec(10)

     IREC(1) = 1
     IREC(3) = Client_No
     IREC(6) = Mrec(13)
     IREC(7) = Date
     IREC(8) = CStr(value + Gst_Value)
     For I = 1 To Lattr
        N1 = Narr1(I)
        Gst_Lamt = Gst_Value: Lamt = value: N2 = value
        If N1 = pick.field(Freq, "D", 1) Then
           If Mid$(Freq, Len(Freq), 1) = "D" Then N1 = N1 & " DAYS TO": GoTo 190
           If N1 = 1 Then N1 = "MONTH TO": GoTo 190
           If N1 = 3 Then N1 = "QUARTER TO": GoTo 190
           If N1 = 6 Then N1 = "HALF-YEAR TO": GoTo 190
           If N1 = 12 Then N1 = "YEAR TO": GoTo 190
190        N2 = " $" & pick.oconv(N2, "MD2")
        Else
           If Mid$(Freq, Len(Freq), 1) = "D" Then
               Gst_Lamt = Int(N1 / CInt(Mid$(Freq, 1, Len(Freq) - 1)) * Narr4(I) + 0.5)
               Lamt = Int(N1 / Mid$(Freq, 1, Len(Freq) - 1) * Narr3(I) + 0.5)
               Mww = " PER " & Freq & "AYS"
               Mw = "DAY"
           Else
              Lamt = N1 * Narr3(I)
              Gst_Lamt = N1 * Narr4(I) 'WCC
              If Mrec(16) = "P" Then 'WCC
                 Select Case Freq 'WCC
                    Case 3   'WCC
                       N1 = "QUARTER"  'WCC
                    Case 6  'WCC
                       N1 = "HALF YEAR"  'WCC
                    Case 12  'WCC
                       N1 = "YEAR"  'WCC
                    Case Else  'WCC
                       N1 = "UNSPECIFIED PERIOD"  'WCC
                 End Select  'WCC
                 Mww = ""  'WCC
              Else  'WCC
                 Mww = " PER MONTH" 'WCC
                 Mw = "MONTH" 'WCC
                 If N1 > 1 Then 'WCC
                    N1 = N1 & " " & Mw 'WCC
                 Else  'WCC
                    N1 = N1 & " " & Mw 'WCC
                 End If 'WCC
              End If 'WCC
           End If 'WCC
           N1 = N1 & " TO"
           N2 = Narr3(I)
           N2 = " $" & pick.oconv(N2, "MD2") & Mww
        End If
        If Narr5(I) = "" Then
           desc = N1 & " " & pick.oconv(Narr2(I), "D2") & " @ " & N2
        Else
           desc = Narr5(I)
        End If
        If Gst_Lamt = 0 And Lamt = 0 Then GoTo 196

        ReDim wrec(6)
        wrec(1) = IREC(0)
        wrec(2) = I
        wrec(4) = glacct
        wrec(5) = Lamt / qty
        wrec(6) = Mnarr & desc
        wrec(7) = qty
        wrec(9) = Lamt
        wrec(10) = GST_CODE
        wrec(11) = Gst_Lamt
        
        'Irec = pick.Replace(Irec, 65, Ct, 0, St_Lval)
        wrec(0) = id & "_" & I
        wterr = d3.d3_writemat(database, mdb_name & "\invoice_lines", wrec())

196  Next I
     IREC(20) = Idate
     IREC(21) = Ldate
     IREC(30) = NO_BATCH
'
     wterr = d3.d3_writemat(database, mdb_name & "\INVOICE", IREC())
     
     If Wantpr = "Y" And Mrec(15) <> "Y" Then
        ReDim Prec(0): Prec(0) = IREC(0)
        wterr = d3.d3_writemat(database, mdb_name & "\PR_INV", Prec())
     End If
9000:
   Next kk

End Function
Public Function TA2480(logentry As String, template_path As String, mdb_name As String, pass_parms As String, Iscr As String) As String

' stock not catered for sr2400.qty
' hp not catered for

Dim Unique As Integer
Dim I As Integer, Cc, Invnum, Invs, aa
Dim Btch_Tot, save, Bb, tr_type, Tr_Type_Rev
Dim Tj_Key As String
Dim Inv_Amts
Dim ptl(), Cphead, Sum1, Sum2, Sum3
Dim Sum4, Tjac As String, Tjcd  As String, Amt, Tjob, J, Txcd() As String, Inv_Tax_Amt() As Currency, tt As Integer
Dim Tjdata(7) As String, desc, Narr, Client_No As String
Dim Gl_Acct, Cr_Rec As String, Amount As Currency, Client_Rec() As String, Attr As Integer
Dim Tdnarr As String, tr_prod As String
Dim Lbno, alt_bno, Sales_Acct, Tr_Tax As String, tr_qty
Dim Tr_Sqty As Currency, tr_cqty As Currency, Tr_Price, Tr_Line_Amt As Currency
Dim Tr_Line_Tax, Tjjob As String, Tjnarr As String, Tjcost As Currency
Dim Instr, tr_conv As String, tr_cost As Currency, Stat_Cost As Currency, Stock_Rec As String
Dim NO_STOCK_STATS, Read_Stock, Tstd_Cost As Currency, Sc_Cost As Currency, Tr_Code As String
Dim Useqty As Long, Usewgt, Uqty, pp, Prod_Grp, Convert As Long, Crvalue As Currency
Dim Utxrate, Utx, Sva_Amt As Currency, Rep_Id As String, Area_Id As String, td_id As String, qty
Dim Td_Id2 As String, tr_wgt As Currency
Dim Dr_Control, Group, No_Cos, Cono, Ii As Integer, Tax_Acct, Tjcdd
Dim Tjpp As Integer, Tjp As Integer
Dim tdrec() As String, temp As String, Total_Cost As Currency, pline As String, err_flag As String

Dim fname As String, fname_mdb As String, lines_mdb As String, lines_batch_mdb As String
Dim batch_lines_file As String, fname_batch As String, tname_batch As String, Batchnum As String
Dim sentence As String, mylist() As String, pick_cnt As Long, total_items As Long
Dim sentence2 As String, mylist2() As String, pick_cnt2 As Long, total_items2 As Long
Dim INV() As String, mdb_inv() As String, jrec() As String, parms() As String, database As String, kk As Integer
Dim rderr As Integer, CASH_DATE As Integer, debt_cont As String, RR As Integer
Dim tr_desc As String, tax_account As String, invoice_rec As String, Tj_Rec As String
Dim wterr As String, tempobj As Object, ids As String, hp As String
Dim Price As Currency, Cost As Currency
Dim TRANS_INFO As String, eom As String, Ldate As Integer, mttr As Integer, Jj As Integer
Dim SUMM() As String, Jobcost As Integer, Ptline As String, want_bno As String
Dim CONTRA_ACCT As String, Sva_Acct As String, Cs_Acct, Sc_Acct, Cl_Acct, No_Ledg As String, STORENO, Scs_Acct, Sales_Acct2
Dim qu As Integer, line_item() As String, Nosva As Integer
' TA2480A PROCESS INVOICES & CREDITS
' CHAINED TO BY TA2480 - PROCESS INVOICES
'               TA2481 - PROCESS STORE INVOICES
'               TA2482 - PROCESS CREDITS
'
     If Iscr = "C" Then
         tname_batch = "CR_BATCH": fname = "CREDIT"
     Else
         tname_batch = "INV_BATCH": fname = "INVOICE"
     End If
     batch_lines_file = tname_batch & "_lines"
     fname_batch = mdb_name & "\" & tname_batch
     fname_mdb = mdb_name & "\" & fname
     lines_mdb = fname_mdb & "_lines"
     lines_batch_mdb = fname_batch & "_lines"
     
     parms = Split(pass_parms, Chr(8))
     If UBound(parms) < 0 Then
        TA2480 = Chr(8) & "No items found for selection " & sentence
        Exit Function
     End If
     Batchnum = parms(0)
     database = pick.extract(logentry, 2, 0, 0)
'
     Unique = 0
     Jobcost = 0
'     Hash = Mid$((Pick.extract(Trans_Info, 10, 0, 0)), 9, 1) + 0
'     If d3.d3_readstr(database, Gst_Accs, "GST.CONTROL", "GST_ACCS") <> 0 Then
'        TA2480 = Chr(8) & "GST_ACCS Item Missing From GST_CONTROL"
'        Exit Function
'     End If
'     Glbatch = Mid$((Pick.extract(Trans_Info, 57, 0, 0)), 18, 1) + 0
'     Batchcont = Mid$((Pick.extract(Trans_Info, 57, 0, 0)), 19, 1) + 0
'     Spec_Sales = Mid$((Pick.extract(Trans_Info, 57, 0, 0)), 33, 1) + 0
'     Costbywgt = Mid$((Pick.extract(Trans_Info, 57, 0, 0)), 35, 1) + 0
'     Brewery = Pick.extract(Trans_Info, 47, 30, 0)
'     Export = Pick.extract(Trans_Info, 111, 0, 0) + 0
'
'     If SELECT_STR Then
'        If ISCR Then
'           EXECUTE "SSELECT CR_BATCH WITH 2 = "STR""
'        Else
'           EXECUTE "SSELECT INV_BATCH WITH 2 = "STR""
'        End If
'        I = 1: Cc = 0
'15      READNEXT ID ELSE GOTO 16
'        If I > 15 Then Cc = Cc + 10: I = 1
'        If Cc = 80 Then
'           LNS$=23: CLS$=CL: CALL SRIP(0,LNS$,"Press RETURN for next page ",AA,CLS$,"","","",""): PRINT @(0,5) & CS &
'        End If
'        PRINT @(CC,I+4) & ID
'        I = I + 1
'        GoTo 15
'16      Cls$ = "": Lns$ = 21: Call SRIP(0, Lns$, "WHICH INVOICE NUMBERS (separate by space) ", Invnum, Cls$, "", "", "", "")
'
'        Invnum = trimm(Invnum)
'        IF INVNUM="" OR INVNUM="ENDIF" THEN Printer.Print  ERASE: RETURN
'        Invs = ""
'        FOR AA = 1 TO 9999 UNTIL pick.field(INVNUM," ",AA) = ""
'           INVS=INVS & " "" & pick.field(INVNUM," ",AA) & """
'        Next Aa
'        GoTo 6
'     End If
'2    If Batchcont = 0 Then Autonxt = 0: GoTo 6
'
'     If Hash Then
'        If Hash = 2 Then
'           Hash_Tot = Pick.extract(Batches, 8, Ans, 0)
'           Hash_Stot = Pick.extract(Batches, 9, Ans, 0)
'           If Hash_Tot <> Hash_Stot Then Emsg = "Hash Total does not balance for batch " & Batchnum: GoTo 9
'        Else
'           Batch_Total = Pick.extract(Batches, 4, Ans, 0)
'           Hash_Tot = Pick.extract(Batches, 8, Ans, 0)
'           Btch_Tot = Pick.oconv(Batch_Total, "MD2")
'           If Hash_Tot <> Btch_Tot Then Emsg = "Batch Total does not balance for batch " & Batchnum: GoTo 9
'        End If
'     End If
'
'6    If iscr Then
'        If SELECT_STR Then
'           Execute "SSELECT CR_BATCH WITH 0 =" & Invs
'           GoTo 11
'        Else
'        If Batchcont Then
'           'sentence = "SSELECT CR_BATCH WITH @7 <> ""Q"" AND WITH @7 <> ""O"" AND WITH @30 = "" & BATCHNUM & "" "
'           GoTo 11
'        Else
'           'EXECUTE "SSELECT CR_BATCH WITH @7 <> "Q" AND WITH @7 <> "O" "
'           GoTo 11
'        End If
'        End If
'     Else
'        If SELECT_STR Then
'           'Execute "SSELECT INV_BATCH WITH 0 =" & Invs
'           GoTo 11
'        Else
'        If Batchcont Then
'           'EXECUTE "SSELECT INV_BATCH WITH @7 <> "Q" AND WITH @7 <> "O" AND WITH @30 = "" & BATCHNUM & "" "
'           GoTo 11
'        Else
'           'EXECUTE "SSELECT INV_BATCH WITH @7 <> "Q" AND WITH @7 <> "O" "
'           GoTo 11
'        End If
'        End If
'     End If
'
10
11    If Iscr = "C" Then
         tr_type = 53
         Tr_Type_Rev = 28
      Else
         tr_type = 25
         Tr_Type_Rev = 50
      End If
'
      ReDim SUMM(2)
'
      If d3.d3_readstr(database, TRANS_INFO, "DICT TRANS.J", "TRANS.INFO") <> 0 Then Exit Function
'      Ret_Acct = Pick.extract(Trans_Info, 81, 0, 0)
      'If Glbatch Then Tjkey = Time() & tj_tno & ICONV(Format$(Now, "DD MMM YY"), "D2") & "2388"
'      Ask_Cost = Pick.extract(Trans_Info, 36, 0, 0) + 0
'      Pricing = Pick.extract(Trans_Info, 42, 0, 0)
      Nosva = 1 'Nosva = Mid$((Pick.extract(Trans_Info, 57, 0, 0)), 8, 1) + 0
'      Area_Flg = Pick.extract(Trans_Info, 44, 1, 0) + 0
'      Area = Pick.extract(Trans_Info, 44, 2, 0) + 0
'      Area_Rep = Pick.extract(Trans_Info, 44, 3, 0) + 0 ' CAN BE 0,1 OR 2
'      Rep_Flg = Pick.extract(Trans_Info, 52, 0, 0) + 0
'      Custord = Mid$((Pick.extract(Trans_Info, 57, 0, 0)), 12, 1) + 0
      Inv_Amts = ""
'      No_Stats = Pick.extract(Trans_Info, 47, 3, 0) + 0
      eom = pick.extract(TRANS_INFO, 8, 0, 0) & Chr(253) & pick.extract(TRANS_INFO, 7, 0, 0) & Chr(253) & pick.extract(TRANS_INFO, 33, 0, 0)
      eom = pick.delet(eom, 1, 1, 0)         '* REMOVE LAST MONTH OF PREVIOUS YEAR **
'
     database = pick.extract(logentry, 2, 0, 0)

     sentence = "select " & fname & " from " & tname_batch & " where batch = '" & Batchnum & "' order by " & fname
     total_items = d3.msa_select(mdb_name, sentence, mylist, pick_cnt, 0, 0)

     If total_items <= 0 Or pick_cnt = -1 Then
        Tj_Key = Chr(8) & "No items found for selection " & sentence
        If pick_cnt = -1 Then Tj_Key = Tj_Key & ". " & mylist(0)
        TA2480 = Tj_Key
        Exit Function
     End If
     
     ReDim ptl(0)
     If total_items = 1 Then ptl(0) = " was" Else ptl(0) = "s were"
     ptl(0) = "<TR><TD colspan=6>" & total_items & " " & fname & ptl(0) & " found in batch " & Batchnum

     total_items = total_items - 1

   For kk = 0 To total_items
      ReDim INV(0): INV(0) = mylist(kk)
      rderr = d3.d3_readmat(database, INV(), fname_batch)
      If rderr <> 0 Then GoTo 9000

      If d3.d3_readstr(database, invoice_rec, fname, INV(0)) = 0 Then
         ReDim Preserve ptl(UBound(ptl) + 1)
         ptl(UBound(ptl)) = "<TR><TD colspan=6>" & INV(0) & " already exists on file " & fname & ". Not processed"
         GoTo 9000
      End If
      
      If UBound(INV) < 68 Then ReDim Preserve INV(68)
      mdb_inv = INV
'      If ISCR <> "C" Then
'         Log_Id = "|INV_BATCH|" & inv(0)
'      Else
'         Log_Id = "|CR_BATCH|" & inv(0)
'      End If
'$INSERT I.LOG.DELETE LOG.ID 300 INV
      'rderr = d3.d3_delete("", fname_batch, Inv(0))
      'Call SR2400_QTY("", inv(1), inv(10), inv(13), "", "", "", 1)
'
      'If inv(38) <> "" Then
      '   Call SR2480_HP(Inv)
      'End If
'
      ReDim Txcd(0): ReDim Inv_Tax_Amt(0)
      
      'Tj_key = inv(7)
      'If Glbatch Then Tj_Key = Tjkey Else Tj_Key = inv(7)
      'If Pick.extract(Tj_Key, 1, 2, 0) = "NOTDONE" Or Tj_Key = "" Then Tj_Key = Time() & tj_tno
      rderr = pick.date_vb_to_pick(INV(21), Ldate, 0)
      If pick.locate(CStr(Ldate), eom, 1, 1, 0, mttr, "AR") = 0 Then
      End If
      If mttr > 24 Then
         ReDim Preserve ptl(UBound(ptl) + 1)
         ptl(UBound(ptl)) = "<TR><TD colspan=6>" & INV(0) & " is ledger dated " & INV(21) & ". Not processed"
         GoTo 9000      '   Ptl = fname & " " & inv(0) & " is ledger dated " & Pick.oconv(Ldate, "D2") & ". " & fname & " NOT PROCESSED_ "
      End If

      Client_No = INV(3)
      'Storeno = 0
      Gl_Acct = 0
      If pick.Index(Client_No, ".", 2) <> 0 Then Gl_Acct = 1
'      If inv(2) = "STR" Then Storeno = inv(3): GoTo 310   ' STORE INVOICE
      INV(27) = "": INV(28) = ""
      Amount = (CCur(INV(8)) + CCur(INV(6))) * 100 'amount + gst
      rderr = pick.date_vb_to_pick(INV(20), CASH_DATE, 0)
            
     sentence2 = "select * from " & batch_lines_file & " where id = '" & INV(0) & "' order by cnt"
     total_items2 = d3.msa_select(mdb_name, sentence2, mylist2, pick_cnt2, 0, 0, 1, 0, Chr(8)) - 1

     For RR = 0 To total_items2
        line_item = Split(mylist2(RR), Chr(8))
        If UBound(line_item) < 16 Then ReDim Preserve line_item(16)
        
        tr_prod = line_item(4) 'invoice=10
        If tr_prod = "" Then GoTo 256
        Tr_Line_Amt = line_item(5) 'invoice=
        tr_desc = line_item(6) 'invoice=12
        tr_qty = line_item(7) 'invoice=13
        Stat_Cost = 0 'pick.fieldcur(mylist2(RR), Chr(8), 9) 'invoice=14
        Tr_Price = line_item(9) 'invoice=15
        Tr_Tax = line_item(10) 'invoice=16
        Tr_Line_Tax = line_item(11) 'invoice=17
        tax_account = line_item(12) 'invoice=
        line_item(14) = Tr_Line_Amt + Tr_Line_Tax
        
        INV(10) = pick.Replace(INV(10), 1, RR + 1, 0, tr_prod)
        INV(12) = pick.Replace(INV(12), 1, RR + 1, 0, tr_desc)
        INV(13) = pick.Replace(INV(13), 1, RR + 1, 0, CStr(tr_qty))
        'inv(14) = pick.replace(inv(14), 1, RR + 1, 0, CStr(Stat_Cost * 100))
        INV(15) = pick.Replace(INV(15), 1, RR + 1, 0, CStr(Tr_Price * 100))
        INV(16) = pick.Replace(INV(16), 1, RR + 1, 0, Tr_Tax)
        INV(17) = pick.Replace(INV(17), 1, RR + 1, 0, CStr(Tr_Line_Tax * 100))
        
        desc = " - " & tr_desc
        If Iscr <> "C" Then Narr = "INV " & INV(0) & desc Else Narr = "C/N " & INV(0) & desc
        
         want_bno = INV(1)
312      qu = 1
         'No_Ledg = Mid$(Tr_Prod, 1, 1) '*USING NO_LEDG AS TEMP VAR**
         'If No_Ledg = "?" Then Qu = 0: Tr_Prod = Mid$(Tr_Prod, 2, 99)
         If pick.Index(tr_prod, ".", 2) = 0 Then
            Call SR2501(database, tr_prod, INV(1), want_bno, INV(0), CONTRA_ACCT, Client_No, Ptline, Sva_Acct, Cs_Acct, Sc_Acct, Cl_Acct, No_Ledg, Sales_Acct, "", STORENO, Scs_Acct, Sales_Acct2)   '*DONOTALTER**
            If Ptline <> "" Then
               ReDim Preserve ptl(UBound(ptl) + 1)
               ptl(UBound(ptl)) = "<TR><TD colspan=6>" & Ptline
            End If
         '   If Spec_Sales And ISCR <> "C" And Not (Gl_Acct) Then Sales_Acct = SALES_ACCT2
         Else
            No_Ledg = "1"
            Sales_Acct = tr_prod
         End If
         tr_wgt = pick.extractcur(INV(48), 1, I, 0)
'         If Costbywgt Or Export Then
'           If Tr_Wgt <> "" Then Tr_Sqty = Tr_Wgt Else Tr_Sqty = Tr_Qty
'           Tr_Cqty = Tr_Sqty
'         Else
           Tr_Sqty = CCur(tr_qty)
           tr_cqty = CCur(tr_qty)
'         End If
         'Sernos = Pick.extract(inv(34), 1, I, 0)
         'Tr_Pr_Disp = Pick.oconv(Tr_Price * 100, "MD4")
         'If Tr_Sqty = "" Then
         '   Tr_Line_Amt = ICONV(Tr_Pr_Disp, "MD22")
         'Else
         '   Tr_Line_Amt = ICONV(Tr_Sqty * Tr_Pr_Disp, "MD22")
         'End If
'         If Brewery Then
'            Tr_Excise = Pick.extract(Inv, 40, I, 0)
'            Tr_Surcharge = Pick.extract(Inv, 41, I, 0)
'         End If
'
'SALES ACCTS
         If Mid$(Sales_Acct, 1, 3) = "JOB" Then Jobcost = 1: Tjac = Mid$(Sales_Acct, 4): Tjjob = 1 Else Tjac = Sales_Acct: Tjjob = 0
         Tjnarr = Narr
         If Tr_Line_Amt < 0 Then Tjcd = Tr_Type_Rev: Tjcost = -Tr_Line_Amt Else Tjcd = tr_type: Tjcost = Tr_Line_Amt
         If Tjac = "" Then Tjac = "SALES ACCT MISSING"
         GoSub 777
         If Mid$(Sales_Acct, 1, 3) = "JOB" Then
            ReDim jrec(0): jrec(0) = Tjac
            rderr = d3.d3_readmat(database, jrec(), "job.l")
            If UBound(jrec) < 18 Then Tjac = "" Else Tjac = jrec(18)
            Tjac = pick.extract(Tjac, 1, 1, 1): Tjjob = 0
            If Tjac = "" Then Tjac = "GL ACCT FOR JOB " & Tjac & " MISSING"
            GoSub 777
         End If
         'If Storeno Then                   ' STORE INVOICE
         '   If Tr_Line_Amt < 0 Then Tjcd = Tr_Type: Tjcost = -(Tr_Line_Amt + Tr_Line_Tax) Else Tjcd = Tr_Type_Rev: Tjcost = Tr_Line_Amt + Tr_Line_Tax
         '   Tjac = SCS_ACCT
         '   If Tjac = "" Then Tjac = "STORE_COS_ACCT MISSING"
         '   GoSub 777
         'End If
         If Tr_Line_Tax <> 0 Then
            If tax_account = "" Then tax_account = "TAX ACCOUNT MISSING"
            For tt = 0 To UBound(Txcd)
               If tax_account = Txcd(tt) Then GoTo found_tax
            Next tt
            tt = UBound(Txcd) + 1
            ReDim Preserve Txcd(tt)
            Txcd(tt) = tax_account
found_tax:
            If UBound(Inv_Tax_Amt) < tt Then ReDim Preserve Inv_Tax_Amt(tt)
            Inv_Tax_Amt(tt) = Inv_Tax_Amt(tt) + Tr_Line_Tax
         End If
'
'         If Brewery Then
'            If Tr_Excise + 0 <> 0 Then
'               LOCATE("EXCISE",TXCD,1,1,0,K,"") ELSE
'                 Txcd = Pick.insert(Txcd, 1, k, 0, "EXCISE")
'               End If
'               Inv_Tax_Amt = Pick.replace(Inv_Tax_Amt, 1, k, 0, Pick.extract(Inv_Tax_Amt, 1, k, 0) + Tr_Excise)
'            End If
'            If Tr_Surcharge + 0 <> 0 Then
'               LOCATE("SURCHARGE",TXCD,1,1,0,K,"") ELSE
'                 Txcd = Pick.insert(Txcd, 1, k, 0, "SURCHARGE")
'               End If
'               Inv_Tax_Amt = Pick.replace(Inv_Tax_Amt, 1, k, 0, Pick.extract(Inv_Tax_Amt, 1, k, 0) + Tr_Surcharge)
'            End If
'         End If
'
         If qu And InStr(tr_prod, ".") = 0 Then
            If No_Ledg = "" Or No_Ledg = "0" Then
               Call SR2710(database, tr_prod, INV(1), CASH_DATE, temp, "", "")
               If d3.d3_readstr(database, tr_conv, "STOCK", tr_prod, 12) <> 0 Then tr_conv = "1"
               If Not IsNumeric(tr_conv) Or tr_conv = "0" Then tr_conv = "1"
               tr_cost = temp / CCur(tr_conv)
         '   Else
         '      Stat_Cost = Pick.extract(inv(14), 1, I, 0)
         '      If Stat_Cost = "" And (No_Ledg = 4 Or ((No_Ledg = 1 Or No_Ledg = 3) And Ask_Cost = 0)) Then
         '         If No_Ledg = 4 Then
         '            If d3.d3_readstr(database, Stock_Rec, "STOCK", Tr_Prod) <> 0 Then Stock_Rec = ""
         '            Call SR2701(Pricing, Stock_Rec, Torr, PERPRICE, inv(20))  '*DONOTALTER**
         '            Stat_Cost = Pick.oconv(ICONV(Tr_Price * PERPRICE / 100, "MD00"), "MD0")
         '         Else
         '            Call SR2710(STOCK_DATA, STOCK_BRANCH_DATA, BRANCH_DATA, Tr_Prod, inv(1), inv(20), Stat_Cost, "", "")
         '            READV TR_CONV FROM STOCK_DATA,TR_PROD,12 ELSE TR_CONV=1
         '            If Tr_Conv + 0 = 0 Then Tr_Conv = 1
         '            Stat_Cost = Stat_Cost / Tr_Conv
         '         End If
         '         inv = Pick.replace(inv(14), 1, I, 0, Stat_Cost)
         '      End If
            End If
         Else
         '   If Stat_Cost = "" Then
         '      Stat_Cost = 0
         '      inv = Pick.replace(inv(14), 1, I, 0, Stat_Cost)
         '   End If
         End If
'
         If No_Ledg = "1" Then GoTo 255
'         If qu = 0 Then GoTo 255         '* QTY 0. NO POSTINGS TO DO **
'         No_Stock_Stats = 0
         Read_Stock = 0
'         If No_Ledg >= 2 Then
'            If Tr_Cqty = "" Then
'               Tstd_Cost = ICONV(Stat_Cost / 100, "MD22")
'            Else
'               Tstd_Cost = ICONV(Tr_Cqty * Stat_Cost / 100, "MD22")
'            End If
'            Sc_Cost = Tstd_Cost
'            GoTo 248
'         End If
'         If Tr_Qty <> "" Then
'            If Tr_Pr_Disp < 0 Then
'               Ptl = fname & " " & inv(0) & " LINE WITH QTY AND NEGATIVE VALUE_ " & fname & " NOT PROCESSED"
'               GoSub 5000
'$INSERT I.QU.REC
'               GoSub 8500: GoTo 200
'            End If
'         End If
         Read_Stock = 1
         If tr_qty < 0 Then
            Tr_Code = Tr_Type_Rev
         Else
            Tr_Code = tr_type
         End If
         If Iscr = "C" Then Useqty = -tr_qty: Usewgt = -tr_wgt: GoTo 530 Else Useqty = tr_qty: Usewgt = tr_wgt
530      If INV(32) = "1" Then 'credit note from customer return of stock
'            Tstd_Cost = ICONV(Stat_Cost * Tr_Cqty, "MD00"): Sc_Cost = Tstd_Cost
'            If d3.d3_readstr(database, Prod_Grp, "STOCK", Tr_Prod) <> 0 Then Prod_Grp = ""
'            Convert = Pick.extract(Prod_Grp, 7, 0, 0)
'            Prod_Grp = Pick.extract(Prod_Grp, 2, 0, 0)
            If No_Ledg = "0" Then GoTo 254 Else GoTo 248
         End If
         Tstd_Cost = Int(Useqty * tr_cost)  'pick.ICONV(pick.extractcur(Useqty, 1, 1, 0) * tr_cost, "MD00")
         If Iscr = "C" And pick.extract(INV(14), 1, I, 0) <> "" Then
            Crvalue = Int(pick.extractcur(INV(14), 1, I, 0) * -1 * tr_cqty)
         Else
            Crvalue = 0
         End If
         Call SR2500(database, eom, TRANS_INFO, "", want_bno, tr_prod, "", Tr_Code, INV(0), pick.ICONV(Format$(Now, "DD MMM YY"), "D2"), Useqty, "", Crvalue, "", Usewgt, "", tr_cost, Total_Cost, Tr_Line_Amt, INV(21), "", "", 0, "", "", Prod_Grp, Convert, "", "", "", "", pline, err_flag)
'         If Pline <> "" Then
'            Ptl = inv(0) & " HAS NOT BEEN PROCESSED."
'            For Pp = 1 To 99
'               Ptl = Left(Ptl & Space(40), 40) & Pick.extract(Pline, 1, Pp, 0)
'               If Pick.extract(Pline, 1, Pp, 0) = "" Then GoTo 580
'               GoSub 5000
'            Next Pp
'         End If
'580      If ERR_FLAG Then
'$INSERT I.QU.REC
'            GoSub 8500: GoTo 200
'         End If
'         If Tr_Cqty + 0 = 0 Then
'            Stat_Cost = 0
'            inv = Pick.replace(inv(14), 1, I, 0, Stat_Cost)
'         Else
'            Stat_Cost = Total_Cost / Tr_Cqty
'            If ISCR = "C" Then Stat_Cost = -Stat_Cost
'            inv = Pick.replace(inv(14), 1, I, 0, Stat_Cost)
'         End If
590      If Iscr = "C" Then
            Sc_Cost = -Total_Cost
            Sva_Amt = Tstd_Cost - Total_Cost
            Tstd_Cost = -Tstd_Cost
         Else
            Sc_Cost = Total_Cost
            Sva_Amt = Total_Cost - Tstd_Cost
         End If
         If Nosva Then
            Tstd_Cost = Tstd_Cost + Sva_Amt
            Sva_Amt = 0
         End If
''
         If No_Ledg = "0" Then GoTo 254
'SVA
'         If Sva_Amt <> 0 Then
'            Tjac = SVA_ACCT: Tjnarr = Narr: Tjjob = 0
'            If Sva_Amt < 0 Then Tjcd = Tr_Type: Tjcost = -Sva_Amt Else Tjcd = Tr_Type_Rev: Tjcost = Sva_Amt
'            If Tjac = "" Then Tjac = "VARIANCE_ACCT MISSING"
'            GoSub 777
'         End If
'         inv = Pick.replace(inv(28), 1, I, 0, Sva_Amt)
'COST OF SALES
248   If Tstd_Cost <> 0 Then
            Tjac = Cs_Acct: Tjnarr = Narr: Tjjob = 0
            If Tstd_Cost < 0 Then Tjcd = tr_type: Tjcost = -Tstd_Cost Else Tjcd = Tr_Type_Rev: Tjcost = Tstd_Cost
            Tjcost = Tjcost / 100
            If Tjac = "" Then Tjac = "COST_OF_SALES ACCT MISSING"
            GoSub 777
         End If
         INV(27) = pick.Replace(INV(27), 1, RR + 1, 0, CStr(Tstd_Cost))
         line_item(15) = Tstd_Cost / 100
'STOCK CONTROL
         If Sc_Cost <> 0 Then
            'If Inv(32) And No_Ledg = 0 Then
            '   Tjac = Ret_Acct
            'Else
               'If No_Ledg >= 3 Then
               '   Tjac = CONTRA_ACCT
               'Else
                  Tjac = Sc_Acct
               'End If
            'End If
            Tjnarr = Narr: Tjjob = 0
            If Sc_Cost < 0 Then Tjcd = Tr_Type_Rev: Tjcost = -Sc_Cost Else Tjcd = tr_type: Tjcost = Sc_Cost
            Tjcost = Tjcost / 100
            If Tjac = "" Then Tjac = "STOCK_CONTROL ACCT MISSING"
            GoSub 777
         End If
254      If Read_Stock Then GoTo 2555
'
255      If d3.d3_readstr(database, Stock_Rec, "STOCK", tr_prod) <> 0 Then
            NO_STOCK_STATS = 1
            Prod_Grp = tr_prod & "*S"
            Convert = 1
            GoTo 2555
         End If
         NO_STOCK_STATS = 0
         Prod_Grp = pick.extract(Stock_Rec, 2, 0, 0)
         Convert = pick.extract(Stock_Rec, 7, 0, 0)
         If Convert = "" Then Convert = 1
2555     If INV(22) = "1" Or INV(22) = "3" Then GoTo 256
         Rep_Id = INV(35)
         'If Area_Flg Then
         '   Area_Id = ""
         'Else
         '   If Area_Rep Then
         '      Area_Id = Inv(33) & "*" & Rep_Id
         '      If Area_Rep = 2 Then
         '         Area_Id = Pick.extract(Inv, 1, 0, 0) & "*" & Pick.extract(Inv, 33, 0, 0) & "*" & Tr_Prod
         '         Rep_Id = Pick.extract(Inv, 1, 0, 0) & "*" & Pick.extract(Inv, 35, 0, 0)
         '      End If
         '      If Area_Rep = 3 Then
         '         Area_Id = Pick.extract(Inv, 3, 0, 0) & "*" & Pick.extract(Inv, 33, 0, 0) & "*" & Prod_Grp
         '      End If
         '      If Area_Rep = 4 Then
         '         Area_Id = Pick.extract(Inv, 1, 0, 0) & "*" & Pick.extract(Inv, 33, 0, 0) & "*" & Tr_Prod
         '         Rep_Id = Pick.extract(Inv, 1, 0, 0) & "*" & Pick.extract(Inv, 35, 0, 0) & "*" & Prod_Grp
         '      End If
         '   Else
         '      Area_Id = Pick.extract(Inv, 33, 0, 0) & "*" & Prod_Grp
         '   End If
         'End If
         td_id = INV(3) & "*" & Prod_Grp
'
         'If Tr_Sqty = "" Then
         '   QTY = pick.extract(inv(18), 1, I, 0)
         '   PRICE = ICONV(Tr_Price / 100, "MD22")
         '   COST = ICONV(Stat_Cost / 100, "MD22")
         'Else
            qty = Tr_Sqty
            Price = Round(Tr_Sqty * Tr_Price * 100)
            Cost = Round(tr_cqty * Stat_Cost * 100)
         'End If
         'If Len(Pick.field(Convert, ".", 2)) < 5 Then
            qty = qty * Convert
         'Else
         '   Ans2 = InStr(Convert, ".")
         '   Ans = Mid$(Convert, Ans2 + 1, 99)
         '   Convert = Mid$(Convert, 1, Ans2 - 1) & Ans
         '   Qty = Qty * Convert
         '   Ans2 = Len(Qty): Ans3 = Len(Ans)
         '   Ans2 = Ans2 - Ans3 + 5
         '   If Mid$(Qty, Ans2, 1) < 5 Then
         '      QTY = QTY / (1 & String$(LEN(ANS,"0"))
         '   Else
         '      QTY = QTY / (1 & String$(LEN(ANS,"0"))
         '      Qty = Qty + 0.0001
         '   End If
         'End If
         'If Qu = 0 Then Qty = 0
         Td_Id2 = Client_No: If InStr(Td_Id2, ".") Then Td_Id2 = INV(25)
         If pick.Index(Client_No, ".", 2) = 0 Then
            Call SR2488(database, Area_Id, td_id, Td_Id2, Rep_Id, NO_STOCK_STATS, Iscr, qty, Price, Cost, mttr)
         End If
256   wterr = d3.d3_writemat(database, lines_mdb, line_item())
      Next RR
'
' write invoice to mdb and to LOGIS
'
      mdb_inv(7) = Date
      mdb_inv(68) = Time()
      wterr = d3.d3_writemat(database, fname_mdb, mdb_inv()) 'mdb invoice or credit
      
      INV(8) = CStr(Amount)
      INV(6) = ""
      rderr = pick.date_vb_to_pick(Date, INV(7), 0)
      INV(9) = total_items2 + 1
      temp = INV(20): rderr = pick.date_vb_to_pick(temp, INV(20), 0)
      temp = INV(21): rderr = pick.date_vb_to_pick(temp, INV(21), 0)
      INV(34) = ""
      temp = INV(36): rderr = pick.date_vb_to_pick(temp, INV(36), 0)
      'inv(68) = Time()
      
      'If inv(22) <> 1 And inv(22) <> 3 Then inv(22) = inv(22) + 1    '* STATS ARE DONE **)
      wterr = d3.d3_writemat(database, fname, INV()) 'invoice or credit
' delete batch invoice
      rderr = d3.d3_delete("", fname_batch, INV(0))
      For RR = 0 To total_items2
         line_item = Split(mylist2(RR), Chr(8))
         wterr = d3.d3_delete(database, lines_batch_mdb, line_item(0))
      Next RR
'
      Tdnarr = Replace(INV(12), Chr(253), Chr(252))
      
     If d3.d3_readstr(database, Cr_Rec, "TDEBTOR", Client_No) <> 0 Then Cr_Rec = ""
'$INSERT I.LOG.UPDATE '|TDEBTOR|':CLIENT.NO 308 CR.REC
      ReDim Client_Rec(0): Client_Rec(0) = Client_No
      rderr = d3.d3_readmat(database, Client_Rec(), "CLIENT")
      If UBound(Client_Rec) < 37 Then ReDim Preserve Client_Rec(37)
      
      ReDim tdrec(0): tdrec(0) = Client_No
      rderr = d3.d3_readmat(database, tdrec(), mdb_name & "\debtor")
      
      If Iscr = "C" Then
         Attr = 74
         If Amount >= 0 Then Tr_Code = Tr_Type_Rev Else Tr_Code = tr_type: Amount = -Amount: GoTo 311
         GoTo 311 ' ??? not yet able to allocate a credit so just add as unallocated
         Set tempobj = CreateObject("cka_ta16.ta16")
         Call tempobj.SR300(logentry, Client_No, Client_Rec(), "", Cr_Rec, Tr_Code, INV(0), Amount, CASH_DATE, Tdnarr, INV(4), "", "", "", INV(21), "", "", "", "", "", "", "", "", mdb_name & "\glcontrols")
         Set tempobj = Nothing
      Else
         If Amount >= 0 Then Tr_Code = Tr_Type_Rev Else Tr_Code = tr_type
         Attr = 73
311   Call sr310_mdb(database, tdrec(), mdb_inv(), Amount / 100, Tr_Code, Tdnarr, 0, debt_cont, mdb_name, "")
         Call SR310(database, INV(21), Client_No, Cr_Rec, INV(0), CASH_DATE, CStr(Amount), Tr_Code, Tdnarr, 0, INV(4), debt_cont, mdb_name, "")
      End If
      If Client_Rec(35) <> "" Or Client_Rec(37) <> "" Then
         For Jj = 1 To pick.dcount(Client_Rec(35), Chr(253))
             rderr = d3.d3_delete("", "TD.VALUE", pick.extract(Client_Rec(35), 1, Jj, 0))
         Next Jj
         For Jj = 1 To pick.dcount(Client_Rec(37), Chr(253))
             rderr = d3.d3_delete("", "TD.VALUE", pick.extract(Client_Rec(37), 1, Jj, 0))
         Next Jj
      End If
      ids = pick.extract(Cr_Rec, Attr, 0, 0)
      If pick.locate(INV(0), ids, 1, 1, 0, Jj, "") <> 0 Then
         Cr_Rec = pick.delet(Cr_Rec, Attr, Jj, 0)
      End If
      hp = INV(38)
      If hp <> "" Then
         If pick.locate(hp, Cr_Rec, 51, 1, 0, Jj, "") = 0 Then Cr_Rec = pick.Replace(Cr_Rec, 52, Jj, 0, hp)
      End If
      wterr = d3.d3_writestr(database, "TDEBTOR", Client_No, Cr_Rec)
      wterr = d3.d3_writemat(database, mdb_name & "\debtor", tdrec())
'
' POST TO TRANS.J
'
      Tjjob = 0: Tjnarr = INV(0)
      'If Storeno Then GoTo 7001     ' POSTING TO STORE C-O-S DONE
      If Gl_Acct Then Tjac = Client_No Else Tjac = debt_cont
      Tjcost = Amount / 100 'multiplied again in routine 777
      If Tjcost >= 0 Then Tjcd = Tr_Type_Rev Else Tjcd = tr_type: Tjcost = -Tjcost
      If Tjac = "" Then Tjac = "DEBTOR CONTROL ACCT MISSING"
      GoSub 777
' SALES TAX
7001  Tjnarr = INV(0): Tjjob = 0
      For I = 1 To UBound(Txcd)
         Tjac = Txcd(I)
         Tr_Line_Tax = Inv_Tax_Amt(I)
         If Tr_Line_Tax = 0 Then GoTo 738
'              Tjac = Pick.extract(Gst_Accs, 2, 1, 0)
'         Else
'            READV TAX_ACCT FROM SALETAX_DATA,TR_TAX,3 ELSE TAX_ACCT="TAX CODE " & TR_TAX & " MISSING"
'            Tjac = Tax_Acct
'         End If
         If Tr_Line_Tax > 0 Then Tjcd = tr_type: Tjcost = Tr_Line_Tax Else Tjcd = Tr_Type_Rev: Tjcost = -Tr_Line_Tax
         'If Tjac = "" Then Tjac = "TAX CODE " & Tr_Tax & " ACCT MISSING"
         GoSub 777
738   Next I

755  Tj_Key = "00" & Timer()
     If d3.d3_readstr(database, Tj_Rec, "TRANS.J", Tj_Key) <> 0 Then Tj_Rec = "": GoTo 760
     'If Glbatch = 0 Then
        'Release TRANS_J_DATA, Tj_Key
        Unique = Unique + 1
        Tj_Key = Tj_Key & Unique
        GoTo 755
     'End If
'$INSERT I.LOG.UPDATE '|TRANS.J|':TJ.KEY 755 TJ.REC
     GoTo 761
760
'$INSERT I.LOG.ADD '|TRANS.J|':TJ.KEY 755
'
761   If Gl_Acct = 0 Then Tjdata(5) = Client_No
      'If Gl_Acct = 0 And Not (Glbatch) Then Tjdata(5) = Client_No
      Tjdata(7) = INV(21)
'
'     If Glbatch Then
'        For I = 1 To 999
'           Tjcd = Tjdata(Pick.extract(1), 1, I)
'           If Tjcd = "" Then GoTo 769
'           For Ii = 1 To 999
'              Tjcdd = Pick.extract(Tj_Rec, 1, Ii, 0)
'              If Tjcdd = "" Then GoTo 765
'              If Tjcd = Tjcdd And Tjdata(Pick.extract(2), 1, I) = Pick.extract(Tj_Rec, 2, Ii, 0) And Tjdata(Pick.extract(3), 1, I) = Pick.extract(Tj_Rec, 3, Ii, 0) And Tjdata(Pick.extract(6), 1, I) = Pick.extract(Tj_Rec, 6, Ii, 0) Then
'                 Tj_Rec = Pick.replace(Tj_Rec, 4, Ii, 0, Pick.extract(Tj_Rec, 4, Ii, 0) + Tjdata(Pick.extract(4), 1, I))
'                 GoTo 768
'              End If
'           Next Ii
'765        Tj_Rec = Pick.insert(Tj_Rec, 1, -1, 0, Tjcd)
'           Tj_Rec = Pick.insert(Tj_Rec, 2, -1, 0, Tjdata(Pick.extract(2), 1, I))
'           Tj_Rec = Pick.insert(Tj_Rec, 3, -1, 0, Tjdata(Pick.extract(3), 1, I))
'           Tj_Rec = Pick.insert(Tj_Rec, 4, -1, 0, Tjdata(Pick.extract(4), 1, I))
'           Tj_Rec = Pick.insert(Tj_Rec, 6, -1, 0, Tjdata(Pick.extract(6), 1, I))
'768     Next I
'769     Tj_Rec = Pick.replace(Tj_Rec, 7, 0, 0, inv(21))
'        Call PICKWT(database, TRANS_J_DATA, Tj_Key, 3, Tj_Rec, 0)
'     Else
         Tjdata(0) = Tj_Key
         wterr = d3.d3_writemat(database, "TRANS.J", Tjdata())
'     End If
'gl summary
     For I = 1 To 999
        Tjcd = pick.extract(Tjdata(1), 1, I, 0)
        If Tjcd = "" Then GoTo 9000
        Tjac = pick.extract(Tjdata(3), 1, I, 0) & "?" & Tjcd
        If pick.extract(Tjdata(2), 1, I, 0) = 1 Then Tjac = "?" & Tjac
        If pick.locate(Tjac, SUMM(1), 1, 1, 0, Ii, "") = 0 Then
           SUMM(1) = pick.Insert(SUMM(1), 1, Ii, 0, Tjac)
           SUMM(2) = pick.Insert(SUMM(2), 1, Ii, 0, pick.extract(Tjdata(4), 1, I, 0))
           GoTo 395
        End If
        SUMM(2) = pick.Replace(SUMM(2), 1, Ii, 0, pick.extractcur(SUMM(2), 1, Ii, 0) + pick.extractcur(Tjdata(4), 1, I, 0))
395  Next I

9000:
  Next kk

        ReDim Preserve ptl(UBound(ptl) + 1)
        ptl(UBound(ptl)) = "<TR><TD>Account<TD>Description<TD>DEBIT<TD>CREDIT"
        If Jobcost Then ptl(UBound(ptl)) = ptl(UBound(ptl)) & "<TD>DEBIT<TH>CREDIT"
        Sum1 = 0: Sum2 = 0: Sum3 = 0: Sum4 = 0
        For I = 1 To 999
           Tjac = pick.extract(SUMM(1), 1, I, 0)
           If Tjac = "" Then GoTo 102
           If Mid$(Tjac, 1, 1) = "?" Then Tjob = 1: Tjac = Mid$(Tjac, 2, 99) Else Tjob = 0
           Tjcd = pick.field(Tjac, "?", 2): Tjac = pick.field(Tjac, "?", 1)
           Amt = pick.extractcur(SUMM(2), 1, I, 0)
           If Tjob Then
              ReDim INV(0): INV(0) = Tjac
              rderr = d3.d3_readmat(database, INV(), "JOB.L")
              If UBound(INV) < 2 Then Ptline = "???" Else Ptline = INV(2)
           Else
              ReDim INV(0): INV(0) = Tjac
              rderr = d3.d3_readmat(database, INV(), "GEN.L")
              If UBound(INV) < 2 Then Ptline = "???" Else Ptline = INV(2)
           End If
           Ptline = "<TR><TD>" & Tjac & "<TD>" & Ptline
           If Tjob = 1 Then Ptline = Ptline & "<TD><TD>"
           If Tjcd < 50 Then
              If Tjob Then Sum4 = Sum4 + Amt Else Sum2 = Sum2 + Amt
              Ptline = Ptline & "<TD>"
           Else
              If Tjob Then Sum3 = Sum3 + Amt Else Sum1 = Sum1 + Amt
           End If
           Ptline = Ptline & "<TD align=right>" & pick.oconv(CStr(Amt), "MD2")
           ReDim Preserve ptl(UBound(ptl) + 1)
           ptl(UBound(ptl)) = Ptline
        Next I
102     Ptline = "<TR><TD><TD><TD align=right>" & pick.oconv(CStr(Sum1), "MD2") & "<TD align=right>" & pick.oconv(CStr(Sum2), "MD2")
        If Jobcost Then
           Ptline = Ptline & "<TD align=right>" & pick.oconv(CStr(Sum3), "MD2") & "<TD align=right>" & pick.oconv(CStr(Sum4), "MD2")
        End If
        ReDim Preserve ptl(UBound(ptl) + 1)
        ptl(UBound(ptl)) = Ptline
        
        TA2480 = Join(ptl, Chr(8))
        
        Exit Function

'
' ROUTINE TO SETUP TRANS.J ITEM
'
777  'If Glbatch Then
     '   If Tjjob = 0 Then Tjnarr = INMSG2 & " BATCH " & inv(30)
     'End If
     Tjpp = 1
779  For Tjp = Tjpp To 999
        If pick.extract(Tjdata(3), 1, Tjp, 0) = Tjac Then GoTo 780
        If pick.extract(Tjdata(3), 1, Tjp, 0) = "" Then
           Tjdata(3) = pick.Insert(Tjdata(3), 1, -1, 0, Tjac)
           Tjdata(6) = pick.Insert(Tjdata(6), 1, -1, 0, Tjnarr)
           Tjdata(2) = pick.Insert(Tjdata(2), 1, -1, 0, Tjjob)
           Tjdata(1) = pick.Insert(Tjdata(1), 1, -1, 0, Tjcd)
           Tjdata(4) = pick.Insert(Tjdata(4), 1, -1, 0, CStr(Tjcost * 100))
           Return
        End If
     Next Tjp
780  If pick.extract(Tjdata(1), 1, Tjp, 0) <> Tjcd Or pick.extract(Tjdata(6), 1, Tjp, 0) <> Tjnarr Or pick.extract(Tjdata(2), 1, Tjp, 0) <> Tjjob Then Tjpp = Tjpp + 1: GoTo 779
     Tjdata(4) = pick.Replace(Tjdata(4), 1, Tjp, 0, pick.extractcur(Tjdata(4), 1, Tjp, 0) + Tjcost * 100)
     Return

End Function
Public Sub SR2488(database As String, Area_Id As String, td_id As String, Client_No As String, Rep_Id As String, NO_STOCK_STATS, Iscr As String, qty, Price, Cost, mttr As Integer)

Dim Area_Rec As String, Mval As String, Td_Rec As String, wterr As String
'
' UPDATE ALL STATISTICS FILES - FROM INVOICES OR CREDITS
'
'
' AREA STATS
'
      If Area_Id = "" Then GoTo 2290
2100  If d3.d3_readstr(database, Area_Rec, "AREA.STATS", Area_Id) <> 0 Then Area_Rec = ""
      'Log_Id = "|AREA_STATS|" & Area_Id
      'LOCATE(LOG_ID,LIDS,1,1,0,I,"") ELSE
      '   Lids = pick.insert(Lids, 1, -1, 0, Log_Id)
      '   GoTo 2101
      'End If
      'GoTo 2102
'2101
'$INSERT I.LOG.UPDATE LOG.ID 2100 AREA.REC   *
2102  Mval = pick.extract(Area_Rec, mttr, 1, 0)
      GoSub 5500
      Area_Rec = pick.Replace(Area_Rec, mttr, 1, 0, Mval)
      wterr = d3.d3_writestr(database, "AREA.STATS", Area_Id, Area_Rec)
'
' DEBTOR STATS ONLY FOR DEBTORS REQUIRING COLLECTION
'
2290
2300  If d3.d3_readstr(database, Td_Rec, "TD.STATS", td_id) <> 0 Then Td_Rec = ""
      'Log_Id = "|TD_STATS|" & TD_ID
      'LOCATE(LOG_ID,LIDS,1,1,0,I,"") ELSE
      '   Lids = pick.insert(Lids, 1, -1, 0, Log_Id)
      '   GoTo 2301
      'End If
      'GoTo 2302
'2301
'$INSERT I.LOG.UPDATE LOG.ID 2300 TD.REC   *
2302  Mval = pick.extract(Td_Rec, mttr, 1, 0)
      GoSub 5500
      Td_Rec = pick.Replace(Td_Rec, mttr, 1, 0, Mval)
      wterr = d3.d3_writestr(database, "TD.STATS", td_id, Td_Rec)
'
' DEBTORS VALUE STATS
'
2350  If d3.d3_readstr(database, Td_Rec, "TD.STATS2", Client_No) <> 0 Then Td_Rec = ""
      'Log_Id = "|TD_STATS2|" & CLIENT_NO
      'LOCATE(LOG_ID,LIDS,1,1,0,I,"") ELSE
      '   Lids = pick.insert(Lids, 1, -1, 0, Log_Id)
      '   GoTo 2351
      'End If
      'GoTo 2352
'2351
'$INSERT I.LOG.UPDATE LOG.ID 2350 TD.REC   *
2352  Mval = pick.extract(Td_Rec, mttr, 1, 0)
      GoSub 5600
      Td_Rec = pick.Replace(Td_Rec, mttr, 1, 0, Mval)
      wterr = d3.d3_writestr(database, "td.STATS2", Client_No, Td_Rec)
'
' REP STATS
'
      If Rep_Id = "" Then GoTo 2600
2380  If d3.d3_readstr(database, Td_Rec, "REP.STATS", Rep_Id) <> 0 Then Td_Rec = ""
      'Log_Id = "|REP_STATS|" & Rep_Id
      'LOCATE(LOG_ID,LIDS,1,1,0,I,"") ELSE
      '   Lids = pick.insert(Lids, 1, -1, 0, Log_Id)
      '   GoTo 2381
      'End If
      'GoTo 2382
'2381
'$INSERT I.LOG.UPDATE '|REP.STATS|':REP.ID 2380 TD.REC   *
2382  Mval = pick.extract(Td_Rec, mttr, 1, 0)
      GoSub 5600
      Td_Rec = pick.Replace(Td_Rec, mttr, 1, 0, Mval)
      wterr = d3.d3_writestr(database, "rep.STATS", Rep_Id, Td_Rec)
2600  Exit Sub
'
' ROUTINE TO UPDATE VALS
'
5500  If Iscr <> "C" Then
         Mval = pick.Replace(Mval, 1, 1, 1, pick.extractcur(Mval, 1, 1, 1) + qty)
         Mval = pick.Replace(Mval, 1, 1, 2, pick.extractcur(Mval, 1, 1, 2) + Price)
         Mval = pick.Replace(Mval, 1, 1, 5, pick.extractcur(Mval, 1, 1, 5) + Cost)
      Else
         Mval = pick.Replace(Mval, 1, 1, 3, pick.extractcur(Mval, 1, 1, 3) + qty)
         Mval = pick.Replace(Mval, 1, 1, 4, pick.extractcur(Mval, 1, 1, 4) + Price)
         Mval = pick.Replace(Mval, 1, 1, 5, pick.extractcur(Mval, 1, 1, 5) - Cost)
      End If
      Return
'
' DEBTOR VALUE STATS AND REP STATS
'
5600  If Iscr <> "C" Then
         Mval = pick.Replace(Mval, 1, 1, 1, pick.extractcur(Mval, 1, 1, 1) + Price)
         Mval = pick.Replace(Mval, 1, 1, 3, pick.extractcur(Mval, 1, 1, 3) + Cost)
      Else
         Mval = pick.Replace(Mval, 1, 1, 2, pick.extractcur(Mval, 1, 1, 2) + Price)
         Mval = pick.Replace(Mval, 1, 1, 3, pick.extractcur(Mval, 1, 1, 3) - Cost)
      End If
      Return
'
' END OF ROUTINE
'

End Sub


Public Sub SR2501(database As String, Prod, Branch, alt_bno, Inv_No, Contra, Client_No, Pt_Line As String, Sva_Acct, Cs_Acct, Sc_Acct, Cl_Acct, No_Ledg As String, Sales_Acct, Dep_Acct, STORENO, Scs_Acct, Sales_Acct2)

Dim PRD_GRP_REC() As String, Stock_Rec() As String, sc_bno As String, Prd_Grp As String
'
' GET LEDGER ACCOUNTS ROUTINE
' IN PT.LINE ERRORS, TA3574 EXPECTS WORD STOCK FOR STOCK ERROR
'                    ELSE ASSUMES PRODUCT GROUP ERROR
'
     If alt_bno = "" Then sc_bno = Branch Else sc_bno = alt_bno
'
9000 ReDim Stock_Rec(0): Stock_Rec(0) = Prod
     If d3.d3_readmat(database, Stock_Rec(), "STOCK") <> 0 Then
        'Pt_Line = "INVOICE " & INV_NO & " FOR SUPPLIER " & CLIENT_NO & "_ STOCK ITEM " & PROD & " DOES NOT EXIST_ LEDGER ACCOUNT FOR POSTINGS UNKNOWN"
9010    Sva_Acct = "SVA"
        Cs_Acct = "COST/SALES"
        Sc_Acct = "STOCK"
        Cl_Acct = "GI_CLRING"
        Sales_Acct = "SALES"
        Contra = "CONTRA"
        Dep_Acct = "DEP": Scs_Acct = "STORECOSTSALES"
        Sales_Acct2 = "SALES"
        No_Ledg = "1"
        Exit Sub
     End If
     Prd_Grp = Stock_Rec(2)
     ReDim PRD_GRP_REC(0): PRD_GRP_REC(0) = Prd_Grp
     If d3.d3_readmat(database, PRD_GRP_REC(), "PRD.GRP") <> 0 Then
        Pt_Line = "Item " & Inv_No & ". Stock item " & Prod & ". PRODUCT GROUP " & Prd_Grp & " DOES NOT EXIST. LEDGER ACCOUNT FOR POSTINGS UNKNOWN"
        GoTo 9010
     End If
     If UBound(PRD_GRP_REC) < 22 Then ReDim Preserve PRD_GRP_REC(22)
'
     No_Ledg = PRD_GRP_REC(5)
'
     Sales_Acct = PRD_GRP_REC(2)
     'BEGIN CASE
     '   Case Mid$(Sales_Acct, 1, 1) = ".": Sales_Acct = Branch & Sales_Acct
     '   Case Mid$(Sales_Acct, Len(Sales_Acct), 1) = ".": Sales_Acct = Sales_Acct & Branch
     '   Case Mid$(Sales_Acct, 1, 1) = " & ": Sales_Acct = Branch & Mid$(Sales_Acct, 2, 99)
     '   CASE MID$(SALES_ACCT,1,1) = "*": SALES_ACCT = MID$(BRANCH*(SALES_ACCT,2,INSTR(SALES_ACCT,".")-2)) & MID$(SALES_ACCT,INSTR(SALES_ACCT,"."),99)
     '   CASE MID$(SALES_ACCT,1,1) = "+": SALES_ACCT = MID$(BRANCH+(SALES_ACCT,2,INSTR(SALES_ACCT,".")-2)) & MID$(SALES_ACCT,INSTR(SALES_ACCT,"."),99)
     '   Case Mid$(Sales_Acct, Len(Sales_Acct), 1) = "+": Sales_Acct = Mid$(Sales_Acct, 1, Index(Sales_Acct, ".", 2)) & pick.field(Sales_Acct, ".", Mid$(3), 1, Len(pick.field(Sales_Acct, ".", 3)) - 1) + Branch
     '   CASE MID$(SALES_ACCT,1,1) = "-": SALES_ACCT = MID$(BRANCH-(SALES_ACCT,2,INSTR(SALES_ACCT,".")-2)) & MID$(SALES_ACCT,INSTR(SALES_ACCT,"."),99)
     '   Case Mid$(Sales_Acct, Len(Sales_Acct), 1) = "-": Sales_Acct = Mid$(Sales_Acct, 1, Index(Sales_Acct, ".", 2)) & Branch - pick.field(Sales_Acct, ".", Mid$(3), 1, Len(pick.field(Sales_Acct, ".", 3)) - 1)
     'ENDIF CASE
'
' CONTRA ACCOUNT
'
     Contra = PRD_GRP_REC(19)
     'BEGIN CASE
     '   Case Mid$(Contra, 1, 1) = ".": Contra = Branch & Contra
     '   Case Mid$(Contra, Len(Contra), 1) = ".": Contra = Contra & Branch
     '   Case Mid$(Contra, 1, 1) = " & ": Contra = Branch & Mid$(Contra, 2, 99)
     '   CASE MID$(CONTRA,1,1) = "*": CONTRA = MID$(BRANCH*(CONTRA,2,INSTR(CONTRA,".")-2)) & MID$(CONTRA,INSTR(CONTRA,"."),99)
     '   CASE MID$(CONTRA,1,1) = "+": CONTRA = MID$(BRANCH+(CONTRA,2,INSTR(CONTRA,".")-2)) & MID$(CONTRA,INSTR(CONTRA,"."),99)
     '   Case Mid$(Contra, Len(Contra), 1) = "+": Contra = Mid$(Contra, 1, Index(Contra, ".", 2)) & pick.field(Contra, ".", Mid$(3), 1, Len(pick.field(Contra, ".", 3)) - 1) + Branch
     '   CASE MID$(CONTRA,1,1) = "-": CONTRA = MID$(BRANCH-(CONTRA,2,INSTR(CONTRA,".")-2)) & MID$(CONTRA,INSTR(CONTRA,"."),99)
     '   Case Mid$(Contra, Len(Contra), 1) = "-": Contra = Mid$(Contra, 1, Index(Contra, ".", 2)) & Branch - pick.field(Contra, ".", Mid$(3), 1, Len(pick.field(Contra, ".", 3)) - 1)
     'ENDIF CASE
'
' SVA
'
     Sva_Acct = PRD_GRP_REC(6)
     'BEGIN CASE
     '   Case Mid$(Sva_Acct, 1, 1) = ".": Sva_Acct = Branch & Sva_Acct
     '   Case Mid$(Sva_Acct, Len(Sva_Acct), 1) = ".": Sva_Acct = Sva_Acct & Branch
     '   Case Mid$(Sva_Acct, 1, 1) = " & ": Sva_Acct = Branch & Mid$(Sva_Acct, 2, 99)
     '   CASE MID$(SVA_ACCT,1,1) = "*": SVA_ACCT = MID$(BRANCH*(SVA_ACCT,2,INSTR(SVA_ACCT,".")-2)) & MID$(SVA_ACCT,INSTR(SVA_ACCT,"."),99)
     '   CASE MID$(SVA_ACCT,1,1) = "+": SVA_ACCT = MID$(BRANCH+(SVA_ACCT,2,INSTR(SVA_ACCT,".")-2)) & MID$(SVA_ACCT,INSTR(SVA_ACCT,"."),99)
     '   Case Mid$(Sva_Acct, Len(Sva_Acct), 1) = "+": Sva_Acct = Mid$(Sva_Acct, 1, Index(Sva_Acct, ".", 2)) & pick.field(Sva_Acct, ".", Mid$(3), 1, Len(pick.field(Sva_Acct, ".", 3)) - 1) + Branch
     '   CASE MID$(SVA_ACCT,1,1) = "-": SVA_ACCT = MID$(BRANCH-(SVA_ACCT,2,INSTR(SVA_ACCT,".")-2)) & MID$(SVA_ACCT,INSTR(SVA_ACCT,"."),99)
     '   Case Mid$(Sva_Acct, Len(Sva_Acct), 1) = "-": Sva_Acct = Mid$(Sva_Acct, 1, Index(Sva_Acct, ".", 2)) & Branch - pick.field(Sva_Acct, ".", Mid$(3), 1, Len(pick.field(Sva_Acct, ".", 3)) - 1)
     'ENDIF CASE
' COST OF SALES
     Cs_Acct = PRD_GRP_REC(3)
     'BEGIN CASE
     '   Case Mid$(Cs_Acct, 1, 1) = ".": Cs_Acct = Branch & Cs_Acct
     '   Case Mid$(Cs_Acct, Len(Cs_Acct), 1) = ".": Cs_Acct = Cs_Acct & Branch
     '   Case Mid$(Cs_Acct, 1, 1) = " & ": Cs_Acct = Branch & Mid$(Cs_Acct, 2, 99)
     '   CASE MID$(CS_ACCT,1,1) = "*": CS_ACCT = MID$(BRANCH*(CS_ACCT,2,INSTR(CS_ACCT,".")-2)) & MID$(CS_ACCT,INSTR(CS_ACCT,"."),99)
     '   CASE MID$(CS_ACCT,1,1) = "+": CS_ACCT = MID$(BRANCH+(CS_ACCT,2,INSTR(CS_ACCT,".")-2)) & MID$(CS_ACCT,INSTR(CS_ACCT,"."),99)
     '   Case Mid$(Cs_Acct, Len(Cs_Acct), 1) = "+": Cs_Acct = Mid$(Cs_Acct, 1, Index(Cs_Acct, ".", 2)) & pick.field(Cs_Acct, ".", Mid$(3), 1, Len(pick.field(Cs_Acct, ".", 3)) - 1) + Branch
     '   CASE MID$(CS_ACCT,1,1) = "-": CS_ACCT = MID$(BRANCH-(CS_ACCT,2,INSTR(CS_ACCT,".")-2)) & MID$(CS_ACCT,INSTR(CS_ACCT,"."),99)
     '   Case Mid$(Cs_Acct, Len(Cs_Acct), 1) = "-": Cs_Acct = Mid$(Cs_Acct, 1, Index(Cs_Acct, ".", 2)) & Branch - pick.field(Cs_Acct, ".", Mid$(3), 1, Len(pick.field(Cs_Acct, ".", 3)) - 1)
     'ENDIF CASE
' STOCK ON HAND
     Sc_Acct = PRD_GRP_REC(7)
     'BEGIN CASE
     '   Case Mid$(Sc_Acct, 1, 1) = ".": Sc_Acct = SC_BNO & Sc_Acct
     '   Case Mid$(Sc_Acct, Len(Sc_Acct), 1) = ".": Sc_Acct = Sc_Acct & Branch
     '   Case Mid$(Sc_Acct, 1, 1) = " & ": Sc_Acct = SC_BNO & Mid$(Sc_Acct, 2, 99)
     '   CASE MID$(SC_ACCT,1,1) = "*": SC_ACCT = MID$(SC_BNO*(SC_ACCT,2,INSTR(SC_ACCT,".")-2)) & MID$(SC_ACCT,INSTR(SC_ACCT,"."),99)
     '   CASE MID$(SC_ACCT,1,1) = "+": SC_ACCT = MID$(SC_BNO+(SC_ACCT,2,INSTR(SC_ACCT,".")-2)) & MID$(SC_ACCT,INSTR(SC_ACCT,"."),99)
     '   Case Mid$(Sc_Acct, Len(Sc_Acct), 1) = "+": Sc_Acct = Mid$(Sc_Acct, 1, Index(Sc_Acct, ".", 2)) & pick.field(Sc_Acct, ".", Mid$(3), 1, Len(pick.field(Sc_Acct, ".", 3)) - 1) + SC_BNO
     '   CASE MID$(SC_ACCT,1,1) = "-": SC_ACCT = MID$(SC_BNO-(SC_ACCT,2,INSTR(SC_ACCT,".")-2)) & MID$(SC_ACCT,INSTR(SC_ACCT,"."),99)
     '   Case Mid$(Sc_Acct, Len(Sc_Acct), 1) = "-": Sc_Acct = Mid$(Sc_Acct, 1, Index(Sc_Acct, ".", 2)) & SC_BNO - pick.field(Sc_Acct, ".", Mid$(3), 1, Len(pick.field(Sc_Acct, ".", 3)) - 1)
     'ENDIF CASE
' CLEARING ACCOUNT
     Cl_Acct = PRD_GRP_REC(8)
     'BEGIN CASE
     '   Case Mid$(Cl_Acct, 1, 1) = ".": Cl_Acct = Branch & Cl_Acct
     '   Case Mid$(Cl_Acct, Len(Cl_Acct), 1) = ".": Cl_Acct = Cl_Acct & Branch
     '   Case Mid$(Cl_Acct, 1, 1) = " & ": Cl_Acct = Branch & Mid$(Cl_Acct, 2, 99)
     '   CASE MID$(CL_ACCT,1,1) = "*": CL_ACCT = MID$(BRANCH*(CL_ACCT,2,INSTR(CL_ACCT,".")-2)) & MID$(CL_ACCT,INSTR(CL_ACCT,"."),99)
     '   CASE MID$(CL_ACCT,1,1) = "+": CL_ACCT = MID$(BRANCH+(CL_ACCT,2,INSTR(CL_ACCT,".")-2)) & MID$(CL_ACCT,INSTR(CL_ACCT,"."),99)
     '   Case Mid$(Cl_Acct, Len(Cl_Acct), 1) = "+": Cl_Acct = Mid$(Cl_Acct, 1, Index(Cl_Acct, ".", 2)) & pick.field(Cl_Acct, ".", Mid$(3), 1, Len(pick.field(Cl_Acct, ".", 3)) - 1) + Branch
     '   CASE MID$(CL_ACCT,1,1) = "-": CL_ACCT = MID$(BRANCH-(CL_ACCT,2,INSTR(CL_ACCT,".")-2)) & MID$(CL_ACCT,INSTR(CL_ACCT,"."),99)
     '   Case Mid$(Cl_Acct, Len(Cl_Acct), 1) = "-": Cl_Acct = Mid$(Cl_Acct, 1, Index(Cl_Acct, ".", 2)) & Branch - pick.field(Cl_Acct, ".", Mid$(3), 1, Len(pick.field(Cl_Acct, ".", 3)) - 1)
     'ENDIF CASE
'
' DEPN ACCT
'
     Dep_Acct = PRD_GRP_REC(13)
     'BEGIN CASE
     '   Case Mid$(Dep_Acct, 1, 1) = ".": Dep_Acct = Branch & Dep_Acct
     '   Case Mid$(Dep_Acct, Len(Dep_Acct), 1) = ".": Dep_Acct = Dep_Acct & Branch
     '   Case Mid$(Dep_Acct, 1, 1) = " & ": Dep_Acct = Branch & Mid$(Dep_Acct, 2, 99)
     '   CASE MID$(DEP_ACCT,1,1) = "*": DEP_ACCT = MID$(BRANCH*(DEP_ACCT,2,INSTR(DEP_ACCT,".")-2)) & MID$(DEP_ACCT,INSTR(DEP_ACCT,"."),99)
     '   CASE MID$(DEP_ACCT,1,1) = "+": DEP_ACCT = MID$(BRANCH+(DEP_ACCT,2,INSTR(DEP_ACCT,".")-2)) & MID$(DEP_ACCT,INSTR(DEP_ACCT,"."),99)
     '   Case Mid$(Dep_Acct, Len(Dep_Acct), 1) = "+": Dep_Acct = Mid$(Dep_Acct, 1, Index(Dep_Acct, ".", 2)) & pick.field(Dep_Acct, ".", Mid$(3), 1, Len(pick.field(Dep_Acct, ".", 3)) - 1) + Branch
     '   CASE MID$(DEP_ACCT,1,1) = "-": DEP_ACCT = MID$(BRANCH-(DEP_ACCT,2,INSTR(DEP_ACCT,".")-2)) & MID$(DEP_ACCT,INSTR(DEP_ACCT,"."),99)
     '   Case Mid$(Dep_Acct, Len(Dep_Acct), 1) = "-": Dep_Acct = Mid$(Dep_Acct, 1, Index(Dep_Acct, ".", 2)) & Branch - pick.field(Dep_Acct, ".", Mid$(3), 1, Len(pick.field(Dep_Acct, ".", 3)) - 1)
     'ENDIF CASE
'
     If STORENO Then
        Scs_Acct = PRD_GRP_REC(18)
        'BEGIN CASE
        '   Case Mid$(Scs_Acct, 1, 1) = ".": Scs_Acct = STORENO & Scs_Acct
        '   Case Mid$(Scs_Acct, Len(Scs_Acct), 1) = ".": Scs_Acct = Scs_Acct & STORENO
        '   Case Mid$(Scs_Acct, 1, 1) = " & ": Scs_Acct = STORENO & Mid$(Scs_Acct, 2, 99)
        '   CASE MID$(SCS_ACCT,1,1) = "*": SCS_ACCT = MID$(STORENO*(SCS_ACCT,2,INSTR(SCS_ACCT,".")-2)) & MID$(SCS_ACCT,INSTR(SCS_ACCT,"."),99)
        '   CASE MID$(SCS_ACCT,1,1) = "+": SCS_ACCT = MID$(STORENO+(SCS_ACCT,2,INSTR(SCS_ACCT,".")-2)) & MID$(SCS_ACCT,INSTR(SCS_ACCT,"."),99)
        '   Case Mid$(Scs_Acct, Len(Scs_Acct), 1) = "+": Scs_Acct = Mid$(Scs_Acct, 1, Index(Scs_Acct, ".", 2)) & pick.field(Scs_Acct, ".", Mid$(3), 1, Len(pick.field(Scs_Acct, ".", 3)) - 1) + STORENO
        '   CASE MID$(SCS_ACCT,1,1) = "-": SCS_ACCT = MID$(STORENO-(SCS_ACCT,2,INSTR(SCS_ACCT,".")-2)) & MID$(SCS_ACCT,INSTR(SCS_ACCT,"."),99)
        '   Case Mid$(Scs_Acct, Len(Scs_Acct), 1) = "-": Scs_Acct = Mid$(Scs_Acct, 1, Index(Scs_Acct, ".", 2)) & STORENO - pick.field(Scs_Acct, ".", Mid$(3), 1, Len(pick.field(Scs_Acct, ".", 3)) - 1)
        'ENDIF CASE
     End If
'
' SPECIAL SALES ACCOUNT
'
     Sales_Acct2 = PRD_GRP_REC(22)
     'BEGIN CASE
     '   Case Mid$(Sales_Acct2, 1, 1) = ".": Sales_Acct2 = Branch & Sales_Acct2
     '   Case Mid$(Sales_Acct2, Len(Sales_Acct2), 1) = ".": Sales_Acct2 = Sales_Acct2 & Branch
     '   Case Mid$(Sales_Acct2, 1, 1) = " & ": Sales_Acct2 = Branch & Mid$(Sales_Acct2, 2, 99)
     '   CASE MID$(SALES_ACCT2,1,1) = "*": SALES_ACCT2 = MID$(BRANCH*(SALES_ACCT2,2,INSTR(SALES_ACCT2,".")-2)) & MID$(SALES_ACCT2,INSTR(SALES_ACCT2,"."),99)
     '   CASE MID$(SALES_ACCT2,1,1) = "+": SALES_ACCT2 = MID$(BRANCH+(SALES_ACCT2,2,INSTR(SALES_ACCT2,".")-2)) & MID$(SALES_ACCT2,INSTR(SALES_ACCT2,"."),99)
     '   Case Mid$(Sales_Acct2, Len(Sales_Acct2), 1) = "+": Sales_Acct2 = Mid$(Sales_Acct2, 1, Index(Sales_Acct2, ".", 2)) & pick.field(Sales_Acct2, ".", Mid$(3), 1, Len(pick.field(Sales_Acct2, ".", 3)) - 1) + Branch
     '   CASE MID$(SALES_ACCT2,1,1) = "-": SALES_ACCT2 = MID$(BRANCH-(SALES_ACCT2,2,INSTR(SALES_ACCT2,".")-2)) & MID$(SALES_ACCT2,INSTR(SALES_ACCT2,"."),99)
     '   Case Mid$(Sales_Acct2, Len(Sales_Acct2), 1) = "-": Sales_Acct2 = Mid$(Sales_Acct2, 1, Index(Sales_Acct2, ".", 2)) & Branch - pick.field(Sales_Acct2, ".", Mid$(3), 1, Len(pick.field(Sales_Acct2, ".", 3)) - 1)
     'ENDIF CASE
     Pt_Line = ""

End Sub
Public Sub sr310_mdb(database As String, tdrec() As String, INV() As String, Tr_Inv_Amt As Currency, Tr_Code As String, Tr_Narr As String, Cr_Relation As Integer, debt_cont As String, mdb_name As String, debtor_controls As String)

Dim Tr_Cash As String, Ii As Integer
Dim temp As String, tempcur As Currency
Dim Tr_Inv_Bal As Currency, Stmnt_Date As String
Dim Cr_No_Trans As Integer, Cr_Cur_Bal As Currency, Cashamtot As Currency
Dim Cashused_Ref As String, Cashused_Amt As String, Cashused_Dte As String, Days_To_Pay As Currency, Days_Ct_Pay As Currency
Dim Days_Used As Currency, Cashrefs As String, Cashpos As Integer, Cashid As String, Cashamt As Currency, Cashp As Integer
Dim Ddtes As String, max As Integer, Cashtyp As Integer, Casha As Currency, Cashdte As Integer, Cashldte As String, Cashofo As Integer
Dim Tran() As String, Cr_Tdate As String, I As Integer
Dim rderr As Integer, dcs() As String, UPDATE_FIRST_UNPAID As Integer
'
' Standard routine to add DEBIT to debtors account
'
'  or a CREDIT that is to be left unallocated
'    (where USE.INV.AMT < 0 and TR.CODE must be credit code)
'
' Can also post Credit transaction with zero balance outstanding which
' in effect is only adding the transaction without affecting the balance
' or credit allocations of the debtor's account
' i.e. USE.INV.AMT m/v 2 is set with 0 (zero)
' e.g. used in library system to post refund
'
'    If USE.INV.AMT<1,3> set, implies want transaction created but treat
'    as already statemented (where USE.INV.AMT<1,3> = statement date)

     Tr_Cash = 31
     Tr_Inv_Bal = Tr_Inv_Amt
     Stmnt_Date = ""
'
      If IsNumeric(tdrec(3)) Then Cr_Cur_Bal = CCur(tdrec(3)) Else Cr_Cur_Bal = 0
      If IsNumeric(tdrec(23)) Then Cr_Relation = CInt(tdrec(23)) Else Cr_Relation = 1
      ReDim dcs(0): dcs(0) = tdrec(23)
      rderr = d3.d3_readmat(database, dcs(), mdb_name & "\glcontrols")
      If UBound(dcs) < 1 Then debt_cont = "missing debtor control" Else debt_cont = dcs(1)
      If Left(debt_cont, 1) = "." Then debt_cont = (Cr_Relation - 1) & debt_cont
      
      Cashamtot = 0
      Cashused_Ref = "": Cashused_Amt = "": Cashused_Dte = ""
      Days_To_Pay = 0: Days_Ct_Pay = 0: Days_Used = 0
'
      If Tr_Inv_Bal = 0 Then Cashamtot = Tr_Inv_Amt: GoTo 500
'
'50    Cashrefs = pick.extract(Cr_Rec, 49, 0, 0)
'        If Cashrefs = "" Then
            GoTo 500 '??? do not allow for pre-allocations yet
'        Else
'           max = pick.dcount(Cashrefs, Chr(253))
'        End If
'      For Cashpos = 1 To max
'         If pick.extract(Cashrefs, 1, Cashpos, 0) <> "" And Mid(inv(0), 1, Len(pick.extract(Cashrefs, 1, Cashpos, 0))) = pick.extract(Cashrefs, 1, Cashpos, 0) Then GoTo 54
'      Next Cashpos
'      GoTo 500
'54    Cashid = pick.extract(Cr_Rec, 50, Cashpos, 0)
'      Cashamt = pick.extractcur(Cr_Rec, 51, Cashpos, 0)
'      If Cashamt > Tr_Inv_Amt - Cashamtot Then Cashamt = Tr_Inv_Amt - Cashamtot
'      For Cashp = 49 To 51
'         Cr_Rec = pick.delet(Cr_Rec, Cashp, Cashpos, 0)
'      Next Cashp
'
' update cash receipt, as now have invoice
'
'      Ddtes = CStr(inv(20))
'      If inv(21) <> "" And inv(21) <> CStr(inv(20)) Then Ddtes = Ddtes & "/" & inv(21)

'      Cashrefs = pick.extract(Cr_Rec, 12, 0, 0)
'      If pick.locate(Cashid, Cashrefs, 1, 1, 0, Cashp, "") = 0 Then GoTo 100
'      Cashtyp = pick.extractint(Cr_Rec, 11, Cashp, 0)
'      If Cashtyp >= 50 Then GoTo 100
'      Casha = pick.extractcur(Cr_Rec, 13, Cashp, 0)
'      Casha = Casha - pick.extractcur(Cr_Rec, 16, Cashp, 0)
'      If Cashamt > -Casha Then Cashamt = -Casha
'      If Cashamt <= 0 Then GoTo 100
'      tempcur = pick.extractcur(Cr_Rec, 16, Cashp, 0)
'      Cr_Rec = pick.replace(Cr_Rec, 16, Cashp, 0, tempcur - Cashamt)
'      Cr_Rec = pick.insert(Cr_Rec, 26, Cashp, -1, inv(0))
'      Cr_Rec = pick.insert(Cr_Rec, 30, Cashp, -1, CStr(Cashamt))
'      Cr_Rec = pick.insert(Cr_Rec, 42, Cashp, -1, Ddtes)
'      temp = pick.extract(Cr_Rec, 14, Cashp, 0)
'      If IsNumeric(temp) Then Cashdte = CCur(temp) Else Cashdte = 0
'      Cashldte = pick.extract(Cr_Rec, 32, Cashp, 0)
'      GoTo 200
'
' GO THRU OVERFLOWS FOR REFERENCE
'
'100   For Cashofo = Cr_Ovfno To 1 Step -1
'         Ovf_Key = Cashofo & "*" & tdrec(0)
'         If d3.d3_readstr(database, Tran, "TD.OFLOW", Ovf_Key) <> 0 Then GoTo 180 'Release TD_OFLOW_DATA, Ovf_Key: GoTo 180
'         Cashrefs = pick.extract(Tran, 3, 0, 0)
'         If pick.locate(Cashid, Cashrefs, 1, 1, 0, Cashp, "") = 0 Then GoTo 180 'Release TD_OFLOW_DATA, Ovf_Key: GoTo 180
'         temp = pick.extract(Tran, 2, Cashp, 0)
'         If IsNumeric(temp) Then Cashtyp = CInt(temp) Else Cashtyp = 0
'         If Cashtyp >= 50 Then GoTo 180 'Release TD_OFLOW_DATA, Ovf_Key: GoTo 180
'$INSERT I.LOG.UPDATE '|TD.OFLOW|':OVF.KEY ? TRAN   *
'         Casha = pick.extractcur(Tran, 4, Cashp, 0)
'         Casha = Casha - pick.extractcur(Tran, 6, Cashp, 0)
'         If Cashamt > -Casha Then Cashamt = -Casha
'         If Cashamt <= 0 Then GoTo 180 'Release TD_OFLOW_DATA, Ovf_Key: GoTo 180
'         tempcur = pick.extractcur(Tran, 6, Cashp, 0)
'         Tran = pick.replace(Tran, 6, Cashp, 0, tempcur - Cashamt)
'         Tran = pick.insert(Tran, 9, Cashp, -1, inv(0))
'         Tran = pick.insert(Tran, 10, Cashp, -1, CStr(Cashamt))
'         Tran = pick.insert(Tran, 12, Cashp, -1, Ddtes)
'         'rderr = d3.d3_writestr(database, "td.oflow", Cashofo & "*" & tdrec(0), Tran)
'         temp = pick.extract(Tran, 5, Cashp, 0)
'         If IsNumeric(temp) Then Cashdte = CCur(temp) Else Cashdte = 0
'         Cashldte = pick.extract(Tran, 11, Cashp, 0)
'         GoTo 200
'180   Next Cashofo
'      GoTo 50
'
'200   tempcur = pick.extractcur(Cr_Rec, 22, 0, 0)
'      Cr_Rec = pick.replace(Cr_Rec, 22, 0, 0, tempcur - Cashamt)
'      Cashamtot = Cashamtot + Cashamt
'      Cashused_Ref = pick.insert(Cashused_Ref, 1, 1, -1, Cashid)
'      Cashused_Amt = pick.insert(Cashused_Amt, 1, 1, -1, CStr(Cashamt))
'      Cdtes = CStr(Cashdte)
'      If Cashldte <> "" And Cashldte <> CStr(Cashdte) Then Cdtes = Cdtes & "/" & Cashldte
'      Cashused_Dte = pick.insert(Cashused_Dte, 1, 1, -1, Cdtes)
'      If Cashtyp = CInt(Tr_Cash) Then
'         Days_Used = 1
'         Days_To_Pay = Days_To_Pay + inv(20) - Cashdte
'         Days_Ct_Pay = Days_Ct_Pay + 1
'      End If
'      GoTo 50
'
'    GET RECORD FOR INSERTION OF TRANSACTION
'
500   ReDim Tran(0)
         Tran(0) = tdrec(0) & "_" & INV(0)
try_again:
         rderr = d3.d3_readmat(database, Tran(), mdb_name & "\dr_trans")
         If rderr = 0 Then 'already exists
            Tran(0) = tdrec(0) & "_" & INV(0) & "_" & Timer()
            GoTo try_again
         End If
         ReDim Preserve Tran(11)
         Tran(1) = tdrec(0)
         Tran(2) = INV(0)
         Tran(3) = Tr_Code
         Tran(4) = Tr_Inv_Amt
         Tran(5) = INV(20)
         Tran(6) = Cashamtot
         Tran(7) = Tr_Narr
         Tran(8) = INV(4)
         Tran(9) = Stmnt_Date
         Tran(11) = INV(21)
         
         'Tran = pick.insert(Tran, 9, i, 0, Cashused_Ref)
        ' Tran = pick.insert(Tran, 10, i, 0, Cashused_Amt)
       '  Tran = pick.insert(Tran, 12, i, 0, Cashused_Dte)
        ' Tran = pick.insert(Tran, 13, i, 0, Stmnt_Date)
         'Tran = pick.insert(Tran, 14, i, 0, "")
         rderr = d3.d3_writemat(database, mdb_name & "\dr_trans", Tran())
      
      tdrec(3) = CStr(Cr_Cur_Bal + Tr_Inv_Bal)
      If Tr_Inv_Bal < 0 Then
        If IsNumeric(tdrec(22)) Then tempcur = CCur(tdrec(22)) Else tempcur = 0
        tdrec(22) = tempcur - Tr_Inv_Amt
      End If
      'If Days_Used Then
      '   Days_To_Pay = Int(Days_To_Pay / Days_Ct_Pay + 0.5)
      '   Cr_Rec = pick.insert(Cr_Rec, 20, 1, 0, CStr(Days_To_Pay))
      '   Cr_Rec = pick.delet(Cr_Rec, 20, 11, 0)
      'End If
'
     UPDATE_FIRST_UNPAID = 0
     If tdrec(53) = "" Then
         UPDATE_FIRST_UNPAID = 1
     Else
        If DateDiff("d", INV(20), tdrec(53)) >= 0 Then UPDATE_FIRST_UNPAID = 1  'means tr_date < tdrec(53) 'first unpaid date
     End If
     If UPDATE_FIRST_UNPAID = 1 Then
        If Tr_Inv_Amt - Cashamtot <> 0 Then
            tdrec(53) = INV(20)
        End If
     End If

End Sub
Public Sub SR2710(database As String, Sno As String, BNO As String, the_DATE As Integer, tr_cost, Tr_Co_Disp, TR_FR_COST)

Dim Sb_Key As String, Sb_Rec As String, Prd_Grp As String, Cost_Dates As String, Costs As String, Oldcost
Dim Costdate As String, Nextcost, Nextdate, Fr_Per As Currency, Br_Grps As String, I As Integer
'
' SUBROUTINE TO RETURN LATEST STD COST IN CENTS (MAY HAVE DECIMAL POINT)
'
' TR.COST IN CENTS IN FORM 999.99
' TR.CO.DISP IN DOLLARS IN FORM 999.99 OR 999.9999
' TR.FR.COST IN CENTS IN FORM 999.99 MV LASTCOST MV DATE USED MV NEXT COST MV NEXT DATE
'
     If BNO = "" Then GoTo 50
'
     Sb_Key = Sno & "." & BNO
     If d3.d3_readstr(database, Sb_Rec, "STOCK.BRANCH", Sb_Key) <> 0 Then
50    If d3.d3_readstr(database, Sb_Rec, "STOCK", Sno) <> 0 Then Sb_Rec = ""
        Prd_Grp = pick.extract(Sb_Rec, 2, 0, 0)
        Cost_Dates = pick.extract(Sb_Rec, 8, 0, 0)
        Costs = pick.extract(Sb_Rec, 9, 0, 0)
        GoTo 100
     End If
     Prd_Grp = ""
     Cost_Dates = pick.extract(Sb_Rec, 35, 0, 0)
     If Cost_Dates = "" Then GoTo 50
     Costs = pick.extract(Sb_Rec, 36, 0, 0)
'
100  If pick.locate(CStr(the_DATE), Cost_Dates, 1, 1, 0, I, "DR") <> 0 Then
        End If
       tr_cost = pick.extract(Costs, 1, I, 0)
       Oldcost = pick.extract(Costs, 1, I + 1, 0): Costdate = pick.extract(Cost_Dates, 1, I, 0)
     If I <> 1 Then Nextcost = pick.extract(Costs, 1, I - 1, 0): Nextdate = pick.extract(Cost_Dates, 1, I - 1, 0) Else Nextcost = "": Nextdate = ""
'
     If BNO <> "" Then
        If d3.d3_readstr(database, Sb_Rec, "BRANCH", BNO) <> 0 Then Sb_Rec = ""
        Fr_Per = pick.extractcur(Sb_Rec, 6, 0, 0)
        Br_Grps = pick.extract(Sb_Rec, 7, 0, 0)
        If Br_Grps = "" Then GoTo 200
' MAY BE DIFFERENT % BASED ON PRODUCT GROUP. ATTEMPT TO FIND IT
        If Prd_Grp = "" Then
           If d3.d3_readstr(database, Prd_Grp, "STOCK", Sno, 2) <> 0 Then GoTo 200
        End If
        If pick.locate(Prd_Grp, Br_Grps, 1, 1, 0, I, "") = 0 Then GoTo 200
        Fr_Per = pick.extractcur(Sb_Rec, 8, I, 0)
'
200     TR_FR_COST = tr_cost / 100 * Fr_Per
        If tr_cost / 100 = pick.oconv(pick.ICONV(tr_cost / 100, "MD00"), "MD2") Then
           TR_FR_COST = pick.oconv(pick.ICONV(TR_FR_COST / 100, "MD00"), "MD0")
           tr_cost = tr_cost + TR_FR_COST * 100
         Else
           tr_cost = tr_cost + TR_FR_COST
           TR_FR_COST = pick.oconv(pick.ICONV(TR_FR_COST / 100, "MD22"), "MD2")
        End If
      Else
        TR_FR_COST = "0.00"
     End If
'
     tr_cost = Format(tr_cost / 100, "#.00") 'pick.oconv(pick.ICONV(tr_cost / 100, "MD22"), "MD2")

     Tr_Co_Disp = Format(tr_cost / 100, "#.0000") 'pick.oconv(tr_cost * 100, "MD4")
     'If Int(Tr_Co_Disp * 100) = Tr_Co_Disp * 100 Then Tr_Co_Disp = pick.oconv(Tr_Co_Disp * 100, "MD2")
     If Right(Tr_Co_Disp, 2) = "00" Then Tr_Co_Disp = Left(Tr_Co_Disp, Len(Tr_Co_Disp) - 2)
'
     TR_FR_COST = TR_FR_COST & Chr(253) & Oldcost & Chr(253) & Costdate & Chr(253) & Nextcost & Chr(253) & Nextdate

End Sub
Public Sub SR2500(database As String, eom As String, TRANS_INFO As String, Poqtyval, Branch As String, Sno As String, Total_Poss_Sva, tr_type As String, Tr_Ref As String, Tr_Date As Integer, use_Qty As Long, Sernos, Crvalue As Currency, tr_conv, tr_wgt, LINE_COST, Std_Cost As Currency, Total_Cost As Currency, TOTAL_SELL, TR_LEDG_DATE As String, Date1, Total_Std_Sva, Whatif As Integer, actual_costs As String, Actual_Qtys As String, Prod_Grp, Convert, Gino, Pono, Sbcuords, Sbcuqtys, Pt_Line As String, err_flag)

Dim Avcost As Integer, Avcost_Upd As Integer, Costbywgt As Integer, Qty_Flag As Integer
Dim Ans, temp As String
Dim Sb_Key As String, Sb_Rec As String, Sb_Qoh As Long, No_Trans As Integer, Pos As Integer
Dim Qty_Left, Gi_Qty
Dim Strec As String, Std_Date, Cost_Left As Currency, Use_Sernos, I As Integer, pline As String
Dim qty, St_Qty, Price, CODE, Remove_Qty, Sb_Sernos, J As Integer
Dim Sb_Serno, Fval, Sb_Sers, Serno, Sb_Ser, Sdates As String, Find_Date As Integer, Ct As Integer, dummy As String
Dim St_Rec As String, Unique As String, Statspos As Integer, Sign, Poqv, Stock_Rec As String, Brans As String

     temp = Mid$((pick.extract(TRANS_INFO, 57, 0, 0)), 14, 1)
     If IsNumeric(temp) Then Avcost = CInt(temp) Else Avcost = 0
     temp = Mid$((pick.extract(TRANS_INFO, 57, 0, 0)), 24, 1)
     If IsNumeric(temp) Then Avcost_Upd = CInt(temp) Else Avcost_Upd = 0
     temp = Mid$((pick.extract(TRANS_INFO, 57, 0, 0)), 35, 1)
     If IsNumeric(temp) Then Costbywgt = CInt(temp) Else Costbywgt = 0
     Qty_Flag = pick.extractint(TRANS_INFO, 110, 0, 0)
'
     Pt_Line = "": err_flag = 0
'
' THIS SUBROUTINE CALCULATES & RETURNS TWO VALUES TO THE PROGRAM
'  TOTAL.COST = TOTAL ACTUAL COST OF THE GOODS
'  NOTE: TOTAL COST + MEANS CREDIT STOCK CONTROL (NORMAL SALES INVOICE)
'
      If tr_type <> 71 And tr_type <> 47 And tr_type <> 50 And tr_type <> 28 Then tr_conv = 1
5     Ans = InStr(Sernos, " ")
      If Ans Then
         Sernos = Mid$(Sernos, 1, Ans - 1) & Chr(252) & Mid$(Sernos, Ans + 1, 999)
         GoTo 5
      End If
      actual_costs = "": Actual_Qtys = ""
'
' ROUTINE USE TO POST MOVEMENT TO STOCK.BRANCH LEDGERS
' USED FOR SALES (TR.TYPE < 50) AND PURCHASES (TR.TYPE >= 50)
' ALSO FINDS COST-OF-SALES FOR SALES FROM STOCK (PURCHASE) LEDGER
' WILL UPDATE STOCK (PURCHASE) LEDGER AND FOR PURCHASES MAY POST
'      CORRECTING ENTRIES TO TRANS.J (I.E. WHERE STOCK LEDGER HAS SALES)
'
      Sb_Key = Sno & "." & Branch
'
2000  If d3.d3_readstr(database, Sb_Rec, "STOCK.BRANCH", Sb_Key) <> 0 Then Sb_Rec = ""
      If Whatif Then GoTo a2000
'$INSERT I.LOG.UPDATE '|STOCK.BRANCH|':SB.KEY 2000 SB.REC
'
a2000:   Sb_Qoh = pick.extractcur(Sb_Rec, 1, 0, 0)
      No_Trans = pick.extractint(Sb_Rec, 43, 0, 0)
'
      Qty_Left = use_Qty
      Gi_Qty = use_Qty
      Total_Cost = 0: Total_Poss_Sva = 0: Total_Std_Sva = 0
      If use_Qty = 0 Then GoTo 1900 '*I_E_ ?PROD LINE ON INVOICE**
      If Avcost Then
         '???If use_Qty = "" Then total_cost = Crvalue: GoTo 1900
         If tr_type = 53 And Crvalue Then Total_Cost = Crvalue: GoTo 1900
         If Avcost = 2 And tr_type <> 71 And tr_type <> 47 Then GoTo 11
         If tr_type = 28 Or tr_type = 50 Or tr_type = 68 Or tr_type = 43 Or tr_type = 70 Or tr_type = 54 Or tr_type = 71 Or tr_type = 47 Then
            Total_Cost = Crvalue
            Qty_Left = 0
            If Abs(Qty_Left) >= Abs(Sb_Qoh) And Sb_Qoh > 0 And Avcost_Upd And tr_type < 50 Then GoTo a11
            GoTo 12
         End If
         If (Qty_Left < 0 And Sb_Qoh <> 0) Or (Qty_Left > 0 And Sb_Qoh > 0) Then
            If Abs(Qty_Left) < Abs(Sb_Qoh) Then
               Total_Cost = Int(Qty_Left * (pick.extractcur(Sb_Rec, 2, 0, 0) / Sb_Qoh))
               Qty_Left = 0
            Else
               Total_Cost = Int(pick.extract(Sb_Rec, 2, 0, 0))
               Qty_Left = Qty_Left - Sb_Qoh
               If Sb_Qoh > 0 And Avcost_Upd Then
a11:            If d3.d3_readstr(database, Strec, "STOCK", Sno) <> 0 Then Strec = ""
                  If Whatif Then GoTo b11
'$INSERT I.LOG.UPDATE '|STOCK|':SNO a11 STREC
b11:           Strec = pick.Insert(Strec, 9, 1, 0, Int(100 * (pick.extract(Sb_Rec, 2, 0, 0) / Sb_Qoh)))
                  Total_Cost = Total_Cost + Int(Qty_Left * (pick.extract(Sb_Rec, 2, 0, 0) / Sb_Qoh))
                  Qty_Left = 0
                  Std_Date = pick.extract(Strec, 8, 1, 0)
                  If Tr_Date < Std_Date Then Date = Std_Date Else Date = Tr_Date
                  Strec = pick.Insert(Strec, 8, 1, 0, Date)
                  If pick.extract(Strec, 8, 11, 0) <> "" Then
                     Strec = pick.delet(Strec, 8, 11, 0)
                     Strec = pick.delet(Strec, 9, 11, 0)
                  End If
                  If Whatif Then
                     'Release STOCK_DATA, SNO
                  Else
                     Call d3.d3_writestr(database, "STOCK", Sno, Strec)
                  End If
               End If
            End If
         End If
11       If Crvalue <> 0 Then
            Total_Cost = Crvalue
         Else
            Total_Cost = Total_Cost + Int(Qty_Left * Std_Cost)
         End If
12     If Avcost = 2 Then
            actual_costs = pick.Insert(actual_costs, 1, -1, 0, CStr(Std_Cost))
         Else
            actual_costs = pick.Insert(actual_costs, 1, -1, 0, Total_Cost / use_Qty)
         End If
         Actual_Qtys = pick.Insert(Actual_Qtys, 1, -1, 0, CStr(use_Qty))
         GoTo 1900
      End If
      If use_Qty < 0 Then '*I_E_ DEBIT STOCK, INCREASE STOCK-ON-HAND**
         If tr_type = 53 And Crvalue Then
            Total_Cost = Crvalue: Cost_Left = Total_Cost
            GoTo 1340
         End If
         If pick.extract(Sb_Rec, 45, 1, 0) + 0 >= 0 Then GoTo 1300
       Else '*I_E_ CREDIT STOCK, DECREASE STOCK-ON-HAND**
         If pick.extractcur(Sb_Rec, 45, 1, 0) + 0 <= 0 Then
            If Sernos = "" Then GoTo 1300
            Pt_Line = "** ERROR SR2500 ** " & Sernos & " CANNOT BE FOUND AS QTY-ON-HAND IS <= ZERO"
            err_flag = err_flag + 1
            'Release STOCK_BRANCH_DATA, Sb_Key
            Exit Sub
         End If
      End If
'
' IF DEBITTING AND STOCK IN CREDIT MATCH UP TRANSACTIONS
' IF CREDITTING AND STOCK IN DEBIT MATCH UP TRANSACTIONS
' IF SERIAL NUMBERS USED, THEY MUST BE THERE AND MATCHED UP
'
      Use_Sernos = Sernos
      For I = 1 To No_Trans
         qty = pick.extract(Sb_Rec, 45, I, 0): St_Qty = qty
         Price = pick.extract(Sb_Rec, 46, I, 0)
         If Price + 0 = 0 Then Price = qty * Std_Cost
         CODE = pick.extract(Sb_Rec, 44, I, 0)
'         If Sernos = "" Then
            If Abs(qty) > Abs(Qty_Left) Then '*QTY -VE IF DEBIT STOCK**
               Remove_Qty = Qty_Left
            Else
               Remove_Qty = qty
            End If
'         Else
'            Sb_Sernos = pick.extract(Sb_Rec, 52, I, 0)
'            Remove_Qty = 0
'            For J = 1 To 999
'               Sb_Serno = pick.extract(Sb_Sernos, 1, 1, J)
'               If Sb_Serno = "" Then
'                  If Remove_Qty = 0 Then GoTo 1190 Else GoTo 1150
'               End If
'               LOCATE(SB_SERNO,USE_SERNOS,1,1,1,SERPOS,"") ELSE GOTO 1120
'               Sb_Sernos = pick.delet(Sb_Sernos, 1, 1, J)
'               J = J - 1
'               Use_Sernos = pick.delet(Use_Sernos, 1, 1, SERPOS)
'               Remove_Qty = Remove_Qty + 1
'1120        Next J
'         End If
1150     qty = qty - Remove_Qty
         If qty = 0 Then
            No_Trans = No_Trans - 1
            Sb_Rec = pick.Replace(Sb_Rec, 43, 0, 0, CStr(No_Trans))
            For J = 44 To 47
               Sb_Rec = pick.delet(Sb_Rec, J, I, 0)
            Next J
            If Sernos <> "" Then
               Sb_Rec = pick.delet(Sb_Rec, 52, I, 0)
            End If
            Sb_Rec = pick.delet(Sb_Rec, 57, I, 0)
            Fval = Price
            I = I - 1
         Else
            Sb_Rec = pick.Replace(Sb_Rec, 45, I, 0, CStr(qty))
            'If Sernos <> "" Then
            '   Sb_Rec = pick.Replace(Sb_Rec, 52, I, 0, Sb_Sernos)
            'End If
            Fval = Int(Remove_Qty * (Price / St_Qty))
            If Abs(Fval) > Abs(Price) Then Fval = Price
            Sb_Rec = pick.Replace(Sb_Rec, 46, I, 0, Price - Fval)
         End If
         Qty_Left = Qty_Left - Remove_Qty
         Total_Cost = Total_Cost + Fval
         If CODE = 25 Then '*SALES INVOICE CAUSED CREDIT ENTRY**
            Total_Poss_Sva = Total_Poss_Sva + Fval
            Total_Std_Sva = Total_Std_Sva + Int(Remove_Qty * Std_Cost)
         End If
         actual_costs = pick.Insert(actual_costs, 1, -1, 0, Fval / Remove_Qty)
         Actual_Qtys = pick.Insert(Actual_Qtys, 1, -1, 0, CStr(Remove_Qty))
         If Qty_Left = 0 Then GoTo 1900
1190  Next I
      'If Sernos <> "" Then '*ERROR MATCH(MUST,ALL) <>S I_E_ QTY_LEFT = 0**
      '   pt_line = "** ERROR SR2500 ** " & Sernos & " WERE NOT ALL FOUND IN ITEM " & Sb_Key
      '   err_flag = err_flag + 1
         'Release STOCK_BRANCH_DATA, Sb_Key
      '   Exit Sub '* TO CALLING PROGRAM **
      'End If
'
' NO MATCHING REQUIRED. EITHER QTY.LEFT OR ORIGINAL USE.QTY
' I.E. DEBITTING STOCK IN DEBIT OR CREDITTING STOCK IN CREDIT
'      CHECK NO MATCH ON SERIAL NUMBERS IF USED
'
1300  Cost_Left = Int(Qty_Left / tr_conv) * Std_Cost  'pick.ICONV((Qty_Left / Tr_Conv) * STD_COST, "MD00")
      Total_Cost = Total_Cost + Cost_Left
      If Qty_Left <> 0 Then
         actual_costs = pick.Insert(actual_costs, 1, -1, 0, CStr(Std_Cost))
         Actual_Qtys = pick.Insert(Actual_Qtys, 1, -1, 0, CStr(Qty_Left))
      End If
'      If Sernos <> "" Then
'         Sb_Sers = pick.extract(Sb_Rec, 52, 0, 0)
'         For I = 1 To 999
'            Serno = pick.extract(Sernos, 1, 1, I)
'            If Serno = "" Then GoTo 1340
'            For J = 1 To No_Trans
'               Sb_Ser = pick.extract(Sb_Sers, 1, J, 0)
'               LOCATE(SERNO,SB_SER,1,1,1,SB_SER,"") ELSE GOTO 1330
'               Pt_Line = "** ERROR SR2500 ** SERIAL NUMBER " & Serno & " ALREADY EXISTS IN ITEM " & Sb_Key
'               Err_Flag = Err_Flag + 1
'               Release STOCK_BRANCH_DATA, Sb_Key
'               Exit Sub '* TO CALLING PROGRAM **
'1330        Next J
'         Next I
'      End If
1340  No_Trans = No_Trans + 1
      Sb_Rec = pick.Replace(Sb_Rec, 43, 0, 0, CStr(No_Trans))
      Sdates = pick.extract(Sb_Rec, 47, 0, 0)
'IF SAME DATE, WANT TRANS AT END OF SAME DATES. 'AR' WILL STOP AT FIRST
      Find_Date = Tr_Date + 1
      If Date1 = 1 Then Find_Date = 0 'TO FORCE IN-OUT STOCK INTO FIRST POS*
      If pick.locate(CStr(Find_Date), Sdates, 1, 1, 0, Pos, "AR") = 0 Then
      End If
      Sb_Rec = pick.Insert(Sb_Rec, 44, Pos, 0, tr_type)
      Sb_Rec = pick.Insert(Sb_Rec, 45, Pos, 0, -Qty_Left)
      Sb_Rec = pick.Insert(Sb_Rec, 46, Pos, 0, -Cost_Left)
      Sb_Rec = pick.Insert(Sb_Rec, 47, Pos, 0, CStr(Tr_Date))
      'If Sernos <> "" Then
      '   Sb_Rec = pick.Insert(Sb_Rec, 52, pos, 0, Sernos)
      'End If
      Sb_Rec = pick.Insert(Sb_Rec, 57, Pos, 0, Tr_Ref)
'
1900 If Avcost = 2 And Gino <> "" Then GoTo 7000
      If Whatif = 0 Then
         St_Rec = Sb_Key
         St_Rec = pick.Replace(St_Rec, 2, 0, 0, tr_type)
         St_Rec = pick.Replace(St_Rec, 3, 0, 0, Tr_Ref)
         St_Rec = pick.Replace(St_Rec, 4, 0, 0, CStr(Tr_Date))
         St_Rec = pick.Replace(St_Rec, 5, 0, 0, -Gi_Qty)
         St_Rec = pick.Replace(St_Rec, 6, 0, 0, -Total_Cost)
         St_Rec = pick.Replace(St_Rec, 7, 0, 0, TR_LEDG_DATE)
         'St_Rec = pick.Replace(St_Rec, 8, 0, 0, Sernos)
         St_Rec = pick.Replace(St_Rec, 9, 0, 0, pick.field(Sb_Key, ".", 1))
         St_Rec = pick.Replace(St_Rec, 10, 0, 0, pick.field(Sb_Key, ".", 2))
2001 Unique = DateDiff("d", "31/12/67", CVar(Now)) & "." & Timer(): Ct = 0
         If d3.d3_readstr(database, dummy, "ST.TRANS", Unique) <> 0 Then GoTo 2002
         'Release ST_TRANS_DATA, Unique
         Ct = Ct + 1
         GoTo 2001
2002
'$INSERT I.LOG.ADD '|ST_TRANS|':UNIQUE 2001
         Call d3.d3_writestr(database, "ST_TRANS", Unique, St_Rec)
      End If
'
      Sb_Qoh = Sb_Qoh - Gi_Qty
      Sb_Rec = pick.Replace(Sb_Rec, 1, 0, 0, CStr(Sb_Qoh))
      If pick.extract(Sb_Rec, 1, 0, 0) < 0 And Qty_Flag And Gi_Qty > 0 Then
         Pt_Line = "STOCK ITEM " & Sno & " AT BRANCH " & Branch & " WILL HAVE A QUANTITY OF " & pick.extract(Sb_Rec, 1, 0, 0)
         err_flag = err_flag + 1
         'Release STOCK_BRANCH_DATA, Sb_Key
'$INSERT I.QU.REC
         Exit Sub
      End If
      Sb_Rec = pick.Replace(Sb_Rec, 2, 0, 0, pick.extractcur(Sb_Rec, 2, 0, 0) - Total_Cost)
      If Costbywgt Then Sb_Rec = pick.Replace(Sb_Rec, 37, 0, 0, pick.extract(Sb_Rec, 37, 0, 0) - tr_wgt)
      If tr_type = 25 Or tr_type = 29 Or tr_type = 53 Or tr_type = 68 Or tr_type = 43 Or tr_type = 54 Then
         If pick.locate(TR_LEDG_DATE, eom, 1, 1, 0, Statspos, "AR") <> 0 Then
         End If
         Statspos = Statspos + pick.extract(TRANS_INFO, 5, 0, 0)
         If tr_type < 50 Then Sign = -1 Else Sign = 1
         Sb_Rec = pick.Replace(Sb_Rec, 64, Statspos, 0, pick.extractcur(Sb_Rec, 64, Statspos, 0) + Gi_Qty)
         Sb_Rec = pick.Replace(Sb_Rec, 65, Statspos, 0, pick.extractcur(Sb_Rec, 65, Statspos, 0) + Total_Cost)
         If TOTAL_SELL + 0 <> 0 Then
            Sb_Rec = pick.Replace(Sb_Rec, 75, Statspos, 0, pick.extractcur(Sb_Rec, 75, Statspos, 0) + Gi_Qty)
            Sb_Rec = pick.Replace(Sb_Rec, 76, Statspos, 0, pick.extractcur(Sb_Rec, 76, Statspos, 0) - Sign * TOTAL_SELL)
            Sb_Rec = pick.Replace(Sb_Rec, 77, Statspos, 0, pick.extractcur(Sb_Rec, 77, Statspos, 0) + Total_Cost)
         End If
      End If
'
' ALTER CUST ORD COMMITS
'
3000  If Pono <> "" And Whatif = 0 Then
         Poqv = Poqtyval & Chr(253) & tr_conv
         If Costbywgt Then Poqv = Poqv & Chr(253) & tr_wgt / use_Qty
         'Call SR2522(SNO,  -use_Qty, Sb_Rec, PONO, Sb_Key, TR_REF,  SBCUORDS, SBCUQTYS, Pt_Line, err_flag, Poqv, ACCOUNT, "", "", "")
      End If
'
      If Sb_Qoh < pick.extractcur(Sb_Rec, 30, 0, 0) And Whatif = 0 Then
         'Call SR2531( SNO, Sb_Rec, TR_REF,  pline, Errflg,  "", "", "", "")
         'pt_line = pick.Insert(pt_line, 1, -1, 0, pline)
         'err_flag = err_flag + Errflg
      End If
'
7000  If Whatif Then
              'Release STOCK_BRANCH_DATA, Sb_Key
          Else
              Call d3.d3_writestr(database, "STOCK_BRANCH", Sb_Key, Sb_Rec)
          End If
'
1000  If d3.d3_readstr(database, Stock_Rec, "STOCK", Sno) <> 0 Then GoTo 9900
      If Whatif Then GoTo 1001
'$INSERT I.LOG.UPDATE '|STOCK|':SNO 1000 STOCK.REC
'
1001 If Avcost = 2 And Gino <> "" Then GoTo 7100
      Stock_Rec = pick.Replace(Stock_Rec, 28, 0, 0, pick.extract(Stock_Rec, 28, 0, 0) - Gi_Qty) '* TOTAL QTY AT ALL BRANCHES **)
      Stock_Rec = pick.Replace(Stock_Rec, 29, 0, 0, pick.extract(Stock_Rec, 29, 0, 0) - Total_Cost) '* TOTAL VALUE AT ALL BRANCHES **)
7100  Brans = pick.extract(Stock_Rec, 18, 0, 0)
      If pick.locate(Branch, Brans, 1, 1, 0, Pos, "") = 0 Then
         Brans = pick.Insert(Brans, 1, Pos, 0, Branch)
         Stock_Rec = pick.Replace(Stock_Rec, 18, 0, 0, Brans)
      End If
      If Whatif Then
         'Release STOCK_DATA, SNO
      Else
         Call d3.d3_writestr(database, "STOCK", Sno, Stock_Rec)
      End If
'
      Prod_Grp = pick.extract(Stock_Rec, 2, 0, 0)
      Convert = pick.extractcur(Stock_Rec, 7, 0, 0)
'
      Exit Sub                             '* TO CALLING PROGRAM **
'
9900  'Printer.Print "** ERROR ** STOCK ITEM "; SNO; " DOES NOT EXIST IN SR2500"
      'Stop

End Sub


Public Function ta2230(logentry As String, template_path As String, mdb_name As String, pass_parms As String, Iscr As String) As String

' TA2230 POST SUPPLIERS INVOICE TO LEDGERS

Dim Cphead, Tr_Commit_Dr, Tr_Commit_Cr, Nz, Saletx
Dim Redo_Batches, Wh_Tax, Use_Invoice, Use_Inv_Rev, Inmsg, Inmsg2
Dim Gmsg, Gmsg2, Inmsg3, Use_Invoice2, Use_Inv_Rev2, Narrflag
Dim Commit, Facts, Custord, Hasinv As Integer, Openitem
Dim Disc_Acct As String, Extradisc As Integer, Glbatch, Costbywgt
Dim Pps_Flg, Gst, Gst_Rate As String, Wh_Rate, Gst_Accs As String, Inp_Gst_Acc
Dim Wh_Tax_Acc As String, Gld_Ctl, Gld_Dte, Linect, Tct, Tbaval, Tgross
Dim Tnetval, Tbatchval, Tbct, Gst_Adj, Afs, Auto
Dim Lastbatch, Ans As String, Autonxt, Flags, fname, Chmsg, Tjkey, Jobcost
Dim Valvar As String, Avcost As Integer, Update_Costs As Integer
Dim Nosva, Jobdet, Library, SUMM() As String, Ct, Baval, Gross, Netval, Pt_Line As String
Dim Pagect, Logids, Batches, Batchval, I As Integer, Sum1, Sum2, Sum3
Dim Sum4, Tjac As String, Tjcd As String, Amt, Tjob As String, Gl_Pos, Gst_Adjustment, Sum5
Dim Logid, Gst_Act, F1, Gl_Num, Gstexp, INV() As String, Totdisc As Currency, Zz, Invamt As Currency
Dim Useinvamt As Currency, Tr_Invoice As String, Client_No As String, Inv_No As String, Tj_Key As String, Cred_Cont As String
Dim Tjdata() As String, Tj_Narr As String, Tjnarr As String, Tjjob As String, Tjcost As Currency, Pono As String, Gino As String, Giqty
Dim Giwgt, tr_prod As String, Book, tr_desc As String, Ppos, tr_qty, Tr_Qty2, Sernos
Dim Cost, Avstdcost, Po_Cost, Po_Val, Clr_Cost, Acct As String, Staff_Job_No
Dim Biblio_Rec, Biblio_Form, Biblio_Catg, Acq_Id, Use_Cost
Dim Tjpp As Integer, Tjp As Integer, Commit_Msg, Ord_Acct As String, No_Ledg As String, New_Std_Cost As Currency
Dim Poqtyval, Giino, Uqty As Long, Std_Cost As Currency, Sbcuords, Sbcuqtys, Total_Cost As Currency
Dim Total_Poss_Sva, Total_Std_Sva, pp As Integer, Valvar_Amt, Sva_Amt, Gi_Cost As Currency
Dim Valvar2, Gst_Inc, Gl_Post As String, Gl_Post_Amt As String, Flg, Tr_Narr As String, Sgnn As Integer
Dim Tr_Narr2, Client_Rec, Trcd As String, Cr_Cont_Accs, Cr_Relation As Integer, Cr_Control
Dim Group, No_Cos, Cono, Ii As Integer, Tj_Rec As String, Gstacct As String, ucost As Currency, qty As Long, uconv As String
Dim tr_conv    As String, Cl_Acct As String, Sva_Acct As String, Cs_Acct As String, Sc_Acct As String
Dim Tj_Rec2 As String, Tjcdd, Tj_Key2 As String, Lgid, J, Ass As String, Gikey, Batch, Prg, Msg
Dim TRANS_INFO As String, temp As String, rderr As Integer, wterr As String, eom As String
Dim pline As String, err_flag As String, Tr_Inv_Rev As String, Cr_Rec As String
Dim ass_rec As String, ass_rec2 As String

Dim fname_mdb As String, lines_mdb As String, lines_batch_mdb As String
Dim batch_lines_file As String, fname_batch As String, tname_batch As String, Batchnum As String
Dim sentence As String, mylist() As String, pick_cnt As Long, total_items As Long
Dim sentence2 As String, mylist2() As String, pick_cnt2 As Long, total_items2 As Long
Dim mdb_inv() As String, jrec() As String, parms() As String, database As String, kk As Integer, RR As Integer
Dim line_item() As String, Idate As Integer, Ldate As Integer

     If Iscr = "C" Then
         tname_batch = "CR_CR_BATCH": fname = "CREDIT"
     Else
         tname_batch = "CR_INV_BATCH": fname = "INVOICE"
     End If
     batch_lines_file = tname_batch & "_lines"
     fname_batch = mdb_name & "\" & tname_batch
     fname_mdb = mdb_name & "\" & fname
     lines_mdb = fname_mdb & "_lines"
     lines_batch_mdb = fname_batch & "_lines"
     
     parms = Split(pass_parms, Chr(8))
     If UBound(parms) < 0 Then
        ta2230 = Chr(8) & "No items found for selection " & sentence
        Exit Function
     End If
     Batchnum = parms(0)
     database = pick.extract(logentry, 2, 0, 0)
'
     'Cphead = Space((132 - Len(pick.extract(ACCOUNT, 1, 1, 1))) / 2) & pick.extract(ACCOUNT, 1, 1, 1)
     Tr_Commit_Dr = 81: Tr_Commit_Cr = 18
     If d3.d3_readstr(database, TRANS_INFO, "DICT TRANS.J", "TRANS_INFO") <> 0 Then Exit Function
     eom = pick.extract(TRANS_INFO, 8, 0, 0) & Chr(253) & pick.extract(TRANS_INFO, 7, 0, 0) & Chr(253) & pick.extract(TRANS_INFO, 33, 0, 0)
     eom = pick.delet(eom, 1, 1, 0)         '* REMOVE LAST MONTH OF PREVIOUS YEAR **
     'Auth_Flag = Mid$((pick.extract(trans_info, 49, 0, 0)), 15, 1) + 0
     Nz = pick.extractint(TRANS_INFO, 133, 0, 0) 'WCC
     Saletx = 1
     Redo_Batches = 0
     Wh_Tax = 0
     If Iscr Then
        Use_Invoice = 53
        Use_Inv_Rev = 28
        Inmsg = "CREDIT": Inmsg2 = "SC": Gmsg = "RETURN": Gmsg2 = "GR": Inmsg3 = "CREDITTED"
     Else
        Use_Invoice = 25: Use_Invoice2 = 20
        Use_Inv_Rev = 50: Use_Inv_Rev2 = 79
        Inmsg = "INVOICE": Inmsg2 = "SI": Gmsg = "INWARDS": Gmsg2 = "GI": Inmsg3 = "INVOICED"
     End If
     Narrflag = Mid$((pick.extract(TRANS_INFO, 49, 0, 0)), 10, 1)
     Commit = Mid$(pick.extract(TRANS_INFO, 130, 0, 0), 1, 1) + 0
     Facts = Mid$((pick.extract(TRANS_INFO, 49, 0, 0)), 14, 1) + 0
     Custord = Mid$((pick.extract(TRANS_INFO, 57, 0, 0)), 12, 1) + 0
     'Numbatch = Mid$((pick.extract(trans_info, 57, 0, 0)), 28, 1) + 0
     Hasinv = pick.extractint(TRANS_INFO, 16, 0, 0)
     Openitem = Mid$((pick.extract(TRANS_INFO, 49, 0, 0)), 4, 1) + 0
     Disc_Acct = pick.extract(TRANS_INFO, 38, 1, 0)
     Extradisc = pick.extractint(TRANS_INFO, 38, 5, 0)
     'Nodots = pick.extract(trans_info, 70, 1, 0) + 2:
     'Bval = Mid$((pick.extract(trans_info, 57, 0, 0)), 27, 1) + 0
     Glbatch = Mid$((pick.extract(TRANS_INFO, 57, 0, 0)), 18, 1) + 0
     Costbywgt = Mid$((pick.extract(TRANS_INFO, 57, 0, 0)), 35, 1) + 0
     'Batchcont = Mid$((pick.extract(trans_info, 57, 0, 0)), 19, 1) + 0
     Pps_Flg = pick.extract(TRANS_INFO, 113, 1, 0) + 0
     Gst = 2 'Mid$((pick.extract(trans_info, 49, 0, 0)), 12, 1) + 0
     If Gst = 2 Then
        If d3.d3_readstr(database, Gst_Rate, "GST.CONTROL", "GST_RATE") <> 0 Then
           Gst_Rate = 1000 & Chr(254) & 4850
        End If
        Wh_Rate = pick.extract(Gst_Rate, 2, 0, 0)
        If d3.d3_readstr(database, Gst_Accs, "GST.CONTROL", "GST_ACCS") <> 0 Then Gst_Accs = ""
        Inp_Gst_Acc = pick.extract(Gst_Accs, 1, 0, 0)
        Wh_Tax_Acc = pick.extract(Gst_Accs, 3, 0, 0)
     End If
     Gld_Ctl = Mid$(pick.extract(TRANS_INFO, 57, 0, 0), 15, 1) + 0
     Gld_Dte = pick.extract(TRANS_INFO, 34, 7, 0)
     Tct = 0: Tbaval = 0: Tgross = 0: Tnetval = 0: Tbatchval = 0: Tbct = 0: Gst_Adj = "": Afs = 0
'
     'If Auth_Flag Then  'WCC
     '   PRINT @(0,4) & "Print Authorisation Forms (Y/N) " &   'WCC
     '   INPUT AFS  'WCC
     '   If Afs = "Y" Then Afs = 1 Else Afs = 0 'WCC
     'End If 'WCC
     'Auto = 0: Batchnum = "": Lastbatch = "ENDIF"
     'If Ans = "AUTO" Then Auto = 2: GoTo 2
     'If Ans = "ALL" Then Auto = 1: GoTo 2
     'IF ANS<>"Y" THEN Printer.Print  ERASE;: RETURN
'
     'If Glbatch Then Tjkey = Time() & tj_tno & pick.iconv(Format$(Now, "DD MMM YY"), "D2") & "2230"
     Jobcost = pick.extractint(TRANS_INFO, 32, 0, 0)
     If Jobcost Then
        'Call SR_JL(1, "", MTS, "", "", JOB_L_DATA, "")
     End If
     Valvar = pick.extract(TRANS_INFO, 1, 0, 0)
     temp = Mid$((pick.extract(TRANS_INFO, 57, 0, 0)), 14, 1)
     If IsNumeric(temp) Then Avcost = CInt(temp) Else Avcost = 0
     'Multi_Company = 1
     'If d3.d3_readstr(database, CO_REC, "DICT GEN.L", "@COMPANY") <> 0 Then Multi_Company = 0
     If Hasinv Then
        If (Avcost = 2 And Valvar = "") Or (Avcost + 0 = 0 And Valvar = "") Then
           ta2230 = Chr(8) & "You must set attr 1 TRANS_INFO to gen_l acct number for value variances"
           Exit Function
        End If
        If Mid$(Valvar, 1, 1) = "." Or Mid$(Valvar, Len(Valvar), 1) = "." Or Mid$(Valvar, Len(Valvar), 1) = "-" Then GoTo 56
        If Valvar <> "" Then
           If d3.d3_readstr(database, temp, "GEN.L", Valvar, 2) <> 0 Then
55           ta2230 = Chr(8) & "Invalid acct number for value variances in attr 1 TRANS_INFO"
               Exit Function
           End If
           If pick.Index(Valvar, ".", 2) = 0 Then GoTo 55
        End If
     End If
56 Update_Costs = pick.extractint(TRANS_INFO, 26, 0, 0)

     Nosva = Mid$((pick.extract(TRANS_INFO, 57, 0, 0)), 8, 1) + 0
     Jobdet = Mid$((pick.extract(TRANS_INFO, 57, 0, 0)), 17, 1) + 0
'
     Library = 0 'pick.extract(trans_info, 132, 0, 0) + 0
'
'     Dim SUMM(2): Dim AUTHOR(50): Dim TOTAL_AUTH(50): Dim TOTAL_AUTH_LESS_GST(50): Dim TOTAL_AUTH_GST(50): MAT SUMM = "" 'WCC
'
     Ct = 0: Baval = 0: Gross = 0: Netval = 0
     Pt_Line = ""
     Logids = ""
'
     database = pick.extract(logentry, 2, 0, 0)

     sentence = "select id from " & tname_batch & " where batch = '" & Batchnum & "' order by " & fname
     total_items = d3.msa_select(mdb_name, sentence, mylist, pick_cnt, 0, 0)

     If total_items <= 0 Or pick_cnt = -1 Then
        Tj_Key = Chr(8) & "No items found for selection " & sentence
        If pick_cnt = -1 Then Tj_Key = Tj_Key & ". " & mylist(0)
        ta2230 = Tj_Key
        Exit Function
     End If
     
     ReDim ptl(0)
     If total_items = 1 Then ptl(0) = " was" Else ptl(0) = "s were"
     ptl(0) = "<TR><TD colspan=6>" & total_items & " " & fname & ptl(0) & " found in batch " & Batchnum

     total_items = total_items - 1

   For kk = 0 To total_items
      ReDim INV(0): INV(0) = mylist(kk)
      rderr = d3.d3_readmat(database, INV(), fname_batch)
      If rderr <> 0 Then GoTo 9000

rderr = pick.date_vb_to_pick(INV(21), Ldate, 0)
rderr = pick.date_vb_to_pick(INV(20), Idate, 0)
'     If Iscr Then
'        Logid = "|CR_CR_BATCH|" & inv(0)
'     Else
'        Logid = "|CR_INV_BATCH|" & inv(0)
'     End If
'$INSERT I.LOG.DELETE LOGID 200 INV MAT
    wterr = d3.d3_delete(database, fname_batch, INV(0)) 'delete from cr_inv_batch
     
     'If Gst = 1 Then
     '   READV GST_ACT FROM SALETAX_DATA,INV(34),4 ELSE GST_ACT="NO GST FOR " & INV(34)  'WCC
     '   For F1 = 1 To INV(9) 'WCC
     '      If Mid$(pick.extract(inv(10), 1, F1), 1, 3) = "JOB" Then 'WCC
     '         READV GL_NUM FROM JOB_L_DATA,MID$(pick.extract(inv(10),1,F1),4,99),18 ELSE GL_NUM=""  'WCC
     '         Gl_Num = pick.extract(Gl_Num, 1, 1, 1) 'WCC
     '      Else  'WCC
     '         Gl_Num = pick.extract(inv(10), 1, F1) 'WCC
     '      End If 'WCC
     '      READV GSTEXP FROM GEN_L_DATA,GL_NUM,24 THEN  'WCC
     '         If Gstexp = "Y" Then 'WCC
     '            INV(8) = INV(8) + pick.extract(inv(36), 1, F1) 'WCC
     '            INV(14)=PICK.REPLACE(14),1,F1,pick.extract(inv(14),1,F1)+pick.extract(inv(36),1,F1)  'WCC)
     '            INV(15)=PICK.REPLACE(15),1,F1,pick.extract(inv(15),1,F1)+pick.extract(inv(36),1,F1)  'WCC)
     '            INV(32) = INV(32) - pick.extract(inv(36), 1, F1) 'WCC
     '            LOCATE(GL_NUM,GST_ADJ,1,0,0,GL_POS,"") ELSE GL_POS=0  'WCC
     '            If Gl_Pos Then  'WCC
     '               GST_ADJ=PICK.REPLACE(GST_ADJ,2,GL_POS,0,PICK.EXTRACT(GST_ADJ,2,GL_POS,0)+pick.extract(inv(36),1,F1)  'WCC)
     '            Else  'WCC
     '               Gst_Adj = pick.insert(Gst_Adj, 1, Gl_Pos, 0, Gl_Num) 'WCC
     '               Gst_Adj = pick.insert(Gst_Adj, 2, Gl_Pos, 0, pick.extract(inv(36), 1, F1)) 'WCC
     '            End If 'WCC
     '            LOCATE(GST_ACT,GST_ADJ,1,0,0,GL_POS,"") ELSE GL_POS=0  'WCC
     '            If Gl_Pos Then  'WCC
     '               GST_ADJ=PICK.REPLACE(GST_ADJ,2,GL_POS,0,PICK.EXTRACT(GST_ADJ,2,GL_POS,0)-pick.extract(inv(36),1,F1)  'WCC)
     '            Else  'WCC
     '               Gst_Adj = pick.insert(Gst_Adj, 1, Gl_Pos, 0, Gst_Act) 'WCC
     '               Gst_Adj = pick.insert(Gst_Adj, 2, Gl_Pos, 0, (pick.extract(inv(36), 1, F1) * (-1))) 'WCC
     '            End If 'WCC
     '            INV(36)=PICK.REPLACE(36),1,F1,0  'WCC)
     '         End If 'WCC
     '      End If 'WCC
     '   Next F1  'WCC
     'End If

     
     
     Totdisc = 0
     'If Extradisc Then
    '    For Zz = 1 To INV(9)
   '        Totdisc = Totdisc + pick.extract(inv(19), 1, Zz)
     '   Next Zz
     'End If
     Invamt = INV(8) + INV(32)
     Useinvamt = Invamt
     'If Extradisc And Totdisc <> 0 Then Useinvamt = Invamt & Chr(253) & Totdisc
     'Useinvamt = pick.Replace(Useinvamt, 1, 4, 0, INV(25))
     'Useinvamt = pick.Replace(Useinvamt, 1, 3, 0, INV(28))
     'For Zz = 1 To INV(9)
     '   If pick.extract(inv(6), 1, Zz) <> "" Or pick.extract(inv(5), 1, Zz) <> "" Then Useinvamt = pick.Replace(Useinvamt, 1, 7, 0, 0): GoTo 1109 'WCC
     'Next Zz
     'Useinvamt = pick.Replace(Useinvamt, 1, 7, 0, pick.extract(Useinvamt, 1, 1, 0)) 'WCC
1109 Baval = Baval + INV(8) + INV(32)
     Tr_Invoice = Use_Invoice: Tr_Inv_Rev = Use_Inv_Rev
     If INV(24) = 1 Then Tr_Invoice = Use_Invoice2: Tr_Inv_Rev = Use_Inv_Rev2
'
     Client_No = pick.field(INV(0), "*", 1)
     Inv_No = Mid$(INV(0), InStr(INV(0), "*") + 1, 99)
     If Glbatch Then Tj_Key = Tjkey Else Tj_Key = INV(7)
     If Gld_Ctl And INV(21) < Gld_Dte Then INV(21) = Gld_Dte
'
     ReDim Tjdata(9)

        Tj_Narr = Inmsg2 & " " & Inv_No
        'If Facts Then
        '   Tj_Narr = Tj_Narr & " " & pick.extract(inv(12), 1, 1, 1)
        'Else
           Tj_Narr = Tj_Narr & " " & INV(3)
        'End If

     If Extradisc And Totdisc <> 0 Then
        Tjac = Disc_Acct: Tjnarr = Tj_Narr: Tjjob = 0
        If Totdisc < 0 Then Tjcd = Tr_Inv_Rev: Tjcost = -Totdisc Else Tjcd = Tr_Invoice: Tjcost = Totdisc
        GoSub 777
     End If
     
     
     sentence2 = "select * from " & batch_lines_file & " where id = '" & INV(0) & "' order by cnt"
     total_items2 = d3.msa_select(mdb_name, sentence2, mylist2, pick_cnt2, 0, 0, 1, 0, Chr(8)) - 1

     For RR = 0 To total_items2
        line_item = Split(mylist2(RR), Chr(8))
        If UBound(line_item) < 16 Then ReDim Preserve line_item(16)
        
        If Iscr Then Pono = "" Else Pono = line_item(13)
        Gino = line_item(14)
        If IsNumeric(line_item(15)) Then Giqty = line_item(15) Else Giqty = 0
        
        tr_prod = line_item(4) 'invoice=10
        If InStr(tr_prod, ".") Then Book = 0 Else Book = 1
        Cost = line_item(5) 'invoice=14
        tr_desc = line_item(6) 'invoice=12
        tr_qty = line_item(7) 'invoice=13
        
        'Stat_Cost = 0 'pick.fieldcur(mylist2(RR), Chr(8), 9) 'invoice=14
        'Tr_Price = line_item(9) 'invoice=15
        'Tr_Tax = line_item(10) 'invoice=16
        'Tr_Line_Tax = line_item(11) 'invoice=17
        'tax_account = line_item(12) 'invoice=
        'line_item(14) = Tr_Line_Amt + Tr_Line_Tax
        
        INV(5) = pick.Replace(INV(5), 1, RR + 1, 0, Pono)
        INV(6) = pick.Replace(INV(6), 1, RR + 1, 0, Gino)
        If Gino <> "" Then Pono = ""
        INV(10) = pick.Replace(INV(10), 1, RR + 1, 0, tr_prod)
        INV(12) = pick.Replace(INV(12), 1, RR + 1, 0, tr_desc)
        INV(13) = pick.Replace(INV(13), 1, RR + 1, 0, CStr(tr_qty))
        INV(14) = pick.Replace(INV(14), 1, RR + 1, 0, CStr(Cost * 100))
        'INV(15) = pick.Replace(INV(15), 1, RR + 1, 0, CStr(Tr_Price * 100))
        'INV(16) = pick.Replace(INV(16), 1, RR + 1, 0, Tr_Tax)
        'INV(17) = pick.Replace(INV(17), 1, RR + 1, 0, CStr(Tr_Line_Tax * 100))
     
        'Giwgt = pick.extract(inv(38), 1, I)
        If Giqty = 0 Then tr_conv = 1 Else tr_conv = tr_qty / Giqty
        'If Costbywgt And Giwgt Then Tr_Qty2 = Giwgt Else Tr_Qty2 = Giqty
        'If Giqty = "" Then xx = pick.extract(inv(15), 1,i,0)Else xx = Tr_Qty2 * pick.extract(inv(15), 1, I)
        'Gross = Gross + Int(xx)
        'Sernos = pick.extract(inv(16), 1, I)
        'If Extradisc Then Cost = Cost + pick.extract(inv(19), 1, I)
        If tr_qty = 0 And Cost = 0 Then GoTo 680
        'Avstdcost = pick.extract(inv(18), 1, I)
        'Po_Cost = pick.extract(inv(17), 1, I)
        'Po_Val = pick.extract(inv(30), 1, I)
        'If Gino <> "" Then
        '   Clr_Cost = pick.extract(inv(31), 1, I)
        'Else
        '   Clr_Cost = 0
        '   If Commit Then
        '      If Pono <> "" Then Clr_Cost = pick.extract(inv(30), 1, I)
        '   End If
        'End If
'
610  If pick.Index(tr_prod, ".", 2) Or (Library And Book) Then
           If Mid$(tr_prod, 1, 3) = "JOB" Then
              If d3.d3_readstr(database, Acct, "JOB.L", Mid$(tr_prod, 4, 99)) <> 0 Then Acct = ""
              Acct = pick.extract(Acct, 18, 1, 1)
           Else
              Acct = tr_prod
              'If Book Then
              '   If Auth_Flag Then  'WCC
              '      If pick.extract(inv(45), 1,i,0)= "" Then 'WCC
              '         If d3.d3_readstr(database, STAFF_REC, "STAFF", pick.extract(inv(35), 1, I)) <> 0 Then 'WCC
              '            Pt_Line = "Staff Code " & pick.extract(inv(35), 1,i,0)& " Not Found on STAFF file - Check Posting " 'WCC
              '            GoSub 5000  'WCC
              '            GoTo 615  'WCC
              '         End If 'WCC
              '         Staff_Job_No = pick.extract(STAFF_REC, 7, 0, 0) 'WCC
              '         If Staff_Job_No = "" Then 'WCC
              '            Pt_Line = "No job number set up for STAFF code " & pick.extract(inv(35), 1,i,0)& " - Check Posting" 'WCC
              '            GoSub 5000  'WCC
              '            GoTo 615  'WCC
              '         Else  'WCC
              '            Staff_Job_No = "JOB" & Staff_Job_No 'WCC
              '         End If 'WCC
              '         If pick.field(Staff_Job_No, ".", 3) = "" Then Staff_Job_No = Staff_Job_No & "." & pick.extract(MTS, 1, 1, 0) 'WCC
              '      Else  'WCC
              '         Staff_Job_No = "JOB" & pick.extract(inv(45), 1,i,0)'WCC
              '      End If 'WCC
              '      If d3.d3_readstr(database, Acct, "JOB.L", Mid$(Staff_Job_No, 4, 99)) <> 0 Then Acct = ""
              '      Acct = pick.extract(Acct, 18, 1, 1)
              '   Else  'WCC
615        '         If d3.d3_readstr(database, Biblio_Rec, "BIBLIO", tr_prod) <> 0 Then Biblio_Rec = ""
              '      Biblio_Form = pick.extract(Biblio_Rec, 12, 0, 0)
              '      Biblio_Catg = pick.extract(Biblio_Rec, 13, 0, 0)
              '      Acq_Id = "@A_" & Biblio_Form & "." & Biblio_Catg
              '      READV  ACCT FROM CODES_DATA,ACQ_ID,2 ELSE ACCT = ""
              '      If Acct = "" Then
              '         Call SR2503(trans_info, "", INV(1), Acct)
              '      End If
              '   End If
              'End If
           End If
620     If Commit And Pono <> "" Then
              Use_Cost = Cost
           Else
              Use_Cost = Cost - Clr_Cost
           End If
           If Use_Cost = 0 Then GoTo 621
           Tjac = Acct: Tjnarr = Tj_Narr: Tjjob = 0
           If Narrflag = 1 Then Tjnarr = Tjnarr & " " & tr_desc
           If Use_Cost > 0 Then Tjcd = Tr_Inv_Rev: Tjcost = Use_Cost Else Tjcd = Tr_Invoice: Tjcost = -Use_Cost
           GoSub 777
           GoTo 621
'
'  ROUTINE TO SETUP TRANS.J ITEM
'
777  If Glbatch Then
           If Tjjob = 0 Then Tjnarr = Inmsg2 & " BATCH " & INV(3)
        End If
        Tjpp = 1
        If Tjac = "" Then Tjac = "ERROR-account not setup in program 2230"
779  For Tjp = Tjpp To 999
           If pick.extract(Tjdata(3), 1, Tjp, 0) = Tjac Then GoTo 781
           If pick.extract(Tjdata(3), 1, Tjp, 0) = "" Then
              Tjdata(3) = pick.Insert(Tjdata(3), 1, -1, 0, Tjac)
              Tjdata(6) = pick.Insert(Tjdata(6), 1, -1, 0, Tjnarr)
              Tjdata(2) = pick.Insert(Tjdata(2), 1, -1, 0, Tjjob)
              Tjdata(1) = pick.Insert(Tjdata(1), 1, -1, 0, Tjcd)
              Tjdata(4) = pick.Insert(Tjdata(4), 1, -1, 0, CStr(Tjcost))
              Return
           End If
        Next Tjp
781  If pick.extract(Tjdata(1), 1, Tjp, 0) <> Tjcd Or pick.extract(Tjdata(6), 1, Tjp, 0) <> Tjnarr Or pick.extract(Tjdata(2), 1, Tjp, 0) <> Tjjob Then Tjpp = Tjpp + 1: GoTo 779
        Tjdata(4) = pick.Replace(Tjdata(4), 1, Tjp, 0, pick.extractcur(Tjdata(4), 1, Tjp, 0) + Tjcost)
        Return
'
'  END OF ROUTINE
'
621     If Mid$(tr_prod, 1, 3) <> "JOB" Then 'WCC
              'If Library And Auth_Flag Then  'WCC
              '   Tjac = Mid$(Staff_Job_No, 4, 99): Tjjob = 1 'WCC
              'Else  'WCC
                 GoTo 622  'WCC
              'End If 'WCC
           Else  'WCC
              Tjac = Mid$(tr_prod, 4, 99): Tjjob = 1 'WCC
           End If 'WCC
           If Gino <> "" Then
              Tjcd = 46: Tjcost = Clr_Cost: Tjnarr = Gmsg2 & " " & Gino & Chr(252) & Inmsg3 & " ON " & Inmsg2 & " " & Inv_No
              GoSub 777
              Tjcd = 50: Tjcost = Cost
              Tjnarr = Tj_Narr
              If Jobdet Then
                 Tjnarr = Tjnarr & Chr(252) & tr_desc & Chr(252) & tr_qty
              End If
              GoSub 777
              GoTo 622
           End If
           If Pono <> "" Then
              Tjcd = Tr_Commit_Cr: Tjcost = Po_Val: Tjnarr = "PO " & Pono & " RECEIVED ON SI " & Inv_No
              GoSub 777
              Tjcd = 50: Tjcost = Cost: GoSub 777
              Tjnarr = Tj_Narr
              If Jobdet Then
                 Tjnarr = Tjnarr & Chr(252) & tr_desc & Chr(252) & tr_qty
              End If
              GoTo 622
           End If
           If Use_Cost > 0 Then Tjcd = Tr_Inv_Rev: Tjcost = Use_Cost Else Tjcd = Tr_Invoice: Tjcost = -Use_Cost
           Tjnarr = Tj_Narr
           GoSub 777
622     If Clr_Cost = 0 Then GoTo 680
           'If Library And Book Then tr_prod = ""
           Call SR2503(TRANS_INFO, Cl_Acct, INV(1), tr_prod) '*DONOTALTER**
           If Commit And Pono <> "" Then GoTo 624
           Tjac = Cl_Acct: Tjnarr = Tj_Narr: Tjjob = 0
           Tjcd = Tr_Inv_Rev: Tjcost = Clr_Cost
           GoSub 777
624     If Commit And Clr_Cost + 0 <> 0 And Pono <> "" Then
              Commit_Msg = "PO " & Pono & " " & tr_desc
              Tjcd = Tr_Commit_Dr: Tjjob = 0: Tjac = Cl_Acct: Tjnarr = Commit_Msg: Tjcost = Clr_Cost: GoSub 777
              Tjcd = Tr_Commit_Cr: Tjjob = 0: Tjac = Acct: Tjnarr = Commit_Msg: Tjcost = Clr_Cost: GoSub 777
           End If
           GoTo 680
        End If
        If Commit And Clr_Cost + 0 <> 0 And Pono <> "" Then
           Ord_Acct = ""
           Call SR2503(TRANS_INFO, Acct, INV(1), Ord_Acct)
           If pick.extract(INV(40), 1, I, 0) <> "" Then Ord_Acct = pick.extract(INV(40), 1, I, 0)
           Commit_Msg = "PO " & Pono & " " & tr_desc
           Tjcd = Tr_Commit_Dr: Tjjob = 0: Tjac = Acct: Tjnarr = Commit_Msg: Tjcost = Clr_Cost: GoSub 777
           Tjcd = Tr_Commit_Cr: Tjjob = 0: Tjac = Ord_Acct: Tjnarr = Commit_Msg: Tjcost = Clr_Cost: GoSub 777
        End If
        Call SR2501(database, tr_prod, INV(1), "", INV(0), "", Client_No, Pt_Line, Sva_Acct, Cs_Acct, Sc_Acct, Cl_Acct, No_Ledg, "", "", "", "", "")
        No_Ledg = No_Ledg + 0
        If Pt_Line <> "" Then GoSub 5000
        'If Iscr = 0 And Update_Costs And No_Ledg <> 4 And Giqty + 0 <> 0 Then
        '   New_Std_Cost = pick.oconv(pick.ICONV((Cost / Giqty), "MD22"), "MD2")
        '   Call SR2715(tr_prod, INV(1), INV(20), New_Std_Cost, Ans, INV(0), Update_Costs)
        '   Pt_Line = pick.extract(Ans, 1, 1, 0)
        '   If Pt_Line <> "" Then GoSub 5000
        '   Pt_Line = pick.extract(Ans, 1, 2, 0)
        '   If Pt_Line <> "" Then GoSub 5000
        'End If
        If Iscr Then
           Poqtyval = ""
           Giino = Gino
           If Giqty = "" Then Std_Cost = Cost Else Std_Cost = Cost / Giqty
           Uqty = tr_qty
           ucost = Cost
           'Uqty = Qty & chr(253) & Sernos & chr(253) & Cost & chr(253) & Tr_Conv
           If Gino <> "" Then Uqty = "":  ucost = Cost - Clr_Cost ' Uqty = chr(253) & chr(253) & Cost - Clr_Cost & chr(253) & Giqty
           'If Costbywgt And Giwgt Then Uqty = Uqty & chr(253) & Giwgt
        Else
           Poqtyval = tr_qty & Chr(253) & Po_Cost
           If Gino = "" Then Giino = "" Else Giino = Client_No & "*" & Gino
           If Giqty = "" Then Uqty = "": Std_Cost = -Cost Else Uqty = -qty: Std_Cost = Cost / Giqty
           'Uqty = Uqty & chr(253) & Sernos & chr(253) & -Cost & chr(253) & Tr_Conv
           ucost = -Cost: uconv = tr_conv
           If Gino <> "" Then Uqty = "":  ucost = -(Cost - Clr_Cost)  'Uqty = chr(253) & chr(253) & -(Cost - Clr_Cost) & chr(253) & Tr_Conv
           If Costbywgt And Giwgt Then Giwgt = -Giwgt 'Uqty = Uqty & chr(253) & -Giwgt
        End If
        If Avcost = 2 And Gino = "" Then Std_Cost = Avstdcost
        Sbcuords = "": Sbcuqtys = ""
        If Avcost = 2 And Gino <> "" Then GoTo 581
        If Gino <> "" And Valvar <> "" Then GoTo 581
        If Avcost And Gino <> "" And Cost = Clr_Cost Then GoTo 581
        Call SR2500(database, eom, TRANS_INFO, Poqtyval, INV(1), tr_prod, Total_Poss_Sva, Tr_Inv_Rev, INV(0), pick.ICONV(Format$(Now, "DD MMM YY"), "D2"), Uqty, Sernos, ucost, tr_conv, Giwgt, Cost, Std_Cost, Total_Cost, "", INV(21), "", Total_Std_Sva, 0, "", "", "", "", Giino, Pono, Sbcuords, Sbcuqtys, pline, err_flag)
        If Iscr Then Total_Cost = -Total_Cost: Total_Poss_Sva = -Total_Poss_Sva: Total_Std_Sva = -Total_Std_Sva
        If pline <> "" Then
           Pt_Line = INV(0) & " HAS NOT BEEN PROCESSED"
           For pp = 1 To 99
              Pt_Line = Left(Pt_Line & Space(40), 40) & pick.extract(pline, 1, pp, 0)
              If pick.extract(pline, 1, pp, 0) = "" Then GoTo 580
              GoSub 5000
           Next pp
           Redo_Batches = 1
        End If
580  'If err_flag Then Redo_Batches = 1: GoSub 6025: GoTo 100
581  If Gino <> "" Then Total_Cost = -Cost
        Valvar_Amt = Cost + Total_Cost
        If Valvar_Amt = 0 Then
           Sva_Amt = 0
        Else
           Sva_Amt = -Total_Std_Sva + Total_Poss_Sva
           Valvar_Amt = Valvar_Amt - Sva_Amt
        End If
        If Commit And Pono <> "" Then Gi_Cost = 0 Else Gi_Cost = Clr_Cost
        Total_Cost = -Total_Cost
        Total_Cost = Total_Cost - Gi_Cost
'
' STOCK  CONTROL
'
        If Total_Cost = 0 Then GoTo 640
        Tjac = Sc_Acct: Tjnarr = Tj_Narr: Tjjob = 0
        If Mid$(Valvar, 1, 1) = "." Then
           Valvar2 = INV(1) & Valvar
        Else
           If Mid$(Valvar, Len(Valvar), 1) = "." Then
              Valvar2 = Valvar & INV(1)
           Else
              'If Mid$(Valvar, Len(Valvar), 1) = "-" Then
              '   Valvar2 = Mid$(Valvar, 1, pick.Index(Valvar, ".", 2)) & INV(1) - pick.field(Valvar, ".", Mid$(3), 1, Len(pick.field(Valvar, ".", 3)) - 1)
              'Else
                 Valvar2 = Valvar
              'End If
           End If
        End If
        If Gino <> "" And Valvar <> "" Then Tjac = Valvar2
        If Total_Cost > 0 Then Tjcd = Tr_Inv_Rev: Tjcost = Total_Cost Else Tjcd = Tr_Invoice: Tjcost = -Total_Cost
        GoSub 777
'
' STOCK CLEARING
'
640     If Gi_Cost = 0 Then GoTo 650
        Tjac = Cl_Acct: Tjnarr = Tj_Narr: Tjjob = 0
        If Gi_Cost > 0 Then Tjcd = Tr_Inv_Rev: Tjcost = Gi_Cost Else Tjcd = Tr_Invoice: Tjcost = -Gi_Cost
        GoSub 777
'
' SVA ACCOUNT OR COST OF SALES (IF NO SVA)
'
650     If Sva_Amt <> 0 Then
           If Nosva Then Tjac = Cs_Acct Else Tjac = Sva_Acct
           Tjnarr = Tj_Narr: Tjjob = 0
           If Sva_Amt > 0 Then Tjcd = Tr_Inv_Rev: Tjcost = Sva_Amt Else Tjcd = Tr_Invoice: Tjcost = -Sva_Amt
           GoSub 777
        End If
'
' VALVAR
'
        If Valvar_Amt <> 0 Then
           Tjac = Valvar2: Tjnarr = Tj_Narr: Tjjob = 0
           If Valvar_Amt > 0 Then Tjcd = Tr_Inv_Rev: Tjcost = Valvar_Amt Else Tjcd = Tr_Invoice: Tjcost = -Valvar_Amt
           GoSub 777
        End If
680  Next RR
     'If Gst = 2 Then
        Gst_Inc = INV(50)
        If Gst_Inc = 0 Then Gross = Gross + INV(32)
     'Else
     '   Gross = Gross + INV(32) 'WCC
     'End If
'
'  UPDATE CREDITOR
'
300  If d3.d3_readstr(database, Cr_Rec, "CREDITOR", Client_No) <> 0 Then
        'Release CREDITOR_DATA, Client_No
        GoSub 6025 ' RECOVER UPDATES ALREADY DONE *
        Redo_Batches = 1
        Pt_Line = Inmsg & " " & Inv_No & "_ CREDITOR " & Client_No & " DOES NOT EXIST"
        GoSub 5000
        GoTo 9000
     End If
'$INSERT I.LOG.UPDATE '|CREDITOR|':CLIENT.NO 300 CR.REC
     Gl_Post = "": Gl_Post_Amt = ""
     For I = 1 To 999
        Flg = pick.extract(Tjdata(2), 1, I, 0)
        If Flg = "" Then GoTo 700
        If Flg = 0 Then
           If pick.extract(Tjdata(1), 1, I, 0) < 50 Then Sgnn = -1 Else Sgnn = 1
           If Iscr Then Sgnn = -Sgnn
           Gl_Post = pick.Insert(Gl_Post, 1, 1, -1, pick.extract(Tjdata(3), 1, I, 0))
           Gl_Post_Amt = pick.Insert(Gl_Post_Amt, 1, 1, -1, Sgnn * pick.extract(Tjdata(4), 1, I, 0))
        End If
     Next I
700  Tr_Narr = pick.oconv(INV(4), "D2"): Tr_Narr = Mid$(Tr_Narr, 1, 2) & Mid$(Tr_Narr, 4, 3) & Mid$(Tr_Narr, 8, 2)
     Tr_Narr = pick.trimm(INV(3) & " " & Tr_Narr)
     If pick.extract(INV(5), 1, 1, 0) <> "" Then
        Tr_Narr2 = "P/O " & pick.extract(INV(5), 1, 1, 0) & " "
     Else
        If pick.extract(INV(6), 1, 1, 0) <> "" Then
           Tr_Narr2 = "G/I " & pick.extract(INV(6), 1, 1, 0) & " "
        Else
           Tr_Narr2 = ""
        End If
     End If
     Select Case Narrflag
        Case Narrflag = 2: Tr_Narr = ""
        Case Narrflag = 1: Tr_Narr = Tr_Narr & " " & Tr_Narr2 & pick.extract(INV(12), 1, 1, 0)
     End Select
     If Iscr Then
        'If Openitem Then
        '   Useinvamt = pick.Replace(Useinvamt, 1, 1, 0, pick.extract(-Useinvamt, 1, 1, 0)): Useinvamt = pick.Replace(Useinvamt, 1, 5, 0, pick.extract(-Useinvamt, 1, 1, 0))
        '   Call SR340(INV(21), Client_No, "", Cr_Rec, Inv_No, INV(20), Useinvamt, Tr_Invoice, Tr_Narr, trans_info, "", Gl_Post, Gl_Post_Amt, "", Cred_Cont)
        'Else
        '   If d3.d3_readstr(database, Client_Rec, "CLIENT", Client_No) <> 0 Then Client_Rec = ""
        '   Call SR350(INV(21), Client_No, Client_Rec, "", Cr_Rec, Inv_No, INV(20), Useinvamt, Tr_Invoice, Tr_Narr, trans_info, Cred_Cont, Gl_Post, Gl_Post_Amt, "", "", "", "", "", "", "", "", "", "", Wh_Tax)
        'End If
     Else
        'If Invamt < 0 Then Useinvamt = pick.Replace(Useinvamt, 1, 5, 0, -Invamt): Trcd = Tr_Inv_Rev Else Trcd = Tr_Invoice
        'If Pps_Flg And pick.extractint(INV(29), 1, 1) Then Useinvamt = pick.Replace(Useinvamt, 1, 6, 0, "Y") ' pps indicator
'** Aus GST Mod
        If Gst = 2 Then
           If INV(34) = "W" Then
              Wh_Tax = Int((Invamt * Wh_Rate) / 10000)
           Else
              Wh_Tax = 0
           End If
           'If Multi_Company Then
           '   Cr_Cont_Accs = pick.extract(trans_info, 12, 0, 0) & chr(253) & pick.extract(trans_info, 13, 0, 0)
           '   Cr_Relation = pick.extract(Cr_Rec, 3, 0, 0) + 1
           '   Cr_Control = pick.extract(Cr_Cont_Accs, 1, Cr_Relation, 1)
           '   Group = pick.field(Cr_Control, ".", 1)
           '   No_Cos = Dpick.ccount(pick.extract(CO_REC, 1, 0, 0), chr(253))
           '   Cono = 0
           '   Ii = 0
           '   Loop
           '   WHILE CONO = 0 AND II < NO_COS DO
           '      Ii = Ii + 1
           '      IF GROUP >= PICK.EXTRACT(CO_REC,1,II,0) AND GROUP PICK.EXTRACT(,= CO_REC<2,II,0) THEN CONO = II
           '   Repeat
           '   If Cono = 0 Then Cono = 1
           '   Wh_Tax_Acc = pick.extract(Gst_Accs, 3, Cono, 0)
           'Else
              Wh_Tax_Acc = pick.extract(Gst_Accs, 3, 1, 0)
           'End If
           '???Call SR340_WH(INV(21), Client_No, "", Cr_Rec, Inv_No, INV(20), Useinvamt, Trcd, Tr_Narr, trans_info, "", Gl_Post, Gl_Post_Amt, "", Cred_Cont, Wh_Tax, Wh_Tax_Acc)
           Call SR340(logentry, Ldate, Client_No, Cr_Rec, Inv_No, Idate, "", Useinvamt, Totdisc, INV(28), INV(25), 0, 0, Trcd, Tr_Narr, Cr_Relation, Gl_Post, Gl_Post_Amt, "", Cred_Cont)
        Else
           Call SR340(logentry, Ldate, Client_No, Cr_Rec, Inv_No, Idate, "", Useinvamt, Totdisc, INV(28), INV(25), 0, 0, Trcd, Tr_Narr, Cr_Relation, Gl_Post, Gl_Post_Amt, "", Cred_Cont)
        End If
'** End of Mod
     End If
     Call d3.d3_writestr(database, "CREDITOR", Client_No, Cr_Rec)
'
'  TRANS.J
'
755  If d3.d3_readstr(database, Tj_Rec, "TRANS.J", Tj_Key) <> 0 Then Tj_Rec = "": GoTo 760
     If Glbatch = 0 Then
        'Release TRANS_J_DATA, Tj_Key
        Tj_Key = Tj_Key & 0
        GoTo 755
     End If
'$INSERT I.LOG.UPDATE '|TRANS.J|':TJ.KEY 755 TJ.REC
     GoTo 761
760
'$INSERT I.LOG.ADD '|TRANS.J|':TJ.KEY 755
'
761  If Invamt >= 0 Then
        Tjdata(1) = pick.Insert(Tjdata(1), 1, -1, 0, Tr_Invoice)
        Tjdata(4) = pick.Insert(Tjdata(4), 1, -1, 0, CStr(Invamt))
     Else
        Tjdata(1) = pick.Insert(Tjdata(1), 1, -1, 0, Tr_Inv_Rev)
        Tjdata(4) = pick.Insert(Tjdata(4), 1, -1, 0, -Invamt)
     End If
     Tjdata(2) = pick.Insert(Tjdata(2), 1, -1, 0, 0)
     Tjdata(3) = pick.Insert(Tjdata(3), 1, -1, 0, Cred_Cont)
     If Glbatch Then Tjnarr = Inmsg2 & " BATCH " & INV(3) Else Tjnarr = Tj_Narr
     Tjdata(6) = pick.Insert(Tjdata(6), 1, -1, 0, Tjnarr)
'GST
     If INV(32) <> "" Then
        If INV(32) >= 0 Then
           Tjdata(1) = pick.Insert(Tjdata(1), 1, -1, 0, Tr_Inv_Rev)
           Tjdata(4) = pick.Insert(Tjdata(4), 1, -1, 0, INV(32))
        Else
           Tjdata(1) = pick.Insert(Tjdata(1), 1, -1, 0, Tr_Invoice)
           Tjdata(4) = pick.Insert(Tjdata(4), 1, -1, 0, -INV(32))
        End If
        Tjdata(2) = pick.Insert(Tjdata(2), 1, -1, 0, 0)
        If Gst = 1 Then
'           READV GSTACCT FROM SALETAX_DATA,INV(34),4 ELSE GSTACCT="GST ACCT FOR CODE " & INV(34)
        Else
           'If Multi_Company Then
           '   Cr_Cont_Accs = pick.extract(trans_info, 12, 0, 0) & chr(253) & pick.extract(trans_info, 13, 0, 0)
           '   Cr_Relation = pick.extract(Cr_Rec, 3, 0, 0) + 1
           '   Cr_Control = pick.extract(Cr_Cont_Accs, 1, Cr_Relation, 1)
           '   Group = pick.field(Cr_Control, ".", 1)
           '   No_Cos = Dpick.ccount(pick.extract(CO_REC, 1, 0, 0), chr(253))
           '   Cono = 0
           '   Ii = 0
           '   Loop
           '   WHILE CONO = 0 AND II < NO_COS DO
           '      Ii = Ii + 1
           '      IF GROUP >= PICK.EXTRACT(CO_REC,1,II,0) AND GROUP PICK.EXTRACT(,= CO_REC<2,II,0) THEN CONO = II
           '   Repeat
           '   If Cono = 0 Then Cono = 1
           '   Gstacct = pick.extract(Gst_Accs, 1, Cono, 0)
           'Else
              Gstacct = pick.extract(Gst_Accs, 1, 1, 0)
           'End If
        End If
        Tjdata(3) = pick.Insert(Tjdata(3), 1, -1, 0, Gstacct)
        If Glbatch Then Tjnarr = Inmsg2 & " BATCH " & INV(3) Else Tjnarr = Tj_Narr
        Tjdata(6) = pick.Insert(Tjdata(6), 1, -1, 0, Tjnarr)
     End If
' END GST
' Aus GST - Dr Creditor with W/Holding Tax if no ABN
     If INV(34) = "W" Then
        If Wh_Tax >= 0 Then
           Tjdata(1) = pick.Insert(Tjdata(1), 1, -1, 0, "17")
           Tjdata(4) = pick.Insert(Tjdata(4), 1, -1, 0, CStr(Wh_Tax))
        Else
           Tjdata(1) = pick.Insert(Tjdata(1), 1, -1, 0, "82")
           Tjdata(4) = pick.Insert(Tjdata(4), 1, -1, 0, -Wh_Tax)
        End If
        Tjdata(2) = pick.Insert(Tjdata(2), 1, -1, 0, 0)
        Tjdata(3) = pick.Insert(Tjdata(3), 1, -1, 0, Wh_Tax_Acc)
        If Glbatch Then Tjnarr = Inmsg2 & " BATCH " & INV(3) Else Tjnarr = Tj_Narr
        Tjdata(6) = pick.Insert(Tjdata(6), 1, -1, 0, Tjnarr)
'       Now Post Other Side to Creditors Control
        If Wh_Tax >= 0 Then
           Tjdata(1) = pick.Insert(Tjdata(1), 1, -1, 0, "82")
           Tjdata(4) = pick.Insert(Tjdata(4), 1, -1, 0, CStr(Wh_Tax))
        Else
           Tjdata(1) = pick.Insert(Tjdata(1), 1, -1, 0, "17")
           Tjdata(4) = pick.Insert(Tjdata(4), 1, -1, 0, -Wh_Tax)
        End If
        Tjdata(2) = pick.Insert(Tjdata(2), 1, -1, 0, 0)
        Tjdata(3) = pick.Insert(Tjdata(3), 1, -1, 0, Cred_Cont)
        If Glbatch Then Tjnarr = Inmsg2 & " BATCH " & INV(3) Else Tjnarr = Tj_Narr
        Tjdata(6) = pick.Insert(Tjdata(6), 1, -1, 0, Tjnarr)
     End If
' End Aus GST W/Holding Tax Mod
     If Glbatch = 0 Then Tjdata(5) = Client_No: Tjdata(9) = Inv_No
     Tjdata(7) = INV(21)
     Tjdata(9) = Inv_No
     Tj_Rec2 = ""
     If Glbatch Then
        For I = 1 To 999
           Tjcd = pick.extract(Tjdata(1), 1, I, 0)
           If Tjcd = "" Then GoTo 769
           If pick.extract(Tjdata(2), 1, I, 0) = 1 Then GoTo 766
           For Ii = 1 To 999
              Tjcdd = pick.extract(Tj_Rec, 1, Ii, 0)
              If Tjcdd = "" Then GoTo 765
              If Tjcd = Tjcdd And pick.extract(Tjdata(2), 1, I, 0) = pick.extract(Tj_Rec, 2, Ii, 0) And pick.extract(Tjdata(3), 1, I, 0) = pick.extract(Tj_Rec, 3, Ii, 0) And pick.extract(Tjdata(6), 1, I, 0) = pick.extract(Tj_Rec, 6, Ii, 0) Then
                 Tj_Rec = pick.Replace(Tj_Rec, 4, Ii, 0, pick.extract(Tj_Rec, 4, Ii, 0) + pick.extract(Tjdata(4), 1, I, 0))
                 GoTo 768
              End If
           Next Ii
765        Tj_Rec = pick.Insert(Tj_Rec, 1, 1, 0, Tjcd)
           Tj_Rec = pick.Insert(Tj_Rec, 2, 1, 0, pick.extract(Tjdata(2), 1, I, 0))
           Tj_Rec = pick.Insert(Tj_Rec, 3, 1, 0, pick.extract(Tjdata(3), I, I, 0))
           Tj_Rec = pick.Insert(Tj_Rec, 4, 1, 0, pick.extract(Tjdata(4), I, I, 0))
           Tj_Rec = pick.Insert(Tj_Rec, 6, 1, 0, pick.extract(Tjdata(6), I, I, 0))
           If pick.extract(Tjdata(2), I, I, 0) = 1 Then Tj_Rec = pick.Insert(Tj_Rec, 5, 1, 0, Client_No) Else Tj_Rec = pick.Insert(Tj_Rec, 5, 1, 0, "")
           GoTo 768
766  '*** SETUP REC FOR SEPERATE JOB_L TRANS_J REC
           Tj_Rec2 = pick.Insert(Tj_Rec2, 1, 1, 0, Tjcd)
           Tj_Rec2 = pick.Insert(Tj_Rec2, 2, 1, 0, pick.extract(Tjdata(2), I, I, 0))
           Tj_Rec2 = pick.Insert(Tj_Rec2, 3, 1, 0, pick.extract(Tjdata(3), I, I, 0))
           Tj_Rec2 = pick.Insert(Tj_Rec2, 4, 1, 0, pick.extract(Tjdata(4), I, I, 0))
           Tj_Rec2 = pick.Insert(Tj_Rec2, 6, 1, 0, pick.extract(Tjdata(6), I, I, 0))
           If pick.extract(Tjdata(2), I, I, 0) = 1 Then Tj_Rec2 = pick.Insert(Tj_Rec2, 5, 1, 0, Client_No) Else Tj_Rec2 = pick.Insert(Tj_Rec2, 5, 1, 0, "")
768     Next I
769     Tj_Rec = pick.Replace(Tj_Rec, 7, 0, 0, INV(21))
        Tj_Rec = pick.Replace(Tj_Rec, 9, 0, 0, Inv_No)
        Call d3.d3_writestr(database, "TRANS_J", Tj_Key, Tj_Rec)
        If Tj_Rec2 <> "" Then
           Tj_Key2 = INV(7)
'
770      If d3.d3_readstr(database, Tj_Rec, "TRANS.J", Tj_Key2) <> 0 Then Tj_Rec = "": GoTo 771
           'Release TRANS_J_DATA, Tj_Key2
           Tj_Key2 = Tj_Key2 & 0
           GoTo 770
'$INSERT I.LOG.UPDATE '|TRANS.J|':TJ.KEY2 770 TJ.REC
           GoTo 772
771
'$INSERT I.LOG.ADD '|TRANS.J|':TJ.KEY2 770
'
772        Tj_Rec2 = pick.Replace(Tj_Rec2, 7, 0, 0, INV(21))
           Tj_Rec2 = pick.Replace(Tj_Rec2, 9, 0, 0, Inv_No)
           Call d3.d3_writestr(database, "TRANS_J", Tj_Key2, Tj_Rec2)
        End If
     Else
        wterr = d3.d3_writemat(database, "TRANS_J", Tjdata())
     End If
'
'     For I = 1 To 999
'        Tjcd = pick.extract(tjdata(1), i,i,0)
'        If Tjcd = "" Then GoTo 400
'        Tjac = pick.extract(tjdata(3), i,i,0) & "?" & Tjcd
'        If pick.extract(tjdata(2), i,i,0) = 1 Then Tjac = "?" & Tjac
'        LOCATE(TJAC,SUMM(1),1,1,0,II,"") ELSE
'           SUMM(1) = pick.insert(SUMM(1), 1, Ii, 0, Tjac)
'           SUMM(2) = pick.insert(SUMM(2), 1, Ii, 0, pick.extract(tjdata(4), i,i,0))
'           GoTo 395
'        End If
'        SUMM(2) = replace(SUMM(2), 1, Ii, 0, SUMM(pick.extract(2), 1, Ii) + pick.extract(tjdata(4), i,i,0))
'395  Next I
'
' WRITE NEW INVOICE
'
400  If d3.d3_readstr(database, Ans, "CR.INV", INV(0)) <> 0 Then GoTo 410
     'Release CR_INV_DATA, INV(0)
     'Pt_Line = Inmsg & " " & INV(0) & " ALREADY EXISTS ON FILE_ CANNOT PROCESS TWICE"
     'GoSub 5000
     GoSub 6025 '* RECOVER UPDATES ALREADY DONE **
     Redo_Batches = 1
     GoTo 9000
410
'     If Iscr Then
'        Lgid = "|CR_CREDIT|" & inv(0)
'     Else
'        Lgid = "|CR_INV|" & inv(0)
'     End If
'$INSERT I.LOG.ADD LGID 400
     For I = INV(9) To 1 Step -1
        If pick.extractint(INV(11), 1, I, 0) = 0 And pick.extractint(INV(14), 1, I, 0) = 0 Then
           For J = 5 To 6
              INV(J) = pick.delet(INV(J), 1, I, 0)
           Next J
           For J = 10 To 18
              INV(J) = pick.delet(INV(J), 1, I, 0)
           Next J
           INV(23) = pick.delet(INV(23), 1, I, 0)
           If Iscr = 0 Then
              INV(26) = pick.delet(INV(26), 1, I, 0)
              INV(27) = pick.delet(INV(27), 1, I, 0)
           End If
           'If Auth_Flag Then  'WCC
           '   INV(30) = pick.delet(INV(30), 1, I, 0) 'WCC
           '   INV(35) = pick.delet(INV(35), 1, I, 0) 'WCC
           '   INV(36) = pick.delet(INV(36), 1, I, 0) 'WCC
           'Else
              If Gst = 2 Then INV(36) = pick.delet(INV(36), 1, I, 0)
           'End If
           If Commit Then INV(40) = pick.delet(INV(40), 1, I, 0)
           INV(9) = INV(9) - 1
        End If
     Next I
     wterr = d3.d3_writemat(database, "CR_INV", INV)
' SNOS=''; QTYS=''
     If Iscr = 0 Then
        For I = 1 To INV(9)
           Ass = pick.extract(INV(37), 1, I, 0)
           If Ass <> "" Then
              If d3.d3_readstr(database, ass_rec, "ASSET.NEW", Ass) <> 0 Then GoTo 455
              If d3.d3_readstr(database, ass_rec2, "ASSET", Ass) <> 0 Then
                 Call d3.d3_writestr(database, "ASSET", Ass, ass_rec)
                 Pt_Line = "Asset " & Ass & " has been added to the asset register_ Invoice " & INV(0): GoSub 5000
                 GoTo 454
              End If
              Pt_Line = "Asset " & Ass & " was meant to have been added to asset register, but already exists! Check": GoSub 5000
454        wterr = d3.d3_delete(database, "ASSET.NEW", Ass)
           End If
           Gikey = pick.extract(INV(6), 1, I, 0)
           If Gikey = "" Then
'              IF NOT(ISCR) THEN
'                 SNOS<1,-1>=INV(10)<1,I>
'                 QTYS<1,-1>=INV(13)<1,I>
'              END
           End If
455     Next I
     End If
'
' Delete invoice registration item. and print authorisation forms if required.
'
     'If Auth_Flag Then
     '   If Afs Then Call SR7145(inv(0))  'WCC - PRINTS AUTHORISATION FORM
     '   Delete INV_AUTH, inv(0) 'WCC - DELETE REGISTRATION ITEM
     'End If
'
' END OF UPDATING
'
'$INSERT I.QU
'
9000:
   Next kk

'
' SUBROUTINE TO PRINT FINAL TOTALS
'
     'Pt_Line = Pt_Line & Right(Space(5) & Ct, 5) & " " & Inmsg & "S_ TOTAL VALUE " & Right(Space(13) & pick.oconv(Baval, "MD2"), 13)
     'IF NUMBATCH<>3 THEN PT_LINE= PT_LINE & "_ GROSS VALUE " & Right(Space() & pick.oconv(GROSS,"MD2"),)
     'If Bval Then
        'PT_LINE= PT_LINE & "_ OPERATOR " & Right(Space() & pick.oconv(BATCHVAL,"MD2"),)
     '   If Numbatch = 3 Then USEVAL = Baval Else USEVAL = Gross
     '   If USEVAL <> Batchval Then
     '      Pt_Line = Pt_Line & "_ ERROR " & pick.oconv(USEVAL - Batchval, "MD2")
     '   End If
     'End If
     'GoSub 5000
     Tct = Tct + Ct: Tbaval = Tbaval + Baval: Tgross = Tgross + Gross: Tnetval = Tnetval + Netval: Tbatchval = Tbatchval + Batchval: Tbct = Tbct + 1
     'If Bval And Auto Then GoTo 190
     'GoSub 5000
     'GoSub 5000
     'Pt_Line = Left("ACCOUNT/" & Space(15), 15) & Left(" " & Space(35), 35) & Right(Space(15) & " G/L ", 15) & Right(Space(15) & " G/L ", 15)
     If Jobcost Then Pt_Line = Pt_Line & Right(Space(15) & "JOB ", 15) & Right(Space(15) & "JOB ", 15)
     GoSub 5000
     Pt_Line = Left("JOB NO_" & Space(15), 15) & Left("DESCRIPTION" & Space(35), 35) & Right(Space(15) & "DEBIT", 15) & Right(Space(15) & "CREDIT", 15)
     If Jobcost Then Pt_Line = Pt_Line & Right(Space(15) & "DEBIT", 15) & Right(Space(15) & "CREDIT", 15)
     If Gst = 1 Then Pt_Line = Pt_Line & Right(Space(15) & "GST ADJUSTMENT", 15)
     GoSub 5000
     Pt_Line = "-------------- ----------------------------------- -------------- --------------"
     If Jobcost Then
        Pt_Line = Pt_Line & " -------------- --------------"
     End If
     If Gst = 1 Then Pt_Line = Pt_Line & " ---------------"
     GoSub 5000
     Sum1 = 0: Sum2 = 0: Sum3 = 0: Sum4 = 0
     For I = 1 To 999
        Tjac = pick.extract(SUMM(1), 1, I, 0)
        If Tjac = "" Then GoTo 102
        If Mid$(Tjac, 1, 1) = "?" Then Tjob = 1: Tjac = Mid$(Tjac, 2, 99) Else Tjob = 0
        Tjcd = pick.field(Tjac, "?", 2): Tjac = pick.field(Tjac, "?", 1)
        Amt = pick.extract(SUMM(2), 1, I, 0)
'        If Tjob Then
'           READV PT_LINE FROM JOB_L_DATA,TJAC,2 ELSE PT_LINE="??"
'        Else
'            READV PT_LINE FROM GEN_L_DATA,TJAC,2 ELSE PT_LINE="??"
'        End If
        Pt_Line = Left(Tjac & Space(15), 15) & Left(Pt_Line & Space(35), 35)
        If Tjob = 1 Then Pt_Line = Pt_Line & Space(30)
        If Tjcd < 50 Then
           If Tjob Then Sum4 = Sum4 + Amt Else Sum2 = Sum2 + Amt
           Pt_Line = Pt_Line & Space(15)
        Else
           If Tjob Then Sum3 = Sum3 + Amt Else Sum1 = Sum1 + Amt
        End If
'        PT_LINE= PT_LINE & Right(Space() & pick.oconv(AMT,"MD2"),)
'        If Gst = 1 Then  'WCC
'           LOCATE(TJAC,GST_ADJ,1,0,0,GL_POS,"") ELSE GL_POS=0  'WCC
'           If Gl_Pos Then  'WCC
'              Gst_Adjustment = pick.extract(Gst_Adj, 2, Gl_Pos, 0) 'WCC
'              ***SUM5=SUM5+GST_ADJUSTMENT  'WCC
'           Else  'WCC
'              Gst_Adjustment = "" 'WCC
'           End If 'WCC
'           Pt_Line = Left(Pt_Line & Space(110), 110) & Right(Space(15) & pick.oconv(Gst_Adjustment, "MD2"), 15)
'        End If 'WCC
        GoSub 5000
     Next I
102  Pt_Line = Space(51) & "-------------- --------------"
     If Jobcost Then
        Pt_Line = Pt_Line & " -------------- --------------"
     End If
     GoSub 5000
'     PT_LINE= SPACE(50) & Right(Space() & pick.oconv(SUM1,"MD2"),) & Right(Space() & pick.oconv(SUM2,"MD2"),)
'     If Jobcost Then
'        PT_LINE= PT_LINE & Right(Space() & pick.oconv(SUM3,"MD2"),) & Right(Space() & pick.oconv(SUM4,"MD2"),)
'     End If
'     GoSub 5000
     Pt_Line = Space(51) & "============== =============="
     If Jobcost Then
        Pt_Line = Pt_Line & " ============== =============="
     End If
     GoSub 5000
190
     Exit Function
'
6025
'$INSERT I.QU.REC
     Return
'
'*************************
' S/R 5000 - Print Routine
'*************************
5000 Return

End Function



Public Sub SR2503(TRANS_INFO As String, Cl_Acct As String, BNO As String, Prod As String)
'
' FIND GOODSIN CLEARING ACCOUNT FOR LEDGER LINES
'
Dim Library
     
     Library = pick.extract(TRANS_INFO, 132, 0, 0) + 0
'
     If Prod <> "" Then
        If Mid$(Prod, 1, 3) = "JOB" Then
           Cl_Acct = pick.extract(TRANS_INFO, 100, 2, 0)
           If Cl_Acct = "" Then Cl_Acct = pick.extract(TRANS_INFO, 100, 1, 0)
        Else
           Cl_Acct = pick.extract(TRANS_INFO, 100, 1, 0)
        End If
     Else
        If Library Then
           Cl_Acct = pick.extract(TRANS_INFO, 100, 5, 0)
           Prod = pick.extract(TRANS_INFO, 100, 6, 0)
           If Mid$(Prod, 1, 1) = "_" Then Prod = BNO & Prod
           If Prod = "" Then Prod = "GI100,6"
        Else
           Cl_Acct = pick.extract(TRANS_INFO, 100, 3, 0)
           Prod = pick.extract(TRANS_INFO, 100, 4, 0)
           If Mid$(Prod, 1, 1) = "_" Then Prod = BNO & Prod
           If Prod = "" Then Prod = "GI100,4"
        End If
     End If
     If Mid$(Cl_Acct, 1, 1) = "_" Then Cl_Acct = BNO & Cl_Acct
     If Cl_Acct = "" Then Cl_Acct = "GICLR"

End Sub

