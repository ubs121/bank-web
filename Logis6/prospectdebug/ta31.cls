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
Attribute VB_Exposed = False
Option Explicit
Option Compare Text

Private ckaiis As New ckaiis
Private d3 As New d3
Private Pick As New Pick

Private g_trans_info_array() As String




Public Function ta3131(logentry As String, nrec() As String, parms As String) As String
' TA3131 PRINT MONTHLY BUILDING STATISTICS REPORT
Dim statsby As String, Fd As Integer
Dim Td As Integer, Fees As String, Fcnt As Integer, File_Desc, I As Integer, Fc As String, px As String, Types As String, maxt
Dim Stats As String, Assess As String, Ward As String, typ As String
Dim value As Currency, Feevalue As Currency, Pos As Integer, pos2 As Integer, Maxw As Integer, Gtot As String, Stot As String
Dim Stot2 As String, k As Integer, desc As String
Dim J As Integer
Dim kk As Integer, sentence As String, total_items As Long, plan_id As String
Dim plans_rec As String, Attr As Integer
Dim rderr As Integer, temp As String, mylist() As String, pick_cnt As Long, cols As Integer
Dim database As String, temp2 As String, tempcur As Currency, Mm As Integer, ncols As Integer
'???fees have to be int(+.5)
     database = Pick.extract(logentry, 2, 0, 0)
     
     Fd = CInt(Pick.extract(parms, 1, 0, 0)) 'iconv
     Td = CInt(Pick.extract(parms, 2, 0, 0)) 'iconv
     statsby = Pick.extract(parms, 3, 0, 0)
     Fees = Pick.extract(parms, 4, 0, 0)
     Fcnt = Pick.dcount(Fees, Chr(253))
     
     ReDim nrec(10)
     nrec(3) = Format$(Now, "DD MMM YY")

     If statsby = "bl_work" Then Attr = 4 Else Attr = 5
     maxt = d3.d3_select(logentry, "SSELECT " & statsby & " BY a0", mylist(), pick_cnt, 0, 0) - 1
     For kk = 0 To maxt
        If d3.d3_readstr(database, desc, statsby, mylist(kk)) = 0 Then
           Types = Pick.insert(Types, 1, 1, -1, mylist(kk))
           Types = Pick.insert(Types, 1, 2, -1, desc)
        End If
     Next kk

40   sentence = "SELECT PLANS WITH 19 >= """ & Fd & """ AND WITH 19 <= """ & Td & """"

300  Stats = ""
     database = Pick.extract(logentry, 2, 0, 0)

   total_items = d3.d3_select(logentry, sentence, mylist(), pick_cnt, 0, 0) - 1

   For kk = 0 To total_items
     plan_id = mylist(kk)
     If d3.d3_readstr(database, plans_rec, "PLANS", plan_id) <> 0 Then GoTo 310
     If Pick.extract(plans_rec, 19, 0, 0) = "" Then GoTo 310
     If Pick.extract(plans_rec, 30, 0, 0) <> "" Then GoTo 310
     Assess = Pick.extract(plans_rec, 1, 0, 0)
     If d3.d3_readstr(database, Ward, "PROPERTY", Assess, 38) <> 0 Then Ward = ""
     If Ward = "" Then Ward = Assess & " ward missing from assessment"
     typ = Pick.extract(plans_rec, Attr, 1, 0)
     If statsby = "bl_structure" Then
        If d3.d3_readstr(database, typ, "BL_BUILDING", typ, 3) <> 0 Then typ = ""
     End If
     If typ = "" Then typ = typ & " missing"
     temp = Pick.extract(plans_rec, 16, 0, 0)
     If IsNumeric(temp) Then value = CCur(temp) Else value = 0
     Feevalue = 0
     For I = 1 To Fcnt
        Fc = Pick.extract(Fees, 1, I, 0)
        If Pick.locate(Fc, plans_rec, 22, 1, 0, Pos, "") <> 0 Then
        'LOCATE(FC,PLANS_REC,22,1,0,POS,"") ELSE POS=0
           temp = Pick.extract(plans_rec, 23, Pos, 0)
           If IsNumeric(temp) Then Feevalue = Feevalue + CCur(temp)
        End If
     Next I
     If Pick.locate(Ward, Stats, 1, 1, 0, Pos, "AL") = 0 Then
        Stats = Pick.insert(Stats, 1, Pos, 0, Ward)
        Stats = Pick.insert(Stats, 2, Pos, 0, Pick.extract(Types, 1, 1, 0))
        Stats = Pick.insert(Stats, 3, Pos, 0, "0")
        Stats = Pick.insert(Stats, 4, Pos, 0, "0")
        Stats = Pick.insert(Stats, 5, Pos, 0, "0")
     End If
     If Pick.locate(typ, Stats, 2, Pos, 1, pos2, "") = 0 Then pos2 = maxt
     'LOCATE(typ,STATS,2,POS,0,POS2,"") ELSE POS2=MAXT
     temp = Pick.extract(Stats, 3, Pos, pos2)
     If IsNumeric(temp) Then temp = CStr(CCur(temp)) + 1 Else temp = "1"
     Stats = Pick.replace(Stats, 3, Pos, pos2, temp)
     temp = Pick.extract(Stats, 4, Pos, pos2)
     If IsNumeric(temp) Then tempcur = CCur(temp) Else tempcur = 0
     tempcur = tempcur + value
     Stats = Pick.replace(Stats, 4, Pos, pos2, CStr(tempcur))
     temp = Pick.extract(Stats, 5, Pos, pos2)
     If IsNumeric(temp) Then tempcur = CCur(temp) Else tempcur = 0
     tempcur = tempcur + Feevalue
     Stats = Pick.replace(Stats, 5, Pos, pos2, CStr(tempcur))
310  Next kk
     GoSub 900
     nrec(5) = "<TH colspan=" & ncols + 1 & ">Building Statistics from " & Format(Pick.date_pick_to_vb(Fd), "dd mmm yy") & " to " & Format(Pick.date_pick_to_vb(Td), "dd mmm yy")
     Exit Function
'
900  Maxw = Pick.dcount(Pick.extract(Stats, 1, 0, 0), Chr(253))
     Gtot = "": Stot = "": Stot2 = ""
     nrec(4) = "": ncols = 0
     If Fcnt Then cols = 3 Else cols = 2

        nrec(2) = "<TH>Type of " & Mid(statsby, 4) 'remove bl_ in front of file name
        nrec(1) = "<TH>Wards"

        ncols = cols
        For k = 1 To Maxw
           If d3.d3_readstr(database, desc, "AREA", Pick.extract(Stats, 1, k, 0), 1) <> 0 Then desc = Pick.extract(Stats, 1, k, 0)
           ncols = ncols + cols
           nrec(1) = nrec(1) & "<TH colspan=" & cols & ">" & desc
           nrec(2) = nrec(2) & "<TH>Value"
           If Fcnt Then nrec(2) = nrec(2) & "<TH>Fees"
           nrec(2) = nrec(2) & "<TH>Number"
        Next k
        nrec(1) = nrec(1) & "<TH colspan=" & cols & ">All Wards"
        nrec(2) = nrec(2) & "<TH>Value"
        If Fcnt Then nrec(2) = nrec(2) & "<TH>Fees"
        nrec(2) = nrec(2) & "<TH>Number"
        For J = 1 To maxt
           nrec(4) = nrec(4) & "<TR CLASS=""mm""><TD>" & Pick.extract(Types, 1, 2, J)
           For k = 1 To Maxw
              temp = Pick.extract(Stats, 4, k, J)
              If IsNumeric(temp) Then temp = Format(CCur(temp) / 100, "#.00") Else temp = "&nbsp;"
              nrec(4) = nrec(4) & "<TD align=right>" & temp
              If Fcnt Then
                 temp = Pick.extract(Stats, 5, k, J)
                 If IsNumeric(temp) Then temp = CStr(Int(CCur(temp) / 100 + 0.5)) Else temp = "&nbsp;"
                 nrec(4) = nrec(4) & "<TD align=right>" & temp
              End If
              nrec(4) = nrec(4) & "<TD align=right>" & "&nbsp;" & Pick.extract(Stats, 3, k, J)
              For Mm = 1 To 3
                 temp = Pick.extract(Stot, Mm, J, 0)
                 Select Case Mm
                    Case 1: temp2 = Pick.extract(Stats, 4, k, J)
                    Case 2: temp2 = Pick.extract(Stats, 3, k, J)
                    Case 3: temp2 = Pick.extract(Stats, 5, k, J)
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
                 Stot = Pick.replace(Stot, Mm, J, 0, CStr(tempcur))
                 
                 temp = Pick.extract(Gtot, Mm, k, 0)
                 Select Case Mm
                    Case 1: temp2 = Pick.extract(Stats, 4, k, J)
                    Case 2: temp2 = Pick.extract(Stats, 3, k, J)
                    Case 3: temp2 = Pick.extract(Stats, 5, k, J)
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
                 Gtot = Pick.replace(Gtot, Mm, k, 0, CStr(tempcur))
              Next Mm
           Next k
           temp = Pick.extract(Stot, 1, J, 0)
           If IsNumeric(temp) Then temp = Format(CCur(temp) / 100, "#.00") Else temp = "&nbsp;"
           nrec(4) = nrec(4) & "<TD align=right>" & temp
           If Fcnt Then
              temp = Pick.extract(Stot, 3, J, 0)
              If IsNumeric(temp) Then temp = CStr(Int(CCur(temp) / 100 + 0.5)) Else temp = "&nbsp;"
              nrec(4) = nrec(4) & "<TD align=right>" & temp
           End If
           nrec(4) = nrec(4) & "<TD align=right>" & "&nbsp;" & Pick.extract(Stot, 2, J, 0)
        Next J
        nrec(4) = nrec(4) & "<TR CLASS=totals><TD>" & "Totals"
        For k = 1 To Maxw
           temp = Pick.extract(Gtot, 1, k, 0)
           If IsNumeric(temp) Then temp = Format(CCur(temp) / 100, "#.00") Else temp = "&nbsp;"
           nrec(4) = nrec(4) & "<TD align=right>" & temp
           If Fcnt Then
              temp = Pick.extract(Gtot, 3, k, 0)
              If IsNumeric(temp) Then temp = CStr(Int(CCur(temp) / 100 + 0.5)) Else temp = "&nbsp;"
              nrec(4) = nrec(4) & "<TD align=right>" & temp
           End If
           nrec(4) = nrec(4) & "<TD align=right>" & "&nbsp;" & Pick.extract(Gtot, 2, k, 0)
           For Mm = 1 To 3
              temp = Pick.extract(Stot2, Mm, 0, 0)
              If IsNumeric(temp) Then tempcur = CCur(temp) Else tempcur = 0
              If IsNumeric(Pick.extract(Gtot, Mm, k, 0)) Then tempcur = tempcur + CCur(Pick.extract(Gtot, Mm, k, 0))
              Stot2 = Pick.replace(Stot2, Mm, 0, 0, CStr(tempcur))
           Next Mm
        Next k
        temp = Pick.extract(Stot2, 1, 0, 0)
        If IsNumeric(temp) Then temp = Format(CCur(temp) / 100, "#.00") Else temp = "&nbsp;"
        nrec(4) = nrec(4) & "<TD align=right>" & temp
        If Fcnt Then
           temp = Pick.extract(Stot2, 3, 0, 0)
           If IsNumeric(temp) Then temp = CStr(Int(CCur(temp) / 100 + 0.5)) Else temp = "&nbsp;"
           nrec(4) = nrec(4) & "<TD align=right>" & temp
        End If
        nrec(4) = nrec(4) & "<TD align=right>" & "&nbsp;" & Pick.extract(Stot2, 2, 0, 0)

     Return

End Function


Public Function ta3133(logentry As String, nrec() As String, parms As String) As String
' TA3133 PRINT MONTHLY BUILDING REVENUE REPORT
Dim date1 As String, date2 As String, Ct As Integer, sct As Integer
Dim Fees As String, Fcnt As Integer, Fc As String, I As Integer, Addr As String
Dim Iprog As Currency, Totv As Currency, Totf As Currency, Stotv As Currency, Stotf As Currency, Save_Ward As String
Dim Assess As String, typ As String, Ward As String, Client_Rec As String, typ_desc As String
Dim value As Currency, Fmax As Integer, Fee_Amt As Currency, J As Integer
Dim plan_id As String, plan_rec As String, need_and As Integer, ctr As Integer
Dim mylist() As String, pick_cnt As Long, database As String, total_items As Long
Dim temp As String, rderr As Integer, Msg As String, kk As Integer, plans_rec As String

     ReDim nrec(19)
     date1 = Pick.extract(parms, 1, 0, 0)
     If date1 <> "" Then date1 = Format(Pick.date_pick_to_vb(date1), "dd mmm yyyy")
     date2 = Pick.extract(parms, 2, 0, 0)
     If date2 <> "" Then date2 = Format(Pick.date_pick_to_vb(date2), "dd mmm yyyy")
     temp = Pick.extract(parms, 3, 0, 0)
     If IsNumeric(temp) Then Iprog = CCur(temp) Else Iprog = -1
     Fees = Pick.extract(parms, 4, 0, 0)
     Fcnt = Pick.dcount(Fees, Chr(253))
     
     nrec(19) = "Print Building Valuation Revenue for applications completed "
     If date1 <> "" Then nrec(19) = nrec(19) & " from " & date1
     If date2 <> "" Then nrec(19) = nrec(19) & " to " & date2

     Ct = 0: Totv = 0: Totf = 0
     sct = 0: Stotv = 0: Stotf = 0
     Save_Ward = ""

     Msg = "SSELECT PLANS BY WARD BY BTYPE ": need_and = 0
     If date1 <> "" Then Msg = Msg & "WITH APPLIC.DATE >= """ & date1 & """": need_and = 1
     If date2 <> "" Then
        If need_and Then Msg = Msg & " AND "
        Msg = Msg & " WITH APPLIC.DATE <= """ & date2 & """": need_and = 1
     End If

     database = Pick.extract(logentry, 2, 0, 0)

   total_items = d3.d3_select(logentry, Msg, mylist(), pick_cnt, 0, 0) - 1
   ctr = 0
   
   For kk = 0 To total_items
     plan_id = mylist(kk)
     If d3.d3_readstr(database, plans_rec, "PLANS", plan_id) <> 0 Then plans_rec = ""
     If Pick.extract(plans_rec, 19, 0, 0) = "" Then GoTo 180
     Assess = Pick.extract(plans_rec, 1, 0, 0)
     typ = Pick.extract(plans_rec, 5, 1, 0)
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
     temp = Pick.extract(plans_rec, 16, 0, 0)
     If IsNumeric(temp) Then value = CCur(temp) Else value = 0
     Fmax = Pick.dcount(Pick.extract(plans_rec, 22, 0, 0), Chr(253))
     Fee_Amt = 0
     For I = 1 To Fmax
        Fc = Pick.extract(plans_rec, 22, I, 0)
        If Fees = "" Then
           temp = Pick.extract(plans_rec, 23, I, J)
           If IsNumeric(temp) Then Fee_Amt = Fee_Amt + CCur(temp)
        Else
           For J = 1 To Fcnt
              If Fc = Pick.extract(Fees, 1, J, 0) Then
                 temp = Pick.extract(plans_rec, 23, I, 0)
                 If IsNumeric(temp) Then Fee_Amt = Fee_Amt + CCur(temp)
              End If
           Next J
        End If
     Next I
     ctr = ctr + 1
     nrec(1) = Pick.replace(nrec(1), 1, ctr, 0, plan_id)
     nrec(2) = Pick.replace(nrec(2), 1, ctr, 0, Addr)
     nrec(3) = Pick.replace(nrec(3), 1, ctr, 0, typ_desc)
     nrec(4) = Pick.replace(nrec(4), 1, ctr, 0, CStr(value))
     nrec(5) = Pick.replace(nrec(5), 1, ctr, 0, CStr(Fee_Amt))
     nrec(6) = Pick.replace(nrec(6), 1, ctr, 0, Ward)
     nrec(7) = Pick.replace(nrec(7), 1, ctr, 0, "1")
     Stotv = Stotv + value: Stotf = Stotf + Fee_Amt: sct = sct + 1
180:
   Next kk
   
   GoSub 200
   ctr = ctr + 1
   nrec(1) = Pick.replace(nrec(1), 1, ctr, 0, " ")
   nrec(2) = Pick.replace(nrec(2), 1, ctr, 0, "Period total (" & Ct & ")")
   nrec(4) = Pick.replace(nrec(4), 1, ctr, 0, CStr(Totv))
   nrec(5) = Pick.replace(nrec(5), 1, ctr, 0, CStr(Totf))
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
Dim Name As String, I As Integer, J As Integer, Fc As String, Build As String, Gl As String, Amt As String
Dim database As String, plans_rec As String, the_rec As String
Dim mylist() As String
Dim pick_cnt As Long
Dim total_items As Integer
Dim kk As Integer
Dim td_rec As String
Dim Line1 As String
Dim Line2 As String

    database = Pick.extract(logentry, 2, 0, 0)
    total_items = d3.d3_select(logentry, "SSELECT PLANS", mylist(), pick_cnt, 0, 0)
    totamt = 0

    the_rec = "<TH>Plan<TH>Builder<TH>Assess"
    
    For kk = 0 To total_items - 1
        If d3.d3_readstr(database, plans_rec, "PLANS", mylist(kk)) = 0 Then
            If Pick.extract(plans_rec, 19, 0, 0) <> "" And Pick.extract(plans_rec, 20, 0, 0) = "" Then
                Assess = Pick.extract(plans_rec, 1, 0, 0)
                Client_No = Pick.extract(plans_rec, 2, 0, 0)
                Line1 = "<TR Class=mm>"
                Line2 = "<TR Class=mm><TD colspan=4 align=right>Amount"
                If d3.d3_readstr(database, td_rec, "TDEBTOR", Client_No) <> 0 Then
                    Assess = "Applicant (debtor) number " & Client_No & " does not exist for Plans No_ " & mylist(kk) ' PLAN_ID
                    Line1 = Line1 & "<TD colspan=3>" & Assess & "<TD align=right>Fee Codes"
                Else
                    If d3.d3_readstr(database, td_rec, "CLIENT", Client_No) <> 0 Then
                        Name = ""
                    Else
                        Name = Pick.extract(td_rec, 1, 0, 0)
                    End If
                    Line1 = Line1 & "<TD><A HREF=/prospect/asp/bi.asp?fn=plans&tn=plans&item=" & mylist(kk) & _
                        ">" & mylist(kk) & "</a><TD><A HREF=/prospect/asp/bi.asp?fn=client&tn=client&item=" & _
                        Client_No & ">" & Name & "</a><TD>" & Assess & "<TD align=right>Fee Codes"
                    I = 1: J = 1
                    Do While Pick.extract(plans_rec, 22, I, 1) <> ""
                        J = 1
                        Do While Pick.extract(plans_rec, 22, I, J) <> ""
                            Fc = Pick.extract(plans_rec, 22, I, J)
                            If d3.d3_readstr(database, Build, "BUILD.CODES", "@C_" & Fc) <> 0 Then Build = ""
                            Gl = Pick.extract(Build, 1, 1, 2)
                            If Gl <> "NO" Then
                                Amt = Pick.extract(plans_rec, 23, I, J)
                                If Amt <> "0" Then
                                    totamt = totamt + CLng(Amt)
                                    Line1 = Line1 & "<TD align=right>" & Fc
                                    Line2 = Line2 & "<TD align=right>" & Pick.oconv(Amt, "MD2")
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
    the_rec = the_rec & "<TR Class=mm><TD colspan=4 align=right><STRONG>Total Amount<TD align=right><STRONG>" & Pick.oconv(CStr(totamt), "MD2")
    TA3135 = the_rec
    
End Function




Public Function ta3148(logentry As String, nrec() As String, parms As String) As String
' TA3148 - Building Licence Application Reporting

Dim Yr As Integer, date1 As String, date2 As String, Id As String, Prec As String
Dim Mm As Integer, sentence As String, database As String, kk As Integer, tot As Currency
Dim mylist() As String, pick_cnt As Long, total_items As Long, Stats As String, Yy As Integer
Dim temp As String, rderr As Integer, I As Integer

     Yr = Pick.extract(parms, 1, 0, 0)
     If Yr > 2050 Then ta3148 = "": Exit Function
     If Yr < 1990 Then ta3148 = "": Exit Function
     
     ReDim nrec(15)
     
     date1 = "01 JAN " & Mid$(Yr, 3, 2): date2 = "31 DEC " & Mid$(Yr, 3, 2)
     nrec(15) = "All approved applications between " & date1 & " and " & date2
     sentence = "SSELECT PLANS BY COMPLETE.DATE WITH COMPLETE.DATE >= """ & date1 & """ AND WITH COMPLETE.DATE <= """ & date2 & """"

     database = Pick.extract(logentry, 2, 0, 0)

     total_items = d3.d3_select(logentry, sentence, mylist(), pick_cnt, 0, 0) - 1
     Stats = ""
     For kk = 0 To total_items
       Id = mylist(kk)
       If d3.d3_readstr(database, Prec, "PLANS", Id) <> 0 Then GoTo 180
       If Pick.extract(Prec, 19, 0, 0) = "" Then GoTo 180
       Mm = Month(Pick.date_pick_to_vb(Pick.extract(Prec, 19, 0, 0)))
       temp = Pick.extract(Stats, Mm, 0, 0)
       If IsNumeric(temp) Then tot = CCur(temp) + 1 Else tot = 1
       Stats = Pick.replace(Stats, Mm, 0, 0, CStr(tot))
180: Next kk

        tot = 0
        nrec(1) = Pick.replace(nrec(1), 1, 1, 0, CStr(Yr))
        For Yy = 1 To 12
           nrec(Yy + 1) = Pick.replace(nrec(Yy + 1), 1, 1, 0, " " & Pick.extract(Stats, Yy, 0, 0))
           tot = tot + Pick.extractcur(Stats, Yy, 0, 0)
        Next Yy
        Stats = Pick.replace(Stats, 13, 0, 0, CStr(tot))
        nrec(14) = Pick.replace(nrec(14), 1, 1, 0, CStr(tot))
        rderr = d3.d3_writestr(database, "plans.stats", CStr(Yr), Stats)
 
        kk = 1
        For Yy = Yr - 1 To Yr - 10 Step -1
           If d3.d3_readstr(database, Stats, "PLANS.STATS", CStr(Yy)) <> 0 Then Stats = ""
           kk = kk + 1
           nrec(1) = Pick.replace(nrec(1), 1, kk, 0, CStr(Yy))
           For I = 1 To 13
              nrec(I + 1) = Pick.replace(nrec(I + 1), 1, kk, 0, " " & Pick.extract(Stats, I, 0, 0))
           Next I
        Next Yy

End Function




Public Function ta3156(template_path As String, logentry As String, parms As String, sentence As String) As String
' TA3156 DATA TRANSFER FOR ABS MONTH BUILDING APPROVALS
Dim date1 As String, date2 As String, database As String
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

     database = Pick.extract(logentry, 2, 0, 0)

     If UBound(g_trans_info_array) = 0 Then
        g_trans_info_array(0) = "TRANS.INFO"
        rderr = d3.d3_readmat(database, g_trans_info_array(), "DICT TRANS.J")
     End If
     If UBound(g_trans_info_array) < 125 Then ReDim Preserve g_trans_info_array(125)
     temp = Mid(g_trans_info_array(125), 23, 3)
     If IsNumeric(temp) Then cdattr = CInt(temp) Else cdattr = 0
     
     date1 = Pick.extract(parms, 1, 0, 0)
     If date1 <> "" Then date1 = Format(Pick.date_pick_to_vb(date1), "dd mmm yyyy")
     date2 = Pick.extract(parms, 2, 0, 0)
     If date2 <> "" Then date2 = Format(Pick.date_pick_to_vb(date2), "dd mmm yyyy")
     Lga = Pick.extract(parms, 3, 0, 0)
     Sla = Pick.extract(parms, 4, 0, 0)
     
     fnum = FreeFile
     nrec = the_drive & "prospect_site/mergefiles/abs" & Format(Now, "ddmmmyy") & ".txt"
     Open nrec For Output Access Write As #fnum
     'Write #fnum, "Asset", "Description", "Group", "Location", "Price", "Date", "Type", "Rate", "Freq", "Current Dep'd Value", "Depreciation Amount", "Depreciated Value", "Total Depreciation", "Class"
     
     codes = Lga
     codes = Pick.replace(codes, 2, 0, 0, Sla)
     rderr = d3.d3_writestr(database, "DICT PLANS", "@ABS", codes)

     Msg = "SSELECT PLANS BY KEY ": need_and = 0
     If date1 <> "" Then Msg = Msg & "WITH APPLIC.DATE >= """ & date1 & """": need_and = 1
     If date2 <> "" Then
        If need_and Then Msg = Msg & " AND "
        Msg = Msg & " WITH APPLIC.DATE <= """ & date2 & """": need_and = 1
     End If

   total_items = d3.d3_select(logentry, Msg, mylist(), pick_cnt, 0, 0) - 1
   ta3156 = nrec & Chr(254) & total_items
   'MsgBox total_items & "=" & msg
   
   For kk = 0 To total_items
     plan_id = mylist(kk)
     If d3.d3_readstr(database, plans, "PLANS", plan_id) <> 0 Then plans = ""
     If Pick.extract(plans, 19, 0, 0) = "" Then GoTo 180
     Apdate = Format(Pick.date_pick_to_vb(Pick.extract(plans, 19, 0, 0)), "ddmmyyyy") 'oconv(Pick.extract(plans, 19, 0, 0), "D4/")
     'Apdate = Mid$(Apdate, 1, 2) & Mid$(Apdate, 4, 2) & Mid$(Apdate, 7, 4)
     Assess = Pick.extract(plans, 1, 0, 0)
     Wkt = Pick.extract(plans, 4, 1, 0)
     If d3.d3_readstr(database, ABSCODE, "BL_WORK", Wkt, 2) <> 0 Then ABSCODE = ""
     If ABSCODE <> "" Then Wkt = ABSCODE
     Bt = Pick.extract(plans, 5, 1, 0)
     If d3.d3_readstr(database, Btype, "Bl_building", Bt) <> 0 Then Btype = ""
     ABSCODE = Pick.extract(Btype, 2, 0, 0): Btdesc = Pick.extract(Btype, 1, 0, 0)
     If ABSCODE <> "" Then Bt = ABSCODE
     Bt = "000" & Bt
     Wt = Pick.extract(plans, 10, 1, 0)
     If d3.d3_readstr(database, ABSCODE, "BL_WALL", Wt, 2) <> 0 Then ABSCODE = ""
     If ABSCODE <> "" Then Wt = ABSCODE
     Wt = "00" & Wt
     Rt = Pick.extract(plans, 11, 1, 0)
     If d3.d3_readstr(database, ABSCODE, "BL_ROOF", Rt, 2) <> 0 Then ABSCODE = ""
     If ABSCODE <> "" Then Rt = ABSCODE
     Rt = "00" & Rt
     Ft = Pick.extract(plans, 12, 1, 0)
     If d3.d3_readstr(database, ABSCODE, "BL_FLOOR", Ft, 2) <> 0 Then ABSCODE = ""
     If ABSCODE <> "" Then Ft = ABSCODE
     Ft = "00" & Ft
     Dw = "000" & Pick.extract(plans, 9, 0, 0)
     St = "00" & Pick.extract(plans, 14, 0, 0)
     Area = String$(6, "0") & Pick.extract(plans, 13, 0, 0)
     value = String$(9, "0") & Pick.extract(plans, 16, 0, 0)
     If d3.d3_readstr(database, Crec, "CLIENT", Assess) <> 0 Then Crec = ""
     If d3.d3_readstr(database, Prec, "PROPERTY", Assess) <> 0 Then Prec = ""
     If cdattr <> 0 Then Cdc = Pick.extract(Prec, cdattr, 0, 0)
     Lot = Pick.extract(Prec, 1, 0, 0): Lotarea = String$(9, "0") & Pick.extract(Prec, 7, 1, 0)
     Vg = Pick.extract(Prec, 25, 0, 0)
     St_No = Pick.field(Pick.extract(Crec, 2, 1, 0), " ", 1)
     Street = Pick.trimm(Pick.field(Pick.extract(Crec, 2, 1, 0), " ", 2) & " " & Pick.field(Pick.extract(Crec, 2, 1, 0), " ", 3))
     St_No = Pick.field(St_No, "LOT", 1)
     If Not (IsNumeric(St_No)) Then
        Street = Pick.extract(Crec, 2, 1, 0)
        St_No = ""
     End If
     Suburb = Pick.extract(Crec, 3, 1, 0)
     If Suburb = "" Then Suburb = Pick.extract(Crec, 4, 1, 0)
     Ppc = Pick.extract(Crec, 5, 1, 0)
     Owner = Pick.extract(Crec, 35, 1, 0)
     If d3.d3_readstr(database, Orec, "CLIENT", Owner) <> 0 Then Orec = ""
     Oname = Pick.extract(Orec, 1, 0, 0)
     Ost_No = Pick.field(Pick.extract(Orec, 2, 1, 0), " ", 1)
     Ostreet = Pick.trimm(Pick.field(Pick.extract(Orec, 2, 1, 0), " ", 2) & " " & Pick.field(Pick.extract(Orec, 2, 1, 0), " ", 3))
     If Not (IsNumeric(Ost_No)) Then
        Ostreet = Pick.extract(Orec, 2, 1, 0)
        Ost_No = ""
     End If
     Osuburb = Pick.extract(Orec, 3, 1, 0)
     If Osuburb = "" Then Osuburb = Pick.extract(Orec, 4, 1, 0)
     Oaddr = Pick.trimm(Pick.extract(Orec, 2, 1, 0) & " " & Pick.extract(Orec, 3, 1, 0) & " " & Pick.extract(Orec, 4, 1, 0))
     Opc = Pick.extract(Orec, 5, 1, 0): Oph = Pick.extract(Orec, 9, 1, 0)
     Builder = Pick.extract(plans, 2, 0, 0)
     If d3.d3_readstr(database, Brec, "CLIENT", Builder) <> 0 Then Brec = ""
     Bname = Pick.extract(Brec, 1, 0, 0)
     Bst_No = Pick.field(Pick.extract(Brec, 2, 1, 0), " ", 1)
     Bstreet = Pick.trimm(Pick.field(Pick.extract(Brec, 2, 1, 0), " ", 2) & " " & Pick.field(Pick.extract(Brec, 2, 1, 0), " ", 3))
     If Not (IsNumeric(Bst_No)) Then
        Bstreet = Pick.extract(Brec, 2, 1, 0)
        Bst_No = ""
     End If
     Bsuburb = Pick.extract(Brec, 3, 1, 0)
     If Bsuburb = "" Then Bsuburb = Pick.extract(Brec, 4, 1, 0)
     Baddr = Pick.trimm(Pick.extract(Brec, 2, 1, 0) & " " & Pick.extract(Brec, 3, 1, 0) & " " & Pick.extract(Brec, 4, 1, 0))
     Bpc = Pick.extract(Brec, 5, 1, 0): Bph = Pick.extract(Brec, 9, 1, 0)
     Breg = Pick.extract(plans, 3, 0, 0)
     If d3.d3_readstr(database, Brec, "CLIENT", Pick.extract(plans, 2, 0, 0)) <> 0 Then Brec = ""
     temp = Pick.extract(plans, 44, 0, 0)
     If IsNumeric(temp) Then Doi = temp Else Doi = "0"
     Ped = "000" & Pick.extract(plans, 46, 0, 0)
     Frt = Pick.extract(plans, 45, 1, 0)
     If d3.d3_readstr(database, ABSCODE, "BL_FRAME", Frt, 2) <> 0 Then ABSCODE = ""
     If ABSCODE <> "" Then Frt = ABSCODE
     Frt = "00" & Frt
     Owntyp = Pick.extract(plans, 79, 0, 0): If Owntyp = "" Then Owntyp = 1
     Detach = Pick.extract(plans, 80, 0, 0): If Detach = "" Then Detach = "D"
     Ndd = "000" & Pick.extract(plans, 81, 0, 0)
     Bca1 = Pick.extract(plans, 82, 1, 0): Bca2 = Pick.extract(plans, 82, 2, 0): Bca3 = Pick.extract(plans, 82, 3, 0)

     Ans = "5" & Right(Space(4) & Lga, 4) & Right(Space(4) & Sla, 4) & Left(plan_id & Space(20), 20)
     Ans = Ans & Space(3) & Left(Apdate & Space(8), 8) & Right(Space(7) & (String$(7, "0") & Cdc), 7) & Space(7) & Left(Pick.extract(Lot, 1, 1, 0) & Space(10), 10) & Space(8) & Left(St_No & Space(10), 10) & Left(Street & Space(30), 30) & Left(Suburb & Space(30), 30) & Left(Ppc & Space(4), 4) & Space(4) & Left(Owntyp & Space(1), 1) & Left(Wkt & Space(1), 1) & Right(Space(3) & Bt, 3) & Left(Btdesc & Space(250), 250) & Right(Space(3) & Dw, 3) & Right(Space(2) & Wt, 2) & Right(Space(2) & Rt, 2) & Right(Space(2) & Ft, 2) & Right(Space(2) & Frt, 2) & Right(Space(6) & Area, 6) & Right(Space(6) & Lotarea, 6) & Right(Space(9) & value, 9) & Left(Detach & Space(1), 1) & Left(Doi & Space(1), 1) & Right(Space(3) & Ped, 3) & Right(Space(2) & St, 2) & Right(Space(3) & Ndd, 3) & Right(Space(8) & (String$(8, "0") & Assess), 8) & Left(Oname & Space(30), 30) & Left(Ost_No & Space(10), 10) & Left(Ostreet & Space(30), 30) & Left(Osuburb & Space(30), 30) & Left(Opc & Space(4), 4)
     Ans = Ans & Left(Oph & Space(14), 14) & Left(Bname & Space(36), 36) & Left(Bst_No & Space(10), 10) & Left(Bstreet & Space(36), 36) & Left(Bsuburb & Space(30), 30) & Left(Bpc & Space(4), 4) & Left(Bph & Space(14), 14) & Left(Breg & Space(10), 10) & Space(10) & Left(Bca1 & Space(6), 6) & Left(Bca2 & Space(6), 6) & Left(Bca3 & Space(6), 6) & Space(59)
     Print #fnum, Ans
180:
  Next kk
  Close #fnum

End Function

Public Function ta3148a(logentry As String, nrec() As String, parms As String) As String
' TA3148 - Building Licence Application Reporting

Dim date1 As String, date2 As String, Msg As String, nx As Integer, desc As String
Dim Wtype As String, Btype As String, Fees As String, Fcnt As Integer
Dim Atr As Integer, temp As String, Maxj As Integer, Fc As String, need_and As Integer
Dim Stat As String, Hdr3 As String, Id As String, J As Integer, k As Integer, I As Integer, Maxi As Integer
Dim Status As String, Xstatus As String, Prec As String, Assess As String, Proprec As String, Lot As String, Ward As String, clrec As String
Dim Paddr As String, Own As String, Builder As String, Owner As String, Wt As String, Bt As String
Dim value As Currency, Totfees As Currency, Totdeps As Currency, kk As Integer, Seq As String
Dim mylist() As String, pick_cnt As Long, database As String, total_items As Long

     ReDim nrec(20)
     date1 = Pick.extract(parms, 1, 0, 0)
     If date1 <> "" Then date1 = Format(Pick.date_pick_to_vb(date1), "dd mmm yyyy")
     date2 = Pick.extract(parms, 2, 0, 0)
     If date2 <> "" Then date2 = Format(Pick.date_pick_to_vb(date2), "dd mmm yyyy")
     Wtype = Pick.extract(parms, 3, 0, 0)
     Btype = Pick.extract(parms, 4, 0, 0)
     Fees = Pick.extract(parms, 5, 0, 0)
     Fcnt = Pick.dcount(Fees, Chr(253))
     Stat = Pick.extract(parms, 6, 0, 0)
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
     
     If date1 <> "" Then nrec(19) = nrec(19) & " from " & date1
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
     If date1 <> "" Then Msg = Msg & "WITH APPLIC.DATE >= """ & date1 & """": need_and = 1
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
     
     database = Pick.extract(logentry, 2, 0, 0)
     total_items = d3.d3_select(logentry, Msg, mylist(), pick_cnt, 0, 0) - 1

     For kk = 0 To total_items
       Id = mylist(kk)
       If d3.d3_readstr(database, Prec, "PLANS", Id) <> 0 Then GoTo 180
       If Id = "" Then GoTo 180

       If Pick.extract(Prec, 30, 0, 0) <> "" Then Status = "X": Xstatus = "Cancelled": GoTo 120
       If Pick.extract(Prec, 19, 0, 0) = "" Then Status = "P": Xstatus = "Pending": GoTo 120
       If Pick.extract(Prec, Atr, 0, 0) = "" Then
          Status = "A"
          If Atr = 71 Then Xstatus = "Approved not issued" Else Xstatus = "Approved fees not raised"
          GoTo 120
       End If
       If Pick.extract(Prec, 31, 0, 0) = "" Then
          Status = "I"
          If Atr = 71 Then Xstatus = "Issued not started" Else Xstatus = "Fees raised not started"
          GoTo 120
       End If
       If Pick.extract(Prec, 36, 0, 0) = "" Then Status = "S": Xstatus = "Construction started": GoTo 120
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

     Assess = Pick.extract(Prec, 1, 0, 0)
     If d3.d3_readstr(database, Proprec, "PROPERTY", Assess) <> 0 Then Proprec = ""
     Lot = Pick.extract(Proprec, 1, 1, 0)
     If d3.d3_readstr(database, Ward, "area", Pick.extract(Proprec, 38, 0, 0)) <> 0 Then Ward = ""
     Ward = Pick.extract(Ward, 1, 0, 0)
     If d3.d3_readstr(database, clrec, "CLIENT", Assess) <> 0 Then clrec = ""
     Paddr = Pick.trimm(Pick.extract(clrec, 2, 1, 0) & " " & Pick.extract(clrec, 3, 1, 0) & " " & Pick.extract(clrec, 4, 1, 0))
     Own = Pick.extract(clrec, 35, 1, 0)
     If d3.d3_readstr(database, clrec, "CLIENT", Pick.extract(Prec, 2, 0, 0)) <> 0 Then clrec = ""
     Builder = Pick.trimm(Pick.extract(clrec, 6, 0, 0) & " " & Pick.extract(clrec, 1, 0, 0))
     If Pick.extract(Prec, 53, 0, 0) <> "" Then
        Owner = Pick.extract(Prec, 53, 0, 0)
     Else
        If d3.d3_readstr(database, clrec, "CLIENT", Own) <> 0 Then clrec = ""
        Owner = Pick.trimm(Pick.extract(clrec, 6, 0, 0) & " " & Pick.extract(clrec, 1, 0, 0))
     End If
     If Wtype <> "" Then Wt = Wtype Else Wt = Pick.extract(Prec, 4, 1, 0)
     If Btype <> "" Then Bt = Btype Else Bt = Pick.extract(Prec, 5, 1, 0)
     temp = Pick.extract(Prec, 16, 0, 0)
     If IsNumeric(temp) Then value = CCur(temp) Else value = 0
     Totfees = 0: Totdeps = 0
     Maxi = Pick.dcount(Pick.extract(Prec, 22, 0, 0), Chr(253))
     For I = 1 To Maxi
        Maxj = Pick.dcount(Pick.extract(Prec, 22, I, 0), Chr(252))
        For J = 1 To Maxj
           Fc = Pick.extract(Prec, 22, I, J)
           If Fees = "" Then
              temp = Pick.extract(Prec, 23, I, J)
              If IsNumeric(temp) Then Totfees = Totfees + CCur(temp)
           Else
              For k = 1 To Fcnt
                 If Fc = Pick.extract(Fees, 1, k, 0) Then
                    temp = Pick.extract(Prec, 23, I, J)
                    If IsNumeric(temp) Then Totfees = Totfees + CCur(temp)
                 End If
              Next k
           End If
160     Next J
     Next I
     Seq = Pick.extract(Prec, 17, 0, 0)
     If Pick.locate(Seq, nrec(4), 1, 1, 0, nx, "ar") <> 0 Then
     End If
     'LOCATE(SEQ,NREC,4,1,0,NX,"AR") ELSE NULL
     nrec(4) = Pick.insert(nrec(4), 1, nx, 0, Seq)
     nrec(1) = Pick.insert(nrec(1), 1, nx, 0, Id)
     nrec(2) = Pick.insert(nrec(2), 1, nx, 0, Wt)
     nrec(3) = Pick.insert(nrec(3), 1, nx, 0, Bt)
     nrec(5) = Pick.insert(nrec(5), 1, nx, 0, Paddr)
     nrec(6) = Pick.insert(nrec(6), 1, nx, 0, Builder)
     nrec(7) = Pick.insert(nrec(7), 1, nx, 0, Owner)
     nrec(8) = Pick.insert(nrec(8), 1, nx, 0, Pick.extract(Prec, 19, 0, 0))
     'Status = Mid$(Pick.extract(Mlev, Xstatus + 1, 0, 0), 5, 99)
     nrec(9) = Pick.insert(nrec(9), 1, nx, 0, Xstatus)
     nrec(10) = Pick.insert(nrec(10), 1, nx, 0, CStr(value))
     nrec(11) = Pick.insert(nrec(11), 1, nx, 0, Ward)
     nrec(12) = Pick.insert(nrec(12), 1, nx, 0, CStr(Totfees))
     nrec(13) = Pick.insert(nrec(13), 1, nx, 0, Pick.extract(Prec, 10, 0, 0))
     nrec(14) = Pick.insert(nrec(14), 1, nx, 0, Pick.extract(Prec, 11, 0, 0))
     nrec(15) = Pick.insert(nrec(15), 1, nx, 0, Pick.extract(Prec, 12, 0, 0))
     temp = Pick.extract(Prec, 32, 0, 0)
     nrec(16) = Pick.insert(nrec(16), 1, nx, 0, replace(temp, Chr(253), ","))
     nrec(17) = Pick.insert(nrec(17), 1, nx, 0, Pick.extract(Prec, 57, 1, 0))
     nrec(18) = Pick.insert(nrec(18), 1, nx, 0, Pick.extract(Prec, 58, 1, 0))
180: Next kk

End Function

Public Function TA3157(template_path As String, logentry As String, parms As String, sentence As String) As String
' TA3157 DATA TRANSFER FOR ABS MONTH BUILDING COMMENCEMENTS
Dim Lga As String, AppDate As String, database As String, ComDate As String
Dim mylist() As String, plan_id As String, plans As String, Ans As String
Dim fnum As Integer, total_items As Integer, kk As Integer, pick_cnt As Long, Status As Integer
Dim temp As String, nrec As String, the_drive As String

    the_drive = Left(template_path, InStr(template_path, "\prospect\") - 1) & "/"
        
    Lga = Pick.extract(parms, 1, 0, 0)          ' LGA
    AppDate = Pick.extract(parms, 2, 0, 0)      ' Approval period YYMM
    
    fnum = FreeFile
    nrec = the_drive & "prospect_site/mergefiles/abs" & Format(Now, "ddmmmyy") & ".txt"
    Open nrec For Output Access Write As #fnum
    
    database = Pick.extract(logentry, 2, 0, 0)
    
    total_items = d3.d3_select(logentry, sentence, mylist(), pick_cnt, 0, 0)
    TA3157 = nrec & Chr(254) & total_items
    
    For kk = 0 To total_items - 1
        plan_id = mylist(kk)
        If d3.d3_readstr(database, plans, "PLANS", plan_id) = 0 Then
            If Pick.extract(plans, 30, 0, 0) = "" Then
                If Pick.extract(plans, 31, 0, 0) = "" Then
                    ComDate = String$(8, "0")
                    Status = 2
                Else
                    ComDate = Format(Pick.date_pick_to_vb(Pick.extract(plans, 31, 0, 0)), "ddmmyy")
                    Status = 1
                End If
            Else
                ComDate = Format(Pick.date_pick_to_vb(Pick.extract(plans, 30, 0, 0)), "ddmmyy")
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
    
    database = Pick.extract(logentry, 2, 0, 0)
    
    total_items = d3.d3_select(logentry, sentence, mylist(), pick_cnt, 0, 0)
    TA3158 = nrec & Chr(254) & total_items
    
    For kk = 0 To total_items - 1
        plan_id = mylist(kk)
        If d3.d3_readstr(database, plans, "PLANS", plan_id) = 0 Then
            Assess = Pick.extract(plans, 1, 0, 0)
            Btype = Pick.extract(plans, 5, 1, 0)
            If d3.d3_readstr(database, desc, "Bl_building", Btype, 1) <> 0 Then desc = ""
            Area = Pick.extract(plans, 13, 0, 0)
            If IsNumeric(Area) Then
                Area = CStr(CCur(Area) * 100)
            End If
            Area = String$(7, "0") & Area
            value = String$(8, "0") & Pick.extract(plans, 16, 0, 0)
            If d3.d3_readstr(database, Own, "CLIENT", Assess, 35) <> 0 Then Own = ""
            If d3.d3_readstr(database, Orec, "CLIENT", Pick.extract(Own, 1, 1, 0)) <> 0 Then Orec = ""
            If d3.d3_readstr(database, Brec, "CLIENT", Pick.extract(plans, 2, 0, 0)) <> 0 Then Brec = ""
            Ans = Left(plan_id & Space(10), 10) & Left(Pick.extract(plans, 3, 0, 0) & Space(4), 4) & _
                Left(Pick.extract(Orec, 1, 0, 0) & Space(40), 40) & Left(Pick.extract(Orec, 7, 0, 0) & _
                Space(20), 20) & Left(Pick.extract(Orec, 2, 1, 0) & Space(30), 30) & _
                Left(Trim(Pick.extract(Orec, 3, 1, 0) & " " & Pick.extract(Orec, 4, 1, 0) & " " & _
                Pick.extract(Orec, 5, 1, 0)) & Space(30), 30) & Left(Pick.extract(Brec, 1, 0, 0) & _
                Space(40), 40) & Left(Pick.extract(Brec, 7, 0, 0) & Space(20), 20) & _
                Left(Pick.extract(Brec, 2, 1, 0) & Space(30), 30) & Left(Trim(Pick.extract(Brec, 3, 1, 0) & " " & _
                Pick.extract(Brec, 4, 1, 0) & " " & Pick.extract(Brec, 5, 1, 0)) & Space(30), 30) & _
                Left(Pick.extract(desc, 1, 1, 0) & Space(30), 30) & Right(Space(8) & value, 8) & _
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
    
    database = Pick.extract(logentry, 2, 0, 0)
    
    total_items = d3.d3_select(logentry, sentence, mylist(), pick_cnt, 0, 0)
    TA3159 = nrec & Chr(254) & total_items
    
    For kk = 0 To total_items - 1
        plan_id = mylist(kk)
        If d3.d3_readstr(database, plans, "PLANS", plan_id) = 0 Then
            Assess = Pick.extract(plans, 1, 0, 0)
            If d3.d3_readstr(database, Crec, "CLIENT", Assess) <> 0 Then Crec = ""
            If d3.d3_readstr(database, Prec, "PROPERTY", Assess) <> 0 Then Prec = ""
            Owner = Pick.extract(Crec, 35, 1, 0)
            If d3.d3_readstr(database, Orec, "CLIENT", Owner) <> 0 Then Orec = ""
            Builder = Pick.extract(plans, 2, 0, 0)
            If d3.d3_readstr(database, Brec, "CLIENT", Builder) <> 0 Then Brec = ""
            Oname = Pick.extract(Orec, 1, 0, 0)
            Opc = Pick.extract(Orec, 5, 1, 0)
            Bname = Pick.extract(Brec, 1, 0, 0)
            Bpc = Pick.extract(Brec, 5, 1, 0)
            Ppc = Pick.extract(Crec, 5, 1, 0)
            Lot = Pick.extract(Prec, 1, 1, 0)
            Cd = Pick.extract(Prec, 125, 0, 0)
            If d3.d3_readstr(database, Wkt, "Bl_work", Pick.extract(plans, 4, 1, 0), 1) <> 0 Then Wkt = ""
            If d3.d3_readstr(database, Bt, "Bl_building", Pick.extract(plans, 5, 1, 0), 1) <> 0 Then Bt = ""
            If d3.d3_readstr(database, Wt, "Bl_wall", Pick.extract(plans, 10, 1, 0), 1) <> 0 Then Wt = Pick.extract(plans, 10, 1, 0)
            If d3.d3_readstr(database, Rt, "Bl_roof", Pick.extract(plans, 11, 1, 0), 1) <> 0 Then Rt = Pick.extract(plans, 11, 1, 0)
            If d3.d3_readstr(database, Ft, "Bl_floor", Pick.extract(plans, 12, 1, 0), 1) <> 0 Then Ft = Pick.extract(plans, 12, 1, 0)
            Dw = String$(5, "0") & Pick.extract(plans, 9, 0, 0)
            St = String$(5, "0") & Pick.extract(plans, 14, 0, 0)
            value = String$(10, "0") & Pick.extract(plans, 16, 0, 0)
            Complete = Pick.date_pick_to_vb(Pick.extract(plans, 19, 0, 0))
            Ans = Left(plan_id & Space(20), 20) & Left(Oname & Space(30), 30) & _
                Left(Pick.extract(Orec, 2, 1, 0) & Space(30), 30) & Left(Pick.extract(Orec, 3, 1, 0) & Space(30), 30) & _
                Left(Pick.extract(Orec, 4, 1, 0) & Space(30), 30) & Left(Opc & Space(10), 10) & _
                Left(Bname & Space(30), 30) & Left(Pick.extract(Brec, 2, 1, 0) & Space(30), 30) & _
                Left(Pick.extract(Brec, 3, 1, 0) & Space(30), 30) & Left(Pick.extract(Brec, 4, 1, 0) & Space(30), 30) & _
                Left(Bpc & Space(10), 10)
            Ans = Ans & Left(Pick.extract(Crec, 2, 1, 0) & Space(30), 30) & _
                Left(Pick.extract(Crec, 3, 1, 0) & Space(30), 30) & Left(Pick.extract(Crec, 4, 1, 0) & Space(30), 30) & _
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
Dim td_rec As String, Client_No As String, I As Integer
Dim temp As String, tempcur As Currency, tempcur2 As Currency
Dim Haslimit As String, Allowb4 As String, Onlythis As String
Dim Tr_Cr As String, Tr_Dr As String, database As String, rderr As Integer
Dim debt_cont As String, Cr_Rec As String, Cred_Cont As String, tj_rec As String
Dim cancel As Integer
Dim Strvm As String, Cl_Fg As String, Plan_Ids As String, T_Name As String, cr_relation As Integer
Dim Tjdata() As String, checking As Integer
Dim posn As Integer
Dim Fdate As Integer, Ln, Adate As String, Ann, Yy, Trinvdate As Integer, Tr_Inv_Date As Integer
Dim Tr_Inv_Ref2, Tamt As Currency, Maxi As Integer, Maxj As Integer, J As Integer, Fc As String, Amt As Currency, CODE, field
Dim Name As String, Build As String, Gl As String, Tr_Inv_Ref As String, Narr As String, Tjac As String, Tjjob As String, Tjcd As String, Tjcost As Currency
Dim Tjnarr As String, Comm As Currency, Comgl As String, Ugl As String
Dim Ll As Integer, Glac As String, Tj_Key As String, tj_tno As String
Dim Gst As String, billto As String
Dim Orec As String, bill_client As String
Dim minimum As Currency, percent As Currency, factor As Currency
Dim gstamt As Currency, gstcomm As Currency
Dim gstrates As String, gstrate As Currency, gstaccs As String
Dim nrec() As String

'ta3120 FILE='SIGNS'; XREF.ATTR=64; PREFIX='SL'; TEXT='Sign'
'ta3121 FILE='DEMOLITIONS'; XREF.ATTR=65; PREFIX='DL'; TEXT='Demolition'
'ta3140 FILE='PLANS'; XREF.ATTR=51; PREFIX='BL'; TEXT='Building'

     ReDim nrec(3)
     database = Pick.extract(logentry, 2, 0, 0)
     temp = d3.execute_tcl(logentry, "WHO", "")
     tj_tno = Right("000" & Pick.field(temp, " ", 1), 3)
      
     which_file = "PLANS": pr_which_file = "PR." & which_file
     Prefix = "BL"
     plan_id = Pick.extract(parms, 1, 0, 0)
     Fdate = Pick.extractint(parms, 2, 0, 0)

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
     temp = Pick.extract(gstrates, 1, 0, 0)
     If IsNumeric(temp) Then gstrate = CCur(temp) Else gstrate = 0
     
     Tr_Cr = 39: Tr_Dr = 64

     If d3.d3_readstr(database, plans_rec, "PLANS", plan_id) <> 0 Then
        TA3140 = "Fees not raised. " & "Plan " & plan_id & " does not exist"
        Exit Function
     End If
     Assess = Pick.extract(plans_rec, 1, 0, 0) 'property assess
     Client_No = Pick.extract(plans_rec, 2, 0, 0) 'applicant debtor
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
     If Pick.extract(plans_rec, 20, 0, 0) <> "" Then
        If Pick.extract(plans_rec, 30, 0, 0) <> "" Then
           If Pick.extract(plans_rec, 30, 0, 0) = Pick.ICONV(Format$(Now, "DD MMM YY"), "D2") Then cancel = 1: GoTo 30
           TA3140 = "Fees not raised. " & "Plan " & plan_id & " Fees raised on " & Pick.oconv(Pick.extract(plans_rec, 20, 0, 0), "D2") & " and then cancelled on " & Pick.oconv(Pick.extract(plans_rec, 30, 0, 0), "D2")
        Else
           TA3140 = "Fees not raised. " & "Plan " & plan_id & " Fees raised on " & Pick.oconv(Pick.extract(plans_rec, 20, 0, 0), "D2")
        End If
        Exit Function
     End If
     If Pick.extract(plans_rec, 19, 0, 0) = "" Then
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
        nrec(1) = "Fees originally raised on the " & Pick.oconv(Pick.extract(plans_rec, 20, 0, 0), "D2") & " and cancelled today. Re-raising fees" & vbCrLf
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
     Maxi = Pick.dcount(Pick.extract(plans_rec, 22, 0, 0), Chr(253))
     For I = 1 To Maxi
        Maxj = Pick.dcount(Pick.extract(plans_rec, 22, I, 0), Chr(252))
        For J = 1 To Maxj
           Fc = Pick.extract(plans_rec, 22, I, J)
           If Fc = "" Then GoTo 340
           If d3.d3_readstr(database, Build, "bl_fee", Fc) <> 0 Then Build = ""
           temp = Pick.extract(Build, 10, 0, 0)
           If IsNumeric(temp) Then minimum = CCur(temp) Else minimum = 0
           temp = Pick.extract(Build, 8, 0, 0)
           If IsNumeric(temp) Then percent = CCur(temp) Else percent = 0
           temp = Pick.extract(Build, 8, 0, 0)
           If IsNumeric(temp) Then factor = CCur(temp) Else factor = 0

           Amt = 0
           Select Case Pick.extract(Build, 7, 0, 0)
              Case "V" '16
                 temp = Pick.extract(Build, 16, 0, 0)
                 If IsNumeric(temp) Then Amt = CCur(temp) Else Amt = 0
                 Amt = Amt * percent * factor
                 If Amt < minimum Then Amt = minimum
              Case "A" '13
                 temp = Pick.extract(Build, 13, 0, 0)
                 If IsNumeric(temp) Then Amt = CCur(temp) Else Amt = 0
                 Amt = Amt * percent * factor
                 If Amt < minimum Then Amt = minimum
              Case "$"
                 temp = Pick.extract(plans_rec, 23, I, J)
                 If IsNumeric(temp) Then Amt = CCur(temp) Else Amt = 0
           End Select
           If Amt = 0 Then GoTo 340
           Gst = Pick.extract(Build, 12, 0, 0) 'will be Y if GST to be added
           If Gst = "y" Then
              gstamt = gstrate * Amt / 10000
              Amt = Amt + gstamt
           End If

           Gl = Pick.extract(Build, 3, 0, 0)
           If Gl = "" Then Gl = Fc & "feecode missing"
           If Gl = "NO" Then GoTo 340
           
           temp = Pick.extract(Build, 4, 0, 0) 'commission
           If IsNumeric(temp) Then Comm = CCur(temp) Else Comm = 0
           If Pick.extract(Build, 6, 0, 0) = "Y" Then 'gst on commission
              gstcomm = gstrate * Comm / 10000
              Comm = Comm + gstcomm
           End If
           If Amt <= Comm Then GoTo 340
           
           Comgl = Pick.extract(Build, 5, 0, 0)
           
           billto = Pick.extract(Build, 13, 0, 0) 'A=applicant, O=owner, P=property
           bill_client = Client_No
           Select Case billto
              Case "a": bill_client = Assess
              Case "o": bill_client = Client_No
              Case "p"
                 If d3.d3_readstr(database, Orec, "CLIENT", Assess) <> 0 Then Orec = ""
                 bill_client = Pick.extract(Orec, 35, 1, 0) 'first owner
           End Select

           If checking <> 0 Then
              If Pick.locate(bill_client, nrec(2), 1, 1, 0, posn, "") = 0 Then
                 nrec(2) = Pick.insert(nrec(2), 1, posn, 0, bill_client)
                 nrec(3) = Pick.insert(nrec(3), 1, posn, 0, "0")
              End If
              temp = Pick.extract(nrec(3), 1, posn, 0)
              If IsNumeric(temp) Then tempcur = CCur(temp) Else tempcur = 0
              tempcur = tempcur + Amt
              nrec(3) = Pick.replace(nrec(3), 1, posn, 0, CStr(tempcur))
              GoTo 340
           End If
           
           If d3.d3_readstr(database, td_rec, "TDEBTOR", bill_client) <> 0 Then
              TA3140 = "Fees not raised. " & "Plan " & plan_id & ". Debtor " & Client_No & " does not exist"
              Exit Function
           End If
'$INSERT I.LOG.UPDATE "|TDEBTOR|":CLIENT.NO 318 TD.REC
           Tr_Inv_Ref = Tr_Inv_Ref2 & "*" & Fc
           Narr = Assess
           Call ta16.SR310(database, CStr(Trinvdate), bill_client, td_rec, Tr_Inv_Ref, Tr_Inv_Date, CStr(Amt), Tr_Dr, Narr, cr_relation, "", debt_cont, "", g_trans_info_array(14))
           Tjac = debt_cont: Tjjob = 0: Tjcd = Tr_Dr: Tjcost = Amt - gstamt: Tjnarr = Tr_Inv_Ref
           GoSub 777
           Tjac = Pick.extract(gstaccs, 2, 0, 0): Tjjob = 0: Tjcd = Tr_Dr: Tjcost = gstamt: Tjnarr = Tr_Inv_Ref
           GoSub 777
           
           Amt = Amt - Comm
           gstamt = gstamt - gstcomm
                      
           If InStr(Gl, ".") = 0 Then
330           If d3.d3_readstr(database, Cr_Rec, "CREDITOR", Gl) <> 0 Then Cr_Rec = "" '???ignoreUgl = "creditor account " & Gl & " is missing in program 3140": Release CREDITOR_DATA, Gl: GoTo 332
'$INSERT I.LOG.UPDATE '|CREDITOR|':CLIENT.NO2 330 CR.REC
              Call ckaiis.SR340(logentry, Trinvdate, Gl, Cr_Rec, Tr_Inv_Ref, Tr_Inv_Date, "", Amt, 0, "", "", 0, 0, Tr_Cr, Narr, cr_relation, "", "", "", Cred_Cont)
              rderr = d3.d3_writestr(database, "creditor", Gl, Cr_Rec)
              Ugl = Cred_Cont
           Else
              Ugl = Gl
           End If
332        Tjac = Ugl: Tjjob = 0: Tjcd = Tr_Cr: Tjcost = Amt - gstamt: Tjnarr = Tr_Inv_Ref
           GoSub 777
           Tjac = Pick.extract(gstaccs, 1, 0, 0): Tjjob = 0: Tjcd = Tr_Cr: Tjcost = gstamt: Tjnarr = Tr_Inv_Ref
           GoSub 777
           If Comm <> 0 Then
              Tjac = Comgl: Tjjob = 0: Tjcd = Tr_Cr: Tjcost = Comm - gstcomm: Tjnarr = Tr_Inv_Ref
              GoSub 777
              Tjac = Pick.extract(gstaccs, 1, 0, 0): Tjjob = 0: Tjcd = Tr_Cr: Tjcost = gstcomm: Tjnarr = Tr_Inv_Ref
              GoSub 777
           End If
340     Next J
     Next I
     If checking <> 0 Then
        Maxi = Pick.dcount(nrec(2), Chr(253))
        For I = 1 To Maxi
           billto = Pick.extract(nrec(2), 1, I, 0)
           If d3.d3_readstr(database, td_rec, "TDEBTOR", billto) <> 0 Then
              TA3140 = "Plan " & plan_id & ". Fees can NOT be raised. Debtor " & billto & " does not exist "
              Exit Function
           End If
           If billto = 1 Then
              temp = Pick.extract(td_rec, 3, 0, 0)
              If IsNumeric(temp) Then tempcur = CCur(temp) Else tempcur = 0
              tempcur = tempcur + CCur(Pick.extract(nrec(3), 1, I, 0))
              temp = Pick.extract(td_rec, 29, 0, 0)
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

400  rderr = d3.d3_writestr(database, "tdebtor", Client_No, td_rec)
410  If d3.d3_readstr(database, plans_rec, "PLANS", plan_id) <> 0 Then
        TA3140 = "Fees not raised. " & "Plan " & plan_id & " does not exist"
        Exit Function
'$INSERT I.QU.REC
     End If
'$INSERT I.LOG.UPDATE "|PLANS|":PLAN.ID 410 PLANS.REC
     plans_rec = Pick.replace(plans_rec, 20, 0, 0, CStr(Fdate))
     If Adate <> "" Then plans_rec = Pick.replace(plans_rec, 43, 0, 0, Adate)
     If Pick.extract(plans_rec, 30, 0, 0) <> "" Then
        plans_rec = Pick.replace(plans_rec, 24, 0, 0, "")
        plans_rec = Pick.replace(plans_rec, 30, 0, 0, "")
     End If
     rderr = d3.d3_writestr(database, which_file, plan_id, plans_rec)
     If Allowb4 = 0 Then
        rderr = d3.d3_writestr(database, pr_which_file, plan_id, "")
     End If
     If Tjdata(1) <> "" Then GoSub 900
     temp = "Fees raised for plan " & plan_id & Chr(254) & nrec(1)
     Maxi = Pick.dcount(nrec(2), Chr(253))
     For I = 1 To Maxi
        rderr = d3.d3_readstr(database, T_Name, "CLIENT", Pick.extract(nrec(2), 1, I, 0), 1)
        If IsNumeric(Pick.extract(nrec(3), 1, I, 0)) Then tempcur = CCur(Pick.extract(nrec(3), 1, I, 0)) / 100 Else tempcur = 0
        temp = temp & Chr(254) & "Invoiced debtor " & Pick.extract(nrec(2), 1, I, 0) & " " & T_Name & " for $" & Format(tempcur, "#.00")
     Next I
     TA3140 = temp
     Exit Function
'
777 For Ll = 1 To 9999
      Glac = Pick.extract(Tjdata(3), 1, Ll, 0)
      If Glac = "" Then GoTo 779
      If Glac = Tjac Then
       If Pick.extract(Tjdata(1), 1, Ll, 0) = Tjcd And Pick.extract(Tjdata(6), 1, Ll, 0) = Tjnarr And Pick.extract(Tjdata(2), 1, Ll, 0) = Tjjob Then
         temp = Pick.extract(Tjdata(4), 1, Ll, 0)
         If IsNumeric(temp) Then tempcur = CCur(temp) Else tempcur = 0
         Tjdata(4) = Pick.replace(Tjdata(4), 1, Ll, 0, CStr(tempcur + Tjcost))
         GoTo 780
       End If
      End If
    Next Ll
779 Tjdata(3) = Pick.insert(Tjdata(3), 1, -1, 0, Tjac)
    Tjdata(6) = Pick.insert(Tjdata(6), 1, -1, 0, Tjnarr)
    Tjdata(2) = Pick.insert(Tjdata(2), 1, -1, 0, Tjjob)
    Tjdata(1) = Pick.insert(Tjdata(1), 1, -1, 0, Tjcd)
    Tjdata(4) = Pick.insert(Tjdata(4), 1, -1, 0, CStr(Tjcost))
780 Return
'
900  Tjdata(7) = Tr_Inv_Date
950  Tj_Key = replace(Timer, ".", "") & tj_tno
     If d3.d3_readstr(database, tj_rec, "TRANS.J", Tj_Key) <> 0 Then GoTo 960
     'Release TRANS_J_DATA, Tj_Key
     GoTo 950
960
'$INSERT I.LOG.ADD "|TRANS.J|":TJ.KEY 950
     Tjdata(0) = Tj_Key
     rderr = d3.d3_writemat(database, "trans.j", Tjdata())
     Return

End Function

Public Sub srclient(Client_Rec As String, Client_No As String, Name As String, Adr1 As String, Adr2 As String, Adr3 As String, Pcode As String, Initials As String, GIVEN As String, title As String, Ptel As String, Btel As String, Telx As String, property As String, Ntype As String, Atype As String, Nameline As String, Addrline As String, Mail As String)

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
    Name = Pick.extract(Client_Rec, 1, 0, 0)
    Initials = Pick.extract(Client_Rec, 6, 0, 0)
    GIVEN = Pick.extract(Client_Rec, 7, 0, 0)
    title = Pick.extract(Client_Rec, 8, 0, 0)
    Btel = Pick.extract(Client_Rec, 9, 1, 0)
    Ptel = Pick.extract(Client_Rec, 9, 2, 0)
    Telx = Pick.extract(Client_Rec, 9, 3, 0)
    property = Pick.extract(Client_Rec, 28, 0, 0)
'
    If Mail = "0" Then
       If Pick.extract(Client_Rec, 5, 2, 0) <> "" Then res = 2 Else res = 1
    Else
       res = 1
    End If
'
    Adr1 = Pick.extract(Client_Rec, 2, res, 0)
    Adr2 = Pick.extract(Client_Rec, 3, res, 0)
    Adr3 = Pick.extract(Client_Rec, 4, res, 0)
    Pcode = Pick.extract(Client_Rec, 5, res, 0)
    If Pcode <> "" Then Pcode = Pcode
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
       If Pcode <> "" Then Addrline = Addrline & " " & Pcode
    End If

End Sub

Private Sub Class_Initialize()

ReDim g_trans_info_array(0)

End Sub



Public Sub gl_account_balances(logentry As String, gl_ac As String, gl_rec As String, commitflag As String, pl_from_year_start As Integer, start_of_year As Integer, sb_date As Integer, tb_date As Integer, Open_Bal As Currency, tran_bal As Currency)

Dim acc_type As String, tr_code As Integer, Tr_Date As Integer, Amount As Currency
Dim sentence As String, trid As String, mylist() As String, total_items As Long, pick_cnt As Long
Dim database As String, kk As Long, tr_rec As String
     database = Pick.extract(logentry, 2, 0, 0)
     
     If d3.d3_readstr(database, gl_rec, "GEN.L", gl_ac) <> 0 Then gl_rec = Chr(254) & "?? ACCOUNT MISSING ??"
     acc_type = Pick.extract(gl_rec, 1, 0, 0)
     
     If pl_from_year_start And acc_type = "C" Then
        Open_Bal = 0
     Else
        If commitflag = "C" Then
           Open_Bal = Pick.extractcur(gl_rec, 32, 1, 0)
        Else
           Open_Bal = Pick.extractcur(gl_rec, 6, 1, 0)
           If commitflag = "B" Then Open_Bal = Open_Bal + Pick.extractcur(gl_rec, 32, 1, 0)
        End If
     End If
     
     tran_bal = 0
     sentence = "SSELECT GL_TRANS WITH A3 = """ & gl_ac & """ BY date"
     total_items = d3.d3_select(logentry, sentence, mylist(), pick_cnt, 0, 0) - 1
     For kk = 0 To total_items
        trid = mylist(kk)
        If d3.d3_readstr(database, tr_rec, "GL_TRANS", trid) <> 0 Then GoTo 3190
        tr_code = Pick.extractint(tr_rec, 1, 0, 0)
        Tr_Date = Pick.extractint(tr_rec, 7, 0, 0)
        Amount = -Pick.extractcur(tr_rec, 4, 0, 0)
' THE - SO THAT SIGNS REVERSED TO CONFORM TO OLD METHOD
' OLD GL HAS DEBITS -VE AND CREDIT S +VE
' THEY ARE THEN MADE TO ACCORD TO CORRECTNESS BY SIGN* (ALWAYS -1)
' SO NEW GL_TRANS HAS DEBITS +VE AND NO SIGN NEEDED
        If commitflag = "A" Then
           If tr_code = 81 Or tr_code = 18 Then GoTo 3190
        Else
           If commitflag = "C" Then
              If tr_code <> 81 And tr_code <> 18 Then GoTo 3190
           End If
        End If
        If pl_from_year_start And acc_type = "C" Then
           If Tr_Date < sb_date Then
              If Tr_Date >= start_of_year Then
                 Open_Bal = Open_Bal + Amount
              End If
              GoTo 3190
           End If
        End If
        If Tr_Date < sb_date Then
           Open_Bal = Open_Bal + Amount
           GoTo 3190
        End If
        If Tr_Date > tb_date Then GoTo 3200
        tran_bal = tran_bal + Amount
3190 Next kk
3200 Exit Sub

End Sub
Public Function ta511(logentry As String, parms As String)

' TA511  Print GL Trial Balance to selected date

Dim Pldate As Integer, Commit As Integer, all_groups As String, Cc As Integer, rcnt As Integer
Dim gl_sc As String, gl_cl As String, gl_gp As String, gl_rec As String, Gl_Accts As String, Tb, Tt
Dim Tot_Open_Dr As Currency, Tot_Open_Cr As Currency, Tot_Tran_Dr As Currency
Dim Tot_Tran_Cr As Currency, Tot_Close_Dr As Currency, Tot_Close_Cr As Currency, Tot_Acc_Open_Dr As Currency, Tot_Acc_Open_Cr As Currency
Dim Tot_Acc_Tran_Dr As Currency, Tot_Acc_Tran_Cr As Currency, Tot_Acc_Close_Dr As Currency, Tot_Acc_Close_Cr As Currency
Dim Tot_Cl_Open_Dr As Currency, Tot_Cl_Open_Cr As Currency, Tot_Cl_Tran_Dr As Currency, Tot_Cl_Tran_Cr As Currency
Dim Tot_Cl_Close_Dr As Currency, Tot_Cl_Close_Cr As Currency, Tot_Gp_Open_Dr As Currency, Tot_Gp_Open_Cr As Currency
Dim Tot_Gp_Tran_Dr As Currency, Tot_Gp_Tran_Cr As Currency, Tot_Gp_Close_Dr As Currency, Tot_Gp_Close_Cr As Currency
Dim Irow, commitflag As String
Dim Ii As Integer, Noz As String, Num, sb_date As Integer
Dim tb_date As Integer, Wantrt As String
Dim All_Group_Ct As Integer, Gp_Open_Dr As Currency
Dim Gp_Open_Cr As Currency, Gp_Tran_Dr As Currency, Gp_Tran_Cr As Currency, Gp_Close_Dr As Currency, Gp_Close_Cr As Currency
Dim Gr_L, Pline As String, Class_Limit As Integer, Class As Integer, Gp_Open_Bal As Currency, Gp_Tran_Bal As Currency
Dim Gp_Close_Bal, Maxct, I As Integer, Pl1, Pl2, Jj As Integer, Cl_Open_Bal As Currency, Cl_Tran_Bal As Currency
Dim Max_Ii As Integer, group As String, sub_class As String
Dim Acc_Name, Rt, kk As Integer, Pl, Open_Bal As Currency, tran_bal As Currency
Dim Direction, The_Key, tr_code, Tr_Date, Amount, Gl_Ovflow, St_Oflow
Dim Okey, k As Integer, Close_Bal, Ll As Integer
Dim pt_line As String
Dim database As String, rderr As Integer, temp As String, Cls As String, subl As String
Dim fso, textfile
Dim LCNT As Long, lines() As String
Dim dr_openbal As Currency, dr_openbalstr As String, cr_openbalstr As String
Dim dr_tranbal As Currency, dr_tranbalstr As String, cr_tranbalstr As String
Dim dr_closebal As Currency, dr_closebalstr As String, cr_closebalstr As String

      database = Pick.extract(logentry, 2, 0, 0)
     
      If UBound(g_trans_info_array) = 0 Then
         g_trans_info_array(0) = "TRANS.INFO"
         rderr = d3.d3_readmat(database, g_trans_info_array(), "DICT TRANS.J")
      End If
      If UBound(g_trans_info_array) < 130 Then ReDim Preserve g_trans_info_array(130)
      
     'If d3.d3_readstr(Company, "DICT GEN.L", "@COMPANY") <> 0 Then Company = ""

     'Cfgrp = "": Ctgrp = ""
     Pldate = Pick.extractint(g_trans_info_array(7), 1, 1, 0) + 1
     temp = Mid$(g_trans_info_array(130), 1, 1)
     If IsNumeric(temp) Then Commit = CInt(temp) Else Commit = 0
     Cc = 0
     Tb = "***** TRIAL BALANCE *****"
     Tt = "*****     TOTAL     *****"
     'Gop = "*****     GROUP     *****"
     Cls = "*****     CLASS     *****"
     subl = "*****   SUBCLASS    *****"
'
     all_groups = ""
     Tot_Open_Dr = 0: Tot_Open_Cr = 0
     Tot_Tran_Dr = 0: Tot_Tran_Cr = 0
     Tot_Close_Dr = 0: Tot_Close_Cr = 0
     Tot_Acc_Open_Dr = 0: Tot_Acc_Open_Cr = 0
     Tot_Acc_Tran_Dr = 0: Tot_Acc_Tran_Cr = 0
     Tot_Acc_Close_Dr = 0: Tot_Acc_Close_Cr = 0
     Tot_Cl_Open_Dr = 0: Tot_Cl_Open_Cr = 0
     Tot_Cl_Tran_Dr = 0: Tot_Cl_Tran_Cr = 0
     Tot_Cl_Close_Dr = 0: Tot_Cl_Close_Cr = 0
     Tot_Gp_Open_Dr = 0: Tot_Gp_Open_Cr = 0
     Tot_Gp_Tran_Dr = 0: Tot_Gp_Tran_Cr = 0
     Tot_Gp_Close_Dr = 0: Tot_Gp_Close_Cr = 0
'
     commitflag = Pick.extract(parms, 1, 0, 0)
     Noz = Pick.extract(parms, 2, 0, 0)
     sb_date = Pick.extractint(parms, 3, 0, 0)
     tb_date = Pick.extractint(parms, 4, 0, 0)
     Wantrt = Pick.extract(parms, 5, 0, 0)
     all_groups = Pick.extract(parms, 6, 0, 0)
     If all_groups = "" Then
        If d3.d3_readstr(database, all_groups, "DICT GEN.L", "XGRP") <> 0 Then all_groups = ""
     End If
     
        Select Case commitflag
           Case "A"
           Case "B"
              'Headp$ = Headp$ & " - Actuals & Commitments"
           Case "C"
              'Headp$ = Headp$ & " - Commitments"
        End Select
'
     Cc = 0
     'If Sbdte >= Pldate Then
110  '   Imsg = "Do you want P & L section as from " & pick.oconv(CStr(Pldate), "D2") & " only ? (Y/N) &   "
     'End If
'
     ta511 = ckaiis.rtf_open(logentry, fso, textfile, ".asp")
     temp = "<TABLE cellspacing=1 cellpadding=1 border=1 WIDTH=95%><TR CLASS=top><TD COLSPAN=9 ALIGN=CENTER>General Ledger Trial Balance as at " & Now & "from " & Pick.oconv(CStr(sb_date), "D2") & " to " & Pick.oconv(CStr(tb_date), "D2") & "<TR CLASS=TOP><TH>Account<TH>Description<TH>Report Type<TH colspan=2>Opening<TH colspan=2>Transaction<TH colspan=2>Closing<TR class=top><TH><TH><TH><TH>Debit<TH>Credit<TH>Debit<TH>Credit<TH>Debit<TH>Credit"
     textfile.WriteLine (temp)
     LCNT = -1
'
200  For All_Group_Ct = 1 To Pick.dcount(all_groups, Chr(253))
        group = Pick.extract(all_groups, 1, All_Group_Ct, 0)
        If group = "" Then GoTo 220
        If d3.d3_readstr(database, Gl_Accts, "DICT GEN.L", "X" & group) <> 0 Then GoTo 210
        GoSub 1000
        For k = UBound(lines) To 0 Step -1
           dr_openbal = Pick.extractcur(lines(k), 3, 0, 0)
           If dr_openbal < 0 Then
              dr_openbalstr = FormatCurrency(-dr_openbal / 100, 2)
              cr_openbalstr = ""
              Tot_Open_Dr = Tot_Open_Dr - dr_openbal
           Else
              dr_openbalstr = ""
              If dr_openbal = 0 Then cr_openbalstr = "" Else cr_openbalstr = FormatCurrency(dr_openbal / 100, 2)
              Tot_Open_Cr = Tot_Open_Cr + dr_openbal
           End If
           dr_tranbal = Pick.extractcur(lines(k), 4, 0, 0)
           If dr_tranbal < 0 Then
              dr_tranbalstr = FormatCurrency(-dr_tranbal / 100, 2)
              cr_tranbalstr = ""
              Tot_Tran_Dr = Tot_Tran_Dr - dr_tranbal
           Else
              dr_tranbalstr = ""
              If dr_tranbal = 0 Then cr_tranbalstr = "" Else cr_tranbalstr = FormatCurrency(dr_tranbal / 100, 2)
              Tot_Tran_Cr = Tot_Tran_Cr + dr_tranbal
           End If
           dr_closebal = dr_openbal + dr_tranbal
           If dr_closebal < 0 Then
              dr_closebalstr = FormatCurrency(-dr_closebal / 100, 2)
              cr_closebalstr = ""
              Tot_Close_Dr = Tot_Close_Dr - dr_closebal
           Else
              dr_closebalstr = ""
              If dr_closebal = 0 Then cr_closebalstr = "" Else cr_closebalstr = FormatCurrency(dr_closebal / 100, 2)
              Tot_Close_Cr = Tot_Close_Cr + dr_closebal
           End If
           temp = "<TR><TD ALIGN=LEFT>" & Pick.extract(lines(k), 1, 0, 0) & "<TD>" & Pick.extract(lines(k), 2, 0, 0) & "<TD ALIGN=LEFT>" & Pick.extract(lines(k), 5, 0, 0) & "<TD>" & dr_openbalstr & "<TD>" & cr_openbalstr & "<TD>" & dr_tranbalstr & "<TD>" & cr_tranbalstr & "<TD>" & dr_closebalstr & "<TD>" & cr_closebalstr
           textfile.WriteLine (temp)
        Next k
        LCNT = -1
        ReDim lines(0)
210  Next All_Group_Ct

220  textfile.WriteLine ("</TABLE>")
     textfile.WriteLine ("</BODY>")
     textfile.WriteLine ("</HTML>")
     Set textfile = Nothing
     Set fso = Nothing
     Exit Function
'
' s/r 1000:  process group level
'
1000 gl_gp = group & ".0"
     Gp_Open_Bal = 0: Gp_Tran_Bal = 0

     Class_Limit = Pick.dcount(Gl_Accts, Chr(254))
     For Class = Class_Limit To 1 Step -1
        If Pick.extract(Gl_Accts, Class, 0, 0) <> "" Then GoSub 2000
     Next Class
     If d3.d3_readstr(database, gl_rec, "GEN.L", gl_gp) <> 0 Then gl_rec = Chr(254) & "?? ACCOUNT MISSING ??"
     LCNT = LCNT + 1
     ReDim Preserve lines(LCNT)
     lines(LCNT) = gl_gp & Chr(254) & Pick.extract(gl_rec, 2, 0, 0) & Chr(254) & Gp_Open_Bal & Chr(254) & Gp_Tran_Bal
     Return
'
' process class levels
'
2000 gl_cl = group & "." & Class
     Cl_Open_Bal = 0: Cl_Tran_Bal = 0
     Max_Ii = Pick.dcount(Pick.extract(Gl_Accts, Class, 0, 0), Chr(253))
     For Ii = Max_Ii To 2 Step -1
        sub_class = Pick.extract(Gl_Accts, Class, Ii, 0)
        GoSub 3000
     Next Ii
     If d3.d3_readstr(database, gl_rec, "GEN.L", gl_cl) <> 0 Then gl_rec = Chr(254) & "?? ACCOUNT MISSING ??"
     LCNT = LCNT + 1
     ReDim Preserve lines(LCNT)
     lines(LCNT) = gl_cl & Chr(254) & Pick.extract(gl_rec, 2, 0, 0) & Chr(254) & Cl_Open_Bal & Chr(254) & Cl_Tran_Bal
     Gp_Open_Bal = Gp_Open_Bal + Cl_Open_Bal
     Gp_Tran_Bal = Gp_Tran_Bal + Cl_Tran_Bal
     Return
'
' process sub-class levels
'
3000 gl_sc = group & "." & Class & "." & sub_class
     If d3.d3_readstr(database, gl_rec, "GEN.L", gl_sc) <> 0 Then gl_rec = Chr(254) & "?? ACCOUNT MISSING ??"
     Call gl_account_balances(logentry, gl_sc, gl_rec, commitflag, Cc, Pldate, sb_date, tb_date, Open_Bal, tran_bal)
     If Noz = "Y" And Open_Bal = 0 And tran_bal = 0 Then Return
     Acc_Name = Pick.extract(gl_rec, 2, 0, 0)
     If Pick.extract(gl_rec, 23, 0, 0) = "1" Then Acc_Name = Acc_Name & " " & "(CLOSED)"
     Rt = Pick.extract(gl_rec, 31, 0, 0)
     LCNT = LCNT + 1
     ReDim Preserve lines(LCNT)
     lines(LCNT) = gl_sc & Chr(254) & Acc_Name & Chr(254) & Open_Bal & Chr(254) & tran_bal & Chr(254) & Rt
     Cl_Open_Bal = Cl_Open_Bal + Open_Bal
     Cl_Tran_Bal = Cl_Tran_Bal + tran_bal
     Return

End Function

Public Function ta194(logentry As String, sentence As String, parms As String) As String
' TA194 REPORT ON OUTSTANDING INVOICES
Dim Rel As String
Dim gtotal As Currency, grun_bal As Currency
Dim gdisc As Currency, gpps As Currency
Dim total_items As Long, kk As Long, Tr_Ref As String
Dim Client_No As String, cr_sec As String
Dim Name As String, GIVEN As String
Dim pclient As String, Cr_Cur_Bal As Currency, run_bal As Currency, totdisc As Currency, bal_missed As Currency, totpps As Currency
Dim Tr_Desc As String, foundtrans As Integer, Tr_Narr As String
Dim Usa As String, Chq As String, chq2 As String
Dim cr_terms As String, cr_related As Integer, Discflag As String, cr_ppsno As String, CR_PPS_RATE As Currency
Dim cr_rel_msg As String, Pps_Flg As String, rderr As Integer
Dim relate As String, temp As String
Dim st_po As String, po_total As Currency, rel_total As Currency, rel_disc As Currency, rel_pps As Currency
Dim Client_Rec As String, Cr_Rec As String, Inz As Integer
Dim cr_post As String, tr_type As Integer, tr_bal As Currency, tr_amt As Currency
Dim pcr_related As String, DEF_DISCOUNTS As String, Tr_Disc As Currency
Dim usebal As Currency, Tr_Payment As Currency, balmsg As String
Dim Maxn As Integer, Ii As Integer, Mulnarr As String
Dim Disc_Apply As String, pps_apply As String, Openitem As String
Dim Msg As String, great_amt As Currency, draw_amt As Currency
Dim mylist() As String, mycreditors() As String, pick_cnt As Long, led As String, DISC_DATE As Integer, Due_Date As Integer
Dim ff As Integer, fff As Integer, SETONLY As String, datedue As Integer, datedue_str As String
Dim useterms As String, Newterms As String, REMFLAG As String
Dim Account As String, Cphead As String, no_auto_sel As String
Dim lastrec As String, Last As Integer, chq_req_rec As String, tj_tno As String
Dim Author As String, rec As String
Dim Tr_Date As Integer, tr_date_str As String, Disc_Apply_Date As String
Dim Tr_Pps As String, startr As Integer, tjdate As Integer, trec As String
Dim cr_author As String, cr_remit As String, cr_discount As String
Dim Yespay As Integer, Mm As Long, run_amt As Currency, Narr As String
Dim database As String, trid As String
Dim fso, textfile

      On Error GoTo ta194_error
      
      database = Pick.extract(logentry, 2, 0, 0)
     
      If d3.d3_readstr(database, Account, "DICT RR.LOG", "4", 2, 1, 1) <> 0 Then Account = ""
      temp = d3.execute_tcl(logentry, "WHO", "")
      tj_tno = Right("000" & Pick.field(temp, " ", 1), 3)
      
      Due_Date = CInt(Pick.extract(parms, 1, 0, 0))
      temp = Pick.extract(parms, 2, 0, 0)
      If IsNumeric(temp) Then DISC_DATE = CInt(temp) Else DISC_DATE = -1
      SETONLY = Pick.extract(parms, 3, 0, 0)
      temp = Pick.extract(parms, 4, 0, 0)
      If IsNumeric(temp) Then draw_amt = CCur(temp) Else draw_amt = -1
      temp = Pick.extract(parms, 5, 0, 0)
      If IsNumeric(temp) Then great_amt = CCur(temp) Else great_amt = -1
      tjdate = CInt(Pick.extract(parms, 6, 0, 0)) 'ledger date for chqs
      led = Pick.extract(parms, 7, 0, 0) '"Do you want to print ledger numbers on report (Y/N)? "
      temp = Pick.extract(parms, 8, 0, 0)
      If IsNumeric(temp) Then startr = CInt(temp) Else startr = -1
       
      If UBound(g_trans_info_array) = 0 Then
         g_trans_info_array(0) = "TRANS.INFO"
         rderr = d3.d3_readmat(database, g_trans_info_array(), "DICT TRANS.J")
      End If
      If UBound(g_trans_info_array) < 113 Then ReDim Preserve g_trans_info_array(113)
      Author = g_trans_info_array(25): If Author = "" Then Author = "0"
      Usa = g_trans_info_array(106): If Usa = "1" Then Chq = "Check": chq2 = "check" Else Chq = "Cheque": chq2 = "cheque"
      Discflag = Pick.extract(g_trans_info_array(38), 1, 2, 0): If Discflag = "" Then Discflag = "0"
      Newterms = Pick.extract(g_trans_info_array(38), 1, 3, 0): If Newterms = "" Then Newterms = "0"
      Openitem = Mid((g_trans_info_array(49)), 4, 1): If Openitem = "" Or Openitem = " " Then Openitem = "0"
      
      REMFLAG = Mid$((g_trans_info_array(49)), 1, 1)
      If Not (IsNumeric(REMFLAG)) Then REMFLAG = "0"
      no_auto_sel = Mid$(g_trans_info_array(49), 13, 1)
      If Not (IsNumeric(no_auto_sel)) Then REMFLAG = "0"
      cr_sec = Mid(g_trans_info_array(49), 18, 1): If cr_sec = "" Then cr_sec = "0"
      Pps_Flg = Pick.extract(g_trans_info_array(113), 1, 1, 0): If Pps_Flg = "" Then Pps_Flg = "0"
       
      ta194 = ckaiis.rtf_open(logentry, fso, textfile, ".asp")
      temp = "<TABLE cellspacing=1 cellpadding=1 border=1 WIDTH=95%><TR CLASS=top><TH COLSPAN=14 ALIGN=CENTER>194 Report on Outstanding Invoices as at " & Now & " due to " & Pick.oconv(CStr(Due_Date), "D2")
      If startr <> -1 Then temp = temp & "COMMENCING FROM " & Format(startr, "dd mmm yy") & " "
      If DISC_DATE <> -1 Then
         temp = temp & "<TR CLASS=top><TH COLSPAN=14 ALIGN=CENTER>Discounts Calculated as at " & Pick.oconv(CStr(DISC_DATE), "D2")
         If SETONLY = "Y" Then temp = temp & ". Only items with settlement discount" Else temp = temp & ". All items with or without settlement discount"
      End If
      textfile.WriteLine (temp)
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
        temp = Pick.extract(lastrec, 2, 0, 0)
        If IsNumeric(temp) Then Last = CInt(temp) Else Last = 0
        Last = Last + 1: lastrec = Pick.replace(lastrec, 2, 0, 0, CStr(Last))
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
   
      sentence = replace(sentence, Chr(8), """")
      total_items = d3.d3_select(logentry, sentence, mycreditors(), pick_cnt, 0, 0) - 1
      If total_items = 0 Then ta194 = Chr(8) & "No creditors for " & sentence: Exit Function
   
      sentence = "sselect cr_trans by a1 by trdate with trbal # ""0"" "
      total_items = d3.d3_select(logentry, sentence, mylist(), pick_cnt, 0, 0) - 1
      If total_items = 0 Then ta194 = Chr(8) & "No transactions for " & sentence: Exit Function
      
      pclient = Chr(8)
      run_bal = 0: totdisc = 0: totpps = 0: run_amt = 0
      
      For kk = 0 To total_items
         trid = mylist(kk)
         If d3.d3_readstr(database, trec, "CR_TRANS", trid) <> 0 Then trec = ""
         Client_No = Pick.extract(trec, 1, 0, 0)
         If Client_No = "6683" Then MsgBox Client_No
         For Mm = 0 To UBound(mycreditors)
            If Client_No = mycreditors(Mm) Then GoTo 112
         Next Mm
         GoTo 890 ' creditor not wanted
      
112:  If pclient = Chr(8) Then pclient = Client_No
If Client_No = "6683" Then MsgBox Client_No & "=here"
      If Client_No <> pclient Then GoSub client_subtotal

      If d3.d3_readstr(database, Client_Rec, "CLIENT", Client_No) <> 0 Then Client_Rec = ""
      If d3.d3_readstr(database, Cr_Rec, "CREDITOR", Client_No) <> 0 Then Cr_Rec = ""
      Rel = Pick.extract(Cr_Rec, 3, 0, 0): If Rel = "" Then Rel = "0"
'      If cr_sec And pick.extract(operator, 4, 0, 0) <> "" Then
'         FOR III=1 TO 999 UNTIL OPERATOR=PICK.REPLACE(OPERATOR,4,1,III,"")
'            REL2 = pick.extract(operator, 4, 1, iii)
'            If rel = REL2 Then GoTo 215
'         Next iii
'         GoTo 890
'      End If
215   Name = Pick.extract(Client_Rec, 1, 1, 0)
      GIVEN = Pick.extract(Client_Rec, 7, 0, 0)
      
'
' BEGIN PRINT OF TRANSACTIONSt
'
      Cr_Cur_Bal = Pick.extractcur(Cr_Rec, 1, 0, 0)
      
      cr_terms = Pick.extract(Cr_Rec, 2, 0, 0)
      If cr_terms = "" Then cr_terms = "30"
      foundtrans = 0
      cr_post = Pick.extract(Cr_Rec, 15, 0, 0)
      temp = Pick.extractint(Cr_Rec, 3, 0, 0)
      If IsNumeric(temp) Then cr_related = CInt(temp) Else cr_related = 1
      pcr_related = temp
      If Discflag <> "0" Then DEF_DISCOUNTS = Pick.extract(Cr_Rec, 30, 0, 0)
      cr_ppsno = Pick.extract(Cr_Rec, 37, 1, 0)
      CR_PPS_RATE = 0
      If Pps_Flg <> "0" Then
         If d3.d3_readstr(database, temp, "PPS.PAYEE", cr_ppsno, 9) <> 0 Then temp = ""
         If IsNumeric(temp) Then CR_PPS_RATE = CCur(temp) Else CR_PPS_RATE = 0
      End If
      cr_rel_msg = Pick.extract(relate, cr_related + 1, 0, 0)
      If cr_rel_msg <> "" Then cr_rel_msg = "(" & cr_rel_msg & ")"

      cr_author = Pick.extract(trec, 10, 0, 0)
      cr_remit = Pick.extract(trec, 11, 0, 0)
      cr_discount = Pick.extract(trec, 15, 0, 0)
      Tr_Pps = Pick.extract(trec, 17, 0, 0) ''''**** NOTE TR.PPS CAN CONTAIN Y\override amt
      Tr_Date = Pick.extractint(trec, 2, 0, 0)
      tr_type = Pick.extractint(trec, 3, 0, 0)
      Tr_Ref = Pick.extract(trec, 4, 0, 0)
      tr_amt = Pick.extractcur(trec, 5, 0, 0)
      tr_bal = Pick.extractcur(trec, 6, 0, 0)
      Tr_Narr = Pick.extract(trec, 7, 0, 0)
'
      If Openitem = "0" And tr_type >= 50 Then GoTo 890
      If tr_type >= 50 Then tr_bal = -tr_bal: tr_amt = -tr_amt
      If Openitem = "0" And tr_bal <= 0 Then GoTo 890
      If Newterms <> "0" Then
         useterms = Pick.extract(trec, 16, 0, 0)
         If useterms = "" Then useterms = cr_terms
      Else
         useterms = cr_terms
      End If
      If IsNumeric(useterms) Then datedue = Tr_Date + CInt(useterms) Else datedue = Tr_Date
      If datedue > Due_Date Then GoTo 890
      Disc_Apply = "": Tr_Disc = 0: Disc_Apply_Date = ""
      pps_apply = ""
'
      Call SR211(database, Author, cr_author, Tr_Payment, tr_amt, tr_bal, Discflag, tr_type, DISC_DATE, Tr_Date, cr_discount, DEF_DISCOUNTS, Tr_Disc, REMFLAG, cr_remit, Yespay, SETONLY, Disc_Apply, Disc_Apply_Date, Pps_Flg, CR_PPS_RATE, Tr_Pps)
'
      If Yespay = 0 Then GoTo 890
      If Disc_Apply_Date <> "" Then
'           DISC_APPLY_DATE = "by " & oconv(tr_date + DISC_APPLY_DATE, "D2")
      End If
         If Disc_Apply <> "" Then
'           DISC_APPLY=SPACE(40+ADJ) & ("Discount of " & DISC_APPLY & "% if paid " & DISC_APPLY_DATE) "L<>40" & OCONV(-TR_DISC,"MD2") "R2<>10"
'           IF pick.extract(TR_PPS,1,1,1) = "" THEN DISC_APPLY=DISC_APPLY & " " & OCONV(TR_PAYMENT,"MD2") "R2<>10"
         End If
         If Pick.extract(Tr_Pps, 1, 1, 1) <> "" Then
'           PPS_APPLY=SPACE(40+ADJ) & "Prescribed Payments tax  " "L<>40" & OCONV(pick.extract(-TR_PPS,1,1,1),"MD2") "R2<>10" & " " & OCONV(TR_PAYMENT,"MD2") "R2<>10"
         End If
         If Openitem <> "0" And startr <> -1 And Tr_Date < startr Then
           bal_missed = bal_missed + tr_bal
           GoTo 890
         End If

      Tr_Desc = ""
      If tr_type <> 0 Then Tr_Desc = Pick.extract(g_trans_info_array(3), 1, tr_type, 0)
      If Tr_Desc = "" Then Tr_Desc = CStr(tr_type)
      foundtrans = 1
      If Pps_Flg <> "0" Then usebal = tr_bal Else usebal = Tr_Payment
      run_bal = run_bal + usebal: totdisc = totdisc + Tr_Disc: run_amt = run_amt + tr_amt
      totpps = totpps + Pick.extractcur(Tr_Pps, 1, 1, 1)
'
      rel_total = rel_total + tr_bal: rel_disc = rel_disc + Tr_Disc
      rel_pps = rel_pps + Pick.extractcur(Tr_Pps, 1, 1, 1)
      tr_date_str = Format(Tr_Date, "dd mmm yy"): tr_date_str = Mid$(tr_date_str, 1, 2) & Mid$(tr_date_str, 4, 3) & Mid$(tr_date_str, 8, 2)
      datedue_str = Format(datedue, "dd mmm yy"): datedue_str = Mid$(datedue_str, 1, 2) & Mid$(datedue_str, 4, 3) & Mid$(datedue_str, 8, 2)
      temp = "<TR><TD>" & pcr_related
      temp = temp & "<TD>" & pclient & "<TD> " & Name & " " & GIVEN & "<TD>" & Tr_Ref & "<TD>" & Tr_Desc & "<TD NOWRAP>" & Pick.oconv(CStr(Tr_Date), "D2") & "<TD NOWRAP>" & Pick.oconv(CStr(datedue), "D2") & "<TD align=right>" & Format(tr_amt / 100, "#.00")
      temp = temp & "<TD align=right>" & Format(usebal / 100, "#.00") & "<TD align=right>" & Format(Tr_Disc / 100, "#.00") & "<TD align=right>" & Format(-Pick.extractcur(Tr_Pps, 1, 1, 1) / 100, "#.00")
      
      'If run_bal > 0 Then
      '      If totdisc Then
      '         temp = "<TR><TD colspan=8><B>Total discount to be claimed</B><TD><B>" & Format(-totdisc / 100, "#.00") & "</B>"
      '         textfile.WriteLine (temp)
      '      End If
      '      If totpps Then
      '         temp = "<TR><TD colspan=8><B>Total Prescribed Payments due</B><TD><B>" & Format(-totpps / 100, "#.00") & "</B>"
      '         textfile.WriteLine (temp)
      '      End If
      '      If totdisc Or totpps Then
      '         temp = "<TR><TD colspan=8><B>Net amount for payment</B><TD><B>" & Format((run_bal - totdisc - totpps) / 100, "#.00") & "</B>"
      '         textfile.WriteLine (temp)
      '      End If
      '   End If
      
      
      
      temp = temp & "<TD align=right>" & Format(Tr_Payment / 100, "#.00")
      If tr_amt <> tr_bal And (Disc_Apply <> "" Or pps_apply <> "") Then
        balmsg = "Previously paid " & Format((tr_bal - tr_amt) / 100, "#.00")
      Else
        balmsg = ""
      End If
      'If pps_apply <> "" Then Tr_Narr = pps_apply & Chr(253) & Tr_Narr
      'If Disc_Apply <> "" Then Tr_Narr = Disc_Apply & Chr(253) & Tr_Narr
      'If balmsg <> "" Then Tr_Narr = balmsg & Chr(253) & Tr_Narr
      temp = temp & "<TD>"
      For Ii = 1 To Pick.dcount(Tr_Narr, Chr(252))
          Narr = Pick.extract(Tr_Narr, 1, 1, Ii)
          If Narr <> "" Then
             If Ii <> 1 Then Narr = "<BR>" & Narr
             temp = temp & Narr
          End If
      Next Ii
      If led = "Y" And tr_type = 25 Then temp = temp & "<TD>" & replace(Pick.extract(trec, 8, 0, 0), Chr(252), ",")
      textfile.WriteLine (temp)
890:
   Next kk
   
     GoSub client_subtotal
     temp = "<TR><TD colspan=7><B>Grand Totals for payment by " & Pick.oconv(CStr(Due_Date), "d2") & "</B><TD align=right nowrap><B>" & Format(gtotal / 100, "#.00") & "</B><TD align=right nowrap><B>" & Format(grun_bal / 100, "#.00") & "</B><TD align=right nowrap><B>" & Format(-gdisc / 100, "#.00") & "</B><TD align=right nowrap><B>" & Format(-gpps / 100, "#.00") & "</B><TD align=right nowrap><B>" & Format((grun_bal - gdisc - gpps) / 100, "#.00") & "</B>"
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
       
     temp = temp & "<TD colspan=4><B>Totals for payment by " & Pick.oconv(CStr(Due_Date), "d2") & "</B><TD align=right nowrap><B>" & Format(run_amt / 100, "#.00") & "</B><TD align=right nowrap><B>" & Format(run_bal / 100, "#.00") & "</B><TD align=right nowrap><B>" & Format(-totdisc / 100, "#.00") & "</B><TD align=right nowrap><B>" & Format(-totpps / 100, "#.00") & "</B><TD align=right nowrap><B>" & Format((run_bal - totdisc - totpps) / 100, "#.00") & "</B>"
        
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
        gdisc = gdisc + totdisc
        gpps = gpps + totpps
        grun_bal = grun_bal + run_bal
     End If
'
     If Openitem <> "0" And bal_missed Then
        temp = "<TR><TD colspan=7>** Balance of transactions prior to " & Pick.oconv(CStr(startr), "D2") & " and NOT reported = " & "<TD>" & Format(bal_missed / 100, "#.00") & " **"
        textfile.WriteLine (temp)
     End If
     run_bal = 0: totdisc = 0: bal_missed = 0: totpps = 0
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
Dim dd As Integer, sorting As String, Indx As Integer, ass As String, grp_num As String, Ans As String
Dim fso, textfile, kk As Integer, temp As String, database As String, rderr As Integer
Dim total_items As Long, pick_cnt As Long, mylist() As String, Row As Integer
'
      database = Pick.extract(logentry, 2, 0, 0)
      
      If UBound(g_trans_info_array) = 0 Then
         g_trans_info_array(0) = "TRANS.INFO"
         rderr = d3.d3_readmat(database, g_trans_info_array(), "DICT TRANS.J")
      End If
      If UBound(g_trans_info_array) < 130 Then ReDim Preserve g_trans_info_array(130)
      
      Yrbegin = Pick.extractint(g_trans_info_array(8), 1, 1, 0)
      'Grp = Mid$((pick.extract(Trans_Info, 73, 0, 0)), 2, 1) + 0
      'Bylocn = Mid$(pick.extract(Trans_Info, 73, 0, 0), 4, 1) + 0 ' 1=LOCN BY GROUP 2 LOCN BY CLASS
      'Special_Grp = Mid$(pick.extract(Trans_Info, 73, 0, 0), 7, 1) + 0
      temp = Mid$(g_trans_info_array(73), 10, 1)
      If IsNumeric(temp) Then soils = CInt(temp) Else soils = 0
'
      run_type = "A"
      dd = Pick.extractint(parms, 1, 0, 0)
      Totsonly = Pick.extract(parms, 2, 0, 0)
      sorting = Pick.extract(parms, 3, 0, 0)
      Select Case sorting
         Case "BY LOCN BY PROJECT BY GROUP BY ASSET.NO": bylocn = 1: soils = 1
         Case "BY LOCN BY GROUP BY ASSET.NO": bylocn = 1
         Case "BY LOCN BY CLASS BY ASSET.NO": bylocn = 2
         Case "BY GL.ACC BY ASSET.NO": bylocn = 0: Grp = 0
         Case "BY TYPE BY CLASS BY GROUP BY PUR_DATE BY ASSET.NO": bylocn = 0: Grp = 1
      End Select
      sentence = sentence & " " & sorting
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
      If run_type = "A" Then Indx = 0 Else Indx = 7

      ta1465 = ckaiis.rtf_open(logentry, fso, textfile, ".asp")
      temp = "<TABLE cellspacing=1 cellpadding=1 border=1 WIDTH=95%><TR CLASS=top><TD colspan=14 align=center>Asset Register as at " & Now & " to " & Pick.oconv(CStr(dd), "D2") & "<TR CLASS=TOP><TH><TH><TH><TH><TH><TH><TH><TH colspan=5>Depreciation<TH colspan=3>Disposal<TR class=top><TH>Asset<TH>Description<TH>Group<TH>Location<TH>Purchase Date<TH>Purchase Price<TH>Current Depreciated Value<TH>Type<TH>Rate<TH>Freq<TH>Current Year<TH>Life to Date<TH>Date<TH>Price<TH>Reference"
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
      If d3.d3_readstr(database, ass, "ASSET", Assetno) <> 0 Then GoTo 290
      Locn = Pick.extract(ass, 4, 0, 0)
      If soils Then Locn = Locn & "," & Pick.extract(ass, 61, 0, 0)
      If bylocn Then
         If bylocn = 1 Or soils Then
            If Locn <> St_Code Or Pick.extract(ass, 37, 0, 0) <> St_Group Then ' TEST FOR CHANGE IN LOCATION
                If St_Group <> "" Then GoSub 940
                St_Group = Pick.extract(ass, 37, 0, 0)
                If Locn <> St_Code Then
                   If St_Code <> "" Then GoSub 950       ' PRINT PRIOR TOTAL
                   St_Code = Locn
                   If d3.d3_readstr(database, Locn_Desc, "LOCATION", Pick.field(St_Code, ",", 1), 1) <> 0 Then Locn_Desc = "** INVALID LOCATION **"
                   GoSub 900                  ' PRINT NEW PAGE HEADINGS
                End If
            End If
         Else
            'If Special_Grp Then
            '   If d3.d3_readstr(database, Ccode, "ASSET.GROUP", pick.extract(ass, 37, 0, 0), 2) <> 0 Then Ccode = "*** INVALID CLASS ***"
            'Else
               Ccode = Pick.extract(ass, 97, 0, 0): If Ccode = "" Then Ccode = "?"
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
               Ccode = Pick.extract(ass, 97, 0, 0): If Ccode = "" Then Ccode = "?"
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
            If Pick.extract(ass, 1, 0, 0) <> St_Code Then           ' TEST FOR CHANGE IN GL A/C NUMBER
                If St_Code <> "" Then GoSub 950       ' PRINT PRIOR TOTAL
                St_Code = Pick.extract(ass, 1, 0, 0)
                If d3.d3_readstr(database, Gl_Ac_Desc, "ASSET.CODES", St_Code, 2) <> 0 Then Gl_Ac_Desc = "** INVALID GL A/C **"
                GoSub 900                  ' PRINT NEW PAGE HEADINGS
            End If
         End If
     End If
'
      If run_type = "A" Then Price = Pick.extractcur(ass, 6, 0, 0) Else Price = Pick.extractcur(ass, 22, 0, 0)
      If Pick.locate(CStr(dd), ass, 11, 1, 0, Pos, "DR") = 0 Then Pos = 1
      depd_val = Pick.extractcur(ass, 12 + Indx, Pos, 0)
      Ltd_Depn = Price - depd_val
      Ltd_Depn = Ltd_Depn / 100
      depd_val = depd_val / 100
      Open_Bal = Pick.extractcur(ass, 13 + Indx, 0, 0)
      Dis_Open = Open_Bal
      If Pick.extractint(ass, 5, 0, 0) > Yrbegin And Open_Bal = 0 Then Open_Bal = Price
      Price = Price / 100
      Dis_Open = Dis_Open / 100
      Ytd_Depn = Open_Bal / 100 - depd_val
      grp_num = Pick.extract(ass, 37, 0, 0)
      If Totsonly = "N" Then
'        PRINT ASSETNO'L#9':' ':ASS<3,1>'L#22':GRP.NUM"R#6":SPACE(1):LOCN'R#4':SPACE(1):pick.oconv(ASS<5>,'D2'):PRICE'R2$,#13':ASS<2>'R#12':SPACE(4):ASS<7+INDX>"L#2":pick.oconv(ASS<8+INDX>,'MD2')'R2#6':ASS<9+INDX>"R#2":DIS.OPEN'R2$,#14':DEPD.VAL'R2$,#13':YTD.DEPN'R2$,#13'
         If soils Then Ans = Pick.extract(ass, 63, 0, 0) Else Ans = Locn
         desc = Pick.extract(ass, 3, 0, 0)
         For Row = Len(desc) To 1 Step -1
            If Mid(desc, Row, 1) <> Chr(253) Then Exit For
            desc = Left(desc, Row - 1)
         Next Row
         desc = replace(desc, Chr(253), "<BR>")
         temp = "<TR><TD>" & Assetno & "<TD>" & desc & "<TD>" & grp_num & "<TD>" & Ans & "<TD>" & Pick.oconv(Pick.extract(ass, 5, 0, 0), "D2") & "<TD align=right>" & Price & "<TD align=right>" & depd_val & "<TD>" & Pick.extract(ass, 7 + Indx, 0, 0) & "<TD align=right>" & Pick.oconv(Pick.extract(ass, 8 + Indx, 0, 0), "MD2") & "<TD align=right>" & Pick.extract(ass, 9 + Indx, 0, 0) & "<TD align=right>" & Ytd_Depn & "<TD align=right>" & FormatCurrency(Ltd_Depn, 2)
         If Pick.extractint(ass, 23, 0, 0) <= dd And Pick.extractint(ass, 23, 0, 0) <> 0 Then
            temp = temp & "<TD>" & Pick.oconv(Pick.extract(ass, 23, 0, 0), "D2") & "<TD align=right>" & Pick.oconv(Pick.extract(ass, 24, 0, 0), "MD2") & "<TD>" & Pick.extract(ass, 25, 0, 0)
         End If
         textfile.WriteLine (temp)
      End If
'
      If Pick.extract(ass, 23, 0, 0) <> "" Then
         If Pick.extractint(ass, 23, 0, 0) <= dd Then
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
     Set textfile = Nothing
     Set fso = Nothing
     Exit Function
'
' Store Class Total Details in dynamic array
'
300: Class_Cnt = Class_Cnt + 1
     Class_Array = Pick.replace(Class_Array, Class_Cnt, 1, 0, St_Group)
     Class_Array = Pick.replace(Class_Array, Class_Cnt, 2, 0, CStr(St_Price))
     Class_Array = Pick.replace(Class_Array, Class_Cnt, 3, 0, CStr(St_Open_Bal))
     Class_Array = Pick.replace(Class_Array, Class_Cnt, 4, 0, CStr(St_Depd_Val))
     Class_Array = Pick.replace(Class_Array, Class_Cnt, 5, 0, CStr(St_Ytd_Depn))
     Class_Array = Pick.replace(Class_Array, Class_Cnt, 6, 0, CStr(St_Ltd_Depn))
     St_Price = 0: St_Open_Bal = 0: St_Ytd_Depn = 0: St_Depd_Val = 0: St_Ltd_Depn = 0
     Return
'
' Move Class Total Details from dynamic array to print fields
'
310: For Row = 1 To Class_Cnt
        St_Group = Pick.extract(Class_Array, Row, 1, 0)
        St_Price = Pick.extract(Class_Array, Row, 2, 0)
        St_Open_Bal = Pick.extract(Class_Array, Row, 3, 0)
        St_Depd_Val = Pick.extract(Class_Array, Row, 4, 0)
        St_Ytd_Depn = Pick.extract(Class_Array, Row, 5, 0)
        St_Ltd_Depn = Pick.extract(Class_Array, Row, 6, 0)
        GoSub 940
        GoSub 320       ' ACCUMULATE GRAND TOTALS
        St_Price = 0: St_Open_Bal = 0: St_Ytd_Depn = 0: St_Depd_Val = 0: St_Ltd_Depn = 0
     Next Row
     Class_Cnt = 0: Class_Array = ""
     Return
'
' Accumulate Grand Totals
'
320:    If Pick.locate(St_Group, Total_Str, 1, 1, 0, Tot_Pos, "") = 0 Then
           Tot_Pos = 0
           Total_Cnt = Total_Cnt + 1
           Total_Str = Pick.replace(Total_Str, 1, Total_Cnt, 0, St_Group)
           Total_Class = Pick.replace(Total_Class, Total_Cnt, 1, 0, St_Group)
           Total_Class = Pick.replace(Total_Class, Total_Cnt, 2, 0, CStr(St_Price))
           Total_Class = Pick.replace(Total_Class, Total_Cnt, 3, 0, CStr(St_Open_Bal))
           Total_Class = Pick.replace(Total_Class, Total_Cnt, 4, 0, CStr(St_Depd_Val))
           Total_Class = Pick.replace(Total_Class, Total_Cnt, 5, 0, CStr(St_Ytd_Depn))
           Total_Class = Pick.replace(Total_Class, Total_Cnt, 6, 0, CStr(St_Ltd_Depn))
        End If
        If Tot_Pos Then
           Total_Class = Pick.replace(Total_Class, Tot_Pos, 2, 0, Pick.extractcur(Total_Class, Tot_Pos, 2, 0) + St_Price)
           Total_Class = Pick.replace(Total_Class, Tot_Pos, 3, 0, Pick.extractcur(Total_Class, Tot_Pos, 3, 0) + St_Open_Bal)
           Total_Class = Pick.replace(Total_Class, Tot_Pos, 4, 0, Pick.extractcur(Total_Class, Tot_Pos, 4, 0) + St_Depd_Val)
           Total_Class = Pick.replace(Total_Class, Tot_Pos, 5, 0, Pick.extractcur(Total_Class, Tot_Pos, 5, 0) + St_Ytd_Depn)
           Total_Class = Pick.replace(Total_Class, Tot_Pos, 6, 0, Pick.extractcur(Total_Class, Tot_Pos, 6, 0) + St_Ltd_Depn)
        End If
     Return
'
' Print Grand Class Total
'
330: For Row = 1 To Total_Cnt
        St_Group = Pick.extract(Total_Class, Row, 1, 0)
        St_Price = Pick.extract(Total_Class, Row, 2, 0)
        St_Open_Bal = Pick.extract(Total_Class, Row, 3, 0)
        St_Depd_Val = Pick.extract(Total_Class, Row, 4, 0)
        St_Ytd_Depn = Pick.extract(Total_Class, Row, 5, 0)
        St_Ltd_Depn = Pick.extract(Total_Class, Row, 6, 0)
        'Printer.Print Space(20); Left((C_Text & St_Group) & Space(32), 32); Right(Space(14) & St_Price, 14); Right(Space(14) & St_Depd_Val, 14);
        'Printer.Print  SPACE(16); Right(Space() & ST_YTD_DEPN,); Right(Space() & ST_LTD_DEPN,);
'       PRINT ST.YTD.DEPN'R2$,#13'
     Next Row
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
Dim nodep As String, Summonly As String, prev_depd_val As Currency
Dim Sel As String
Dim temp As String, acc_pers As Integer
Dim end_last_year As Integer, end_first_prd As Integer, FUTURE As Integer, prior As Integer
Dim ass() As String, Gg As Integer
Dim total_items As Long, cnt As Integer, pick_cnt As Long, mylist() As String, J As Long
Dim depn_freq As String, dep_per_yr As Integer, dep_mths As Integer
Dim tempcur As Currency
Dim class_code As String, depd_val As Currency
Dim resid As Currency, residual As Integer, open_val As Currency, days_flag As Integer
Dim I As Integer, depn_date As String, First As String, last_depn As String, posn As Integer, Pos As Integer
Dim depn_rate As Currency, pur_price As Currency, depn As Currency
Dim post_depns As String, post_dates As String, cycle As Integer
Dim tjpp As Integer, tj_rec As String, Tjac As String, Tjjob As String, Tjcd As String, Tjcost As String, tjp As Integer
Dim p_depn As String, Count As Integer, p_date As String, Tj_Key As String, tot_depn As Currency
Dim cents As String, Amt As Currency
Dim diy As Integer, dip As Integer, Indx As Integer
Dim gc As Integer, Glac As String, tempd
Dim database As String, rderr As Integer, Cls As String, subl As String
Dim fso, textfile, nrec() As String, sorting As String
Dim bylocn As Integer, soils As Integer, Grp As Integer

    database = Pick.extract(logentry, 2, 0, 0)
    
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
    
    d1 = Pick.extractint(parms, 1, 0, 0)
    nodep = Pick.extract(parms, 2, 0, 0)
    Summonly = Pick.extract(parms, 4, 0, 0)
    run_type = "A"

    sorting = Pick.extract(parms, 3, 0, 0)
    Select Case sorting
       Case "BY LOCN BY PROJECT BY GROUP BY ASSET.NO": bylocn = 1: soils = 1
       Case "BY LOCN BY GROUP BY ASSET.NO": bylocn = 1
       Case "BY LOCN BY CLASS BY ASSET.NO": bylocn = 2
       Case "BY GL.ACC BY ASSET.NO": bylocn = 0: Grp = 0
       Case "BY TYPE BY CLASS BY GROUP BY PUR_DATE BY ASSET.NO": bylocn = 0: Grp = 1
    End Select
    sentence = sentence & " " & sorting
      
    If realrun Then
       If d1 < Pick.extractint(g_trans_info_array(34), 1, 9, 0) Or d1 > Pick.extractint(g_trans_info_array(34), 1, 10, 0) Then
          SR1455A = Chr(8) & "Date must be a month end and must be within date range entered in 599"
          Exit Function
       End If
    End If
    
    SR1455A = ckaiis.rtf_open(logentry, fso, textfile, ".asp")
    temp = "<TABLE cellspacing=1 cellpadding=1 border=1 WIDTH=95%><TR CLASS=top><TD COLSPAN=9 ALIGN=CENTER>Asset Depreciation to " & Pick.oconv(CStr(d1), "D2") & "    as at " & Now
    temp = temp & "<TR class=top><TH>Asset<TH>Description<TH>Group<TH>Location<TH>Price<TH>Date<TH>Type<TH>Rate<TH>Freq<TH>Current Dep'd Value<TH>Depreciation Amount<TH>Depreciated Value<TH>Total Depreciation<TH>Class"
    textfile.WriteLine (temp)
    
    cents = Pick.extract(g_trans_info_array(151), 1, 3, 0) ': If cents = "" Then MD2 = "MD2": MD2CONV = "MD2": cents = 2: DOL = "$" Else MD2 = "MD02": MD2CONV = "MD20": DOL = ""
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
    I = Pick.dcount(Pick.extract(eoms, 1, 0, 0), Chr(253))
    last_date = CInt(Pick.extract(eoms, 1, I, 0))

    If d1 > CInt(g_trans_info_array(7)) Then     ' DEPN IN FUTURE YEAR ?
       end_last_year = CInt(g_trans_info_array(7))
       end_first_prd = CInt(Pick.extract(g_trans_info_array(33), 1, 1, 0))
       FUTURE = 1: prior = 0
    Else
       'LN = LN + 2
       If d1 <= CInt(Pick.extract(g_trans_info_array(8), 1, 1, 0)) Then
65      ' Call SRIP(0, LN, "Previous END-of-year (for reducing balance) ", PY_DATE, CLEARS, "", "", "D_ENDIF", "")
          'IF PY_DATE = "ENDIF" THEN PRINT ERASE & : RETURN
          'D2 = ICONV(PY_DATE, "D2")
          'LOCATE(D2,EOMS,1,1,0,POS2,"") ELSE PRINT BELL & : GOTO 65
          'IF D2>=D1 THEN PRINT BELL & : GOTO 65
          'ENDIF_LAST_YEAR = pick.extract(eoms, 1, POS2, 0)
          'ENDIF_FIRST_PRD = pick.extract(eoms, 1, POS2 + 1, 0)
          'future = 0: prior = 1
       Else
          end_last_year = CInt(Pick.extract(g_trans_info_array(8), 1, 1, 0))
          end_first_prd = CInt(Pick.extract(g_trans_info_array(8), 1, 2, 0))
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
     ReDim ass(0): ass(0) = mylist(J)
     If d3.d3_readmat(database, ass(), "ASSET") <> 0 Then GoTo 100
     If UBound(ass) < 97 Then ReDim Preserve ass(97)
     If ass(23) <> "" And run_type <> "T" Then GoTo 7000   ' ASSET DISPOSED

     depn_freq = ass(9 + I)
     Select Case depn_freq
       Case "M": dep_per_yr = acc_pers: dep_mths = 1
       Case "Q": dep_per_yr = 4:   dep_mths = 3
       Case "H": dep_per_yr = 2:   dep_mths = 6
       Case "Y": dep_per_yr = 1:   dep_mths = acc_pers
       Case Else: GoTo 7000 'error
     End Select
'
     depn_date = Pick.extract(ass(10 + I), 1, 1, 0) ' FIRST DEP"N
     If depn_date <> "" Then                        ' FIRST DEP`N
        last_depn = depn_date
        First = "Y"
     Else
        last_depn = Pick.extract(ass(10 + I), 1, 2, 0)
        First = "N"
     End If
'
' IF FULL VALUE DEPRECIATION, THEN DEPRECIATE AT END OF MONTH OF PURCHASE
    If ass(7 + I) = "3" Then
        If IsNumeric(ass(5)) Then tempcur = CCur(ass(5)) Else tempcur = 0
        If tempcur > end_last_year Then last_depn = ass(5) Else depn_date = end_first_prd:  GoTo 175
    End If
'
    posn = Pick.locate(last_depn, eoms, 1, 1, 0, Pos, "AR")
    If Pick.extract(eoms, 1, Pos, 0) = "" Then
       depn_date = "99999"
       GoTo 175
    End If
'
160 If ass(7 + I) <> "3" Then
        If First = "Y" Then GoTo 175
        Pos = Pos + dep_mths
     End If
     If d1 > last_date Then depn_date = "99999" Else depn_date = Pick.extract(eoms, 1, Pos, 0)

175 If CCur(depn_date) > d1 Then GoTo 7000        ' NOT DUE FOR DEP`N

    temp = Pick.extract(ass(12 + I), 1, 1, 0)
    If IsNumeric(temp) Then depd_val = CCur(temp) Else depd_val = 0
    open_val = depd_val
    If residual <> 0 Then
       If run_type = "A" Then temp = ass(42) Else temp = ass(43)
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
    temp = ass(8 + I)
    If IsNumeric(temp) Then depn_rate = CCur(temp) / 100 Else depn_rate = 0
    If run_type = "A" Then temp = ass(6) Else temp = ass(22)
    If IsNumeric(temp) Then pur_price = CCur(temp) Else pur_price = 0
'
200 Select Case ass(7 + I)
       Case "1"              ' STRAIGHT LINE DEPRECIATION
          depn = pur_price / 100 * depn_rate
       Case "2"   ' REDUCING BALANCE DEPRECIATION
          depn = depd_val * depn_rate
       Case "3"  ' FULL VALUE DEPRECIATION
         If prev_depd_val < pur_price Then depn = prev_depd_val * dep_per_yr Else depn = pur_price * dep_per_yr
       Case "4"   ' YEAR REST REDUCING BALANCE
          If FUTURE Or prior Then
             posn = Pick.locate(CStr(end_last_year), ass(11 + I), 1, 1, 0, pos2, "")
             If posn = 0 Then pos2 = 0
             If pos2 Then temp = Pick.extract(ass(12 + I), 1, pos2, 0) Else temp = "0"
             If IsNumeric(temp) Then depn = CCur(temp) Else depn = 0
             If depn = 0 Then
                temp = ass(13 + I)   ' YEAR OPENING BAL
                If IsNumeric(temp) Then depn = CCur(temp) Else depn = 0
             End If
          Else
             temp = ass(13 + I)   ' YEAR OPENING BAL
             If IsNumeric(temp) Then depn = CCur(temp) Else depn = 0
          End If
          If IsNumeric(ass(5)) Then tempcur = CCur(ass(5)) Else tempcur = 0
          If tempcur > end_last_year Then depn = pur_price
          depn = depn / 100 * depn_rate

       Case Else
          depn = 0
    End Select

    depn = depn / 100
    If days_flag <> 0 Then
       If depn_date > CInt(g_trans_info_array(7)) Then
          diy = CInt(Pick.extract(g_trans_info_array(33), 1, acc_pers, 0)) - CInt(g_trans_info_array(7))
       Else
          If depn_date > CInt(Pick.extract(g_trans_info_array(8), 1, 1, 0)) Then
             diy = CInt(g_trans_info_array(7)) - Pick.extract(g_trans_info_array(8), 1, 0, 0)
          Else
             diy = CInt(Pick.extract(g_trans_info_array(8), 1, 1, 0)) - CInt(Pick.extract(g_trans_info_array(9), 1, 0, 0))
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
       If run_type = "A" Then temp = ass(42) Else temp = ass(43)
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

    post_depns = Pick.insert(post_depns, -1, 0, 0, CStr(Int(depn * 100)))
    post_dates = Pick.insert(post_dates, -1, 0, 0, depn_date)

    If Pick.extract(ass(10 + I), 1, 1, 0) <> "" Then
       ass(10 + I) = Pick.replace(ass(10 + I), 1, 1, 0, "")
    End If
    ass(10 + I) = Pick.replace(ass(10 + I), 1, 2, 0, CStr(depn_date))
    ass(11 + I) = Pick.insert(ass(11 + I), 1, 1, 0, depn_date)
    ass(12 + I) = Pick.insert(ass(12 + I), 1, 1, 0, CStr(depd_val))
    last_depn = depn_date
'
    Pos = Pos + dep_mths
    depn_date = Pick.extract(eoms, 1, Pos, 0)
    If depn_date = "" Then depn_date = "99999"
    cycle = cycle + 1
    If run_type = "T" And ass(23) <> "" Then
       If CCur(ass(23)) < CCur(depn_date) Then GoTo 210
    End If
    If depn_date <= d1 And ass(7 + I) <> "3" Then
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
           p_depn = Pick.extract(post_depns, Count, 0, 0)      ' DEP`N AMOUNT TO POST
           If p_depn = "" Then GoTo 6100
           If p_depn Then
               p_date = Pick.extract(post_dates, Count, 0, 0)
               'tj_key = TNO & p_date & "1455"
6000           If d3.d3_readstr(database, tj_rec, "TRANS.J", Tj_Key) <> 0 Then tj_rec = "": GoTo 6010
'$INSERT I.LOG.UPDATE '|TRANS.J|':TJ.KEY 6000 TJ.REC
               GoTo 6020
6010:
'$INSERT I.LOG.ADD '|TRANS.J|':TJ.KEY 6000
'
6020        If ass(2) = "" Then ass(2) = "Exp_ acct missing"
               If ass(1) = "" Then ass(1) = "Prov_ acct missing"
               Tjac = ass(2)
               Tjjob = "0"
               Tjcd = 63
               Tjcost = p_depn
               GoSub 7777
               Tjac = ass(1)
               Tjcd = 38
               GoSub 7777
               'tj_rec = pick.REPLACE(tj_rec, 6, 0, 0, "ASSET DEPN " & OCONV(p_date, "D2"))
               tj_rec = Pick.replace(tj_rec, 7, 0, 0, p_date)
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
     If Summonly = "N" Then
        cnt = cnt + 1
        temp = "<TR><TD>" & mylist(J) & "<TD>" & ass(3) & "<TD>" & ass(37) & "<TD>" & ass(4) & "<TD align=right>" & FormatCurrency(pur_price, 2) & "<TD>" & Pick.oconv(ass(5), "D2") & "<TD>" & ass(7 + I) & "<TD>" & FormatCurrency(depn_rate, 2) & "<TD>" & ass(9 + I) & "<TD>" & FormatCurrency(open_val, 2) & "<TD>" & FormatCurrency(depn, 2) & "<TD>" & FormatCurrency(depd_val, 2) & "<TD>" & FormatCurrency(tot_depn, 2) & "<TD>" & ass(97)
        textfile.WriteLine (temp)
        'Print ((ASSETNO & Space(8 - Len(ASSETNO))) & " " & ass(pick.extract(3), 1, 1)); "L<>29" & grp_code; "R<>6" & " " & ass(4); "R<>4"
        '& pur_price; R2_14 & " " & OCONV(ass(5), "D2") & Space(3) & ass(7 + i) & " " & depn_rate; "R2<>5"
        '& Space(3) & ass(9 + i) & OCONV(open_val, MD2); R2_14 & depn; R2_12 & depd_val; R2_14 &
        'tot_depn; R2_14
     End If
     GoSub 8000                      ' BUILD GL SUMMARY DETAILS
100  Next J ' GET ANOTHER ASSET
     For Gg = 0 To 3 Step 3
        For Count = 1 To Pick.dcount(nrec(14 + Gg), Chr(253))
           temp = "<TR><TD>" & Pick.extract(nrec(14 + Gg), 1, Count, 0) & "<TD align=right>" & Pick.extractcur(nrec(14 + Gg), 1, Count, 0) & "<TD align=right>" & Pick.extractcur(nrec(14 + Gg), 1, Count, 0)
           textfile.WriteLine (temp)
       Next Count
     Next Gg
     textfile.WriteLine ("</TABLE>")
     textfile.WriteLine ("</BODY>")
     textfile.WriteLine ("</HTML>")
     Set textfile = Nothing
     Set fso = Nothing
     Exit Function
'
7000: ' If realrun Then
 '        Release ASSET_DATA, asset
'$INSERT I.QU
     'End If
     GoTo 100
7777 tjpp = 1
7778 For tjp = tjpp To 999
        If Pick.extract(tj_rec, 3, tjp, 0) = Tjac Then GoTo 7779
        If Pick.extract(tj_rec, 3, tjp, 0) = "" Then
           tj_rec = Pick.insert(tj_rec, 3, -1, 0, Tjac)
           tj_rec = Pick.insert(tj_rec, 2, -1, 0, Tjjob)
           tj_rec = Pick.insert(tj_rec, 1, -1, 0, Tjcd)
           tj_rec = Pick.insert(tj_rec, 4, -1, 0, Tjcost)
           Return
        End If
     Next tjp
7779 If Pick.extract(tj_rec, 1, tjp, 0) <> Tjcd Or Pick.extract(tj_rec, 2, tjp, 0) <> Tjjob Then tjpp = tjpp + 1: GoTo 7778
     tj_rec = Pick.replace(tj_rec, 4, tjp, 0, Pick.extract(tj_rec, 4, tjp, 0) + Tjcost)
     Return
'
'--- S/R 8000:  ROUTINE TO BUILD DETAILS FOR GL POSTING SUMMARY
'
8000 ReDim nrec(20)
     For Count = 1 To Pick.dcount(post_depns, Chr(254))
        p_depn = Pick.extract(post_depns, Count, 0, 0)
        If p_depn = "" Then Return
        If Not IsNumeric(p_depn) Then Return
        If p_depn <> 0 Then
         For Gg = 0 To 3 Step 3
'** BUILD DEPRECIATION POSTING DETAILS ***
           If Gg = 0 Then Glac = ass(2) Else Glac = ass(1)
           posn = Pick.locate(Glac, nrec(14 + Gg), 1, 1, 0, Indx, "")
           If posn = 0 Then Indx = 0
           If Indx <> 0 Then
               Amt = Pick.extractcur(nrec(15 + Gg), 1, Indx, 0)
               gc = CInt(Pick.extract(nrec(16 + Gg), 1, Indx, 0))
               nrec(15 + Gg) = Pick.replace(nrec(15 + Gg), 1, Indx, 0, CStr(Amt + CCur(p_depn))) ' UPDATE TOTALS)
               nrec(16 + Gg) = Pick.replace(nrec(16 + Gg), 1, Indx, 0, CStr(gc + 1))
           Else
               nrec(14 + Gg) = Pick.insert(nrec(14 + Gg), 1, -1, 0, Glac) ' NEW POSTING A/C
               nrec(15 + Gg) = Pick.insert(nrec(15 + Gg), 1, -1, 0, p_depn)
               nrec(16 + Gg) = Pick.insert(nrec(16 + Gg), 1, -1, 0, "1")
           End If
         Next Gg
       End If
     Next Count
     Return

End Function


Public Sub SR211(database As String, Author, cr_author As String, Tr_Payment As Currency, tr_amt As Currency, tr_bal As Currency, Discflag, tr_type As Integer, DISC_DATE, Tr_Date, cr_discount As String, DEF_DISCOUNTS, Tr_Disc As Currency, REMFLAG, cr_remit As String, Yespay As Integer, SETONLY, Disc_Apply, Disc_Apply_Date, Pps_Flg, CR_PPS_RATE As Currency, Tr_Pps As String)

Dim Tr_Paid
Dim Nodays, Discounts As String, Pp, Jj As Integer
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
     If Author Then
        If Author = 2 And Pick.extract(cr_author, 1, 0, 0) = "" Then GoTo 100
        If Author = 1 And Pick.extractcur(cr_author, 1, 0, 0) <> 0 Then GoTo 100
        Tr_Payment = Pick.extractcur(cr_author, 1, 0, 0)
        If tr_bal >= 0 Then
           Tr_Paid = tr_amt - tr_bal
           If Tr_Paid >= Tr_Payment Then
              Tr_Payment = 0
           Else
              Tr_Payment = Tr_Payment - Tr_Paid
           End If
        End If
        If Tr_Payment = 0 Then
          If tr_bal <> 0 Then GoTo 700 Else GoTo 600
        End If
     Else
100     If Discflag = 0 Then GoTo 400
        If tr_type <> 25 Then GoTo 400
        If tr_amt <> tr_bal Then GoTo 400   ' no discount on part payments
        Nodays = DISC_DATE - Tr_Date
        Discounts = Pick.extract(cr_discount, 1, 0, 0)
        If Discounts = "" Then
           Discounts = DEF_DISCOUNTS
           If Mid$(Discounts, 1, 1) <> "0" Then GoTo 400
        Else
           If Mid$(Discounts, 1, 1) <> "0" Then GoTo 400
           Discounts = Mid$(Discounts, 1, 1) & Chr(253) & Mid$(Discounts, 3, 99)
200        Pp = InStr(Discounts, ",")
           If Pp Then Discounts = Mid$(Discounts, 1, Pp - 1) & Chr(252) & Mid$(Discounts, Pp + 1, 99): GoTo 200
300        Pp = InStr(Discounts, " ")
           If Pp Then Discounts = Mid$(Discounts, 1, Pp - 1) & Chr(253) & Mid$(Discounts, Pp + 1, 99): GoTo 300
        End If
        For Jj = 1 To 3
           If Pick.extract(Discounts, 1, Jj + 1, 1) + 0 = 0 Then GoTo 400
           If Nodays <= Pick.extract(Discounts, 1, Jj + 1, 2) Or Pick.extract(Discounts, 1, Jj + 1, 2) = "" Then
              Disc_Apply = Pick.extract(Discounts, 1, Jj + 1, 1): Disc_Apply_Date = Pick.extract(Discounts, 1, Jj + 1, 2)
              Tr_Disc = tr_bal / 100 * Disc_Apply
              Tr_Payment = Int(tr_bal - Tr_Disc + 0.5)
              Tr_Disc = tr_bal - Tr_Payment
              GoTo 500
           End If
        Next Jj
400     Tr_Payment = tr_bal
500     If Tr_Payment = 0 Then
600       If REMFLAG Or Pick.extract(cr_remit, 1, 0, 0) <> "" Then GoTo 700
        End If
     End If
     If Discflag Then
        If Tr_Disc = 0 And SETONLY = "Y" Then GoTo 700
     End If
'
     If Pps_Flg Then     ' PPS system
       If Pick.extract(Tr_Pps, 1, 1, 1) <> "" Then     ' PPS to apply
         Prev_Pps = 0
         If Pick.extract(Tr_Pps, 1, 1, 1) <> "Y" Then Prev_Pps = Pick.extract(Tr_Pps, 1, 1, 1) ' previous PPS
         Balance = Tr_Payment + Prev_Pps + Tr_Disc
         If Pick.extract(Tr_Pps, 1, 1, 2) <> "" Then ' test against PPS over-ride
           Paid_So_Far = tr_amt - tr_bal - Prev_Pps - Tr_Disc
           If Balance + Paid_So_Far > Pick.extract(Tr_Pps, 1, 1, 2) Then
             Balance = Pick.extract(Tr_Pps, 1, 1, 2) - Paid_So_Far
             If Balance < 0 Then Balance = 0
           End If
         End If
         Tr_Pps = Pick.replace(Tr_Pps, 1, 1, 1, Int((Balance * CR_PPS_RATE / 100) + 0.5))
         Tr_Pps = Pick.replace(Tr_Pps, 1, 1, 1, Int(Pick.extract(Tr_Pps, 1, 1, 1) / 100) * 100) ' truncate cents)
         Tr_Payment = Tr_Payment - Pick.extract(Tr_Pps, 1, 1, 1)
       End If
     Else
       Tr_Pps = ""
     End If
     Exit Sub      ' to calling program **
'
700  Yespay = 0  ' NOT available for payment

End Sub



Public Function ta580(logentry As String, parms As String) As String

' TA580  BURST TRANS.J TO TRANS.J.COPY TO ALLOW POSTING TO GEN.L

Dim Tr_Cash_Rev As Integer, Cur_Date, Start_Year As Integer
Dim Acceptclose As Integer, Debt As String, Vfdate As Integer, Vtdate As Integer, Usa As Integer, Chq As String
Dim One_Side As String, Inter_Comp As Integer, company As String, Inter_Acs As String, Ct As Long
Dim Total_Chq As Currency, Ct_Chq As Integer, Numv As Integer, I As Integer, Tj As String, Amt As String, Job As String, Ii As Integer, Tc_Type As Integer
Dim Tc_Acct As String, Name As String, Tid As String, Tc_Code As Integer, Tc_Item As String, Tc_Narr As String, X As String, Y As String, Jobrec As String
Dim Max As Integer, Mm As Integer, Deposit As String, Copyrec As String, Dc_Rec As String, Save_Company As Integer, Fnd As Integer, Dr As Integer, Cr As Integer
Dim opn As Integer, temp As String, kk As Long, database As String, rderr As Integer, dno As Integer
Dim mylist() As String, pick_cnt As Long, total_items As Long, sentence As String, tj_id As String
Dim No_Inter_Acs As Integer, Acct As String, Grp As String, Cpos As Integer, No_Trans As Integer
Dim fso, textfile, Ans As Integer

'        THE TRANS.J RECORDS ARE MULTI-VALUED - EACH MULTI-VALUE GIVES
'        RISE TO A TRANS.J.COPY TRANSACTION
'        TRANS.J TRANSACTIONS ARE DELETED AS THEY ARE REWRITTEN
'        RECORD CASH DEPOSITS ON DAILY.CASH FILE FOR LATER ANALYSIS
'
      Tr_Cash_Rev = 56
'
      Cur_Date = Pick.ICONV(Format$(Now, "DD MMM YY"), "D2")
      'Cphead = Space((132 - Len(pick.extract(account, 1, 1, 1))) / 2) & pick.extract(account, 1, 1, 1)

      database = Pick.extract(logentry, 2, 0, 0)
     
      If UBound(g_trans_info_array) = 0 Then
         g_trans_info_array(0) = "TRANS.INFO"
         rderr = d3.d3_readmat(database, g_trans_info_array(), "DICT TRANS.J")
      End If
      If UBound(g_trans_info_array) < 130 Then ReDim Preserve g_trans_info_array(130)
      
      Start_Year = Pick.extractint(g_trans_info_array(8), 1, 1, 0)
      Acceptclose = Pick.extractint(g_trans_info_array(70), 1, 4, 0)
      Debt = g_trans_info_array(14)
      Vfdate = Pick.extractint(g_trans_info_array(34), 1, 7, 0)
      Vtdate = Pick.extractint(g_trans_info_array(34), 1, 8, 0)
      'Usa = g_trans_info_array( 106) + 0
      Usa = 0
      If Usa Then Chq = "check" Else Chq = "cheque"
      'Jobcost = pick.extract(TRANS_INFO, 32, 0, 0) + 0
      One_Side = g_trans_info_array(102)  ' a/c used for ONE-SIDED entries
      'If Jobcost Then
      '   If d3.d3_readstr(database, Bunit, "DICT JOB.L", "@BUNIT") <> 0 Then Bunit = ""
      'End If
      Inter_Comp = 1
      If d3.d3_readstr(database, company, "DICT GEN.L", "@COMPANY") <> 0 Then Inter_Comp = 0
      If Inter_Comp Then
         Inter_Acs = Pick.extract(company, 4, 0, 0) & Chr(253) & Pick.extract(company, 5, 0, 0)
      End If
'
      sentence = "select trans.j"
      total_items = d3.d3_select(logentry, sentence, mylist(), pick_cnt, 0, 0)
      Ct = 0
      Total_Chq = 0:  Ct_Chq = 0
      ta580 = ckaiis.rtf_open(logentry, fso, textfile, ".asp")
      temp = "<TABLE cellspacing=1 cellpadding=1 border=1 WIDTH=95%><TR CLASS=top><TD COLSPAN=9 ALIGN=CENTER>General ledger transaction journal preliminary preparation and audit report " & Now & ". Dates must be in range (inclusive) " & Pick.oconv(CStr(Vfdate), "D2") & " to " & Pick.oconv(CStr(Vtdate), "D2")
      temp = temp & "<TR CLASS=TOP><TH>Account<TH>Description<TH>Report Type<TH colspan=2>Opening<TH colspan=2>Transaction<TH colspan=2>Closing<TR class=top><TH><TH><TH><TH>Debit<TH>Credit<TH>Debit<TH>Credit<TH>Debit<TH>Credit"
      textfile.WriteLine (temp)
'
   For kk = 0 To total_items
      tj_id = mylist(kk)
1100  If d3.d3_readstr(database, Tj, "TRANS.J", tj_id) <> 0 Then
1102     'Release TRANS_J_DATA, tj_id
         GoTo 10000
      End If
'$INSERT I.LOG.DELETE '|TRANS.J|':TJ.ID 1100 TJ
      Ans = Pick.extractint(Tj, 1, 1, 0)
      If Ans > 89 Then GoTo 1199
'
      If Pick.extract(Tj, 12, 0, 0) <> "" And Pick.extract(Tj, 13, 0, 0) <> "" Then 'foreign currency conversion
         Numv = Pick.dcount(Pick.extract(Tj, 1, 0, 0), Chr(253))
         For I = 1 To Numv
            Tj = Pick.replace(Tj, 4, I, 0, Int(Pick.extractcur(Tj, 13, 0, 0) / 10000 * Pick.extractcur(Tj, 4, I, 0) + 0.5))
         Next I
      End If
      If Pick.dcount(Pick.extract(Tj, 1, 0, 0), Chr(253)) <> Pick.dcount(Pick.extract(Tj, 3, 0, 0), Chr(253)) Or Pick.dcount(Pick.extract(Tj, 1, 0, 0), Chr(253)) <> Pick.dcount(Pick.extract(Tj, 4, 0, 0), Chr(253)) Then
         Printer.Print tj_id; " transaction rejected because there are not an equal number of codes, accounts and debits/credits"
         GoTo 1015
      End If
      If InStr(Pick.extract(Tj, 4, 0, 0), ".") Then
         Printer.Print tj_id; " transaction rejected because value has fractions of a cent"
1015     'Release TRANS_J_DATA, tj_id
'$INSERT I.QU.REC
1020     For I = 1 To 9999
            Ans = Pick.extract(Tj, 1, I, 0)
            If Ans = "" Then GoTo 10000
            Amt = Pick.extractcur(Tj, 4, I, 0): If InStr(Amt, ".") = 0 Then Amt = Pick.oconv(Amt, "MD2")
            Job = Pick.extract(Tj, 2, I, 0): If Job = "0" Then Job = ""
            Printer.Print Left(Ans & Space(3), 3); Left(Job & Space(2), 2); Left(Pick.extract(Tj, 3, I, 0) & Space(16), 16); Right(Space(15) & Amt, 15); " "; Left(Pick.extract(Tj, 5, I, 0) & Space(7), 7); Left(Pick.oconv(Pick.extract(Tj, 7, 0, 0), "D2") & Space(10), 10); Left(Pick.extract(Tj, 6, I, 0) & Space(77), 77)
         Next I
         GoTo 10000
      End If
      If InStr(Pick.extract(Tj, 4, 0, 0), "-") Then
         Printer.Print tj_id; " transaction rejected because value is negative"
         GoTo 1015
      End If
      If Pick.extractint(Tj, 7, 0, 0) <= Start_Year Then
         Printer.Print tj_id; " transaction rejected because dated "; Pick.oconv(Pick.extract(Tj, 7, 0, 0), "D2")
         GoTo 1015
      End If
      If (Pick.extractint(Tj, 7, 0, 0) < Vfdate Or Pick.extractint(Tj, 7, 0, 0) > Vtdate) And Pick.extract(Tj, 1, 0, 0) <> "2" Then
         Printer.Print tj_id; " transaction rejected because dated "; Pick.oconv(Pick.extract(Tj, 7, 0, 0), "D2")
         GoTo 1015
      End If
'
' check to see all accounts exist and are open (GL only)
'
      For Ii = 1 To 9999
        If Pick.extract(Tj, 1, Ii, 0) = "" Then Exit For
        Tc_Type = Pick.extractint(Tj, 2, Ii, 0)
        Tc_Acct = Pick.extract(Tj, 3, Ii, 1)
        If Tc_Type = 0 Then
          If Tc_Acct <> One_Side Or Tc_Acct = "" Then
             If d3.d3_readstr(database, temp, "GEN.L", Tc_Acct, 23) <> 0 Then
                Printer.Print tj_id; " transaction rejected because GL account "; Tc_Acct; " does not exist"
                GoTo 1015
             End If
             If IsNumeric(temp) Then opn = CInt(temp) Else opn = 0
             If opn Then
                If Acceptclose <> 0 Then
                   Printer.Print tj_id; " transaction posted to closed GL account "; Tc_Acct
                Else
                   Printer.Print tj_id; " transaction rejected because GL account "; Tc_Acct; " is CLOSED"
                   GoTo 1015
                End If
             End If
          End If
        Else
           If d3.d3_readstr(database, temp, "JOB.L", Tc_Acct, 3) <> 0 Then
              Printer.Print tj_id; " transaction rejected because JOB account "; Tc_Acct; " does not exist"
              'If pick.extract(Bunit, 1, 0, 0) <> "" And Mid$(Tc_Acct, 1, 4) <> "ERR." Then
              '   Tid = pick.field(Tc_Acct, ".", 1)
              '   Call SR_BUJOB(Tid, BU, BUNO)
              '   OPEN "",BUNO & "TRANS_J" TO OT_DATA ELSE GOTO 1015
              '   Delete TRANS_J_DATA, TJ_ID
              '   Call PICKWT(database, OT_DATA, TJ_ID, 3, Tj, 0)
              '   Printer.Print "*** COPIED TO ACCOUNT "; BUNO; " "; BU; " TRANS_J"
              'End If
              GoTo 1020
           End If
        End If
      Next Ii
'
'  LEAVE CHEQUE REQUESTS IN JOURNAL FILE
'
      If Pick.extract(Tj, 1, 1, 0) = 26 Or Pick.extract(Tj, 1, 1, 0) = 51 Then
        Ct_Chq = Ct_Chq + 1
        Total_Chq = Total_Chq + Pick.extract(Tj, 4, 1, 0)
        GoTo 1015
      End If
'
1199  '???Delete TRANS_J_DATA, tj_id
'
'
      For I = 1 To 9999
         If Pick.extract(Tj, 1, I, 0) = "" Then
            If Inter_Comp Then GoSub 8000
'$INSERT I.QU
            GoTo 10000
         End If
         Tc_Code = Pick.extractint(Tj, 1, I, 0)
         Tc_Type = Pick.extractint(Tj, 2, I, 0)
         Tc_Acct = Pick.extract(Tj, 3, I, 1)
         If InStr(Pick.extract(Tj, 5, 0, 0), Chr(253)) Then
            Tc_Item = Pick.extract(Tj, 5, I, 0)
         Else
            Tc_Item = Pick.extract(Tj, 5, 0, 0)
         End If
         If InStr(Pick.extract(Tj, 6, 0, 0), Chr(253)) Then
            Tc_Narr = Pick.extract(Tj, 6, I, 0)
            If Tc_Narr = "" Then Tc_Narr = Pick.extract(Tj, 6, 1, 0)
         Else
            Tc_Narr = Pick.extract(Tj, 6, 0, 0)
         End If
         X = "": Y = ""
         If Tc_Type = 1 Then           ' JOB COSTING TRANS_
1500        If d3.d3_readstr(database, temp, "DICT TRAN", tj_id & I & Y) <> 0 Then GoTo 1600
            'Release TRANS_JOB, TJ_ID & I & Y
            Y = Y & "Y"
            GoTo 1500
'
1600:
'$INSERT I.LOG.ADD '|TRANS.JOB|':TJ.ID:I:Y 2000
'
            Jobrec = Tc_Code & Chr(254) & "" & Chr(254) & Tc_Acct & Chr(254) & Pick.extract(Tj, 4, I, 0) & Chr(254) & Tc_Item & Chr(254) & Tc_Narr
            Max = Pick.dcount(Tj, Chr(254))
            For Mm = 7 To Max
               Jobrec = Pick.replace(Jobrec, Mm, 0, 0, Pick.extract(Tj, Mm, 0, 0))
            Next Mm
            '???Call PICKWT(database, TRANS_JOB, tj_id & I & Y, 3, Jobrec, 0)
            GoTo 2500
         End If
'
2000     If d3.d3_readstr(database, temp, "DICT TRANS.J", tj_id & I & X) <> 0 Then GoTo 2100
         'Release TRANS_J_COPY, tj_id & I & X
         X = X & "X"
         GoTo 2000
2100:
'$INSERT I.LOG.ADD '|TRANS.J.COPY|':TJ.ID:I:X 2000
'
' RECORD DEPOSIT ON DAILY.CASH FILE
'
         If Tc_Code = Tr_Cash_Rev And Debt <> "" Then
            Deposit = Pick.field(Pick.extract(Tj, 6, 0, 0), "D", 2)
            If IsNumeric(Deposit) Then GoSub 7000
         End If
'
         If Tc_Acct = One_Side Then GoTo 2500 'mco 20jul00 - do not write one-sided account
         Copyrec = Tc_Code & Chr(254) & "" & Chr(254) & Tc_Acct & Chr(254) & Pick.extract(Tj, 4, I, 0) & Chr(254) & Tc_Item & Chr(254) & Tc_Narr
         Max = Pick.dcount(Tj, Chr(254))
         For Mm = 7 To Max
            Copyrec = Pick.replace(Copyrec, Mm, 0, 0, Pick.extract(Tj, Mm, 0, 0))
         Next Mm
         '???Call PICKWT(database, TRANS_J_COPY, tj_id & I & X, 3, Copyrec, 0)
'
2500  Next I
10000 Next kk

     If Ct_Chq Then
        temp = "There are " & Chq & "s still to be printed to total value of $" & Pick.oconv(CStr(Total_Chq), "MD2,")
        textfile.WriteLine (temp)
     End If
     textfile.WriteLine ("</TABLE>")
     textfile.WriteLine ("</BODY>")
     textfile.WriteLine ("</HTML>")
     textfile.Close
     Set textfile = Nothing
     Set fso = Nothing
     Exit Function
'
' RECORD CASH DEPOSIT ROUTINE
'
7000  If d3.d3_readstr(database, Dc_Rec, "DAILY.CASH", CStr(Cur_Date)) <> 0 Then Dc_Rec = ""
'$INSERT I.LOG.UPDATE '|DAILY.CASH|':CUR.DATE 7000 DC.REC
      If Pick.locate(Deposit, Dc_Rec, 1, 0, 0, dno, "AR") = 0 Then
         Dc_Rec = Pick.insert(Dc_Rec, dno, 0, 0, Deposit)
      End If
      '???Call PICKWT(database, DAILY_CASH_DATA, Cur_Date, 3, Dc_Rec, 0)
      Return
'
'
' s/r 8000: For Inter-company accounting ONLY !
'           Routine will determine if transaction should be considered
'           for inter-company journal processing (via TA587)
'
8000  Save_Company = 0: Fnd = 0: Dr = 0: Cr = 0: No_Inter_Acs = 0
      For I = 1 To 999
         If Pick.extract(Tj, 1, I, 0) = "" Then Exit For
         Acct = Pick.extract(Tj, 3, I, 1)
         If InStr(Inter_Acs, Acct) Then No_Inter_Acs = No_Inter_Acs + 1
         Grp = Pick.field(Acct, ".", 1)
         If Pick.locate(Grp, company, 1, 0, 0, Cpos, "AR") = 0 Then Cpos = Cpos - 1
         If Pick.extract(company, 1, Cpos, 0) <> "" Then
            If Grp <= Pick.extractint(company, 2, Cpos, 0) Then
               If Cpos <> Save_Company Then
                  Save_Company = Cpos
                  Fnd = Fnd + 1
               End If
               If Pick.extract(Tj, 1, I, 0) < 50 Then Cr = 1 Else Dr = 1
            End If
         End If
      Next I
      No_Trans = I - 1
      If Fnd > 1 And Cr And Dr And No_Inter_Acs < No_Trans Then
         '???Call PICKWT(database, TRANS_J_INTER_DATA, tj_id, 3, Tj, 0)
      End If
      Return

End Function


