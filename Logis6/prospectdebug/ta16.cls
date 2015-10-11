VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "ta16"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit
Option Compare Text
Option Base 0

Private d3 As New d3
Private Pick As New Pick

Private g_trans_info_array() As String
Private g_rates() As String


Public Sub SR1654_A(database As String, Cr_Rec As String, Client_No As String, IFDate As String, ITDate As String, Eom As String, eom_val, Unused, print_ctl As String, Cde As String, other, ArrearDate As String)
Dim cr_oflow, st_cr_oflow, oflow_key As String, Cr_No_Trans, Cr_Code As String, from_date As Integer, to_date As Integer, arr_date As Integer
Dim Cr_Ref As String, Cr_Tdate As String, Cr_Tamt As String, cr_tbal As String, Cr_Xref As String, Cr_Xamt As String, Cr_Ldate As String, Interim As Integer, Penalty As Integer
Dim Cr_Xdate As String, cr_sdate As String, TR_POS As Integer, Tr_Ref, Mid$, tr_amt, tr_bal, tr_code
Dim tr_ldate, Tr_Sdate, Tr_Date, Tr_Xref As String, tr_xamt As String, Tr_Xdate As String
Dim px, Row As Integer, Col As Integer, pxval, Max, Sbl As Integer, Xref, Dte_Trans_Paid
'
' Analyse debtor transactions as at a given date
'
'       EOM<1,1> = Code
'          <2,1> = From.date
'          <2,2> = To.date
'          <3,2> = Arrears to From.date : <3,4> = Arrears YTD (30 Jun)
'          <4,2> = Levy raised for period
'          <4,4> = Levy raised YTD (to TO.DATE)
'          <5> same as 4 for Interims
'          <6> same as 4 for Penalty
'          <8,2> = Arrears paid during period
'          <9,4> = Current paid during period :  <9,4> = Current paid YTD
'
' =======================================================================*
'
     from_date = CInt(IFDate)
     to_date = CInt(ITDate)
     arr_date = CInt(ArrearDate)
     cr_oflow = Pick.extractint(Cr_Rec, 27, 0, 0)
     st_cr_oflow = cr_oflow + 1
100  If cr_oflow Then
        oflow_key = (st_cr_oflow - cr_oflow) & "*" & Client_No
        If d3.d3_readstr(database, Cr_Rec, "TD.OFLOW", oflow_key) <> 0 Then Cr_Rec = ""
        Cr_No_Trans = Pick.extractint(Cr_Rec, 1, 0, 0)
        Cr_Code = Pick.extract(Cr_Rec, 2, 0, 0)
        Cr_Ref = Pick.extract(Cr_Rec, 3, 0, 0)
        Cr_Tdate = Pick.extract(Cr_Rec, 5, 0, 0)
        Cr_Tamt = Pick.extract(Cr_Rec, 4, 0, 0)
        cr_tbal = Pick.extract(Cr_Rec, 6, 0, 0)
        Cr_Xref = Pick.extract(Cr_Rec, 9, 0, 0)
        Cr_Xamt = Pick.extract(Cr_Rec, 10, 0, 0)
        Cr_Ldate = Pick.extract(Cr_Rec, 11, 0, 0)
        Cr_Xdate = Pick.extract(Cr_Rec, 12, 0, 0)
        cr_sdate = Pick.extract(Cr_Rec, 13, 0, 0)
     Else
        If st_cr_oflow <> 1 Then
           If d3.d3_readstr(database, Cr_Rec, "TDEBTOR", Client_No) <> 0 Then Cr_Rec = ""
        End If
        Cr_No_Trans = Pick.extractint(Cr_Rec, 2, 0, 0)
        Cr_Code = Pick.extract(Cr_Rec, 11, 0, 0)
        Cr_Ref = Pick.extract(Cr_Rec, 12, 0, 0)
        Cr_Tdate = Pick.extract(Cr_Rec, 14, 0, 0)
        Cr_Tamt = Pick.extract(Cr_Rec, 13, 0, 0)
        cr_tbal = Pick.extract(Cr_Rec, 16, 0, 0)
        Cr_Xref = Pick.extract(Cr_Rec, 26, 0, 0)
        Cr_Xamt = Pick.extract(Cr_Rec, 30, 0, 0)
        Cr_Ldate = Pick.extract(Cr_Rec, 32, 0, 0)
        Cr_Xdate = Pick.extract(Cr_Rec, 42, 0, 0)
        cr_sdate = Pick.extract(Cr_Rec, 54, 0, 0)
     End If
     cr_oflow = cr_oflow - 1
'
     For TR_POS = 1 To Cr_No_Trans
        Tr_Ref = Pick.extract(Cr_Ref, 1, TR_POS, 0)
        If Mid$(Tr_Ref, 5, 1) = "I" Then Interim = 1 Else Interim = 0
        If Mid$(Tr_Ref, 5, 1) = "P" Then Penalty = 1 Else Penalty = 0
        tr_amt = Pick.extractcur(Cr_Tamt, 1, TR_POS, 0)
        tr_bal = tr_amt - Pick.extractcur(cr_tbal, 1, TR_POS, 0)
        tr_code = Pick.extract(Cr_Code, 1, TR_POS, 0)
        tr_ldate = Pick.extractint(Cr_Ldate, 1, TR_POS, 0)
        Tr_Sdate = Pick.extractint(cr_sdate, 1, TR_POS, 1)
'
        Tr_Date = Pick.extractint(Cr_Tdate, 1, TR_POS, 0)
        If Tr_Date > to_date Then GoTo 300
        Tr_Ref = Pick.extract(Cr_Ref, 1, TR_POS, 0)
        Tr_Xref = Pick.extract(Cr_Xref, 1, TR_POS, 0)
        tr_xamt = Pick.extract(Cr_Xamt, 1, TR_POS, 0)
        Tr_Xdate = Pick.extractint(Cr_Xdate, 1, TR_POS, 0)
        If tr_code >= "50" Then
           GoSub 2000
        Else
           GoSub 2500
        End If
300  Next TR_POS
     If cr_oflow >= 0 Then GoTo 100
     Exit Sub
'
'*****************************
' S/R 2000 - Write transaction
'*****************************
2000 px = Mid$(Tr_Ref, 1, 2)
     If px <> Pick.extract(print_ctl, 1, 0, 0) Then Return
     If Interim Then
        Row = 3
     Else
        If Penalty Then
           Row = 4
        Else
           Row = 2
        End If
     End If
     If Tr_Date >= arr_date And Tr_Date < from_date Then
        Col = 2
        GoSub 3000
     Else
        If Tr_Date >= from_date And Tr_Date <= to_date Then
           Col = 3
           GoSub 3000
        End If
     End If
     If Tr_Date >= arr_date And Tr_Date <= to_date Then
        Col = 4
        GoSub 3000
     End If
     If Tr_Date < arr_date Then
        Row = 1: Col = 1
        GoSub 3000
     End If
     Return
'
'******************************
' S/R 2500 - Credit transaction
'******************************
2500 pxval = 1
     Max = Pick.dcount(Pick.extract(Tr_Xref, 1, 1, 0), Chr(252))
     For Sbl = 1 To Max
        Xref = Pick.extract(Tr_Xref, 1, 1, Sbl)
        tr_amt = Pick.extractcur(tr_xamt, 1, 1, Sbl)
        tr_amt = -tr_amt
        Dte_Trans_Paid = Pick.extract(Tr_Xdate, 1, 1, Sbl)
        If Xref = "" Then Return
        If Mid$(Xref, 1, 2) <> Pick.extract(print_ctl, 1, 0, 0) Then GoTo 2550
        If Dte_Trans_Paid < arr_date Then Row = 6 Else Row = 7 ' Arrears Paid ?
        If Tr_Date < arr_date Then   ' arrears
           Row = 5: Col = 1
           GoSub 3000
        Else
           If Tr_Date >= arr_date And Tr_Date < from_date Then
              Col = 2 ' before period
           Else
              If Tr_Date >= from_date And Tr_Date <= to_date Then
                 Col = 3 ' during period
              End If
           End If
           GoSub 3000
           If Tr_Date >= arr_date And Tr_Date <= to_date Then
              Col = 4 ' YTD
              GoSub 3000
           End If
        End If
2550 Next Sbl
     Return
'
'********************
' S/R 3000 -  Write to table
'********************
3000 Eom = Pick.replace(Eom, Row, Col, 0, CStr(Pick.extractcur(Eom, Row, Col, 0) + tr_amt))
     Return
End Sub
Public Sub SR1654_DET(logentry As String, Cde, Fdate As String, TDATE As String, print_ctl As String)
Dim Bar, Vm, Tot1 As String, Tot2 As String, Tot3 As String, Tot4 As String, Tot5 As String, Tot6 As String, Tot7 As String, Tot8 As String
Dim Tot9 As String, Seq, max_lines, Pg, LCNT, database As String, Sent As String, total_items, mylist() As String, Assess, rec As String, pt_line
Dim item As String, Directory, Tmt, Atm, Mlev, Bon_Row, Mlev_Which, Sel, pick_cnt As Long
Dim Def_Fol, Msg$, Cls$, fname, Hd1, Hd2, Hd3, Hd4, Hd5, Hd6, H1
Dim H2, H3, H4, H5, H6, H7, H8, H9, H10, Hd7, Hd8, Hd9, xx As Long, DQ As String
'
'     Print detailed report for assessments
'
    Bar = "|": Vm = Chr(253): DQ = Chr(34)
    Tot1 = "": Tot2 = "": Tot3 = "": Tot4 = "": Tot5 = "": Tot6 = ""
    Tot7 = "": Tot8 = "": Tot9 = ""
    Seq = 1: max_lines = 58: Pg = 0: LCNT = 999
    database = Pick.extract(logentry, 2, 0, 0)
'

    GoSub 500

'
'
     Sent = "SELECT RATE.STATS BY ASSESS WITH FDATE = " & DQ & Fdate & DQ & " AND WITH TDATE = " & DQ & TDATE & DQ
     total_items = d3.d3_select(logentry, Sent, mylist(), pick_cnt, 0, 0)
'
For xx = 0 To UBound(mylist)
    item = mylist(xx)
    Assess = Pick.field(item, "-", 1)
    If d3.d3_readstr(database, rec, "RATE.STATS", item) <> 0 Then rec = ""
    pt_line = Left(Assess & Space(8), 8)
    pt_line = pt_line & " " & Right(Space(12) & Pick.oconv(Pick.extractcur(rec, 3, 2, 0), "MD2"), 12) & " " & Right(Space(12) & Pick.oconv(Pick.extractcur(rec, 3, 4, 0), "MD2"), 12)
    pt_line = pt_line & " " & Right(Space(12) & Pick.oconv(Pick.extractcur(rec, 4, 2, 0), "MD2"), 12) & " " & Right(Space(12) & Pick.oconv(Pick.extractcur(rec, 4, 4, 0), "MD2"), 12)
    pt_line = pt_line & " " & Right(Space(12) & Pick.oconv(Pick.extractcur(rec, 5, 2, 0), "MD2"), 12) & " " & Right(Space(12) & Pick.oconv(Pick.extractcur(rec, 5, 4, 0), "MD2"), 12)
    pt_line = pt_line & " " & Right(Space(12) & Pick.oconv(Pick.extractcur(rec, 6, 2, 0), "MD2"), 12) & " " & Right(Space(12) & Pick.oconv(Pick.extractcur(rec, 6, 4, 0), "MD2"), 12)
    pt_line = pt_line & " " & Right(Space(12) & Pick.oconv(Pick.extractcur(rec, 7, 2, 0), "MD2"), 12) & " " & Right(Space(12) & Pick.oconv(Pick.extractcur(rec, 7, 4, 0), "MD2"), 12)
    pt_line = pt_line & " " & Right(Space(12) & Pick.oconv(Pick.extractcur(rec, 8, 2, 0), "MD2"), 12) & " " & Right(Space(12) & Pick.oconv(Pick.extractcur(rec, 8, 4, 0), "MD2"), 12)
    pt_line = pt_line & " " & Right(Space(12) & Pick.oconv(Pick.extractcur(rec, 9, 2, 0), "MD2"), 12) & " " & Right(Space(12) & Pick.oconv(Pick.extractcur(rec, 9, 4, 0), "MD2"), 12)
    pt_line = pt_line & " " & Right(Space(12) & Pick.oconv(Pick.extractcur(rec, 10, 2, 0), "MD2"), 12) & " " & Right(Space(12) & Pick.oconv(Pick.extractcur(rec, 10, 4, 0), "MD2"), 12)
    pt_line = pt_line & " " & Space(13) & Right(Space(12) & Pick.oconv(Pick.extractcur(rec, 11, 4, 0), "MD2"), 12)
    GoSub 700
    Tot1 = Pick.replace(Tot1, 1, 1, 0, Pick.extractcur(Tot1, 1, 1, 0) + Pick.extractcur(rec, 3, 2, 0)): Tot1 = Pick.replace(Tot1, 1, 2, 0, Pick.extractcur(Tot1, 1, 2, 0) + Pick.extractcur(rec, 3, 4, 0))
    Tot2 = Pick.replace(Tot2, 1, 1, 0, Pick.extractcur(Tot2, 1, 1, 0) + Pick.extractcur(rec, 4, 2, 0)): Tot2 = Pick.replace(Tot2, 1, 2, 0, Pick.extractcur(Tot2, 1, 2, 0) + Pick.extractcur(rec, 4, 4, 0))
    Tot3 = Pick.replace(Tot3, 1, 1, 0, Pick.extractcur(Tot3, 1, 1, 0) + Pick.extractcur(rec, 5, 2, 0)): Tot3 = Pick.replace(Tot3, 1, 2, 0, Pick.extractcur(Tot3, 1, 2, 0) + Pick.extractcur(rec, 5, 4, 0))
    Tot4 = Pick.replace(Tot4, 1, 1, 0, Pick.extractcur(Tot4, 1, 1, 0) + Pick.extractcur(rec, 6, 2, 0)): Tot4 = Pick.replace(Tot4, 1, 2, 0, Pick.extractcur(Tot4, 1, 2, 0) + Pick.extractcur(rec, 6, 4, 0))
    Tot5 = Pick.replace(Tot5, 1, 1, 0, Pick.extractcur(Tot5, 1, 1, 0) + Pick.extractcur(rec, 7, 2, 0)): Tot5 = Pick.replace(Tot5, 1, 2, 0, Pick.extractcur(Tot5, 1, 2, 0) + Pick.extractcur(rec, 7, 4, 0))
    Tot6 = Pick.replace(Tot6, 1, 1, 0, Pick.extractcur(Tot6, 1, 1, 0) + Pick.extractcur(rec, 8, 2, 0)): Tot6 = Pick.replace(Tot6, 1, 2, 0, Pick.extractcur(Tot6, 1, 2, 0) + Pick.extractcur(rec, 8, 4, 0))
    Tot7 = Pick.replace(Tot7, 1, 1, 0, Pick.extractcur(Tot7, 1, 1, 0) + Pick.extractcur(rec, 9, 2, 0)): Tot7 = Pick.replace(Tot7, 1, 2, 0, Pick.extractcur(Tot7, 1, 2, 0) + Pick.extractcur(rec, 9, 4, 0))
    Tot8 = Pick.replace(Tot8, 1, 1, 0, Pick.extractcur(Tot8, 1, 1, 0) + Pick.extractcur(rec, 10, 2, 0)): Tot8 = Pick.replace(Tot8, 1, 2, 0, Pick.extractcur(Tot8, 1, 2, 0) + Pick.extractcur(rec, 10, 4, 0))
    Tot9 = Pick.replace(Tot9, 1, 2, 0, Pick.extractcur(Tot9, 1, 2, 0) + Pick.extractcur(rec, 11, 4, 0))
Next xx
GoSub 800
Exit Sub
'
'************************************
' S/R 500 - Headings for PRINT option
'************************************
500 Hd1 = Space(60) & "Schedule  14"
    Hd2 = Space(32) & Pick.extract(print_ctl, 2, 0, 0) & " Levy Assessment Profile Return Form - Detailed"
    Hd3 = ""
    Hd4 = database
    Hd5 = "Period " & Pick.oconv(Fdate, "D2") & " to " & Pick.oconv(TDATE, "D2")
    Hd6 = String$(244, "-")
    H1 = " ASSESS " & Bar
    H2 = "       ARREARS B/F       " & Bar
    H3 = "   INITIAL LEVY RAISED   " & Bar
    H4 = "  SUBSEQUENT LEVY RAISED " & Bar
    H5 = " PENALTY INTEREST RAISED " & Bar
    H6 = "           TOTAL         " & Bar
    H7 = "     ARREARS COLLECTED   " & Bar
    H8 = "     CURRENT COLLECTED   " & Bar
    H9 = "      TOTAL COLLECTED    " & Bar
    H10 = "      NET OUTSTANDING    " & Bar
    Hd7 = H1 & H2 & H3 & H4 & H5 & H6 & H7 & H8 & H9 & H10
    Hd8 = Space(9) & String$(10, "   Period   |     YTD    " & Bar)
    Hd9 = String$(244, "-")
    Return

'*********************
' 600 - Print headings
'*********************
600 Printer.Print Hd1
    Printer.Print Hd2
    Printer.Print Hd3
    Printer.Print Hd4
    Printer.Print Left(Hd5 & Space(100), 100); "PAGE "; Pg
    Printer.Print Hd6
    Printer.Print Hd7
    Printer.Print Hd8
    Printer.Print Hd9
    Return
'
'************************
' S/R 700 - Print PT.LINE
'************************
700  If LCNT > max_lines Then
        Printer.newpage
        Pg = Pg + 1
        GoSub 600  ' print headings
        LCNT = 9
     End If
     Printer.Print pt_line
     pt_line = ""
     LCNT = LCNT + 1
     Return
'
'***********************
' S/R 800 - Print totals
'***********************
800    Printer.Print Hd6
       Printer.Print
       Printer.Print Space(9);
       Printer.Print Right(Space(12) & Pick.oconv(Pick.extractcur(Tot1, 1, 1, 0), "MD2"), 12); " "; Right(Space(12) & Pick.oconv(Pick.extractcur(Tot1, 1, 2, 0), "MD2"), 12); " ";
       Printer.Print Right(Space(12) & Pick.oconv(Pick.extractcur(Tot2, 1, 1, 0), "MD2"), 12); " "; Right(Space(12) & Pick.oconv(Pick.extractcur(Tot2, 1, 2, 0), "MD2"), 12); " ";
       Printer.Print Right(Space(12) & Pick.oconv(Pick.extractcur(Tot3, 1, 1, 0), "MD2"), 12); " "; Right(Space(12) & Pick.oconv(Pick.extractcur(Tot3, 1, 2, 0), "MD2"), 12); " ";
       Printer.Print Right(Space(12) & Pick.oconv(Pick.extractcur(Tot4, 1, 1, 0), "MD2"), 12); " "; Right(Space(12) & Pick.oconv(Pick.extractcur(Tot4, 1, 2, 0), "MD2"), 12); " ";
       Printer.Print Right(Space(12) & Pick.oconv(Pick.extractcur(Tot5, 1, 1, 0), "MD2"), 12); " "; Right(Space(12) & Pick.oconv(Pick.extractcur(Tot5, 1, 2, 0), "MD2"), 12); " ";
       Printer.Print Right(Space(12) & Pick.oconv(Pick.extractcur(Tot6, 1, 1, 0), "MD2"), 12); " "; Right(Space(12) & Pick.oconv(Pick.extractcur(Tot6, 1, 2, 0), "MD2"), 12); " ";
       Printer.Print Right(Space(12) & Pick.oconv(Pick.extractcur(Tot7, 1, 1, 0), "MD2"), 12); " "; Right(Space(12) & Pick.oconv(Pick.extractcur(Tot7, 1, 2, 0), "MD2"), 12); " ";
       Printer.Print Right(Space(12) & Pick.oconv(Pick.extractcur(Tot8, 1, 1, 0), "MD2"), 12); " "; Right(Space(12) & Pick.oconv(Pick.extractcur(Tot8, 1, 2, 0), "MD2"), 12); " ";
       Printer.Print Space(13); Right(Space(12) & Pick.oconv(Pick.extractcur(Tot9, 1, 2, 0), "MD2"), 12)
       Printer.Print String$(244, "=")
       Return

    Return
'
End Sub

Public Sub SR1654_SUM(database As String, Report_Id As String, print_ctl As String)
Dim Vm, Sp, report As String, rec As String, Ii As Integer, Tmt, Atm, Mlev, Bon_Row, Format As String
Dim Mlev_Which, Sel, Def_Fol, Msg$, Cls$, fname, Xrec, Account As String
'
     Vm = Chr(253): Sp = Space(2)
     If d3.d3_readstr(database, Format, "DICT RATE.STATS", "@PRINT.FORMAT") <> 0 Then
        Exit Sub
     End If
     If d3.d3_readstr(database, report, "DICT RATE.STATS", Report_Id) <> 0 Then report = ""
'
     GoSub 500
     GoSub 600  ' Print report
     Exit Sub
'
'*********************************
' S/R 500 - Prepare report (Print)
'*********************************
500  rec = ""
'    FOR II = 1 TO 3
'       REC<II> = FORMAT<II>
'    NEXT II
     rec = Pick.replace(rec, 1, 0, 0, Pick.extract(Format, 1, 0, 0))
     rec = Pick.replace(rec, 2, 0, 0, Space(20) & "Annual " & Pick.extract(print_ctl, 2, 0, 0) & " " & Pick.extract(Format, 2, 0, 0))
     rec = Pick.replace(rec, 3, 0, 0, Pick.extract(Format, 3, 0, 0))
     rec = Pick.replace(rec, 4, 0, 0, Left(Account & Space(38), 38) & Pick.extract(Format, 4, 0, 0))
     rec = Pick.replace(rec, 5, 0, 0, "PERIOD " & Pick.oconv(Pick.extract(report, 2, 1, 0), "D2") & " to " & Pick.oconv(Pick.extract(report, 2, 2, 0), "D2") & Pick.extract(Format, 5, 0, 0))
     rec = Pick.replace(rec, 6, 0, 0, Space(34) & String$(21, "-") & "  " & String$(21, "-"))
     For Ii = 7 To 12
        rec = Pick.replace(rec, Ii, 0, 0, Pick.extract(Format, Ii, 0, 0))
     Next Ii
     rec = Pick.replace(rec, 13, 0, 0, Left(Pick.extract(Format, 13, 0, 0) & Space(33), 33) & Space(8) & Right(Space(14) & Pick.oconv(Pick.extract(report, 3, 2, 0), "MD2"), 14) & Space(8) & Right(Space(14) & Pick.oconv(Pick.extract(report, 3, 4, 0), "MD2"), 14))
     rec = Pick.replace(rec, 14, 0, 0, Pick.extract(Format, 14, 0, 0))
     rec = Pick.replace(rec, 15, 0, 0, Left(Pick.extract(Format, 15, 0, 0) & Space(33), 33)) & Right(Space(7) & Pick.extract(report, 4, 1, 0), 7) & " " & Right(Space(14) & Pick.oconv(Pick.extract(report, 4, 4, 0), "MD2"), 14) & " " & Right(Space(7) & Pick.extract(report, 4, 3, 0), 7) & " " & Right(Space(14) & Pick.oconv(Pick.extract(report, 4, 2, 0), "MD2"), 14)
     For Ii = 16 To 20
        rec = Pick.replace(rec, Ii, 0, 0, Pick.extract(Format, Ii, 0, 0))
     Next Ii
     rec = Pick.replace(rec, 21, 0, 0, Left(Pick.extract(Format, 21, 0, 0) & Space(33), 33)) & Right(Space(7) & Pick.extract(report, 5, 1, 0), 7) & " " & Right(Space(14) & Pick.oconv(Pick.extract(report, 5, 2, 0), "MD2"), 14) & Right(Space(7) & Pick.extract(report, 5, 3, 0), 7) & " " & Right(Space(14) & Pick.oconv(Pick.extract(report, 5, 4, 0), "MD2"), 14)
     For Ii = 22 To 27
        rec = Pick.replace(rec, Ii, 0, 0, Pick.extract(Format, Ii, 0, 0))
     Next Ii
     rec = Pick.replace(rec, 28, 0, 0, Left(Pick.extract(Format, 28, 0, 0) & Space(33), 33)) & Right(Space(7) & Pick.extract(report, 6, 1, 0), 7) & " " & Right(Space(14) & Pick.oconv(Pick.extract(report, 6, 2, 0), "MD2"), 14) & Right(Space(7) & Pick.extract(report, 6, 3, 0), 7) & " " & Right(Space(14) & Pick.oconv(Pick.extract(report, 6, 4, 0), "MD2"), 14)
     rec = Pick.replace(rec, 29, 0, 0, Space(33) & "-------" & " " & String$(14, "-") & " " & "-------" & " " & String$(14, "-"))
     rec = Pick.replace(rec, 30, 0, 0, Pick.extract(Format, 29, 0, 0))
     rec = Pick.replace(rec, 31, 0, 0, Left(Pick.extract(Format, 31, 0, 0) & Space(33), 33)) & Right(Space(7) & Pick.extract(report, 7, 1, 0), 7) & " " & Right(Space(14) & Pick.oconv(Pick.extract(report, 7, 2, 0), "MD2"), 14) & Right(Space(7) & Pick.extract(report, 7, 3, 0), 7) & " " & Right(Space(14) & Pick.oconv(Pick.extract(report, 7, 4, 0), "MD2"), 14)
     rec = Pick.replace(rec, 32, 0, 0, Space(33) & "-------" & " " & String$(14, "-") & " " & "-------" & " " & String$(14, "-"))
     For Ii = 31 To 39
        rec = Pick.replace(rec, Ii + 2, 0, 0, Pick.extract(Format, Ii, 0, 0))
     Next Ii
     rec = Pick.replace(rec, 42, 0, 0, Left(Pick.extract(Format, 42, 0, 0) & Space(33), 33) & Space(8) & Right(Space(14) & Pick.oconv(Pick.extract(report, 8, 2, 0), "MD2"), 14) & Space(9) & Right(Space(14) & Pick.oconv(Pick.extract(report, 8, 4, 0), "MD2"), 14))
     For Ii = 41 To 42
        rec = Pick.replace(rec, Ii + 2, 0, 0, Pick.extract(Format, Ii, 0, 0))
     Next Ii
     rec = Pick.replace(rec, 45, 0, 0, Left(Pick.extract(Format, 43, 0, 0) & Space(33), 33) & Space(8) & Right(Space(14) & Pick.oconv(Pick.extract(report, 9, 2, 0), "MD2"), 14) & Space(9) & Right(Space(14) & Pick.oconv(Pick.extract(report, 9, 4, 0), "MD2"), 14))
     rec = Pick.replace(rec, 46, 0, 0, Space(33) & Space(7) & " " & String$(14, "-") & " " & Space(7) & " " & String$(14, "-"))
     rec = Pick.replace(rec, 47, 0, 0, Pick.extract(Format, 44, 0, 0))
     rec = Pick.replace(rec, 47, 0, 0, Left(Pick.extract(Format, 45, 0, 0) & Space(33), 33) & Space(8) & Right(Space(14) & Pick.oconv(Pick.extract(report, 10, 2, 0), "MD2"), 14) & Space(9) & Right(Space(14) & Pick.oconv(Pick.extract(report, 10, 4, 0), "MD2"), 14))
     rec = Pick.replace(rec, 48, 0, 0, Space(33) & Space(7) & " " & String$(14, "-") & " " & Space(7) & " " & String$(14, "-"))
     rec = Pick.replace(rec, 49, 0, 0, Pick.extract(Format, 46, 0, 0))
     rec = Pick.replace(rec, 50, 0, 0, Pick.extract(Format, 47, 0, 0))
     rec = Pick.replace(rec, 51, 0, 0, Left(Pick.extract(Format, 48, 0, 0) & Space(33), 33)) & Space(31) & Right(Space(14) & Pick.oconv(Pick.extract(report, 11, 4, 0), "MD2"), 14)
     rec = Pick.replace(rec, 52, 0, 0, Space(64) & String$(14, "="))
     Return

'
'***********************
' S/R 600 - Print Report
'***********************
600  For Ii = 1 To 52
        Printer.Print Pick.extract(rec, Ii, 0, 0)
     Next Ii
     Return

End Sub
Public Function TA1629(logentry As String, Params As String)
' TA1629 BATCH REPORT OF ALL CHANGES
Dim Prog, database As String, Brec As String, Oper As String, want_ptr As String, Lns$, Del, Prt, Lct, I As Integer, Id As String, Assess As String, prop As String, Subhead As String
Dim Startnum As String, Which, Rates As String, Ratesrub As String, ValCodes As String, Rates_Cat As String, CFlags As String, Nomayvote As String, Muloc As String, Chk_Dig As String, Quals As String, Check_Sec As String, Status As String, Class As String, relate As String, Head1 As String, Indices As String, Prophdg As String, Ward_Tag As String
Dim rec As String, Changes_Data As String
'
Prog = "TA1629"

    database = Pick.extract(logentry, 2, 0, 0)
     
    Oper = Pick.extract(Params, 1, 0, 0)
    want_ptr = Trim(Pick.extract(Params, 2, 0, 0))
    
'    On Error GoTo error_ptr
    Set Printer = Printers(CInt(want_ptr))
'    On Error GoTo error_printing
    Call printer_on_off(1, "", 8, vbPRORLandscape)


    Call Sr1620(database, Rates, Ratesrub, ValCodes, Rates_Cat, CFlags, "", Nomayvote, Muloc, Chk_Dig, Quals, Check_Sec, Status, Class, relate, Head1, Indices, Prophdg, Ward_Tag)
'
'

    If d3.d3_readstr(database, Brec, "CH.BATCH", Oper) <> 0 Then
        TA1629 = Chr$(8) & "No batch for this operator "
        Exit Function
    End If
'
    Lct = 0
    For I = 2 To 9999
        Id = Pick.extract(Brec, I, 0, 0)
        If Id = "" Then GoTo 200
        If d3.d3_readstr(database, rec, "CHANGES", Id) <> 0 Then GoTo 100
        Assess = Pick.field(Id, "|", 2)
        If d3.d3_readstr(database, prop, "PROPERTY", Assess) <> 0 Then prop = ""
        Startnum = Pick.field(Id, "|", 3)
        Which = Pick.field(Id, "|", 1)
        Call SR1607P(database, Assess, Subhead, prop, Startnum, Which & Chr(253) & 1 & Chr(253) & Oper, Lct, Prophdg, Rates)
        If Startnum = "END" Then GoTo 200
100  Next I
'
200  Call printer_on_off(0)
Exit Function

ThisErr:
Printer.Print Err.Description
Exit Function

error_ptr:
   TA1629 = Chr(8) & Err & " - " & Error(Err) & " - cannot Set Printer"
   Exit Function
error_ptrname:
   TA1629 = Chr(8) & Err & " - " & Error(Err) & " - printer name " & want_ptr
   Exit Function
error_printing:
   TA1629 = Chr(8) & Err & " - " & Error(Err)
   Exit Function


End Function



Public Sub SR1607P(database As String, Assess As String, Subhead As String, prop As String, Startnum As String, Which_Flags As String, Lct, Prophdg As String, Rates As String)

Dim rderr, Which, Wantdisp, Oper, Am As String, Vm As String, Svm As String, Startdate
Dim Qld_Fmt, Xlines As String, Nomayvote, Bar, Llen, Maxlct, Arec As String, Maxa
Dim OLD As String, Newone As String, I As Integer, cnt As Integer, Client_No As String, Lns$, Cls$, Msg$, Ans, Pclrec As String, Hdesc
Dim Narr, Mvnarr, Sline, P As Integer, P_Maxsvm As Integer, Prted, rec As String, Pnum As Integer
Dim Pct As Integer, Cnum As Integer, Cct, Readp, Readc, Crec As String, Prec As String, Maxn, Attr As Integer
Dim J As Integer, This_Cat, This_Attr As Integer, This_Code, This_Desc, This_Fld As String
Dim New_Incr, Old_Incr, Sold As String, Snew As String, Oldj As String, Name As String, Emsg As String, Newj As String, Max
Dim Num_New, Ii As Integer, Maxj, tst As Integer

'
' DISPLAY PROPERTY HISTORY
'
     If UBound(g_trans_info_array) = 0 Then
        g_trans_info_array(0) = "TRANS.INFO"
        rderr = d3.d3_readmat(database, g_trans_info_array(), "DICT TRANS.J")
     End If
     Which = Pick.extract(Which_Flags, 1, 1, 0): Wantdisp = Pick.extract(Which_Flags, 1, 2, 0): Oper = Pick.extract(Which_Flags, 1, 3, 0)
     Am = Chr(254)
     Vm = Chr(253)
     Svm = Chr(252)
     If Pick.extract(Startnum, 1, 2, 0) = "D" Then
        Startdate = Pick.extract(Startnum, 1, 1, 0)
        Startnum = ""
     Else
        Startdate = ""
     End If
'     Qld_Fmt = Mid$(pick.extract(TRANS_INFO, 53, 0, 0), 4, 1) + 0
     Xlines = ""
     Nomayvote = Mid$(g_trans_info_array(53), 1, 1) + 0
     Bar = "|"
     Llen = 130: Maxlct = 55
     If d3.d3_readstr(database, Arec, "SCROLL.KEYS", "@A|PROPERTY") <> 0 Then Arec = ""
     Maxa = Pick.ccount(Arec, Chr(254), 1) + 1
     For I = 1 To Maxa
'       IF AREC<I,1>#'' THEN PROPHDG<I,1>=AREC<I,1>
        If Pick.extract(Prophdg, I, 1, 0) = "" Then Prophdg = Pick.replace(Prophdg, I, 1, 0, Pick.extract(Arec, I, 1, 0))
     Next I
     Dim C(999)
     C(1) = "Name": C(2) = "Address-1": C(3) = "Address-2": C(4) = "Address-3"
     C(5) = "Postcode": C(32) = "Votes Cncl": C(33) = "Votes Mayl"
     C(16) = "Senior No": C(17) = "Pen Start": C(18) = "Pen End": C(19) = "Defer"
     C(14) = "Pens type"
     C(34) = "Qual": C(35) = "Owners": C(36) = "Electors": C(37) = "Occupiers"
     C(38) = "Roll": C(43) = "Pens no": C(44) = "Pensioner": C(84) = "Senior"
     If Lct = 0 Then
        Printer.Print "PROPERTY/CLIENT CHANGES FOR " & Oper & " AS PRINTED AT " & Format$(Now, "DD MMM YY")
     End If
     cnt = 0
'
100  cnt = cnt + 1
     Client_No = Pick.extract(Assess, 1, cnt, 0)
     If Client_No = "" Then
101     Exit Sub '* TO CALLING PROGRAM **
     End If

     If d3.d3_readstr(database, Pclrec, "CLIENT", Client_No) <> 0 Then Pclrec = ""
     If Pick.extract(Pclrec, 28, 0, 0) = 1 Then
        Hdesc = "PROPERTY "
     Else
        Select Case Pclrec
           Case Pick.replace(Pclrec, 10, 0, 0, "")
              Hdesc = "CREDITOR "
           Case Pick.replace(Pclrec, 10, 0, 0, 1)
              Hdesc = "DEBTOR "
           Case Pick.replace(Pclrec, 10, 0, 0, 2)
              Hdesc = "OWNER/OCCUPIER "
           Case 1
              Hdesc = "UNKNOWN TYPE "
        End Select
     End If
     GoSub 5000
     Printer.Print Hdesc & Client_No & Space(5) & Trim(Pick.extract(Pclrec, 1, 0, 0) & " " & Pick.extract(Pclrec, 2, 1, 0) & " " & Pick.extract(Pclrec, 3, 1, 0) & " " & Pick.extract(Pclrec, 4, 1, 0) & " " & Pick.extract(Pclrec, 5, 1, 0))
'
'     If Qld_Fmt Then
'        XLINES= "Vg no &  " & PICK.EXTRACT(PROP,46,0,0) & "     Area &  " & PICK.EXTRACT(PROP,7,0,0) & "   M"gee &  " & PROP<49>
'        Narr = pick.extract(PROP, 28, 1, 0) & " " & pick.extract(PROP, 28, 2, 0) & " " & pick.extract(PROP, 28, 3, 0) & " " & pick.extract(PROP, 28, 4, 0)
'        Mvnarr = ""
'        Call SR525(Narr, (Llen - 20), Mvnarr) '*DONOTALTER**
'        I = 0
'        Loop
'           I = I + 1
'        UNTIL MVNARR=PICK.REPLACE(MVNARR,1,I,0,"") DO
'           If I = 1 Then
'              Xlines = Xlines & Svm & "Description &  " & pick.extract(Mvnarr, 1, I, 0)
'           Else
'              Xlines = Xlines & Svm & Space(5) & pick.extract(Mvnarr, 1, I, 0)
'           End If
'        Repeat
'     End If

     If Which = "" Then
        P_Maxsvm = Pick.ccount(Subhead, Svm, 1) + 1
        If Xlines <> "" Then
            Subhead = Pick.delet(Subhead, 1, 1, P_Maxsvm) ' DELETE BLANK LINE
            Subhead = Subhead & Svm & Pick.extract(Xlines, 1, 1, 0) & Svm
            P_Maxsvm = Pick.ccount(Subhead, Svm, 1) + 1
        End If
        Sline = P_Maxsvm
        Lct = Maxlct + 1
        GoSub 5000
     Else
        Sline = 3
'        GOSUB 5000; PRINT; GOSUB 5000; PRINT
'        GOSUB 5000; PRINT STR('=',LLEN)
        GoSub 5000: Printer.Print String$((Llen / 2), "- ")
     End If
     If Wantdisp Then GoSub 5000: Printer.Print "PROPERTY "; Client_No; Space(5); Trim(Pick.extract(Pclrec, 1, 0, 0) & " " & Pick.extract(Pclrec, 2, 1, 0) & " " & Pick.extract(Pclrec, 3, 1, 0) & " " & Pick.extract(Pclrec, 4, 1, 0) & " " & Pick.extract(Pclrec, 5, 1, 0))
     If Startnum > 1 Then GoTo 950
     Prted = 0
     If Pick.extract(prop, 42, 0, 0) <> "" Or Pick.extract(prop, 43, 0, 0) <> "" Then
        GoSub 5000: Printer.Print "Added: "; Left(Pick.oconv(Pick.extract(prop, 42, 0, 0), "D2") & Space(14), 14); Pick.extract(prop, 43, 0, 0): Prted = 1
     End If
     If Pick.extract(prop, 44, 0, 0) <> "" Then GoSub 5000: Printer.Print Space(25); Pick.extract(prop, 44, 0, 0): Prted = 1
     If Pick.extract(prop, 84, 0, 0) <> "" Then GoSub 5000: Printer.Print Space(25); Pick.extract(prop, 84, 0, 0): Prted = 1
     If Pick.extract(prop, 45, 0, 0) <> "" Then GoSub 5000: Printer.Print Space(25); Pick.extract(prop, 45, 0, 0): Prted = 1
     If Prted Then GoSub 5000: Printer.Print String$((Llen / 2), "- ")
'
950  If d3.d3_readstr(database, rec, "CHANGES", "P" & Bar & Client_No) <> 0 Then rec = ""
     Pnum = Pick.extractint(rec, 2, 0, 0)
     Pct = 0
     If d3.d3_readstr(database, rec, "CHANGES", "C" & Bar & Client_No) <> 0 Then rec = ""
     Cnum = Pick.extractint(rec, 2, 0, 0)
     Cct = 0
     Readp = 1: Readc = 1
     If Which = "P" Then Readc = 0: Crec = 99999: Pct = Startnum - 1
     If Which = "C" Then Readp = 0: Prec = 99999: Cct = Startnum - 1
'
1000 If Readp Then
1005    Pct = Pct + 1
        If Pct <= Pnum Then
           If d3.d3_readstr(database, Prec, "CHANGES", "P" & Bar & Client_No & Bar & Pct) <> 0 Then GoTo 1005
           If Startdate <> "" Then
              If Pick.extract(Prec, 1, 0, 0) < Startdate Then GoTo 1000
           End If
        Else
           Prec = "99999"
        End If
        Readp = 0
     End If
     If Readc Then
1010    Cct = Cct + 1
        If Cct <= Cnum Then
           If d3.d3_readstr(database, Crec, "CHANGES", "C" & Bar & Client_No & Bar & Cct) <> 0 Then GoTo 1010
           If Startdate <> "" Then
              If Pick.extract(Crec, 1, 0, 0) < Startdate Then GoTo 1000
           End If
        Else
           Crec = "99999"
        End If
        Readc = 0
     End If
     If Pick.extract(Prec, 1, 0, 0) = Pick.extract(Crec, 1, 0, 0) Then tst = 2 Else tst = 1
     If Pick.extract(Prec, tst, 0, 0) <= Pick.extract(Crec, tst, 0, 0) Then Readp = 1: rec = Prec Else Readc = 1: rec = Crec
     If rec = "99999" Then GoTo 100
'
     GoSub 5000: Printer.Print "Altered: "; Left(Pick.oconv(Pick.extract(rec, 1, 0, 0), "D2") & Space(14), 14); Pick.extract(rec, 6, 1, 0)
     Maxn = Pick.ccount(Pick.extract(rec, 6, 0, 0), Chr(253), 1) + 1: If Pick.extract(rec, 6, 0, 0) = "" Then Maxn = 0
     For I = 2 To Maxn
        Msg = Pick.extract(rec, 6, I, 0)
        If Msg <> "" Then GoSub 5000: Printer.Print Space(25); Pick.extract(rec, 6, I, 0)
     Next I
     For I = 1 To 999
        Attr = Pick.extractint(rec, 7, I, 0)
        If Attr = 0 Then
           GoSub 5000: Printer.Print String$((Llen / 2), "- ")
           GoTo 1000
        End If
        OLD = Pick.extract(rec, 6 + 2 * I, 0, 0): OLD = Pick.delet(OLD, 1, 1, 0)
        Newone = Pick.extract(rec, 7 + 2 * I, 0, 0)
        Newone = Pick.delet(Newone, 1, 1, 0)
        If Readp Then
           Msg = Pick.extract(Prophdg, Attr, 1, 0)
           Select Case Attr
            Case 34 To 35
              If OLD <> "" Then OLD = Pick.oconv(Trim(OLD), "D2")
              If Newone <> "" Then Newone = Pick.oconv(Trim(Newone), "D2")
            Case 29
              For J = 1 To 9999
                If Pick.extract(OLD, 1, J, 0) = "" And Pick.extract(Newone, 1, J, 0) = "" Then GoTo 1300
                If Pick.extract(OLD, 1, J, 1) <> "" Or Pick.extract(OLD, 1, J, 2) <> "" Then
                  This_Cat = Pick.extract(OLD, 1, J, 1)
                  This_Attr = (This_Cat * 10) - 1
                  This_Code = Pick.extract(Rates, This_Attr, 2, 0)
                  This_Desc = Pick.extract(Rates, This_Attr, 1, 0)
                  This_Fld = This_Code & " " & Pick.extract(OLD, 1, J, 1) & "/" & Pick.extract(OLD, 1, J, 2) & " " & This_Desc
                  OLD = Pick.replace(OLD, 1, J, 0, This_Fld)
                Else
                    OLD = Pick.replace(OLD, 1, J, 0, "")
                End If
'
                If Pick.extract(Newone, 1, J, 1) <> "" Or Pick.extract(Newone, 1, J, 2) <> "" Then
                  This_Cat = Pick.extract(Newone, 1, J, 1)
                  This_Attr = (This_Cat * 10) - 1
                  This_Code = Pick.extract(Rates, This_Attr, 2, 0)
                  This_Desc = Pick.extract(Rates, This_Attr, 1, 0)
                  This_Fld = This_Code & " " & Pick.extract(Newone, 1, J, 1) & "/" & Pick.extract(Newone, 1, J, 2) & " " & This_Desc
                  Newone = Pick.replace(Newone, 1, J, 0, This_Fld)
                Else
                    Newone = Pick.replace(Newone, 1, J, 0, "")
                End If
             Next J
           Case 30
             If Newone <> "" Then
                New_Incr = Pick.extract(Newone, 1, 1, 5)
                Newone = Pick.extract(Newone, 1, 1, 1) & "," & Pick.extract(Newone, 1, 1, 2) & " to " & Pick.extract(Newone, 1, 1, 3) & " in yr" & Pick.extract(Newone, 1, 1, 4) + 0 & " "
                If New_Incr <> "" Then Newone = Newone & "int " & New_Incr
             End If
             If OLD <> "" Then
                Old_Incr = Pick.extract(OLD, 1, 1, 5)
                OLD = Pick.extract(OLD, 1, 1, 1) & "," & Pick.extract(OLD, 1, 1, 2) & " to " & Pick.extract(OLD, 1, 1, 3) & " in yr" & Pick.extract(OLD, 1, 1, 4) + 0 & " "
                If Old_Incr <> "" Then OLD = OLD & "int " & Old_Incr
             End If
1300       End Select
        Else
           Msg = C(Attr)
           If Attr = 32 Or Attr = 33 Or Attr = 34 Or Attr = 38 Then GoTo 1690
' these will be done by finding 36 first - electoral information
           If Attr = 35 Or Attr = 36 Or Attr = 37 Then
              Sold = OLD: Snew = Newone
              OLD = "": Newone = ""
              For J = 1 To 999
                 Oldj = Pick.extractint(Sold, 1, J, 0)
                 If Oldj = "" Then GoTo 1610
                 If d3.d3_readstr(database, Name, "CLIENT", Oldj) <> 0 Then Name = ""
                 Name = Pick.extract(Name, 1, 0, 0) & " " & Pick.extract(Name, 6, 0, 0)
                 OLD = Pick.insert(OLD, 1, -1, 0, Name)
                 If Attr = 36 Then
                    Emsg = "Roll " & Pick.extract(rec, 6 + (I + 1) * 2, 2, 0) & " Qual " & Pick.extract(rec, 6 + (I + 2) * 2, 2, 0) & " Cncl " & Pick.extract(rec, 6 + (I + 3) * 2, 2, 0)
                    If Nomayvote = 0 Then
                       Emsg = Emsg & " Mayl " & Pick.extract(rec, 6 + (I + 4) * 2, 2, 0)
                    End If
                    OLD = Pick.insert(OLD, 1, -1, 0, Emsg)
                 End If
              Next J
1610          For J = 1 To 999
                 Newj = Pick.extract(Snew, 1, J, 0)
                 If Newj = "" Then GoTo 1620
                 If d3.d3_readstr(database, Name, "CLIENT", Newj) <> 0 Then Name = ""
                 Name = Pick.extract(Name, 1, 0, 0) & " " & Pick.extract(Name, 6, 0, 0)
                 Newone = Pick.insert(Newone, 1, -1, 0, Name)
                 If Attr = 36 Then
                    Emsg = "Roll " & Pick.extract(rec, 7 + (I + 1) * 2, 2, 0) & " Qual " & Pick.extract(rec, 7 + (I + 2) * 2, 2, 0) & " Cncl " & Pick.extract(rec, 7 + (I + 3) * 2, 2, 0)
                    If Nomayvote = 0 Then
                       Emsg = Emsg & " Mayl " & Pick.extract(rec, 7 + (I + 4) * 2, 2, 0)
                    End If
                    Newone = Pick.insert(Newone, 1, -1, 0, Emsg)
                 End If
              Next J
           End If
           If Attr = 17 Or Attr = 18 Then
              Max = Pick.ccount(OLD, Chr(253), 1) + 1
              Num_New = Pick.ccount(Newone, Chr(253), 1) + 1
              If Num_New > Max Then Max = Num_New
              For Ii = 1 To Max
                 If Pick.extract(OLD, 1, Ii, 0) = "" And Pick.extract(Newone, 1, Ii, 0) = "" Then GoTo 1615
                 If Pick.extract(OLD, 1, Ii, 0) <> "" Then OLD = Pick.replace(OLD, 1, Ii, 0, Pick.oconv(Pick.extract(OLD, 1, Ii, 0), "D2"))
                 If Pick.extract(Newone, 1, Ii, 0) <> "" Then Newone = Pick.replace(Newone, 1, Ii, 0, Pick.oconv(Pick.extract(Newone, 1, Ii, 0), "D2"))
1615          Next Ii
           End If
        End If
1620    GoSub 5000: Printer.Print Left(Msg & Space(11), 11) & "Old:" & Left(Pick.extract(OLD, 1, 1, 0) & Space(55), 55) & "New:" & Left(Pick.extract(Newone, 1, 1, 0) & Space(55), 55)
        Maxj = Pick.dcount(Pick.extract(OLD, 1, 0, 0), Chr(253))
        If Pick.dcount(Pick.extract(Newone, 1, 0, 0), Chr(253)) > Maxj Then Maxj = Pick.dcount(Pick.extract(Newone, 1, 0, 0), Chr(253))
        For J = 2 To Maxj
           GoSub 5000: Printer.Print Space(11); "Old: "; Left(Pick.extract(OLD, 1, J, 0) & Space(55), 55) & "New:" & Left(Pick.extract(Newone, 1, J, 0) & Space(55), 55)
        Next J
1690 Next I
     GoTo 1000
'
5000 Lct = Lct + 1
     If Lct > Maxlct Then

        If Which = "" Then
            GoSub 9000
            Lct = P_Maxsvm
        Else
            Printer.Print Chr(12)
            Printer.Print
            Lct = 2
        End If
     End If
     Return
9000 P = 0
     Do While P <= P_Maxsvm
        P = P + 1
        Printer.Print Pick.extract(Subhead, 1, 1, P)
     Loop
     Return

End Sub

Public Sub Sr1620(database As String, Rates As String, Ratesrub As String, ValCodes As String, Rates_Cat As String, CFlags, logamend, Nomayvote, Muloc As String, Chk_Dig As String, Quals, Check_Sec As String, Status As String, Class As String, relate As String, Head1 As String, Indices As String, Prophdg As String, Ward_Tag As String)
Dim Unused, No_Vals, J As Integer
Dim I As Integer, This_Attr As Integer, Nocat, Logamendif, rderr

If UBound(g_trans_info_array) = 0 Then
    g_trans_info_array(0) = "TRANS.INFO"
    rderr = d3.d3_readmat(database, g_trans_info_array(), "DICT TRANS.J")
End If
Unused = ""

If d3.d3_readstr(database, Prophdg, "DICT TRANS.J", "@PROPERTY") <> 0 Then Prophdg = ""
     If Pick.extract(Prophdg, 1, 1, 0) = "" Then Prophdg = Pick.replace(Prophdg, 1, 1, 0, "Lot No")
     If Pick.extract(Prophdg, 2, 1, 0) = "" Then Prophdg = Pick.replace(Prophdg, 2, 1, 0, "Location")
     If Pick.extract(Prophdg, 5, 1, 0) = "" Then Prophdg = Pick.replace(Prophdg, 5, 1, 0, "Frontage")
     If Pick.extract(Prophdg, 6, 1, 0) = "" Then Prophdg = Pick.replace(Prophdg, 6, 1, 0, "Depth")
     If Pick.extract(Prophdg, 7, 1, 0) = "" Then Prophdg = Pick.replace(Prophdg, 7, 1, 0, "Area")
     If Pick.extract(Prophdg, 8, 1, 0) = "" Then Prophdg = Pick.replace(Prophdg, 8, 1, 0, "Cur Zoning")
     If Pick.extract(Prophdg, 9, 1, 0) = "" Then Prophdg = Pick.replace(Prophdg, 9, 1, 0, "Pres use")
     If Pick.extract(Prophdg, 10, 1, 0) = "" Then Prophdg = Pick.replace(Prophdg, 10, 1, 0, "Build")
     If Pick.extract(Prophdg, 12, 1, 0) = "" Then Prophdg = Pick.replace(Prophdg, 12, 1, 0, "Pool ")
     If Pick.extract(Prophdg, 14, 1, 0) = "" Then Prophdg = Pick.replace(Prophdg, 14, 1, 0, "Min Rate C")
     If Pick.extract(Prophdg, 15, 1, 0) = "" Then Prophdg = Pick.replace(Prophdg, 15, 1, 0, "Valuation")
     If Pick.extract(Prophdg, 16, 1, 0) = "" Then Prophdg = Pick.replace(Prophdg, 16, 1, 0, "Prev Value")
     If Pick.extract(Prophdg, 18, 1, 0) = "" Then Prophdg = Pick.replace(Prophdg, 18, 1, 0, "S/unit Ent")
     If Pick.extract(Prophdg, 19, 1, 0) = "" Then Prophdg = Pick.replace(Prophdg, 19, 1, 0, "Rate flag")
     If Pick.extract(Prophdg, 21, 1, 0) = "" Then Prophdg = Pick.replace(Prophdg, 21, 1, 0, "Rubb charge (n)")
     If Pick.extract(Prophdg, 22, 1, 0) = "" Then Prophdg = Pick.replace(Prophdg, 22, 1, 0, "Strata no")
     If Pick.extract(Prophdg, 23, 1, 0) = "" Then Prophdg = Pick.replace(Prophdg, 23, 1, 0, "Strata lot")
     If Pick.extract(Prophdg, 26, 1, 0) = "" Then Prophdg = Pick.replace(Prophdg, 26, 1, 0, "Fut value")
     If Pick.extract(Prophdg, 27, 1, 0) = "" Then Prophdg = Pick.replace(Prophdg, 27, 1, 0, "Prev zoning")
     If Pick.extract(Prophdg, 29, 1, 0) = "" Then Prophdg = Pick.replace(Prophdg, 29, 1, 0, "Val category")
     If Pick.extract(Prophdg, 30, 1, 0) = "" Then Prophdg = Pick.replace(Prophdg, 30, 1, 0, "Phased yrs")
     If Pick.extract(Prophdg, 34, 1, 0) = "" Then Prophdg = Pick.replace(Prophdg, 34, 1, 0, "Reval date")
     If Pick.extract(Prophdg, 35, 1, 0) = "" Then Prophdg = Pick.replace(Prophdg, 35, 1, 0, "Reval effect")
     If Pick.extract(Prophdg, 38, 1, 0) = "" Then Prophdg = Pick.replace(Prophdg, 38, 1, 0, "Ward")
     If Pick.extract(Prophdg, 1, 2, 0) = "" Then Prophdg = Pick.replace(Prophdg, 1, 2, 0, "Lot No")
     If Pick.extract(Prophdg, 2, 2, 0) = "" Then Prophdg = Pick.replace(Prophdg, 2, 2, 0, "Location")
     If Pick.extract(Prophdg, 5, 2, 0) = "" Then Prophdg = Pick.replace(Prophdg, 5, 2, 0, "Frontage")
     If Pick.extract(Prophdg, 6, 2, 0) = "" Then Prophdg = Pick.replace(Prophdg, 6, 2, 0, "Depth")
     If Pick.extract(Prophdg, 7, 2, 0) = "" Then Prophdg = Pick.replace(Prophdg, 7, 2, 0, "Area")
     If Pick.extract(Prophdg, 8, 2, 0) = "" Then Prophdg = Pick.replace(Prophdg, 8, 2, 0, "Current Zoning")
     If Pick.extract(Prophdg, 9, 2, 0) = "" Then Prophdg = Pick.replace(Prophdg, 9, 2, 0, "Present use")
     If Pick.extract(Prophdg, 10, 2, 0) = "" Then Prophdg = Pick.replace(Prophdg, 10, 2, 0, "Building type & Cond")
     If Pick.extract(Prophdg, 12, 2, 0) = "" Then Prophdg = Pick.replace(Prophdg, 12, 2, 0, "Pool (N/A/B)?")
     If Pick.extract(Prophdg, 14, 2, 0) = "" Then Prophdg = Pick.replace(Prophdg, 14, 2, 0, "Min Rate Category")
     If Pick.extract(Prophdg, 15, 2, 0) = "" Then Prophdg = Pick.replace(Prophdg, 15, 2, 0, "Valuation")
     If Pick.extract(Prophdg, 16, 2, 0) = "" Then Prophdg = Pick.replace(Prophdg, 16, 2, 0, "Previous Valuation")
     If Pick.extract(Prophdg, 18, 2, 0) = "" Then Prophdg = Pick.replace(Prophdg, 18, 2, 0, "S/unit Entitlement")
     If Pick.extract(Prophdg, 19, 2, 0) = "" Then Prophdg = Pick.replace(Prophdg, 19, 2, 0, "Rateable flag")
     If Pick.extract(Prophdg, 21, 2, 0) = "" Then Prophdg = Pick.replace(Prophdg, 21, 2, 0, "Rubbish charge (n)")
     If Pick.extract(Prophdg, 22, 2, 0) = "" Then Prophdg = Pick.replace(Prophdg, 22, 2, 0, "Strata plan no")
     If Pick.extract(Prophdg, 23, 2, 0) = "" Then Prophdg = Pick.replace(Prophdg, 23, 2, 0, "Strata lot no")
     If Pick.extract(Prophdg, 26, 2, 0) = "" Then Prophdg = Pick.replace(Prophdg, 26, 2, 0, "Future value")
     If Pick.extract(Prophdg, 27, 2, 0) = "" Then Prophdg = Pick.replace(Prophdg, 27, 2, 0, "Previous zoning")
     If Pick.extract(Prophdg, 29, 2, 0) = "" Then Prophdg = Pick.replace(Prophdg, 29, 2, 0, "Val category")
     If Pick.extract(Prophdg, 34, 2, 0) = "" Then Prophdg = Pick.replace(Prophdg, 34, 2, 0, "Revaluation date")
     If Pick.extract(Prophdg, 35, 2, 0) = "" Then Prophdg = Pick.replace(Prophdg, 35, 2, 0, "Revaluation effective")
     If Pick.extract(Prophdg, 38, 2, 0) = "" Then Prophdg = Pick.replace(Prophdg, 38, 2, 0, "Ward")
'
ValCodes = ""
'
' VALCODES
' --------------------
'
' Attr 1         = category descriptions multi-valued
' Attr 2 onwards = rate code descriptions multi-valued
'                  attribute is relevant category number+1
'                  eg. attr 2 relates to category 1
'                  sub-value 1 = code
'                  sub-value 2 = narrative
'
If d3.d3_readstr(database, Rates_Cat, "DICT TRANS.J", "@RATES_CAT") <> 0 Then Rates_Cat = 0
Rates_Cat = Pick.extractint(Rates_Cat, 1, 1, 0)
If d3.d3_readstr(database, Rates, "DICT TRANS.J", "@RATES") <> 0 Then Rates = ""
ValCodes = Pick.replace(ValCodes, 1, 0, 0, Pick.extract(Rates, 9, 1, 0))
ValCodes = Pick.replace(ValCodes, 2, 0, 0, Pick.extract(Rates, 1, 0, 0))
No_Vals = Pick.ccount(Pick.extract(Rates, 1, 0, 0), Chr(253), 1) + 1
For J = 1 To No_Vals
  ValCodes = Pick.replace(ValCodes, 2, J, 2, Pick.extract(Rates, 8, J, 0))
Next J
If d3.d3_readstr(database, Ratesrub, "DICT TRANS.J", "@RATESRUB") <> 0 Then Ratesrub = ""
If Rates_Cat Then  ' multiple rating categories
   For I = 2 To 999
      This_Attr = (I * 10) - 9
      If Pick.extract(Rates, This_Attr + 8, 0, 0) = "" Then GoTo 50
      ValCodes = Pick.replace(ValCodes, I + 1, 0, 0, Pick.extract(Rates, This_Attr, 0, 0))
      No_Vals = Pick.ccount(Pick.extract(Rates, This_Attr, 0, 0), Chr(253), 1) + 1
      For J = 1 To No_Vals
        ValCodes = Pick.replace(ValCodes, I + 1, J, 2, Pick.extract(Rates, This_Attr + 7, J, 0))
      Next J
      ValCodes = Pick.replace(ValCodes, 1, I, 0, Pick.extract(Rates, This_Attr + 8, 1, 0))
   Next I
50:
End If
'
If d3.d3_readstr(database, Indices, "DICT TRANS.J", "@INDICES") <> 0 Then Indices = ""
CFlags = g_trans_info_array(53)
Nocat = Mid$(CFlags, 7, 1) + 0: Logamendif = Mid$(CFlags, 11, 1) + 0
Nomayvote = Mid$(CFlags, 1, 1) + 0: Muloc = Mid$(CFlags, 8, 1) + 0
If d3.d3_readstr(database, Chk_Dig, "DICT CLIENT", "@ALL") <> 0 Then Chk_Dig = 1: GoTo 1
Chk_Dig = 0
1: Quals = "AO" & Chr(253) & "OO" & Chr(253) & "CAO" & Chr(253) & "COO" & Chr(253) & "O" & Chr(253) & "CO" & Chr(253) & "N"
Check_Sec = String$(10, "1")
If d3.d3_readstr(database, Status, "DICT TDEBTOR", "@STATUS") <> 0 Then Status = ""
If d3.d3_readstr(database, Class, "DICT TDEBTOR", "@CLASS") <> 0 Then Class = ""
If d3.d3_readstr(database, relate, "DICT TDEBTOR", "@RELATE") <> 0 Then relate = ""
'
'READV WARD_TAG FROM TRANS_J_DICT,"@PROPERTY",38 ELSE WARD_TAG = ""
If d3.d3_readstr(database, Ward_Tag, "DICT TRANS.J", "@PROPERTY", 38) <> 0 Then Ward_Tag = ""
If Ward_Tag = "" Then Ward_Tag = "Ward"
'
Head1 = "(L)oad, (A)mend, (DS)display Property Details, (Q)uestions &   "

End Sub


Public Function TA1654(logentry As String, parms As String)
' TA1654 RATES & CHARGES PERIODIC RECONCILIATION
Dim Cde As String, from_date As String, to_date As String, Summa As String, want_ptr As String, Prog, database As String, Am, Vm, Svm, Erm, cnt, report As String
Dim P_Flag, Ennd, Sent As String, Cls$, Lns$, Ans, Box_Type, Err As String, temp() As String
Dim Pos, desc, IFDate As String, ITDate As String, Rating_Yr As String, xx As Long
Dim other As String, arr_date As String, Areas, Report_Id As String, Key As String, Ass_Rec As String, Tdebtor_Rec As String, Assess As String
Dim ClientRec As String, Property_Rec As String, print_ctl As String, Eom As String, Arr30jun, Arr_Preperiod
Dim Levy_Raised_Period, Int_Raised_Period, Pen_Raised_Period, Levy_Raised_Ytd
Dim Int_Raised_Ytd, Pen_Raised_Ytd, Arr_Paid_Preperiod, Arrears_Paid_Period
Dim Arrears_Paid_Ytd, Curr_Paid_Preperiod, Current_Paid_Period
Dim Current_Paid_Ytd, Period_Raised, Ytd_Raised, Period_Paid, Ytd_Paid
Dim Net_Os, Max, Mlev, Ii, Bon_Row, Mlev_Which, Num, Rates, Jj
Dim rtab, P, Y, mylist() As String, pick_cnt As Long, total_items As String
'
     Prog = "TA1654"
     Am = Chr(254): Vm = Chr(253): Svm = Chr(252)
     database = Pick.extract(logentry, 2, 0, 0)
'     temp = Split(Parms, am)
     Cde = Pick.extract(parms, 1, 0, 0)
     from_date = Pick.extract(parms, 2, 0, 0)
     to_date = Pick.extract(parms, 3, 0, 0)
     Summa = Pick.extract(parms, 4, 0, 0)
     want_ptr = Pick.extract(parms, 5, 0, 0)
     Set Printer = Printers(CInt(want_ptr))
     Call printer_on_off(1, "", 8, vbPRORLandscape)
'
     If UBound(g_trans_info_array) = 0 Then
        g_trans_info_array(0) = "TRANS.INFO"
        Erm = d3.d3_readmat(database, g_trans_info_array(), "DICT TRANS.J")
     End If
'     TA1654 = Chr(8) & Erm
'     Exit Function
     P_Flag = Mid$(g_trans_info_array(53), 17, 1) + 0
     cnt = 0
     Ennd = 0
     print_ctl = Cde
'
     Sent = "SELECT PROPERTY"
'

     IFDate = Pick.ICONV(from_date, "D2")
     ITDate = Pick.ICONV(to_date, "D2")
     report = Pick.replace(report, 2, 1, 0, IFDate): report = Pick.replace(report, 2, 2, 0, ITDate)
     Rating_Yr = Pick.extract(g_trans_info_array(59), 1, 1, 0)
     arr_date = Pick.ICONV("01 JUL " & Rating_Yr, "D2")
'
'
'
     Err = d3.execute_tcl(logentry, "CLEAR-FILE DATA RATE.STATS", "")
'
     total_items = d3.d3_select(logentry, Sent, mylist(), pick_cnt, 0, 0)
For xx = 0 To UBound(mylist)
     Assess = mylist(xx)
     Key = Assess & "-" & Cde & "-" & IFDate & "-" & ITDate
     Ass_Rec = ""
     If d3.d3_readstr(database, Tdebtor_Rec, "TDEBTOR", Assess) <> 0 Then Tdebtor_Rec = ""
     If d3.d3_readstr(database, ClientRec, "CLIENT", Assess) <> 0 Then ClientRec = "?? DOES NOT EXIST"
     If d3.d3_readstr(database, Property_Rec, "PROPERTY", Assess) <> 0 Then Property_Rec = ""
'
     cnt = cnt + 1
'
     Eom = ""
'
     Call SR1654_A(database, Tdebtor_Rec, Assess, IFDate, ITDate, Eom, "", "", print_ctl, "", other, arr_date)
'
     Arr30jun = Pick.extractcur(Eom, 1, 1, 0) + Pick.extractcur(Eom, 5, 1, 0)
     Arr_Preperiod = Arr30jun + Pick.extractcur(Eom, 6, 2, 0)
'MsgBox "Arrpreperiod = " & Arr_Preperiod & " Assess = " & Assess
     Levy_Raised_Period = Pick.extractcur(Eom, 2, 3, 0)
     Int_Raised_Period = Pick.extractcur(Eom, 3, 3, 0)
     Pen_Raised_Period = Pick.extractcur(Eom, 4, 3, 0)
     Levy_Raised_Ytd = Pick.extractcur(Eom, 2, 4, 0)
     Int_Raised_Ytd = Pick.extractcur(Eom, 3, 4, 0)
     Pen_Raised_Ytd = Pick.extractcur(Eom, 4, 4, 0)
     Arr_Paid_Preperiod = Pick.extractcur(Eom, 6, 2, 0)
     Arrears_Paid_Period = Pick.extractcur(Eom, 6, 3, 0)
     Arrears_Paid_Ytd = Pick.extractcur(Eom, 6, 4, 0)
     Curr_Paid_Preperiod = Pick.extractcur(Eom, 7, 2, 0)
     Current_Paid_Period = Pick.extractcur(Eom, 7, 3, 0)
     Current_Paid_Ytd = Pick.extractcur(Eom, 7, 4, 0)
'
     Period_Raised = Arr_Preperiod + Levy_Raised_Period + Int_Raised_Period + Pen_Raised_Period
     Ytd_Raised = Arr30jun + Levy_Raised_Ytd + Int_Raised_Ytd + Pen_Raised_Ytd
     Period_Paid = Abs(Arrears_Paid_Period + Current_Paid_Period)
     Ytd_Paid = Abs(Arrears_Paid_Ytd + Current_Paid_Ytd)
     Net_Os = Ytd_Raised - Ytd_Paid
'
     GoSub 600    ' Write each assessment
     GoSub 700    ' Add to totals
'
Next xx
     
     Report_Id = "@" & Cde & "-" & IFDate & "-" & ITDate
     Call d3.d3_writestr(database, "DICT RATE.STATS", Report_Id, report)
     If Summa = 1 Then
        GoSub 900   ' Print report
     Else
        GoSub 950
     End If
     Call printer_on_off(0)
     Exit Function
'
'********************************
' S/R 600 - Write each assessment
'********************************
600  Ass_Rec = ""
     Ass_Rec = Pick.replace(Ass_Rec, 1, 0, 0, Cde)
     Ass_Rec = Pick.replace(Ass_Rec, 2, 0, 0, IFDate & Vm & ITDate)
     Ass_Rec = Pick.replace(Ass_Rec, 3, 0, 0, Vm & Arr_Preperiod & Vm & Vm & Arr30jun)
     Ass_Rec = Pick.replace(Ass_Rec, 4, 0, 0, Vm & Levy_Raised_Period & Vm & Vm & Levy_Raised_Ytd)
     Ass_Rec = Pick.replace(Ass_Rec, 5, 0, 0, Vm & Int_Raised_Period & Vm & Vm & Int_Raised_Ytd)
     Ass_Rec = Pick.replace(Ass_Rec, 6, 0, 0, Vm & Pen_Raised_Period & Vm & Vm & Pen_Raised_Ytd)
     Ass_Rec = Pick.replace(Ass_Rec, 7, 0, 0, Vm & Period_Raised & Vm & Vm & Ytd_Raised)
     Ass_Rec = Pick.replace(Ass_Rec, 8, 0, 0, Vm & Abs(Arrears_Paid_Period) & Vm & Vm & Abs(Arrears_Paid_Ytd))
     Ass_Rec = Pick.replace(Ass_Rec, 9, 0, 0, Vm & Abs(Current_Paid_Period) & Vm & Vm & Abs(Current_Paid_Ytd))
     Ass_Rec = Pick.replace(Ass_Rec, 10, 0, 0, Vm & Period_Paid & Vm & Vm & Ytd_Paid)
     Ass_Rec = Pick.replace(Ass_Rec, 11, 0, 0, Vm & Vm & Vm & Net_Os)
     Call d3.d3_writestr(database, "RATE.STATS", Key, Ass_Rec)
'
     Return
'
'**********
' S/R 700 - Add to totals
'************************
700  P = 0: Y = 0
     report = Pick.replace(report, 3, 2, 0, CStr(Pick.extractcur(report, 3, 2, 0) + Arr_Preperiod))
     report = Pick.replace(report, 3, 4, 0, CStr(Pick.extractcur(report, 3, 4, 0) + Arr30jun))
     If Levy_Raised_Period + 0 <> 0 Then
        P = 1
        report = Pick.replace(report, 4, 1, 0, Pick.extractcur(report, 4, 1, 0) + 1)
     End If
     report = Pick.replace(report, 4, 2, 0, Pick.extractcur(report, 4, 2, 0) + Levy_Raised_Period)
     If Levy_Raised_Ytd + 0 <> 0 Then
        Y = 1
        report = Pick.replace(report, 4, 3, 0, Pick.extractcur(report, 4, 3, 0) + 1)
     End If
     report = Pick.replace(report, 4, 4, 0, Pick.extractcur(report, 4, 4, 0) + Levy_Raised_Ytd)
     If Int_Raised_Period + 0 <> 0 Then
        P = 1
        report = Pick.replace(report, 5, 1, 0, Pick.extractcur(report, 5, 1, 0) + 1)
     End If
     report = Pick.replace(report, 5, 2, 0, Pick.extractcur(report, 5, 2, 0) + Int_Raised_Period)
     If Int_Raised_Ytd + 0 <> 0 Then
        Y = 1
        report = Pick.replace(report, 5, 3, 0, Pick.extractcur(report, 5, 3, 0) + 1)
     End If
     report = Pick.replace(report, 5, 4, 0, Pick.extractcur(report, 5, 4, 0) + Int_Raised_Ytd)
     If Pen_Raised_Period + 0 <> 0 Then
        P = 1
        report = Pick.replace(report, 6, 1, 0, Pick.extractcur(report, 6, 1, 0) + 1)
     End If
     report = Pick.replace(report, 6, 2, 0, Pick.extractcur(report, 6, 2, 0) + Pen_Raised_Period)
     If Pen_Raised_Ytd + 0 <> 0 Then
        Y = 1
        report = Pick.replace(report, 6, 3, 0, Pick.extractcur(report, 6, 3, 0) + 1)
     End If
     report = Pick.replace(report, 6, 4, 0, Pick.extractcur(report, 6, 4, 0) + Pen_Raised_Ytd)
     If P = 1 Then
        report = Pick.replace(report, 7, 1, 0, Pick.extractcur(report, 7, 1, 0) + 1)
     End If
     report = Pick.replace(report, 7, 2, 0, Pick.extractcur(report, 7, 2, 0) + Period_Raised)
     If Y = 1 Then
        report = Pick.replace(report, 7, 3, 0, Pick.extractcur(report, 7, 3, 0) + 1)
     End If
     report = Pick.replace(report, 7, 4, 0, Pick.extractcur(report, 7, 4, 0) + Ytd_Raised)
     report = Pick.replace(report, 8, 2, 0, Pick.extractcur(report, 8, 2, 0) + Abs(Arrears_Paid_Period))
     report = Pick.replace(report, 8, 4, 0, Pick.extractcur(report, 8, 4, 0) + Abs(Arrears_Paid_Ytd))
     report = Pick.replace(report, 9, 2, 0, Pick.extractcur(report, 9, 2, 0) + Abs(Current_Paid_Period))
     report = Pick.replace(report, 9, 4, 0, Pick.extractcur(report, 9, 4, 0) + Abs(Current_Paid_Ytd))
     report = Pick.replace(report, 10, 2, 0, Pick.extractcur(report, 10, 2, 0) + Period_Paid)
     report = Pick.replace(report, 10, 4, 0, Pick.extractcur(report, 10, 4, 0) + Ytd_Paid)
     report = Pick.replace(report, 11, 4, 0, Pick.extractcur(report, 11, 4, 0) + Net_Os)
     Period_Raised = 0: Ytd_Raised = 0: Period_Paid = 0: Ytd_Paid = 0
     Return
'
'*******************************
' S/R 900 - Write Summary Report
'*******************************
900  Call SR1654_SUM(database, Report_Id, print_ctl)
     Return
'
'*******************************
' S/R 950 - Write Detailed Report
'*******************************
950  Call SR1654_DET(database, Cde, IFDate, ITDate, print_ctl)
     Return
'
End Function


Private Sub Class_Initialize()
ReDim g_trans_info_array(0)
ReDim g_rates(0)
End Sub



Public Function TA1682(logentry As String, Whatif As Integer, FUTURE As Integer, VERS As String, Sent As String, parms As String) As String

Dim temp As String, Gst As Integer, Gst_Accs As String, REBATE_ON_LEVY As Integer, posn As Integer
Dim REMISSION As Integer, Narr_Yr As String
Dim Water As Integer, GST_CHARGED As String, STATE_REBATE As String, Water_Rec As String
Dim Wr_Levy As String, Senior_Perc As Currency, Senior_Max As String, Fire_Levy_Codes As String, No_Cats As Integer
Dim rderr As Integer, gst_rec As String, wx As Integer
'Dim Last_Chng, Lastbit, Categs, Rl_Lc, Item, R_Format
Dim Ii As Integer, Rate_Categs As String, Rates_Rep As String
Dim Dr_Rates As String
Dim Cr_Rates As String, Dr_Rub As String, Cr_Rub As String, Dr_Inv As String, Cr_Inv As String, Tot_Raised As Currency
Dim Tot_Subsidy As String, Max_Ii As Integer, Rtab_Key As String, Rtab_Key_Ct As String, Service_Dates As String
Dim INV_TAB As String, Prec() As String, Client_Rec() As String, Wait As String, Wait_Ct As Integer, Income_Accts As String
Dim Want_Accts As String, Tot_Rebate_Rval As String, TOT_REBATE_AMT As String, Rebate_Amt As String, Dtot_Rebate_Rval As Currency
Dim Total_Disc As Currency, Total_Disc_Rebate As Currency, Redo_Keys As String, Fire_Code As Integer
Dim No_Rates As Integer, Rtx As Integer, RATEVAL As Currency, GSTVAL As Currency, Check_Categ As String, Cindx As Integer, Tr_Date As String
Dim PEN_DATE As String, DISC_DATE As String, RKEY As String, Tr_Reference As String, Tot_Prev As Currency, Mm, Ikey_Prev  As String
Dim Val_Prev As Currency, Narr As String, Gl_Income As String, Remiss_Acct As String, Tr_Desc As String, DISC_PERC As Currency
Dim PEN_PERC As Currency, Apply_Rebate As String, Apply_Remis As String, Rebate_Percs As String, DISC_REBATE_AMT As Currency
Dim Max_Senior As Currency, R_AMT As Currency, R_ACCT As String, Ps_Indx As Integer, REBATE_PERC As Currency, Disc_Amt As Currency
Dim P_Rb, P_Rbe, Used_Code As String, Used_Val As String, Gl_Date As String, Dr_Code As String, Cr_Code As String, Rates_Rec As String
Dim tr_amt As Currency, Tr_Narr As String, Ww As Integer, Rate_Subsidy As Currency, Fire_Subsidy As Currency, Subsidy As Currency
Dim Subsidy_Narr, Tjac As String, Tjjob As String, Tjcost As Currency, Tjcd As String, Tjnarr As String, Remiss_Amt As Currency
Dim Remiss_Narr As String, Ll As Integer, Glac As String, Tjdata(7) As String, PRG As String, Narr1 As String, Prog_Desc, Whos
Dim rcnt As Integer, Gtot As Currency, Total_Gst As Currency, Client_No As String, Cr_Rec As String, Tj_Key As String, Has_Td_Value
Dim Already_Done, Rates_Key As String, Pcode As Integer, MIN_USED As String
Dim total_items As Currency, mylist() As String, Jj As Long, tempcur As Currency
Dim database As String, pick_cnt As Long, ratevals As String, narrs As String
Dim POSS(20, 5) As String, dummy() As String, Found As Integer, PENALTY_DATES As String, DISCOUNT_DATES As String
Dim N_CODES As String, rl_lc As Integer, tj_tno As String, tj_rec As String, debt_cont As String
Dim GST_CODE As String, rx As Integer, Rate_Code As String
Dim tempobj As Object

' Raise rates or do what-if raising of rates
    database = Pick.extract(logentry, 2, 0, 0)
    Rate_Categs = ""
    If Whatif <> 1 Then
        For Ii = 1 To 4
            If Pick.extract(parms, Ii, 0, 0) <> "" Then
                If Rate_Categs = "" Then
                Rate_Categs = Pick.extract(parms, Ii, 0, 0)
            Else
                TA1682 = Chr(8) & "Must only select rate codes from one or other group"
                Exit Function
            End If
        End If
        Next Ii
        If Rate_Categs = "" Then TA1682 = Chr(8) & "Must select some rate codes to rate": Exit Function
        Service_Dates = Pick.extract(parms, 5, 0, 0)
        DISCOUNT_DATES = Pick.extract(parms, 6, 0, 0)
        PENALTY_DATES = Pick.extract(parms, 7, 0, 0)
        GST_CODE = Pick.extract(parms, 8, 0, 0) 'not asked for in Australia

        If UBound(g_rates) = 0 Then
            g_rates(0) = "@RATES"
            Ii = d3.d3_readmat(database, g_rates(), "DICT TRANS.J")
        End If
    Else
        If VERS = 1 Then
            g_rates(0) = "@RATES"
            Ii = d3.d3_readmat(database, g_rates(), "DICT TRANS.J")
        Else
            g_rates(0) = "@RATES." & VERS
            Ii = d3.d3_readmat(database, g_rates(), "DICT RATE.MODEL")
        End If
        For Ii = 1 To 9999
            rx = Ii * 10 - 1
            If rx > UBound(g_rates) Then GoTo 120
            Rate_Code = Pick.extract(g_rates(rx), 1, 2, 0)
            If Rate_Code = "" Then GoTo 120
            If Rate_Categs = "" Then
                Rate_Categs = Ii
            Else
                Rate_Categs = Rate_Categs & Chr(254) & CStr(Ii)
            End If
        Next Ii
120:
        Service_Dates = Pick.ICONV(Format$(Now, "DD MMM YY"), "D2")
    End If
    If UBound(g_trans_info_array) = 0 Then
       g_trans_info_array(0) = "TRANS.INFO"
       posn = d3.d3_readmat(database, g_trans_info_array(), "DICT TRANS.J")
    End If
    If UBound(g_trans_info_array) < 126 Then ReDim Preserve g_trans_info_array(126)
    
     temp = Mid(Pick.extract(g_trans_info_array(49), 1, 0, 0), 12, 1)
     If IsNumeric(temp) Then Gst = CInt(temp) Else Gst = 0
     If Gst = 2 Then
        If d3.d3_readstr(database, Gst_Accs, "GST.CONTROL", "GST_ACCS") <> 0 Then Gst_Accs = "INPUT GST ACC" & Chr(254) & "OUTPUT GST ACC"
     Else
        If Gst = 1 Then
           If d3.d3_readstr(database, gst_rec, "SALETAX", GST_CODE) <> 0 Then gst_rec = ""
        End If
     End If
     temp = Mid(Pick.extract(g_trans_info_array(53), 1, 0, 0), 21, 1)
     If IsNumeric(temp) Then REBATE_ON_LEVY = CInt(temp) Else REBATE_ON_LEVY = 0
     If REBATE_ON_LEVY <> 0 Then TA1682 = Chr(8) & "Do not support REBATE_ON_LEVY": Exit Function
     temp = Mid(Pick.extract(g_trans_info_array(53), 1, 0, 0), 20, 1)
     If IsNumeric(temp) Then REMISSION = CInt(temp) Else REMISSION = 0
'     temp = Mid(pick.extract(g_trans_info_array(53), 1, 0, 0), 2, 1)
'     If IsNumeric(temp) Then Levy_Install = CInt(temp) Else Levy_Install = 0
     Narr_Yr = Pick.extract(g_trans_info_array(59), 1, 1, 0)
'     Max_Levy_Install = pick.extractint(g_trans_info_array(59), 1, 2, 0)
     Water = Pick.extractint(g_trans_info_array(126), 1, 1, 0)

     GST_CHARGED = ""
     If d3.d3_readstr(database, STATE_REBATE, "DICT TRANS.J", "@STATE_REBATE") <> 0 Then STATE_REBATE = ""
     If Pick.extract(STATE_REBATE, 4, 0, 0) = "" Then STATE_REBATE = Pick.replace(STATE_REBATE, 4, 0, 0, "0.5")
'
     If Water Then
        If d3.d3_readstr(database, Water_Rec, "DICT TRANS.J", "@WATER") <> 0 Then Water_Rec = ""
        Wr_Levy = Pick.extract(Water_Rec, 4, 0, 0)
        If Wr_Levy = "" Then Wr_Levy = "WR"
        Senior_Perc = Pick.extractcur(Water_Rec, 9, 4, 0) / 10000
        Senior_Max = Pick.extract(Water_Rec, 9, 3, 0)
     Else
        Wr_Levy = ""
     End If
     If d3.d3_readstr(database, Fire_Levy_Codes, "DICT TRANS.J", "@RATES.Print.CTL", 6) <> 0 Then Fire_Levy_Codes = ""
     
     If Whatif Then
        No_Cats = sr16_catnum(database)
     End If
     If Whatif = 1 Then
        rderr = d3.d3_writestr(database, "DICT PROP.MODEL", "SENT" & VERS, Sent)
     End If
     Rates_Rep = ""
     If Whatif = 0 Then
        Rates_Rep = Rate_Categs
        Rates_Rep = Pick.replace(Rates_Rep, 4, 0, 0, "0") ' STORE PROP COUNT)
        Rates_Rep = Pick.replace(Rates_Rep, 5, 0, 0, "0") ' STORE LEVY)
        Rates_Rep = Pick.replace(Rates_Rep, 6, 0, 0, "0") ' STORE AUS GST)
     End If
'     Make_Adj = pick.extract(inst_tab, 1, 4, 0)
'     Make_Num = pick.extractint(inst_tab, 1, 5, 0)
     Dr_Rates = 73:  Cr_Rates = 48
     Dr_Rub = 77:    Cr_Rub = 22
     Dr_Inv = 50:    Cr_Inv = 25
     Tot_Raised = 0
     Tot_Subsidy = ""
     Max_Ii = Pick.dcount(Pick.extract(Service_Dates, 1, 0, 0), Chr(253))
     For Ii = 1 To Max_Ii
        Rtab_Key = "@RATES" & Pick.extract(Service_Dates, 1, Ii, 0)
        Rtab_Key_Ct = 0
200     ReDim dummy(0)
        dummy(0) = Rtab_Key
        If d3.d3_readmat(database, dummy(), "DICT TRANS.J") <> 0 Then GoTo 210
'       Release TRANS_J_DICT, Rtab_Key
        If UBound(g_rates) <> UBound(dummy) Then GoTo 205
        For Jj = 0 To UBound(g_rates)
           If dummy(Jj) <> g_rates(Jj) Then GoTo 205
        Next Jj
        GoTo 220
205     Rtab_Key_Ct = Rtab_Key_Ct + 1
        Rtab_Key = "@RATES" & Pick.extract(Service_Dates, 1, Ii, 0) & "-" & Rtab_Key_Ct
        GoTo 200
210     If Whatif Then
'           Release TRANS_J_DICT, Rtab_Key
        Else
           rderr = d3.d3_writemat(database, "DICT TRANS.J", g_rates())
        End If
220     Service_Dates = Pick.replace(Service_Dates, 2, Ii, 0, Mid$(Rtab_Key, 7, 99))
     Next Ii
'
   Sent = replace(Sent, Chr(254), """", , , vbBinaryCompare)
   total_items = d3.d3_select(logentry, Sent, mylist(), pick_cnt, 0, 0)
   For Jj = 0 To total_items - 1
1010 INV_TAB = ""
     Client_No = mylist(Jj)
     ReDim Prec(0)
     Prec(0) = Client_No
     If d3.d3_readmat(database, Prec(), "PROPERTY") <> 0 Then GoTo 1000
     If UBound(Prec) < 37 Then ReDim Preserve Prec(37)
     If Prec(32) <> "" Then GoTo 1000
'
     If Whatif And FUTURE Then
        Max_Ii = Pick.dcount(Prec(37), Chr(253))
        For Ii = 1 To Max_Ii
           If Pick.extract(Prec(37), 1, Ii, 0) <> "" Then Prec(19) = Pick.replace(Prec(19), 1, Ii, 0, Pick.extract(Prec(37), 1, Ii, 0))
        Next Ii
        Max_Ii = Pick.dcount(Prec(26), Chr(253))
        For Ii = 1 To Max_Ii
           If Pick.extract(Prec(26), 1, Ii, 0) <> "" Then Prec(15) = Pick.replace(Prec(15), 1, Ii, 0, Pick.extract(Prec(26), 1, Ii, 0))
        Next Ii
     End If
'
     ReDim Client_Rec(0): Client_Rec(0) = Client_No
     If d3.d3_readmat(database, Client_Rec(), "CLIENT") <> 0 Then
     End If
     ReDim Preserve Client_Rec(16)

     If Whatif Then
        If d3.d3_readstr(database, Cr_Rec, "TDEBTOR", Client_No) <> 0 Then GoTo 1000
     Else
        If d3.d3_readstr(database, Cr_Rec, "TDEBTOR", Client_No) <> 0 Then
           'Release TDEBTOR_DATA, Client_No
           GoTo 1000
        End If
        Wait = "": Wait_Ct = 0
     End If
' Do not need $INSERT as unlikely overflow will be written to or
' created in SR310.  Hence performance increase.
     Income_Accts = 0
     Want_Accts = FUTURE
     If REMISSION Then Want_Accts = Pick.replace(Want_Accts, 1, 5, 0, 2)
     Call sr1690(database, Client_Rec(), Prec(), ratevals, Pcode, Want_Accts, narrs, Income_Accts, MIN_USED, GST_CHARGED)
     Tot_Rebate_Rval = "":  TOT_REBATE_AMT = "":  Rebate_Amt = ""
     Dtot_Rebate_Rval = 0: Total_Disc = 0:  Total_Disc_Rebate = 0
     Redo_Keys = "":  Fire_Code = 0
'
'***** Valuation Charges ******
'
     No_Rates = Pick.dcount(ratevals, Chr(254))
     For Rtx = 1 To No_Rates
        RATEVAL = Pick.extractcur(ratevals, Rtx, 0, 0)
        If Gst = 2 Then
           GSTVAL = Pick.extractcur(GST_CHARGED, Rtx, 0, 0)
        Else
           GSTVAL = 0
        End If
        If RATEVAL = 0 Then GoTo 1090
        Check_Categ = Pick.extract(Prec(29), 1, Rtx, 0)
        If Pick.locate(Check_Categ, Rate_Categs, 1, 1, 0, Found, "") = 0 Then GoTo 1090
        Cindx = (Check_Categ - 1) * 10
        Rates_Rep = Pick.replace(Rates_Rep, 4, Found, 0, CStr(Pick.extractint(Rates_Rep, 4, Found, 0) + 1))
        Max_Ii = Pick.dcount(Pick.extract(Service_Dates, 1, 0, 0), Chr(253))
        For Ii = 1 To Max_Ii
           Tr_Date = Pick.extract(Service_Dates, 1, Ii, 0)
           PEN_DATE = Pick.extract(PENALTY_DATES, 1, Ii, 0)
           DISC_DATE = Pick.extract(DISCOUNT_DATES, 1, Ii, 0)
           RKEY = Pick.extract(Service_Dates, 2, Ii, 0)
           Tr_Reference = Pick.extract(g_rates(Cindx + 9), 1, 2, 0)
'           If Levy_Install = 1 Then
'              Rateval = Int(pick.extractcur(ratevals, Rtx, 0, 0) / Max_Levy_Install + 0.5)
'              If Make_Adj = "Y" Then
'                 Tot_Prev = 0
'                 For Mm = 1 To Make_Num
'                    Ikey_Prev = Tr_Reference & Narr_Yr & "-" & Mm & "*" & Client_No
'                    If d3.d3_readstr(database, temp, "INVOICE", Ikey_Prev, 8) <> 0 Then temp = "0"
'                    If IsNumeric(temp) Then Val_Prev = CCur(temp) Else Val_Prev = 0
'                    Tot_Prev = Tot_Prev + Rateval - Val_Prev
'                 Next Mm
'                 Rateval = Rateval + Int(Tot_Prev / (Max_Levy_Install - Make_Num) + 0.5)
'              End If
'           End If
           Narr = Pick.extract(narrs, Rtx, 0, 0)
           Gl_Income = Pick.extract(Income_Accts, Rtx, 1, 0)
           Remiss_Acct = Pick.extract(Income_Accts, Rtx, 5, 0)
           Tr_Desc = Pick.extract(g_rates(Cindx + 9), 1, 1, 1)
           DISC_PERC = Pick.extractcur(g_rates(Cindx + 9), 1, 3, 0)
           PEN_PERC = Pick.extractcur(g_rates(Cindx + 9), 1, 4, 0)
           Apply_Rebate = Pick.extract(g_rates(Cindx + 9), 1, 6, 1)
           Apply_Remis = Pick.extract(g_rates(Cindx + 9), 1, 7, 1)
'
           Rebate_Percs = "":  Rebate_Amt = ""
           DISC_REBATE_AMT = 0:  Max_Senior = 0
           R_AMT = RATEVAL:  R_ACCT = Gl_Income:  Fire_Code = 0
'
'
           If Pcode And Apply_Rebate = "Y" Then
              Ps_Indx = 1
1020          REBATE_PERC = Pick.extractcur(STATE_REBATE, 4, Ps_Indx, 0) * Pcode
              Rebate_Percs = Pick.replace(Rebate_Percs, 1, Ps_Indx, 0, CStr(REBATE_PERC))
              Rebate_Amt = Pick.replace(Rebate_Amt, 1, Ps_Indx, 0, CStr(RATEVAL * Pick.extractcur(STATE_REBATE, 4, Ps_Indx, 0) * Pcode))
              If Fire_Levy_Codes <> "" Then     ' for fire levies only
                 If Pick.locate(Tr_Reference, Fire_Levy_Codes, 1, 1, 0, Fire_Code, "") = 0 Then Fire_Code = 0
              Else
                 Fire_Code = 0
              End If
'
' for other than fire levy, must correct rebate amount for possible
' rounding error (i.e. when more than one rate charge applicable)
              If Fire_Code = 0 Then
                 Tot_Rebate_Rval = Pick.replace(Tot_Rebate_Rval, 1, Ps_Indx, 0, Pick.extractcur(Tot_Rebate_Rval, 1, Ps_Indx, 0) + RATEVAL)
                 Rebate_Amt = Pick.replace(Rebate_Amt, 1, Ps_Indx, 0, Int(Pick.extractcur(Rebate_Amt, 1, Ps_Indx, 0) + 0.5))
                 TOT_REBATE_AMT = Pick.replace(TOT_REBATE_AMT, 1, Ps_Indx, 0, Pick.extractcur(TOT_REBATE_AMT, 1, Ps_Indx, 0) + Pick.extractcur(Rebate_Amt, 1, Ps_Indx, 0))
              Else
                 Rebate_Amt = Pick.replace(Rebate_Amt, 1, Ps_Indx, 0, Int(Pick.extractcur(Rebate_Amt, 1, Ps_Indx, 0) + 0.5))
              End If
' rebate on discounted levy ------
              If REBATE_ON_LEVY = 0 Then
                 If DISC_PERC + 0 <> 0 And DISC_DATE <> "" Then
                    Disc_Amt = Pick.ICONV(RATEVAL * DISC_PERC / 100, "MD00")
                    Total_Disc = Total_Disc + Disc_Amt
                    DISC_REBATE_AMT = (RATEVAL - Disc_Amt) * REBATE_PERC
                    Total_Disc_Rebate = Total_Disc_Rebate + DISC_REBATE_AMT
                    If Fire_Code = 0 Then
                       Dtot_Rebate_Rval = Dtot_Rebate_Rval + RATEVAL
                       P_Rb = (Dtot_Rebate_Rval - Total_Disc) * REBATE_PERC
                       P_Rbe = P_Rb - Total_Disc_Rebate   ' progressive rebate rounding error
                       If P_Rbe Then DISC_REBATE_AMT = DISC_REBATE_AMT + P_Rbe
                       DISC_REBATE_AMT = Int(DISC_REBATE_AMT + 0.5)
                    End If
                 Else
                    DISC_REBATE_AMT = Pick.extractcur(Rebate_Amt, 1, Ps_Indx, 0)
                 End If
              Else
                 R_AMT = R_AMT - Pick.extractcur(Rebate_Amt, 1, Ps_Indx, 0)
                 DISC_REBATE_AMT = 0
              End If
              Ps_Indx = Ps_Indx + 1
              If REMISSION And Ps_Indx <= 2 And Apply_Remis = "Y" Then GoTo 1020
              Max_Senior = 0
           Else
              If Client_Rec(16) <> "" And Water And Tr_Reference = Wr_Levy Then
                 Rebate_Percs = Senior_Perc
                 Max_Senior = Senior_Max
                 If IsNumeric(Rebate_Percs) Then tempcur = CCur(Rebate_Percs) Else tempcur = 0
                 Rebate_Amt = Int(RATEVAL * tempcur + 0.5)
                 DISC_REBATE_AMT = Int(RATEVAL * (100 - DISC_PERC) / 100 * tempcur + 0.5)
                 If Max_Senior <> 0 And Rebate_Amt > Max_Senior Then
                    Rebate_Amt = Max_Senior
                    DISC_REBATE_AMT = Int(Rebate_Amt * (100 - DISC_PERC) / 100 + 0.5)
                 End If
              End If
           End If
'
           Used_Code = Pick.extract(Prec(19), 1, Rtx, 0)
           Used_Val = Pick.extract(Prec(15), 1, Rtx, 0) & Chr(253) & Pick.extract(MIN_USED, Rtx, 3, 0) & Chr(253) & Pick.extract(MIN_USED, Rtx, 4, 0) & Chr(253) & Pick.extract(MIN_USED, Rtx, 7, 0)
           GoSub 4000      ' generate reference and rates record
           If Already_Done Then GoTo 1080
'
           Tot_Raised = Tot_Raised + RATEVAL
           Rates_Rep = Pick.replace(Rates_Rep, 5, Found, 0, CStr(Pick.extractcur(Rates_Rep, 5, Found, 0) + RATEVAL))
           If Gst = 2 Then
              Rates_Rep = Pick.replace(Rates_Rep, 6, Found, 0, CStr(Pick.extractcur(Rates_Rep, 6, Found, 0) + GSTVAL))
           End If
           Gl_Date = Tr_Date
           If Whatif Then
              INV_TAB = Pick.replace(INV_TAB, 3, Rtx, 0, CStr(Pick.extractcur(INV_TAB, 3, Rtx, 0) + RATEVAL))
           Else
              If REBATE_ON_LEVY And Pcode Then
                 Wait_Ct = Wait_Ct + 1
                 Wait = Pick.replace(Wait, 1, Wait_Ct, 0, Gl_Date)
                 Wait = Pick.replace(Wait, 2, Wait_Ct, 0, Tr_Reference)
                 Wait = Pick.replace(Wait, 3, Wait_Ct, 0, Tr_Date)
                 Wait = Pick.replace(Wait, 4, Wait_Ct, 0, Pick.extract(Rates_Rec, 2, 0, 0))
                 Wait = Pick.replace(Wait, 5, Wait_Ct, 0, Narr)
                 Wait = Pick.replace(Wait, 6, Wait_Ct, 0, Gl_Income)
                 Wait = Pick.replace(Wait, 7, Wait_Ct, 0, Tr_Desc)
                 If Fire_Code = 0 Then wx = 1 Else wx = 2
                 Wait = Pick.replace(Wait, 8, Wait_Ct, wx, Pick.extract(Rebate_Amt, 1, 1, 0)) ' subsidy)
                 Wait = Pick.replace(Wait, 9, Wait_Ct, 0, Pick.extract(Rebate_Amt, 1, 2, 0)) ' remission)
                 Wait = Pick.replace(Wait, 10, Wait_Ct, 0, Remiss_Acct)
              Else
                 Dr_Code = Dr_Rates:  Cr_Code = Cr_Rates
                 tr_amt = RATEVAL:  Tr_Narr = Narr
                 If Gst = 2 Then
                    tr_amt = tr_amt + GSTVAL
                 End If
                 GoSub 3000
              End If
           End If
1080    Next Ii
1090 Next Rtx
'
' charging complete, finalise debtor postings
'
1200 If Whatif Then
        N_CODES = ""
        N_CODES = Pick.replace(N_CODES, 1, 1, 0, 19)
        N_CODES = Pick.replace(N_CODES, 1, 2, 0, 8)
        N_CODES = Pick.replace(N_CODES, 1, 3, 0, 9)
        N_CODES = Pick.replace(N_CODES, 1, 4, 0, 38)
        Call SR1682A_M(database, Gst, 5, VERS, FUTURE, Prec(), INV_TAB, MIN_USED, N_CODES, POSS(), Client_No, GST_CHARGED)
     Else
       If REBATE_ON_LEVY And Pcode Then
          '???Call SR1682_REB(STATE_REBATE, TOT_REBATE_AMT, Redo_Keys, REMISSION, Wait)
          For Ww = 1 To Wait_Ct
             Dr_Code = Dr_Rates:  Cr_Code = Cr_Rates
             tr_amt = Pick.extractcur(Wait, 4, Ww, 0): Tr_Narr = Pick.extract(Wait, 5, Ww, 0)
             Gl_Date = Pick.extract(Wait, 1, Ww, 0): Tr_Reference = Pick.extract(Wait, 2, Ww, 0)
             Tr_Date = Pick.extract(Wait, 3, Ww, 0): Gl_Income = Pick.extract(Wait, 6, Ww, 0)
             Tr_Desc = Pick.extract(Wait, 7, Ww, 0)
             GoSub 3000
'
             Rate_Subsidy = Pick.extract(Wait, 8, Ww, 1): Fire_Subsidy = Pick.extract(Wait, 8, Ww, 2)
             If Rate_Subsidy Or Fire_Subsidy Then
                Subsidy = Rate_Subsidy + Fire_Subsidy
' n.b. opposite side of subsidy posting processed at end of levy run
                Subsidy_Narr = "STATE SUBSIDY"
                Tjac = Gl_Income:  Tjjob = 0:  Tjcost = Subsidy
                Tjcd = Cr_Rates:  Tjnarr = Subsidy_Narr
                GoSub 1300
                Tot_Subsidy = Pick.replace(Tot_Subsidy, 1, 1, 0, Pick.extract(Tot_Subsidy, 1, 1, 0) + Rate_Subsidy)
                Tot_Subsidy = Pick.replace(Tot_Subsidy, 1, 2, 0, Pick.extract(Tot_Subsidy, 1, 2, 0) + Fire_Subsidy)
             End If
             Remiss_Amt = Pick.extract(Wait, 9, Ww, 0)
             If Remiss_Amt Then
                Remiss_Narr = "COUNCIL REMISSION - " & Pick.extract(Wait, 7, Ww, 0)
                Tjac = Pick.extract(Wait, 10, Ww, 0): Tjjob = 0: Tjcd = Dr_Rates
                Tjcost = Remiss_Amt:  Tjnarr = Remiss_Narr
                GoSub 1300
                Tjac = Gl_Income:  Tjjob = 0:  Tjcd = Cr_Rates
                Tjcost = Remiss_Amt:  Tjnarr = Remiss_Narr
                GoSub 1300
             End If
          Next Ww
       End If
       rderr = d3.d3_writestr(database, "TDEBTOR", Client_No, Cr_Rec)
     End If
'$INSERT I.QU
1000:
   Next Jj
   GoSub 2000
   Exit Function
'
' s/r 1300: set up TRANS.J item for posting
'
1300 If Tjcost = 0 Then Return
     For Ll = 1 To 9999
        Glac = Pick.extract(Tjdata(3), 1, Ll, 0)
        If Glac = "" Then GoTo 1320
        If Glac = Tjac Then
           If Pick.extract(Tjdata(1), 1, Ll, 0) = Tjcd And Pick.extract(Tjdata(6), 1, Ll, 0) = Tjnarr And Pick.extract(Tjdata(2), 1, Ll, 0) = Tjjob Then
              Tjdata(4) = Pick.replace(Tjdata(4), 1, Ll, 0, CStr(Pick.extractcur(Tjdata(4), 1, Ll, 0) + Tjcost))
              GoTo 1390
           End If
        End If
     Next Ll
1320 Tjdata(3) = Pick.insert(Tjdata(3), 1, -1, 0, Tjac)
     Tjdata(6) = Pick.insert(Tjdata(6), 1, -1, 0, Tjnarr)
     Tjdata(2) = Pick.insert(Tjdata(2), 1, -1, 0, Tjjob)
     Tjdata(1) = Pick.insert(Tjdata(1), 1, -1, 0, Tjcd)
     Tjdata(4) = Pick.insert(Tjdata(4), 1, -1, 0, CStr(Tjcost))
1390 Return
'
' s/r 2000: Routine to write TRANS.J entry for entire opening balances
'          and post total subsidy to sundry debtor, if applicable
'
2000 If Whatif Then
        Call SR1682A_S(database, 2, 4, POSS(), No_Cats, FUTURE, "", 5, VERS, "1680")
        Return
     End If
     PRG = "1682*1"
     Narr1 = "Raising rates" & Chr(254) & Chr(254) & Chr(254) & Chr(254) & Rate_Categs & Chr(254) & Pick.extract(g_trans_info_array(59), 1, 1, 0) & Chr(254) & Pick.extract(Service_Dates, 1, 0, 0) & Chr(254) & DISCOUNT_DATES & Chr(254) & PENALTY_DATES & Chr(254) & Sent & Chr(254) & Rates_Rep
     Call SR1600RL(logentry, PRG, Narr1)
'     temp = "Summary of Charges Levied_"
'     Rcnt = pick.DCount(pick.extract(Rates_Rep, 1, 0, 0), Chr(253))
'     temp = temp & Chr(254) & " Charging Code Description Number of Total Levied"
'     If gst = 2 Then
'        temp = temp & " GST"
'     End If
'     temp = temp & " Properties"
'     Gtot = 0
'     Total_Gst = 0
'     For Ii = 1 To Rcnt
'        'Printer.Print " "; Left(pick.extract(Rates_Rep, 1, Ii, 0) & Space(19), 19); Left(pick.extract(Rates_Rep, 2, Ii, 0) & Space(22), 22); Right(Space(10) & pick.extract(Rates_Rep, 4, Ii, 0), 10); " "; Right(Space(12) & pick.oconv(pick.extract(Rates_Rep, 5, Ii, 0), "MD2"), 12);
'        If gst = 2 Then
'           Printer.Print " "; Right(Space(10) & pick.oconv(pick.extract(Rates_Rep, 6, Ii, 0), "MD2"), 10)
'           Total_Gst = Total_Gst + pick.extractcur(Rates_Rep, 6, Ii, 0)
'        End If
'        Gtot = Gtot + pick.extractcur(Rates_Rep, 5, Ii, 0)
'     Next Ii
'        Printer.Print " TOTAL"; Right(Space(64) & pick.oconv(Gtot, "MD2"), 64)
'        If gst = 2 Then
'           Printer.Print " "; Right(Space(10) & pick.oconv(Total_Gst, "MD2"), 10)
'        End If
     TA1682 = Rates_Rep
     
     Tr_Date = Pick.extract(Service_Dates, 1, 1, 0)
     If REBATE_ON_LEVY Then
        Rate_Subsidy = Pick.extract(Tot_Subsidy, 1, 1, 0)
        If Rate_Subsidy Then
           Client_No = Pick.extract(STATE_REBATE, 3, 0, 0)
           If d3.d3_readstr(database, Cr_Rec, "TDEBTOR", Client_No) <> 0 Then Cr_Rec = ""
           Dr_Code = Dr_Rates:  Cr_Code = Cr_Rates
           Gl_Date = Tr_Date:  tr_amt = Rate_Subsidy
           Tr_Reference = Pick.extract(g_rates(9), 1, 2, 0) & Narr_Yr
           Tr_Narr = "STATE SUBSIDY":  Tr_Desc = Tr_Narr
           Gl_Income = ""       ' GL income posting already done
           GoSub 3000
           rderr = d3.d3_writestr(database, "TDEBTOR", Client_No, Cr_Rec)
        End If
        Fire_Subsidy = Pick.extract(Tot_Subsidy, 1, 2, 0)
        If Fire_Subsidy Then
           Tjac = Pick.extract(STATE_REBATE, 5, 0, 0): Tjjob = 0: Tjcd = Dr_Rates
           Tjcost = Fire_Subsidy: Tjnarr = "STATE SUBSIDY"
           GoSub 1300
        End If
     End If
     If Tjdata(1) = "" Then Return
     Tjdata(7) = Tr_Date
     temp = d3.execute_tcl(logentry, "WHO", "")
     tj_tno = Right("000" & Pick.field(temp, " ", 1), 3)
2500 Tj_Key = Pick.field(CStr(Timer), ".", 1) & tj_tno
     If d3.d3_readstr(database, tj_rec, "TRANS.J", Tj_Key) <> 0 Then GoTo 2600
'     Release TRANS_J_DATA, Tj_Key
     GoTo 2500
2600 Tjdata(0) = Tj_Key
     rderr = d3.d3_writemat(database, "TRANS.J", Tjdata())
'     Has_Td_Value = 1
'     OPEN "","TD_VALUE" TO TD_VALUE_DATA ELSE HAS_TD_VALUE = 0
'     If Has_Td_Value Then
'        CLEARFILE TD_VALUE_DATA
'     End If
     Return
'
'
' s/r 3000:   update rates debtor account
'
3000 Set tempobj = CreateObject("cka_ta31.ta31")
     Call tempobj.SR310(database, Gl_Date, Client_No, Cr_Rec, Tr_Reference, CInt(Tr_Date), CStr(tr_amt), Dr_Code, Tr_Narr, 0, "", debt_cont, "", g_trans_info_array(14))
     Set tempobj = Nothing
     Tjac = debt_cont:  Tjjob = 0:  Tjcd = Dr_Code
     Tjcost = tr_amt:  Tjnarr = Tr_Desc
     GoSub 1300
     If Gl_Income <> "" Then
        Select Case Gst
        Case 1
           Tjac = Gl_Income:  Tjjob = 0:  Tjcd = Cr_Code
           Tjcost = Pick.extract(Rates_Rec, 2, 0, 0) - Pick.extract(Rates_Rec, 9, 2, 0)
           Tjnarr = Tr_Desc
           GoSub 1300
           Tjac = Pick.extract(gst_rec, 3, 0, 0):  Tjjob = 0:  Tjcd = Cr_Code
           Tjcost = Pick.extract(Rates_Rec, 9, 2, 0): Tjnarr = Tr_Desc
           GoSub 1300
        Case 2
           Tjac = Gl_Income: Tjjob = 0: Tjcd = Cr_Code
           Tjcost = Pick.extract(Rates_Rec, 2, 0, 0) - Pick.extract(Rates_Rec, 9, 2, 0)
           Tjnarr = Tr_Desc
           GoSub 1300
           Tjac = Pick.extract(Gst_Accs, 2, 1, 0): Tjjob = 0: Tjcd = Cr_Code
           Tjcost = Pick.extract(Rates_Rec, 9, 2, 0): Tjnarr = Tr_Desc
           GoSub 1300
        Case Else
           Tjac = Gl_Income:  Tjjob = 0:  Tjcd = Cr_Code
           Tjcost = tr_amt:  Tjnarr = Tr_Desc
           GoSub 1300
        End Select
     End If
     Return
'
'
' s/r 4000: Generate rates reference and INVOICE record
'
4000 Already_Done = 0
     If Whatif Then
        INV_TAB = Pick.replace(INV_TAB, 1, Rtx, 0, CStr(DISC_PERC))
        INV_TAB = Pick.replace(INV_TAB, 2, Rtx, 1, Pick.extract(INV_TAB, 2, Rtx, 1) + Pick.extract(Rebate_Amt, 1, 1, 0))
        INV_TAB = Pick.replace(INV_TAB, 2, Rtx, 2, Pick.extract(INV_TAB, 2, Rtx, 2) + Pick.extract(Rebate_Amt, 1, 2, 0))
        Return
     End If
     Tr_Reference = Tr_Reference & Narr_Yr
'     If Levy_Install Then Tr_Reference = Tr_Reference & "-" & ii
     Call SR1682(Rates_Rec, Client_No, CStr(R_AMT), R_ACCT, Narr, Gst, Pick.extractcur(gst_rec, 2, 0, 0), GST_CODE, Tr_Date, Used_Code, Used_Val, RKEY, DISC_PERC, DISC_DATE, PEN_PERC, PEN_DATE, Rebate_Percs, Rebate_Amt, REBATE_ON_LEVY, DISC_REBATE_AMT & Chr(253) & Max_Senior, Pcode, GSTVAL)

     Rates_Key = Tr_Reference & "*" & Client_No
4120 If d3.d3_readstr(database, temp, "RATES", Rates_Key) <> 0 Then GoTo 4150
'     Release RATES_DATA, Rates_Key
     Already_Done = 1
     Return
4150:
'$INSERT I.LOG.ADD '|RATES|':RATES.KEY 4120

     rderr = d3.d3_writestr(database, "RATES", Rates_Key, Rates_Rec)
     If REBATE_ON_LEVY And Pcode And Fire_Code = 0 Then
        Redo_Keys = Pick.insert(Redo_Keys, -1, 0, 0, Rates_Key & Chr(253) & Rebate_Amt)
     End If
     Return

End Function


Public Function sr16_catnum(database As String) As Integer

' Return number of rates categories

Dim num_attr As Integer, No_Cats As Integer

     If UBound(g_rates) = 0 Then
        g_rates(0) = "@RATES"
        num_attr = d3.d3_readmat(database, g_rates(), "DICT TRANS.J")
     End If

     For No_Cats = 2 To 999
        num_attr = (No_Cats * 10) - 9
        If UBound(g_rates) < num_attr + 8 Then No_Cats = No_Cats - 1: Exit For
        If g_rates(num_attr + 8) = "" Then No_Cats = No_Cats - 1: Exit For
     Next No_Cats
     sr16_catnum = No_Cats
     
End Function

Public Sub sr1690(database As String, Client_Rec() As String, Prec() As String, RATEVAL As String, Pcode As Integer, Ufuture As String, Narr As String, rates_levied As String, MIN_USED As String, GST_CHARGED As String)

' If UFUTURE<1,3> = 1, then being called for discount acct (TA1656)
' If UFUTURE<1,4> = 1, then being called for penalty acct (TA1659)
' If UFUTURE<1,5> = 1, then being called for rebate acct (TA1654)

' If any of above flags are set = 2, then RATES.LEVIED will be
' multi-valued per rate category passing back GL accounts in
' corresponding m/v of each category (attr) within RATES.LEVIED
' (applies to Rate levy (SR1682A) in particular)

' For Non-Multi rate systems, MIN.USED serves a dual purpose.
' Return rate value in RATEVAL

Dim nz_install As String, temp As String
Dim No_Rates As Integer, Ii As Integer
Dim typ As String, units As String, subcode As String, uattr As String
Dim Attr As Integer, posn As Integer, Pos As Integer
Dim rate As String, MODEL As Integer, nrr As String
Dim min_levied As String, max_levied As String
Dim Rate_In As String, orig_levied As String, rlev As String
Dim minrate As Currency, maxrate As Currency, rv As String
Dim rval As Currency, lrval As Integer, zeroes As String
Dim gst_oz_rate As Currency, Gst As String, gst_ind As String
Dim FUTURE As Integer, wantdisc As Integer, wantpenalty As Integer, wantrebate As Integer
     If UBound(g_trans_info_array) = 0 Then
        g_trans_info_array(0) = "TRANS.INFO"
        Ii = d3.d3_readmat(database, g_trans_info_array(), "DICT TRANS.J")
     End If
            
     nz_install = Mid(g_trans_info_array(53), 6, 1)
     Gst = Mid(g_trans_info_array(49), 12, 1)
     If Gst = "2" Then
        If d3.d3_readstr(database, temp, "GST.CONTROL", "GST.RATE", 1) <> 0 Then temp = "1000"
        If IsNumeric(temp) Then gst_oz_rate = CCur(temp) Else gst_oz_rate = 1000
     End If
'     max_lEVY = TRANS.INFO<59,2>
     FUTURE = Pick.extractint(Ufuture, 1, 1, 0)
     MODEL = Pick.extractint(Ufuture, 1, 2, 0)
     wantdisc = Pick.extractint(Ufuture, 1, 3, 0)
     wantpenalty = Pick.extractint(Ufuture, 1, 4, 0)
     wantrebate = Pick.extractint(Ufuture, 1, 5, 0)
'     orig_levied = rates.LEVIED
     MIN_USED = ""
     RATEVAL = ""
'     RATES.LEVIED = 'RATESACCT'
'      NARR = ''
     Pcode = 0
     If Not (MODEL) Then
        If UBound(Client_Rec) > 43 Then
           If IsNumeric(Client_Rec(44)) Then Pcode = CInt(Client_Rec(44)) Else Pcode = 0
        End If
     End If

     No_Rates = Pick.dcount(Prec(29), Chr(253))
     For Ii = 1 To No_Rates                '* valuation charges
        typ = Pick.extract(Prec(19), 1, Ii, 0)
        If typ = "" Then GoTo sr1690_190
        Call sr16_units(typ, units, subcode)
        If units = "" Then units = "0"
        uattr = Pick.extract(Prec(29), 1, Ii, 0)
        If uattr = "" Or Not IsNumeric(uattr) Then uattr = CStr(Ii)
        Attr = (CInt(uattr) * 10) - 9
        If Attr > UBound(g_rates) Then GoTo sr1690_190
        posn = Pick.locate(subcode, g_rates(Attr), 1, 1, 0, Pos, "")
        If posn = 0 Then GoTo sr1690_190
        MIN_USED = Pick.replace(MIN_USED, Ii, 2, 0, Pick.extract(g_rates(Attr + 3), 1, Pos, 0))
        If wantdisc Then
           rlev = Pick.extract(g_rates(Attr + 6), 1, Pos, 2)
           If wantdisc = 1 Then GoTo 180
           If MODEL = 0 Then rates_levied = Pick.replace(rates_levied, Ii, 3, 0, rlev)
        End If
        If wantpenalty Then
           rlev = Pick.extract(g_rates(Attr + 6), 1, Pos, 3)
           If wantpenalty = 1 Then GoTo 180
           If MODEL = 0 Then rates_levied = Pick.replace(rates_levied, Ii, 4, 0, rlev)
        End If
        If wantrebate Then
           rlev = Pick.extract(g_rates(Attr + 6), 1, Pos, 4)
           If wantrebate = 1 Then GoTo 180
           If MODEL = 0 Then rates_levied = Pick.replace(rates_levied, Ii, 5, 0, rlev)
        End If

        rate = Pick.extract(Prec(15), 1, Ii, 0)
        If FUTURE Then
           If Pick.extract(Prec(26), 1, Ii, 0) <> "" Then rate = Pick.extract(Prec(26), 1, Ii, 0)
        End If

        Rate_In = Pick.extract(g_rates(Attr + 1), 1, Pos, 1)
        MIN_USED = Pick.replace(MIN_USED, Ii, 3, 0, Rate_In)
        If MODEL = 0 Then
           nrr = Pick.extract(g_rates(Attr + 2), 1, Pos, 0)
           If Right(nrr, 1) <> " " Then nrr = nrr & " "
           Narr = Pick.replace(Narr, Ii, 0, 0, nrr & rate)
           min_levied = Pick.extract(g_rates(Attr + 6), 1, Pos, 1)
           max_levied = Pick.extract(g_rates(Attr + 6), 1, Pos, 5)
           If orig_levied = "1" Then rlev = Pick.extract(g_rates(Attr + 5), 1, Pos, 0) Else rlev = Pick.extract(g_rates(Attr + 4), 1, Pos, 1)
           If min_levied = "" Or orig_levied = "1" Then min_levied = rlev
        End If
        temp = Pick.extract(g_rates(Attr + 9), 1, Pos, 1)
        If temp = "" Then minrate = 0 Else minrate = CCur(temp) * 100
        MIN_USED = Pick.replace(MIN_USED, Ii, 4, 0, CStr(minrate))
        temp = Pick.extract(g_rates(Attr + 9), 1, Pos, 2)
        If temp = "" Then maxrate = 0 Else maxrate = CCur(temp) * 100
        MIN_USED = Pick.replace(MIN_USED, Ii, 7, 0, CStr(maxrate))
' provide alternative narrative for unit type charges
'        IF NOT(RATE_IN) AND NOT(RATE) AND MINRATE THEN
'           NARR<II> = 'Levied at ':OCONV(MINRATE,'MD2$'):' per unit on ':UNITS:' unit'
'           IF UNITS > 1 THEN NARR<II> = NARR<II>:'s'
'        End
        rv = Pick.field(Rate_In, ".", 2)
        If Len(rv) < 5 Then
           If Not IsNumeric(Rate_In) Or Not IsNumeric(rate) Then rval = 0 Else rval = CCur(Rate_In) * CCur(rate)
        Else
           lrval = Len(rv) - 4
           zeroes = String$(lrval, "0")
           rval = CStr(CCur(Pick.field(Rate_In, ".", 1) & zeroes) + CCur(Left(rv, lrval) & "." & Mid(rv, lrval + 1, 4)))
           rval = CStr(CCur(rval) * CCur(rate) / CCur((1 & zeroes)))
        End If
        rval = Int(rval + 0.5)
'        If rval < minrate And (rval <> 0) Then
         If rval < minrate Then
           rval = minrate
           If MODEL = 0 Then rlev = min_levied
           MIN_USED = Pick.replace(MIN_USED, Ii, 1, 0, "1")
        End If
        If maxrate And rval > maxrate Then
           rval = maxrate
           If MODEL = 0 Then rlev = max_levied 'mc 16sep00
           MIN_USED = Pick.replace(MIN_USED, Ii, 6, 0, "1")
        End If
        RATEVAL = Pick.replace(RATEVAL, Ii, 0, 0, CStr(CCur(rval) * CCur(units)))
        If nz_install = "1" Then
'           RATEVAL<II> = INT(RATEVAL<II> / (max_lEVY*5)+.5) * (max_lEVY*5)
        End If
180:
        If MODEL = 0 Then rates_levied = Pick.replace(rates_levied, Ii, 1, 0, rlev)
        If Gst = 2 Then
           gst_ind = Pick.extract(g_rates(Attr + 8), 1, 10, 0)
           If gst_ind = "Y" Then
              GST_CHARGED = Pick.replace(GST_CHARGED, Ii, 0, 0, Int((Pick.extractcur(RATEVAL, Ii, 0, 0) * gst_oz_rate) / 10000))
           End If
        End If
sr1690_190:
     Next Ii

End Sub

Public Sub SR1682A_M(database As String, Gst As Integer, nn As Integer, VERS As String, FUTURE As Integer, PROP_REC() As String, INV_TAB As String, MIN_USED As String, N_CODES As String, POSS() As String, Client_No As String, GST_CHARGED As String)

Dim Mrec As String, Adj As Integer, tempint As Integer, Max_Pp As Integer, Pp As Integer, Rcat As Integer
Dim value As Currency, rderr As Integer, Levyval As Currency, Rt_Code As String
Dim rate_catg As Integer, RATEVAL As Currency, catg As String, GSTVAL As Currency
'
'  create prop.model record.
'
     If d3.d3_readstr(database, Mrec, "PROP.MODEL", Client_No) <> 0 Then Mrec = ""
     If IsNumeric(VERS) Then tempint = CInt(VERS) Else tempint = 0
     Adj = (tempint - 1) * 20 + FUTURE * 10
     Max_Pp = Pick.dcount(PROP_REC(29), Chr(253))
     For Pp = 1 To Max_Pp
        Rcat = Pick.extractint(PROP_REC(29), 1, Pp, 0)
        If Rcat = 0 Then GoTo 90
        Mrec = Pick.replace(Mrec, Adj + 1, Rcat, 0, CStr(Rcat))
        Mrec = Pick.replace(Mrec, Adj + 2, Rcat, 0, Pick.extract(PROP_REC(19), 1, Pp, 0))
        value = Pick.extractcur(PROP_REC(15), 1, Pp, 0)
        If FUTURE Then
           If IsNumeric(Pick.extract(PROP_REC(26), 1, Pp, 0)) Then value = Pick.extractcur(PROP_REC(26), 1, Pp, 0)
        End If
        Mrec = Pick.replace(Mrec, Adj + 3, Rcat, 0, CStr(value))
        Levyval = Pick.extractcur(INV_TAB, 3, Pp, 0)
        Mrec = Pick.replace(Mrec, Adj + 4, Rcat, 0, CStr(Levyval))
        Mrec = Pick.replace(Mrec, Adj + 5, Rcat, 0, CStr(Int(Levyval * Pick.extractcur(INV_TAB, 1, Pp, 0) / 100 + 0.5))) 'discount)
        Mrec = Pick.replace(Mrec, Adj + 6, Rcat, 0, Pick.extract(INV_TAB, 2, Pp, 1)) ' rebate)
        Mrec = Pick.replace(Mrec, Adj + 7, Rcat, 0, Pick.extract(INV_TAB, 2, Pp, 2)) ' remission (if given))
        Mrec = Pick.replace(Mrec, Adj + 8, Rcat, 0, Pick.extract(MIN_USED, Rcat, 1, 0))
90   Next Pp
     rderr = d3.d3_writestr(database, "PROP.MODEL", Client_No, Mrec)
'
     Max_Pp = Pick.dcount(PROP_REC(19), Chr(253))
     For Pp = 1 To Max_Pp
        rate_catg = Pick.extractint(PROP_REC(29), 1, Pp, 0)
        If rate_catg = 0 Then GoTo 190
        value = Pick.extractcur(PROP_REC(15), 1, Pp, 0)
        If FUTURE Then
           If IsNumeric(Pick.extract(PROP_REC(26), 1, Pp, 0)) Then value = Pick.extractcur(PROP_REC(26), 1, Pp, 0)
        End If
        RATEVAL = Pick.extractcur(INV_TAB, 3, Pp, 0)
        catg = 1
        If Pick.extractint(MIN_USED, Pp, 1, 0) = 0 Then catg = 0
        If Gst = 2 Then
           If RATEVAL > 0 Then
              GSTVAL = Pick.extractcur(GST_CHARGED, Pp, 0, 0)
           Else
              GSTVAL = 0
           End If
        Else
           GSTVAL = 0
        End If
        Call SR1682A_P(Pp, rate_catg, nn, N_CODES, PROP_REC(), POSS(), "1", value, RATEVAL, catg, 0, GSTVAL)
190  Next Pp

End Sub

Public Sub SR1682A_P(px As Integer, rate_catg As Integer, nn As Integer, N_CODES As String, PROP_REC() As String, POSS() As String, Num As String, use_VALUE As Currency, RATEVAL As Currency, catg As String, MODEL As Integer, GSTVAL As Currency)

Dim Ii As Integer, N_Code As Integer, CODE As String, Units_Code As String, NUM_UNITS As String
Dim Found As Integer, Code_List As String, Min_Catg As String, Pos As Integer, pos1 As Integer, pos3 As Integer
'
'   build array for analysis
'
     For Ii = 1 To nn
        If Pick.extract(N_CODES, 1, Ii, 0) = "" Then Exit For
        N_Code = Pick.extractint(N_CODES, 1, Ii, 0)
        If UBound(PROP_REC) < CInt(N_Code) Then
            ReDim Preserve PROP_REC(N_Code)
        End If
        CODE = PROP_REC(N_Code)
        If MODEL = 0 Then
           If Pick.extract(N_CODES, 1, Ii, 0) = 19 Then
              CODE = Pick.extract(CODE, 1, px, 0)
              Units_Code = CODE
              Call sr16_units(Units_Code, NUM_UNITS, CODE)
           Else
              CODE = Pick.trimm(CODE)
           End If
        End If
        If CODE = "" Then CODE = " "
        Found = 1
        Code_List = POSS(rate_catg, Ii)
        If Pick.locate(CODE, Code_List, 1, 1, 0, Pos, "AR") = 0 Then Found = 0
        If Found = 0 Then
           POSS(rate_catg, Ii) = Pick.insert(POSS(rate_catg, Ii), 1, Pos, 0, CODE)
           POSS(rate_catg, Ii) = Pick.insert(POSS(rate_catg, Ii), 2, Pos, 0, Num)
           POSS(rate_catg, Ii) = Pick.insert(POSS(rate_catg, Ii), 3, Pos, 0, CStr(use_VALUE))
           POSS(rate_catg, Ii) = Pick.insert(POSS(rate_catg, Ii), 4, Pos, 0, CStr(RATEVAL))
           POSS(rate_catg, Ii) = Pick.insert(POSS(rate_catg, Ii), 5, Pos, 0, catg)
           POSS(rate_catg, Ii) = Pick.insert(POSS(rate_catg, Ii), 6, Pos, 0, NUM_UNITS)
           POSS(rate_catg, Ii) = Pick.insert(POSS(rate_catg, Ii), 7, Pos, 0, CStr(use_VALUE))
           POSS(rate_catg, Ii) = Pick.insert(POSS(rate_catg, Ii), 8, Pos, 0, CStr(RATEVAL))
           POSS(rate_catg, Ii) = Pick.insert(POSS(rate_catg, Ii), 9, Pos, 0, CStr(GSTVAL))
        Else
           POSS(rate_catg, Ii) = Pick.replace(POSS(rate_catg, Ii), 2, Pos, 0, CStr(Pick.extractcur(POSS(rate_catg, Ii), 2, Pos, 0) + Num))
           POSS(rate_catg, Ii) = Pick.replace(POSS(rate_catg, Ii), 3, Pos, 0, CStr(Pick.extractcur(POSS(rate_catg, Ii), 3, Pos, 0) + use_VALUE))
           POSS(rate_catg, Ii) = Pick.replace(POSS(rate_catg, Ii), 4, Pos, 0, CStr(Pick.extractcur(POSS(rate_catg, Ii), 4, Pos, 0) + RATEVAL))
           Min_Catg = Pick.extract(POSS(rate_catg, Ii), 5, Pos, 0)
           Found = 1
           If Pick.locate(catg, Min_Catg, 1, 1, 1, pos1, "AR") = 0 Then Found = 0
           If Found = 0 Then
              POSS(rate_catg, Ii) = Pick.insert(POSS(rate_catg, Ii), 5, Pos, pos1, catg)
              POSS(rate_catg, Ii) = Pick.insert(POSS(rate_catg, Ii), 6, Pos, pos1, NUM_UNITS)
              POSS(rate_catg, Ii) = Pick.insert(POSS(rate_catg, Ii), 7, Pos, pos1, CStr(use_VALUE))
              POSS(rate_catg, Ii) = Pick.insert(POSS(rate_catg, Ii), 8, Pos, pos1, CStr(RATEVAL))
              POSS(rate_catg, Ii) = Pick.insert(POSS(rate_catg, Ii), 9, Pos, pos1, CStr(GSTVAL))
           Else
              If NUM_UNITS = "" Then NUM_UNITS = "0"
              POSS(rate_catg, Ii) = Pick.replace(POSS(rate_catg, Ii), 6, Pos, pos1, CStr(Pick.extractcur(POSS(rate_catg, Ii), 6, Pos, pos1) + CCur(NUM_UNITS)))
              POSS(rate_catg, Ii) = Pick.replace(POSS(rate_catg, Ii), 7, Pos, pos1, CStr(Pick.extractcur(POSS(rate_catg, Ii), 7, Pos, pos1) + use_VALUE))
              POSS(rate_catg, Ii) = Pick.replace(POSS(rate_catg, Ii), 8, Pos, pos1, CStr(Pick.extractcur(POSS(rate_catg, Ii), 8, Pos, pos1) + RATEVAL))
              POSS(rate_catg, Ii) = Pick.replace(POSS(rate_catg, Ii), 9, Pos, pos1, CStr(Pick.extractcur(POSS(rate_catg, Ii), 9, Pos, pos1) + GSTVAL))
           End If
        End If
        POSS(rate_catg, Ii) = Pick.replace(POSS(rate_catg, Ii), 10, 1, 0, CStr(Pick.extractcur(POSS(rate_catg, Ii), 10, 1, 0) + Num))
        POSS(rate_catg, Ii) = Pick.replace(POSS(rate_catg, Ii), 10, 2, 0, CStr(Pick.extractcur(POSS(rate_catg, Ii), 10, 2, 0) + use_VALUE))
        POSS(rate_catg, Ii) = Pick.replace(POSS(rate_catg, Ii), 10, 3, 0, CStr(Pick.extractcur(POSS(rate_catg, Ii), 10, 3, 0) + RATEVAL))
        Found = 1
        Code_List = POSS(rate_catg, Ii)
        If Pick.locate(catg, Code_List, 11, 1, 1, pos3, "AR") = 0 Then Found = 0
        If Found = 0 Then
           POSS(rate_catg, Ii) = Pick.insert(POSS(rate_catg, Ii), 11, 1, pos3, catg)
           POSS(rate_catg, Ii) = Pick.insert(POSS(rate_catg, Ii), 12, 1, pos3, NUM_UNITS)
           POSS(rate_catg, Ii) = Pick.insert(POSS(rate_catg, Ii), 13, 1, pos3, CStr(use_VALUE))
           POSS(rate_catg, Ii) = Pick.insert(POSS(rate_catg, Ii), 14, 1, pos3, CStr(RATEVAL))
           POSS(rate_catg, Ii) = Pick.insert(POSS(rate_catg, Ii), 15, 1, pos3, CStr(GSTVAL))
        Else
           If NUM_UNITS = "" Then NUM_UNITS = "0"
           POSS(rate_catg, Ii) = Pick.replace(POSS(rate_catg, Ii), 12, 1, pos3, CStr(Pick.extractcur(POSS(rate_catg, Ii), 12, 1, pos3) + CCur(NUM_UNITS)))
           POSS(rate_catg, Ii) = Pick.replace(POSS(rate_catg, Ii), 13, 1, pos3, CStr(Pick.extractcur(POSS(rate_catg, Ii), 13, 1, pos3) + use_VALUE))
           POSS(rate_catg, Ii) = Pick.replace(POSS(rate_catg, Ii), 14, 1, pos3, CStr(Pick.extractcur(POSS(rate_catg, Ii), 14, 1, pos3) + RATEVAL))
           POSS(rate_catg, Ii) = Pick.replace(POSS(rate_catg, Ii), 15, 1, pos3, CStr(Pick.extractcur(POSS(rate_catg, Ii), 15, 1, pos3) + GSTVAL))
        End If
     Next Ii

End Sub

Public Sub SR1682A_S(database As String, save As Integer, NO_SEL As Integer, POSS() As String, MAX_CAT As Integer, FUTURE As Integer, opt As String, nn As Integer, VERS As String, Prog As String)

' prog must be just the number (ie in logis would be TA1682 - here want just 1682)

Dim Max_Pp As Integer, Pp As Integer, Ii As Integer, J As Integer, Jj As Integer, Vector As String
Dim kk As Integer, xx As Integer, Key As String, wterr As Integer
'
' Write and restore model data from DICT RATE.MODEL
'
     If save = 0 Then GoTo 9000
'
     If save <> 2 Then GoTo 8000
'
     Max_Pp = 2
     If MAX_CAT > Max_Pp Then Max_Pp = MAX_CAT
     For Pp = 1 To Max_Pp
       For Ii = 1 To nn
          If POSS(Pp, Ii) = "" Then GoTo 2101
          If Pick.extract(POSS(Pp, Ii), 11, 1, 1) = "0" Then
             POSS(Pp, Ii) = Pick.replace(POSS(Pp, Ii), 11, 1, 1, "NOT MIN")
          Else
             POSS(Pp, Ii) = Pick.replace(POSS(Pp, Ii), 11, 1, 1, "MIN")
          End If
'
          If Pick.extract(POSS(Pp, Ii), 11, 1, 2) = "1" Then POSS(Pp, Ii) = Pick.replace(POSS(Pp, Ii), 11, 1, 2, "MIN")
'
          xx = Pick.dcount(Pick.extract(POSS(Pp, Ii), 1, 0, 0), Chr(253))
          For J = 1 To xx
             If Pick.extract(POSS(Pp, Ii), 5, J, 1) = "0" Then
                POSS(Pp, Ii) = Pick.replace(POSS(Pp, Ii), 5, J, 1, "NOT MIN")
             Else
                POSS(Pp, Ii) = Pick.replace(POSS(Pp, Ii), 5, J, 1, "MIN")
             End If
             If Pick.extract(POSS(Pp, Ii), 5, J, 2) = "1" Then POSS(Pp, Ii) = Pick.replace(POSS(Pp, Ii), 5, J, 2, "MIN")
          Next J
          POSS(Pp, Ii) = Pick.insert(POSS(Pp, Ii), 1, -1, 0, "Total")
          POSS(Pp, Ii) = Pick.insert(POSS(Pp, Ii), 2, -1, 0, Pick.extract(POSS(Pp, Ii), 10, 1, 0))
          POSS(Pp, Ii) = Pick.insert(POSS(Pp, Ii), 3, -1, 0, Pick.extract(POSS(Pp, Ii), 10, 2, 0))
          POSS(Pp, Ii) = Pick.insert(POSS(Pp, Ii), 4, -1, 0, Pick.extract(POSS(Pp, Ii), 10, 3, 0))
          POSS(Pp, Ii) = Pick.insert(POSS(Pp, Ii), 5, -1, 0, Pick.extract(POSS(Pp, Ii), 11, 1, 0))
          POSS(Pp, Ii) = Pick.insert(POSS(Pp, Ii), 6, -1, 0, Pick.extract(POSS(Pp, Ii), 12, 1, 0))
          POSS(Pp, Ii) = Pick.insert(POSS(Pp, Ii), 7, -1, 0, Pick.extract(POSS(Pp, Ii), 13, 1, 0))
          POSS(Pp, Ii) = Pick.insert(POSS(Pp, Ii), 8, -1, 0, Pick.extract(POSS(Pp, Ii), 14, 1, 0))
          POSS(Pp, Ii) = Pick.insert(POSS(Pp, Ii), 9, -1, 0, Pick.extract(POSS(Pp, Ii), 15, 1, 0))
       Next Ii
2101 Next Pp
'
'
8000 For Ii = 1 To NO_SEL
        For Jj = 1 To MAX_CAT
           Vector = ""
           For kk = 1 To 15
             Vector = Pick.replace(Vector, kk, 0, 0, Pick.extract(POSS(Jj, Ii), kk, 0, 0))
           Next kk
           Key = "@" & Prog & "." & FUTURE & "." & VERS & "." & Jj & "." & Ii
           wterr = d3.d3_writestr(database, "DICT RATE.MODEL", Key, Vector)
        Next Jj
     Next Ii
     Exit Sub
'
' Restore Item
'
9000 For Ii = 1 To NO_SEL
        For Jj = 1 To MAX_CAT
           Key = "@" & Prog & "." & FUTURE & "." & VERS & "." & Jj & "." & Ii
           If d3.d3_readstr(database, Vector, "DICT RATE.MODEL", Key) <> 0 Then Vector = ""
           For kk = 1 To 15
              POSS(Jj, Ii) = Pick.insert(POSS(Jj, Ii), -1, 0, 0, Pick.extract(Vector, kk, 0, 0))
           Next kk
           If Pick.extract(opt, 1, Ii, 0) = "" Then
              If POSS(Jj, Ii) <> "" Then opt = Pick.replace(opt, 1, Ii, 0, 1)
           End If
        Next Jj
     Next Ii

End Sub

Public Sub SR1600RL(logentry As String, PRG As String, Narr As String)

Dim prgno As String, opt As Integer, counter As Integer, Key As String, Whos As String, Termno As String
Dim Tc As String, dc As String, Last_Chng As String
Dim temp As String, rderr As Integer, logrec As String
Dim database As String

' WRITE ENTRY FOR PRG IN RATESLOG FILE
' PRG SHOULD CONTAIN EG '1600*11' TO WHICH THE LAST CHANGE # IS ADDED
' TO FORM THE ITEM KEY
' IF NEED TO WRITE TO ATTRIBUTES 7 & UP THE DATA SHOULD BE IN NARR
' WITH THE APPROPRIATE ATTRIBUTE MARKS

     database = Pick.extract(logentry, 2, 0, 0)
     prgno = Pick.field(PRG, "*", 1)
     temp = Pick.field(PRG, "*", 2)
     If IsNumeric(temp) Then opt = CInt(temp) Else opt = 0
     If d3.d3_readstr(database, logrec, "RATESLOG,", prgno) <> 0 Then logrec = ""
     counter = Pick.extractint(logrec, opt, 0, 0) + 1
     Key = PRG & "*" & counter
     
     temp = d3.execute_tcl(logentry, "WHO", "")
     Termno = Pick.field(temp, " ", 1)
     Whos = Pick.field(temp, " ", 2)
     
     Tc = Pick.field(CStr(Timer), ".", 1)
     dc = Pick.ICONV(Format$(Now, "DD MMM YY"), "D2")
     Last_Chng = dc & Chr(254) & Tc & Chr(254) & Termno & Chr(254) & Whos & Chr(254) & prgno & Chr(254) & Narr
     rderr = d3.d3_writestr(database, "RATESLOG", Key, Last_Chng)
     logrec = Pick.replace(logrec, opt, 0, 0, CStr(counter))
     rderr = d3.d3_writestr(database, "RATESLOG", prgno, logrec)

End Sub

Public Sub SR1682(Rates_Rec As String, ASSESS_NO As String, R_AMT As String, R_ACCT As String, Narr As String, Gst As Integer, GST_RATE As Currency, GST_CODE As String, SERVICE_DATE As String, Rate_Sub_Code As String, RATING As String, RKEY As String, DISC_PERC As Currency, DISC_DATE As String, PEN_PERC As Currency, PEN_DATE As String, REBATE_PERC As String, Rebate_Amt As String, REBATE_ON_LEVY As Integer, DISC_REBATE_AMT As String, Pcode As Integer, GSTVAL As Currency)

Dim units As String, CODE As String, gst_amt As Currency
Dim Valuation As Currency, rate_in_dollar As String, Min_Value As Currency, Max_Value As Currency, Max_Ii As Integer, GROSS_AMT As Currency
Dim Ii As Integer, Units_Code As String, Rnding As Integer, Net_Amt As Currency
Dim State_Rebate_Perc As Currency, State_Rebate_Amt As Currency, State_Rebate_Disc As Currency
Dim Council_Rebate_Perc As Currency, Council_Rebate_Amt As Currency, Council_Rebate_Disc As Currency
Dim Disc_Base As Currency, Disc_Amt As Currency, Gross_Amt2 As Currency
'
' set up RATES record
'
'
     Valuation = Pick.extract(RATING, 1, 1, 0)
     rate_in_dollar = Pick.extract(RATING, 1, 2, 0)
     Min_Value = Pick.extract(RATING, 1, 3, 0)
     Max_Value = Pick.extract(RATING, 1, 4, 0) + 0
'
     Max_Ii = Pick.dcount(R_AMT, Chr(253))
     GROSS_AMT = 0
     For Ii = 1 To Max_Ii
        GROSS_AMT = GROSS_AMT + Pick.extractcur(R_AMT, 1, Ii, 0)
     Next Ii
'
     Rates_Rec = ""                ' format RATES record
     Rates_Rec = Pick.replace(Rates_Rec, 1, 0, 0, Rate_Sub_Code)
     Rates_Rec = Pick.replace(Rates_Rec, 2, 0, 0, CStr(GROSS_AMT))
     Rates_Rec = Pick.replace(Rates_Rec, 3, 0, 0, SERVICE_DATE)
     Rates_Rec = Pick.replace(Rates_Rec, 4, 0, 0, SERVICE_DATE) ' GL date)
     If rate_in_dollar + 0 <> 0 Then 'mco 11jul00
        Rates_Rec = Pick.replace(Rates_Rec, 5, 0, 0, CStr(Valuation)) ' valuation charge)
        Rates_Rec = Pick.replace(Rates_Rec, 6, 0, 0, rate_in_dollar)
        Rates_Rec = Pick.replace(Rates_Rec, 7, 0, 0, CStr(Min_Value))
        If Max_Value <> 0 Then Rates_Rec = Pick.replace(Rates_Rec, 60, 0, 0, CStr(Max_Value))
     Else                         ' fixed charge
        Rates_Rec = Pick.replace(Rates_Rec, 7, 0, 0, CStr(Min_Value))
        If Rate_Sub_Code = "" Then
           units = "1"
        Else
           Units_Code = Rate_Sub_Code
           Call sr16_units(Units_Code, units, CODE)
           Rates_Rec = Pick.replace(Rates_Rec, 1, 0, 0, CODE)  ' rubbish code without numeric)
        End If
        Rates_Rec = Pick.replace(Rates_Rec, 8, 0, 0, units)
     End If
'
     If Gst = 1 Then
        If GROSS_AMT > 0 Then Rnding = 0.5 Else Rnding = -0.5
        Net_Amt = Int(GROSS_AMT * 100 / (GST_RATE + 100) + Rnding)
        gst_amt = GROSS_AMT - Net_Amt
        Rates_Rec = Pick.replace(Rates_Rec, 9, 1, 0, GST_CODE)
        Rates_Rec = Pick.replace(Rates_Rec, 9, 2, 0, CStr(gst_amt))
     Else
        If Gst = 2 Then
           Rates_Rec = Pick.replace(Rates_Rec, 2, 0, 0, Pick.extract(Rates_Rec, 2, 0, 0) + GSTVAL)
           Rates_Rec = Pick.replace(Rates_Rec, 9, 1, 0, 10)
           Rates_Rec = Pick.replace(Rates_Rec, 9, 2, 0, CStr(GSTVAL))
        End If
     End If
'
     State_Rebate_Perc = Pick.extractcur(REBATE_PERC, 1, 1, 0) * 100
     State_Rebate_Amt = Pick.extractcur(Rebate_Amt, 1, 1, 0)
     State_Rebate_Disc = Pick.extractcur(DISC_REBATE_AMT, 1, 1, 0)
     Council_Rebate_Perc = Pick.extractcur(REBATE_PERC, 1, 2, 0) * 100
     Council_Rebate_Amt = Pick.extractcur(Rebate_Amt, 1, 2, 0)
     Council_Rebate_Disc = Pick.extractcur(DISC_REBATE_AMT, 1, 2, 0)
'
     If DISC_PERC + 0 <> 0 And DISC_DATE <> "" Then
        Disc_Base = GROSS_AMT
        If REBATE_ON_LEVY Then
           Disc_Base = Disc_Base + State_Rebate_Amt + Council_Rebate_Amt
        End If
        Disc_Amt = Int(DISC_PERC * Disc_Base / 100 + 0.5)
        Rates_Rec = Pick.replace(Rates_Rec, 10, 0, 0, CStr(DISC_PERC))   ' discount rate)
        Rates_Rec = Pick.replace(Rates_Rec, 11, 0, 0, DISC_DATE)   ' due date)
        Rates_Rec = Pick.replace(Rates_Rec, 12, 0, 0, CStr(Disc_Amt))    ' discount offered (gross))
        Rates_Rec = Pick.replace(Rates_Rec, 14, 0, 0, Pick.extract(Rates_Rec, 12, 0, 0))
     End If
'
     If PEN_PERC + 0 <> 0 And PEN_DATE <> "" Then
        Rates_Rec = Pick.replace(Rates_Rec, 15, 0, 0, CStr(PEN_PERC))    ' penalty rate)
        Rates_Rec = Pick.replace(Rates_Rec, 16, 0, 0, PEN_DATE)    ' due date)
     End If
'
     If REBATE_ON_LEVY Then
        If Pcode Then
           Rates_Rec = Pick.replace(Rates_Rec, 20, 0, 0, CStr(State_Rebate_Perc)) ' state rebate rate)
           Rates_Rec = Pick.replace(Rates_Rec, 21, 0, 0, CStr(State_Rebate_Amt)) ' gross rebate offered)
           Rates_Rec = Pick.replace(Rates_Rec, 23, 0, 0, CStr(State_Rebate_Disc)) ' applied by levy run)
'
           Rates_Rec = Pick.replace(Rates_Rec, 25, 0, 0, CStr(Council_Rebate_Perc)) ' council remission)
           Rates_Rec = Pick.replace(Rates_Rec, 26, 0, 0, CStr(Council_Rebate_Amt)) ' gross amount)
           Rates_Rec = Pick.replace(Rates_Rec, 28, 0, 0, CStr(Council_Rebate_Disc)) ' applied by levy run)
        End If
     Else
        If State_Rebate_Perc And State_Rebate_Amt Then
           Rates_Rec = Pick.replace(Rates_Rec, 20, 0, 0, CStr(State_Rebate_Perc))
           Rates_Rec = Pick.replace(Rates_Rec, 21, 0, 0, CStr(State_Rebate_Amt))
           Rates_Rec = Pick.replace(Rates_Rec, 22, 0, 0, CStr(State_Rebate_Disc))
        End If
        If Pcode And DISC_PERC + 0 <> 0 And DISC_DATE <> "" Then
           Gross_Amt2 = GROSS_AMT - State_Rebate_Amt - Council_Rebate_Amt
           Disc_Amt = Int(DISC_PERC * Gross_Amt2 / 100 + 0.5)
           Rnding = (Pick.extract(Rates_Rec, 12, 0, 0) + Pick.extract(Rates_Rec, 22, 0, 0)) - (Disc_Amt + Pick.extract(Rates_Rec, 21, 0, 0))
           Rates_Rec = Pick.replace(Rates_Rec, 14, 0, 0, Disc_Amt + Rnding) ' rebated discount)
        End If
     End If

End Sub

Public Sub sr16_units(Units_Code As String, units As String, CODE As String)

' separate UNITS:CODE into UNITS & CODE
' (e.g. rubbish charges)

Dim Max_Jj As Integer, Jj As Integer
Dim cchar As String

     CODE = ""
     units = ""

     CODE = Pick.trimm(Units_Code)
     If CODE = "" Then Exit Sub
     If IsNumeric(Left(CODE, 1)) Then
        Max_Jj = Len(CODE)
        For Jj = 1 To Max_Jj
           cchar = Mid(CODE, Jj, 1)
           If Not IsNumeric(cchar) Then Exit For
           units = units & cchar
        Next Jj
        CODE = Mid(CODE, Jj)
     End If
     CODE = Pick.trimm(CODE)
     If units = "" Then units = "1"

End Sub



Public Sub SR1665(logentry As String, Sel As String, HeadYear As String, Glac As String, ExcelPath As String, ExcelFileName As String, Howbig As Long, Userec() As String, Optional Sent As String = "")
' TA1665 PRINT SCHEDULE OF RATES LEVIED
Dim Prog, Trans_Info As String, Gst, Gst_Control_Data, GST_CHARGED, Catdesc As String, Nocats As Integer
Dim Max_Ii, Ii As Integer, Council As String, Am As String, Vm As String, Svm As String, Msgf, I As Integer, Ln
Dim Clears, Ans, J As Integer, catg As String, Exbal, gl_rec As String, match, cnt, Values As String
Dim PROP_REC() As String, MMod, Ufuture As String, Ct, Atr As Integer, Rtcode As String, Num, Rtdoll As String, Rtype As String
Dim Rtdesc As String, Rtmin As String, Rtvalue As String, Min, k As Integer, Pcnt, LCNT, Gtot As String, tot As String, Stot As String
Dim pt_line As String, Notyp, typ, Nocodes, CODE, Yield1, Yield2, Rateable, xx As Integer
Dim S As Integer, logarray() As String, mylist() As String, Prec As String, MIN_USED As String, rderr As Integer, Pos As Integer, pos2 As Integer
Dim total_items As Long, pick_cnt As Long, X, Result As String, Rates As String, RATEVAL As String, work As String
Dim fso, fileno, textfile, tempstr, colhead
Dim dummy(0) As String
'
     Prog = "TA1665"
     Am = Chr(254): Vm = Chr(253): Svm = Chr(252)
     ReDim Userec(9)
     logarray() = Split(logentry, Am)
     If d3.d3_readstr(logarray(1), Trans_Info, "DICT TRANS.J", "TRANS.INFO") <> 0 Then Stop
     Gst = Mid$(Pick.extract(Trans_Info, 49, 0, 0), 12, 1)
     GST_CHARGED = ""
     If Glac = "NONE" Then
        Glac = ""
        Exbal = 0
     End If
     If InStr(Glac, ".") Then
        rderr = d3.d3_readstr(logarray(1), gl_rec, "GEN.L", Glac)
        If Pick.Index(Glac, ".", 2) Then
            Exbal = Int(Pick.extract(gl_rec, 4, 0, 0) / 100 + 0.5)
        Else
            Exbal = Int(Pick.extract(gl_rec, 3, 0, 0) / 100 + 0.5)
        End If
     Else
        If IsNumeric(Glac) Then Exbal = Glac
     End If
     If UBound(g_rates) = 0 Then
        g_rates(0) = "@RATES"
        Ii = d3.d3_readmat(logarray(1), g_rates(), "DICT TRANS.J")
     End If
     If d3.d3_readstr(logarray(1), Rates, "DICT TRANS.J", "@RATES") <> 0 Then Stop
     Catdesc = "": Nocats = 0: Prec = ""

     Max_Ii = Pick.dcount(Rates, Chr(254))
     For Ii = 9 To Max_Ii Step 10
        Nocats = Nocats + 1
        Catdesc = Pick.replace(Catdesc, Nocats, 0, 0, Pick.extract(Rates, Ii, 1, 0))
     Next Ii
     If d3.d3_readstr(logarray(1), Council, "DICT RR.LOG", "4", 2) <> 0 Then Council = ""
'
     Nocats = Pick.ccount(Sel, Vm, 1) + 1
     If Nocats = 1 Then
        Sel = 1
     End If
'

     cnt = 0: Values = ""
'
     If Sent = "" Then Sent = "SELECT PROPERTY"
     total_items = d3.d3_select(logentry, Sent, mylist(), pick_cnt, 0, 0)

'
     For X = 0 To total_items - 1
        ReDim PROP_REC(0)
        PROP_REC(0) = mylist(X)
        rderr = d3.d3_readmat(logarray(1), PROP_REC(), "PROPERTY")
        If UBound(PROP_REC) < 29 Then ReDim Preserve PROP_REC(29)
'
        cnt = cnt + 1
        Ufuture = "": Ufuture = Pick.replace(Ufuture, 1, 2, 0, 1)
        Call sr1690(logarray(1), dummy(), PROP_REC(), RATEVAL, 0, Ufuture, "", "", MIN_USED, "")
        If Nocats Then
            Ct = Pick.ccount(Pick.extract(PROP_REC(29), 1, 0, 0), Vm, 1) + 1
            For I = 1 To Ct
                catg = Pick.extract(PROP_REC(29), 1, I, 0)
                Result = Pick.locate(catg, Sel, 1, 1, 0, Pos, "")
                If Result = "0" Then GoTo 190
                GoSub 200
190         Next I
        End If
     Next X
     GoSub 500
     Exit Sub
'
200  Atr = (catg - 1) * 10 + 1
     Rtcode = Pick.extract(PROP_REC(19), 1, I, 0)
     If Rtcode = "" Then Return
     For J = 1 To 99
        If Pick.match(Mid$(Rtcode, J, 1), "1N") = 0 Then Exit For
     Next J
     If J > 1 Then
        Num = Mid$(Rtcode, 1, J - 1): Rtcode = Mid$(Rtcode, J, 99)
     Else
        Num = 1
     End If
     Result = Pick.locate(Rtcode, Rates, Atr, 1, 0, Pos, "")
     If Result = "0" Then
        Return
     End If
     Rtdoll = Pick.extract(Rates, Atr + 1, Pos, 0)
     Rtype = Pick.extract(Rates, Atr + 3, Pos, 0)
     If Rtype = "" Then Rtype = "None"
     Rtdesc = Pick.extract(Rates, Atr + 7, Pos, 0)
     If Rtdesc = "" Then Rtdesc = "No description"
     Rtmin = Pick.extract(Rates, Atr + 9, Pos, 1)
     Rtvalue = Pick.extractcur(PROP_REC(15), 1, I, 0)
     Min = Pick.extract(MIN_USED, I, 1, 0)
     Result = Pick.locate(Rtype, Values, Atr, 1, 0, Pos, "AR")
     If Result = "0" Then
        Values = Pick.insert(Values, Atr, Pos, 0, Rtype)
        Values = Pick.insert(Values, Atr + 1, Pos, 0, Rtcode)
        Values = Pick.insert(Values, Atr + 2, Pos, 0, Rtdesc)
        Values = Pick.insert(Values, Atr + 3, Pos, 0, Rtdoll)
        Values = Pick.insert(Values, Atr + 4, Pos, 0, Rtmin)
        For k = 5 To 6
           Values = Pick.insert(Values, Atr + k, Pos, 0, "0")
        Next k
     End If
     Result = Pick.locate(Rtcode, Values, Atr + 1, Pos, 1, pos2, "AL")
     If Result = "0" Then
        Values = Pick.insert(Values, Atr + 1, Pos, pos2, Rtcode)
        Values = Pick.insert(Values, Atr + 2, Pos, pos2, Rtdesc)
        Values = Pick.insert(Values, Atr + 3, Pos, pos2, Rtdoll)
        Values = Pick.insert(Values, Atr + 4, Pos, pos2, Rtmin)
        For k = 5 To 6
           Values = Pick.insert(Values, Atr + k, Pos, pos2, "0")
        Next k
     End If
     If Min <> "" And Min <> "0" Then
        Values = Pick.replace(Values, Atr + 6, Pos, pos2, CStr(Pick.extractcur(Values, Atr + 6, Pos, pos2) + Num))
     Else
        Values = Pick.replace(Values, Atr + 5, Pos, pos2, CStr(Pick.extractcur(Values, Atr + 5, Pos, pos2) + (Rtvalue * Num)))
     End If
     Return
'
500:  Pcnt = 0: LCNT = 99
     Gtot = "": tot = "": Stot = ""
     For I = 1 To Nocats
        catg = Pick.extract(Sel, 1, I, 0)
        If catg = "" Then GoTo 590
        Atr = (catg - 1) * 10 + 1
        pt_line = "Category " & catg: GoSub 900
        Notyp = Pick.ccount(Pick.extract(Values, Atr, 0, 0), Vm, 1) + 1
        For J = 1 To Notyp
           typ = Pick.extract(Values, Atr, J, 0)
           If typ = "" Then GoTo 580
           pt_line = Space(5) & "Rate Type " & typ: GoSub 900
           Nocodes = Pick.ccount(Pick.extract(Values, Atr + 1, J, 0), Svm, 1) + 1
           For k = 1 To Nocodes
              CODE = Pick.extract(Values, Atr + 1, J, k)
              If CODE = "" Then GoTo 570
              Yield1 = Int(Pick.extractcur(Values, Atr + 5, J, k) * Pick.extractcur(Values, Atr + 3, J, k) / 100 + 0.5)
              Yield2 = Int(Pick.extractcur(Values, Atr + 6, J, k) * Pick.extractcur(Values, Atr + 4, J, k) + 0.5)
              Rateable = Int(Pick.extractcur(Values, Atr + 5, J, k) / 1000 + 0.5)
              pt_line = CODE & Vm & Pick.extract(Values, Atr + 2, J, k) & Vm & Rateable & Vm & Pick.extract(Values, Atr + 3, J, k) & Vm & Yield1 & Vm & Pick.extract(Values, Atr + 6, J, k) & Vm & Yield2 & Vm & Yield1 + Yield2: GoSub 900
              Stot = Pick.replace(Stot, 1, 0, 0, CStr(Pick.extractcur(Stot, 1, 0, 0) + Pick.extractcur(Values, Atr + 5, J, k)))
              Stot = Pick.replace(Stot, 3, 0, 0, CStr(Pick.extractcur(Stot, 3, 0, 0) + Yield1))
              Stot = Pick.replace(Stot, 4, 0, 0, CStr(Pick.extractcur(Stot, 4, 0, 0) + Pick.extractcur(Values, Atr + 6, J, k)))
              Stot = Pick.replace(Stot, 5, 0, 0, CStr(Pick.extractcur(Stot, 5, 0, 0) + Yield2))
570        Next k
           pt_line = "": GoSub 900
           pt_line = "&nbsp;" & Vm & "&nbsp;" & Vm & Int(Pick.extract(Stot, 1, 0, 0) / 1000 + 0.5) & Vm & "&nbsp;" & Vm & Pick.extract(Stot, 3, 0, 0) & Vm & Pick.extract(Stot, 4, 0, 0) & Vm & Pick.extract(Stot, 5, 0, 0) & Vm & CStr(Pick.extractcur(Stot, 3, 0, 0) + Pick.extractcur(Stot, 5, 0, 0)): GoSub 900
           For S = 1 To 5
              tot = Pick.replace(tot, S, 0, 0, CStr(Pick.extractcur(tot, S, 0, 0) + Pick.extractcur(Stot, S, 0, 0)))
           Next S
           Stot = ""
580     Next J
        If Nocats > 1 Then
           pt_line = "": GoSub 900
           pt_line = "Total for category " & Vm & catg & Vm & Int(Pick.extractcur(tot, 1, 0, 0) / 1000 + 0.5) & Vm & "&nbsp;" & Vm & Pick.extract(tot, 3, 0, 0) & Vm & Pick.extract(tot, 4, 0, 0) & Vm & Pick.extract(tot, 5, 0, 0) & Vm & CStr(Pick.extractcur(tot, 3, 0, 0, 1) + Pick.extractcur(tot, 5, 0, 0, 1)): GoSub 900
           pt_line = "": GoSub 900
        End If
        For S = 1 To 5
           Gtot = Pick.replace(Gtot, S, 0, 0, CStr(Pick.extractcur(Gtot, S, 0, 0) + Pick.extractcur(tot, S, 0, 0)))
        Next S
        tot = ""
590  Next I
     If Glac <> "" Then
        pt_line = "": GoSub 900
        pt_line = "&nbsp;" & Vm & "Ex Gratia Rates" & Vm & "&nbsp;" & Vm & "&nbsp;" & Vm & "&nbsp;" & Vm & "&nbsp;" & Vm & Exbal: GoSub 900
        pt_line = "": GoSub 900
     End If

     pt_line = "GRAND TOTAL (LEVIED)" & Vm & "&nbsp;" & Vm & "&nbsp;" & Vm & "&nbsp;" & Vm & "&nbsp;" & Vm & "&nbsp;" & Vm & "&nbsp;" & Vm & CStr(Pick.extractcur(Gtot, 3, 0, 0) + Pick.extractcur(Gtot, 5, 0, 0) + Exbal): GoSub 900
    Howbig = Pick.ccount(Userec(1), Vm, 0) + 1
    Set fso = New Scripting.FileSystemObject
    fileno = 0
    ExcelFileName = ExcelPath & "\Ratlevy" & CStr(fileno) & ".xls"
    Do While fso.FileExists(ExcelFileName)
        fileno = fileno + 1
        ExcelFileName = ExcelPath & "\Ratlevy" & CStr(fileno) & ".xls"
    Loop
    Set textfile = fso.CreateTextFile(ExcelFileName, True)
    tempstr = colhead & vbTab & vbTab & "Rateable Value ($000's)" & vbTab & "Rate in $ (c.)" & vbTab & "Estimated Yield" & vbTab & "Minimum no." & vbTab & "Minimum Yield($)" & vbTab
    tempstr = tempstr & "Est Total Yield ($)"
    textfile.WriteLine (tempstr)
    For I = 1 To Howbig
        For J = 1 To 8
            work = Pick.extract(Userec(J), 1, I, 0)
            If work = "&nbsp;" Then work = ""
            If J = 1 Then
                tempstr = work
            Else
                tempstr = tempstr & vbTab & work
            End If
        Next J
        textfile.WriteLine (tempstr)
    Next I
    textfile.Close
    ExcelFileName = "Ratlevy" & CStr(fileno) & ".xls"
     Return
'
900:
    For xx = 1 To 8
        work = Pick.extract(pt_line, 1, xx, 0)
        If work = "" Then work = "&nbsp;"
        If Userec(xx) = "" Then
            Userec(xx) = work
        Else
            Userec(xx) = Userec(xx) & Vm & work
        End If
    Next xx
        
    Return
End Sub

Public Sub SR16_VAL(database As String, Prec() As String, vrec() As String)

' Show valuations for property and charge codes

     Dim Ii As Integer, maxii As Integer, vp As Integer
     Dim totval As Currency, rdesc As String
     Dim Rcat As String, rcatdesc As String
     Dim Rcode As String, RATEVAL As String, Invalid As String
     Dim rderr As Integer, temp As String, MIN_USED As String
     Dim dummy(0) As String, grates As String
     
     ReDim vrec(7)
     
     rderr = d3.d3_readstr(database, grates, "DICT TRANS.J", "@RATES")
           
'     ALPHA.DICT = ''
     If UBound(Prec) < 37 Then ReDim Preserve Prec(37)
     
     maxii = Pick.dcount(Prec(29), Chr(253))
     
     vp = 1
     For Ii = 1 To maxii
        If Pick.extract(Prec(26), 1, Ii, 0) <> "" Or Pick.extract(Prec(37), 1, Ii, 0) <> "" Then
           Rcat = Pick.extract(Prec(29), 1, Ii, 0)
           If IsNumeric(Rcat) Then
              rcatdesc = Pick.extract(grates, (CInt(Rcat) - 1) * 10 + 9, 1, 0)
              vrec(1) = Pick.replace(vrec(1), 1, vp, 0, rcatdesc)
              vrec(2) = Pick.replace(vrec(2), 1, vp, 0, Pick.extract(Prec(26), 1, Ii, 0))
              vrec(4) = Pick.replace(vrec(4), 1, vp, 0, Pick.extract(Prec(37), 1, Ii, 0))
              vrec(7) = Pick.replace(vrec(7), 1, vp, 0, "Future value and/or ratecode")
              vp = vp + 1
           End If
        End If
     Next Ii

     totval = 0
'     READ CLIENT.REC FROM CLIENT.DATA,prec(0) ELSE CLIENT.REC=''
     Call sr1690(database, dummy(), Prec(), RATEVAL, 0, "", "", "", MIN_USED, "")
'     CALL SR1690 (CLIENT.REC,PREC,RATEVAL,'','',RATES,0,'','',CLIENT.DATA,'','','',MIN.USED); **DONOTALTER**
     For Ii = 1 To maxii
        Rcat = Pick.extract(Prec(29), 1, Ii, 0)
        If IsNumeric(Rcat) Then
           rcatdesc = Pick.extract(grates, (CInt(Rcat) - 1) * 10 + 9, 1, 0)
           vrec(1) = Pick.replace(vrec(1), 1, vp, 0, rcatdesc)
           vrec(2) = Pick.replace(vrec(2), 1, vp, 0, Pick.extract(Prec(15), 1, Ii, 0))
           vrec(3) = Pick.replace(vrec(3), 1, vp, 0, Prec(35))
           Rcode = Pick.extract(Prec(19), 1, Ii, 0)
           vrec(4) = Pick.replace(vrec(4), 1, vp, 0, Rcode)
           GoSub 4000
           vrec(5) = Pick.replace(vrec(5), 1, vp, 0, rdesc)
           temp = Pick.extract(RATEVAL, Ii, 0, 0)
           If IsNumeric(temp) Then
              totval = totval + CCur(temp)
              temp = "Levy $" & Format(CCur(temp) / 100, "#.00")
           Else
              temp = ""
           End If
           vrec(7) = Pick.replace(vrec(7), 1, vp, 0, temp)
           vp = vp + 1
        End If
     Next Ii

     If maxii <> 1 Then
        vrec(1) = Pick.replace(vrec(1), 1, vp, 0, " ")
        temp = "Total $" & Format(totval / 100, "#.00")
        vrec(7) = Pick.replace(vrec(7), 1, vp, 0, temp)
        vp = vp + 1
     End If
     
Dim Crec() As String, Max As Integer, I As Integer, origs As String, add_vp As Integer, Narr As String
Dim Edate As String, epos As Integer, tempd As Variant, Pos As Integer, posn As Integer, Attr As Integer

        ReDim Crec(0): Crec(0) = "P|" & Prec(0)
        rderr = d3.d3_readmat(database, Crec(), "CHANGES")
        If UBound(Crec) < 2 Then
           Max = 0
        Else
           If IsNumeric(Crec(2)) Then Max = CInt(Crec(2)) Else Max = 0
        End If
 

      origs = ""
      For I = Max To 1 Step -1
         add_vp = 0
         ReDim Crec(0): Crec(0) = "P|" & Prec(0) & "|" & I
         rderr = d3.d3_readmat(database, Crec(), "CHANGES")
         posn = Pick.locate("15", Crec(7), 1, 1, 0, Pos, "")
         If posn = 0 Then GoTo sr16_val_130
         Ii = 1: Attr = 9 + (Pos - 1) * 2
         If UBound(Crec) < Attr Then ReDim Preserve Crec(Attr)
         For Ii = 1 To maxii
           If Pick.extract(Crec(Attr - 1), 1, Ii + 1, 0) <> Pick.extract(Crec(Attr), 1, Ii + 1, 0) Then GoTo sr16_val_115
         Next Ii
         GoTo sr16_val_130
sr16_val_115:
         Rcat = Pick.extract(Prec(29), 1, Ii, 0)
         If IsNumeric(Rcat) Then rcatdesc = Pick.extract(grates, (CInt(Rcat) - 1) * 10 + 9, 1, 0) Else rcatdesc = Rcat
         vrec(1) = Pick.replace(vrec(1), 1, vp, 0, rcatdesc)
         origs = Pick.replace(origs, 15, Ii, 0, Pick.extract(Crec(Attr - 1), 1, Ii + 1, 0))
         origs = Pick.replace(origs, 29, Ii, 1, CStr(Ii))
         vrec(2) = Pick.replace(vrec(2), 1, vp, 0, Pick.extract(Crec(Attr), 1, Ii + 1, 0))
         add_vp = 1
         If Ii <> 1 Then
            Edate = Crec(6)
            epos = Pick.Index(Edate, "Change effective", 1)
            If epos <> 0 Then
               Edate = Mid(Edate, epos + 17, 9)
               posn = Pick.date_vb_to_pick(Edate, tempd, 0)
               Edate = CStr(tempd)
            Else
               Edate = ""
            End If
            vrec(3) = Pick.replace(vrec(3), 1, vp, 0, Edate)
            GoTo sr16_val_140
         End If
sr16_val_130:
         posn = Pick.locate("35", Crec(7), 1, 1, 0, Pos, "") 'eff date
         If posn = 0 Then GoTo sr16_val_140
         Attr = 9 + (Pos - 1) * 2
         vrec(3) = Pick.replace(vrec(3), 1, vp, 0, Pick.extract(Crec(Attr), 1, 2, 0))
         add_vp = 1
sr16_val_140:
        posn = Pick.locate("29", Crec(7), 1, 1, 0, Pos, "")
         If posn = 0 Then GoTo sr16_val_160
         Attr = 9 + (Pos - 1) * 2
         For Ii = 1 To maxii
             If Pick.extract(Crec(Attr - 1), 1, Ii + 1, 0) <> Pick.extract(Crec(Attr), 1, Ii + 1, 0) Then GoTo sr16_val_145
         Next Ii
         GoTo sr16_val_160
sr16_val_145:
         origs = Pick.replace(origs, 29, Ii, 0, Pick.extract(Crec(Attr - 1), 1, Ii + 1, 0)): add_vp = 1
         Rcat = Pick.extract(Prec(29), 1, Ii, 0)
         If IsNumeric(Rcat) Then rcatdesc = Pick.extract(grates, (CInt(Rcat) - 1) * 10 + 9, 1, 0) Else rcatdesc = Rcat
         vrec(1) = Pick.replace(vrec(1), 1, vp, 0, rcatdesc)
         Rcode = Pick.extract(Crec(Attr), 1, Ii + 1, 2): GoSub 4000
         vrec(4) = Pick.replace(vrec(4), 1, vp, 0, Rcode)
         vrec(5) = Pick.replace(vrec(5), 1, vp, 0, rdesc)
         Edate = Crec(6)
         epos = Pick.Index(Edate, "Change effective", 1)
         If epos <> 0 Then
            Edate = Mid(Edate, epos + 17, 9)
            posn = Pick.date_vb_to_pick(Edate, tempd, 0)
            Edate = CStr(tempd)
         Else
            Edate = ""
         End If
         vrec(3) = Pick.replace(vrec(3), 1, vp, 0, Edate)
sr16_val_160:
         If add_vp <> 0 Then
            vrec(6) = Pick.replace(vrec(6), 1, vp, 0, Crec(1))
            Narr = Pick.extract(Crec(6), 1, 1, 0)
            If Left(Narr, 16) = "Change effective" Then Narr = ""
            vrec(7) = Pick.replace(vrec(7), 1, vp, 0, Narr)
            If Pick.extract(vrec(1), 1, vp, 0) = "" Then vrec(1) = Pick.replace(vrec(1), 1, vp, 0, " ")
            vp = vp + 1
         End If
      Next I
      For Ii = 1 To maxii
         add_vp = 0
         If Pick.extract(origs, 15, Ii, 0) <> "" Then
            vrec(2) = Pick.replace(vrec(2), 1, vp, 0, Pick.extract(origs, 15, Ii, 0))
            add_vp = 1
         End If
         If Pick.extract(origs, 19, Ii, 0) <> "" Then
            Rcode = Pick.extract(origs, 19, Ii, 0): GoSub 4000
            vrec(4) = Pick.replace(vrec(4), 1, vp, 0, Rcode)
            vrec(5) = Pick.replace(vrec(5), 1, vp, 0, rdesc): add_vp = 1
         End If
         If Pick.extract(origs, 29, Ii, 0) <> "" Then
            Rcode = Pick.extract(origs, 29, Ii, 2)
            If Rcode <> "" Then
               GoSub 4000
               vrec(4) = Pick.replace(vrec(4), 1, vp, 0, Rcode)
               vrec(5) = Pick.replace(vrec(5), 1, vp, 0, rdesc)
            End If
            Rcat = Pick.extract(origs, 29, Ii, 1)
            If IsNumeric(Rcat) Then rcatdesc = Pick.extract(grates, (CInt(Rcat) - 1) * 10 + 9, 1, 0) Else rcatdesc = Rcat
            vrec(1) = Pick.replace(vrec(1), 1, vp, 0, rcatdesc)
            add_vp = 1
         End If
         If add_vp <> 0 Then
            vrec(7) = Pick.replace(vrec(7), 1, vp, 0, "Property loaded")
            If Pick.extract(vrec(1), 1, vp, 0) = "" Then vrec(1) = Pick.replace(vrec(1), 1, vp, 0, " ")
            vp = vp + 1
         End If
     Next Ii

     Exit Sub
     
4000:
     rdesc = sr_ratedesc(Rcat, Rcode, grates) ' Get rate description
     Return

End Sub
Public Function TA1685(logentry As String, PASS_Interim As String, LIVE_RUN As Integer, Sdate As Integer, Edate As Integer, Sent As String, parms As String) As String

Dim mylist() As String, pick_cnt As Long, total_items As Long
Dim MAILADDR() As String, nme() As String, GIVEN() As String, INIT() As String
Dim trans_rec As String, temp As String, Rate_Categs As String
Dim Which As String, Wanted As String, Interim As Integer, Pool_Flg As Integer
Dim INT_METH As Integer, posn As Integer, rderr As Integer, ptab As String
Dim Yr As String, Interim_Details As String, Interim_Amts As String, Interim_Bals As String
Dim install As String, Mess As String, R_Area As String, dum_r_area As String, Shire_Clerk As String, Apbar_Ctl As String
Dim Pool_Code As String, rtab As String, Minmax As String, Ct10 As String, Ii As Integer, Format_Rec As String, DISC_DATE As String
Dim Exclude As Integer, Issue_Date As Integer, Due_Date As Integer, arr_date As Integer
Dim Micr As String, No_Charges As Integer, int_rec As String
Dim TD_OFLOW_REC As String, datums As String, allow_defer As Currency, seq_no As Currency
Dim PEN_PERC As Currency, days_due As Currency, accr As Currency, catg_code As String
'Dim Path_Name
Dim Disc_Arr As String, PENALTY_TAB As String, Inst_Remind As String, Client_No As String, Interim_Ref As String
Dim pt_line As String, Narr As String, Date_P As Integer, Interim_Gst_Codes As String
Dim Interim_Gst_Amts As String, Last_Notice As Integer, Penalty_Since As Currency, No_Oflows As Integer, Orec As String
Dim Pens_Nos As String, Addr As String, Num As String, Street As String, Client_Rec() As String
Dim Tt As Integer, Own As String, Nonrefs As String, Defer_Refs As String, Instref As String, Nonrefs_Amt  As String
Dim Defer_Refs_Amt As String, Instref_Amt As String, Lot As String, Instal_Tab As String, Rate_Tab As String, Max_Rates As Integer
Dim Property_Rec As String, Rate_Desc As String, Grv As String, Ctx As Integer, Vatx As Integer, Rate_Ind As String
Dim Pos As Integer, Grv_Code As String, Abrv_Desc As String, Total_Penalty As Currency, Install_Opt As String
Dim Last_Instal, Irx As Integer, Prev_Irx As Integer, Payment1, Irm As Integer, Subtot As Currency, Pcode As Integer, end_date As Integer
Dim Rate_Code As String, start_date As Integer, PEN_AMT As Currency, Pinst_Tab As String, Types As String, Refs As String
Dim Amts As String, Dates As String, Paids As String, Notrans As Integer, narrs As String, Found As Integer, Qq As Integer, Okey As String, Disc_Amt As Currency
Dim rx As Integer, Apply_Rebate As String, Apply_Defer As String, Inst_Tab As String, Ri_Tab As String, Temp_D As String
Dim Dx As Integer, Length2 As Integer, Name1 As String, Name2 As String, Ward_Desc As String, CODE As String, Cl_No As String, J As Integer
Dim Noip, X As Integer, kk As Integer, typp As Integer, Dte As Integer, Ref As String, Interim_Trans As Integer, Amt As Currency
Dim Paid, Pre As String, Rates_Id As String, Rates_Rec As String, Ppos As Integer, Instalable_Trans As Integer, Instpos As Integer
Dim Rtx As Integer, Disc_Due_Date As Integer, Aiplan As String, Adj As Integer, aa As Integer, dd As Integer
Dim database As String, special As String, ut_install_fname As String, rpos As Integer, fkey As String
Dim special_suffix As String, ignores As String, mv As Integer, inc As Integer
Dim senior As Integer, apamt As String, icd As String, ins_codes As String, apcode As String, pwr As Integer

' if printing the special code (eg underground power) then only want to print transactions with a code of UP
' if printing the normal codes then must ignore all special coded transactions - so ignores is setup with UP

     database = Pick.extract(logentry, 2, 0, 0)
     Rate_Categs = "": special = ""
     For Ii = 1 To 4
        If Pick.extract(parms, Ii, 0, 0) <> "" Then
           If Rate_Categs = "" Then
              Rate_Categs = Pick.extract(parms, Ii, 0, 0)
              If Ii <> 1 Then special = Pick.extract(Rate_Categs, 1, 1, 0)
           Else
              TA1685 = Chr(8) & "Must only select rate codes from one or other group"
              Exit Function
           End If
        End If
     Next Ii
     If Rate_Categs = "" Then TA1685 = Chr(8) & "Must select some rate codes to print": Exit Function
     
     If UBound(g_rates) = 0 Then
        g_rates(0) = "@RATES"
        rderr = d3.d3_readmat(database, g_rates(), "DICT TRANS.J")
     End If

     Max_Rates = Pick.dcount(Rate_Categs, Chr(253))
     For Ii = 1 To Max_Rates 'change passed category numbers to codes and descriptions
        kk = Pick.extractint(Rate_Categs, 1, Ii, 0)
        kk = kk * 10 - 1
        Rate_Categs = Pick.replace(Rate_Categs, 1, Ii, 0, Pick.extract(g_rates(kk), 1, 2, 0))
        Rate_Categs = Pick.replace(Rate_Categs, 2, Ii, 0, Pick.extract(g_rates(kk), 1, 1, 0))
     Next Ii
     If special <> "" Then special_suffix = "." & Pick.extract(Rate_Categs, 1, 1, 0) Else special_suffix = ""
     ut_install_fname = "INSTALL.CTL" & special_suffix
     
     Pool_Code = "SP"
     If Pool_Flg And special = "" Then
        If Pick.locate(Pool_Code, Rate_Categs, 1, 1, 0, Rtx, "") = 0 Then
           Rate_Categs = Pick.insert(Rate_Categs, 1, -1, 0, Pool_Code)
           Rate_Categs = Pick.insert(Rate_Categs, 2, -1, 0, "SWIMMING POOL")
        End If
     End If
     If special = "" Then
        Rate_Categs = Pick.insert(Rate_Categs, 1, -1, 0, "SUNDRY")
        Rate_Categs = Pick.insert(Rate_Categs, 2, -1, 0, "Sundry Transactions")
     End If
     Max_Rates = Pick.dcount(Pick.extract(Rate_Categs, 1, 0, 0), Chr(253))

     Issue_Date = Pick.extractint(parms, 5, 0, 0)
     Due_Date = Pick.extractint(parms, 6, 0, 0)
     Exclude = Pick.extractint(parms, 7, 0, 0)
     fkey = Pick.extract(parms, 8, 0, 0)
     If d3.d3_readstr(database, Format_Rec, "RATES.CTL", fkey) <> 0 Then TA1685 = Chr(8) & fkey & "does not exist in RATES.CTL file": Exit Function
     
     Which = Pick.extract(PASS_Interim, 1, 2, 0)
     Wanted = Pick.extract(PASS_Interim, 1, 3, 0)
     Interim = Pick.extractint(PASS_Interim, 1, 1, 0)

     Pool_Flg = d3.d3_file_exists(database, "sw.pool") '0=not exists,1=exists
     
     If UBound(g_trans_info_array) = 0 Then
        g_trans_info_array(0) = "TRANS.INFO"
        posn = d3.d3_readmat(database, g_trans_info_array(), "DICT TRANS.J")
     End If
     If UBound(g_trans_info_array) < 59 Then ReDim Preserve g_trans_info_array(59)
     arr_date = Pick.extract(g_trans_info_array(59), 1, 3, 0)
     temp = Mid$(g_trans_info_array(53), 14, 1)
     If IsNumeric(temp) Then INT_METH = CInt(temp) Else INT_METH = 0
     Yr = Pick.extract(g_trans_info_array(59), 1, 1, 0)
     Interim_Details = "": Interim_Amts = "": Interim_Bals = ""
'
     'If d3.d3_readstr(database, Bay_Flg, "DICT TRANS.J", "@RATE_FLAG") <> 0 Then Bay_Flg = "0"
     If d3.d3_readstr(database, install, "DICT TRANS.J", "@INSTALL" & special_suffix) <> 0 Then install = ""
     ins_codes = Pick.extract(install, 22, 1, 0) & Chr(253) & Pick.extract(install, 23, 1, 0) '"II" "IA" "AI" "AA"
     mv = 2
     If pwr Then
        ins_codes = Pick.extract(install, 22, 2, 0) & Chr(253) & Pick.extract(install, 23, 2, 0) '"UI" "UA"
        If d3.d3_readstr(database, install, "DICT TRANS.J", "@INSTALL_UP") <> 0 Then install = ""
        mv = 3
     End If
     apcode = "AP": apamt = 0
'    INS.CODES=INS.CODES:INSTALL<22,MV>:CHAR(253):INSTALL<23,MV>
     ins_codes = ins_codes & Chr(253) & Pick.extract(install, 22, mv, 0) & Chr(253) & Pick.extract(install, 23, mv, 0)

     If d3.d3_readstr(database, Mess, "DICT TRANS.J", "@RATESMESS") <> 0 Then Mess = ""
     R_Area = "*"
     If d3.d3_readstr(database, dum_r_area, "DICT TDEBTOR", "@RATES.AREA") <> 0 Then R_Area = "N"
     If d3.d3_readstr(database, Shire_Clerk, "DICT RR.LOG", "4", 8) <> 0 Then Shire_Clerk = ""
     If d3.d3_readstr(database, Apbar_Ctl, "DICT TRANS.J", "@APBAR_CTL") <> 0 Then Apbar_Ctl = ""
'
     Call SR300_TAB(database, rtab, ptab)
     ignores = ""
     If special = "" Then
        If Pool_Flg Then
           If Pick.locate(Pool_Code, rtab, 1, 1, 0, Rtx, "") = 0 Then
              rtab = Pick.insert(rtab, 1, -1, 0, Pool_Code)
              rtab = Pick.insert(rtab, 2, -1, 0, "N")
              rtab = Pick.insert(rtab, 3, -1, 0, "N")
           End If
        End If
        For Ii = 1 To Pick.dcount(rtab, Chr(253))
           If Pick.extract(rtab, 4, Ii, 0) <> "" Then ignores = Pick.insert(ignores, 1, -1, 0, Pick.extract(rtab, 1, Ii, 0))
        Next Ii
     End If
'
     Minmax = g_rates(1)
     Ct10 = Pick.dcount(g_rates(10), Chr(253))
     For Ii = 1 To Ct10
        Minmax = Pick.replace(Minmax, 2, Ii, 0, Pick.extractcur(g_rates(10), 1, Ii, 1) * 100)
        Minmax = Pick.replace(Minmax, 3, Ii, 0, Pick.extractcur(g_rates(10), 1, Ii, 2) * 100)
     Next Ii
     DISC_DATE = ""
     pt_line = ""
     seq_no = 0
'        If d3.d3_readstr(database, Path_Name, "RATES.CTL", "@RATES_NOTICE_PATHNAME") <> 0 Then Path_Name = ""
'        CLEARFILE RATES_XFER_DATA

     If Interim = 2 Then
        If d3.d3_readstr(database, int_rec, "PR.INTERIM", Wanted) <> 0 Then Exit Function
        Client_No = Pick.field(Wanted, "-", 1)
        Interim_Ref = Pick.extract(int_rec, 2, 0, 0)
        GoTo 210
     End If

  Sent = replace(Sent, Chr(254), """", , , vbBinaryCompare)
  total_items = d3.d3_select(logentry, Sent, mylist(), pick_cnt, 0, 0)
  For kk = 0 To total_items - 1
     Client_No = mylist(kk)
     If Interim Then
        If d3.d3_readstr(database, Interim_Ref, "PR.INTERIM", Client_No) <> 0 Then GoTo 480
        If LIVE_RUN Then
           Date_P = CInt(Pick.ICONV(Format$(Now, "DD MMM YY"), "D2"))
           If Pick.extract(Interim_Ref, 3, 0, 0) <> "" Then GoTo 480
           Interim_Ref = Pick.replace(Interim_Ref, 3, 0, 0, CStr(Date_P))
           rderr = d3.d3_writestr(database, "PR.INTERIM", Client_No, Interim_Ref)
        Else
           Date_P = Pick.extractint(Interim_Ref, 3, 0, 0)
           If Date_P = 0 Then GoTo 480   ' not a reprint
           If Date_P < Sdate And Sdate <> 0 Then GoTo 480
           If Date_P < Sdate Or Edate <> 0 Then GoTo 480
        End If
        Interim_Ref = Pick.extract(Interim_Ref, 2, 0, 0)
'        DELETE PR.INTERIM.DATA,CLIENT.NO
        Client_No = Pick.field(Client_No, "-", 1) ' in case more than one interim in same print run
     End If

210  Interim_Details = "": Interim_Amts = "": Interim_Bals = ""
     Interim_Gst_Codes = "": Interim_Gst_Amts = ""
     If d3.d3_readstr(database, trans_rec, "TDEBTOR", Client_No) <> 0 Then GoTo 480

     Last_Notice = Pick.extractint(trans_rec, 55, 0, 0): Penalty_Since = 0
     No_Oflows = Pick.extractint(trans_rec, 27, 0, 0)
'
     Orec = ""
     ReDim nme(2)
     ReDim GIVEN(2)
     ReDim INIT(2)
     ReDim MAILADDR(5): Pens_Nos = ""
     Addr = "":  Num = "":  Street = ""
     ReDim Client_Rec(0): Client_Rec(0) = Client_No
     If d3.d3_readmat(database, Client_Rec(), "CLIENT") <> 0 Then
     End If
     If UBound(Client_Rec) < 84 Then ReDim Preserve Client_Rec(84) 'mco 16jan02
'
     For Tt = 1 To 2
        Own = Pick.extract(Client_Rec(35), 1, Tt, 0)
        If Own = "" Then GoTo 300
        If d3.d3_readstr(database, Orec, "CLIENT", Own) <> 0 Then Orec = ""
        Pens_Nos = Pick.insert(Pens_Nos, 1, -1, 0, Pick.extract(Orec, 43, 0, 0))
        nme(Tt) = Pick.extract(Orec, 1, 0, 0)
        INIT(Tt) = Pick.extract(Orec, 6, 0, 0)
        GIVEN(Tt) = Pick.extract(Orec, 7, 0, 0)
        If Tt = 1 Then
           For Ii = 2 To 5
              MAILADDR(Ii) = Pick.extract(Orec, Ii, 1, 0)
              If Ii = 5 Then MAILADDR(Ii) = MAILADDR(5)
              If Ii = 5 And MAILADDR(5) = "9999" Then MAILADDR(5) = ""
           Next Ii
        End If
     Next Tt
     If Pick.extract(Client_Rec(35), 1, 3, 0) <> "" Then nme(2) = nme(2) & " & others"
'
300  If MAILADDR(4) <> "" Then
        MAILADDR(4) = MAILADDR(4) & " " & MAILADDR(5)
        MAILADDR(5) = ""
     Else
        MAILADDR(3) = MAILADDR(3) & " " & MAILADDR(5)
        MAILADDR(5) = ""
     End If
     If d3.d3_readstr(database, Property_Rec, "PROPERTY", Client_No) <> 0 Then GoTo 480
     If Pick.extract(Property_Rec, 32, 0, 0) <> "" Then GoTo 480
'
     Call SR1692(Client_Rec(), "", Pcode, senior)
'
' analyse all transaction records
'
     Nonrefs = "": Defer_Refs = "": Instref = ""
     Nonrefs_Amt = "": Defer_Refs_Amt = "": Instref_Amt = ""
     Lot = Pick.extract(Property_Rec, 1, 1, 0)
     Instal_Tab = ""
     Rate_Tab = Rate_Categs 'mvalued with categories to be rated - attr 1 (code) 2 (desc)

     If Pick.extract(Property_Rec, 29, 0, 0) = "" And Pick.extract(Property_Rec, 19, 0, 0) <> "" Then
        Property_Rec = Pick.replace(Property_Rec, 29, 0, 0, 1)
     End If
     Rate_Desc = "": Grv = ""
     No_Charges = Pick.dcount(Pick.extract(Property_Rec, 29, 0, 0), Chr(253))
     For Ii = 1 To No_Charges
      Ctx = Pick.extractint(Property_Rec, 29, Ii, 0)
      If Ctx <> 0 Then
       Vatx = (Ctx * 10) - 9
       catg_code = Pick.extract(g_rates(Vatx + 9), 1, 2, 0)
       If Pick.locate(catg_code, Rate_Tab, 1, 1, 0, rpos, "") <> 0 Then 'want to print this category
        Rate_Ind = Pick.extract(Property_Rec, 19, Ii, 0)
        If Rate_Ind <> "" Then
           If Pick.locate(Rate_Ind, g_rates(Vatx), 1, 1, 0, Pos, "") <> 0 Then
              Grv_Code = Pick.extract(g_rates(Vatx + 3), 1, Pos, 0)       ' GRV code
              Abrv_Desc = Pick.extract(g_rates(Vatx + 7), 1, Pos, 0)      ' abrev. desc.
              Rate_Desc = Pick.replace(Rate_Desc, 2, Ctx, 0, Abrv_Desc)
              Grv = Pick.replace(Grv, 1, Ctx, 0, Pick.extract(Property_Rec, 15, Ii, 0))
              Rate_Tab = Pick.replace(Rate_Tab, 3, rpos, 0, Rate_Ind)
              Rate_Tab = Pick.replace(Rate_Tab, 4, rpos, 0, Abrv_Desc)
              Rate_Tab = Pick.replace(Rate_Tab, 16, rpos, 0, Grv_Code)
           End If
        End If
       End If
      End If
     Next Ii
'
     PENALTY_TAB = "":  Inst_Remind = "":  Total_Penalty = 0
     Install_Opt = Pick.extract(trans_rec, 85, 0, 0)
     If Install_Opt <> "" Then
        If Pick.locate(CStr(Issue_Date), trans_rec, 86, 1, 0, Irx, "AR") = 0 Then
        End If
'       MADE INCORRECT ASSUMPTIONS AS WHAT TO DO IF AFTER INSTALMENT PERIOD.
        Last_Instal = 0
        If Irx > CInt(Install_Opt) Then Irx = Install_Opt: Last_Instal = 1
        Inst_Remind = Pick.replace(Inst_Remind, 1, 0, 0, Pick.extract(trans_rec, 86, Irx, 0)) ' next date due)
        Inst_Remind = Pick.replace(Inst_Remind, 2, 0, 0, Pick.extract(trans_rec, 90, Irx, 0)) ' next amount due)
        Inst_Remind = Pick.replace(Inst_Remind, 5, 0, 0, Pick.extract(trans_rec, 92, Irx, 0)) ' amount pre-paid)
        Prev_Irx = Irx - 1
        If Last_Instal Then Prev_Irx = CInt(Install_Opt)
        Payment1 = 0
        For Irm = 1 To Prev_Irx               ' overdue
           Subtot = Pick.extractcur(trans_rec, 90, Irm, 0) - Pick.extractcur(trans_rec, 92, Irm, 0)
           If Irm = 1 Then Payment1 = Subtot
           If Subtot > 0 Then
              Inst_Remind = Pick.replace(Inst_Remind, 3, 0, 0, Pick.extractcur(Inst_Remind, 3, 0, 0) + Subtot)
              If Irm > 1 And (Pcode + senior) = 0 Then ' no penalty on 1st
                 end_date = Issue_Date
                 Rate_Code = Pick.extract(ptab, 1, 1, 0)
                 start_date = Pick.extract(trans_rec, 86, Irm, 0)
                 If Prev_Irx >= 2 Then           ' to last instalment
                    start_date = Pick.extract(trans_rec, 86, Prev_Irx, 0)
                    GoSub 5000                   ' calculate penalty
                    Inst_Remind = Pick.replace(Inst_Remind, 4, 0, 0, Pick.extract(Inst_Remind, 4, 0, 0) + PEN_AMT)
                 End If
              End If
           End If
        Next Irm
        If Pick.extractcur(Inst_Remind, 2, 0, 0) Then    ' rate on current instalment
           start_date = Due_Date
           end_date = Due_Date + 2
           Subtot = Pick.extractcur(Inst_Remind, 2, 0, 0)
           Rate_Code = Pick.extract(ptab, 1, 1, 0)
           GoSub 5000
           PENALTY_TAB = Pick.replace(PENALTY_TAB, 3, 0, 0, CStr(PEN_AMT)) ' daily accrual rate)
        End If
     End If
'
     PEN_AMT = 0: Pinst_Tab = ""
     Found = 0
     If No_Oflows Then
        For Qq = 1 To No_Oflows
           Okey = Qq & "*" & Client_No
           If d3.d3_readstr(database, TD_OFLOW_REC, "TD.OFLOW", Okey) <> 0 Then Return
           Types = Pick.extract(TD_OFLOW_REC, 2, 0, 0)
           Refs = Pick.extract(TD_OFLOW_REC, 3, 0, 0)
           Amts = Pick.extract(TD_OFLOW_REC, 4, 0, 0)
           Dates = Pick.extract(TD_OFLOW_REC, 5, 0, 0)
           Paids = Pick.extract(TD_OFLOW_REC, 6, 0, 0)
           Notrans = Pick.extractint(TD_OFLOW_REC, 1, 0, 0)
           narrs = Pick.extract(TD_OFLOW_REC, 7, 0, 0)
           GoSub 4500
        Next Qq
     End If
     If Found = 0 And Exclude Then GoTo 480
'
     PENALTY_TAB = Pick.replace(PENALTY_TAB, 1, 0, 0, CStr(PEN_AMT))
     PENALTY_TAB = Pick.replace(PENALTY_TAB, 2, 0, 0, Int(Pick.extractint(Pinst_Tab, 11, 0, 0))) '"RATE PER DAY ON O"DUE INSTALMENTS)
     PENALTY_TAB = Pick.replace(PENALTY_TAB, 5, 0, 0, Int(Pick.extractint(Pinst_Tab, 11, 0, 0))) '??? RATE PER DAY ON ARREARS)
'
     Disc_Arr = ""
     For Ii = 1 To Max_Rates
        Rate_Code = Pick.extract(Rate_Tab, 1, Ii, 0)
        Disc_Amt = Pick.extractcur(Rate_Tab, 13, Ii, 0)
'
        If Pick.locate(Rate_Code, rtab, 1, 1, 0, rx, "") = 0 Then rx = 0
        If rx Then Apply_Rebate = Pick.extract(rtab, 2, rx, 0) Else Apply_Rebate = "N"
        If rx Then Apply_Defer = Pick.extract(rtab, 3, rx, 0) Else Apply_Defer = "N"
'
        Disc_Arr = Pick.replace(Disc_Arr, 1, Ii, 0, Pick.extract(Rate_Tab, 20, Ii, 0)) ' discount rate)
        Disc_Arr = Pick.replace(Disc_Arr, 3, Ii, 0, Pick.extract(Rate_Tab, 21, Ii, 0)) ' penalty rate)
'
     Next Ii
'
     Disc_Arr = Pick.replace(Disc_Arr, 2, 0, 0, DISC_DATE)
     Disc_Arr = Pick.replace(Disc_Arr, 6, 0, 0, CStr(Due_Date))
'
     Inst_Tab = ""
     If Pick.extract(install, 1, 0, 0) <> "" Then
        Ri_Tab = ""
        Ri_Tab = Pick.replace(Ri_Tab, 1, 0, 0, Pick.extract(Rate_Tab, 1, 0, 0))
        Ri_Tab = Pick.replace(Ri_Tab, 2, 0, 0, Pick.extract(Instal_Tab, 2, 0, 0))
        If Interim = 0 Then
           Ri_Tab = Pick.replace(Ri_Tab, 12, 0, 0, Pick.extract(Rate_Tab, 12, 0, 0))
           Ri_Tab = Pick.replace(Ri_Tab, 11, 0, 0, Pick.extract(Rate_Tab, 11, 0, 0))
           Ri_Tab = Pick.replace(Ri_Tab, 17, 0, 0, Pick.extract(PENALTY_TAB, 1, 0, 0))
        End If
        Temp_D = 0
        For Dx = 1 To Max_Rates
           Temp_D = Temp_D + Pick.extractcur(Rate_Tab, 10, Dx, 0) + Pick.extractcur(Rate_Tab, 11, Dx, 0) - Pick.extractcur(Rate_Tab, 12, Dx, 0) - Pick.extractcur(Rate_Tab, 13, Dx, 0) - Pick.extractcur(Rate_Tab, 14, Dx, 0) - Pick.extractcur(Rate_Tab, 15, Dx, 0)
        Next Dx
        If Temp_D + Pick.extractcur(Ri_Tab, 17, 0, 0) > 0 Then
           Call SR16_INST(install, Ri_Tab, Pcode, senior, CStr(Issue_Date), Inst_Tab, Interim)
        End If
     End If
'
    Addr = Pick.extract(Client_Rec(2), 1, 2, 0)
    If Addr = "" Then Addr = Pick.extract(Client_Rec(2), 1, 1, 0)
    If IsNumeric(Mid$(Addr, 1, 1)) Then
        Num = Pick.field(Addr, " ", 1)
        Length2 = Len(Num) + 2
    Else
        Num = "": Length2 = 1
    End If
    Street = Mid(Addr, Length2, 99)
'
    Name1 = Pick.trimm(GIVEN(1) & " " & nme(1))
    Name2 = Pick.trimm(GIVEN(2) & " " & nme(2))
    If d3.d3_readstr(database, Ward_Desc, "AREA", Pick.extract(Property_Rec, 38, 0, 0), 1) <> 0 Then Ward_Desc = ""
'--------------------------------------------
'   Generate the check digit for the client
'--------------------------------------------
     If d3.d3_readstr(database, CODE, "DICT TRANS.J", "@CONTROL") <> 0 Then CODE = ""
     Call SR1685_CHK(CODE, Client_No)
    'If pick.extract(Bay_Flg, 1, 1, 0) = "1" And Micr <> "Y" Then
    '    Cl_No = String$(7 - Len(CLIENT_NO), "0") & pick.extract(CLIENT_NO, 1, 0, 0)
    '    CLIENT_NO = pick.Replace(CLIENT_NO, 3, 0, 0, "<")
    '    For j = 2 To 8 Step 2
    '       CLIENT_NO = pick.Replace(CLIENT_NO, 3, 0, 0, pick.extract(CLIENT_NO, 3, 0, 0) & "A" & Left(Mid$(Cl_No, j - 1, 2) & Space(2), 2))
    '    Next j
    '    CLIENT_NO = pick.Replace(CLIENT_NO, 3, 0, 0, pick.extract(CLIENT_NO, 3, 0, 0) & "A  A  A  A  A <A08A6=A12A7 & A51A75A8=A39A07A< A60")
    'End If
'
     PENALTY_TAB = Pick.replace(PENALTY_TAB, 6, 0, 0, CStr(Penalty_Since))
     Call SR1685_13(database, Yr, Name1, Name2, MAILADDR(), Disc_Arr, CStr(Issue_Date), Client_No, Property_Rec, Pcode, senior, Ward_Desc, Client_Rec(), Grv, Shire_Clerk, Rate_Desc, R_Area, Minmax, Mess, Format_Rec, trans_rec, Rate_Tab, Inst_Tab, pt_line, Apbar_Ctl, Inst_Remind, PENALTY_TAB, Interim_Details, Interim_Amts, Interim_Bals, datums, Interim_Gst_Codes, Interim_Gst_Amts, apamt)
'
     seq_no = seq_no + 1
     rderr = d3.d3_writestr(database, "RATES.XFER", CStr(seq_no), pt_line)
'
     If LIVE_RUN Then
        Noip = Pick.dcount(Pick.extract(Inst_Tab, 1, 0, 0), Chr(253))
        For X = 1 To Noip
           GoSub 6000
        Next X
     End If
490  If Which <> "S" Then
        If d3.d3_readstr(database, trans_rec, "TDEBTOR", Pick.extract(Client_No, 1, 0, 0)) <> 0 Then
           trans_rec = Pick.replace(trans_rec, 55, 0, 0, CStr(Issue_Date))
           rderr = d3.d3_writestr(database, "TDEBTOR", Pick.extract(Client_No, 1, 0, 0), trans_rec)
        End If
     End If
480:
     If Interim = 2 Then Exit Function
    Next kk
    If LIVE_RUN Then
       Narr = "Live Run on " & Pick.oconv(Pick.ICONV(Format$(Now, "DD MMM YY"), "D2"), "D2")
       If Interim Then Narr = Narr & " INTERIM"
       Narr = Narr & " sent to file"
       Narr = Narr & Chr(254) & Chr(254) & Chr(254) & Chr(254) & Chr(254) & Yr & Chr(254) & Issue_Date & Chr(254) & Chr(254) & Chr(254) & Sent
       Call SR1600RL(logentry, "1685*1", Narr)
    End If
    'Call SR_XFER("RATES_XFER", Path_Name, "rates")
    Exit Function
'
' s/r 4500:  analyse transaction history
'
4500 For kk = 1 To Notrans
        typp = Pick.extractint(Types, 1, kk, 0)
        Dte = Pick.extractint(Dates, 1, kk, 0)
        Ref = Pick.extract(Refs, 1, kk, 0)
        icd = Left(Ref, 2)
        
        If pwr Then
           If Pick.locate(icd, Rate_Tab, 1, 1, 0, inc, "") = 0 Then inc = 0
           If inc = 0 Then
              If Pick.locate(icd, ins_codes, 1, 1, 0, inc, "") = 0 Then GoTo 4598  'UI or UA okay
           End If
        Else
           If typp = 48 Or typp = 73 Then
              If Pick.locate(icd, Rate_Tab, 1, 1, 0, inc, "") = 0 Then inc = 0
              If inc = 0 Then
                 If Pick.locate(icd, ins_codes, 1, 1, 0, inc, "") = 0 Then GoTo 4598 'II or IA or AI or AA okay
              End If
           End If
        End If

        Interim_Trans = 0 'MCO FOR LSE
        If Interim Then
           If Pick.locate(Ref, Interim_Ref, 1, 1, 0, Interim_Trans, "") = 0 Then Interim_Trans = 0
           If Interim_Trans = 0 Then GoTo 4598
        End If
        Amt = Pick.extract(Amts, 1, kk, 0)
        If Exclude And Amt > 0 Then
           If Dte >= arr_date Then
              If Dte > Exclude Then
                 If Mid$(Ref, 5, 1) = "I" Then GoTo 4598 'exclude interim charges
              End If
           End If
        End If
        If Amt <> 0 Then Found = 1
        Paid = Pick.extract(Paids, 1, kk, 0)
        Narr = Pick.extract(narrs, 1, kk, 0)
        If typp = 76 And Dte > Last_Notice Then Penalty_Since = Penalty_Since + Amt
        If Interim_Trans Then
           Pre = Mid$(Ref, 1, 2)
           If Pick.locate(Pre, rtab, 1, 1, 0, Ppos, "") = 0 Then
           End If
           Interim_Details = Pick.insert(Interim_Details, 1, Ppos, -1, Narr)
           Interim_Amts = Pick.insert(Interim_Amts, 1, Ppos, -1, CStr(Amt))
           Interim_Bals = Pick.insert(Interim_Bals, 1, Ppos, -1, CStr(Amt - Paid))
           Rates_Id = Ref & "*" & Pick.extract(Client_No, 1, 0, 0)
           If d3.d3_readstr(database, Rates_Rec, "RATES", Rates_Id) <> 0 Then Rates_Rec = ""
           Interim_Gst_Codes = Pick.insert(Interim_Gst_Codes, 1, Ppos, -1, Pick.extract(Rates_Rec, 9, 1, 0))
           Interim_Gst_Amts = Pick.insert(Interim_Gst_Amts, 1, Ppos, -1, Pick.extract(Rates_Rec, 9, 2, 0))
           If Paid <> 0 Then
              Ppos = Max_Rates + 1
              Interim_Details = Pick.insert(Interim_Details, 1, Ppos, -1, "Already paid")
              Interim_Amts = Pick.insert(Interim_Amts, 1, Ppos, -1, -Paid)
              Interim_Bals = Pick.insert(Interim_Bals, 1, Ppos, -1, 0)
           End If
        End If
4591    Subtot = Amt - Paid
        If Dte < arr_date Then
           If Subtot = 0 Then GoTo 4598
        End If
        If icd = apcode Then
           apamt = apamt + Subtot
           GoTo 4598
        End If


        Instalable_Trans = 0
        If install <> "" Then
           Instalable_Trans = 1
           Instpos = 0
           If Dte >= arr_date And typp >= 50 And typp <> 76 Then
              If Pick.locate(Rate_Code, install, 6, 1, 1, Instpos, "") = 0 Then Instpos = 0
           End If
           If Instpos = 0 Then
              Instalable_Trans = 0
           Else
              If Pick.extract(install, 7, 1, Instpos) <> "Y" Then
                 Instalable_Trans = 0
              End If
           End If
        End If

        If Pick.locate(Rate_Code, rtab, 1, 1, 0, Rtx, "") = 0 Then Rtx = 0
        If Rtx Then Apply_Rebate = Pick.extract(rtab, 2, Rtx, 0) Else Apply_Rebate = "N"
        If Rtx Then Apply_Defer = Pick.extract(rtab, 3, Rtx, 0) Else Apply_Defer = "N"
'
        Rate_Tab = Pick.replace(Rate_Tab, 8, rx, 0, Pick.extractcur(Rate_Tab, 8, rx, 0) + Subtot) ' total)
        Rate_Tab = Pick.replace(Rate_Tab, 9, rx, 0, Pick.extractcur(Rate_Tab, 9, rx, 0) + Subtot) ' total)
        If Paid <> 0 And typp >= 50 Then
           Rate_Tab = Pick.replace(Rate_Tab, 8, rx, 0, Pick.extract(Rate_Tab, 8, rx, 0) + Paid) ' total)
           Rate_Tab = Pick.replace(Rate_Tab, 9, rx, 0, Pick.extract(Rate_Tab, 9, rx, 0) + Paid) ' total)
           Rate_Tab = Pick.replace(Rate_Tab, 8, Max_Rates, 0, Pick.extract(Rate_Tab, 8, Max_Rates, 0) - Paid) ' total)
           Rate_Tab = Pick.replace(Rate_Tab, 9, Max_Rates, 0, Pick.extract(Rate_Tab, 9, Max_Rates, 0) - Paid) ' total)
        End If
'
        Disc_Amt = 0:  Rates_Rec = ""
        Select Case typp
           Case 73, 77, 48, 22                    ' rates
              Rates_Id = Ref & "*" & Pick.extract(Client_No, 1, 0, 0)
              If d3.d3_readstr(database, Rates_Rec, "RATES", Rates_Id) <> 0 Then Rates_Rec = ""
              Rate_Tab = Pick.replace(Rate_Tab, 5, rx, 0, Pick.extract(Rates_Rec, 6, 0, 0)) ' rate in $)
              Rate_Tab = Pick.replace(Rate_Tab, 6, rx, 0, Pick.extract(Rates_Rec, 7, 0, 0)) ' minimum amount)
              Rate_Tab = Pick.replace(Rate_Tab, 7, rx, 0, Pick.extract(Rates_Rec, 8, 0, 0)) ' units)
              Rate_Tab = Pick.replace(Rate_Tab, 22, rx, 0, Pick.extract(Rates_Rec, 60, 0, 0)) ' maximum amount)
              Rate_Tab = Pick.replace(Rate_Tab, 23, rx, 0, Pick.extract(Rates_Rec, 44, 0, 0)) ' assess xferred from)
              Rate_Tab = Pick.replace(Rate_Tab, 24, rx, 0, Pick.extract(Rates_Rec, 45, 0, 0)) ' amount transferred)
              Rate_Tab = Pick.replace(Rate_Tab, 25, rx, 0, Pick.extract(Rates_Rec, 9, 1, 0)) ' GST Code)
              Rate_Tab = Pick.replace(Rate_Tab, 26, rx, 0, Pick.extract(Rates_Rec, 9, 2, 0)) ' GST Amount)
           Case 76
              Rates_Id = Ref & "*" & Pick.extract(Client_No, 1, 0, 0)
              If d3.d3_readstr(database, Rates_Rec, "RATES", Rates_Id) <> 0 Then Rates_Rec = ""
           Case Is >= 50                      ' other charges
           Case 1                                ' credits
              Apply_Rebate = "N"
        End Select
        If Pick.extract(Rates_Rec, 11, 0, 0) <> "" Then DISC_DATE = Pick.extract(Rates_Rec, 11, 0, 0)
        Call SR16_defer(Apply_Defer, Client_Rec(), Dte, allow_defer)
        If Subtot <> 0 Then
           If allow_defer Then
              If Dte >= arr_date And Instalable_Trans Then
                 Instref = Pick.insert(Instref, 1, -1, 0, Ref): Instref_Amt = Pick.insert(Instref_Amt, 1, -1, 0, CStr(Subtot))
              Else
                 Defer_Refs = Pick.insert(Defer_Refs, 1, -1, 0, Ref): Defer_Refs_Amt = Pick.insert(Defer_Refs_Amt, 1, -1, 0, CStr(Subtot))
              End If
           Else
              If Instalable_Trans = 0 Then
                 Nonrefs = Pick.insert(Nonrefs, 1, -1, 0, Ref): Nonrefs_Amt = Pick.insert(Nonrefs_Amt, 1, -1, 0, CStr(Subtot))
              Else
                 Instref = Pick.insert(Instref, 1, -1, 0, Ref): Instref_Amt = Pick.insert(Instref_Amt, 1, -1, 0, CStr(Subtot))
              End If
           End If
        End If
        Pinst_Tab = ""
        Call SR300_INSPEN(database, Pinst_Tab, Pick.extract(Client_No, 1, 0, 0), typp, Ref, Dte, arr_date, Pcode, senior, trans_rec, Subtot, "", ptab, INT_METH, Client_Rec(), "", PEN_AMT, Issue_Date, allow_defer)
        If Dte >= arr_date Then ' current charge
           Rate_Tab = Pick.replace(Rate_Tab, 10, rx, 0, Pick.extractcur(Rate_Tab, 10, rx, 0) + Subtot) ' current)
           If Paid <> 0 And typp >= 50 Then
              Rate_Tab = Pick.replace(Rate_Tab, 10, rx, 0, Pick.extractcur(Rate_Tab, 10, rx, 0) + Paid) ' total)
              Rate_Tab = Pick.replace(Rate_Tab, 10, Max_Rates, 0, Pick.extractcur(Rate_Tab, 10, Max_Rates, 0) - Paid) ' total)
           End If
           Instal_Tab = Pick.replace(Instal_Tab, 2, rx, 0, Pick.extractcur(Instal_Tab, 2, rx, 0) + Subtot)
           If Paid <> 0 And typp >= 50 Then
              Instal_Tab = Pick.replace(Instal_Tab, 2, rx, 0, Pick.extractcur(Instal_Tab, 2, rx, 0) + Paid)
              Instal_Tab = Pick.replace(Instal_Tab, 2, Max_Rates, 0, Pick.extractcur(Instal_Tab, 2, Max_Rates, 0) - Paid)
           End If
           If Subtot = 0 Then GoTo 4598
           Disc_Due_Date = Pick.extractint(Rates_Rec, 11, 0, 0)
           If Disc_Due_Date >= Issue_Date Then
              DISC_DATE = Disc_Due_Date
              If (Pcode + senior) Then
                 Disc_Amt = Pick.extractcur(Rates_Rec, 14, 0, 0)
                 If Disc_Amt = "" Then Disc_Amt = Pick.extractcur(Rates_Rec, 12, 0, 0) 'MCO - MAY NOT BE REBATABLE
              Else
                 Disc_Amt = Pick.extractcur(Rates_Rec, 12, 0, 0)
              End If
              If Subtot > "0" Then
                 If Disc_Amt > Subtot Then Disc_Amt = 0
              Else
                 If Disc_Amt < "0" Then
                    If typp = 48 Then Disc_Amt = Disc_Amt
                 End If
              End If
              Rate_Tab = Pick.replace(Rate_Tab, 13, rx, 0, Pick.extractcur(Rate_Tab, 13, rx, 0) + Disc_Amt)
              Rate_Tab = Pick.replace(Rate_Tab, 9, rx, 0, Pick.extractcur(Rate_Tab, 9, rx, 0) - Disc_Amt)
           End If
           If (Pcode Or senior) And Apply_Rebate = "Y" Then
              Rate_Tab = Pick.replace(Rate_Tab, 14, rx, 0, Pick.extractcur(Rate_Tab, 14, rx, 0) + Pick.extractcur(Rates_Rec, 21, 0, 0)) ' rebate)
              Rate_Tab = Pick.replace(Rate_Tab, 15, rx, 0, Pick.extractcur(Rate_Tab, 15, rx, 0) + Pick.extractcur(Rates_Rec, 26, 0, 0)) ' remiss)
              Instal_Tab = Pick.replace(Instal_Tab, 2, rx, 0, Pick.extractcur(Instal_Tab, 2, rx, 0) - Pick.extractcur(Rates_Rec, 21, 0, 0))
           End If
           If Pick.extractcur(Rates_Rec, 75, 0, 0) <> 0 Then
              Rate_Tab = Pick.replace(Rate_Tab, 27, rx, 0, Pick.extractcur(Rate_Tab, 27, rx, 0) + Pick.extractcur(Rates_Rec, 75, 0, 0)) ' rebate)
              Instal_Tab = Pick.replace(Instal_Tab, 2, rx, 0, Pick.extractcur(Instal_Tab, 2, rx, 0) - Pick.extractcur(Rates_Rec, 75, 0, 0))
           End If
           Rate_Tab = Pick.replace(Rate_Tab, 20, rx, 0, Pick.extract(Rates_Rec, 10, 0, 0)) ' discount rate)
           Rate_Tab = Pick.replace(Rate_Tab, 21, rx, 0, Pick.extract(Rates_Rec, 15, 0, 0)) ' penalty rate)
        Else                               ' arrears charge
           Rate_Tab = Pick.replace(Rate_Tab, 11, rx, 0, Pick.extractcur(Rate_Tab, 11, rx, 0) + Subtot) ' arrears)
           If Paid <> 0 And typp >= 50 Then
              Rate_Tab = Pick.replace(Rate_Tab, 11, rx, 0, Pick.extractcur(Rate_Tab, 11, rx, 0) + Paid) ' total)
              Rate_Tab = Pick.replace(Rate_Tab, 11, Max_Rates, 0, Pick.extractcur(Rate_Tab, 11, Max_Rates, 0) - Paid) ' total)
           End If
           If allow_defer Then
              Rate_Tab = Pick.replace(Rate_Tab, 8, rx, 0, Pick.extractcur(Rate_Tab, 8, rx, 0) - Subtot) ' total)
              Rate_Tab = Pick.replace(Rate_Tab, 9, rx, 0, Pick.extractcur(Rate_Tab, 9, rx, 0) - Subtot) ' total)
              Rate_Tab = Pick.replace(Rate_Tab, 12, rx, 0, Pick.extractcur(Rate_Tab, 12, rx, 0) + Subtot) ' deferred)
           End If
        End If
4598 Next kk
     Return
'
' s/r 5000:  calculate (daily) penalty interest
'
5000 Call SR1694_PENALTY(database, PEN_AMT, PEN_PERC, Rate_Code, ptab, start_date, end_date - 1, Subtot, days_due, accr)
     Return
'
' S/R 6000: EXTRACT AIPLAN X FROM INSTREF
'
6000 If Pick.extract(Inst_Tab, 11, X, 0) = "" Then Return ' NOTHING TO OFFER
     If d3.d3_readstr(database, Aiplan, ut_install_fname, Pick.extract(Client_No, 1, 0, 0)) <> 0 Then Aiplan = ""
     Adj = 0
     For aa = 12 To 9999 Step 20
        If Pick.extract(Aiplan, aa, 0, 0) = "" Then GoTo 6010
        Adj = Adj + 20
     Next aa
6010 Aiplan = Pick.replace(Aiplan, 1 + Adj, 0, 0, Pick.extract(Inst_Tab, 2, X, 0))    ' DATES)
     Aiplan = Pick.replace(Aiplan, 2 + Adj, 0, 0, Pick.extract(Inst_Tab, 3, X, 0))    ' BASE AMT)
     Dx = Pick.extract(Inst_Tab, 1, X, 0)
     Aiplan = Pick.replace(Aiplan, 3 + Adj, 0, 0, 0)
     For dd = 1 To Dx
        Aiplan = Pick.replace(Aiplan, 3 + Adj, 0, 0, Pick.extract(Aiplan, 3 + Adj, 0, 0) + Pick.extract(Inst_Tab, 4, X, dd)) ' ADMIN)
     Next dd
     Aiplan = Pick.replace(Aiplan, 4 + Adj, 0, 0, Pick.extract(Inst_Tab, 8, X, 0))    ' INTEREST)
     Aiplan = Pick.replace(Aiplan, 5 + Adj, 0, 0, Pick.extract(Inst_Tab, 11, X, 0))
     Aiplan = Pick.replace(Aiplan, 6 + Adj, 0, 0, Instref)
     Aiplan = Pick.replace(Aiplan, 8 + Adj, 0, 0, Nonrefs)
     Aiplan = replace(Aiplan, Chr(252), Chr(253))
     Aiplan = Pick.replace(Aiplan, 7 + Adj, 1, 0, Pick.extract(Inst_Tab, 12, 0, 0))
     Aiplan = Pick.replace(Aiplan, 7 + Adj, 2, 0, Pick.extract(Inst_Tab, 9, 0, 0))
     Aiplan = Pick.replace(Aiplan, 7 + Adj, 3, 0, Pick.extract(Inst_Tab, 10, 0, 0))
     Aiplan = Pick.replace(Aiplan, 18 + Adj, 1, 0, Pick.extract(datums, 32, 0, 0))
     Aiplan = Pick.replace(Aiplan, 18 + Adj, 2, 0, Pick.extract(datums, 74, 0, 0))
     Aiplan = Pick.replace(Aiplan, 18 + Adj, 3, 0, Pick.extract(datums, 78, 0, 0))
     Aiplan = Pick.replace(Aiplan, 18 + Adj, 4, 0, Pick.extract(datums, 24, 0, 0))
     Aiplan = Pick.replace(Aiplan, 18 + Adj, 5, 0, Pick.extractcur(datums, 33, 0, 0) * -1) 'Make discount a + amt)
     Aiplan = Pick.replace(Aiplan, 10 + Adj, 0, 0, Pick.extract(install, 1, X, 0))
     Aiplan = Pick.replace(Aiplan, 11 + Adj, 0, 0, CStr(Interim))
     Aiplan = Pick.replace(Aiplan, 12 + Adj, 0, 0, Pick.extract(Inst_Tab, 1, X, 0))
     If Interim And Pick.extract(Inst_Tab, 1, X, 0) = 0 Then Aiplan = Pick.replace(Aiplan, 10 + Adj, 0, 0, 0)
     Aiplan = Pick.replace(Aiplan, 13 + Adj, 0, 0, Defer_Refs)
     Aiplan = Pick.replace(Aiplan, 9 + Adj, 0, 0, Nonrefs_Amt)
     Aiplan = Pick.replace(Aiplan, 19 + Adj, 0, 0, Instref_Amt)
     Aiplan = Pick.replace(Aiplan, 20 + Adj, 0, 0, Defer_Refs_Amt)
     rderr = d3.d3_writestr(database, ut_install_fname, Pick.extract(Client_No, 1, 0, 0), Aiplan)
     Return

End Function


Public Sub SR300_RATES(database As String, Client_Rec() As String, Pcode As Integer, Rcode As String, ASSESS_NO As String, PEN_AMT As Currency, CASH_DATE As String, PENALTY_TAB As String, Narr As String, Tr_Inv_Ref As String, Tjrec As String, Disc_Or_Rebate As String, Pp_Type As String, GROSS_AMT As Currency, Disc_Amt As Currency, Tr_Ref As String, UREF As String)

Dim Year As String, Rtrecnar As String, Attr As Integer, Cde As String, suffix As String
Dim GST_CHARGED As String, Prec() As String, Ufuture As String, INT_ACCS As String
Dim Int_Acc As String, cat_no As String, Oname As String, wterr As Integer
Dim Ptx As Integer, Pos As Integer, Rtid_Ct, Rtrec As String, Ii As Integer, aa
Dim Bb As Integer, Use_Ref As String, old_rec As String, pens As String
'
' Add discount transaction for discount raised in cash receipting
'     - one for each rating prefix
'
     Year = Pick.extract(g_trans_info_array(59), 1, 1, 0)        ' current rating year
     Rtrecnar = Narr
     Rtrecnar = replace(Rtrecnar, Chr(252), Chr(253))
'
     Select Case Disc_Or_Rebate
     Case "D"
        Attr = 3: Cde = 66: suffix = "D": Pp_Type = 41
     Case "R"
        Attr = 5: Cde = 62: suffix = "R": Pp_Type = 37
     Case "P"
        Attr = 4: Cde = 23: suffix = "P": Pp_Type = 76
     End Select
'
     GST_CHARGED = ""
     ReDim Prec(0): Prec(0) = ASSESS_NO
     If d3.d3_readmat(database, Prec(), "PROPERTY") <> 0 Then
     End If
     Ufuture = "":  Ufuture = Pick.replace(Ufuture, 1, Attr, 0, "1")
     INT_ACCS = ""
     Call sr1690(database, Client_Rec(), Prec(), "", Pcode, Ufuture, "", INT_ACCS, "", GST_CHARGED)
     If Pick.locate(Rcode, PENALTY_TAB, 1, 1, 0, Ptx, "") = 0 Then Ptx = 1
     cat_no = Pick.extract(PENALTY_TAB, 4, Ptx, 0)
     Call SR300_PENACC(cat_no, Int_Acc, Prec(), INT_ACCS)
     Pos = Pick.dcount(Pick.extract(Tjrec, 1, 0, 0), Chr(253)) + 1
     Tjrec = Pick.replace(Tjrec, 1, Pos, 0, Cde)
     Tjrec = Pick.replace(Tjrec, 3, Pos, 0, Int_Acc)
     Tjrec = Pick.replace(Tjrec, 4, Pos, 0, CStr(PEN_AMT))
     Tjrec = Pick.replace(Tjrec, 5, Pos, 0, ASSESS_NO)
'
     Rtid_Ct = 0
     Tr_Inv_Ref = Rcode & Year & suffix  '1ST Cat_ as prefix (primary)
350  If d3.d3_readstr(database, Rtrec, "RATES", Tr_Inv_Ref & "*" & ASSESS_NO) <> 0 Then GoTo 360
     Rtid_Ct = Rtid_Ct + 1
     Tr_Inv_Ref = Rcode & Year & suffix & "-" & Rtid_Ct
     GoTo 350
360  Rtrec = ""
     If suffix = "P" Then Rtrec = Pick.replace(Rtrec, 2, 0, 0, CStr(PEN_AMT)) Else Rtrec = Pick.replace(Rtrec, 2, 0, 0, CStr(-PEN_AMT))
     Rtrec = Pick.replace(Rtrec, 3, 0, 0, CASH_DATE)
     Rtrec = Pick.replace(Rtrec, 4, 0, 0, CASH_DATE)
     If suffix = "P" Then Rtrec = Pick.replace(Rtrec, 15, 0, 0, Pick.extract(PENALTY_TAB, 2, Ptx, 0))
     Rtrec = Pick.replace(Rtrec, 34, 0, 0, Rtrecnar)
     Rtrec = Pick.replace(Rtrec, 59, 0, 0, suffix)
     If suffix = "R" Then
        Call SR1693(database, Client_Rec(), Pcode, Oname, pens, "", "", "ALL")
        Rtrec = Pick.replace(Rtrec, 61, 0, 0, Oname)
'
        For Ii = 1 To 99
           aa = Pick.Index(Oname, "&", Ii)
           If aa = "0" Then GoTo 365
           Bb = Pick.Index(pens, "&", Ii)
           If Bb = 0 Then pens = pens & " & NON"
        Next Ii
'
365     Rtrec = Pick.replace(Rtrec, 62, 0, 0, Pick.trimm(pens))
        Rtrec = Pick.replace(Rtrec, 68, 0, 0, Pcode * 100)
'        RTREC<12>=DISC.AMT; *AMOUNT OF DISCOUNT APPLIED BEFORE REBATE GIVEN
        Rtrec = Pick.replace(Rtrec, 67, 0, 0, CStr(GROSS_AMT)) 'AMOUNT ON WHICH REBATE GIVEN)
     End If
     If suffix = "D" Then
        Rtrec = Pick.replace(Rtrec, 67, 0, 0, CStr(GROSS_AMT)) 'AMOUNT ON WHICH DISCOUNT GIVEN)
     End If
     Rtrec = Pick.replace(Rtrec, 63, 0, 0, ASSESS_NO)
     Rtrec = Pick.replace(Rtrec, 64, 0, 0, Tr_Inv_Ref)
     Rtrec = Pick.replace(Rtrec, 65, 0, 0, UREF)
     Rtrec = Pick.replace(Rtrec, 66, 0, 0, Tr_Ref)
     Rtrec = Pick.replace(Rtrec, 69, 0, 0, Int_Acc)
     Rtrec = Pick.replace(Rtrec, 70, 0, 0, CStr(PEN_AMT))
'$INSERT I.LOG.ADD "|RATES|":TR.INV.REF:'*':ASSESS.NO 350
     wterr = d3.d3_writestr(database, "RATES", Tr_Inv_Ref & "*" & ASSESS_NO, Rtrec)
     If suffix = "D" Then
        Use_Ref = Tr_Ref & "*" & ASSESS_NO
370:    If d3.d3_readstr(database, old_rec, "RATES", Use_Ref) <> 0 Then old_rec = ""
'$INSERT I.LOG.UPDATE "|RATES|":USE.REF 370 OLD.REC
        old_rec = Pick.replace(old_rec, 13, 0, 0, Abs(Pick.extractcur(Rtrec, 2, 0, 0)))
        wterr = d3.d3_writestr(database, "RATES", Use_Ref, old_rec)
     End If
     Tjrec = Pick.replace(Tjrec, 6, Pos, 0, Tr_Inv_Ref & " " & Rtrecnar)

End Sub

Public Sub SR300(logentry As String, Client_No As String, clrec() As String, ptab As String, cx As String, use_inv_type As String, use_inv_ref As String, USE_INV_AMT As Currency, CASH_DATE As Integer, USE_NARR, USE_CUST_REF, REC_CT, rb_given, IMM_DISC, USE_LEDG_DATE, auto_dates As String, UPDATE_POS As String, USE_UP As String, CData, PR_BANK, install, penalty_flg As String, vrectest As String)

Dim INT_METH As Integer, rebate_variance As Integer, tr_inv_type As String, UREF As String
Dim uamt As Currency, ACCRUING As Currency, tot_ii_ia As Currency, Tr_Inv_Date As Integer
Dim Council As String, temp As String, arrdate As Integer, penalty_cx As String, rules As String
Dim PENALTY_TAB As String, dcid_no As String, Rebate_Amt As Currency, cpx As Integer
Dim disc_given As String, disc_not_given As String, rebate_given As String, rrec As String
Dim posn As Integer, testpos As Integer, testrpos As Integer, RATESKEY As String
Dim bbb As String, lkforpx As String, Aaa As Integer, ansc As String, lkforcd As String
Dim uselkpx As String, rtab As String, urule As Integer, cnt As Integer
Dim tr_lkref As String, lkforref As String, refx As Integer, zeropos As Integer
Dim Prefix As String, Rtx As Integer, dozero As String, Code_List As String
Dim Oflow_Dates As String, I As Integer, rebate_gross As Currency
Dim Next_Ovfno As Integer, Disc_Amt As Currency, tr_amt As Currency
Dim rb_ref As String, totdisc As Currency, totrebate As Currency
Dim rref As String, First_Unpaid As Currency, tr_total_pay As Currency, tr_prepay As Currency
Dim cr_post As String, cr_post_amt As String, cr_post_date As String, cr_next_pos As Integer
Dim Tr_Next_Ovf As Integer, Ovf_No As Integer, Tr_Next_Pos As Integer
Dim save_accruing As Currency, save_tr_payment As Currency, Tr_Payment As Currency, CALC_DATE As Integer, save_penalty_cx As String
Dim tr_type As Integer, looping As Integer, save_ptab As String
Dim Cr_Ovfno As Integer, andthe_ovf As Integer, Cr_Cur_Bal As Currency, Pcode As Integer
Dim cr_no_txs As Integer, Cr_Tdate As String, Cr_Type As String, Cr_Tref As String, Cr_Tamt As String, Cr_Narr As String, cr_ledg_date As String
Dim Cr_Cust_Ref As String, Cr_Xref As String, Cr_Xamt As String, cr_xdte As String, Cr_Stdate As String, Cr_Tpaid As String
Dim tr_tpaid As Currency, Tr_Ref As String, TR_POS As Integer, Tr_Date As Integer
Dim tr_bal As Currency, Tr_Cash As String, disc_was_given As Integer, tjdrec As String
Dim utref As String, utcode As Integer, utdate As Integer, lkforperc As String
Dim dotest As Integer, Current As Currency, arrears As Currency
Dim updating As Integer, f_date As String, t_date As String, REFAMTS As String
Dim amt_left As Currency, uamt_left As Currency, RTKEY As String
Dim st_next_ovfno As Integer, pfx_amts As String, pfx_tamt As String
Dim udate As Integer, Pos As Integer, allow_defer As Currency
Dim pusebal As Currency, uperc As Currency, Ptx As Integer
Dim usebal As Currency, unalloc As Currency, TR_CUST_REF As String
Dim unam As Currency, paypenalty As Currency, paying As Currency, Pp As Integer
Dim pp_amt As Currency, pp_narr As String, pp_paid As Currency
Dim pp_ref As String, Pp_Type As String, Gg As Integer
Dim rebate_flg As Integer, tx As String, fupt As Long
Dim Ovf_Key As String, tx_write() As String, testing As Integer, ARRY As String
Dim cr_relation As Integer, dc As String, auto_oy As Integer, TR_INV_TR_POS As Integer, TR_INV_OVFNO As Integer
Dim Ddtes As String, LEDG_DATE As String, RTREF As String, suffix As String, DISC_FLG As Integer
Dim DISC_TR_BAL As Currency, NOTALLOC As Currency, SAVE_TR_BAL As Currency, REB_NOTALLOC As Currency
Dim Days_To_Pay As Currency, Days_Ct_Pay As Currency, CR_XPOST_DATE As String
Dim CR_XPOST As String, CR_XPOST_amt As String, tr_ldate As String, UPDATE_FIRST_UNPAID As Integer
Dim ICS As String, ias As String, CASH_INV As String, entered As String
Dim CASH_RCP As String, cash_amt As String, PP_DATE As String, Rcode As String, Tjrec As String
Dim PP_XPOST As String, PP_XPOST_AMT As String, PP_XPOST_DATE As String, tj_tno As String
Dim database As String, batch_key As String, Ans As String, wterr As Integer, TEST_DATE As Integer
Dim Tr_Narr As String, DKey As String, DCT As Integer, Ww As String, Ggg As Integer, PP_NAR As String
Dim DF_DATES As Currency, senior As Integer

DISC_FLG = 0
     
     database = Pick.extract(logentry, 2, 0, 0)
     
     temp = d3.execute_tcl(logentry, "WHO", "")
     tj_tno = Right("000" & Pick.field(temp, " ", 1), 3)
     
     If UBound(g_trans_info_array) = 0 Then
        g_trans_info_array(0) = "TRANS.INFO"
        posn = d3.d3_readmat(database, g_trans_info_array(), "DICT TRANS.J")
     End If

If vrectest = "?" Then
   vrectest = "": testing = 1: ARRY = ""
Else
   testing = 0
End If

rebate_flg = 0: ReDim tx_write(0)
rebate_variance = 10: 'mco 12apr99
temp = Mid$(g_trans_info_array(53), 14, 1)
If IsNumeric(temp) Then INT_METH = CInt(temp) Else INT_METH = 0
tr_inv_type = use_inv_type
UREF = use_inv_ref
uamt = USE_INV_AMT: ACCRUING = 0: tot_ii_ia = 0  'TJDREC = "": TJREC = ""
Tr_Inv_Date = CASH_DATE
'TR_NARR = USE_NARR
'TR_CUST_REF = USE_CUST_REF
'LEDG_DATE = USE_LEDG_DATE
updating = Pick.extractint(USE_UP, 1, 1, 0) ': OY_TDATE = pick.extract(USE_UP, 1, 2, 0)
'
'nz = g_trans_info_array(133): If nz = "1" Then OWNER = 37 Else OWNER = 35
cr_relation = Pick.extractint(cx, 23, 0, 0) + 1
dc = Pick.extract(g_trans_info_array(14), 1, cr_relation, 0)
If dc = "" Then dc = Pick.extract(g_trans_info_array(14), 1, 1, 0)
If Mid$(dc, 1, 1) = "_" Then dc = cr_relation - 1 & dc
Council = g_trans_info_array(92)
temp = Pick.extract(g_trans_info_array(59), 1, 3, 0)
If IsNumeric(temp) Then arrdate = CInt(temp) Else arrdate = 0
'PMGNT = pick.extract(TRANS_INFO, 97, 0, 0) + 0
Tr_Cash = "31"
'
auto_oy = 0
If updating Then auto_oy = 1
TR_INV_OVFNO = Pick.extractint(UPDATE_POS, 1, 1, 0)
TR_INV_TR_POS = Pick.extractint(UPDATE_POS, 1, 2, 0)
'ST_CX = CX '* IN CASE HAVE TO DO RECOVERY FOR PROCESS NO **
penalty_cx = cx 'let this be updated in sr300_inspen so penalty on instalments works
'
' IF AX=1 THEN ALLOCATION TO DEBITS DATED FROM VAL1 AUTO.DATES TO
' VAL2 AUTO.DATES. LEAVE BOTH NULL IF ALL FROM OLDEST REQUIRED.
' VAL3 CAN BE S/V LIST OF REFERENCES TO LK FOR IF REQUIRED
' VAL4 CAN BE PREFIX TO LK FOR IF REQUIRED
' VAL5 CAN BE CODE(S) TO LK FOR IF REQUIRED
' VAL6 CAN BE % OF AMOUNT OWING TO BE PAID IF REQUIRED
'    (e.g. "P90" IMPLIES PRO-RATA OF 90% (max) OF TRANS)
' VAL7 CAN BE AMOUNTS CORRESPONDING TO VAL3 (REFERENCES) TO BE CREDITED
' VAL8 IS NUMBER OF INSTALMENTS SELECTED
' VAL9 IS ADJUST POSITION OF INSTALMENT IN INSTALL.CTL ITEM
' VAL10 IS ALLOCATION CODE USED EG PI2 PP2 ETC
' IF UPDATING THEN ALLOCATING A PREVIOUSLY UNALLOCATED CREDIT (UPDATE.POS)
'    EITHER A CALL FROM TA670 OR ANDTHEREST SET BY OY PROCESS
'
'ALLOW_PREALLOC = pick.extract(TRANS_INFO, 69, 0, 0) + 0
Pcode = 0: rules = "": senior = 0
PENALTY_TAB = ""
If Council <> "" And clrec(28) = "1" Then
     Call SR300_TAB(database, rtab, PENALTY_TAB)
'     If HAS_TD_VALUE Then
'        Delete TD_VALUE_DATA, pick.extract(CLREC, OWNER, 1, 0)
'     End If
     If tr_inv_type <> 41 Then  ' ignore discounts
        If UBound(clrec) < 84 Then ReDim Preserve clrec(84) 'mc 16jan02
        Call SR1692(clrec(), "", Pcode, senior)
        'Call SR1693(CLIENT_DATA, clrec, pcode, ONAME, PENS, PMSG, "", "")
        dcid_no = clrec(50)
        If dcid_no = "" Then
           dcid_no = "1"
           If Pcode <> 0 Then dcid_no = "2"
        End If
        If d3.d3_readstr(database, rules, "DICT CASH", "@RULES" & dcid_no) = 1 Then rules = ""
    End If
End If

100 GoSub 7700
rb_given = 0: rb_ref = "": disc_given = "": rebate_given = "": totdisc = 0: totrebate = 0: Rebate_Amt = 0: disc_not_given = ""
Disc_Amt = 0
rref = ""
temp = Pick.extract(cx, 53, 0, 0)
If IsNumeric(temp) Then First_Unpaid = CCur(temp) Else First_Unpaid = 0
cr_post = ""
cr_post_amt = ""
cr_post_date = ""
'DAYS_TO_PAY = 0
'DAYS_CT_PAY = 0
cr_next_pos = 0
If updating Then cr_next_pos = TR_INV_TR_POS: andthe_ovf = TR_INV_OVFNO
102 tr_total_pay = 0
tr_prepay = 0
'CR_XPOST = "": CR_XPOST_AMT = "": CR_XPOST_DATE = ""
Tr_Next_Ovf = Ovf_No
'CASH_INV = "": CASH_RCP = "": CASH_AMT = ""
'
'TR_DESC = TRIMM(pick.extract(TRANS_INFO, 3, tr_inv_type, 0))
'
' find trans
'
   Tr_Next_Pos = 0
25210 GoTo 259
'
' DISPLAY FOUND TRANSACTION
'
25230:
 temp = Pick.extract(Cr_Tdate, 1, TR_POS, 0)
 If IsNumeric(temp) Then Tr_Date = CInt(temp) Else Tr_Date = 0
 'TR_LDATE = pick.extract(cr_ledg_date, 1, TR_POS, 0)
 'TR_STDATE = pick.extract(cr_stdate, 1, TR_POS, 0)
 Tr_Ref = Pick.extract(Cr_Tref, 1, TR_POS, 0)
 'TR_CU_REF = pick.extract(cr_cust_ref, 1, TR_POS, 0)
 tr_type = Pick.extractint(Cr_Type, 1, TR_POS, 0)
 temp = Pick.extract(Cr_Tamt, 1, TR_POS, 0)
 If IsNumeric(temp) Then tr_amt = CCur(temp) Else tr_amt = 0
 temp = Pick.extract(Cr_Tpaid, 1, TR_POS, 0)
 If IsNumeric(temp) Then tr_tpaid = CCur(temp) Else tr_tpaid = 0
 tr_bal = tr_amt - tr_tpaid
 If Council <> "" And tr_type >= 50 And tr_inv_type = Tr_Cash Then
    utref = Tr_Ref: utcode = tr_type: utdate = Tr_Date: GoSub 8000
 End If
 'T_NARR = pick.extract(cr_narr, 1, TR_POS, 0)
 'DREF = ""
 'IF TR_CU_REF = "" THEN DREF=TR_REF & DREF ELSE DREF=TR_REF & DREF "L<>11" & TR_CU_REF
 'AUTO_PREF = "": Return
 Return
'
' END OF DISPLAY SUBROUTINE
'
'
' s/r:  record transactions credited
'
25244:
      If PENALTY_TAB <> "" And INT_METH = 0 Then
'        If PROG <> "TA1656" Then
'         If penalty_flg = "" Then
            save_accruing = ACCRUING: save_ptab = ptab: save_tr_payment = Tr_Payment: save_penalty_cx = penalty_cx
            CALC_DATE = Tr_Inv_Date: looping = 0
            
25245   Call SR300_INSPEN(database, ptab, Client_No, tr_type, Tr_Ref, Tr_Date, arrdate, Pcode, senior, penalty_cx, Tr_Payment, UREF, PENALTY_TAB, INT_METH, clrec(), CStr(Tr_Inv_Date), ACCRUING, CALC_DATE, 0)
            If looping Then
               If Abs(tr_total_pay + Tr_Payment + ACCRUING - uamt) < 5 Then
                  Tr_Payment = Tr_Payment - (tr_total_pay + Tr_Payment + ACCRUING - uamt)
                  If Tr_Payment <= 0 Then Tr_Payment = save_tr_payment
               Else
                  Tr_Payment = Tr_Payment - (tr_total_pay + Tr_Payment + ACCRUING - uamt)
                  ACCRUING = save_accruing: ptab = save_ptab: penalty_cx = save_penalty_cx 'MC 28APR99
                  GoTo 25245
               End If
            Else
               If tr_total_pay + Tr_Payment + ACCRUING > uamt Then
                  Tr_Payment = Tr_Payment - (tr_total_pay + Tr_Payment + ACCRUING - uamt)
                  If Tr_Payment <= 0 Then
                     Tr_Payment = save_tr_payment
                  Else
                     ACCRUING = save_accruing: ptab = save_ptab: penalty_cx = save_penalty_cx ' MC28APR99
                     looping = 1
                     save_tr_payment = Tr_Payment
                     GoTo 25245
                  End If
               End If
            End If
            If ACCRUING <> 0 Then
               If dotest Then vrectest = Pick.replace(vrectest, 6, 0, 0, CStr(ACCRUING))
            End If
         End If
'        End If
'      End If
'   If ovf_no Then GoSub 7600          ' LOG OVERFLOW B4_UPDATE *
   Cr_Tpaid = Pick.replace(Cr_Tpaid, 1, TR_POS, 0, tr_tpaid + Tr_Payment)
   testrpos = 0
   disc_was_given = 0 'MCO 14APR99
   If Disc_Amt = 0 Then disc_was_given = 1 'MCO 14APR99
   If Pick.extract(CStr(IMM_DISC), 1, 1, 0) Then
      If Disc_Amt <> 0 And IMM_DISC <> "2" Then
         posn = Pick.locate(Tr_Ref, disc_given, 1, 1, 0, testpos, "")
         If posn = 0 Then
 ' 2 means paying last instalment, so get rebate but no discounts
            temp = Pick.extract(Cr_Tpaid, 1, TR_POS, 0)
            If IsNumeric(temp) Then temp = CStr(CCur(temp) + Disc_Amt) Else temp = CStr(Disc_Amt)
            Cr_Tpaid = Pick.replace(Cr_Tpaid, 1, TR_POS, 0, temp)
            disc_given = Pick.insert(disc_given, 1, -1, 0, Tr_Ref)
            disc_given = Pick.insert(disc_given, 2, -1, 0, CStr(Disc_Amt))
            disc_given = Pick.insert(disc_given, 3, -1, 0, CStr(tr_amt))
            disc_given = Pick.insert(disc_given, 4, -1, 0, CStr(Tr_Inv_Date))
            disc_was_given = 2 'MCO 14APR99
         End If
      End If
   End If 'mco25mar99
   If disc_was_given = 0 Then
      posn = Pick.locate(Tr_Ref, disc_not_given, 1, 1, 0, testpos, "")
      If posn = 0 Then
         disc_not_given = Pick.insert(disc_not_given, 1, -1, 0, Tr_Ref)
         disc_not_given = Pick.insert(disc_not_given, 2, -1, 0, CStr(Disc_Amt))
         disc_not_given = Pick.insert(disc_not_given, 3, -1, 0, CStr(tr_amt))
         disc_not_given = Pick.insert(disc_not_given, 4, -1, 0, CStr(Tr_Inv_Date))
         disc_not_given = Pick.insert(disc_not_given, 5, -1, 0, CStr(Tr_Payment))
         disc_not_given = Pick.insert(disc_not_given, 6, -1, 0, UREF)
         disc_not_given = Pick.insert(disc_not_given, 7, -1, 0, CStr(USE_INV_AMT))
      End If
   End If
   If Rebate_Amt <> 0 And disc_was_given Then
    If Pick.extract(CStr(IMM_DISC), 1, 2, 0) <> "0" Then
      posn = Pick.locate(Tr_Ref, rebate_given, 1, 1, 0, testrpos, "")
      If posn = 0 Then
         temp = Pick.extract(Cr_Tpaid, 1, TR_POS, 0)
         If IsNumeric(temp) Then temp = (CCur(temp) + Rebate_Amt) Else temp = CStr(Rebate_Amt)
         Cr_Tpaid = Pick.replace(Cr_Tpaid, 1, TR_POS, 0, temp)
         rebate_given = Pick.insert(rebate_given, 1, -1, 0, Tr_Ref)
         rebate_given = Pick.insert(rebate_given, 2, -1, 0, CStr(Rebate_Amt))
         rebate_given = Pick.insert(rebate_given, 3, -1, 0, CStr(tr_amt))
         rebate_given = Pick.insert(rebate_given, 4, -1, 0, CStr(Tr_Inv_Date))
         rebate_given = Pick.insert(rebate_given, 5, -1, 0, CStr(Disc_Amt))
      End If
    End If 'MCO 14APR99
   End If

         Ddtes = Tr_Inv_Date
         If LEDG_DATE <> "" And LEDG_DATE <> Ddtes Then Ddtes = Ddtes & "/" & LEDG_DATE
         'If ICD Then
         '   If pick.locate(tr_inv_type, CDCDS, 1, 1, 0, XD, "") = 0 Then XD = 0
         '   If XD Then
         '      XD = pick.ccount(Tr_Narr, svm)
         '      Ddtes = Ddtes & "*" & pick.extract(Tr_Narr, 1, 1, XD + 1)
         '   End If
         'End If
         If Tr_Payment <> 0 Then
            If rebate_flg Then
               RTREF = UREF:  suffix = "R": GoSub 8500
               Cr_Xref = Pick.insert(Cr_Xref, 1, TR_POS, -1, RTREF)
            Else
               If DISC_FLG Then
                  RTREF = UREF:  suffix = "D":  GoSub 8500
                  Cr_Xref = Pick.insert(Cr_Xref, 1, TR_POS, -1, RTREF)
               Else
                  Cr_Xref = Pick.insert(Cr_Xref, 1, TR_POS, -1, UREF)
               End If
            End If
            Cr_Xamt = Pick.insert(Cr_Xamt, 1, TR_POS, -1, CStr(Tr_Payment))
            cr_xdte = Pick.insert(cr_xdte, 1, TR_POS, -1, Ddtes)
         End If
         If disc_was_given = 2 Then 'discount was given
            RTREF = Tr_Ref: suffix = "D":  GoSub 8500
            If DISC_TR_BAL <> 0 Then
               Cr_Xref = Pick.insert(Cr_Xref, 1, TR_POS, -1, RTREF)
               If DISC_TR_BAL < Disc_Amt Then
                  Cr_Xamt = Pick.insert(Cr_Xamt, 1, TR_POS, -1, CStr(DISC_TR_BAL))
                  NOTALLOC = NOTALLOC + Disc_Amt - DISC_TR_BAL
               Else
                  Cr_Xamt = Pick.insert(Cr_Xamt, 1, TR_POS, -1, CStr(Disc_Amt))
               End If
               If updating Then cr_xdte = Pick.insert(cr_xdte, 1, TR_POS, -1, Pick.ICONV(Format$(Now, "DD MMM YY"), "D2")) Else cr_xdte = Pick.insert(cr_xdte, 1, TR_POS, -1, Ddtes)
            End If
            If DISC_TR_BAL = 0 Then NOTALLOC = NOTALLOC + Disc_Amt
         End If
         If testrpos Then 'rebate was given
            RTREF = Tr_Ref: suffix = "R": GoSub 8500
            If SAVE_TR_BAL <> 0 Then
               Cr_Xref = Pick.insert(Cr_Xref, 1, TR_POS, -1, RTREF)
               If SAVE_TR_BAL < Rebate_Amt Then
                  Cr_Xamt = Pick.insert(Cr_Xamt, 1, TR_POS, -1, CStr(SAVE_TR_BAL))
                  REB_NOTALLOC = REB_NOTALLOC + Rebate_Amt - SAVE_TR_BAL
               Else
                  Cr_Xamt = Pick.insert(Cr_Xamt, 1, TR_POS, -1, CStr(Rebate_Amt))
               End If
               If updating Then cr_xdte = Pick.insert(cr_xdte, 1, TR_POS, -1, Pick.ICONV(Format$(Now, "DD MMM YY"), "D2")) Else cr_xdte = Pick.insert(cr_xdte, 1, TR_POS, -1, Ddtes)
            End If
            If SAVE_TR_BAL = 0 Then REB_NOTALLOC = REB_NOTALLOC + Rebate_Amt
         End If

   If (updating = 0 Or updating = 2) And Tr_Payment <> 0 Then
     If Pick.extract(cr_post, 1, 0, 0) = "" Then cpx = 1 Else cpx = Pick.ccount(Pick.extract(cr_post, 1, 0, 0), Chr(252), 0) + 2
     cr_post = Pick.replace(cr_post, 1, 1, cpx, Tr_Ref)
     cr_post_amt = Pick.replace(cr_post_amt, 1, 1, cpx, CStr(Tr_Payment))
     cr_post_date = Pick.replace(cr_post_date, 1, 1, cpx, CStr(Tr_Date))
     Days_To_Pay = Days_To_Pay + Tr_Inv_Date - Tr_Date
     Days_Ct_Pay = Days_Ct_Pay + 1
   End If
   If Tr_Payment <> 0 Then
      CR_XPOST = Pick.insert(CR_XPOST, 1, 1, -1, Tr_Ref)
      CR_XPOST_amt = Pick.insert(CR_XPOST_amt, 1, 1, -1, CStr(Tr_Payment))
      Ddtes = Tr_Date
'      If tr_ldate <> "" And tr_ldate <> Tr_Date Then Ddtes = Ddtes & "/" & tr_ldate
      If tr_ldate <> "" Then
        If CInt(tr_ldate) <> Tr_Date Then Ddtes = Ddtes & "/" & tr_ldate
      End If
      CR_XPOST_DATE = Pick.insert(CR_XPOST_DATE, 1, 1, -1, Ddtes)
   End If
   If Tr_Date <= First_Unpaid Then UPDATE_FIRST_UNPAID = 1
   ICS = "": ias = ""
      GoTo 25247
25246:
   CASH_INV = Pick.insert(CASH_INV, 1, -1, 0, entered)
   CASH_RCP = Pick.insert(CASH_RCP, 1, -1, 0, UREF)
   cash_amt = Pick.insert(cash_amt, 1, -1, 0, CStr(Tr_Payment))
   If updating = 0 Or updating = 2 Then
      If Pick.extract(cr_post, 1, 0, 0) = "" Then cpx = 1 Else cpx = Pick.dcount(Pick.extract(cr_post, 1, 0, 0), Chr(252)) + 1
      cr_post = Pick.replace(cr_post, 1, 1, cpx, "PRE-" & entered)
      cr_post_amt = Pick.replace(cr_post_amt, 1, 1, cpx, CStr(Tr_Payment))
      cr_post_date = Pick.replace(cr_post_date, 1, 1, cpx, CStr(Tr_Inv_Date))
   End If
   tr_prepay = tr_prepay + Tr_Payment
   ICS = "": ias = ""
25247 tr_total_pay = tr_total_pay + Tr_Payment
      Return
'
' END OF SUBROUTINE TO RECORD TXS CREDITED
'
'255:
'    If tr_total_pay + ACCRUING >= uamt Then Return
'    If PRE_ALLOC = 1 Then Return
'    GoTo 25225 '*MAYBE MORE WITH SAME REF**
'
' credit all transactions - perhaps for date range
'
259 dozero = ""
      f_date = Pick.extract(auto_dates, 1, 1, 0)
      t_date = Pick.extract(auto_dates, 1, 2, 0)
      lkforref = Pick.extract(auto_dates, 1, 3, 0): lkforcd = Pick.extract(auto_dates, 1, 5, 0): lkforpx = Pick.extract(auto_dates, 1, 4, 0): urule = 0: lkforperc = Pick.extract(auto_dates, 1, 6, 0): REFAMTS = Pick.extract(auto_dates, 1, 7, 0)
      amt_left = uamt - tr_total_pay - ACCRUING: uamt_left = amt_left
      If f_date = "RULE" Then
aa2598:
         urule = urule + 1: uamt_left = amt_left
         If Pick.extract(rules, urule, 0, 0) = "" Or Pick.extract(rules, urule, 0, 0) = String(Len(Pick.extract(rules, urule, 0, 0)), Chr(253)) Then GoTo 298
         f_date = Pick.extract(rules, urule, 1, 0): t_date = Pick.extract(rules, urule, 2, 0): lkforref = Pick.extract(rules, urule, 3, 0): lkforpx = Pick.extract(rules, urule, 4, 0): lkforcd = Pick.extract(rules, urule, 5, 0): lkforperc = Pick.extract(rules, urule, 6, 0): REFAMTS = Pick.extract(rules, urule, 7, 0)
         If f_date = "YR" Then f_date = CStr(arrdate + 1)
         If t_date = "YR" Then t_date = CStr(arrdate)
      End If

      If IsNumeric(f_date) Then
         If CInt(f_date) < First_Unpaid Then f_date = CStr(First_Unpaid)
      End If
      If f_date = "" Then Next_Ovfno = 1: GoTo 260
      If Cr_Ovfno = 0 Then Next_Ovfno = 0: GoTo 260
      posn = Pick.locate(CStr(f_date), Oflow_Dates, 1, 1, 0, I, "DR")
      If posn = 0 Then
        Next_Ovfno = Cr_Ovfno - I + 2
        If Next_Ovfno = 0 Then Next_Ovfno = 1
        GoTo 260
      End If
' overflow found - get previous anyway (just in case)
2599  If f_date <> Pick.extract(Oflow_Dates, 1, I + 1, 0) Then
         Next_Ovfno = Cr_Ovfno - I + 1
         If Next_Ovfno = 0 Then Next_Ovfno = 1
         GoTo 260
      End If
      I = I + 1
      GoTo 2599
'
260 If Mid$(lkforperc, 1, 1) <> "P" Then GoTo 270
' total by prefix so can calc. pro-rata percentages
    Call Pick.sr_change(lkforpx, ",", Chr(253))
    st_next_ovfno = Next_Ovfno: pfx_amts = "": pfx_tamt = 0: uselkpx = ""
263 GoSub 7100: TR_POS = 0
    For TR_POS = TR_POS + 1 To cr_no_txs
     Tr_Date = Pick.extract(Cr_Tdate, 1, TR_POS, 0)
 '    TR_STDATE = pick.EXTRACT(cr_stdate, 1, tr_pos, 0)
     tr_lkref = Pick.extract(Cr_Tref, 1, TR_POS, 0)
     udate = Tr_Date
     If IsNumeric(f_date) Then
       If udate < CInt(f_date) Then GoTo 266
     End If
     If lkforpx <> "" Then
       bbb = Mid$(tr_lkref, 1, Len(Pick.extract(lkforpx, 1, 1, 0)))
       posn = Pick.locate(bbb, lkforpx, 1, 1, 0, Aaa, "")
       If posn = 0 Then GoTo 266
     End If
     ansc = Pick.extract(Cr_Type, 1, TR_POS, 0)
     If ansc < 50 Then GoTo 266
     If lkforcd <> "" Then
       posn = Pick.locate(ansc, lkforcd, 1, 1, 1, Pos, "")
       If posn = 0 Then GoTo 266
     End If
     If IsNumeric(t_date) Then
       If udate > CInt(t_date) Then
         GoTo 269
       End If
     End If
     ansc = Pick.extract(Cr_Tamt, 1, TR_POS, 0)
     posn = Pick.locate(bbb, uselkpx, 1, 1, 0, Aaa, "")
     If posn = 0 Then
       uselkpx = Pick.insert(uselkpx, 1, Aaa, 0, bbb)
       pfx_amts = Pick.insert(pfx_amts, 1, Aaa, 0, 0)
     End If
     pfx_amts = Pick.replace(pfx_amts, 1, Aaa, 0, Pick.extract(pfx_amts, 1, Aaa, 0) + ansc)
     pfx_tamt = pfx_tamt + ansc
266 Next TR_POS
    If Ovf_No Then Next_Ovfno = Ovf_No + 1: GoTo 263
269 Next_Ovfno = st_next_ovfno
'
270 GoSub 7100: TR_POS = 0
    For TR_POS = TR_POS + 1 To cr_no_txs
     Tr_Date = Pick.extract(Cr_Tdate, 1, TR_POS, 0)
'     TR_LDATE = pick.EXTRACT(cr_ledg_date, 1, tr_pos, 0)
'     TR_STDATE = pick.EXTRACT(cr_stdate, 1, tr_pos, 0)
     tr_lkref = Pick.extract(Cr_Tref, 1, TR_POS, 0)
     temp = Pick.extract(Cr_Tamt, 1, TR_POS, 0)
     If IsNumeric(temp) Then tr_bal = CCur(temp) Else tr_bal = 0
     temp = Pick.extract(Cr_Tpaid, 1, TR_POS, 0)
     If IsNumeric(temp) Then tr_bal = tr_bal - CCur(temp)
     utcode = Pick.extractint(Cr_Type, 1, TR_POS, 0)
     udate = Tr_Date
     If f_date <> "" Then
       If udate < f_date Then GoTo 290
     End If
     refx = 0
     If lkforref <> "" Then
       posn = Pick.locate(tr_lkref, lkforref, 1, 1, 1, refx, "")
       If posn = 0 Then GoTo 290
     End If
     If lkforpx <> "" Then
        bbb = Mid$(tr_lkref, 1, Len(Pick.extract(lkforpx, 1, 1, 0)))
        posn = Pick.locate(bbb, lkforpx, 1, 1, 0, Aaa, "")
        If posn = 0 Then GoTo 290
        If Mid$(lkforperc, 1, 1) = "P" Then
          posn = Pick.locate(bbb, uselkpx, 1, 1, 0, Aaa, "")
          If posn = 0 Then GoTo 290
        End If
     End If
     If lkforcd <> "" Then
       ansc = Pick.extract(Cr_Type, 1, TR_POS, 0)
       posn = Pick.locate(ansc, lkforcd, 1, 1, 0, Pos, "")
       If posn = 0 Then GoTo 290
     End If
     If t_date <> "" Then
       If udate > t_date Then
         GoTo 297
       End If
     End If
     rebate_gross = 0: dotest = 0: Current = 0: arrears = 0
     posn = Pick.locate(tr_lkref, vrectest, 1, 1, 0, zeropos, "")
     If posn = 0 Then
        dotest = 1
        vrectest = Pick.replace(vrectest, 1, zeropos, 0, tr_lkref)
        If Tr_Date >= arrdate Then
           vrectest = Pick.replace(vrectest, 2, 0, 0, CStr(Pick.extractcur(vrectest, 2, 0, 0) + tr_bal))
           Current = Pick.extract(Cr_Tamt, 1, TR_POS, 0)
        Else
           vrectest = Pick.replace(vrectest, 3, 0, 0, CStr(Pick.extractcur(vrectest, 3, 0, 0) + tr_bal))
           arrears = tr_bal
        End If
     End If
     If Council <> "" And utcode >= 50 And tr_inv_type = Tr_Cash Then
        utref = tr_lkref: utdate = Tr_Date: GoSub 8000
        If dotest Then
           If allow_defer Then
              vrectest = Pick.replace(vrectest, 4, 0, 0, CStr(Pick.extractcur(vrectest, 4, 0, 0) + allow_defer))
           End If
           vrectest = Pick.replace(vrectest, 5, 0, 0, CStr(Pick.extractcur(vrectest, 5, 0, 0) + Rebate_Amt + Disc_Amt))
           Prefix = Mid$(tr_lkref, 1, 2)
           Code_List = Pick.extract(vrectest, 20, 1, 0)
           posn = Pick.locate(Prefix, vrectest, 20, 1, 1, Rtx, "")
           If posn = 0 Then
              Rtx = Pick.dcount(Pick.extract(vrectest, 20, 1, 0), Chr(252))
              vrectest = Pick.replace(vrectest, 20, 1, Rtx + 1, Prefix)
           End If
           If Current Then Current = Current - rebate_gross
           temp = Pick.extract(vrectest, 21, 1, Rtx)
           If IsNumeric(temp) Then temp = CStr(CCur(temp) + Current) Else temp = CStr(Current)
           vrectest = Pick.replace(vrectest, 21, 1, Rtx, temp)
           temp = Pick.extract(vrectest, 22, 1, Rtx)
           If IsNumeric(temp) Then temp = CStr(CCur(temp) + arrears) Else temp = CStr(arrears)
           vrectest = Pick.replace(vrectest, 22, 1, Rtx, temp)
           temp = Pick.extract(vrectest, 23, 1, Rtx)
           If IsNumeric(temp) Then temp = CStr(CCur(temp) + allow_defer) Else temp = CStr(allow_defer)
           vrectest = Pick.replace(vrectest, 23, 1, Rtx, temp)
        End If
     End If
     If tr_bal < 0 Then GoTo 290
     posn = Pick.locate(tr_lkref, dozero, 1, 0, 0, zeropos, "")
     If posn = 0 Then zeropos = 0
     If zeropos <> 0 And tr_bal = 0 Then GoTo 290   'mco 12apr99
     dozero = Pick.insert(dozero, -1, 0, 0, tr_lkref)
     If lkforperc <> "" Then
       If Mid$(lkforperc, 1, 1) = "P" Then
          If Pick.extract(uselkpx, 1, Aaa + 1, 0) = "" Then
             pusebal = amt_left
          Else
             If pfx_tamt = 0 Then uperc = 0 Else uperc = Pick.extractcur(pfx_amts, 1, Aaa, 0) * 100 / pfx_tamt
             pusebal = uamt_left / 100 * uperc
          End If
          uperc = Mid$(lkforperc, 2, 99)
          If IsNumeric(temp) Then uperc = CCur(temp) Else uperc = 100
          If uperc = 0 Then uperc = 100
          pusebal = Int(pusebal + 0.5)
       Else
          If refx <> 0 Then
             temp = Pick.extract(lkforperc, 1, 1, refx)
             If Not (IsNumeric(temp)) Then temp = ""
             If temp = "" Then uperc = Pick.extractcur(lkforperc, 1, 1, 1) Else uperc = CCur(temp)
          Else
             uperc = CCur(lkforperc)
          End If
       End If
       temp = Pick.extract(Cr_Tamt, 1, TR_POS, 0)
       If IsNumeric(temp) Then usebal = CCur(temp) Else usebal = 0
       usebal = (usebal - rebate_gross) / 100 * uperc
       usebal = Int(usebal + 0.5)
       If refx = 0 Then
          temp = Pick.extract(Cr_Tamt, 1, TR_POS, 0)
          If IsNumeric(temp) Then usebal = usebal - (CCur(temp) - tr_bal) Else usebal = usebal - (0 - tr_bal)
       End If
       If usebal <= 0 Then GoTo 290 ' USEBAL=0
       If Mid$(lkforperc, 1, 1) = "P" Then
          If usebal > pusebal Then usebal = pusebal
       End If
       If amt_left - usebal < 5 Then usebal = amt_left
       If usebal > tr_bal Then usebal = tr_bal
      Else
       If lkforref <> "" Then
         usebal = Pick.extract(REFAMTS, 1, 1, refx)
         If usebal > tr_bal Or usebal = "" Then usebal = tr_bal
       Else
         usebal = tr_bal
       End If
      End If
      If amt_left <= usebal Then
       Tr_Payment = amt_left
       GoSub 25230
       If Tr_Payment < tr_bal And Rebate_Amt <> 0 Then
          If Tr_Payment < tr_bal - rebate_variance Then
             Rebate_Amt = 0
          Else
             Rebate_Amt = Rebate_Amt + (tr_bal - Tr_Payment)
          End If
       End If
       GoSub 25244
'          If AUTO_OY Then ANDTHEREST = 1: GoTo 502
         GoTo 501
      End If
      Tr_Payment = usebal
      GoSub 25230
      amt_left = amt_left + ACCRUING 'will be taking off new amount after gosub
      GoSub 25244
      amt_left = amt_left - Tr_Payment - ACCRUING
290 Next TR_POS
    If Ovf_No Then Next_Ovfno = Ovf_No + 1: GoTo 270
297 If urule Then GoTo aa2598
298:
'      If AUTO_OY Then ANDTHEREST = 1: GoTo 502
      GoTo 501
'
' END OF INPUT
'
'510   Call SRIP(0, Prow, PM, Ans, IPCL, "", "", "", "")
'      If Ans = "Y" Then
'         If AUTO_OY Then ANDTHEREST = 1: GoTo 502
'         If unam <> 0 And Council And testing = 0 Then
'            Call PICKWT(DISCOUNT_DATA, "unalloc*" & CLIENT_NO, 3, "", 0)
'         End If
'         GoTo 501
'      End If
'      IF ANS="OY" AND UPDATING<>2 THEN ANDTHEREST=1: GOTO 502
501:
'       ANDTHEREST = 0
502  tr_total_pay = tr_total_pay - tr_prepay
'
     unalloc = uamt - tr_total_pay - ACCRUING
' INSTALMENTS !!!
'     If pick.EXTRACT(auto_dates, 1, 8, 0) <> "" Then
'        If INSTALL <> "" And CLREC(28) = "1" Then
'           Call SR300_INS(INSTALL, cr_post, cr_post_amt, tr_inv_date, UREF, CX, CLIENT_NO, auto_dates)
'        End If
'     End If
' FORCE TEST FOR PENALTY ON EACH ASSESSMENT.
    unam = uamt - tr_total_pay
    paypenalty = 0
    If INT_METH = 0 Then
   
       If ACCRUING <> 0 And ptab <> "" Then
    
          paying = ACCRUING
          If unam < paying Then
             temp = Pick.extract(ptab, 2, Pick.dcount(ptab, Chr(253)), 0)
             If IsNumeric(temp) Then temp = CStr(CCur(temp) + unam - paying) Else temp = CStr(unam - paying)
             ptab = Pick.replace(ptab, 2, Pick.dcount(ptab, Chr(253)), 0, temp)  'rounding errors
             paying = unam
          End If
          paypenalty = paying
          GoSub 555: Pp = I - 1
          For Ptx = 1 To Pick.dcount(ptab, Chr(253))
             'rcode = pick.EXTRACT(ptab, 1, ptx, 0)
             temp = Pick.extract(ptab, 2, Ptx, 0)
             If IsNumeric(temp) Then pp_amt = CCur(temp) Else pp_amt = 0
             If pp_amt > 0 Then
                pp_narr = Pick.extract(ptab, 3, Ptx, 0)
                If updating Then
                   PP_DATE = Pick.ICONV(Format$(Now, "DD MMM YY"), "D2"): Pp = Pick.dcount(Pick.extract(Cr_Tdate, 1, 0, 0), Chr(253))
                Else
                   PP_DATE = Tr_Inv_Date
                End If
                If testing Then
                   pp_ref = "?": Pp_Type = "76"
                Else
                   Call SR300_RATES(database, clrec(), Pcode, Rcode, Client_No, pp_amt, CStr(Tr_Inv_Date), PENALTY_TAB, pp_narr, pp_ref, Tjrec, "P", Pp_Type, "", "", "", UREF)
                End If
                pp_paid = pp_amt
                If pp_paid > paying Then pp_paid = paying
                paying = paying - pp_paid
                PP_XPOST = "": PP_XPOST_AMT = "": PP_XPOST_DATE = ""
                If pp_paid <> 0 Then
                   PP_XPOST = UREF: PP_XPOST_AMT = pp_paid: PP_XPOST_DATE = Tr_Inv_Date
                   CR_XPOST = Pick.insert(CR_XPOST, 1, 1, -1, pp_ref): CR_XPOST_amt = Pick.insert(CR_XPOST_amt, 1, 1, -1, CStr(pp_paid)): CR_XPOST_DATE = Pick.insert(CR_XPOST_DATE, 1, 1, -1, CStr(Tr_Inv_Date))
                End If
                Pp = Pp + 1: GoSub 577
             End If
          Next Ptx
          If Tjrec <> "" And testing = 0 Then
             Tjrec = Pick.insert(Tjrec, 1, -1, 0, 76): Tjrec = Pick.insert(Tjrec, 3, -1, 0, dc): Tjrec = Pick.insert(Tjrec, 4, -1, 0, CStr(ACCRUING)): Tjrec = Pick.insert(Tjrec, 5, -1, 0, Client_No)
             If Pick.dcount(Pick.extract(Tjrec, 1, 0, 0), Chr(253)) <> 2 Then Tjrec = Pick.insert(Tjrec, 6, -1, 0, "Penalty") 'if only one use nicer narrative of first one)
             Tjrec = Pick.replace(Tjrec, 7, 0, 0, CStr(CASH_DATE))
             
             batch_key = Time() & tj_tno
530          If d3.d3_readstr(database, Ans, "TRANS.J", batch_key) <> 0 Then GoTo 537
             'Release TRANS_J_DATA, BATCH_KEY
             batch_key = Time() & tj_tno & Rnd(9)
             GoTo 530
537:
'$INSERT I.LOG.ADD '|TRANS.J|':BATCH.KEY 530
             wterr = d3.d3_writestr(database, "TRANS.J", batch_key, Tjrec)
             Tjrec = ""
          End If
       End If
    End If
' FOR UPDATING UPDATE TXS ELSE GET RECORD FOR INSERTION OF TXSACTION
560   If updating Then
         Next_Ovfno = TR_INV_OVFNO
         GoSub 7100
         'If Ovf_No Then GoSub 7600  '* B4_LOG OVERFLOW **
         If Pick.extract(Cr_Tref, 1, TR_INV_TR_POS, 0) = UREF Then
            Cr_Tpaid = Pick.replace(Cr_Tpaid, 1, TR_INV_TR_POS, 0, Pick.extractcur(Cr_Tpaid, 1, TR_INV_TR_POS, 0) - tr_total_pay - paypenalty)
            If CR_XPOST <> "" Then
               Cr_Xref = Pick.insert(Cr_Xref, 1, TR_INV_TR_POS, -1, CR_XPOST)
               Cr_Xamt = Pick.insert(Cr_Xamt, 1, TR_INV_TR_POS, -1, CR_XPOST_amt)
               cr_xdte = Pick.insert(cr_xdte, 1, TR_INV_TR_POS, -1, CR_XPOST_DATE)
            End If
         Else
            'GoTo 9200
         End If
      End If
      GoTo 572
'
' Routine to get setup to insert transaction
'
555   If Cr_Ovfno = 0 Then
         Next_Ovfno = 1
      Else
         If Pick.locate(CStr(TEST_DATE), Oflow_Dates, 1, 1, 0, I, "DR") = 0 Then
         End If
         Next_Ovfno = Cr_Ovfno - I + 2 'WILL BE CR_OVFNO+1 FOR MASTER_ OK
         If Next_Ovfno = 0 Then          ' 0 MEANS BEFORE FIRST TXSACTION *
            Next_Ovfno = 1
            cx = Pick.replace(cx, 28, Cr_Ovfno + 1, 0, CStr(TEST_DATE))
         End If
         If Next_Ovfno > Cr_Ovfno Then Next_Ovfno = Cr_Ovfno
      End If
      GoSub 7100
      For I = 1 To cr_no_txs
         If TEST_DATE < Pick.extractint(Cr_Tdate, 1, I, 0) Then GoTo 570
      Next I
570   'If Ovf_No Then GoSub 7600 'ELSE
      Return

'
' end of routine toget setup for inserting transaction
'
572 If updating Then
       TEST_DATE = CInt(Pick.ICONV(Format$(Now, "DD MMM YY"), "D2")): GoSub 555: Pp = I - 1: GoTo 575
    Else
       TEST_DATE = Tr_Inv_Date: GoSub 555: Pp = I
    End If
    pp_ref = UREF: Pp_Type = tr_inv_type
    pp_amt = -uamt
    pp_paid = -tr_total_pay - paypenalty
    If pp_paid < pp_amt Then pp_paid = pp_amt 'not enough cash to pay all penalty accrued
    PP_XPOST = CR_XPOST: PP_XPOST_AMT = CR_XPOST_amt: pp_narr = Tr_Narr: PP_XPOST_DATE = CR_XPOST_DATE
    GoSub 577
'
575 If rebate_given <> "" Then
       totrebate = 0
       For Gg = 1 To Pick.dcount(Pick.extract(rebate_given, 1, 0, 0), Chr(253))
          Rcode = Mid$(Pick.extract(rebate_given, 1, Gg, 0), 1, 2)
          pp_amt = Pick.extractcur(rebate_given, 2, Gg, 0)
          rref = Pick.extract(rebate_given, 1, Gg, 0)
          totrebate = totrebate + pp_amt
          pp_narr = "Rebate given on " & Pick.oconv(Pick.extract(rebate_given, 3, Gg, 0), "MD2")
          If Pick.extractcur(rebate_given, 5, Gg, 0) <> 0 Then pp_narr = pp_narr & " less discount of " & Pick.oconv(Pick.extract(rebate_given, 5, Gg, 0), "MD2")
          If updating Then PP_DATE = Pick.ICONV(Format$(Now, "DD MMM YY"), "D2") Else PP_DATE = Tr_Inv_Date
          If testing Then
             pp_ref = "?": Pp_Type = 37
          Else
             Call SR300_RATES(database, clrec(), Pcode, Rcode, Client_No, pp_amt, CStr(Tr_Inv_Date), PENALTY_TAB, pp_narr, pp_ref, tjdrec, "R", Pp_Type, Pick.extractcur(rebate_given, 3, Gg, 0), Pick.extractcur(rebate_given, 5, Gg, 0), rref, UREF)
          End If
          Pp = Pp + 1: pp_amt = -pp_amt
          pp_paid = pp_amt
          PP_XPOST = Pick.extract(rebate_given, 1, Gg, 0): PP_XPOST_AMT = -pp_amt: pp_narr = "": PP_XPOST_DATE = Pick.extract(rebate_given, 4, Gg, 0)
          GoSub 577
          cr_next_pos = cr_next_pos + 1
       Next Gg
       If totrebate <> 0 Then
          tjdrec = Pick.insert(tjdrec, 1, -1, 0, Pp_Type): tjdrec = Pick.insert(tjdrec, 3, -1, 0, dc): tjdrec = Pick.insert(tjdrec, 4, -1, 0, CStr(totrebate)): tjdrec = Pick.insert(tjdrec, 5, -1, 0, Client_No)
       End If
    End If
    If disc_given <> "" Then
       totdisc = 0
       For Gg = 1 To Pick.dcount(Pick.extract(disc_given, 1, 0, 0), Chr(253))
          Rcode = Mid$(Pick.extract(disc_given, 1, Gg, 0), 1, 2)
          temp = Pick.extract(disc_given, 2, Gg, 0)
          If IsNumeric(temp) Then pp_amt = CCur(temp) Else pp_amt = 0
          rref = Pick.extract(disc_given, 1, Gg, 0)
          totdisc = totdisc + pp_amt
          pp_narr = "Discount on " & Pick.oconv(Pick.extract(disc_given, 3, Gg, 0), "MD2")
          If updating Then PP_DATE = Pick.ICONV(Format$(Now, "DD MMM YY"), "D2") Else PP_DATE = Tr_Inv_Date
          If testing Then
             pp_ref = "?": Pp_Type = 41
          Else
             Call SR300_RATES(database, clrec(), Pcode, Rcode, Client_No, pp_amt, CStr(Tr_Inv_Date), PENALTY_TAB, pp_narr, pp_ref, tjdrec, "D", Pp_Type, Pick.extractcur(disc_given, 3, Gg, 0), "", rref, UREF)
          End If
          Pp = Pp + 1: pp_amt = -pp_amt
          pp_paid = pp_amt
          PP_XPOST = Pick.extract(disc_given, 1, Gg, 0): PP_XPOST_AMT = -pp_amt: pp_narr = "": PP_XPOST_DATE = Pick.extract(disc_given, 4, Gg, 0)
          GoSub 577
          cr_next_pos = cr_next_pos + 1
       Next Gg
       If totdisc <> 0 Then
          tjdrec = Pick.insert(tjdrec, 1, -1, 0, Pp_Type): tjdrec = Pick.insert(tjdrec, 3, -1, 0, dc): tjdrec = Pick.insert(tjdrec, 4, -1, 0, CStr(totdisc)): tjdrec = Pick.insert(tjdrec, 5, -1, 0, Client_No)
       End If
    End If
    If disc_not_given <> "" And testing = 0 Then
       For Gg = 1 To Pick.dcount(Pick.extract(disc_not_given, 1, 0, 0), Chr(253))
          Rcode = Mid$(Pick.extract(disc_not_given, 1, Gg, 0), 1, 2)
          DKey = Rcode & Pick.extract(g_trans_info_array(59), 1, 1, 0) & "*" & Client_No
          DCT = 0
740      If d3.d3_readstr(database, Ww, "DISCOUNT", DKey) <> 0 Then
             Ww = "": GoTo 750
          End If
          DKey = Rcode & Pick.extract(g_trans_info_array(59), 1, 1, 0) & "-" & DCT & "*" & Client_No
          DCT = DCT + 1
          GoTo 740
750       For Ggg = 1 To 7
             Ww = Pick.replace(Ww, Ggg, 0, 0, Pick.extract(disc_not_given, Ggg, Gg, 0))
          Next Ggg
          Ww = Pick.replace(Ww, 8, 0, 0, Client_No)
          wterr = d3.d3_writestr(database, "DISCOUNT", DKey, Ww)
       Next Gg
    End If
    If rebate_flg Then
       Rcode = Mid$(Tr_Ref, 1, 2)
       PP_NAR = "Rebate on " & Pick.oconv(CStr(tr_amt), "MD2")
       If testing Then
          pp_ref = "?": Pp_Type = "37"
       Else
          Call SR300_RATES(database, clrec(), Pcode, Rcode, Client_No, uamt, CStr(Tr_Inv_Date), PENALTY_TAB, PP_NAR, pp_ref, tjdrec, "R", Pp_Type, "", "", Tr_Ref, UREF)
       End If
       tjdrec = Pick.insert(tjdrec, 1, -1, 0, Pp_Type): tjdrec = Pick.insert(tjdrec, 3, -1, 0, dc)
       tjdrec = Pick.insert(tjdrec, 4, -1, 0, CStr(uamt)): tjdrec = Pick.insert(tjdrec, 5, -1, 0, Client_No)
    End If
    If DISC_FLG Then
       Rcode = Mid$(Tr_Ref, 1, 2)
       PP_NAR = "Discount on " & Pick.oconv(CStr(tr_amt), "MD2")
       If testing Then
          pp_ref = "?": Pp_Type = 41
       Else
          Call SR300_RATES(database, clrec(), Pcode, Rcode, Client_No, uamt, CStr(Tr_Inv_Date), PENALTY_TAB, PP_NAR, pp_ref, tjdrec, "D", Pp_Type, tr_amt, "", Tr_Ref, UREF)
       End If
       tjdrec = Pick.insert(tjdrec, 1, -1, 0, Pp_Type): tjdrec = Pick.insert(tjdrec, 3, -1, 0, dc)
       tjdrec = Pick.insert(tjdrec, 4, -1, 0, CStr(uamt)): tjdrec = Pick.insert(tjdrec, 5, -1, 0, Client_No)
    End If
    If tjdrec <> "" And testing = 0 Then
       batch_key = Timer() & tj_tno
540     If d3.d3_readstr(database, Ans, "TRANS.J", batch_key) <> 0 Then GoTo 547
'       Release TRANS_J_DATA, BATCH_KEY
       batch_key = Timer() & tj_tno & Rnd(9)
       GoTo 540
547:
       tjdrec = Pick.replace(tjdrec, 7, 0, 0, CStr(CASH_DATE))
       If updating Then tjdrec = Pick.replace(tjdrec, 7, 0, 0, Pick.ICONV(Format$(Now, "DD MMM YY"), "D2")) Else tjdrec = Pick.replace(tjdrec, 7, 0, 0, CStr(CASH_DATE))
       wterr = d3.d3_writestr(database, "TRANS.J", batch_key, tjdrec)
       tjdrec = ""
    End If
    GoTo 580
'
' Insert tranasaction
'
577 cr_no_txs = cr_no_txs + 1
    Cr_Tdate = Pick.insert(Cr_Tdate, 1, Pp, 0, CStr(Tr_Inv_Date))
    Cr_Type = Pick.insert(Cr_Type, 1, Pp, 0, Pp_Type)
    If rebate_flg Then
'       cr_tref = pick.Insert(cr_tref, 1, pp, 0, RTREF)
    Else
       Cr_Tref = Pick.insert(Cr_Tref, 1, Pp, 0, pp_ref)
    End If
    Cr_Tamt = Pick.insert(Cr_Tamt, 1, Pp, 0, CStr(pp_amt))
    Cr_Tpaid = Pick.insert(Cr_Tpaid, 1, Pp, 0, CStr(pp_paid))
    Cr_Cust_Ref = Pick.insert(Cr_Cust_Ref, 1, Pp, 0, TR_CUST_REF)
    Cr_Xref = Pick.insert(Cr_Xref, 1, Pp, 0, PP_XPOST)
    Cr_Xamt = Pick.insert(Cr_Xamt, 1, Pp, 0, PP_XPOST_AMT)
    Cr_Narr = Pick.insert(Cr_Narr, 1, Pp, 0, pp_narr)
    If updating Then
       cr_ledg_date = Pick.insert(cr_ledg_date, 1, Pp, 0, PP_DATE)
    Else
       cr_ledg_date = Pick.insert(cr_ledg_date, 1, Pp, 0, LEDG_DATE)
    End If
    cr_xdte = Pick.insert(cr_xdte, 1, Pp, 0, PP_XPOST_DATE)
    Cr_Stdate = Pick.insert(Cr_Stdate, 1, Pp, 0, "")
    Return
'
' End insert
'
580   GoSub 7100 'write overflow record
      If updating Then
         cx = Pick.replace(cx, 22, 0, 0, Pick.extractcur(cx, 22, 0, 0) - tr_total_pay - paypenalty)
      Else
         cx = Pick.replace(cx, 3, 0, 0, CStr(Cr_Cur_Bal - uamt))
         cx = Pick.replace(cx, 22, 0, 0, Pick.extractcur(cx, 22, 0, 0) + uamt - tr_total_pay - paypenalty + NOTALLOC + REB_NOTALLOC)
         If Days_Ct_Pay And tr_inv_type = Tr_Cash Then
            Days_To_Pay = Int(Days_To_Pay / Days_Ct_Pay + 0.5)
            cx = Pick.insert(cx, 20, 1, 0, CStr(Days_To_Pay))
            cx = Pick.delet(cx, 20, 11, 0)
         End If
      End If
   cx = Pick.replace(cx, 3, 0, 0, Pick.extract(cx, 3, 0, 0) - totdisc - totrebate + ACCRUING + tot_ii_ia)
   cx = Pick.insert(cx, 49, -1, 0, CASH_INV)
   cx = Pick.insert(cx, 50, -1, 0, CASH_RCP)
   cx = Pick.insert(cx, 51, -1, 0, cash_amt)
   'If ANDTHEREST Then ST_CX = cx: penalty_cx = cx: GoTo 400
585:
    If Pick.extractcur(cx, 22, 0, 0) = 0 Then cx = Pick.replace(cx, 49, 0, 0, "")
    cx = Pick.replace(cx, 50, 0, 0, ""): cx = Pick.replace(cx, 51, 0, 0, "")
    If Pick.extractcur(cx, 3, 0, 0) = 0 And Pick.extractcur(cx, 22, 0, 0) = 0 Then
       DF_DATES = 99999: GoTo 595
    End If
    If First_Unpaid = 0 Then GoTo 587
    If updating = 0 Then
       If uamt - tr_total_pay <> 0 Then
          If Tr_Inv_Date < First_Unpaid Then
             First_Unpaid = Tr_Inv_Date
             GoTo 590
          End If
       End If
    Else
       If uamt = tr_total_pay Then
          If Tr_Inv_Date <= First_Unpaid Then GoTo 587
       End If
    End If
    If UPDATE_FIRST_UNPAID = 0 Then GoTo 590
587:
   'DFLGS = 1  ' find first unpaid
590:
    'DF_DATES = first_unpaid & Chr(253) & pick.EXTRACT(CX, 48, 0, 0) & Chr(253) & pick.EXTRACT(CX, 47, 0, 0)
    'If  pick.extract(DFLGS, 1, 1, 0) Then
    '   Call SR300_4(DFLGS, DF_DATES, CLIENT_NO, CR_OVFNO, OFLOW_DATES, CX, TD_OFLOW_DATA)
    'End If
'
595 'CX = pick.replace(CX, 53, 0, 0, pick.EXTRACT(DF_DATES, 1, 1, 0))
    'If PMGNT Then CX = pick.replace(CX, 48, 0, 0, pick.extract(DF_DATES, 1, 2, 0)): CX = pick.replace(CX, 47, 0, 0, pick.extract(DF_DATES, 1, 3, 0))
'    If CDATA <> "" Then
'      REC_CT = REC_CT + 1
'      CDATA = pick.replace(CDATA, 13, REC_CT, 0, cr_post)
'      CDATA = pick.replace(CDATA, 14, REC_CT, 0, cr_post_amt)
'      CDATA = pick.replace(CDATA, 15, REC_CT, 0, cr_post_date)
'      If council <> "" Then
'         If totrebate <> 0 Then CDATA = pick.replace(CDATA, 27, REC_CT, 0, totrebate)
'         If totdisc <> 0 Then CDATA = pick.replace(CDATA, 25, REC_CT, 0, totdisc)
'      End If
'    End If
    Exit Sub    ' to calling program
'
' HAVE REQUESTED THAT OTHER UNALLOCATED CREDITS BE MADE AVAILABLE
'

7100 If Ovf_No = 0 Then GoSub 7200 Else GoSub 7400
     Ovf_No = Next_Ovfno
     If Next_Ovfno > Cr_Ovfno Then Ovf_No = 0
     If Ovf_No = 0 Then GoTo 7790 Else GoTo 7300
7200 cx = Pick.replace(cx, 2, 0, 0, CStr(cr_no_txs))
cx = Pick.replace(cx, 14, 0, 0, Cr_Tdate)
cx = Pick.replace(cx, 11, 0, 0, Cr_Type)
cx = Pick.replace(cx, 12, 0, 0, Cr_Tref)
cx = Pick.replace(cx, 13, 0, 0, Cr_Tamt)
cx = Pick.replace(cx, 16, 0, 0, Cr_Tpaid)
cx = Pick.replace(cx, 24, 0, 0, Cr_Narr)
cx = Pick.replace(cx, 32, 0, 0, cr_ledg_date)
cx = Pick.replace(cx, 25, 0, 0, Cr_Cust_Ref)
cx = Pick.replace(cx, 26, 0, 0, Cr_Xref)
cx = Pick.replace(cx, 30, 0, 0, Cr_Xamt)
cx = Pick.replace(cx, 42, 0, 0, cr_xdte)
cx = Pick.replace(cx, 54, 0, 0, Cr_Stdate)
Return
'
7300:
Ovf_Key = Ovf_No & "*" & Client_No
If testing Then
   If Pick.extract(ARRY, Ovf_No, 0, 0) <> "" Then
      tx = Pick.extract(ARRY, Ovf_No, 0, 0)
      If tx = " " Then tx = ""
      tx = replace(tx, Chr(8), Chr(254))
      GoTo 7305
   End If
End If
If UBound(tx_write) >= Ovf_No Then
   If tx_write(Ovf_No) <> "" Then
      tx = tx_write(Ovf_No)
      GoTo 7305
   End If
End If
If d3.d3_readstr(database, tx, "TD.OFLOW", Ovf_Key) = 1 Then tx = ""
7305: 'cannot write in vbasic so if do want to write then store in this array
cr_no_txs = Pick.extractint(tx, 1, 0, 0)
Cr_Tdate = Pick.extract(tx, 5, 0, 0)
Cr_Type = Pick.extract(tx, 2, 0, 0)
Cr_Tref = Pick.extract(tx, 3, 0, 0)
Cr_Tamt = Pick.extract(tx, 4, 0, 0)
Cr_Xref = Pick.extract(tx, 9, 0, 0)
Cr_Xamt = Pick.extract(tx, 10, 0, 0)
cr_xdte = Pick.extract(tx, 12, 0, 0)
Cr_Stdate = Pick.extract(tx, 13, 0, 0)
Cr_Tpaid = Pick.extract(tx, 6, 0, 0)
Cr_Narr = Pick.extract(tx, 7, 0, 0)
cr_ledg_date = Pick.extract(tx, 11, 0, 0)
Cr_Cust_Ref = Pick.extract(tx, 8, 0, 0)
Return
'
7400 If Pick.extract(tx, 6, 0, 0) = Cr_Tpaid Then Return
tx = Pick.replace(tx, 1, 0, 0, CStr(cr_no_txs))
tx = Pick.replace(tx, 5, 0, 0, Cr_Tdate)
tx = Pick.replace(tx, 2, 0, 0, Cr_Type)
tx = Pick.replace(tx, 3, 0, 0, Cr_Tref)
tx = Pick.replace(tx, 4, 0, 0, Cr_Tamt)
tx = Pick.replace(tx, 9, 0, 0, Cr_Xref)
tx = Pick.replace(tx, 10, 0, 0, Cr_Xamt)
tx = Pick.replace(tx, 12, 0, 0, cr_xdte)
tx = Pick.replace(tx, 13, 0, 0, Cr_Stdate)
tx = Pick.replace(tx, 6, 0, 0, Cr_Tpaid)
tx = Pick.replace(tx, 7, 0, 0, Cr_Narr)
tx = Pick.replace(tx, 11, 0, 0, cr_ledg_date)
tx = Pick.replace(tx, 8, 0, 0, Cr_Cust_Ref)
      If Ovf_No = Cr_Ovfno Then
         cx = Pick.replace(cx, 28, 1, 0, Pick.extract(tx, 5, Pick.extractint(tx, 1, 0, 0), 0))
         cx = Pick.replace(cx, 28, 2, 0, Pick.extract(tx, 5, 1, 0))
      End If
      If testing Then
         tx = replace(tx, Chr(254), Chr(8))
         ARRY = Pick.replace(ARRY, Ovf_No, 0, 0, tx)
      Else
         ReDim Preserve tx_write(Ovf_No): tx_write(Ovf_No) = tx
         'Call PICKWT(TD_OFLOW_DATA, ovf_key, 3, tx, 0)
      End If
Return
'
7500 If Cr_Ovfno Then
       fupt = First_Unpaid - 1
       posn = Pick.locate(CStr(fupt), Oflow_Dates, 1, 1, 0, Next_Ovfno, "DR")
       If posn = 0 Then GoTo 266
       If Next_Ovfno = 1 Then
          Next_Ovfno = 0
       Else
          Next_Ovfno = Cr_Ovfno - Next_Ovfno + 2
          If Next_Ovfno <= 0 Then Next_Ovfno = 1
       End If
     Else
       Next_Ovfno = 0
     End If
     Return
'
7700 Cr_Ovfno = Pick.extractint(cx, 27, 0, 0)
Oflow_Dates = Pick.extract(cx, 28, 0, 0)
Cr_Cur_Bal = Pick.extractcur(cx, 3, 0, 0)
If Cr_Ovfno Then Ovf_No = 1: andthe_ovf = 1: GoTo 7300
Ovf_Key = "1*" & Client_No
If testing Then
   ARRY = Pick.replace(ARRY, 1, 0, 0, " ")
Else
   tx = ""
'$INSERT I.LOG.ADD '|TD.OFLOW|':OVF.KEY ? TX   *
   wterr = d3.d3_writestr(database, "TD.OFLOW", Ovf_Key, tx)
End If
'       LOG.LIST<-1>=OVF.KEY
Ovf_No = 1: andthe_ovf = 1
cx = Pick.replace(cx, 27, 0, 0, "1")
Cr_Ovfno = 1
cx = Pick.replace(cx, 28, 0, 0, 0 & Chr(253) & 0)
Oflow_Dates = Pick.extract(cx, 28, 0, 0)
7790  tx = "": GoTo 7305

8000 Call SR300_R(database, utcode, utref, utdate, Client_No, tr_bal, CASH_DATE, arrdate, Disc_Amt, clrec(), rtab, Rebate_Amt, auto_dates, rebate_gross, allow_defer)
     Return
'
8500  RTKEY = Mid$(RTREF, 1, 4): RATESKEY = RTKEY & suffix & "*" & Client_No
      cnt = 0
1000  If d3.d3_readstr(database, rrec, "RATES", RATESKEY) <> 0 Then rrec = ""
      If rrec <> "" Then
         cnt = cnt + 1
         RATESKEY = RTKEY & suffix & "-" & cnt & "*" & Client_No
         GoTo 1000
      Else
         If cnt = 0 Then RTREF = RTKEY & suffix Else RTREF = RTKEY & suffix & "-" & cnt
      End If
      Return

End Sub

Public Sub sr1694(logentry As String, vrec() As String, Cur_Date As String, use_id As String, one_prop As String, Optional ptab As String = "")

' Routine creates m/v lists with property balance details of all
' properties owned by first owner (including first property)

Static install() As String
Static install_read As Boolean
Dim rderr As Integer, assessnum As String, clpos As Integer, posn As Integer
Dim start_penalty_due As String
Dim Attr As Integer, occs As Integer
Dim Orec() As String, fown As String, assess_nos As String, ASSESS_NO As String
Dim total_props As Integer, Ii As Integer, Jj As Integer
Dim clrec() As String, Pcode As String, transrec As String
Dim assess_bals As String, gross_bal As String, total_bal As Currency, total_curr As Currency
Dim auto_dates As String, Dte As Integer, dte_copy As Integer, IMM_DISC As String, vrectest As String
Dim assess_curr As String, assess_net As String, assess_arrs As String, assess_defr As String
Dim assess_penalty As String, assess_ramt As String, total_net As Currency, total_arrs As Currency
Dim total_defr As Currency, total_ramt As Currency, Total_Penalty As Currency, Rate_Tab As String
Dim Net_Amt As Currency, nz As String, Ans As String, database As String
Dim temp As String, tempcur As Currency, tempcur2 As Currency
Dim kk As Integer, daily_accr As Currency, max_tab As Integer, dd As Integer

     database = Pick.extract(logentry, 2, 0, 0)
     If Cur_Date = "" Then Cur_Date = Date
     Cur_Date = Day(Cur_Date) & "/" & Month(Cur_Date) & "/" & Year(Cur_Date)
     
     If Not install_read Then
         ReDim install(0): install(0) = "@INSTALL"
         rderr = d3.d3_readmat(database, install(), "DICT TRANS.J")
         install_read = True
     End If
            
     If UBound(g_trans_info_array) = 0 Then
        g_trans_info_array(0) = "TRANS.INFO"
        rderr = d3.d3_readmat(database, g_trans_info_array(), "DICT TRANS.J")
     End If
 
'     INT.METH = TRANS.INFO<53>[14,1]    ;* penalty interest method
     start_penalty_due = g_trans_info_array(58) ' penalty cut-over date
     If UBound(g_trans_info_array) < 133 Then nz = "" Else nz = g_trans_info_array(133)
     If nz = "1" Then Attr = 37: occs = 31 Else Attr = 35: occs = 29

     If one_prop <> "" Then
        assess_nos = use_id
        ReDim Orec(0): Orec(0) = use_id
        rderr = d3.d3_readmat(database, Orec(), "CLIENT")
        If UBound(Orec) < 7 Then ReDim Preserve Orec(7)
     Else
        ReDim Orec(0): Orec(0) = use_id
        rderr = d3.d3_readmat(database, Orec(), "CLIENT")
        If UBound(Orec) < Attr Then fown = "" Else fown = Pick.extract(Orec(Attr), 1, 1, 0)
        ReDim Orec(0): Orec(0) = fown
        If fown <> "" Then
           rderr = d3.d3_readmat(database, Orec(), "CLIENT")
        End If
        If UBound(Orec) < occs Then ReDim Preserve Orec(occs)
        assess_nos = Orec(occs)
'        IF HAS.TD.VALUE AND INT.METH THEN
'           READ VREC FROM TD.VALUE.DATA,FOWN ELSE GOTO 100
'           Exit function
'        End If
     End If
'100:
     assess_bals = "":  assess_curr = "":  assess_net = """"
     assess_arrs = "": assess_defr = "": assess_penalty = "": assess_ramt = ""
     total_bal = 0:  total_curr = 0
     total_net = 0: total_arrs = 0: total_defr = 0: total_ramt = 0
     Total_Penalty = 0
     Rate_Tab = ""

     total_props = Pick.dcount(assess_nos, Chr(253))
'        If IS303 And TOTAL.PROPS > 50 Then
'           BOX.Type = 1: Char (254): 'PLEASE NOTE'
'           SR=P$-3; ER=P$
'           CALL SR.BOX(0,SR,79,ER,BOX.TYPE,'')
'           PRINT @(1,P$-2):CL:'First owner has more than 50 properties, 309 should be used to receipt this':
'           MSG$='assessment as processing could be slow ! Ok to continue (Y/N)? '
'           LNS$=P$-1; CLS$=''; CALL SRIP(1,LNS$,MSG$,ANS,CLS$,'N','','','')
'           IF ANS#'Y' THEN FLAGS<1,3>=1; RETURN
'        End If

     For Ii = 1 To total_props
        ASSESS_NO = Pick.extract(assess_nos, 1, Ii, 0)
        ReDim clrec(0): clrec(0) = ASSESS_NO
        rderr = d3.d3_readmat(database, clrec(), "CLIENT")
        If UBound(clrec) < 44 Then ReDim Preserve clrec(44)
        Pcode = clrec(44)
        rderr = d3.d3_readstr(database, transrec, "TDEBTOR", ASSESS_NO)
        gross_bal = Pick.extract(transrec, 3, 0, 0)
        assess_bals = Pick.replace(assess_bals, 1, Ii, 0, gross_bal)
        If IsNumeric(gross_bal) Then total_bal = total_bal + CCur(gross_bal)

        auto_dates = "RULE"
        auto_dates = Pick.replace(auto_dates, 1, 8, 0, "2")
        auto_dates = Pick.replace(auto_dates, 1, 10, 0, "PNET")
        rderr = Pick.date_vb_to_pick(Cur_Date, Dte, 0): dte_copy = Dte
        IMM_DISC = "1" & Chr(253) & "1"
        vrectest = "?"
        Call SR300(logentry, ASSESS_NO, clrec(), ptab, transrec, "31", Chr(253), 99999999, Dte, "", "", "", "", IMM_DISC, dte_copy, auto_dates, "", "", "", "", install, "", vrectest)
        If IsNumeric(gross_bal) Then Net_Amt = CCur(gross_bal) Else Net_Amt = 0
        assess_curr = Pick.replace(assess_curr, 1, Ii, 0, Pick.extract(vrectest, 2, 0, 0))
        Ans = Pick.extract(assess_curr, 1, Ii, 0)
        If IsNumeric(Ans) Then total_curr = total_curr + CCur(Ans)
        assess_arrs = Pick.replace(assess_arrs, 1, Ii, 0, Pick.extract(vrectest, 3, 0, 0))
        Ans = Pick.extract(assess_arrs, 1, Ii, 0)
        If IsNumeric(Ans) Then total_arrs = total_arrs + CCur(Ans)
        assess_defr = Pick.replace(assess_defr, 1, Ii, 0, Pick.extract(vrectest, 4, 0, 0))
        Ans = Pick.extract(assess_defr, 1, Ii, 0)
        If IsNumeric(Ans) Then total_defr = total_defr + CCur(Ans): Net_Amt = Net_Amt - CCur(Ans)
        assess_penalty = Pick.replace(assess_penalty, 1, Ii, 0, Pick.extract(vrectest, 6, 0, 0))
        Ans = Pick.extract(assess_penalty, 1, Ii, 0)
        If IsNumeric(Ans) Then Total_Penalty = Total_Penalty + CCur(Ans): Net_Amt = Net_Amt + CCur(Ans)
        assess_ramt = Pick.replace(assess_ramt, 1, Ii, 0, Pick.extract(vrectest, 5, 0, 0))
        Ans = Pick.extract(assess_ramt, 1, Ii, 0)
        If IsNumeric(Ans) Then total_ramt = total_ramt + CCur(Ans): Net_Amt = Net_Amt - CCur(Ans)
 
        For Jj = 20 To 23
           Rate_Tab = Pick.replace(Rate_Tab, Jj - 19, Ii, 0, Pick.extract(vrectest, Jj, 0, 0))
        Next Jj

        assess_net = Pick.replace(assess_net, 1, Ii, 0, CStr(Net_Amt))
        total_net = total_net + Net_Amt
     Next Ii

     ReDim vrec(39)
     vrec(39) = Dte
     vrec(1) = CStr(total_props)
     vrec(2) = assess_nos
     vrec(3) = CStr(total_bal)
     vrec(4) = assess_bals
     vrec(5) = CStr(total_curr)
     vrec(6) = assess_curr
     vrec(7) = CStr(total_net)
     vrec(8) = assess_net
     vrec(9) = CStr(total_arrs)
     vrec(10) = assess_arrs
     vrec(11) = CStr(total_ramt)
     vrec(12) = assess_ramt
     vrec(13) = CStr(total_defr)
     vrec(14) = assess_defr
     vrec(15) = Cur_Date '* date last calculated
     vrec(16) = CStr(Total_Penalty)
     vrec(17) = assess_penalty
     vrec(20) = Pick.extract(Rate_Tab, 1, 0, 0) ' rate codes
     vrec(21) = Pick.extract(Rate_Tab, 2, 0, 0) ' current amt per rate code
     vrec(22) = Pick.extract(Rate_Tab, 3, 0, 0) ' arrears per rate code
     vrec(23) = Pick.extract(Rate_Tab, 4, 0, 0) ' deferred per rate code
     vrec(24) = Orec(1) & " " & Orec(7)
'
' Generate Penalty Interest display
'
     For Jj = 1 To Pick.dcount(Pick.extract(ptab, 9, 0, 0), Chr(252))
        assessnum = Pick.extract(ptab, 9, 1, Jj)
        posn = Pick.locate(assessnum, vrec(2), 1, 1, 0, clpos, "")
        vrec(31) = Pick.insert(vrec(31), 1, clpos, -1, Pick.extract(ptab, 6, 1, Jj))
        vrec(32) = Pick.insert(vrec(32), 1, clpos, -1, Pick.extract(ptab, 8, 1, Jj))
        vrec(33) = Pick.insert(vrec(33), 1, clpos, -1, Pick.extract(ptab, 10, 1, Jj))
        vrec(34) = Pick.insert(vrec(34), 1, clpos, -1, Pick.extract(ptab, 5, 1, Jj))
        vrec(35) = Pick.insert(vrec(35), 1, clpos, -1, Pick.extract(ptab, 4, 1, Jj))
        vrec(36) = Pick.insert(vrec(36), 1, clpos, -1, Pick.extract(ptab, 7, 1, Jj))
        daily_accr = 0
        max_tab = Pick.dcount(Pick.extract(vrec(31), 1, clpos, 0), Chr(252))
        For dd = 1 To max_tab
           vrec(38) = Pick.replace(vrec(38), 1, clpos, dd, Pick.extract(vrec(31), 1, clpos, dd) & "*" & Pick.extract(vrec(2), 1, clpos, 0))
           tempcur = Pick.extractcur(vrec(32), 1, clpos, dd)
           tempcur2 = Pick.extractcur(vrec(35), 1, clpos, dd)
           daily_accr = daily_accr + tempcur * tempcur2 / 365
        Next dd
        vrec(37) = Pick.replace(vrec(37), 1, clpos, 0, Format(daily_accr / 10000, "#.0000"))
     Next Jj

End Sub


Public Sub SR1625_INS(logentry As String, nrec() As String, Cur_Date As String)

'  Display current instalment option for assessment

Dim rtab As String, PENALTY_TAB As String, td_rec As String
Dim rebatE_info As String, extrapenalty As String
Dim allow_display As String, No_Install As Integer
Dim clpos As Integer, posn As String, tempcur As Currency
Dim nx As Integer, Ii As Integer, kk As Integer, Totals_NX As Integer

Dim totals As Currency
Dim Date_Due As String
Dim Penamt As Currency
Dim Base_AMT As Currency, Net_DUE As Currency, Charges As Currency
Dim Bal_DUE As Currency, Paid_AMT As Currency
Dim temp As String
Dim Makes As String
Dim Dates  As String
Dim instal_ref As String
Dim admin_fee  As Currency
Dim rderr As Integer, special As Integer, xpen As Currency, desc As String, Mm As Integer
Dim Int_AMTS As String
Dim dd As Integer, Adj As Integer, MAXKK As Integer
Dim Dte As String, Tots As String
Dim Dpos As Integer, SUB_HD1  As String
Dim Max As Integer, EE As Integer, cnt As Integer
Dim install As String
Dim vrec() As String
Dim database As String

database = Pick.extract(logentry, 2, 0, 0)

     ReDim Preserve nrec(10): nrec(10) = Cur_Date
     If UBound(g_trans_info_array) = 0 Then
        g_trans_info_array(0) = "TRANS.INFO"
        rderr = d3.d3_readmat(database, g_trans_info_array(), "DICT TRANS.J")
     End If
        
     Call SR300_TAB(database, rtab, PENALTY_TAB)
     If d3.d3_readstr(database, rebatE_info, "dict trans.j", "@STATE_REBATE") <> 0 Then rebatE_info = ""
     If d3.d3_readstr(database, install, "dict trans.j", "@INSTALL") <> 0 Then rebatE_info = ""
     
     If Pick.extract(rebatE_info, 4, 1, 0) = "" Then rebatE_info = Pick.replace(rebatE_info, 4, 1, 0, 0.5)
      
     Call sr1694(logentry, vrec(), Cur_Date, nrec(0), nrec(0))
     allow_display = 1 & Chr(253) & 1 & Chr(253) & 8
     extrapenalty = ""
     Call SR1695_INS(logentry, nrec(), Cur_Date, extrapenalty)
     If d3.d3_readstr(database, td_rec, "TDEBTOR", nrec(0)) <> 0 Then td_rec = ""

     posn = Pick.locate(nrec(0), extrapenalty, 1, 1, 0, clpos, "")
     
     If special = 0 Then
        desc = " (Standard) "
     Else
        If special = 12 Then
           If Pick.extract(install, 21, 2, 0) = "UP" Then
              desc = " (Underground Power) "
           Else
              desc = " (Arrears Arrangement) "
           End If
        Else
           If special = 24 Then desc = " (Arrears Arrangement) "
        End If
     End If
     
    No_Install = Pick.extractint(td_rec, 85 + special, 0, 0)
    If d3.d3_readstr(database, instal_ref, "INSTALL.CTL", nrec(0)) <> 0 Then instal_ref = ""

    nx = 0
    totals = 0
     For Ii = 1 To No_Install
        Date_Due = Pick.extract(td_rec, 86 + special, Ii, 0)
        
        Penamt = 0
        For kk = 1 To Pick.dcount(Pick.extract(extrapenalty, 3, clpos, 0), Chr(252))
           If Pick.extract(extrapenalty, 12, clpos, kk) <> 0 Then
              If Date_Due = Pick.extract(extrapenalty, 3, clpos, kk) Then
                 Penamt = Penamt + Pick.extractcur(extrapenalty, 6, clpos, kk)
              End If
           End If
        Next kk

        Base_AMT = Pick.extractcur(td_rec, 87 + special, Ii, 0)
        Net_DUE = Pick.extractcur(td_rec, 90 + special, Ii, 0) + Penamt
        Charges = Net_DUE - Base_AMT - Penamt
        Paid_AMT = Pick.extractcur(td_rec, 92 + special, Ii, 0)
        Bal_DUE = Net_DUE - Paid_AMT

        nx = nx + 1
        nrec(1) = Pick.replace(nrec(1), 1, nx, 0, Date_Due)
        nrec(2) = Pick.replace(nrec(2), 1, nx, 0, Ii & "/" & Pick.extract(td_rec, 85, 0, 0))
        nrec(3) = Pick.replace(nrec(3), 1, nx, 0, CStr(Base_AMT))
        nrec(4) = Pick.replace(nrec(4), 1, nx, 0, CStr(Charges))
        nrec(5) = Pick.replace(nrec(5), 1, nx, 0, CStr(Penamt))
        
        temp = Pick.extract(extrapenalty, 13, clpos, 0)
        If IsNumeric(temp) Then temp = CStr(CCur(temp) - Penamt) Else temp = CStr(-Penamt)
        
        extrapenalty = Pick.replace(extrapenalty, 13, clpos, 0, temp)
        nrec(6) = Pick.replace(nrec(6), 1, nx, 0, CStr(Net_DUE))
        nrec(7) = Pick.replace(nrec(7), 1, nx, 0, CStr(Paid_AMT))
        nrec(8) = Pick.replace(nrec(8), 1, nx, 0, CStr(Bal_DUE))
     Next Ii
     If No_Install < 1 Then
        nx = nx + 1
        nrec(1) = Pick.replace(nrec(1), 1, nx, 0, "No instalment plan selected")
     End If
     
'** GSM 3/7/01
    xpen = 0
    For Mm = 1 To No_Install
       xpen = xpen + Pick.extractcur(extrapenalty, 13, clpos, Mm) + Pick.extractcur(extrapenalty, 14, clpos, Mm)
    Next Mm
'****
     If xpen <> "0" Then
        nx = nx + 1
        nrec(1) = Pick.replace(nrec(1), 1, nx, 0, "Other penalty to " & Cur_Date)
        nrec(5) = Pick.replace(nrec(5), 1, nx, 0, CStr(xpen))
        nrec(6) = Pick.replace(nrec(6), 1, nx, 0, Pick.extract(nrec(5), 1, nx, 0))
        nrec(8) = Pick.replace(nrec(8), 1, nx, 0, Pick.extract(nrec(5), 1, nx, 0))
     End If
     If No_Install <> 0 Then nrec(9) = CStr(No_Install)

'make charge details screen

     Makes = ""
     Dates = Pick.extract(td_rec, 86, 0, 0)
     Call Pick.sr_change(Dates, Chr(253), Chr(252))
     If instal_ref <> "" Then
        admin_fee = 0
        For dd = 1 To 9999
           Adj = (dd - 1) * 20
           If Pick.extract(instal_ref, 10 + Adj, 0, 0) = "" Then GoTo 1050
           If Pick.extract(instal_ref, 15 + Adj, 0, 0) = "" Then GoTo 1040
           If Pick.extract(instal_ref, 16 + Adj, 0, 0) <> "" Then GoTo 1040
           Makes = Pick.insert(Makes, 1, -1, 0, Pick.extract(instal_ref, 3 + Adj, 0, 0))
           Makes = Pick.insert(Makes, 2, -1, 0, Pick.extract(instal_ref, 12 + Adj, 0, 0))
           Makes = Pick.insert(Makes, 3, -1, 0, Pick.extract(instal_ref, 10 + Adj, 0, 0))
           temp = Pick.extract(instal_ref, 3 + Adj, 0, 0)
           If IsNumeric(temp) Then admin_fee = admin_fee + CCur(temp)
           Int_AMTS = ""
           MAXKK = Pick.dcount(Pick.extract(instal_ref, 1 + Adj, 0, 0), Chr(253))
           For kk = 1 To MAXKK
              Dte = Pick.extract(instal_ref, 1 + Adj, kk, 0)
              posn = Pick.locate(CStr(Dte), Dates, 1, 1, 1, Dpos, "")
              Int_AMTS = Pick.replace(Int_AMTS, 1, 1, Dpos, Pick.extract(instal_ref, 4 + Adj, kk, 0))
           Next kk
           Makes = Pick.insert(Makes, 4, -1, 0, Int_AMTS)
1040 Next dd
1050: temp = Pick.extract(td_rec, 88, 0, 0)
         If IsNumeric(temp) Then tempcur = CCur(temp) Else tempcur = 0
         If admin_fee < tempcur Then   'allow for changeover
           Makes = Pick.insert(Makes, 1, 1, 0, CStr(tempcur - admin_fee))
           Makes = Pick.insert(Makes, 2, 1, 0, Pick.extract(td_rec, 85, 0, 0))
           Makes = Pick.insert(Makes, 3, 1, 0, Pick.extract(td_rec, 85, 0, 0))
           Makes = Pick.insert(Makes, 4, 1, 0, "")
           MAXKK = Pick.dcount(Dates, Chr(252))
           For kk = 1 To MAXKK
              Makes = Pick.replace(Makes, 4, 1, kk, Pick.extract(td_rec, 89, kk, 0))
           Next kk
        End If
     Else
        Dates = Pick.replace(Dates, 2, 0, 0, Pick.extract(td_rec, 89, 0, 0))
     End If
     
     Max = Pick.dcount(Pick.extract(Makes, 1, 0, 0), Chr(253))
     cnt = 10
     Tots = 0
     For EE = 1 To Pick.dcount(Pick.extract(Dates, 1, 1, 0), Chr(252))
        cnt = cnt + 1
        If cnt > UBound(nrec) Then ReDim Preserve nrec(cnt)
        nrec(cnt) = Pick.replace(nrec(cnt), 1, 1, 0, Pick.date_pick_to_vb(val(Pick.extract(Dates, 1, 1, EE))))
        For dd = 1 To Max
           tempcur = Pick.extractcur(Makes, 4, dd, EE)
           nrec(cnt) = Pick.replace(nrec(cnt), 1, dd + 1, 0, Format(tempcur / 100, "#.00") & " (Plan " & Pick.extract(Makes, 3, dd, 0) & ")")
           tempcur = tempcur + Pick.extractcur(Tots, 1, dd, 0)
           Tots = Pick.replace(Tots, 1, dd, 0, CStr(tempcur))
        Next dd
     Next EE

     cnt = 20 'allow for maximum of 4 instalments
     If cnt > UBound(nrec) Then ReDim Preserve nrec(cnt)
     nrec(cnt) = Pick.replace(nrec(cnt), 1, 1, 0, "Interest")
     For dd = 1 To Max
        temp = Pick.extract(Tots, 1, dd, 0)
        If IsNumeric(temp) Then tempcur = CCur(temp) Else tempcur = 0
        nrec(cnt) = Pick.replace(nrec(cnt), 1, dd + 1, 0, CStr(tempcur))
     Next dd
     cnt = cnt + 1
     If cnt > UBound(nrec) Then ReDim Preserve nrec(cnt)
     nrec(cnt) = Pick.replace(nrec(cnt), 1, 1, 0, "Per install")
     For dd = 1 To Max
         tempcur = Pick.extractcur(Tots, 1, dd, 0)
         Mm = Pick.extractint(Makes, 2, dd, 0)
         If Mm <> 0 Then temp = CStr(Int(tempcur / Mm)) Else temp = ""
         nrec(cnt) = Pick.replace(nrec(cnt), 1, dd + 1, 0, temp)
     Next dd
     cnt = cnt + 1
     If cnt > UBound(nrec) Then ReDim Preserve nrec(cnt)
     nrec(cnt) = Pick.replace(nrec(cnt), 1, 1, 0, "1st round")
     For dd = 1 To Max
         tempcur = Pick.extractcur(Tots, 1, dd, 0)
         Mm = Pick.extractint(Makes, 2, dd, 0)
         If Mm <> 0 Then temp = CStr((tempcur - Int(tempcur / Mm) * Mm)) Else temp = ""
         nrec(cnt) = Pick.replace(nrec(cnt), 1, dd + 1, 0, temp)
     Next dd

     Tots = ""
     cnt = cnt + 1
     If cnt > UBound(nrec) Then ReDim Preserve nrec(cnt)
     nrec(cnt) = Pick.replace(nrec(cnt), 1, 1, 0, "Fees")
     For dd = 1 To Max
        tempcur = Pick.extractcur(Makes, 1, dd, 0)
        nrec(cnt) = Pick.replace(nrec(cnt), 1, dd + 1, 0, CStr(tempcur))
        tempcur = Pick.extractcur(Tots, 1, dd, 0)
        tempcur = tempcur + Pick.extractcur(Makes, 1, dd, 0)
        Tots = Pick.replace(Tots, 1, dd, 0, CStr(tempcur))
     Next dd
     cnt = cnt + 1
     If cnt > UBound(nrec) Then ReDim Preserve nrec(cnt)
     nrec(cnt) = Pick.replace(nrec(cnt), 1, 1, 0, "Per instal")
     For dd = 1 To Max
         tempcur = Pick.extractcur(Tots, 1, dd, 0)
         Mm = Pick.extractint(Makes, 2, dd, 0)
         If Mm <> 0 Then temp = CStr(Int(tempcur / Mm)) Else temp = ""
         nrec(cnt) = Pick.replace(nrec(cnt), 1, dd + 1, 0, temp)
     Next dd
     cnt = cnt + 1
     If cnt > UBound(nrec) Then ReDim Preserve nrec(cnt)
     nrec(cnt) = Pick.replace(nrec(cnt), 1, 1, 0, "1st round")
     For dd = 1 To Max
         tempcur = Pick.extractcur(Tots, 1, dd, 0)
         Mm = Pick.extractint(Makes, 2, dd, 0)
         If Mm <> 0 Then temp = CStr((tempcur - Int(tempcur / Mm) * Mm)) Else temp = ""
         nrec(cnt) = Pick.replace(nrec(cnt), 1, dd + 1, 0, temp)
     Next dd

End Sub
Public Sub SR1695_INS(logentry As String, nrec() As String, Cur_Date As String, Optional extrapenalty As String = "")

' Routine to display instalment details for properties

Static install() As String
Static install_read As Boolean, rderr As Integer
Dim inst_descs As String, vrec() As String, inst_totals As String
Dim max_install As Integer, max_props As Integer, nx As Integer
Dim Ii As Integer, clpos As Integer, rtab As String, PENALTY_TAB As String
Dim d_rec As String, insts As String, inst_option As String
Dim all_paid As Currency, inx As Integer, total_due As Currency, inst_payment As Currency
Dim inst_charges As Currency, PEN_AMT As Currency, Apply_Install As Integer, morepenalty As Currency
Dim installs_left As String, fullpay As Currency, fullpay_date As Integer, takenup As Integer
Dim theattr As Integer, Interim As String, inopt As String, ASSESS_NO As String
Dim Max_Jj As Integer, Jj As Integer
Dim inst_dx As String, not_done_assess As Integer, usejj As Integer, pix As Integer
Dim Date_Due As String, Dte As String, total_due_save3 As Currency, total_due_save As Currency
Dim already As String, aa As Integer, Adj As Integer, pln As String, uadj As Integer, max_nx As Integer
Dim use_assess As String, posn As Integer, tempcur As Currency
Dim total_base As Currency, total_chgs As Currency, total_ndue As Currency
Dim allow_display As Integer, temp As String, tot13 As Currency, Tt As Integer, cdte As Integer
Dim database As String, ptab As String, special As Integer, is1650 As Integer
Dim insbal As Currency, tot_insbal As Currency, arr_date As Integer, catg As String, kk As Integer
Dim arr As Integer, INSTAL_NO As Integer, LP As Integer

     database = Pick.extract(logentry, 2, 0, 0)
     If UBound(g_trans_info_array) = 0 Then
         g_trans_info_array(0) = "TRANS.INFO"
         rderr = d3.d3_readmat(database, g_trans_info_array(), "DICT TRANS.J")
     End If
     is1650 = 0
     Call SR300_TAB(database, rtab, PENALTY_TAB)
     ptab = ""
     Call sr1694(logentry, vrec(), Cur_Date, nrec(0), "", ptab)
     
     rderr = Pick.date_vb_to_pick(Cur_Date, cdte, 0):
     
     If Not install_read Then
         ReDim install(0): install(0) = "@INSTALL"
         rderr = d3.d3_readmat(database, install(), "DICT TRANS.J")
         install_read = True
     End If
     allow_display = 1
     inst_descs = "1st" & Chr(253) & "2nd" & Chr(253) & "3rd" & Chr(253) & "4th" & Chr(253) & "5th" & Chr(253) & "6th" & Chr(253) & "7th" & Chr(253) & "8th" & Chr(253) & "9th" & Chr(253) & "10th" & Chr(253) & "11th" & Chr(253) & "12th"
'
     special = 0
     insbal = 0: tot_insbal = 0
     max_install = Pick.dcount(install(1), Chr(253))
     temp = vrec(1)
     If IsNumeric(temp) Then max_props = CInt(temp) Else max_props = 0
     ReDim Preserve nrec(10):  nrec(10) = Cur_Date: nx = 0
     inst_totals = install(1)

     If vrec(20) <> "" Then
        For Ii = 1 To max_props       ' calc_ instalments per property
           ASSESS_NO = Pick.extract(vrec(2), 1, Ii, 0)
           
        If is1650 Then GoSub 3000
        If Pick.extract(vrec(20), 1, Ii, 0) <> "" Or (is1650 And tot_insbal) Then
           If is1650 = 0 Then  'get extra penalty to penalty date for a client
              posn = Pick.locate(ASSESS_NO, extrapenalty, 1, 1, 0, clpos, "")
              extrapenalty = Pick.replace(extrapenalty, 1, clpos, 0, ASSESS_NO)
              arr_date = Pick.extractint(g_trans_info_array(59), 1, 3, 0)
              For Jj = 1 To Pick.dcount(Pick.extract(ptab, 1, 0, 0), Chr(253))
                 catg = Pick.extract(ptab, 1, Jj, 0)
                 For kk = 1 To Pick.dcount(Pick.extract(ptab, 9, Jj, 0), Chr(252))
                    If Pick.extract(ptab, 9, Jj, kk) = ASSESS_NO Then
                       If special = 0 Then
                          If catg = Pick.extract(install(21), 1, 2, 0) Or catg = "UA" Or catg = "UI" Then GoTo 444
                       Else
                          If catg <> Pick.extract(install(21), 1, 2, 0) And catg <> "UA" And catg <> "UI" Then GoTo 444
                       End If
                       Dte = Pick.extractint(ptab, 10, Jj, kk)
                       extrapenalty = Pick.insert(extrapenalty, 3, clpos, -1, Dte)
                       extrapenalty = Pick.insert(extrapenalty, 6, clpos, -1, Pick.extract(ptab, 7, Jj, kk))
                       If Dte <= arr_date Then arr = 2 Else arr = 1
                       extrapenalty = Pick.replace(extrapenalty, 12 + arr, clpos, special, Pick.extractcur(extrapenalty, 12 + arr, clpos, special) + Pick.extractcur(ptab, 7, Jj, kk))
                       extrapenalty = Pick.insert(extrapenalty, 12, clpos, -1, Pick.extract(ptab, 12, Jj, kk))
                    End If
444               Next kk
              Next Jj
           End If
           
           If d3.d3_readstr(database, d_rec, "TDEBTOR", ASSESS_NO) <> 0 Then d_rec = ""
           If d3.d3_readstr(database, insts, "INSTALL.CTL", ASSESS_NO) <> 0 Then insts = ""

           inst_option = Pick.extract(d_rec, 85, 0, 0)

           If inst_option <> "" Then     ' instalments not yet selected
              all_paid = 0
              For inx = 1 To CInt(inst_option)    ' next instalment due
                 temp = Pick.extract(d_rec, 90, inx, 0)
                 If IsNumeric(temp) Then total_due = CCur(temp) Else total_due = 0
                 temp = Pick.extract(d_rec, 92, inx, 0)
                 If IsNumeric(temp) Then total_due = total_due - CCur(temp)
                 If total_due <> 0 Then GoTo 200
              Next inx
              all_paid = 1
              inx = CInt(inst_option)
              If inx <> 0 Then
200            inst_dx = Pick.extract(inst_descs, 1, inx, 0)
                 Date_Due = Pick.extract(d_rec, 86, inx, 0)
                 temp = Pick.extract(d_rec, 87, inx, 0)
                 If IsNumeric(temp) Then inst_payment = CCur(temp) Else inst_payment = 0
                 temp = Pick.extract(d_rec, 90, inx, 0)
                 If IsNumeric(temp) Then inst_charges = CCur(temp) - inst_payment Else inst_charges = -inst_payment
'                 If IS1650 = 0 Then       ' add in penalty
                    temp = Pick.extract(vrec(17), 1, Ii, 0)
                    If IsNumeric(temp) Then PEN_AMT = CCur(temp) Else PEN_AMT = 0
                    inst_charges = inst_charges + PEN_AMT
                    total_due = total_due + PEN_AMT
'                 End If
                 Apply_Install = 1
                 morepenalty = 0
                 installs_left = inst_option: fullpay = 0: fullpay_date = 0: takenup = inx: theattr = 0: Interim = "": inopt = inst_option: GoSub 2950
'
                 If allow_display = 1 Then
                    nx = nx + 1
                    nrec(1) = Pick.replace(nrec(1), 1, nx, 0, ASSESS_NO)
                    nrec(2) = Pick.replace(nrec(2), 1, nx, 0, inst_option)
                    nrec(3) = Pick.replace(nrec(3), 1, nx, 0, inst_dx)
                    nrec(4) = Pick.replace(nrec(4), 1, nx, 0, Date_Due)
                    nrec(5) = Pick.replace(nrec(5), 1, nx, 0, CStr(inst_payment))
                    nrec(6) = Pick.replace(nrec(6), 1, nx, 0, CStr(inst_charges))
                    nrec(7) = Pick.replace(nrec(7), 1, nx, 0, CStr(total_due))
                 End If
                 tot13 = 0
                 For Tt = 1 To Pick.dcount(Pick.extract(extrapenalty, 13, clpos, 0), Chr(252))
                    tot13 = tot13 + Pick.extractcur(extrapenalty, 13, clpos, Tt)
                 Next Tt
                 If tot13 <> 0 And all_paid = 0 Then
                    nx = nx + 1
                    nrec(1) = Pick.replace(nrec(1), 1, nx, 0, "  ")
                    nrec(2) = Pick.replace(nrec(2), 1, nx, 0, "Extra penalty to " & Cur_Date)
                    nrec(7) = Pick.replace(nrec(7), 1, nx, 0, CStr(tot13))
                 End If
              End If
           End If
'INTERIMS FROM INSTALL.CTL FILE
'           IF ALLOW.DISPLAY THEN
              already = ""
              For aa = 0 To 9999
                 Adj = aa * 20
                 If Pick.extract(insts, Adj + 10, 0, 0) = "" Then GoTo 220
'                 IF INSTS<ADJ+11>#1 THEN GOTO 210; *NOT INTERIM
                 If Pick.extract(insts, Adj + 15, 0, 0) <> "" Then GoTo 210 'ON DEBTOR SO SHOWN ABOVE
                 pln = Pick.extract(insts, Adj + 10, 0, 0)
                 Dte = Pick.extract(insts, Adj + 1, 1, 0)
                 nx = nx + 1
                 nrec(1) = Pick.replace(nrec(1), 1, nx, 0, ASSESS_NO)
                 'RGM  ** ERROR **
                 'If pick.extract(insts, adj + 11, 0, 0) = 1 Then nrec(1) = pick.replace(nrec(1), 1, nx, 0, pick.extract(nrec, 1, nx, 0) & " interim")
                 If Pick.extract(insts, Adj + 11, 0, 0) = 1 Then nrec(1) = Pick.replace(nrec(1), 1, nx, 0, Pick.extract(nrec(1), 1, nx, 0) & " interim")
                 nrec(2) = Pick.replace(nrec(2), 1, nx, 0, pln)
                 nrec(3) = Pick.replace(nrec(3), 1, nx, 0, Pick.extract(inst_descs, 1, 1, 0))
                 nrec(4) = Pick.replace(nrec(4), 1, nx, 0, Dte)
                 temp = Pick.extract(insts, 2 + Adj, 1, 0)
                 If IsNumeric(temp) Then total_due = CCur(temp) Else total_due = 0
                 temp = Pick.extract(insts, 7 + Adj, 1, 0)
                 If IsNumeric(temp) Then total_due = total_due + CCur(temp)
                 nrec(5) = Pick.replace(nrec(5), 1, nx, 0, CStr(total_due))
                 total_due_save = total_due
                 temp = Pick.extract(insts, 5 + Adj, 1, 0)
                 If IsNumeric(temp) Then total_due = CCur(temp) Else total_due = 0
                 temp = Pick.extract(insts, 2 + Adj, 1, 0)
                 If IsNumeric(temp) Then temp = CStr(total_due - CCur(temp)) Else temp = CStr(total_due)
                 nrec(6) = Pick.replace(nrec(6), 1, nx, 0, temp)
                 temp = Pick.extract(insts, 7 + Adj, 1, 0)
                 If IsNumeric(temp) Then total_due = total_due + CCur(temp)
                 total_due_save3 = total_due
                 nrec(7) = Pick.replace(nrec(7), 1, nx, 0, CStr(total_due)) 'errro
                 inst_payment = 0: inst_charges = 0: Apply_Install = 0
                 If already = Pick.extract(insts, 6 + Adj, 0, 0) & Chr(253) & Pick.extract(insts, 8 + Adj, 0, 0) Then
                    fullpay = 0: fullpay_date = 0
                 Else
                    already = Pick.extract(insts, 6 + Adj, 0, 0) & Chr(253) & Pick.extract(insts, 8 + Adj, 0, 0)
                    temp = Pick.extract(insts, 18 + Adj, 1, 0)
                    If IsNumeric(temp) Then fullpay = CCur(temp) Else fullpay = 0
                    temp = Pick.extract(insts, 18 + Adj, 2, 0)
                    If IsNumeric(temp) Then fullpay = fullpay + CCur(temp)
                    temp = Pick.extract(insts, 18 + Adj, 4, 0)
                    If IsNumeric(temp) Then fullpay_date = CInt(temp) Else fullpay_date = 0
                    If fullpay_date < cdte Then
                       temp = Pick.extract(insts, 18 + Adj, 5, 0)
                       If IsNumeric(temp) Then fullpay = fullpay + CCur(temp)
                    End If
                 End If
                 installs_left = Pick.extract(insts, 12 + Adj, 0, 0)
                 morepenalty = 0
'                If IS1650 = 0 Then
                    If inst_option = "" Then
                       tot13 = 0
                       For Tt = 1 To Pick.dcount(Pick.extract(extrapenalty, 13, clpos, 0), Chr(252))
                          tot13 = tot13 + Pick.extractcur(extrapenalty, 13, clpos, Tt)
                       Next Tt
                       If tot13 And all_paid = 0 Then
                          nx = nx + 1
                          nrec(1) = Pick.replace(nrec(1), 1, nx, 0, "  ")
                          nrec(2) = Pick.replace(nrec(2), 1, nx, 0, "Extra penalty to " & Cur_Date) 'date
                          nrec(7) = Pick.replace(nrec(7), 1, nx, 0, CStr(tot13))
                       End If
                       morepenalty = Pick.extractcur(extrapenalty, 14, clpos, special) - Pick.extractcur(insts, Adj + 7, 3, 0)
                       If morepenalty <> 0 Then
                          nx = nx + 1
                          nrec(1) = Pick.replace(nrec(1), 1, nx, 0, "  ")
                          nrec(2) = Pick.replace(nrec(2), 1, nx, 0, "Extra penalty on arrears to " & Cur_Date) 'date
                          nrec(7) = Pick.replace(nrec(7), 1, nx, 0, CStr(morepenalty))
                          nx = nx + 1
                          nrec(1) = Pick.replace(nrec(1), 1, nx, 0, "  ")
                          nrec(2) = Pick.replace(nrec(2), 1, nx, 0, "Total with extra penalty on arrears to " & Cur_Date) 'date
                          nrec(7) = Pick.replace(nrec(7), 1, nx, 0, CStr(morepenalty + total_due_save3))
                       End If
                    End If
'                 End If
                 takenup = 0: theattr = Adj: Interim = Pick.extract(insts, Adj + 11, 0, 0): inopt = pln: GoSub 2950
                 If Interim <> "1" Then uadj = -6 Else uadj = 0
                 temp = Pick.extract(inst_totals, 8 + uadj, usejj, 0)
                 If IsNumeric(temp) Then temp = CStr(CCur(temp) + total_due_save) Else temp = CStr(total_due_save)
                 inst_totals = Pick.replace(inst_totals, 8 + uadj, usejj, 0, temp)
                 temp = Pick.extract(inst_totals, 9 + uadj, usejj, 0)
                 If IsNumeric(temp) Then tempcur = CCur(temp) Else tempcur = 0
                 temp = Pick.extract(insts, 3 + uadj, 1, 0)
                 If IsNumeric(temp) Then tempcur = tempcur + CCur(temp)
                 temp = Pick.extract(insts, 4 + uadj, 1, 0)
                 If IsNumeric(temp) Then tempcur = tempcur + CCur(temp)
                 inst_totals = Pick.replace(inst_totals, 9 + uadj, usejj, 0, CStr(tempcur))
                 temp = Pick.extract(inst_totals, 10 + uadj, usejj, 0)
                 If IsNumeric(temp) Then temp = CStr(CCur(temp) + total_due_save3) Else temp = CStr(total_due_save3)
                 inst_totals = Pick.replace(inst_totals, 10 + uadj, usejj, 0, temp)
210           Next aa
220:
           End If
        Next Ii
     End If
'
     max_nx = nx
     If allow_display = 1 Then
        If max_props > 1 Then
           For Jj = 1 To Pick.dcount(Pick.extract(inst_totals, 2, 0, 0), Chr(253))
              temp = Pick.extract(inst_totals, 2, Jj, 0)
              If IsNumeric(temp) Then total_base = CCur(temp) Else total_base = 0
              temp = Pick.extract(inst_totals, 3, Jj, 0)
              If IsNumeric(temp) Then total_chgs = CCur(temp) Else total_chgs = 0
              temp = Pick.extract(inst_totals, 4, Jj, 0)
              If IsNumeric(temp) Then total_ndue = CCur(temp) Else total_ndue = 0
              If total_base <> 0 Or total_chgs <> 0 Or total_ndue <> 0 Then
                 nx = nx + 1
                 nrec(1) = Pick.replace(nrec(1), 1, nx, 0, " ")
'                 IF JJ=MAX.INSTALL+1 THEN
'                    NREC<2,NX>='n/a'
'                 END ELSE
                    nrec(2) = Pick.replace(nrec(2), 1, nx, 0, "Total for " & Pick.extract(inst_totals, 1, Jj, 0))
'                 END
                 nrec(5) = Pick.replace(nrec(5), 1, nx, 0, CStr(total_base))
                 nrec(6) = Pick.replace(nrec(6), 1, nx, 0, CStr(total_chgs))
                 nrec(7) = Pick.replace(nrec(7), 1, nx, 0, CStr(total_ndue))
              End If
           Next Jj
           For Jj = 1 To max_install
              temp = Pick.extract(inst_totals, 8, Jj, 0)
              If IsNumeric(temp) Then total_base = CCur(temp) Else total_base = 0
              temp = Pick.extract(inst_totals, 9, Jj, 0)
              If IsNumeric(temp) Then total_chgs = CCur(temp) Else total_chgs = 0
              temp = Pick.extract(inst_totals, 10, Jj, 0)
              If IsNumeric(temp) Then total_ndue = CCur(temp) Else total_ndue = 0
              If total_base <> 0 Or total_chgs <> 0 Or total_ndue <> 0 Then
                 nx = nx + 1
                 nrec(1) = Pick.replace(nrec(1), 1, nx, 0, " ")
                 nrec(2) = Pick.replace(nrec(2), 1, nx, 0, "Total interim " & Pick.extract(inst_totals, 1, Jj, 0))
                 nrec(3) = Pick.replace(nrec(5), 1, nx, 0, CStr(total_base))
                 nrec(4) = Pick.replace(nrec(6), 1, nx, 0, CStr(total_chgs))
                 nrec(5) = Pick.replace(nrec(7), 1, nx, 0, CStr(total_ndue))
                 use_assess = " "
              End If
           Next Jj
        End If
    End If
    Exit Sub
''
' s/r 2900:  extract nominated FIRST instalment payment details
'
2950:
     posn = Pick.locate(inopt, inst_totals, 1, 1, 0, usejj, "")
     If posn = 0 Then
     'LOCATE(INOPT,INST_TOTALS,1,1,0,USEJJ,"") ELSE
        inst_totals = Pick.replace(inst_totals, 1, usejj, 0, inopt)
     End If
     temp = Pick.extract(inst_totals, 2, usejj, 0)
     If IsNumeric(temp) Then tempcur = CCur(temp) Else tempcur = 0
     tempcur = tempcur + inst_payment
     inst_totals = Pick.replace(inst_totals, 2, usejj, 0, CStr(tempcur))
     temp = Pick.extract(inst_totals, 3, usejj, 0)
     If IsNumeric(temp) Then tempcur = CCur(temp) Else tempcur = 0
     tempcur = tempcur + inst_charges
     inst_totals = Pick.replace(inst_totals, 3, usejj, 0, CStr(tempcur))
     temp = Pick.extract(inst_totals, 4, usejj, 0)
     If IsNumeric(temp) Then tempcur = CCur(temp) Else tempcur = 0
     tempcur = tempcur + total_due
     inst_totals = Pick.replace(inst_totals, 4, usejj, 0, CStr(tempcur))
     pix = Pick.dcount(Pick.extract(inst_totals, 5, usejj, 0), Chr(252)) + 1
     inst_totals = Pick.replace(inst_totals, 5, usejj, pix, ASSESS_NO)
     inst_totals = Pick.replace(inst_totals, 6, usejj, pix, CStr(total_due))
     inst_totals = Pick.replace(inst_totals, 7, usejj, pix, CStr(Apply_Install))
     inst_totals = Pick.replace(inst_totals, 11, usejj, pix, Interim)
     inst_totals = Pick.replace(inst_totals, 12, usejj, pix, CStr(theattr))
     inst_totals = Pick.replace(inst_totals, 13, usejj, pix, CStr(takenup))
     inst_totals = Pick.replace(inst_totals, 14, usejj, pix, CStr(fullpay))
     inst_totals = Pick.replace(inst_totals, 15, usejj, pix, installs_left)
     inst_totals = Pick.replace(inst_totals, 16, usejj, pix, CStr(morepenalty))
     inst_totals = Pick.replace(inst_totals, 17, usejj, pix, CStr(fullpay_date))
     Return
'
's/r 3000: check if there is an instalment balance
'
3000 insbal = 0: tot_insbal = 0
     If d3.d3_readstr(database, d_rec, "TDEBTOR", ASSESS_NO) <> 0 Then d_rec = ""
     INSTAL_NO = Pick.extractint(d_rec, 85, 0, 0)
     For LP = 1 To INSTAL_NO
       insbal = Pick.extract(d_rec, 90, LP, 0) - Pick.extract(d_rec, 92, LP, 0)
       If insbal Then tot_insbal = tot_insbal + insbal
     Next LP
     Return

End Sub
Public Sub ta1642(the_drive As String, logentry As String, vrec() As String, Cur_Date As String, ids As String, Flags As String)

' TA1642 PRINT PROPERTY FINANCIAL STATEMENTS
' ids has all the assess ids to be done
'     if null means select PR.PROP.STMT for request ids and get assessments from there
' disc_date is last date for allowing discount
'     Call PICKWT(PR_PROP_STMT_DICT, "@DEFAULT", 3, default, 0)
    
Dim cnt As Integer, temp As String, arrdate As Integer, Td As Integer
Dim Assess As String, Client_No As String, fee As String, date_printed As String, proposed_settle As String
Dim paddr1 As String, paddr2 As String, Rcode As String, R_Desc As String, save_desc As String
Dim PROP_REC As String, Ans As String, Id As String, Prec As String
Dim one As String, rpos As Integer, Jj As Integer, Client_Rec As String
Dim pvalue As String, vendifor1 As String, vendifor2 As String, purchaser1 As String, purchaser2 As String
Dim Eom As String, multi As Integer, inpr As Integer
Dim Name As String, Addr1 As String, Addr2 As String, as_at, one_day As Currency
Dim tot As Currency, tot_rebate As Currency, tot_disc As Currency, Cc As Integer
Dim Current As String, arrears As String, Cr_Rec As String
Dim penalties As String, others As String
Dim Paid As String, disc As String, adisc As String, arebate As String, Stot As String
Dim billed As String, detail1 As String, detail2 As String, detail3 As String, detail4 As String
Dim value1 As String, value2 As String, value3 As String, value4 As String
Dim tempval As Currency, tempval2 As Currency
Dim interest1 As String, interest2 As String, interest3 As String
Dim rebate As String
Dim insurance1 As String, insurance2 As String, disc_date2 As Integer
Dim disc2 As String, MAX_CAT As Integer, I As Integer
Dim the_file As String, rdesc As String, Pos As Integer
Dim the_rec() As String, rderr As Integer, writeerror As Integer
Dim disc_given As String, totalpayable As String, rateflag As String
Dim maxr As Integer, r As Integer, lcode As String, codes As String, divis As String, rules As String
Dim tempvrec() As String, vcnt As Integer, selecting As Integer, flattr As Integer
Dim print_ctl As String, J As Integer, other As Integer
Dim eoy_date As String, Yy As String, totdisc As Currency
Dim DISC_DATE As Integer
Dim calc_rebate As Currency, calc_rebate_disc As Currency, pr As Integer, calc_disc As Currency, Ii As Integer
Dim Pcnt As Integer, Pp As Integer, P As Integer, plan_rec As String, iname As String
Dim catg As String, sc As Integer
Dim fnum As Integer, database As String
    
    database = Pick.extract(logentry, 2, 0, 0)
    
    DISC_DATE = 11932 '31/8/00???

    ReDim vrec(61): vcnt = 0
    'Server.MapPath("\prospect\template\")
    vrec(61) = the_drive & "/prospect_site/mergefiles/" & "property_settlement" & ".txt"
    fnum = FreeFile
    Open vrec(61) For Output Access Write As #fnum
    Call sr682_ctl(database, print_ctl, R_Desc, MAX_CAT, flattr)
    For Jj = 1 To MAX_CAT
       catg = Pick.extract(print_ctl, Jj, 1, 0)
       If catg = "" Then catg = "XX" ' last charge for all sundry items
       Write #fnum, catg & "cat_desc", catg & "curr_to_date", catg & "current", catg & "arr_to_date", catg & "arrears", catg & "penalty", catg & "other", catg & "less_paid", catg & "less_prev_disc", catg & "less_prev_rebate", catg & "total_due", catg & "disc_if_paid_by_date", catg & "disc_if_paid_by_value", catg & "less_pens_rebate",
    Next Jj
    Write #fnum, "date", "applicant", "address1", "address2", "propaddress1", "propaddress2", "assessment", "vendifor1", "vendifor2", "purchaser1", "purchaser2", "interest1", "interest2", "interest3", "totalpayable", "insurance1", "insurance2", "rateflag", "settle_date"

    If ids = "" Then 'select all the ones required from PR.PROP.STMT
       selecting = 1
'      MSG="SSELECT PR.PROP.STMT BY APPLICANT WITH NO DATE.PRINTED"
    Else
       selecting = 0
    End If
'     If d3.d3_readstr(database,DISCRATE, "DICT TDEBTOR", "@DISC") <> 0 Then DISCRATE = ""
'     HAS_TD_VALUE = 0
'     council = pick.extract(TRANS_INFO, 92, 0, 0)
'     If council Then
'        HAS_TD_VALUE = 1
'     End If
      If UBound(g_trans_info_array) = 0 Then
         g_trans_info_array(0) = "TRANS.INFO"
         rderr = d3.d3_readmat(database, g_trans_info_array(), "DICT TRANS.J")
      End If
      If UBound(g_trans_info_array) < 59 Then temp = "" Else temp = g_trans_info_array(59)
      temp = Pick.extract(temp, 1, 3, 0)
      If IsNumeric(temp) Then arrdate = CInt(temp) Else arrdate = 0
'
'     GL_JOB = pick.extract(TRANS_INFO, 70, 4, 0) & Chr(253) & pick.extract(TRANS_INFO, 70, 5, 0)
'     Controls = pick.extract(TRANS_INFO, 4, 0, 0) & Chr(253) & pick.extract(TRANS_INFO, 12, 0, 0) & Chr(253) & pick.extract(TRANS_INFO, 13, 0, 0) & Chr(253) & pick.extract(TRANS_INFO, 14, 0, 0) & Chr(253) & pick.extract(TRANS_INFO, 31, 0, 0)
'     LOCATE("????",CONTROLS,1,1,0,ANS,"") ELSE NULL
'     For ii = ans To 1 Step -1
'        If pick.extract(Controls, 1, ii, 0) = "" Then Controls = pick.delet(Controls, 1, ii, 0)
'     Next ii
'     If d3.d3_readstr(database,REBATE_PERC, "DICT TRANS.J", "@STATE_REBATE") <> 0 Then REBATE_PERC = ""
'     REBATE_PERC = pick.extract(REBATE_PERC, 4, 1, 0)
'     IF REBATE_PERC = "" THEN REBATE_PERC = 0_5
'     P_FLAG = Mid$((pick.extract(TRANS_INFO, 53, 0, 0)), 17, 1) + 0
'     EXTRA = Mid$((pick.extract(TRANS_INFO, 53, 0, 0)), 24, 1) + 0
'     ARDATE = oconv(arrdate, "D2")
'     WATER = pick.extract(TRANS_INFO, 126, 1, 0) + 0
'     If WATER <> 2 Then WATER = 0
'     HASPLANS = 1
'     OPEN "","PLANS" TO PLANS_DATA ELSE HASPLANS=0
'     OPEN "","BUILD_CODES" TO BUILD_CODES_DATA ELSE HASPLANS=0
'     TR_CR = 25: TR_DR = 50
'
     cnt = Pick.dcount(Pick.extract(ids, 1, 0, 0), Chr(253))
'
'     If d3.d3_readstr(database,default, "DICT PR.PROP.STMT", "@DEFAULT") <> 0 Then default = ""
'     If pick.extract(default, 2, 0, 0) = "" Then default = pick.Replace(default, 2, 0, 0, oconv(arrdate, "D2"))
'
'     msg = "General ledger account for fees raised &  "
'200  Call SRIP(0, 7, msg, GLFEEAC, CLEARS, pick.extract(default, 1, 0, 0), "", "", "")
'     IF GLFEEAC="ENDIF" THEN PRINT ERASE & : STOP
'     Call SR_GL(GEN_L_DATA, Controls, GLFEEAC, GL_JOB, GL_JOB_DATA, GLNAME, ERRFLG, "", GSTEXP, "", ""): If ERRFLG Then GoTo 200
'     default = pick.Replace(default, 1, 0, 0, GLFEEAC)
'
'210  Call SRIP(0, 9, "Enter date (exclusive) before which rates will be in arrears &  ", ans, CLEARS, pick.extract(default, 2, 0, 0), "", "D_ENDIF", "")
'     IF ANS = "ENDIF" THEN PRINT ERASE: STOP
'     default = pick.Replace(default, 2, 0, 0, ans)
'     arrdate = ICONV(ans, "D2")
     eoy_date = DateAdd("d", -1, CVar(Pick.date_pick_to_vb(val(arrdate))))
     eoy_date = DateAdd("yyyy", 1, CVar(eoy_date))
     Yy = DatePart("yyyy", CVar(Pick.date_pick_to_vb(val(arrdate))))
     Yy = Right(Yy, 2)
     eoy_date = Format(eoy_date, "dd mmm yy")
     
     For Td = 1 To cnt
        Id = Pick.extract(ids, 1, Td, 0)
        vcnt = vcnt + 1
        vrec(1) = Pick.insert(vrec(1), 1, vcnt, 0, Id)
        vrec(2) = Pick.insert(vrec(2), 1, vcnt, 0, Format(Date, "DD MMM YY"))
        If selecting = 1 Then
           inpr = 1
           If d3.d3_readstr(database, Prec, "PR.PROP.STMT", Id) <> 0 Then
              inpr = 0
              If d3.d3_readstr(database, Prec, "PROP.STMT", Id) <> 0 Then inpr = 2: GoTo 299
           End If
           Assess = Pick.extract(Prec, 1, 1, 0)
           Client_No = Pick.extract(Prec, 2, 0, 0)
           fee = Pick.extract(Prec, 5, 0, 0)
           date_printed = Pick.extract(Prec, 6, 0, 0)
           proposed_settle = Pick.extract(Prec, 7, 0, 0)
        Else
           Assess = Id: Client_No = "": fee = "": date_printed = ""
           Jj = Pick.date_vb_to_pick(Day(Cur_Date) & "/" & Month(Cur_Date) & "/" & Year(Cur_Date), proposed_settle, 0)
        End If
        proposed_settle = Format(Pick.date_pick_to_vb(val(proposed_settle)), "dd mmm yy")
        save_desc = R_Desc
        If d3.d3_readstr(database, Client_Rec, "CLIENT", Assess) <> 0 Then Client_Rec = ""
        paddr1 = Pick.extract(Client_Rec, 2, 1, 0)
        paddr2 = Pick.trimm(Pick.extract(Client_Rec, 3, 1, 0) & " " & Pick.extract(Client_Rec, 4, 1, 0))
        
        If d3.d3_readstr(database, PROP_REC, "PROPERTY", Assess) <> 0 Then PROP_REC = ""
        If Pick.extract(PROP_REC, 1, 1, 0) <> "" Then paddr1 = "LOT " & Pick.extract(PROP_REC, 1, 1, 0) & ", " & paddr1
        one = "1"
        Jj = Pick.locate(one, PROP_REC, 29, 1, 0, rpos, "")
        Rcode = Pick.extract(PROP_REC, 19, rpos, 0): pvalue = Pick.extract(PROP_REC, 15, rpos, 0)
        
        If d3.d3_readstr(database, Ans, "CLIENT", Pick.extract(Client_Rec, 35, 1, 0)) <> 0 Then Ans = ""
        vendifor1 = Pick.extract(Ans, 1, 0, 0) & " " & Pick.extract(Ans, 6, 0, 0)
        If d3.d3_readstr(database, Ans, "CLIENT", Pick.extract(Client_Rec, 35, 2, 0)) <> 0 Then Ans = ""
        vendifor2 = Pick.extract(Ans, 1, 0, 0) & " " & Pick.extract(Ans, 6, 0, 0)
        If selecting = 1 Then
           If d3.d3_readstr(database, Ans, "CLIENT", Pick.extract(Prec, 8, 1, 0)) <> 0 Then Ans = ""
           purchaser1 = Pick.extract(Ans, 1, 0, 0) & " " & Pick.extract(Ans, 6, 0, 0)
           If d3.d3_readstr(database, Ans, "CLIENT", Pick.extract(Prec, 8, 2, 0)) <> 0 Then Ans = ""
           purchaser2 = Pick.extract(Ans, 1, 0, 0) & " " & Pick.extract(Ans, 6, 0, 0)
        Else
           purchaser1 = "": purchaser2 = ""
        End If
        If d3.d3_readstr(database, Cr_Rec, "TDEBTOR", Assess) <> 0 Then Cr_Rec = ""
        Eom = ""
        Call SR682(database, Cr_Rec, Assess, arrdate, 0, 0, Eom, "", 6, print_ctl, "", other)
        multi = 0
'
250     If Client_No <> "" Then
           If d3.d3_readstr(database, Ans, "CLIENT", Client_No) <> 0 Then Ans = ""
           Name = Pick.trimm(Pick.extract(Ans, 8, 0, 0) & " " & Pick.extract(Ans, 7, 0, 0) & " " & Pick.extract(Ans, 1, 0, 0))
           Addr1 = Pick.extract(Ans, 2, 1, 0)
           Addr2 = Pick.trimm(Pick.extract(Ans, 3, 1, 0) & " " & Pick.extract(Ans, 4, 1, 0) & " " & Pick.extract(Ans, 5, 1, 0))
        Else
           Name = "": Addr1 = "": Addr2 = ""
        End If
' ADDED FOR INTEREST ON OVERDUE
        Jj = Pick.date_vb_to_pick(Day(Date) & "/" & Month(Date) & "/" & Year(Date), as_at, 0)
        as_at = as_at + 1
        Call sr1694(logentry, tempvrec(), CStr(as_at), Assess, "")
        temp = tempvrec(16)
        as_at = as_at - 1
        Call sr1694(logentry, tempvrec(), CStr(as_at), Assess, "")
        one_day = CCur(temp) - CCur(tempvrec(16))
'
        tot = 0: tot_rebate = 0: tot_disc = 0
        Cc = 0
        rdesc = "": Current = "": arrears = "": penalties = "": others = "": rebate = ""
        Paid = "": disc = "":  adisc = "": arebate = "": Stot = "": billed = "": disc_given = ""
        insurance1 = "": insurance2 = ""
        disc_date2 = DISC_DATE
        disc2 = ""

        For I = 1 To MAX_CAT
           For J = 1 To 9
              If Pick.extract(Eom, 2, I, J) <> "" Or Pick.extract(Eom, 1, I, J) <> "" Then GoTo 270
           Next J
           GoTo 289
270        Cc = Cc + 1
           Current = Pick.replace(Current, Cc, 0, 0, Pick.extract(Eom, 2, I, 1))
           arrears = Pick.replace(arrears, Cc, 0, 0, Pick.extract(Eom, 1, I, 1))
           If IsNumeric(Pick.extract(Eom, 2, I, 6)) Then tempval = CCur(Pick.extract(Eom, 2, I, 6)) Else tempval = 0
           If IsNumeric(Pick.extract(Eom, 1, I, 6)) Then tempval = tempval + CCur(Pick.extract(Eom, 1, I, 6))
           If IsNumeric(Pick.extract(Eom, 2, I, 3)) Then tempval = tempval + CCur(Pick.extract(Eom, 2, I, 3))
           Paid = Pick.replace(Paid, Cc, 0, 0, CStr(tempval)) ' include discount given
           
           disc_given = Pick.replace(disc_given, Cc, 0, 0, Pick.extract(Eom, 2, I, 3))
           disc = Pick.replace(disc, Cc, 0, 0, "0") '   DISC<CC>=EOM<2,I,3>+0)
           adisc = Pick.replace(adisc, Cc, 0, 0, Pick.extract(Eom, 1, I, 3))
           If disc_date2 < CInt(as_at) Then
              If IsNumeric(Pick.extract(adisc, Cc, 0, 0)) Then tempval = CCur(Pick.extract(adisc, Cc, 0, 0)) Else tempval = 0
              If IsNumeric(Pick.extract(disc, Cc, 0, 0)) Then tempval = tempval + CCur(Pick.extract(disc, Cc, 0, 0))
              adisc = Pick.replace(adisc, Cc, 0, 0, CStr(tempval))
              disc2 = Pick.replace(disc2, Cc, 0, 0, Pick.extract(disc, Cc, 0, 0))
              disc = Pick.replace(disc, Cc, 0, 0, "0")
           End If
           rebate = Pick.replace(rebate, Cc, 0, 0, Pick.extract(Eom, 2, I, 2))
           arebate = Pick.replace(arebate, Cc, 0, 0, Pick.extract(Eom, 1, I, 2))
           If IsNumeric(Pick.extract(Eom, 2, I, 7)) Then tempval = CCur(Pick.extract(Eom, 2, I, 7)) Else tempval = 0
           If IsNumeric(Pick.extract(Eom, 1, I, 7)) Then tempval = tempval + CCur(Pick.extract(Eom, 1, I, 7))
           penalties = Pick.replace(penalties, Cc, 0, 0, CStr(tempval))
           If IsNumeric(Pick.extract(Eom, 2, I, 4)) Then tempval = CCur(Pick.extract(Eom, 2, I, 4)) Else tempval = 0
           If IsNumeric(Pick.extract(Eom, 1, I, 4)) Then tempval = tempval + CCur(Pick.extract(Eom, 1, I, 4))
           If IsNumeric(Pick.extract(Eom, 2, I, 5)) Then tempval = tempval + CCur(Pick.extract(Eom, 2, I, 5))
           If IsNumeric(Pick.extract(Eom, 1, I, 5)) Then tempval = tempval + CCur(Pick.extract(Eom, 1, I, 5))
           If IsNumeric(Pick.extract(Eom, 2, I, 8)) Then tempval = tempval + CCur(Pick.extract(Eom, 2, I, 8))
           If IsNumeric(Pick.extract(Eom, 1, I, 8)) Then tempval = tempval + CCur(Pick.extract(Eom, 1, I, 8))
           others = Pick.replace(others, Cc, 0, 0, CStr(tempval))
           billed = Pick.replace(billed, Cc, 0, 0, eoy_date)
           pr = 0
           totdisc = 0
           Ii = 0: calc_rebate = 0: calc_rebate_disc = 0: calc_disc = 0
'              If WATER And i = max_cat Then
'                 NO_SUPPLY = pick.extract(client_rec, 11, 0, 0)
'                 For S = 1 To NO_SUPPLY
'                    If d3.d3_readstr(database,UT_REC, "UT.INSTALL", assess & "*" & S) <> 0 Then UT_REC = ""
'                    If S = 1 Then billed = pick.Replace(billed, cc, 0, 0, oconv(pick.extract(UT_REC, 21, 1, 0), "D2"))
 '                   INVNO = pick.extract(UT_REC, 23, 1, 0)
 '                   If d3.d3_readstr(database,ans, "INVOICE", INVNO) <> 0 Then ans = ""
 '                   If ans <> "" Then
'                       If S = 1 And pick.extract(ans, 43, 2, 0) <> "" Then disc_date2 = pick.extract(ans, 43, 2, 0)
'                       IF pick.extract(ANS,43,1,0)<>"" THEN CALC_DISC=CALC_DISC-INT(pick.extract(ANS,8,0,pick.extract(0)*ANS,43,1)/100+0_5)
'                       CALC_REBATE = pick.extract(CALC_REBATE - ans, 45, 2, 0)
'                       CALC_REBATE_DISC = pick.extract(CALC_REBATE_DISC - ans, 45, 3, 0)
'                    End If
'                 Next S
'              Else
265              If Ii Then
                    If d3.d3_readstr(database, Ans, "RATES", Pick.extract(print_ctl, I, 1, 0) & Yy - pr & "I-" & Ii & "*" & Assess) <> 0 Then Ans = ""
                    If Ans = "" And pr <> 1 Then pr = 1: Ii = 1: GoTo 265
                 Else
                    If d3.d3_readstr(database, Ans, "RATES", Pick.extract(print_ctl, I, 1, 0) & Yy & "*" & Assess) <> 0 Then Ans = ""
                    temp = Pick.extract(Ans, 21, 0, 0)
                    If IsNumeric(temp) Then calc_rebate = -1 * CCur(temp) Else calc_rebate = 0
                    temp = Pick.extract(Ans, 22, 0, 0)
                    If IsNumeric(temp) Then calc_rebate_disc = -1 * CCur(temp) Else calc_rebate_disc = 0
                    If Ans = "" Then Ii = Ii + 1: GoTo 265
                 End If
                 If Ans <> "" Then
                    If Pick.extract(Ans, 11, 0, 0) <> "" Then
                       If IsNumeric(Pick.extract(Ans, 11, 0, 0)) Then disc_date2 = CInt(Pick.extract(Ans, 11, 0, 0))
                    End If
                    If IsNumeric(Pick.extract(Ans, 2, 0, 0)) Then tempval = CCur(Pick.extract(Ans, 2, 0, 0)) Else tempval = 0
                    If IsNumeric(Pick.extract(Ans, 10, 0, 0)) Then
                        calc_disc = -1 * Int(tempval * CCur(Pick.extract(Ans, 10, 0, 0)) / 100 + 0.5)
                    End If
                    If disc_date2 > CInt(as_at) Then totdisc = totdisc + calc_disc: calc_disc = 0
                    Ii = Ii + 1: GoTo 265
                 End If
'              End If
              If IsNumeric(Pick.extract(disc, Cc, 0, 0)) Then tempval = CCur(Pick.extract(disc, Cc, 0, 0)) Else tempval = 0
              If tempval = 0 And disc_date2 >= CInt(as_at) Then
                 If IsNumeric(Pick.extract(disc2, Cc, 0, 0)) Then tempval = CCur(Pick.extract(disc2, Cc, 0, 0)) Else tempval = 0
                 disc = Pick.replace(disc, Cc, 0, 0, totdisc - tempval)
              End If
'           If WATER Then
'              If pick.extract(save_desc, I, 0, 0) = "Water" Then
'                 save_desc = pick.Replace(save_desc, I, 0, 0, "Rates")
'              Else
'                 If pick.extract(save_desc, I, 0, 0) = "Sundry" Then
'                    save_desc = pick.Replace(save_desc, I, 0, 0, "Water")
'                 Else
'                    If pick.extract(save_desc, I, 0, 0) = "Garbage" Then
'                       save_desc = pick.Replace(save_desc, I, 0, 0, "Rubbish")
'                    End If
'                 End If
'              End If

           rdesc = Pick.replace(rdesc, Cc, 0, 0, Pick.extract(save_desc, I, 0, 0))
           sc = 1: vrec(20 + Cc) = Pick.insert(vrec(20 + Cc), 1, vcnt, sc, Pick.extract(save_desc, I, 0, 0)) 'XXcat_desc
           sc = sc + 1: vrec(20 + Cc) = Pick.insert(vrec(20 + Cc), 1, vcnt, sc, Pick.extract(billed, Cc, 0, 0)) 'XXcurr_to_date
           If IsNumeric(Pick.extract(Current, Cc, 0, 0)) Then tempval = CCur(Pick.extract(Current, Cc, 0, 0)) / 100 Else tempval = 0
           sc = sc + 1: vrec(20 + Cc) = Pick.insert(vrec(20 + Cc), 1, vcnt, sc, Format(tempval, "$#0.00")) 'XXcurrent
           sc = sc + 1: vrec(20 + Cc) = Pick.insert(vrec(20 + Cc), 1, vcnt, sc, Format(Pick.date_pick_to_vb(val(arrdate)), "dd mmm yy")) 'XXarr_to_date
           If IsNumeric(Pick.extract(arrears, Cc, 0, 0)) Then tempval = CCur(Pick.extract(arrears, Cc, 0, 0)) / 100 Else tempval = 0
           sc = sc + 1: vrec(20 + Cc) = Pick.insert(vrec(20 + Cc), 1, vcnt, sc, Format(tempval, "$#0.00")) 'XXarrears
           If IsNumeric(Pick.extract(penalties, Cc, 0, 0)) Then tempval = CCur(Pick.extract(penalties, Cc, 0, 0)) / 100 Else tempval = 0
           sc = sc + 1: vrec(20 + Cc) = Pick.insert(vrec(20 + Cc), 1, vcnt, sc, Format(tempval, "$#0.00")) 'XXpenalty
           If IsNumeric(Pick.extract(others, Cc, 0, 0)) Then tempval = CCur(Pick.extract(others, Cc, 0, 0)) / 100 Else tempval = 0
           sc = sc + 1: vrec(20 + Cc) = Pick.insert(vrec(20 + Cc), 1, vcnt, sc, Format(tempval, "$#0.00")) 'XXother
           If IsNumeric(Pick.extract(rebate, Cc, 0, 0)) Then tempval = CCur(Pick.extract(rebate, Cc, 0, 0)) Else tempval = 0
           If tempval = 0 Then
              If IsNumeric(Pick.extract(disc, Cc, 0, 0)) Then tempval = CCur(Pick.extract(disc, Cc, 0, 0)) Else tempval = 0
              If tempval <> 0 Then rebate = Pick.replace(rebate, Cc, 0, 0, CStr(calc_rebate_disc)) Else rebate = Pick.replace(rebate, Cc, 0, 0, CStr(calc_rebate))
           End If
           If IsNumeric(Pick.extract(Paid, Cc, 0, 0)) Then tempval = CCur(Pick.extract(Paid, Cc, 0, 0)) Else tempval = 0
           sc = sc + 1: vrec(20 + Cc) = Pick.insert(vrec(20 + Cc), 1, vcnt, sc, Format(tempval / 100, "$#0.00")) 'XXless_paid
           If IsNumeric(Pick.extract(adisc, Cc, 0, 0)) Then tempval = CCur(Pick.extract(adisc, Cc, 0, 0)) Else tempval = 0
           sc = sc + 1: vrec(20 + Cc) = Pick.insert(vrec(20 + Cc), 1, vcnt, sc, Format(tempval / 100, "$#0.00")) 'XXless_prev_disc
           If IsNumeric(Pick.extract(arebate, Cc, 0, 0)) Then tempval = CCur(Pick.extract(arebate, Cc, 0, 0)) Else tempval = 0
           sc = sc + 1: vrec(20 + Cc) = Pick.insert(vrec(20 + Cc), 1, vcnt, sc, Format(tempval / 100, "$#0.00")) 'XXless_prev_rebate
           tempval = 0
           If IsNumeric(Pick.extract(Eom, 2, I, 1)) Then tempval = tempval + CCur(Pick.extract(Eom, 2, I, 1))
           If IsNumeric(Pick.extract(Eom, 1, I, 1)) Then tempval = tempval + CCur(Pick.extract(Eom, 1, I, 1))
           If IsNumeric(Pick.extract(penalties, Cc, 0, 0)) Then tempval = tempval + CCur(Pick.extract(penalties, Cc, 0, 0))
           If IsNumeric(Pick.extract(others, Cc, 0, 0)) Then tempval = tempval + CCur(Pick.extract(others, Cc, 0, 0))
           If IsNumeric(Pick.extract(Paid, Cc, 0, 0)) Then tempval = tempval + CCur(Pick.extract(Paid, Cc, 0, 0))
           If IsNumeric(Pick.extract(adisc, Cc, 0, 0)) Then tempval = tempval + CCur(Pick.extract(adisc, Cc, 0, 0))
           If IsNumeric(Pick.extract(arebate, Cc, 0, 0)) Then tempval = tempval + CCur(Pick.extract(arebate, Cc, 0, 0))
           Stot = Pick.replace(Stot, Cc, 0, 0, CStr(tempval))
           sc = sc + 1: vrec(20 + Cc) = Pick.insert(vrec(20 + Cc), 1, vcnt, sc, Format(tempval / 100, "$#0.00")) 'XXtotal_due
           If IsNumeric(Pick.extract(disc, Cc, 0, 0)) Then tempval = CCur(Pick.extract(disc, Cc, 0, 0)) Else tempval = 0
           If IsNumeric(Pick.extract(disc_given, Cc, 0, 0)) Then tempval2 = CCur(Pick.extract(disc_given, Cc, 0, 0)) Else tempval2 = 0
           If tempval <> tempval2 Then
              tot_disc = tot_disc + tempval
           Else
              tempval = 0
           End If
           sc = sc + 1: vrec(20 + Cc) = Pick.insert(vrec(20 + Cc), 1, vcnt, sc, Format(Pick.date_pick_to_vb(val(disc_date2)), "dd mmm yy"))  'XXdisc_if_paid_by_date
           sc = sc + 1: vrec(20 + Cc) = Pick.insert(vrec(20 + Cc), 1, vcnt, sc, Format(tempval / -100, "$#0.00")) 'XXdisc_if_paid_by_value
           
           If IsNumeric(Pick.extract(Stot, Cc, 0, 0)) Then tempval = CCur(Pick.extract(Stot, Cc, 0, 0)) Else tempval = 0
           If tempval < "100" And tempval > "-100" Then rebate = Pick.replace(rebate, Cc, 0, 0, "0")
           tot = tot + tempval
           If IsNumeric(Pick.extract(rebate, Cc, 0, 0)) Then tempval = CCur(Pick.extract(rebate, Cc, 0, 0)): tot = tot + tempval Else tempval = 0
           sc = sc + 1: vrec(20 + Cc) = Pick.insert(vrec(20 + Cc), 1, vcnt, sc, Format(tempval / 100, "$#0.00")) 'XXLess_pens_rebate
289     Next I
        For I = 1 To Cc
           For P = 1 To sc
              Write #fnum, Pick.extract(vrec(20 + I), 1, vcnt, P),
           Next P
        Next I
        
        Pcnt = Pick.dcount(Pick.extract(Client_Rec, 51, 0, 0), Chr(253))
        Pp = 0
        For P = 1 To Pcnt
           If d3.d3_readstr(database, plan_rec, "PLANS", Pick.extract(Client_Rec, 51, P, 0)) <> 0 Then plan_rec = ""
           If Pick.extract(plan_rec, 68, 0, 0) <> "" Then
              If Pp = 0 Then insurance1 = "HOME INDEMNITY INSURANCE"
              Pp = Pp + 1
              insurance1 = insurance1 & Chr(10) & "  Insurer"
              If d3.d3_readstr(database, iname, "BUILD.CODES", "@IN_" & Pick.extract(plan_rec, 66, 0, 0)) <> 0 Then iname = Pick.extract(plan_rec, 66, 0, 0)
              iname = Pick.extract(iname, 1, 0, 0)
              insurance2 = insurance2 & Chr(10) & iname
              insurance1 = insurance1 & Chr(10) & "  Certificate Number "
              insurance2 = insurance2 & Chr(10) & Pick.extract(plan_rec, 67, 0, 0)
              insurance1 = insurance1 & Chr(10) & "  Issue Date"
              insurance2 = insurance2 & Chr(10) & Format(Pick.date_pick_to_vb(val(Pick.extract(plan_rec, 68, 0, 0))), "DD MMM YY")
              If Pick.extract(plan_rec, 69, 0, 0) <> "" Then
                 insurance1 = insurance1 & Chr(10) & "  Expiry Date"
                 insurance2 = insurance2 & Chr(10) & Format(Pick.date_pick_to_vb(val(Pick.extract(plan_rec, 69, 0, 0))), "DD MMM YY")
              End If
              insurance1 = insurance1 & Chr(10) & "  Amount of Cover"
              insurance2 = insurance2 & Chr(10) & "$" & Pick.extract(plan_rec, 70, 0, 0)
            End If
        Next P
' ADDED FOR INTEREST ON OVERDUE
        If tempvrec(16) <> "" Then
           interest1 = "INTEREST ON OVERDUE"
           interest2 = "Charges to " & Format(Pick.date_pick_to_vb(val(as_at)), "DD MMM YY") & " " & Format(tempvrec(16), "$######0.00")
           interest3 = "(Interest accruing at " & Format(one_day, "$######0.00") & " per day)"
           tot = tot + CCur(tempvrec(16))
        Else
           interest1 = "": interest2 = "": interest3 = ""
        End If
        tot = tot + tot_disc
        If tot_disc <> 0 And disc_date2 < CInt(as_at) Then
           totalpayable = "TOTAL AMOUNT PAYABLE by " & Format(Pick.date_pick_to_vb(val(disc_date2)), "dd mmm yy") & " is " & Format(tot / 100, "$######0.00")
        Else
           totalpayable = "TOTAL AMOUNT PAYABLE is " & Format(tot / 100, "$######0.00")
        End If
           rateflag = ""
           If d3.d3_readstr(database, rules, "DICT PR.PROP.STMT", "@RULES") <> 0 Then rules = ""
           If rules <> "" Then
              maxr = Pick.dcount(Pick.extract(rules, 1, 0, 0), Chr(253))
              For r = 1 To maxr
                 lcode = Pick.extract(rules, 1, r, 0)
                 codes = Pick.extract(rules, 2, r, 0)
                 divis = Pick.extract(rules, 3, r, 0)
                 Jj = Pick.locate(Rcode, codes, 1, 1, 1, rpos, "")
                 If Jj <> 0 Then
                    If divis = "Y" Then
                       If pvalue Mod 52 = 0 Then rateflag = lcode
                    Else
                       If divis = "N" Then
                          If pvalue Mod 52 <> 0 Then rateflag = lcode
                       Else
                          rateflag = lcode
                       End If
                    End If
                 End If
                 If rateflag = "" Then Exit For
              Next r
           End If
           Write #fnum, Format(Date, "DD MMM YY"), Name, Addr1, Addr2, paddr1, paddr2, Assess, vendifor1, vendifor2, purchaser1, purchaser2, interest1, interest2, interest3, totalpayable, insurance1, insurance2, rateflag,
           If Td = cnt Then 'this is done because if one uses a write then a cr lf is written and the WORD objects that there is a null record after the last record written
              Print #fnum, """" & proposed_settle & """";
           Else
              Write #fnum, proposed_settle
           End If
           
        If multi = 0 And date_printed = "" And selecting = 0 Then GoSub 300
        If selecting = 0 Then GoTo 299
        multi = multi + 1
        If Pick.extract(Prec, 3, multi, 0) <> "" Then
           Client_No = Pick.extract(Prec, 3, multi, 0)
           GoTo 250
        End If
        If date_printed <> "" Then    ' reprint
           Jj = Pick.locate(CStr(as_at), Prec, 6, 1, 0, Pos, "")
           If Jj = 0 Then
              ReDim the_rec(0)
              the_rec(0) = Id
              If inpr = 1 Then the_file = "PR.PROP.STMT" Else the_file = "PROP.STMT"
              rderr = d3.d3_readmat(database, the_rec(), the_file)
              If rderr <> 0 Then GoTo 299
              If UBound(the_rec) < 6 Then ReDim the_rec(6)
              the_rec(6) = Pick.insert(the_rec(6), 1, -1, 0, temp)
              writeerror = d3.d3_writemat(database, the_file, the_rec())
           End If
        End If
299     If inpr <> 2 Then
           vrec(3) = Pick.insert(vrec(3), 1, vcnt, 0, Name)
           vrec(4) = Pick.insert(vrec(4), 1, vcnt, 0, Addr1)
           vrec(5) = Pick.insert(vrec(5), 1, vcnt, 0, Addr2)
           vrec(6) = Pick.insert(vrec(6), 1, vcnt, 0, paddr1)
           vrec(7) = Pick.insert(vrec(7), 1, vcnt, 0, paddr2)
           vrec(8) = Pick.insert(vrec(8), 1, vcnt, 0, Assess)
           vrec(9) = Pick.insert(vrec(9), 1, vcnt, 0, vendifor1)
           vrec(10) = Pick.insert(vrec(10), 1, vcnt, 0, vendifor2)
           vrec(11) = Pick.insert(vrec(11), 1, vcnt, 0, purchaser1)
           vrec(12) = Pick.insert(vrec(12), 1, vcnt, 0, purchaser2)
           vrec(13) = Pick.insert(vrec(13), 1, vcnt, 0, interest1)
           vrec(14) = Pick.insert(vrec(14), 1, vcnt, 0, interest2)
           vrec(15) = Pick.insert(vrec(15), 1, vcnt, 0, interest3)
           vrec(16) = Pick.insert(vrec(16), 1, vcnt, 0, totalpayable)
           vrec(17) = Pick.insert(vrec(17), 1, vcnt, 0, replace(insurance1, Chr(10), Chr(252)))
           vrec(18) = Pick.insert(vrec(18), 1, vcnt, 0, replace(insurance2, Chr(10), Chr(252)))
           vrec(19) = Pick.insert(vrec(19), 1, vcnt, 0, rateflag)
           vrec(20) = Pick.insert(vrec(20), 1, vcnt, 0, proposed_settle)
        End If
        
     Next Td
     Close #fnum
     Exit Sub
     
300  If Not IsNumeric(fee) Then GoTo 410
     If CCur(fee) <= 0 Then GoTo 410
'     TRINVDATE = ICONV(Format$(Now, "DD MMM YY"), "D2")
'     tr_inv_date = ICONV(Format$(Now, "DD MMM YY"), "D2")
'     TR_INV_REF = "PS" & id
'318  If d3.d3_readstr(database,td_rec, "TDEBTOR", client_no) <> 0 Then
'        Release TDEBTOR_DATA, client_no
'        ptl = "DEBTOR " & client_no & " DOES NOT EXIST"
'319     PRINT @(0,23) & PTL & : INPUT A &
'$INSERT I.QU.REC
'        Return
'     End If
'$INSERT I.LOG.UPDATE '|TDEBTOR|':CLIENT.NO 318 TD.REC
'     narr = "Statement for " & assess
'     Call SR310(RR_LOG_DICT, B4_LOG_DICT, TRINVDATE, TNO, PROG, LOG_ENTRY, client_no, TDEBTOR_DATA, TD_OFLOW_DATA, td_rec, TR_INV_REF, tr_inv_date, fee, TR_DR, narr, TRANS_INFO, "", "", DEBT_CONT, "", ACCOUNT,g_trans_info_array(14))
'
'     MAT TJDATA = ""
'     tjac = DEBT_CONT: tjjob = 0: tjcd = TR_DR: tjcost = fee: TJNARR = TR_INV_REF & " FOR " & assess
'     GoSub 777
'     tjac = GLFEEAC: tjjob = 0: tjcd = TR_CR: tjcost = fee: TJNARR = TR_INV_REF & " FOR " & assess
'     GoSub 777
'
'400  Call PICKWT(TDEBTOR_DATA, client_no, 3, td_rec, 0)
'     If TJDATA(1) <> "" Then GoSub 900
'
410   ReDim the_rec(0)
      the_rec(0) = Id
      the_file = "PR.PROP.STMT"
      rderr = d3.d3_readmat(database, the_rec(), the_file)
      If rderr <> 0 Then Return
      If UBound(the_rec) < 7 Then ReDim the_rec(7)
      the_rec(6) = Pick.insert(the_rec(6), 1, -1, 0, CStr(as_at))
      If the_rec(7) <> "" Then 'settlement
         writeerror = d3.d3_writemat(database, the_file, the_rec())
      Else
         writeerror = d3.d3_delete(database, the_file, Id)
         writeerror = d3.d3_writemat(database, "PROP.STMT", the_rec())
      End If
'$INSERT I.QU
     Return
'
'777  For LL = 1 To 9999
'       glac = TJDATA(pick.extract(3), 1, LL)
'       If glac = "" Then GoTo 779
'       If glac = tjac Then
'        If TJDATA(pick.extract(1), 1, LL) = tjcd And TJDATA(pick.extract(6), 1, LL) = TJNARR And TJDATA(pick.extract(2), 1, LL) = tjjob Then
'          TJDATA(4)=PICK.REPLACE(4),1,LL,TJDATA(pick.extract(4),1,LL)+TJCOST)
'          GoTo 780
'        End If
'       End If
'     Next LL
'779  TJDATA(3) = Insert(TJDATA(3), 1, -1, 0, tjac)
'     TJDATA(6) = Insert(TJDATA(6), 1, -1, 0, TJNARR)
 '    TJDATA(2) = Insert(TJDATA(2), 1, -1, 0, tjjob)
'     TJDATA(1) = Insert(TJDATA(1), 1, -1, 0, tjcd)
'     TJDATA(4) = Insert(TJDATA(4), 1, -1, 0, tjcost)
'780  Return
'
'900  TJDATA(7) = tr_inv_date
'950  tj_key = Time() & TJ_TNO
'     If d3.d3_readstr(database,tj_rec, "TRANS.J", tj_key) <> 0 Then GoTo 960
'     Release TRANS_J_DATA, tj_key
'     GoTo 950
'960  NULL
'$INSERT I.LOG.ADD '|TRANS.J|':TJ.KEY 950
'
'     MATCALL PICKWT(TRANS_J_DATA, tj_key, 3, TJDATA, 0)
'     Return
'
'1000 OPEN "","SCROLL_KEYS" TO SCROLL_KEYS_DATA ELSE STOP
'     OPEN "DICT","PR_PROP_STMT" TO PR_PROP_STMT_DICT ELSE STOP
'     SKEY = "S_1642"
'     If d3.d3_readstr(database,Key, "SCROLL.KEYS", SKEY) <> 0 Then
'        PRINT @(0,P$) & BELL & SKEY & " missing from SCROLL_KEYS !" &
'        Stop
'     End If
'     If d3.d3_readstr(database,RECS, "DICT PR.PROP.STMT", "@RULES") <> 0 Then RECS = ""
'     datum = pick.extract(RECS, 2, 0, 0)
'     Call sr_change(datum, Chr(252), ",")
'     RECS = pick.Replace(RECS, 2, 0, 0, datum)
'     OLD_RECS = RECS
'     Screen = HEAD
'     Screen = pick.Replace(Screen, 2, 2, 0, "Must be entered in rule sequence")
'     DISPONLY = 0
'     XTRA_COMMAND = ""
'
'1200 MODE = "D"
'     GoSub 2000
'
'1300 BEGIN CASE
'        Case ans = "ENDIF"
'           PRINT @(0,P$) & "No processing done_ " & CL &
'           GoTo 1310
'        Case ans = "Y"
'           If RECS = OLD_RECS Then
'              PRINT @(0,P$) & "Nothing changed_ " & CL &
'              GoTo 1310
'           End If
'           datum = pick.extract(RECS, 2, 0, 0)
'           Call sr_change(datum, ",", Chr(252))
'           RECS = pick.Replace(RECS, 2, 0, 0, datum)
'           Call PICKWT(PR_PROP_STMT_DICT, "@RULES", 3, RECS, 0)
'           PRINT @(0,P$) & "All updating completed_ " & CL &
'           GoTo 1310
'     ENDIF CASE
'1310 return
'
'2000 UHEAD = HEAD
'     Call SRSCROLL(HEADP$, MODE, RECS, Key, TNO, STARTI, SYSTEM_PTR, "", "", DISPONLY, ADJUST, XTRA_COMMAND, PCOL, ans, Screen, UHEAD, "", ALLS, "", "", T$)
'     Return
    
End Sub

Public Sub sr16_cat(database As String, Mlev() As String)
     
Dim Ii As Integer, rx As Integer, No_Cats As Integer

     ReDim Mlev(11)
        
     No_Cats = sr16_catnum(database)
     For Ii = 1 To No_Cats
        rx = (Ii - 1) * 10 + 9
        Mlev(1) = Pick.replace(Mlev(1), 1, Ii, 0, CStr(Ii))
        Mlev(2) = Pick.replace(Mlev(2), 1, Ii, 0, Pick.extract(g_rates(rx), 1, 1, 0))
        Mlev(3) = Pick.replace(Mlev(3), 1, Ii, 0, Pick.extract(g_rates(rx), 1, 2, 0))
        Mlev(4) = Pick.replace(Mlev(4), 1, Ii, 0, Pick.extract(g_rates(rx), 1, 3, 0))
        Mlev(5) = Pick.replace(Mlev(5), 1, Ii, 0, Pick.extract(g_rates(rx), 1, 4, 0))
        Mlev(6) = Pick.replace(Mlev(6), 1, Ii, 0, Pick.extract(g_rates(rx), 1, 6, 0))
        Mlev(7) = Pick.replace(Mlev(7), 1, Ii, 0, Pick.extract(g_rates(rx), 1, 8, 0))
        Mlev(8) = Pick.replace(Mlev(8), 1, Ii, 0, Pick.extract(g_rates(rx), 1, 9, 0)) 'pens penalty on arrears mc08aug99
        Mlev(9) = Pick.replace(Mlev(9), 1, Ii, 0, Pick.extract(g_rates(rx), 1, 10, 0))  'gst mc08aug99
        Mlev(10) = Pick.replace(Mlev(10), 1, Ii, 0, Pick.extract(g_rates(rx), 1, 11, 0))  'special eg UP underground power
     Next Ii

End Sub

Public Sub sr1600(database As String, nrec() As String, lne As String)

Dim ia As Integer, Max As Integer, No_Cats As Integer, Categ As String
Dim I As Integer, J As Integer

     ReDim nrec(27)
     No_Cats = sr16_catnum(database)
     Categ = Pick.field(lne, ",", 2): If Categ = "" Then Categ = "1"
     
        ia = (CInt(Categ) - 1) * 10
        nrec(20) = Pick.extract(g_rates(ia + 9), 1, 1, 0) 'cat desc
        nrec(21) = Pick.extract(g_rates(ia + 9), 1, 2, 0) 'cat prefix
        nrec(22) = Pick.extract(g_rates(ia + 9), 1, 3, 0) 'cat discount
        nrec(23) = Pick.extract(g_rates(ia + 9), 1, 4, 0) 'cat penalty
        nrec(24) = Pick.extract(g_rates(ia + 9), 1, 6, 0) 'cat rebate
        nrec(25) = Pick.extract(g_rates(ia + 9), 1, 7, 0) 'cat remission
        nrec(26) = Pick.extract(g_rates(ia + 9), 1, 8, 0) 'cat defer
        nrec(27) = Pick.extract(g_rates(ia + 9), 1, 9, 0) 'cat no penalty on pensioer arrears
        
        nrec(1) = g_rates(ia + 1)
        Max = Pick.dcount(nrec(1), Chr(253))
        nrec(2) = g_rates(ia + 8)
        nrec(3) = g_rates(ia + 2)
        'select CASE option
        'Case FUTURE
        '   NREC(3)=g_rates(IA+8)
        '   NREC(4)=g_rates(IA+2)
        '   MAXO=COUNT(RREC(IA+1),VM)+1
        '   NP=COUNT(NREC(1),VM)+1
        '   For OO = 1 To MAXO
        '      OLD=RREC(IA+1,OO)
        '      LOCATE OLD IN NREC(1,1) SETTING OPOS ELSE NP=NP+1; OPOS=NP
        '      NREC(10,OPOS)=OLD
        '      NREC(11,OPOS)=RREC(IA+8,OO)
        '      NREC(5,OPOS)=g_rates(IA+10,OO,1)
        '      NREC(6,OPOS)=g_rates(IA+10,OO,2)
        '      NREC(7,OPOS)=RREC(IA+2,OO)
        '      NREC(8,OPOS)=RREC(IA+10,OO,1)
        '      NREC(9,OPOS)=RREC(IA+10,OO,2)
        '   Next OO
        'Case UOPT = 1
           nrec(6) = g_rates(ia + 4)
           nrec(7) = g_rates(ia + 5)
           For I = 1 To Max
              nrec(4) = Pick.replace(nrec(4), 1, I, 0, Pick.extract(g_rates(ia + 10), 1, I, 1))
              nrec(5) = Pick.replace(nrec(5), 1, I, 0, Pick.extract(g_rates(ia + 10), 1, I, 2))
              For J = 1 To 4
                 nrec(7 + J) = Pick.replace(nrec(7 + J), 1, I, 0, Pick.extract(g_rates(ia + 6), 1, I, J))
              Next J
              nrec(12) = Pick.replace(nrec(12), 1, I, 0, Pick.extract(g_rates(ia + 7), 1, I, 1))
              nrec(13) = Pick.replace(nrec(13), 1, I, 0, Pick.extract(g_rates(ia + 7), 1, I, 5))
              nrec(14) = Pick.replace(nrec(14), 1, I, 0, Pick.extract(g_rates(ia + 7), 1, I, 2))
              nrec(15) = Pick.replace(nrec(15), 1, I, 0, Pick.extract(g_rates(ia + 7), 1, I, 3))
              'If PGL Then
                 nrec(16) = Pick.replace(nrec(16), 1, I, 0, Pick.extract(g_rates(ia + 7), 1, I, 4))
              'End If
           Next I
        'CASE OPTION=3
        '   nrec(3) = g_rates(ia + 3)
        '   For i = 1 To max
        '      For j = 1 To 4
        '         nrec = pick.replace(nrec(3 + j), 1, i, 0, pick.extract(g_rates(ia + 5), 1, i, j))
        '      Next j
        '   Next i
        '   nrec(8) = g_rates(ia + 4)
        'End Select

End Sub

Public Sub SR1680A(logentry As String, VERS As String, FUTURE As String, Sel As String, Pp As String, ExcelPath As String, Use_rec() As String)
'
' Displays Standard Rates Model Reports
'
Dim Ii As Integer, Jj As Integer, Key As String, Vector As String, kk As Integer, rec As String, Max_Ii As Integer, nrec As String
Dim Max_Jj As Integer, No_Cats As Integer
Dim POSS(20, 5) As String, Am As String, Vm As String, Svm As String
Dim logarray() As String, Prog As String, ScrollItem As String, temp As String, tarray() As String
'
' Get the Data
'
Prog = "TA1680"
Am = Chr(254)
Vm = Chr(253)
Svm = Chr(252)
logarray = Split(logentry, Chr(254))
No_Cats = sr16_catnum(logarray(1))
For Ii = 1 To 4
   For Jj = 1 To No_Cats
      Key = "@" & Mid$(Prog, 3, 4) & "." & FUTURE & "." & VERS & "." & Jj & "." & Ii
      If d3.d3_readstr(logarray(1), Vector, "DICT RATE.MODEL", Key) <> 0 Then Vector = ""
      For kk = 1 To 15
         POSS(Jj, Ii) = Pick.insert(POSS(Jj, Ii), -1, 0, 0, Pick.extract(Vector, kk, 0, 0))
      Next kk
   Next Jj
Next Ii
'

rec = POSS(Pp, Sel)

'
' display results
'
Max_Ii = Pick.ccount(Pick.extract(rec, 1, 0, 0), Vm, 0) + 1
nrec = ""
For Ii = Max_Ii To 1 Step -1
   Max_Jj = Pick.ccount(Pick.extract(rec, 5, Ii, 0), Svm, 0) + 1
   For Jj = 1 To Max_Jj
      For kk = 1 To 9
        temp = Pick.extract(rec, kk, Ii, Jj)
        If temp = "" Or temp = " " Then temp = "&nbsp;"
        nrec = Pick.insert(nrec, kk, Ii + Jj - 1, 0, temp)
      Next kk
   Next Jj
Next Ii
nrec = "1" & Vm & "2" & Vm & "3" & Vm & "4" & Vm & "5" & Vm & "6" & Vm & "7" & Vm & "8" & Vm & "9" & Am & nrec
Use_rec = Split(nrec, Chr(254))
For Ii = 1 To UBound(Use_rec)
    temp = Use_rec(Ii)
    tarray = Split(temp, Vm)
    For Jj = 0 To UBound(tarray)
        If tarray(Jj) = "" Then tarray(Jj) = "&nbsp;"
    Next Jj
    temp = Join(tarray, Vm)
    Use_rec(Ii) = temp
Next Ii
End Sub

Public Sub SR1680B(logentry As String, VERS As String, FUTURE As String, Pp As String, Sel As String, Llim As String, Ulim As String, ExcelPath As String, ExcelFileName As String, Howbig As Long, Use_rec() As String)
Dim Am As String, Vm As String, Svm As String, Prow, Rates As String, No_Cats, Adj
Dim Fadj, Head_Scr, Control, Record_Length
Dim Ending_Out, Extra_Command, starti, MySent As String, pick_cnt As Long
Dim I As Integer, Temp_Id_Count, more, adjust, totals As String, Dicts
Dim Dname As String, Rts, Rt As Integer, Cgrv, Fgrv, Frt, Vgrv, Pgrv, Ccrt, Vrt, Prt
Dim jrec As String, Filter, match, Last_Sel, NO_SEL, A_Header, Mlev
Dim Ii As Long, Bon_Row, Mlev_Which, Sent As String, Summary, Found
Dim Attrib As Integer, Msgf, Hbreak, trec, J As Integer, Client_Rec As String, work As Currency, work1 As Currency
Dim Prec As String, Bfield As String, Old_Crec, Umore, Mode, Xtra_Cmd, Disponly, Uhead, workstr As String
Dim Thevalue As Currency, Imsg, wterr As String
Dim logarray() As String, mylist() As String
Dim Trans_Info As String, total_items As Long
Dim DQ As String, Crec As String
Dim fso, fileno, textfile, tempstr As String, colhead As String
'
' Show modelling results by assessment
'
' PP = category selection, SEL = Display options
Am = Chr(254): Vm = Chr(253): Svm = Chr(252): DQ = Chr(34)
logarray = Split(logentry, Am)
If d3.d3_readstr(logarray(1), Rates, "DICT TRANS.J", "@RATES") <> 0 Then Rates = ""
No_Cats = sr16_catnum(logarray(1))
Adj = (VERS - 1) * 20
Fadj = Adj + 10
'
5:
'
Control = "": Ending_Out = 0
'
Extra_Command = ""
starti = 1
Crec = "": I = 0: Temp_Id_Count = 0: more = 1: adjust = 0: totals = ""
Dicts = ""

'
Dname = "SENT" & VERS
If d3.d3_readstr(logarray(1), MySent, "DICT PROP.MODEL", Dname) <> 0 Then Exit Sub
'
total_items = d3.d3_select(logentry, MySent, mylist(), pick_cnt, 0, 0)
'
For I = 0 To total_items - 1
    If d3.d3_readstr(logarray(1), jrec, "PROP.MODEL", mylist(I)) = 0 Then
        Rts = Pick.ccount(Pick.extract(jrec, 1, 0, 0), Vm, 0) + 1
        For Rt = 1 To Rts
            Cgrv = Pick.extract(jrec, 3, Rt, 0)
            If FUTURE Then
                Fgrv = Pick.extract(jrec, 3 + Fadj, Rt, 0)
                Frt = Pick.extract(jrec, 4 + Fadj, Rt, 0)
            Else
                Fgrv = Pick.extract(jrec, 3 + Adj, Rt, 0)
                Frt = Pick.extract(jrec, 4 + Adj, Rt, 0)
            End If
            If IsNumeric(Fgrv) And IsNumeric(Cgrv) Then
                Vgrv = Fgrv - Cgrv
            Else
                Vgrv = 0
            End If
            If Cgrv = "" Or Cgrv = 0 Then
                Pgrv = ""
            Else
                Pgrv = Vgrv / Cgrv * 100
            End If
            Ccrt = Pick.extract(jrec, 4, Rt, 0)
            If IsNumeric(Frt) And IsNumeric(Ccrt) Then
                Vrt = Frt - Ccrt
            Else
                Vrt = 0
            End If
            If CStr(Ccrt) = "" Or Ccrt = 0 Then
                Prt = ""
            Else
                Prt = Vrt / Ccrt * 100
            End If
            jrec = Pick.replace(jrec, 9 + Adj, Rt, 0, CStr(Vgrv))
            jrec = Pick.replace(jrec, 10 + Adj, Rt, 0, CStr(Pgrv))
            jrec = Pick.replace(jrec, 9 + Fadj, Rt, 0, CStr(Vrt))
            jrec = Pick.replace(jrec, 10 + Fadj, Rt, 0, CStr(Prt))
        Next Rt
    End If
    wterr = d3.d3_writestr(logarray(1), "PROP.MODEL", mylist(I), jrec)
Next I
'
'
Filter = 0
'
Sent = MySent
Summary = 0
colhead = "Assesment"
Select Case Sel
    Case 1
        Sent = Sent & " BY ID"
'
    Case 2
        Sent = Sent & " BY A8"  ' ZONE
        Summary = 1
        Attrib = 8
        colhead = "Zone"
'
    Case 3
        Sent = Sent & " BY-EXP A29 = " & DQ & Pp & DQ & " BY A19"
        Summary = 1
        Attrib = 19
        colhead = "Rate" & vbCrLf & "Category"
'
    Case 4
        Sent = Sent & " BY WARD"
        Summary = 1
        Attrib = 38
        colhead = "Ward"
'
    Case 5
        Filter = 1
        Llim = Pick.ICONV(Llim, "MD2"): Ulim = Pick.ICONV(Ulim, "MD2")
'
    Case 6
        Filter = 1
        Llim = Pick.ICONV(Llim, "MD2"): Ulim = Pick.ICONV(Ulim, "MD2")
'
    Case 7
        Llim = Pick.ICONV(Llim, "MD2"): Ulim = Pick.ICONV(Ulim, "MD2")
'
    Case 8
        Filter = 1
'
    Case 9
        Filter = 1
        Llim = Pick.ICONV(Llim, "MD2"): Ulim = Pick.ICONV(Ulim, "MD2")
'
    Case 10
        Filter = 1
End Select
'
total_items = d3.d3_select(logentry, Sent, mylist(), pick_cnt, 0, 0)
I = 0
Hbreak = ""
'
'100  READNEXT ID ELSE
For Ii = 0 To total_items - 1

    If d3.d3_readstr(logarray(1), jrec, "PROP.MODEL", mylist(Ii)) = 0 Then
        If d3.d3_readstr(logarray(1), Client_Rec, "CLIENT", mylist(Ii)) <> 0 Then Client_Rec = ""
        If Summary Then
            If d3.d3_readstr(logarray(1), Prec, "PROPERTY", mylist(Ii)) <> 0 Then Prec = ""
            Bfield = Pick.extract(Prec, Attrib, 0, 0)
            If Attrib = 19 Then Bfield = Pick.extract(Prec, Attrib, CInt(Pp), 0)
            If Hbreak = "" Then
                Hbreak = Bfield
                If I = 0 Then I = 1
            End If
            If Hbreak <> Bfield Then
                For J = 2 To 8
                    If J <> 5 Then
'                        Totals = pick.replace(Totals, j, 0, 0, pick.extract(Totals, j, 0, 0) + pick.extract(Crec, j, I, 0))
                        work = Pick.extractcur(Crec, J, I, 0)
                        work1 = Pick.extractcur(totals, J, 0, 0)
                        work = work + work1
                        totals = Pick.replace(totals, J, 0, 0, CStr(work))
                    End If
                Next J
                If Pick.extractcur(Crec, 2, I, 0) <> 0 Then
                    work = (Pick.extractcur(Crec, 3, I, 0) - Pick.extractcur(Crec, 2, I, 0)) / Pick.extractcur(Crec, 2, I, 0) * 100
                    Crec = Pick.replace(Crec, 5, I, 0, CStr(work))
                End If
                If Pick.extractcur(Crec, 6, I, 0) <> 0 Then
                    work = (Pick.extractcur(Crec, 7, I, 0) - Pick.extractcur(Crec, 6, I, 0)) / Pick.extractcur(Crec, 6, I, 0) * 100
                    Crec = Pick.replace(Crec, 9, I, 0, CStr(work))
                End If
                I = I + 1
                Hbreak = Bfield
            End If
        End If
'
        Rts = Pick.ccount(Pick.extract(jrec, 1, 0, 0), Vm, 0) + 1
        If Rts < Pp Then GoTo 200
        If Filter Then
            Thevalue = 0
            Select Case Sel
            Case 5
                ' "Future Value"
                If FUTURE Then
                    Thevalue = Pick.extractcur(jrec, 3 + Fadj, CInt(Pp), 0)
                Else
                    Thevalue = Pick.extractcur(jrec, 3 + Adj, CInt(Pp), 0)
                End If
'
            Case 6
                ' "Proposed Rates"
                If FUTURE Then
                    Thevalue = Pick.extractcur(jrec, 4 + Fadj, CInt(Pp), 0)
                Else
                    Thevalue = Pick.extractcur(jrec, 4 + Adj, CInt(Pp), 0)
                End If
'
            Case 7
                ' "Value Variance $"
                Thevalue = Pick.extractcur(jrec, 9 + Adj, CInt(Pp), 0)
'
            Case 8
                ' "Value Variance %"
                Thevalue = Pick.extractcur(jrec, 10 + Adj, CInt(Pp), 0)
'
            Case 9
                ' "Rates Variance $"
                Thevalue = Pick.extractcur(jrec, 9 + Fadj, CInt(Pp), 0)
'
            Case 10
                ' "Rates Variance %"
                Thevalue = Pick.extractcur(jrec, 10 + Fadj, CInt(Pp), 0)
            End Select
            If Thevalue < Llim Or Thevalue > Ulim Then GoTo 200
        End If
        If Summary = 0 Then
            I = I + 1
            Crec = Pick.replace(Crec, 1, I, 0, mylist(Ii))
            Crec = Pick.replace(Crec, 2, I, 0, Pick.extract(jrec, 3, CInt(Pp), 0))
            If FUTURE Then
                Crec = Pick.replace(Crec, 3, I, 0, Pick.extract(jrec, 3 + Fadj, CInt(Pp), 0))
                Crec = Pick.replace(Crec, 7, I, 0, Pick.extract(jrec, 4 + Fadj, CInt(Pp), 0))
            Else
                Crec = Pick.replace(Crec, 3, I, 0, Pick.extract(jrec, 3 + Adj, CInt(Pp), 0))
                Crec = Pick.replace(Crec, 7, I, 0, Pick.extract(jrec, 4 + Adj, CInt(Pp), 0))
            End If
            Crec = Pick.replace(Crec, 4, I, 0, Pick.extract(jrec, 9 + Adj, CInt(Pp), 0))
            Crec = Pick.replace(Crec, 5, I, 0, Pick.extract(jrec, 10 + Adj, CInt(Pp), 0))
            Crec = Pick.replace(Crec, 6, I, 0, Pick.extract(jrec, 4, CInt(Pp), 0))
            Crec = Pick.replace(Crec, 8, I, 0, Pick.extract(jrec, 9 + Fadj, CInt(Pp), 0))
            Crec = Pick.replace(Crec, 9, I, 0, Pick.extract(jrec, 10 + Fadj, CInt(Pp), 0))
            Crec = Pick.replace(Crec, 10, I, 0, Pick.extract(Client_Rec, 2, 0, 0))
            For J = 2 To 8
                If J <> 5 Then
                    work = Pick.extractcur(Crec, J, I, 0)
                    work1 = Pick.extractcur(totals, J, 0, 0)
                    work = work + work1
                    totals = Pick.replace(totals, J, 0, 0, CStr(work))
                End If
            Next J
        Else
            Crec = Pick.replace(Crec, 1, I, 0, Bfield)
            work = Pick.extractcur(Crec, 2, I, 0)
            work1 = Pick.extractcur(jrec, 3, CInt(Pp), 0)
            work = work + work1
            Crec = Pick.replace(Crec, 2, I, 0, CStr(work))
            If FUTURE Then
                work = Pick.extractcur(Crec, 3, I, 0)
                work1 = Pick.extractcur(jrec, 3 + Fadj, CInt(Pp), 0)
                work = work + work1
                Crec = Pick.replace(Crec, 3, I, 0, CStr(work))
                work = Pick.extractcur(Crec, 7, I, 0)
                work1 = Pick.extractcur(jrec, 4 + Fadj, CInt(Pp), 0)
                work = work + work1
                Crec = Pick.replace(Crec, 7, I, 0, CStr(work))
            Else
                work = Pick.extractcur(Crec, 3, I, 0)
                work1 = Pick.extractcur(jrec, 3 + Adj, CInt(Pp), 0)
                work = work + work1
                Crec = Pick.replace(Crec, 3, I, 0, CStr(work))
                work = Pick.extractcur(Crec, 7, I, 0)
                work1 = Pick.extractcur(jrec, 4 + Adj, CInt(Pp), 0)
                work = work + work1
                Crec = Pick.replace(Crec, 7, I, 0, CStr(work))
            End If
                work = Pick.extractcur(Crec, 4, I, 0)
                work1 = Pick.extractcur(jrec, 9 + Adj, CInt(Pp), 0)
                work = work + work1
                Crec = Pick.replace(Crec, 4, I, 0, CStr(work))
                work = Pick.extractcur(Crec, 6, I, 0)
                work1 = Pick.extractcur(jrec, 4, CInt(Pp), 0)
                work = work + work1
                Crec = Pick.replace(Crec, 6, I, 0, CStr(work))
                work = Pick.extractcur(Crec, 8, I, 0)
                work1 = Pick.extractcur(jrec, 9 + Fadj, CInt(Pp), 0)
                work = work + work1
                Crec = Pick.replace(Crec, 8, I, 0, CStr(work))
        End If
    End If
200:
Next Ii
'
'
trec = Crec
more = 0
If Summary Then
    If Pick.extractcur(Crec, 2, I, 0) <> 0 Then
        work = (Pick.extractcur(Crec, 3, I, 0) - Pick.extractcur(Crec, 2, I, 0)) / Pick.extractcur(Crec, 2, I, 0) * 100
        Crec = Pick.replace(Crec, 5, I, 0, CStr(work))
    End If
    If Pick.extractcur(Crec, 6, I, 0) <> 0 Then
        work = (Pick.extractcur(Crec, 7, I, 0) - Pick.extractcur(Crec, 6, I, 0)) / Pick.extractcur(Crec, 6, I, 0) * 100
        Crec = Pick.replace(Crec, 9, I, 0, CStr(work))
    End If
    For J = 2 To 8
        If J <> 5 Then
            work = Pick.extractcur(Crec, J, I, 0)
            work1 = Pick.extractcur(totals, J, 0, 0)
            work = work + work1
            totals = Pick.replace(totals, J, 0, 0, CStr(work))
        End If
    Next J
    If Pick.extractcur(totals, 2, 0, 0) <> 0 Then
        work = Pick.extractcur(totals, 3, I, 0)
        work1 = Pick.extractcur(totals, 2, I, 0)
        work = work - work1
        If work <> 0 And work1 <> 0 Then work = work / (work1 * 100)
        totals = Pick.replace(totals, 5, I, 0, CStr(work))
    End If
    If Pick.extractcur(totals, 6, 0, 0) <> 0 Then
        work = Pick.extractcur(totals, 7, I, 0)
        work1 = Pick.extractcur(totals, 6, I, 0)
        work = work - work1
        If work <> 0 And work1 <> 0 Then work = work / (work1 * 100)
        totals = Pick.replace(totals, 9, I, 0, CStr(work))
    End If
End If
I = I + 1
Crec = Pick.replace(Crec, 1, I, 0, "Totals")
For J = 2 To 8
    If J <> 5 Then
        Crec = Pick.replace(Crec, J, I, 0, Pick.extract(totals, J, 0, 0))
    End If
Next J
If Summary Then
    Crec = Pick.replace(Crec, 5, I, 0, Pick.extract(totals, 5, 0, 0))
    Crec = Pick.replace(Crec, 9, I, 0, Pick.extract(totals, 9, 0, 0))
End If
Crec = "X" & Am & Crec
Use_rec = Split(Crec, Am, , vbBinaryCompare)
Howbig = Pick.ccount(Use_rec(1), Vm, 0) + 1
Set fso = New Scripting.FileSystemObject
fileno = 0
ExcelFileName = ExcelPath & "\Ratmod" & CStr(fileno) & ".xls"
Do While fso.FileExists(ExcelFileName)
    fileno = fileno + 1
    ExcelFileName = ExcelPath & "\Ratmod" & CStr(fileno) & ".xls"
Loop
Set textfile = fso.CreateTextFile(ExcelFileName, True)
tempstr = colhead & vbTab & "Current" & "Value" & vbTab & "Future" & "Value" & vbTab & "Variance $" & vbTab & "Variance %" & vbTab & "Current" & "Rates" & vbTab
tempstr = tempstr & "Proposed" & "Rates" & vbTab & "Variance $" & vbTab & "Variance %" & vbTab & "Address"
textfile.WriteLine (tempstr)
For I = 1 To Howbig
    tempstr = Pick.extract(Use_rec(1), 1, I, 0) & vbTab & Pick.extract(Use_rec(2), 1, I, 0) & vbTab & Pick.extract(Use_rec(3), 1, I, 0) & vbTab & Pick.extract(Use_rec(4), 1, I, 0) & vbTab & Pick.extract(Use_rec(5), 1, I, 0)
    tempstr = tempstr & vbTab & Pick.extract(Use_rec(6), 1, I, 0) & vbTab & Pick.extract(Use_rec(7), 1, I, 0) & vbTab & Pick.extract(Use_rec(8), 1, I, 0) & vbTab & Pick.extract(Use_rec(9), 1, I, 0)
    If Sel <> "2" And Sel <> "3" And Sel <> "4" And Sel <> "5" Then
        tempstr = tempstr & vbTab & Pick.extract(Use_rec(10), 1, I, 0)
    End If
    textfile.WriteLine (tempstr)
Next I
textfile.Close
ExcelFileName = "Ratmod" & CStr(fileno) & ".xls"
End Sub

Public Function sr1600_str(database As String, lne As String) As String

Dim nrec() As String
Call sr1600(database, nrec(), lne)
sr1600_str = Join(nrec, Chr(254))

End Function

Public Function sr16_cat_str(database As String)

Dim Mlev() As String

Call sr16_cat(database, Mlev())
sr16_cat_str = Join(Mlev, Chr(254))

End Function

Public Function sr_ratedesc(Rcat As String, Rcode As String, grates As String)

' Get rate description from ratecode

Dim I As Integer, ucat As Integer, rattr As Integer
Dim typ As String, Tt As Integer, numtype As Integer
Dim posn As Integer, Pos As Integer, mr As String, temp As String

     If Not (IsNumeric(Rcat)) Then ' passed category desc not number
        For I = 9 To 999 Step 10
           If UBound(g_rates) < I Then ucat = 1: GoTo ratedesc_9
           If Rcat = Pick.extract(g_rates(I), 1, 1, 0) Then ucat = (I - 9) / 10 + 1: GoTo ratedesc_9
           If g_rates(I) = "" Then ucat = 1: GoTo ratedesc_9
        Next I
     Else
        ucat = Rcat
     End If
ratedesc_9:
     rattr = (ucat - 1) * 10 + 1
     typ = Rcode
     If IsNumeric(Left(typ, 1)) Or Left(typ, 1) = "." Or Left(typ, 1) = "-" Then
        If IsNumeric(typ) Then GoTo ratedesc_4060 ' ALLOW FOR NUMERIC CODES AT SWAN
        For Tt = 2 To 99
           If Not IsNumeric(Mid(typ, Tt, 1)) And Mid(typ, Tt, 1) <> "." And Mid(typ, Tt, 1) <> "-" Then Exit For
        Next Tt
        numtype = CInt(Left(typ, Tt - 1)): typ = Mid(typ, Tt)
     End If
ratedesc_4060:
     temp = Pick.extract(grates, rattr, 0, 0)
     posn = Pick.locate(typ, temp, 1, 1, 0, Pos, "")
     If posn = 0 Then
        sr_ratedesc = temp
     Else
        sr_ratedesc = Pick.extract(grates, rattr + 7, Pos, 0)
     End If
     
End Function
Public Sub SR300_TAB(database As String, rtab As String, PENALTY_TAB As String)
'
' Setup rates table and penalty table from @RATES
'
Dim sundry() As String, Ii As Integer, Max_Ii As Integer, Jj As Integer, Ptx As Integer
Dim INT_METH As String

    If UBound(g_rates) = 0 Then
        g_rates(0) = "@RATES"
        Ii = d3.d3_readmat(database, g_rates(), "DICT TRANS.J")
     End If
  
     rtab = "": PENALTY_TAB = ""
     Jj = 0: Ptx = 0
     Max_Ii = UBound(g_rates)
     For Ii = 9 To Max_Ii Step 10
        Jj = Jj + 1
        rtab = Pick.replace(rtab, 1, Jj, 0, Pick.extract(g_rates(Ii), 1, 2, 0)) ' rate code)
        rtab = Pick.replace(rtab, 2, Jj, 0, Pick.extract(g_rates(Ii), 1, 6, 0)) ' rebate indicator)
        rtab = Pick.replace(rtab, 3, Jj, 0, Pick.extract(g_rates(Ii), 1, 8, 0)) ' deferred indicator)
        rtab = Pick.replace(rtab, 4, Jj, 0, Pick.extract(g_rates(Ii), 1, 11, 0)) ' special indicator)
        If Pick.extract(g_rates(Ii), 1, 4, 0) <> "" Then          ' penalty codes
           Ptx = Ptx + 1
           PENALTY_TAB = Pick.replace(PENALTY_TAB, 1, Ptx, 0, Pick.extract(g_rates(Ii), 1, 2, 0))
           PENALTY_TAB = Pick.replace(PENALTY_TAB, 2, Ptx, 0, Pick.extract(g_rates(Ii), 1, 4, 0))
           PENALTY_TAB = Pick.replace(PENALTY_TAB, 3, Ptx, 0, Pick.extract(g_rates(Ii), 1, 1, 0))
           PENALTY_TAB = Pick.replace(PENALTY_TAB, 4, Ptx, 0, CStr(Jj))
           PENALTY_TAB = Pick.replace(PENALTY_TAB, 11, Ptx, 0, Pick.extract(g_rates(Ii), 1, 8, 0)) 'deferment indicator)
           PENALTY_TAB = Pick.replace(PENALTY_TAB, 12, Ptx, 0, Pick.extract(g_rates(Ii), 1, 9, 0)) 'pensioner no penalty on arrears)
       End If
     Next Ii
     INT_METH = Mid$(g_trans_info_array(53), 14, 1)
     ReDim sundry(0): sundry(0) = "@CHARGES"
     Ii = d3.d3_readmat(database, sundry(), "DICT TRANS.J")
     If UBound(sundry) >= 18 And INT_METH = "0" Then
        Max_Ii = Pick.dcount(sundry(1), Chr(253))
        For Ii = 1 To Max_Ii
           If Pick.extract(sundry(18), 1, Ii, 0) <> "" Then
              Ptx = Ptx + 1
              'RGM ** ERROR **   Sundry is an array, trying to pass as a single string as in following line
              'penalty_tab = pick.replace(penalty_tab, 1, ptx, 0, pick.extract(sundry, 1, ii, 0)) ' sundry prefix)
              PENALTY_TAB = Pick.replace(PENALTY_TAB, 1, Ptx, 0, Pick.extract(CStr(sundry(Ii)), 1, Ii, 0)) ' sundry prefix)
              PENALTY_TAB = Pick.replace(PENALTY_TAB, 2, Ptx, 0, Pick.extract(CStr(sundry(Ii)), 18, Ii, 0)) ' penalty rate)
              PENALTY_TAB = Pick.replace(PENALTY_TAB, 3, Ptx, 0, Pick.extract(CStr(sundry(Ii)), 2, Ii, 0))
              PENALTY_TAB = Pick.replace(PENALTY_TAB, 4, Ptx, 0, "!" & Pick.extract(CStr(sundry(Ii)), 19, Ii, 0)) ' interest a/c)
           End If
        Next Ii
     End If

End Sub


Public Sub SR16_INST(install As String, Ri_Tab As String, Pcode As Integer, senior As Integer, Sdate As String, Inst_Tab As String, Interim As Integer)

Dim Use_Codes As String, GROSS_AMT As Currency, Total_Other As Currency, Gross_Charges As Currency
Dim Total_Penalty As Currency, Total_Deferred As Currency, Max_Jj As Integer, Jj As Integer, Rate_Code As String, Rate_Amt  As Currency
Dim Ix As Integer, Apply_Install As String, Apply_Charges As String, arrears As Currency, Deferred As Currency, Penalty As Currency
Dim Min_Levy As Currency, No_Offer As String, Max_Ii As Integer, Ii As Integer, No_Install As Integer
Dim Plan_Num As String, Due_Dates As String, Dpos As Integer, dd As Integer, Admin_Amt As Currency, int_rate As Currency, Chg_Amt As Currency
Dim Chg_Tab  As String, diff As Currency, Total_Cost As Currency, Amt As Currency, Tot_Int As Currency, First_Due As Integer
Dim Ramt As Currency, Date_Due As Integer, period As Integer, Int_Amt As Currency, Dist_Cr As Currency, tempcur As Currency
Dim INST_AMT As Currency
'
'    Routine to create INST.TAB containing all valid instalment options
'    Must pass RI.TAB containing list of rate codes and amounts
'    INST.TAB returned as
'    <1>   m/v list of instalment options
'    <2>   m/v list, s/v list of due dates per instalment option
'    <3>   m/v list, s/v list of base amount apportioned per date
'    <4>   m/v list, s/v list of admin amount apportioned per date
'    <5>   m/v list, s/v list of interest amount apportioned per date
'    <6>   m/v list, total cost per instalment option
'    <7>   m/v list, s/v list total payment per instalment
'          sum of <3> <4> <5>
'          first payment includes arrears, less deferred
'    <8>   m/v list, s/v list of actual interest amount calculated to
'          instalment due date
'
     Use_Codes = Pick.extract(install, 6, 1, 0)
     GROSS_AMT = 0:  Total_Other = 0:  Gross_Charges = 0
     Total_Penalty = 0: Total_Deferred = 0
     Max_Jj = Pick.dcount(Pick.extract(Ri_Tab, 1, 0, 0), Chr(253))
     For Jj = 1 To Max_Jj             ' calculate gross amount
        Rate_Code = Pick.extract(Ri_Tab, 1, Jj, 0)
        Rate_Amt = Pick.extractcur(Ri_Tab, 2, Jj, 0)
        If Pick.locate(Rate_Code, Use_Codes, 1, 1, 1, Ix, "") = 0 Then Ix = 0
        If Ix Then
           Apply_Install = Pick.extract(install, 7, 1, Ix)
           Apply_Charges = Pick.extract(install, 8, 1, Ix)
        Else
           Apply_Install = "N"
           Apply_Charges = "N"
        End If
        If Apply_Install = "Y" Then
           GROSS_AMT = GROSS_AMT + Rate_Amt
           If Apply_Charges = "Y" Then
              Gross_Charges = Gross_Charges + Rate_Amt
           End If
        Else
           Total_Other = Total_Other + Rate_Amt   ' gsm  13_11_97
        End If
        arrears = Pick.extractcur(Ri_Tab, 11, Jj, 0)
        Deferred = Pick.extractcur(Ri_Tab, 12, Jj, 0): Total_Deferred = Total_Deferred + Deferred
        Penalty = Pick.extractcur(Ri_Tab, 17, Jj, 0): Total_Penalty = Total_Penalty + Penalty
        Total_Other = Total_Other + arrears - Deferred + Penalty
     Next Jj
'
     Inst_Tab = ""
     Inst_Tab = Pick.replace(Inst_Tab, 9, 0, 0, CStr(Total_Deferred))
     Inst_Tab = Pick.replace(Inst_Tab, 10, 0, 0, CStr(Total_Penalty))
     Min_Levy = Pick.extractcur(install, 4, 1, 0)
     No_Offer = 0
     If GROSS_AMT <= Min_Levy Then
        If Interim = 0 Then
           Inst_Tab = Pick.replace(Inst_Tab, 7, 1, 1, CStr(Total_Other + GROSS_AMT))
           Inst_Tab = Pick.replace(Inst_Tab, 11, 0, 0, CStr(GROSS_AMT))
           GoTo 995
        End If
        No_Offer = 1
     End If
     Max_Ii = Pick.dcount(Pick.extract(install, 1, 0, 0), Chr(253))
     For Ii = 1 To Max_Ii
        No_Install = Pick.extractint(install, 1, Ii, 0)
        Plan_Num = No_Install
        Due_Dates = Pick.extract(install, 5, Ii, 0)
        If Sdate <> "" Then
           If Pick.locate(Sdate, Due_Dates, 1, 1, 1, Dpos, "AR") = 0 Then Dpos = Dpos - 1
           For dd = Dpos To 1 Step -1
              Due_Dates = Pick.delet(Due_Dates, 1, 1, dd)
              No_Install = No_Install - 1
           Next dd
           If No_Install <= 1 Or No_Offer Then
              If Interim = 0 Or Ii <> Max_Ii Then GoTo 990
              No_Install = 0: Due_Dates = Sdate
           End If
        End If
'
        If (Pcode And Pick.extract(install, 2, Ii, 2) = "N") Or No_Install = 0 Then
           Admin_Amt = 0
        Else
           Admin_Amt = Pick.extractcur(install, 2, Ii, 1)
           If Plan_Num <> No_Install Then Admin_Amt = Int(Admin_Amt * (No_Install - 1) / (Plan_Num - 1))
        End If
'
        If Pcode And Pick.extract(install, 3, Ii, 2) = "N" Then
           int_rate = 0
        Else
           int_rate = Pick.extractcur(install, 3, Ii, 1)
        End If
'
        Inst_Tab = Pick.replace(Inst_Tab, 1, Ii, 0, CStr(No_Install))
        Inst_Tab = Pick.replace(Inst_Tab, 2, Ii, 0, Due_Dates)
        If No_Install = 0 Then INST_AMT = GROSS_AMT Else INST_AMT = Int(GROSS_AMT / No_Install)
        If No_Install = 0 Then GoTo 960
        Chg_Amt = Int(Gross_Charges / No_Install)
        Chg_Tab = ""
        For Jj = 1 To No_Install
           Inst_Tab = Pick.replace(Inst_Tab, 3, Ii, Jj, CStr(INST_AMT))
           Chg_Tab = Pick.replace(Chg_Tab, 1, Jj, 0, CStr(Chg_Amt))
        Next Jj
        diff = GROSS_AMT - (INST_AMT * No_Install)
        Inst_Tab = Pick.replace(Inst_Tab, 3, Ii, 1, CStr(Pick.extractcur(Inst_Tab, 3, Ii, 1) + diff)) ' remainder)
        diff = Gross_Charges - (Chg_Amt * No_Install)
        Chg_Tab = Pick.replace(Chg_Tab, 1, 1, 0, CStr(Pick.extractcur(Chg_Tab, 1, 1, 0) + diff))   ' remainder)
'
        Total_Cost = 0
        If Admin_Amt <> 0 Then
' distribute admin fee over each instalment
           Amt = Int(Admin_Amt / No_Install)
           Inst_Tab = Pick.replace(Inst_Tab, 4, Ii, 1, CStr(Admin_Amt - Amt * No_Install)) ' rounding)
           For Jj = 1 To No_Install
              Inst_Tab = Pick.replace(Inst_Tab, 4, Ii, Jj, CStr(Pick.extractcur(Inst_Tab, 4, Ii, Jj) + Amt))
              Total_Cost = Total_Cost + Pick.extractcur(Inst_Tab, 4, Ii, Jj)
           Next Jj
        End If
'
        If int_rate <> 0 Then
           Inst_Tab = Pick.replace(Inst_Tab, 8, Ii, 1, 0)
           Tot_Int = 0
           First_Due = Pick.extractint(Due_Dates, 1, 1, 1)     ' first instalment due
           For Jj = 2 To No_Install
              Ramt = Pick.oconv(Pick.extract(Chg_Tab, 1, Jj, 0), "MD2")
              Date_Due = Pick.extractint(Due_Dates, 1, 1, Jj)
              period = Date_Due - First_Due
              Int_Amt = Int(Ramt * int_rate / 100 * period / 365 + 0.5)
              Inst_Tab = Pick.replace(Inst_Tab, 8, Ii, Jj, CStr(Int_Amt))
              Tot_Int = Tot_Int + Int_Amt
           Next Jj
' distribute interest fee over each instalment
           Amt = Int(Tot_Int / No_Install)
           diff = Tot_Int - (Amt * No_Install)    ' rounding
           Inst_Tab = Pick.replace(Inst_Tab, 5, Ii, 1, CStr(diff))
           Total_Cost = Total_Cost + diff
           For Jj = 1 To No_Install
              Inst_Tab = Pick.replace(Inst_Tab, 5, Ii, Jj, CStr(Pick.extractcur(Inst_Tab, 5, Ii, Jj) + Amt))
              Total_Cost = Total_Cost + Amt
           Next Jj
        End If
        Inst_Tab = Pick.replace(Inst_Tab, 6, Ii, 0, CStr(Total_Cost))
960     Dist_Cr = 0
        Inst_Tab = Pick.replace(Inst_Tab, 12, 0, 0, CStr(Total_Other))
        If Total_Other >= 0 Then
           Inst_Tab = Pick.replace(Inst_Tab, 7, Ii, 1, CStr(Total_Other)) 'mco TOTAL_FIRST_AMT)
        Else
           Dist_Cr = Total_Other
        End If
        For Jj = 1 To No_Install
         If Dist_Cr < 0 Then
           tempcur = Pick.extractcur(Inst_Tab, 3, Ii, Jj) + Pick.extractcur(Inst_Tab, 4, Ii, Jj) + Pick.extractcur(Inst_Tab, 5, Ii, Jj)
           If Dist_Cr + tempcur > 0 Then
              Inst_Tab = Pick.replace(Inst_Tab, 7, Ii, Jj, CStr(Dist_Cr + tempcur))
           Else
              Inst_Tab = Pick.replace(Inst_Tab, 7, Ii, Jj, "0")
           End If
           Dist_Cr = Dist_Cr + tempcur
         Else
           Inst_Tab = Pick.replace(Inst_Tab, 7, Ii, Jj, Pick.extractcur(Inst_Tab, 7, Ii, Jj) + Pick.extractcur(Inst_Tab, 3, Ii, Jj) + Pick.extractcur(Inst_Tab, 4, Ii, Jj) + Pick.extractcur(Inst_Tab, 5, Ii, Jj))
         End If
         Inst_Tab = Pick.replace(Inst_Tab, 11, Ii, Jj, Pick.extractcur(Inst_Tab, 11, Ii, Jj) + Pick.extractcur(Inst_Tab, 3, Ii, Jj) + Pick.extractcur(Inst_Tab, 4, Ii, Jj) + Pick.extractcur(Inst_Tab, 5, Ii, Jj))
        Next Jj
        If No_Install = 0 Then Jj = 1: Inst_Tab = Pick.replace(Inst_Tab, 11, Ii, 1, CStr(GROSS_AMT))
        If Dist_Cr < 0 Then
           Inst_Tab = Pick.replace(Inst_Tab, 7, Ii, Jj, CStr(Pick.extractcur(Inst_Tab, 7, Ii, Jj) + Dist_Cr))
           Dist_Cr = 0
        End If
        If No_Install = 0 Then GoTo 995
990  Next Ii
995  Exit Sub

End Sub


Public Sub SR1685_CHK(CODE As String, Client_No As String)

Dim Mods10 As String, Len_Cl As Integer, Numeric_Field As String, Total As Currency
Dim Ii As Integer, Result As Integer, Remainder As Integer
Dim Chk_Digit
'
' Calculate check digit for usercode
'
     Mods10 = "12121212121212121212"
     Len_Cl = Len(Client_No)
     Numeric_Field = String$(6 - Len_Cl, "0") & Client_No
     Total = 0
     For Ii = 1 To Len(Numeric_Field)
       Result = CInt(Mid$(Numeric_Field, Ii, 1)) * CInt(Mid$(Mods10, Ii, 1))
       If Result > 9 Then Result = Mid$(Result, 1, 1) + Mid$(Result, 2, 1)
       Total = Total + Result
     Next Ii
     Remainder = Total Mod 10
     If Remainder <> 0 Then
        Chk_Digit = 10 - Remainder
     Else
        Chk_Digit = 0
     End If
     Client_No = Pick.replace(Client_No, 2, 0, 0, Numeric_Field & Chk_Digit)

End Sub





Public Sub SR1685_13(database As String, Start_Year As String, Name1 As String, Name2 As String, MAILADDR() As String, Disc_Arr As String, Sdate As String, Client_No As String, Property_Rec As String, Pcode As Integer, senior As Integer, Ward_Desc As String, Client_Rec() As String, Grv As String, Shire_Clerk As String, Rate_Desc As String, Area_Flg As String, Minmax As String, Mess As String, Format_Rec As String, trans_rec As String, Rate_Tab As String, Inst_Tab As String, pt_line As String, Apbar_Ctl As String, Inst_Remind As String, PENALTY_TAB As String, Interim_Details As String, Interim_Amts As String, Interim_Bals As String, datums As String, Interim_Gst_Codes As String, Interim_Gst_Amts As String, apamt As String)

Dim Arithmetic As String
Dim Disc_Rate As String, DISC_DATE As String, Penalty_Rate As String, arr_date As String, Due_Date As String
Dim Ii As Integer, Lots As String, Max_Lots As Integer, Locs As String, Max_Locs As Integer, Bar_Code As String
Dim datum As String, Pline As String
Dim Key_Line As String, Msg As String, Bar_Tab As String, Max_Ii As Integer, Curr_Amt, Arrs_Amt, Defr_Amt
Dim Disc_Amt, Rebate_Amt, senior_amt, Remiss_Amt, Net_Rebate, Net_Disc, Gtot_G
Dim Gtot_Gr As Currency, Gtot_Grd, Jj As Integer, Un_Fl As String, xx As Integer, Ar_Tot As Currency, Area_Mess As String
Dim Rowx As Integer, Row As Integer, Num As Integer, Col As Integer, L_R, Flx, wth As Integer, ctl, Ctl_Mvx
Dim Iflx As String, Apply_Msk As Integer, Oflx   As String, Max_Jj As Integer, Xfld As String, Len_Pline As Integer
Dim Addx, Colx, Dc_Pos, nx As Integer, First_Char As String, Afld As String, Op_Sign As String
Dim Dfld As String, Max_Ax As Integer, Ax As Integer, Achar As String, Fieldx As String, Code_Pfx As String, Atx As String, Mvx As String, Svx As String, Pfld As String
Dim Pkey As String, Code_Dsc As String, msk As String, temp As String, tempcur As Currency
'
'  Routine to print Council Rates Notice in USER-DEFINED format.
'
'  ACTION 0 = test print, 1 = print, 2 = tape
'
     Arithmetic = "+-*"
     If Pcode <> 0 Or senior <> 0 Then
        If Pcode <> 0 Then
           datums = Pick.replace(datums, 28, 0, 0, CStr(50 * CInt(Pcode)))   ' pensioner rebate rate)
           datums = Pick.replace(datums, 19, 0, 0, Pick.extract(Mess, 1, 0, 0)) ' message)
        Else
           datums = Pick.replace(datums, 94, 0, 0, CStr(25 * CInt(senior)))   ' pensioner rebate rate)
           datums = Pick.replace(datums, 19, 0, 0, Pick.extract(Mess, 3, 0, 0)) ' message)
        End If
     Else
        datums = Pick.replace(datums, 19, 0, 0, Pick.extract(Mess, 2, 0, 0)) ' message)
     End If
'
     Disc_Rate = Pick.extract(Disc_Arr, 1, 0, 0)
     DISC_DATE = Pick.extract(Disc_Arr, 2, 0, 0)
     Penalty_Rate = Pick.extract(Disc_Arr, 3, 0, 0)
     arr_date = Pick.extract(Disc_Arr, 4, 0, 0)
     Due_Date = Pick.extract(Disc_Arr, 6, 0, 0)
'
     If Area_Flg = "*" Then Area_Flg = 1 Else Area_Flg = 0
'
     datums = ""
     datums = Pick.replace(datums, 1, 0, 0, Pick.extract(Client_No, 1, 0, 0)) ' assessment number)
     datums = Pick.replace(datums, 2, 0, 0, Name1)          ' first owner name)
     datums = Pick.replace(datums, 3, 0, 0, Name2)          ' second owner name)
'
     For Ii = 1 To 4                  ' mailing address
        datums = Pick.replace(datums, 3 + Ii, 0, 0, MAILADDR(Ii))
     Next Ii
     For Ii = 7 To 4 Step -1          ' remove null lines
        If Pick.extract(datums, Ii, 0, 0) = "" Then
           datums = Pick.delet(datums, Ii, 0, 0)
        End If
     Next Ii
'
     datums = Pick.replace(datums, 8, 0, 0, Pick.extract(Client_Rec(1), 1, 1, 0)) ' property name)
     datums = Pick.replace(datums, 9, 0, 0, Pick.extract(Client_Rec(2), 1, 1, 0)) ' property address line 1)
     datums = Pick.replace(datums, 10, 0, 0, Pick.extract(Client_Rec(3), 1, 1, 0)) ' property address line 2)
     datums = Pick.replace(datums, 15, 0, 0, Pick.extract(Client_Rec(5), 1, 1, 0))
'
     Lots = Pick.extract(Property_Rec, 1, 0, 0)
     If Lots <> "" Then
        Max_Lots = Pick.dcount(Lots, Chr(253))
        For Ii = Max_Lots To 1 Step -1
           If Pick.extract(Lots, 1, Ii, 0) = "" Then Lots = Pick.delet(Lots, 1, Ii, 0)
        Next Ii
        Max_Lots = Pick.dcount(Lots, Chr(253))
        Lots = replace(Lots, Chr(253), " ")
        Lots = replace(Lots, "X", "")
        If Max_Lots = 1 Then Msg = "LOT" Else Msg = "LOTS"
        Lots = Msg & " " & Lots & ":"
     End If
'
     Locs = Pick.extract(Property_Rec, 2, 0, 0)
     If Locs <> "" Then
        Max_Locs = Pick.dcount(Locs, Chr(253))
        For Ii = Max_Locs To 1 Step -1
           If Pick.extract(Locs, 1, Ii, 0) = "" Then Locs = Pick.delet(Locs, 1, Ii, 0)
        Next Ii
        Max_Locs = Pick.dcount(Locs, Chr(253))
        Locs = replace(Locs, Chr(253), " ")
        Locs = replace(Locs, "X", "")
        If Max_Locs = 1 Then Msg = "LOCATION" Else Msg = "LOCATIONS"
        Locs = Msg & " " & Locs & ":"
     End If
     datums = Pick.replace(datums, 11, 0, 0, Locs)          ' location details)
     datums = Pick.replace(datums, 12, 0, 0, Lots)          ' lot details)
'
     Bar_Code = "":  Key_Line = ""
     If Pick.extract(Apbar_Ctl, 3, 1, 0) <> "" Then         ' australia post
        Bar_Tab = Pick.extract(Client_No, 1, 0, 0) & Chr(253) & Pick.extract(datum, 32, 0, 0)
        Call SR_APBAR(Apbar_Ctl, 1, Bar_Tab, Bar_Code, Key_Line)
     End If
     datums = Pick.replace(datums, 13, 0, 0, Bar_Code)
     datums = Pick.replace(datums, 14, 0, 0, Key_Line)
'
     datums = Pick.replace(datums, 16, 0, 0, Grv)      ' valuation)
     datums = Pick.replace(datums, 17, 0, 0, Ward_Desc)     ' ward description)
     datums = Pick.replace(datums, 18, 0, 0, Shire_Clerk)   ' shire clerk"s name)

     datums = Pick.replace(datums, 20, 0, 0, Start_Year)    ' start of rate year)
     datums = Pick.replace(datums, 21, 0, 0, Right(Space(2) & (Start_Year + 1), 2))
     datums = Pick.replace(datums, 22, 0, 0, Sdate)         ' service (issue) date)
     datums = Pick.replace(datums, 23, 0, 0, Due_Date)      ' payment due date)
     datums = Pick.replace(datums, 24, 0, 0, DISC_DATE)     ' discount date)
     datums = Pick.replace(datums, 25, 0, 0, arr_date)      ' arrears date)
     datums = Pick.replace(datums, 26, 0, 0, Disc_Rate)     ' discount % rate)
     datums = Pick.replace(datums, 27, 0, 0, Penalty_Rate)  ' penalty interest rate)
     
     datums = Pick.replace(datums, 29, 0, 0, Pick.extract(Minmax, 2, 0, 0))    ' minimum amount payable)
     datums = Pick.replace(datums, 85, 0, 0, Pick.extract(Minmax, 3, 0, 0))
'
     Max_Ii = Pick.dcount(Pick.extract(Rate_Tab, 1, 0, 0), Chr(253))
     For Ii = 1 To Max_Ii
        Curr_Amt = Pick.extractcur(Rate_Tab, 10, Ii, 0)
        Arrs_Amt = Pick.extractcur(Rate_Tab, 11, Ii, 0)
        Defr_Amt = Pick.extractcur(Rate_Tab, 12, Ii, 0)
        Disc_Amt = Pick.extractcur(Rate_Tab, 13, Ii, 0)
        Rebate_Amt = Pick.extractcur(Rate_Tab, 14, Ii, 0)
        senior_amt = Pick.extractcur(Rate_Tab, 27, Ii, 0)
        Remiss_Amt = Pick.extractcur(Rate_Tab, 15, Ii, 0)
        Net_Rebate = Curr_Amt - Rebate_Amt - senior_amt
        Net_Disc = Curr_Amt - Rebate_Amt - Disc_Amt - senior_amt
        Gtot_G = Curr_Amt + Arrs_Amt - Defr_Amt
        Gtot_Gr = Gtot_G - Rebate_Amt - Remiss_Amt - senior_amt
        Gtot_Grd = Gtot_Gr - Disc_Amt
'
        datums = Pick.replace(datums, 30, 0, 0, CStr(Pick.extractcur(datums, 30, 0, 0) + Gtot_G)) ' grand total)
        datums = Pick.replace(datums, 31, 0, 0, CStr(Pick.extractcur(datums, 31, 0, 0) + Gtot_Gr)) '  less rebate)
        datums = Pick.replace(datums, 32, 0, 0, CStr(Pick.extractcur(datums, 32, 0, 0) + Gtot_Grd)) '  less rebate/disc)
        datums = Pick.replace(datums, 33, 0, 0, CStr(Pick.extractcur(datums, 33, 0, 0) - Disc_Amt)) ' total discount)
        datums = Pick.replace(datums, 34, 0, 0, CStr(Pick.extractcur(datums, 34, 0, 0) - Rebate_Amt)) ' total rebate)
        datums = Pick.replace(datums, 35, 0, 0, CStr(Pick.extractcur(datums, 35, 0, 0) - Remiss_Amt)) ' total remission)
        datums = Pick.replace(datums, 95, 0, 0, CStr(Pick.extractcur(datums, 95, 0, 0) - senior_amt)) ' total current)
        datums = Pick.replace(datums, 36, 0, 0, CStr(Pick.extractcur(datums, 36, 0, 0) + Curr_Amt)) ' total current)
        datums = Pick.replace(datums, 37, 0, 0, CStr(Pick.extractcur(datums, 37, 0, 0) + Net_Rebate)) ' net (rebate))
        datums = Pick.replace(datums, 38, 0, 0, CStr(Pick.extractcur(datums, 38, 0, 0) + Net_Disc)) ' net (rebate&disc))
        datums = Pick.replace(datums, 39, 0, 0, CStr(Pick.extractcur(datums, 39, 0, 0) + Arrs_Amt)) ' total arrears)
        datums = Pick.replace(datums, 40, 0, 0, CStr(Pick.extractcur(datums, 40, 0, 0) + Defr_Amt)) ' total deferred)
'
        For Jj = 1 To 16
           datums = Pick.replace(datums, 40 + Jj, Ii, 0, Pick.extract(Rate_Tab, Jj, Ii, 0))
        Next Jj
        datums = Pick.replace(datums, 96, Ii, 0, Pick.extract(Rate_Tab, 27, Ii, 0)) 'senior rebates
        datums = Pick.replace(datums, 86, Ii, 0, Pick.extract(Rate_Tab, 22, Ii, 0))
        datums = Pick.replace(datums, 88, Ii, 0, Pick.extract(Rate_Tab, 23, Ii, 0))
        datums = Pick.replace(datums, 89, Ii, 0, Pick.extract(Rate_Tab, 24, Ii, 0))
     Next Ii
     datums = Pick.replace(datums, 33, 0, 0, Pick.extract(datums, 33, 0, 0) * -1)
     datums = Pick.replace(datums, 34, 0, 0, Pick.extract(datums, 34, 0, 0) * -1)
     datums = Pick.replace(datums, 35, 0, 0, Pick.extract(datums, 35, 0, 0) * -1)
     For Ii = 1 To Max_Ii
        datums = Pick.replace(datums, 53, Ii, 0, Pick.extractcur(datums, 53, Ii, 0) * -1)
        datums = Pick.replace(datums, 54, Ii, 0, Pick.extractcur(datums, 54, Ii, 0) * -1)
        datums = Pick.replace(datums, 55, Ii, 0, Pick.extractcur(datums, 55, Ii, 0) * -1)
        datums = Pick.replace(datums, 96, Ii, 0, Pick.extractcur(datums, 96, Ii, 0) * -1)
     Next Ii
'
     For Ii = 1 To 7                             ' instalment options
        datums = Pick.replace(datums, 59 + Ii, 0, 0, Pick.extract(Inst_Tab, Ii, 0, 0))
     Next Ii
'
     datums = Pick.replace(datums, 69, 0, 0, Pick.extract(Inst_Remind, 1, 0, 0))        ' next instalment date)
     datums = Pick.replace(datums, 70, 0, 0, Pick.extract(Inst_Remind, 2, 0, 0))        ' next amount due)
     datums = Pick.replace(datums, 71, 0, 0, Pick.extract(Inst_Remind, 3, 0, 0))        ' previous overdue)
     datums = Pick.replace(datums, 72, 0, 0, Pick.extract(Inst_Remind, 4, 0, 0))        ' penalty since last)
     datums = Pick.replace(datums, 73, 0, 0, Pick.extract(Inst_Remind, 5, 0, 0))        ' amount pre-paid)
'
     datums = Pick.replace(datums, 74, 0, 0, Pick.extract(PENALTY_TAB, 1, 0, 0))        ' total penalty)
     datums = Pick.replace(datums, 75, 0, 0, Pick.extract(PENALTY_TAB, 2, 0, 0))        ' rate on overdues)
     datums = Pick.replace(datums, 76, 0, 0, Pick.extract(PENALTY_TAB, 3, 0, 0))        ' rate on current)
     datums = Pick.replace(datums, 77, 0, 0, Interim_Details)
     datums = Pick.replace(datums, 78, 0, 0, Pick.extract(PENALTY_TAB, 4, 0, 0))        ' Penalty accrued 30/6EOY)
     datums = Pick.replace(datums, 79, 0, 0, Pick.extract(PENALTY_TAB, 5, 0, 0))        ' RATE ON ARREARS_)
     If Pick.extractint(Client_Rec(16), 1, 0, 0) Then datums = Pick.replace(datums, 80, 0, 0, "Senior   ")
     If Pick.extractint(Client_Rec(44), 1, 0, 0) Then
        If Pick.extractint(Client_Rec(84), 1, 0, 0) Then
           datums = Pick.replace(datums, 80, 0, 0, "Pens/Senior")
        Else
           datums = Pick.replace(datums, 80, 0, 0, "Pensioner")
        End If
     Else
        If Pick.extractint(Client_Rec(84), 1, 0, 0) Then datums = Pick.replace(datums, 80, 0, 0, "Senior")
     End If
     datums = Pick.replace(datums, 81, 0, 0, Interim_Amts)
     datums = Pick.replace(datums, 82, 0, 0, Interim_Bals)
     datums = Pick.replace(datums, 83, 0, 0, Pick.extract(Client_No, 2, 0, 0))
     datums = Pick.replace(datums, 84, 0, 0, Pick.extract(PENALTY_TAB, 6, 0, 0))
     datums = Pick.replace(datums, 87, 0, 0, Pick.extract(trans_rec, 3, 0, 0))
     datums = Pick.replace(datums, 90, 0, 0, Pick.extract(Rate_Tab, 25, 0, 0)) ' GST Code)
     datums = Pick.replace(datums, 91, 0, 0, Pick.extract(Rate_Tab, 26, 0, 0)) ' GST Amount)
     datums = Pick.replace(datums, 92, 0, 0, Interim_Gst_Codes)
     datums = Pick.replace(datums, 93, 0, 0, Interim_Gst_Amts)
     datums = Pick.replace(datums, 97, 0, 0, apamt)
     datums = Pick.replace(datums, 98, 0, 0, Pick.extract(trans_rec, 58, 0, 0))
     datums = Pick.replace(datums, 99, 0, 0, Pick.extract(trans_rec, 59, 0, 0))
     datums = Pick.replace(datums, 100, 0, 0, Pick.extract(trans_rec, 60, 0, 0))
     datums = Pick.replace(datums, 101, 0, 0, Pick.extract(trans_rec, 64, 0, 0))
     datums = Pick.replace(datums, 102, 0, 0, Pick.extract(trans_rec, 65, 0, 0))
     datums = Pick.replace(datums, 103, 0, 0, Pick.extract(trans_rec, 66, 0, 0))
'
' message for area of property
'
     If Area_Flg Then
        Un_Fl = "Ha_"
        xx = InStr(Pick.extract(Property_Rec, 1, 1, 0), " EL")
        If xx Then Un_Fl = "sq_ Km"
        Ar_Tot = 0
        Max_Ii = Pick.dcount(Pick.extract(Property_Rec, 7, 0, 0), Chr(253))
        For Ii = 1 To Max_Ii
           Ar_Tot = Ar_Tot + Pick.extract(Property_Rec, 7, Ii, 0)
        Next Ii
        Area_Mess = "AREA = " & Ar_Tot & " " & Un_Fl
        If Pick.extract(Rate_Desc, 2, 0, 0) = "GRV" Then Area_Mess = ""
     End If
'
     pt_line = "": Rowx = 1
     Max_Ii = Pick.dcount(Pick.extract(Format_Rec, 1, 0, 0), Chr(253))
     For Ii = 1 To Max_Ii
        temp = Pick.extract(Format_Rec, 2, Ii, 0)
        If Not IsNumeric(temp) Then Row = Rowx: GoTo 400
        If Mid$(temp, 1, 1) = "+" Then
           If IsNumeric(Pick.trimm(Mid$(temp, 2, 2))) Then Row = Rowx + CInt(Pick.trimm(Mid$(temp, 2, 2)))
           GoTo 400
        End If
        If Not IsNumeric(temp) Then Row = Rowx: GoTo 400
        Row = CInt(temp)
        If Row < 1 Or Row > 71 Then Row = Rowx: GoTo 400
400:
        Col = Pick.extract(Format_Rec, 3, Ii, 0)
        L_R = Pick.extract(Format_Rec, 4, Ii, 0)
        Flx = Pick.extract(Format_Rec, 5, Ii, 0)
        msk = Pick.extract(Format_Rec, 6, Ii, 0)
        wth = Pick.extractint(Format_Rec, 7, Ii, 0)
        ctl = Pick.extract(Format_Rec, 8, Ii, 0)
'
        Ctl_Mvx = 1
        If ctl <> "" Then             ' check controlling field
           Iflx = ctl
           Apply_Msk = 0
           GoSub 1000                ' build field
           If Pick.trimm(Oflx) = "" Then Flx = "": GoTo 990
           If Oflx = "0" Then Flx = "": GoTo 990
           If Oflx = String$(Len(Oflx), Chr(253)) Then Flx = "": GoTo 990
        End If
'
        Iflx = Flx
        Apply_Msk = 1
        GoSub 1000                   ' build data field
'
        Max_Jj = Pick.dcount(Oflx, Chr(253))
        For Jj = 1 To Max_Jj
           Rowx = Row + Jj - 1
           Xfld = Pick.extract(Oflx, 1, Jj, 0)
           Pline = Pick.extract(pt_line, Rowx, 0, 0)                 ' justification
'
           Len_Pline = Len(Pline) + 1
           If Len_Pline < Col Then
              Addx = Col - Len_Pline
              Pline = Pline & Space(Addx)      ' pad with spaces
           End If
'
           Select Case L_R
              Case "L"
                 If wth <> 0 Then
                    Xfld = Left(Xfld & Space(wth), wth)
                 End If
                 Colx = Len(Xfld)
                 Pline = Mid$(Pline, 1, Col - 1) & Xfld & Mid$(Pline, Col + Colx + 1, 9999) ' mco 13JAN97 COL to COL-1
              Case "R"
                 If wth <> 0 Then
                    Xfld = Right(Space(wth) & Xfld, wth)
                 End If
                 Colx = Len(Xfld)
                 Pline = Mid$(Pline, 1, Col) & Xfld & Mid$(Pline, Col + Colx + 1, 9999)
           End Select
           pt_line = Pick.replace(pt_line, Rowx, 0, 0, Pline)
        Next Jj
990  Next Ii
     Exit Sub
'
' s/r 1000:  Build data/control field
'            (converts IFLX to OFLX)
1000 Oflx = ""
1010 Dc_Pos = InStr(Iflx, "::")
     If Dc_Pos Then              ' convert double colon
        Iflx = Mid$(Iflx, 1, Dc_Pos - 1) & "~" & Mid$(Iflx, Dc_Pos + 1, 9999)
        GoTo 1010
     End If
'
     nx = 0
     Do                                     ' process each element
        nx = nx + 1
        Xfld = Pick.field(Iflx, ":", nx)
        If Xfld = "" Then Exit Do
        First_Char = Mid$(Xfld, 1, 1)
        Select Case First_Char
           Case "P"                ' property data
              Xfld = Mid$(Xfld, 2, 99)
              Fieldx = Pick.field(Xfld, ":", 1)
              Code_Pfx = Pick.field(Xfld, ":", 2)
              Atx = Pick.field(Fieldx, ",", 1)
              Mvx = Pick.field(Fieldx, ",", 2)
              If Mvx = "" Then Mvx = 1
              Svx = Pick.field(Fieldx, ",", 3)
              If Svx = "" Then Svx = 1
              Pfld = Pick.extract(Property_Rec, CInt(Atx), CInt(Mvx), CInt(Svx))
              If Code_Pfx = "" Then
                 If msk <> "" And Apply_Msk Then Pfld = Pick.oconv(Pfld, msk)
                 Oflx = Oflx & Pfld
              Else
                 Pkey = Code_Pfx & Pfld
                 If d3.d3_readstr(database, Code_Dsc, "PCODES", Pkey) <> 0 Then Code_Dsc = Pfld
                 Oflx = Oflx & Code_Dsc
              End If
           Case "'"               ' literal text"
              Xfld = Pick.field(Xfld, "'", 2)
              Oflx = Oflx & Xfld
           Case """"               ' literal text"
              Xfld = Pick.field(Xfld, """", 2)
              Oflx = Oflx & Xfld
           Case Else
            If IsNumeric(Left(First_Char, 1)) Then      ' datum /arithmetic
              Afld = "":  Op_Sign = "":  Dfld = ""
              Max_Ax = Len(Xfld)
              For Ax = 1 To Max_Ax
                 Achar = Mid$(Xfld, Ax, 1)
                 If InStr(Arithmetic, Achar) Then
                    GoSub 1100
                    Op_Sign = Achar
                 Else
                    Afld = Afld & Achar
                 End If
              Next Ax
              If Afld <> "" Then
                 GoSub 1100
              End If
              If msk <> "" And Apply_Msk Then
                 Dfld = Pick.oconv(Dfld, msk)
              End If
              Oflx = Oflx & Dfld
            End If
        End Select
        Dc_Pos = InStr(Oflx, "~")
        If Dc_Pos Then
           Oflx = Mid$(Oflx, 1, Dc_Pos - 1) & ":" & Mid$(Oflx, Dc_Pos + 1, 9999)
        End If
     Loop
     Return
'
' s/r 1100:  extract selected DATUM field
'
1100 Atx = Pick.field(Afld, ",", 1)
     Mvx = Pick.field(Afld, ",", 2)
     If Mvx = "" Then Mvx = "1"
     Svx = Pick.field(Afld, ",", 3)
     If Svx = "" Then Svx = "1"
     If Mvx = "A" Then Mvx = "0": Svx = "0"
     temp = Pick.extract(datums, CInt(Atx), CInt(Mvx), CInt(Svx))
     If Op_Sign = "" Then             ' datum field only
        Dfld = temp
     Else                         ' apply arithmetic
        If Not IsNumeric(temp) Then temp = "0"
        If IsNumeric(Dfld) Then tempcur = CCur(Dfld) Else tempcur = 0
        Select Case Op_Sign
           Case "+":  Dfld = CStr(tempcur + CCur(temp))
           Case "-":   Dfld = CStr(tempcur - CCur(temp))
           Case "*":  Dfld = CStr(tempcur * CCur(temp))
        End Select
     End If
     Afld = ""
     Return

End Sub

Public Sub SR16_defer(Apply_Defer As String, Client_Rec() As String, Tr_Date As Integer, allow_defer As Currency)
'
' routine to determine if arrears transaction is deferred
'
Dim dfx As Integer, check_defer As Integer, end_pdate As String, posn As Integer

     allow_defer = 0
     If Apply_Defer = "Y" Then      ' check if deferred
        If Client_Rec(17) <> "" Then
           posn = Pick.locate(CStr(Tr_Date), Client_Rec(17), 1, 1, 0, dfx, "AR")
           check_defer = 0
           If Pick.extract(Client_Rec(17), 1, dfx, 0) = CStr(Tr_Date) Then
              check_defer = 1
           Else
              dfx = dfx - 1
              If dfx <> 0 Then
                 end_pdate = Pick.extract(Client_Rec(18), 1, dfx, 0)
                 If end_pdate = "" Then
                    check_defer = 1
                 Else
                    If Tr_Date <= end_pdate Then check_defer = 1
                 End If
              End If
           End If
           If check_defer = 1 And Pick.extract(Client_Rec(19), 1, dfx, 0) = "Y" Then allow_defer = 1
        End If
     End If
End Sub

Public Sub SR300_INSPEN(database As String, ptab As String, Client_No As String, tr_type As Integer, Tr_Ref As String, Tr_Date As Integer, arrdate As Integer, Pcode As Integer, senior As Integer, cx As String, Tr_Payment As Currency, UREF As String, PENALTY_TAB As String, INT_METH As Integer, clrec() As String, CASH_DATE As String, ACCRUING As Currency, CALC_DATE As Integer, allow_defer As Currency)
     
Dim posn As Integer, Pos As Integer, rcx As Integer, Prefix As String, Ptx As Integer
Dim start_date As String, Qq As Integer, temp As String
Dim qqdate As Integer, qqamt As Currency, qqinstal As String, PEN_AMT As Currency
Dim PEN_PERC As Currency, days_due As Currency, accr As Currency

     If PENALTY_TAB <> "" And INT_METH = 0 Then
        Call SR16_PENSDTE(database, Client_No, start_date, tr_type, Tr_Ref, Tr_Date, arrdate, Pcode, cx, Tr_Payment, CASH_DATE, UREF, CALC_DATE)
        Prefix = Mid$(Tr_Ref, 1, 2)
        posn = Pick.locate(Prefix, PENALTY_TAB, 1, 1, 0, rcx, "")
        If posn <> 0 Then
           If Pcode <> 0 And Pick.extract(PENALTY_TAB, 12, rcx, 0) = "Y" Then Exit Sub 'mc 11jun99
           Call SR16_defer(Pick.extract(PENALTY_TAB, 11, rcx, 0), clrec, Tr_Date, allow_defer)
           If allow_defer Then Exit Sub
        End If
        If start_date = "" Then Exit Sub
        For Qq = 1 To Pick.dcount(Pick.extract(start_date, 1, 0, 0), Chr(253))
           temp = Pick.extract(start_date, 1, Qq, 0)
           If IsNumeric(temp) Then qqdate = CInt(temp) Else qqdate = 0
           temp = Pick.extract(start_date, 2, Qq, 0)
           If temp = "" Then
              qqamt = Tr_Payment
           Else
              If IsNumeric(temp) Then qqamt = CCur(temp) Else qqamt = 0
           End If
           qqinstal = Pick.extract(start_date, 3, Qq, 0)
           Call SR1694_PENALTY(database, PEN_AMT, PEN_PERC, Prefix, PENALTY_TAB, qqdate, CALC_DATE, qqamt, days_due, accr)
           
           If PEN_AMT <> 0 Then
              ACCRUING = ACCRUING + PEN_AMT
              posn = Pick.locate(Prefix, ptab, 1, 1, 0, Ptx, "")
              If posn = 0 Then
                 If Pick.extract(ptab, 1, 0, 0) = "" Then
                    Ptx = 1
                 Else
                    Ptx = Pick.ccount(Pick.extract(ptab, 1, 0, 0), Chr(253), 0) + 2
                 End If
                 ptab = Pick.replace(ptab, 1, Ptx, 0, Prefix)
              End If
              temp = Pick.extract(ptab, 2, Ptx, 0)
              If IsNumeric(temp) Then temp = CStr(CCur(temp) + PEN_AMT) Else temp = CStr(PEN_AMT)
              ptab = Pick.replace(ptab, 2, Ptx, 0, temp)
              ptab = Pick.insert(ptab, 3, Ptx, -1, "Penalty on " & Tr_Ref & " for $" & Format(qqamt / 100, "#.00") & " for " & days_due & " days @ " & PEN_PERC & "%  => $" & Format(PEN_AMT / 100, "#.00"))
              ptab = Pick.insert(ptab, 4, Ptx, -1, CStr(PEN_PERC))
              ptab = Pick.insert(ptab, 5, Ptx, -1, CStr(days_due))
              ptab = Pick.insert(ptab, 6, Ptx, -1, Tr_Ref)
              ptab = Pick.insert(ptab, 7, Ptx, -1, CStr(PEN_AMT))
              ptab = Pick.insert(ptab, 8, Ptx, -1, CStr(qqamt))
              ptab = Pick.insert(ptab, 9, Ptx, -1, Client_No)
              ptab = Pick.insert(ptab, 10, Ptx, -1, CStr(qqdate))
              temp = Pick.extract(ptab, 11, 0, 0)
              If IsNumeric(temp) Then temp = CStr(CCur(temp) + accr) Else temp = CStr(accr)
              ptab = Pick.replace(ptab, 11, 0, 0, temp)
              If IsNumeric(qqinstal) Then temp = CStr(qqinstal) Else temp = "0"
              ptab = Pick.insert(ptab, 12, Ptx, -1, temp)
           End If
        Next Qq
     End If

End Sub

Public Sub SR1694_PENALTY(database As String, PEN_AMT As Currency, PEN_PERC As Currency, Prefix As String, PENALTY_TAB As String, start_date As Integer, Cur_Date As Integer, OSTAND As Currency, days_due As Currency, accr As Currency)

Dim Pos As Integer, posn As Integer, Ptx As Integer, temp As String, install As String

     PEN_AMT = 0
     
     If start_date = 0 Then Exit Sub
     days_due = (Cur_Date - start_date)
     If days_due <= 0 Then Exit Sub
     
'
     posn = Pick.locate(Prefix, PENALTY_TAB, 1, 1, 0, Ptx, "")
     If posn = 0 Then
        If d3.d3_readstr(database, install, "DICT TRANS.J", "@INSTALL") <> 0 Then install = ""
        posn = Pick.locate(Prefix, install, 22, 1, 0, Ptx, "")
        If posn = 0 Then
           posn = Pick.locate(Prefix, install, 23, 1, 0, Ptx, "")
           If posn = 0 Then Exit Sub
        End If
'        If Prefix <> "II" And Prefix <> "IA" Then Exit Sub
        Ptx = 1
     End If
     PEN_PERC = Pick.extractcur(PENALTY_TAB, 2, Ptx, 0)
     If OSTAND > 0 Then
        PEN_AMT = Int(OSTAND * PEN_PERC * days_due / 36500 + 0.5)
        accr = Int(OSTAND * PEN_PERC / 365)
     End If

End Sub


Public Sub SR300_PENACC(cat_no As String, Int_Acc As String, Prec() As String, INT_ACCS As String)

Dim Pcats As String, Cindx As Integer
'
' Get penalty interest account to credit
'
     If Mid$(cat_no, 1, 1) = "!" Then     ' sundry  - GL a/c
        Int_Acc = Mid$(cat_no, 2, 99)
        If Int_Acc = "" Then Int_Acc = "WASNULL " & cat_no
     Else                 ' ascertain from rate category
        Pcats = Prec(29)
        If Pick.locate(cat_no, Pcats, 1, 1, 0, Cindx, "") = 0 Then Cindx = 1
        Int_Acc = Pick.extract(INT_ACCS, Cindx, 0, 0)
        If Int_Acc = "" Then Int_Acc = "WASNULL " & cat_no
     End If

End Sub

Public Sub SR1693(database As String, Client_Rec() As String, Pcode As Integer, Owner_Names As String, Pension_Nos As String, Pmsg As String, First_Orec As String, Phones As String)

Dim Qld_Fmt As Integer, temp As String, P_Flag As Integer, nz As String, Ptype As Integer, Attr As Integer
Dim Name_Switch As Integer, kk As Integer, Ono As String, Orec As String, Ans As String, All_Pens As Integer
Dim Pno As String, Pt As String, Plural As String, Qmsg As String, STATE_REBATE As String, Subsidy As String, Remiss As String
'
' Routine to set up (multi) owner names and pensioner number/s
' and determine property pensioner status.
'
     temp = Mid$(g_trans_info_array(53), 4, 1)
     If IsNumeric(temp) Then Qld_Fmt = CInt(temp) Else Qld_Fmt = 0
     temp = Mid$(g_trans_info_array(53), 17, 1)
     If IsNumeric(temp) Then P_Flag = CInt(temp) Else P_Flag = 0
     nz = g_trans_info_array(133)
     temp = Mid$(g_trans_info_array(53), 19, 1)
     If IsNumeric(temp) Then Ptype = CInt(temp) Else Ptype = 0
     If nz = "1" Then Attr = 37 Else Attr = 35
     If Phones = "ALL" Then All_Pens = 1 Else All_Pens = 0 'MC 04MAY99
     Owner_Names = "": Pension_Nos = "": First_Orec = "": Phones = ""
'
     Name_Switch = 0
     kk = 0
     Do
        kk = kk + 1
        Ono = Pick.extract(Client_Rec(Attr), 1, kk, 0)
        If Ono = "" Then Exit Do
        If d3.d3_readstr(database, Orec, "CLIENT", Ono) <> 0 Then Orec = ""
        If kk = 1 Then First_Orec = Orec
        Ans = Pick.extract(Orec, 1, 0, 0)
        If Ans = Mid$(Owner_Names, 4, Len(Ans)) And Name_Switch <= 1 Then
           Owner_Names = Owner_Names & " & " & Pick.trimm(Ans & " " & Pick.extract(Orec, 6, 0, 0))
        Else
           Name_Switch = Name_Switch + 1
           If Name_Switch > 2 And All_Pens = 0 Then  'MC 04MAY99
              If Name_Switch = 3 Then
                 Owner_Names = Owner_Names & " & others"
              End If
           Else
              Owner_Names = Owner_Names & " & " & Pick.trimm(Ans & " " & Pick.extract(Orec, 6, 0, 0))
           End If
        End If
        Pno = Pick.extract(Orec, 43, 0, 0): Pt = Pick.extract(Orec, 14, 0, 0)
        If Pno <> "" Then
           If Ptype Then Pno = Pno & " (" & Pt & ")"
           If Pension_Nos = "" Then
              Pension_Nos = Pno
           Else
              Pension_Nos = Pension_Nos & " & " & Pno
           End If
        End If
        If Phones = "" Or Phones = Chr(253) & Chr(253) Then Phones = Pick.extract(Orec, 9, 0, 0)
     Loop
'
     Owner_Names = Mid$(Owner_Names, 4, 999)
'
     If Pension_Nos <> "" And All_Pens = 0 Then
        If InStr(Pension_Nos, " & ") Then Plural = "s " Else Plural = " "
        Pension_Nos = " (Pensioner" & Plural & Pension_Nos & ")"
     End If
     If IsNumeric(Client_Rec(44)) Then Pcode = CInt(Client_Rec(44)) Else Pcode = 0
     If Pcode Then
        If P_Flag = 2 Then
           Qmsg = ""
           If Qld_Fmt Then
              If d3.d3_readstr(database, STATE_REBATE, "DICT TRANS.J", "@STATE_REBATE") <> 0 Then STATE_REBATE = ""
              Subsidy = Pick.extract(STATE_REBATE, 4, 1, 0)
              If Subsidy Then
                 Subsidy = Subsidy * 100 * Pcode
                 Qmsg = Qmsg & ", Subsidy &  " & Subsidy & "%"
              End If
              Remiss = Pick.extract(STATE_REBATE, 4, 2, 0)
              If Remiss Then
                 Remiss = Remiss * 100 * Pcode
                 Qmsg = Qmsg & ", Remission &  " & Remiss & "%"
              End If
           End If
           Pmsg = "** " & Pcode * 100 & "% Pensioner" & Qmsg & " **"
        Else
           Pmsg = "** Pensioner Property **"
        End If
     Else
       If Pension_Nos = "" Then
         Pmsg = ""
       Else
          Pmsg = "** NOT Pensioner Property **"
       End If
     End If
     If Pcode = 0 And Client_Rec(16) <> "" Then
        Pmsg = "** Senior Property **"
     End If

End Sub

Public Sub SR300_R(database As String, utcode As Integer, utref As String, utdate As Integer, Client_No As String, tr_bal As Currency, use_inv_date As Integer, arrdate As Integer, Disc_Amt As Currency, Client_Rec() As String, rtab As String, Rebate_Amt As Currency, auto_dates As String, rebate_gross As Currency, allow_defer As Currency)
'
' Find amount payable for Council transactions
' n.b.  TR.BAL will be returned with maximum allocatable balance
'       ORIDE.BAL will be returned with default balance to allocate
'                 (applies to manual allocations only)
'
Dim Cde As String, oninstal As Integer, instal_ref As String, rderr As Integer
Dim dd As Integer, Adj As Integer, xtr_bal As Currency, temp As String
Dim Rates_Rec As String, Rates_Id As String, rebate_allowed As Integer
Dim SERVICE_DATE As Integer, DISC_DATE As String, rebate_disc As Currency
Dim inv_id As String, DISC_PERC As Currency, IREC As String, Rtx As Integer
Dim Apply_Defer As String, posn As Integer, Pos As Integer, Prefix As String
Dim oride_bal As Currency

     oride_bal = 0: allow_defer = 0
     rebate_gross = 0: Rebate_Amt = 0: Disc_Amt = 0
'     If PROG = "TA670" And REF_ENT Then Exit Sub
'
     Cde = Pick.extract(auto_dates, 1, 10, 0)
     oninstal = 0
     If Cde = "PNET" Then GoTo 1050
     If Cde = "PCR" Then GoTo 1050
'
     If d3.d3_readstr(database, instal_ref, "INSTALL_CTL", Client_No) = 1 Then instal_ref = ""

     For dd = 1 To 9999
        Adj = (dd - 1) * 20
        If Pick.extract(instal_ref, 10 + Adj, 0, 0) = "" Then GoTo 1050
        If Pick.extract(instal_ref, 15 + Adj, 0, 0) = "" Then GoTo 1040
        If Pick.extract(instal_ref, 16 + Adj, 0, 0) <> "" Then GoTo 1040
        posn = Pick.locate(utref, instal_ref, 6 + Adj, 1, 0, Pos, "")
        If posn = 0 Then GoTo 1040
        oninstal = 1
        Exit For
1040 Next dd

1050 xtr_bal = tr_bal
     oride_bal = tr_bal
     Select Case utcode
        Case 73                          ' rates
           Rates_Id = utref & "*" & Client_No
           If d3.d3_readstr(database, Rates_Rec, "RATES", Rates_Id) = 1 Then Rates_Rec = ""
           temp = Pick.extract(Rates_Rec, 3, 0, 0)
           If IsNumeric(temp) Then SERVICE_DATE = CInt(temp) Else SERVICE_DATE = 0
           DISC_DATE = Pick.extract(Rates_Rec, 11, 0, 0)
           temp = Pick.extract(Rates_Rec, 12, 0, 0)
           If IsNumeric(temp) Then Disc_Amt = CCur(temp) Else Disc_Amt = 0
           temp = Pick.extract(Rates_Rec, 21, 0, 0)
           If IsNumeric(temp) Then rebate_gross = CCur(temp) Else rebate_gross = 0
           temp = Pick.extract(Rates_Rec, 22, 0, 0)
           If IsNumeric(temp) Then rebate_disc = CCur(temp) Else rebate_disc = 0
        Case 50                          ' sundry invoice
           inv_id = utref
           If d3.d3_readstr(database, IREC, "INVOICE", inv_id) = 1 Then IREC = ""
           temp = Pick.extract(IREC, 20, 0, 0)
           If IsNumeric(temp) Then SERVICE_DATE = CInt(temp) Else SERVICE_DATE = 0
           temp = Pick.extract(IREC, 43, 1, 0)
           If IsNumeric(temp) Then DISC_PERC = CCur(temp) Else DISC_PERC = 0
           DISC_DATE = Pick.extract(IREC, 43, 2, 0)
           temp = Pick.extract(IREC, 8, 0, 0)
           If IsNumeric(temp) Then Disc_Amt = CCur(temp) Else Disc_Amt = 0
           Disc_Amt = Int(DISC_PERC * Disc_Amt / 100 + 0.5)
           temp = Pick.extract(IREC, 45, 2, 0)
           If IsNumeric(temp) Then rebate_gross = CCur(temp) Else rebate_gross = 0
           temp = Pick.extract(IREC, 45, 3, 0)
           If IsNumeric(temp) Then rebate_disc = CCur(temp) Else rebate_disc = 0
        Case Else                                  ' other
           SERVICE_DATE = utdate
           DISC_DATE = ""
           Disc_Amt = 0
           rebate_gross = 0
           rebate_disc = 0
     End Select
     If SERVICE_DATE = 0 Then SERVICE_DATE = utdate
'
     If Not IsNumeric(DISC_DATE) Then GoTo sr300_r_bad
     If DISC_DATE <> "" And use_inv_date <= CInt(DISC_DATE) And oninstal = 0 Then
        oride_bal = oride_bal - Disc_Amt
        tr_bal = tr_bal - Disc_Amt          ' reduce by discount
        Rebate_Amt = rebate_disc
     Else
sr300_r_bad:
        Disc_Amt = 0
        Rebate_Amt = rebate_gross
     End If
'
     rebate_allowed = 0
     If SERVICE_DATE < arrdate Then
        If use_inv_date <= SERVICE_DATE + 183 Then rebate_allowed = 1 ' within 6 months of service
     Else
        rebate_allowed = 1
     End If
     If rebate_allowed = 1 Then
        tr_bal = tr_bal - Rebate_Amt        ' reduce by rebate
        oride_bal = oride_bal - Rebate_Amt
     Else                               ' arrears
        Rebate_Amt = 0 'MCO 23APR99
        If Client_Rec(17) <> "" Then
           Prefix = Mid$(utref, 1, 2)
           posn = Pick.locate(Prefix, rtab, 1, 1, 0, Rtx, "")
           If posn <> 0 Then Apply_Defer = Pick.extract(rtab, 3, Rtx, 0) Else Apply_Defer = "N"
           Call SR16_defer(Apply_Defer, Client_Rec(), SERVICE_DATE, allow_defer)
           If allow_defer Then
              allow_defer = tr_bal
              oride_bal = 0
              tr_bal = 0                 ' - ignore deferred rates
           End If
        End If
     End If
'
     If tr_bal < 0 Then tr_bal = 0
     If tr_bal > xtr_bal Then tr_bal = xtr_bal
'
     If oride_bal < 0 Then oride_bal = 0
     If oride_bal > xtr_bal Then oride_bal = xtr_bal
End Sub

Public Sub sr682_ctl(database As String, print_ctl As String, R_Desc As String, MAX_CAT As Integer, flattr As Integer)
'
' Get relevant descriptions for rates print control
'
Dim rates_print_ctl As String, descs As String, I As Integer

     flattr = 0
     If d3.d3_readstr(database, rates_print_ctl, "DICT TRANS.J", "@RATES.PRINT.CTL") <> 0 Then rates_print_ctl = ""
     If rates_print_ctl <> "" Then
        descs = "Rates"
        descs = Pick.replace(descs, 2, 0, 0, "Water")
        descs = Pick.replace(descs, 3, 0, 0, "WaterCons")
        descs = Pick.replace(descs, 4, 0, 0, "Sewerage")
        descs = Pick.replace(descs, 5, 0, 0, "Garbage")
        descs = Pick.replace(descs, 6, 0, 0, "Fire Levy")
        MAX_CAT = 0: R_Desc = "": print_ctl = ""
        For I = 1 To 6
           If Pick.extract(rates_print_ctl, I, 0, 0) <> "" Then
              MAX_CAT = MAX_CAT + 1
              print_ctl = Pick.replace(print_ctl, MAX_CAT, 0, 0, Pick.extract(rates_print_ctl, I, 0, 0))
              R_Desc = Pick.replace(R_Desc, MAX_CAT, 0, 0, Pick.extract(descs, I, 0, 0))
              If I = 6 Then flattr = MAX_CAT ' which attr has fire levy
           End If
        Next I
        MAX_CAT = MAX_CAT + 1
        R_Desc = Pick.replace(R_Desc, MAX_CAT, 0, 0, "Sundry")
     Else
        print_ctl = "RT"
        print_ctl = Pick.replace(print_ctl, 2, 0, 0, "RB")
        MAX_CAT = 3
        R_Desc = "Rates"
        R_Desc = Pick.replace(R_Desc, 2, 0, 0, "Rubbish")
        R_Desc = Pick.replace(R_Desc, 3, 0, 0, "Other")
     End If

End Sub

Public Sub SR682(database As String, Cr_Rec As String, Client_No As String, from_date As Integer, to_date As Integer, payto_date As Integer, Eom As String, eom_val As String, want As Integer, print_ctl As String, Cde As String, other As Integer)
'
' Analyse debtor transactions as at a given date
'
' where WANT is defined as follows:
' '' =  usual 682, balance owing by month, use EOM and EOM.VAL
'  1 =  balance owing by transaction code
'       use EOM only attr 1 = transaction code
'                    attr 2 = total amount
'                    attr 3 = total owing as at date given
'  2 =  code ex 1651 gives amounts by categories defined in CDE
'       EOM attr 3 for after to.date
'           attr 2 for from.date to to.date
'           attr 1 for prior from.date
'       each attr, vals for rate types as given in PRINT.CTL
'           attrs eg 1 rates, 2 water, 3 excess
'       each val, sval 1 levy, 2 rebate, 3 discount, 4 jnl dr,
'           5 jnl cr, 6 receipt, 7 penalty, 8 other, 9 total of all,
'           10 remission (WANT=4) (included in 9 total also)
'  3 =  as for 2 but only uses balances owing / unallocated
'  4 =  as for 2 but get rebate & remission from INVOICE file
'  5 =  specific to TA682ARA, uses statement date instead of ledger date
'  6 =  as for 2 but will ignore arrears paid transactions (1642)
'  7 =  as for 2 but specific coding for deferrements report. Will pass
'       back only balance of deffered transactions.
'
' ====== Additional to all formats: =======
'    EOM.VAL<1,10> contains total unallocated credit incurred AFTER
'                  TO.DATE
'
'
Dim want7 As Integer, mult_date As Integer, Client_Rec As String
Dim Tr_Cash As Integer, Tr_Disc As Integer, REBATE_ON_LEVY As String
Dim maxval As Integer, rderr As Integer, temp As String
Dim st_cr_oflow As Integer, oflow_key As String, Cr_No_Trans As Integer
Dim Cr_Code As String, Cr_Ref As String, Cr_Tdate As String, Cr_Tamt As String, cr_tbal As String
Dim Cr_Xref As String, Cr_Xamt As String, Cr_Ldate As String, Cr_Xdate As String, cr_sdate As String
Dim TR_POS As Integer, cr_oflow As Integer, tempval As Currency
Dim Tr_Ref As String, tr_amt As Currency, tr_bal As Currency, tr_code As Integer
Dim tr_ldate As String, Tr_Date As String
Dim tr_xamt As String, Sbl As Integer, tr_xtdate As String, xamt As Currency
Dim Tr_Xref As String, Tr_Xdate As String, trans_date As String, use_mult_date As Integer
Dim adding As Integer, Use_Date As String, unalloc As Currency
Dim Dt_Flg As Integer, Cd_Flg As Integer, Jj As Integer, iii As Integer
Dim amt2 As Currency, amtot As Currency, pxval As Integer, px As String
Dim inv_id As String, max_sbl As Integer

'     If want = 7 Then
'        If d3.d3_readstr(database,client_rec, "CLIENT", client_no) <> 0 Then client_rec = ""
'     End If
     want7 = 0
     If payto_date = 0 Then
        mult_date = 0
        payto_date = to_date
     Else
        mult_date = 1
     End If
'
     Tr_Cash = 31: Tr_Disc = 41
'
     If UBound(g_trans_info_array) = 0 Then
        g_trans_info_array(0) = "TRANS.INFO"
        rderr = d3.d3_readmat(database, g_trans_info_array(), "DICT TRANS.J")
     End If
     If UBound(g_trans_info_array) < 53 Then temp = "" Else temp = g_trans_info_array(53)
     REBATE_ON_LEVY = Mid$(temp, 21, 1)
     If want = 2 Or want = 3 Or want = 4 Or want = 6 Or want = 7 Then
'
' follow format of RATES.PRINT.CTL
' 1=RATES, 2=WATER, 3=EXCESS WATER, 4=SEWERAGE, 5=RUBBISH, 6=FIRELEVY
' 7= EVERYTHING ELSE
'
        maxval = Pick.dcount(print_ctl, Chr(254))
        If Cde = "" Then
           Cde = Pick.replace(Cde, 22, 0, 0, 1): Cde = Pick.replace(Cde, 48, 0, 0, 1)
           Cde = Pick.replace(Cde, 73, 0, 0, 1): Cde = Pick.replace(Cde, 77, 0, 0, 1)
           Cde = Pick.replace(Cde, 25, 0, 0, 1): Cde = Pick.replace(Cde, 50, 0, 0, 1)
           Cde = Pick.replace(Cde, 37, 0, 0, 2): Cde = Pick.replace(Cde, 62, 0, 0, 2)
           Cde = Pick.replace(Cde, 41, 0, 0, 3): Cde = Pick.replace(Cde, 66, 0, 0, 3)
           Cde = Pick.replace(Cde, 58, 0, 0, 4): Cde = Pick.replace(Cde, 33, 0, 0, 5)
           Cde = Pick.replace(Cde, 31, 0, 0, 6): Cde = Pick.replace(Cde, 56, 0, 0, 6)
           Cde = Pick.replace(Cde, 35, 0, 0, 6): Cde = Pick.replace(Cde, 60, 0, 0, 6) ' cash & cancelled cash)
'          CDE<41> = 6;  CDE<66> = 6      ;* discount
           Cde = Pick.replace(Cde, 76, 0, 0, 7): Cde = Pick.replace(Cde, 23, 0, 0, 7) ' penalty)
           other = "8"
        End If
     End If
     temp = Pick.extract(Cr_Rec, 27, 0, 0)
     If IsNumeric(temp) Then cr_oflow = CInt(temp) Else cr_oflow = 0
     If cr_oflow = 0 Then Exit Sub
     st_cr_oflow = cr_oflow + 1
100  oflow_key = (st_cr_oflow - cr_oflow) & "*" & Client_No
     If d3.d3_readstr(database, Cr_Rec, "TD.OFLOW", oflow_key) <> 0 Then Cr_Rec = ""
     temp = Pick.extract(Cr_Rec, 1, 0, 0)
     If IsNumeric(temp) Then Cr_No_Trans = CInt(temp) Else Cr_No_Trans = 0
     Cr_Code = Pick.extract(Cr_Rec, 2, 0, 0)
     Cr_Ref = Pick.extract(Cr_Rec, 3, 0, 0)
     Cr_Tdate = Pick.extract(Cr_Rec, 5, 0, 0)
     Cr_Tamt = Pick.extract(Cr_Rec, 4, 0, 0)
     cr_tbal = Pick.extract(Cr_Rec, 6, 0, 0)
     Cr_Xref = Pick.extract(Cr_Rec, 9, 0, 0)
     Cr_Xamt = Pick.extract(Cr_Rec, 10, 0, 0)
     Cr_Ldate = Pick.extract(Cr_Rec, 11, 0, 0)
     Cr_Xdate = Pick.extract(Cr_Rec, 12, 0, 0)
     cr_sdate = Pick.extract(Cr_Rec, 13, 0, 0)

     cr_oflow = cr_oflow - 1
'
     For TR_POS = 1 To Cr_No_Trans
        Tr_Ref = Pick.extract(Cr_Ref, 1, TR_POS, 0)
        temp = Pick.extract(Cr_Tamt, 1, TR_POS, 0)
        If IsNumeric(temp) Then tr_amt = CCur(temp) Else tr_amt = 0
        temp = tr_amt - Pick.extract(cr_tbal, 1, TR_POS, 0)
        If IsNumeric(temp) Then tr_bal = CCur(temp) Else tr_bal = 0
        temp = Pick.extract(Cr_Code, 1, TR_POS, 0)
        If IsNumeric(temp) Then tr_code = CInt(temp) Else tr_code = 0
        tr_ldate = Pick.extract(Cr_Ldate, 1, TR_POS, 0)
'        tr_sdate = pick.extract(cr_sdate, 1, tr_pos, 1)
'
        If want = 3 Then
           If tr_bal = 0 Then GoTo 300
           tr_amt = tr_bal
           Tr_Date = Pick.extract(Cr_Tdate, 1, TR_POS, 0)
           If Not IsNumeric(Tr_Date) Then Tr_Date = "0"
           Tr_Ref = Pick.extract(Cr_Ref, 1, TR_POS, 0)
           GoSub 2000
           GoTo 300
        End If
        If want = 2 Or want = 4 Or want = 6 Or want = 7 Then
           Tr_Date = Pick.extract(Cr_Tdate, 1, TR_POS, 0)
           If want = 6 Then
              If Tr_Ref = "PURGE" And tr_bal = 0 Then GoTo 300
              If tr_code >= 50 And CInt(Tr_Date) < from_date Then
                 tr_xamt = "0"
                 For Sbl = 1 To 999
                    tr_xtdate = Pick.extract(Cr_Xdate, 1, TR_POS, Sbl)
                    If tr_xtdate = "" Then
                       tr_amt = tr_amt - CCur(tr_xamt)
                       If tr_amt = 0 Then GoTo 300
                       GoTo 170
                    End If
                    temp = Pick.extract(Cr_Xamt, 1, TR_POS, Sbl)
                    If IsNumeric(temp) Then xamt = CCur(temp) Else xamt = 0
                    tr_xamt = CStr(CCur(tr_xamt) + xamt)
                 Next Sbl
              End If
           End If
170        If want = 7 Then
'              Call SR16_defer("Y", client_rec, tr_date, allow_defer)
'              If allow_defer = 0 Then GoTo 300
           End If
           Tr_Ref = Pick.extract(Cr_Ref, 1, TR_POS, 0)
           Tr_Xref = Pick.extract(Cr_Xref, 1, TR_POS, 0)
           tr_xamt = Pick.extract(Cr_Xamt, 1, TR_POS, 0)
           Tr_Xdate = Pick.extract(Cr_Xdate, 1, TR_POS, 0)
           GoSub 2000
           GoTo 300
        End If
'
'        If want = 5 Then
'           trans_date = tr_sdate
'           If trans_date = "" Then trans_date = tr_ldate
'        Else
           trans_date = tr_ldate
'        End If
        If InStr(trans_date, "/") Then
           trans_date = Pick.field(trans_date, "/", 2)
        End If
        If trans_date = "" Then trans_date = "0"
'
        use_mult_date = 0
        If to_date <> 0 Then
           If CInt(trans_date) > to_date Then
              If tr_code >= 50 Then GoTo 180
              If tr_bal = tr_amt Then                  ' unallocated
                 eom_val = Pick.replace(eom_val, 1, 10, 0, Pick.extract(eom_val, 1, 10, 0) + Abs(tr_bal))
                 GoTo 300
              End If
              use_mult_date = mult_date
           End If
        End If
        If from_date <> 0 Then
           If CInt(trans_date) < from_date Then
              If tr_code >= 50 Then GoTo 300
              If tr_bal = tr_amt Then GoTo 300         ' unallocated
           End If
        End If
        If tr_code >= 50 Then
           Use_Date = trans_date
           GoSub 1000
180        If want = 5 Then
'              TRS_ID = client_no & "*" & tr_ldate & "*" & tr_ref
'              WRITEV TRANS_DATE ON TD_STATE_DATA,TRS_ID,1
           End If
           GoTo 300
        End If
        If to_date <> 0 Or from_date <> 0 Then
           If (CInt(trans_date) > payto_date And payto_date <> 0) Or (CInt(trans_date) < from_date And from_date <> 0) Then
              adding = 1
           Else
              If tr_bal And use_mult_date = 0 Then     ' unallocated
                 If want = 5 And tr_code = Tr_Cash Then
                    eom_val = Pick.replace(eom_val, 1, 11, 0, Pick.extract(eom_val, 1, 11, 0) + tr_bal)
                 Else
                    Use_Date = trans_date
                    GoSub 1000
                 End If
              End If
              adding = 0
           End If
           unalloc = tr_bal
           For Jj = 1 To 99999
              Tr_Xref = Pick.extract(Cr_Xref, 1, TR_POS, Jj)
              If Tr_Xref = "" Then GoTo 220
              tr_bal = Pick.extract(Cr_Xamt, 1, TR_POS, Jj)
              tr_xtdate = Pick.field(Pick.extract(Cr_Xdate, 1, TR_POS, Jj), "*", 1)
              If InStr(tr_xtdate, "/") Then tr_xtdate = Pick.field(tr_xtdate, "/", 2)
              If want = 5 Then
'                 TRS_ID = client_no & "*" & tr_xtdate & "*" & tr_xref
'                 READV TR_XDATE FROM TD_STATE_DATA,TRS_ID,1 ELSE TR_XDATE = ""
                 If Tr_Xdate = "" Then Tr_Xdate = tr_xtdate
              Else
                 Tr_Xdate = tr_xtdate
              End If
              If adding Then
 '                IF (TO_DATE pick.extract(, TR_XDATE AND TO_DATE <> "",0,0) OR (FROM_DATE ) TR_XDATE AND FROM_DATE <> "") THEN GOTO 200
                 Use_Date = Tr_Xdate
              Else
                 If (payto_date >= CInt(Tr_Xdate) And payto_date <> 0) Or (from_date <= CInt(Tr_Xdate) And from_date <> 0) Then GoTo 200
                 If payto_date <> to_date And CInt(Tr_Xdate) > to_date Then GoTo 200
                 Use_Date = trans_date
                 tr_bal = -tr_bal
              End If
              GoSub 1000
200        Next Jj
220        If unalloc <> 0 Then                 ' remaining unallocated
              If CInt(trans_date) > to_date Then
                 temp = Pick.extract(eom_val, 1, 10, 0)
                 If IsNumeric(temp) Then tempval = CCur(temp) Else tempval = 0
                 If unalloc < 0 Then tempval = tempval - unalloc Else tempval = tempval + unalloc
225              eom_val = Pick.replace(eom_val, 1, 10, 0, CStr(tempval))
              Else
                 If want = 5 Then
                    If tr_code <> Tr_Cash Then GoTo 225
                 End If
              End If
           End If
        Else
           If tr_bal <> 0 Then
              Use_Date = trans_date
              GoSub 1000
           End If
        End If
300  Next TR_POS
     If cr_oflow > 0 Then GoTo 100
     Exit Sub
'
' s/r 1000:  age debtor amounts
'
1000 Select Case want
        Case "1"
 '          LOCATE(TR_CODE,EOM,1,1,0,III,"AR") ELSE
 '             EOM = Insert(EOM, 1, III, 0, TR_CODE)
 '             EOM = Insert(EOM, 2, III, 0, 0)
 '             EOM = Insert(EOM, 3, III, 0, 0)
 '          End If
 '          EOM = pick.Replace(EOM, 2, III, 0, pick.extract(EOM, 2, III, 0) + tr_amt)
 '          EOM = pick.Replace(EOM, 3, III, 0, pick.extract(EOM, 3, III, 0) + tr_bal)
        Case Else
           Jj = Pick.locate(Use_Date, Eom, 1, 1, 0, iii, "AR")
           temp = Pick.extract(eom_val, 1, iii, 0)
           If IsNumeric(temp) Then tempval = CCur(temp) Else tempval = 0
           eom_val = Pick.replace(eom_val, 1, iii, 0, CStr(tempval + tr_bal))
     End Select
     Return
'
' Code from 1651
'
2000 If to_date <> 0 And CInt(Tr_Date) > to_date Then
        Dt_Flg = 3
     Else
        If CInt(Tr_Date) >= from_date Then
           Dt_Flg = 2
        Else
           Dt_Flg = 1
        End If
     End If
     temp = Pick.extract(Cde, tr_code, 0, 0)
     If temp = "" Or Not IsNumeric(temp) Then Cd_Flg = other Else Cd_Flg = CInt(temp)
'
'     If want = 7 And dt_flg = 2 Then
'        inv_id = tr_ref & "*" & client_no
'        If d3.d3_readstr(database,rates_rec, "RATES", inv_id) <> 0 Then rates_rec = ""
'        If pick.extract(rates_rec, 23, 0, 0) + 0 = 0 And pick.extract(rates_rec, 21, 0, 0) + 0 <> 0 Then
'           eom_val = pick.Replace(eom_val, 4, 0, 0, pick.extract(eom_val, 4, 0, 0) + pick.extract(rates_rec, 2, 0, 0))
'        End If
'     End If
'
     px = Mid$(Tr_Ref, 1, 2): GoSub 2200
     If pxval <> 0 Then
        If want = 6 And tr_code < 50 And tr_bal = 0 Then
           If CInt(Tr_Date) < from_date Then GoTo 2020
           If tr_code = Tr_Disc Then GoTo 2020    ' check disc on last year
        End If
'        If want = 7 Then
'           If tr_bal = 0 And dt_flg = 2 Then Return
'           want7 = 1
'           TR.AMT=TR.BAL
'        End If
        GoSub 2100
        want7 = 0
'        If WANT = 4 Then
'           inv_id = tr_ref & "*" & CLIENT_NO
'           If d3.d3_readstr(database,irec, "INVOICE", inv_id) <> 0 Then Return
'           tr_amt = pick.extract(-irec, 45, 7, 0)      ' rebate subsidy
'           CD_FLG = 2:  GoSub 2100
'           tr_amt = pick.extract(-irec, 45, 8, 0)      ' remission
'           CD_FLG = 10:  GoSub 2100
'           disc_perc = pick.extract(irec, 43, 1, 0)
'           TR_AMT = -INT(pick.extract(IREC,8,0,0)*DISC_PERC/100+_5)
'           CD_FLG = 3:  GoSub 2100
'        End If
        If want <> 7 Then Return
     End If
     
'     If want = 7 Then
'        If pxval = 0 Then Return
'        If CInt(tr_code) < 50 Then Return
'        If dt_flg = 2 Then Return
'       see if current credits paid off deferred arrears
'        For sbl = 1 To 999
'           If pick.extract(tr_xref, 1, 1, sbl) = "" Then Return
'           If pick.extract(tr_xdate, 1, 1, sbl) > from_date Then
'              temp = pick.extract(tr_xamt, 1, 1, sbl)
'              If IsNumeric(temp) Then tr_amt = CCur(temp) Else tr_amt = 0
'              temp = pick.extract(eom, dt_flg, pxval, 12)
'              If IsNumeric(temp) Then tr_amt = tr_amt + CCur(temp)
'              eom = pick.Replace(eom, dt_flg, pxval, 12, CStr(tr_amt))
'           End If
'        Next sbl
'     End If
'     If want = 3 Then
'        pxval = maxval + 1: GoSub 2100: Return   ' unallocated credits
'     End If

2020 amt2 = tr_amt: amtot = 0
     max_sbl = Pick.dcount(Pick.extract(Tr_Xref, 1, 1, 0), Chr(252))
     For Sbl = 1 To max_sbl
        px = Mid$(Pick.extract(Tr_Xref, 1, 1, Sbl), 1, 2): GoSub 2200
        If pxval = 0 Then pxval = maxval + 1
        temp = Pick.extract(tr_xamt, 1, 1, Sbl)
        If IsNumeric(temp) Then tr_amt = CCur(temp) Else tr_amt = 0
        If tr_code < 50 Then tr_amt = -tr_amt
        If want = 6 And tr_code < 50 Then
           tr_xtdate = Pick.field(Pick.extract(Cr_Xdate, 1, TR_POS, Sbl), "*", 1)
           If InStr(tr_xtdate, "/") Then tr_xtdate = Pick.field(tr_xtdate, "/", 2)
           If CInt(tr_xtdate) < from_date Then amtot = amtot + tr_amt: GoTo 2050
        End If
        amtot = amtot + tr_amt
        GoSub 2100
2050 Next Sbl
     pxval = maxval + 1
     tr_amt = amt2 - amtot
     GoSub 2100
     Return
'
2100 temp = Pick.extract(Eom, Dt_Flg, pxval, Cd_Flg)
'If dt_flg = 2 And pxval = 1 And cd_flg = 2 Then
'MsgBox temp & "=" & tr_amt & "=" & tr_ref
'End If
     If IsNumeric(temp) Then tempval = tr_amt + CCur(temp) Else tempval = tr_amt
     Eom = Pick.replace(Eom, Dt_Flg, pxval, Cd_Flg, CStr(tempval))
     temp = Pick.extract(Eom, Dt_Flg, pxval, 9)
     If IsNumeric(temp) Then tempval = tr_amt + CCur(temp) Else tempval = tr_amt
     Eom = Pick.replace(Eom, Dt_Flg, pxval, 9, CStr(tempval))
'     If want7 Then
'        eom = pick.Replace(eom, dt_flg, pxval, 10, tr_bal + pick.extract(eom, dt_flg, pxval, 10))
'        eom = pick.Replace(eom, dt_flg, pxval, 11, tr_amt + pick.extract(eom, dt_flg, pxval, 11))
'     End If
     Return
'
' Find val depending on prefix of reference
'
2200 For pxval = 1 To maxval
        Jj = Pick.locate(px, print_ctl, pxval, 1, 0, iii, "")
        If Jj <> 0 Then Return
     Next pxval
     pxval = 0
     Return


End Sub

Public Sub SR_APBAR(Apbar_Ctl As String, Apx As Integer, Bar_Tab As String, Bar_Code As String, Key_Line As String)

Dim Primes As String, Client_No As String, Amount As String, Bar_Leadin As String, Key_Leadin As String, Ap_Cust_Id As String
Dim Trans_Type As String, Bcx As String, Total_Value As Currency, Ii As Integer, Strx As String
Dim Dec_Code As Integer, Weight As Integer, value As Currency, Checksum As Integer, Prime_Tot As Currency, Mod97 As Integer
Dim temp As String
'
' Routine to generate Australia Post barcode line & key line
'
     Primes = 3 & Chr(253) & 5 & Chr(253) & 7 & Chr(253) & 11 & Chr(253) & 13 & Chr(253) & 17 & Chr(253) & 19 & Chr(253) & 23 & Chr(253) & 29 & Chr(253) & 31 & Chr(253) & 37 & Chr(253) & 41 & Chr(253) & 43 & Chr(253) & 47 & Chr(253) & 53 & Chr(253) & 59 & Chr(253) & 61 & Chr(253) & 67 & Chr(253) & 71
'
     Client_No = Pick.extract(Bar_Tab, 1, 1, 0)
     Amount = Pick.extract(Bar_Tab, 1, 2, 0)
'
     Bar_Leadin = Pick.extract(Apbar_Ctl, 1, 1, 0)        ' barcode lead-in
     Key_Leadin = Pick.extract(Apbar_Ctl, 1, 2, 0)        ' key line lead-in
     Ap_Cust_Id = Pick.extract(Apbar_Ctl, 2, 0, 0)          ' customer id
     Trans_Type = Pick.extract(Apbar_Ctl, 3, Apx, 0)      ' transaction type
'
     Bcx = ""                              ' 32 digit string
     Bcx = Bcx & Right(Space(6) & Bar_Leadin & Ap_Cust_Id, 6)
     Bcx = Bcx & Right(Space(9) & Abs(Amount), 9)
     Client_No = Right(Space(5) & Client_No, 5)
     Bcx = Bcx & Right(Space(16) & Trans_Type & Client_No, 16)
     Bcx = Bcx & "0"
'
     Bar_Code = ""
     Key_Line = ""
'
'---for each numeric digit pair in the data, perform encoding and
'---generate weighted value for later checksum calculation.
'
     Total_Value = 0
     For Ii = 1 To 32 Step 2        ' numeric digit pair_
        temp = Pick.trimm(Mid$(Bcx, Ii, 2))    ' encoding of numeric digit pair.
        If temp = "00" Then
           Dec_Code = 174
        Else
           If IsNumeric(temp) Then Strx = CInt(temp) Else Strx = 0
           If Strx <= 93 Then
              Dec_Code = Strx + 32
           Else
              Dec_Code = Strx + 71
           End If
        End If
'---append encoded numeric digit pair to encoded barcode string.
        Bar_Code = Bar_Code & Chr(Dec_Code)
        If Dec_Code = 34 Then Bar_Code = Bar_Code & Chr(Dec_Code)
'---calculate weight.
        Weight = (Ii + 1) / 2
'---calculate weighted value, and accumulate.
        value = Strx * Weight
        Total_Value = Total_Value + value
     Next Ii
'
'---calculate checksum.
     Total_Value = Total_Value + 105
     Checksum = Total_Value Mod 103
'---encode checksum.
     If Checksum = 0 Then
        Checksum = Chr(174)
     Else
        If Checksum + 0 <= 93 Then
           Checksum = Chr(Checksum + 32)
        Else
           Checksum = Chr(Checksum + 71)
        End If
     End If
     If Checksum = """" Then Checksum = Checksum & Checksum
'
'---build the complete encoded barcode string and store.
     Bar_Code = Chr(163) & Bar_Code & Checksum & Chr(164)
'
'
' calculate keying line checksum.
'
     Bcx = ""
     Bcx = Bcx & Right(Space(3) & Ap_Cust_Id, 3)
'*[PM]start
'*** BCX = BCX:TRANS.TYPE "R%3"
     Bcx = Bcx & Right(Space(16) & Trans_Type & Client_No, 16)
'*[PM]end
'
     Prime_Tot = 0
     For Ii = 1 To 19
        Prime_Tot = Prime_Tot + Mid$(Bcx, Ii, 1) * Pick.extractint(Primes, 1, Ii, 0)
     Next Ii
' now subtract the modulus 97 of the running total from 97,
     Mod97 = 97 - Prime_Tot Mod 97
     Key_Line = Key_Leadin & "  " & Ap_Cust_Id & "  " & Trans_Type & Client_No & "  " & Mod97

End Sub

Public Function sr16_catdesc(database As String, Rcat As Integer) As String

Dim rderr As Integer

     If UBound(g_rates) = 0 Then
        g_rates(0) = "@RATES"
        rderr = d3.d3_readmat(database, g_rates(), "DICT TRANS.J")
     End If

     sr16_catdesc = Pick.extract(g_rates((CInt(Rcat) - 1) * 10 + 9), 1, 1, 0)

End Function

Public Sub SR16_PAYINS(d_rec, INS_AMT As Currency, CASH_DATE As String, cash_key As String, payments As String, CALC_DATE, PAYING_ALL)
'
'  apply payment against next outstanding instalment
'
Dim temp As String, numins As Integer, amt_left As Currency, kk As Integer, amt_due As Currency
Dim Amt As Currency, iamt As Currency, xx As Integer, posn As Integer, start_date As String, tempint As Integer

     temp = Pick.extract(CStr(d_rec), 85, 0, 0)
     If IsNumeric(temp) Then numins = CInt(temp) Else numins = 0
     payments = ""
     amt_left = INS_AMT
     For kk = 1 To numins
        temp = Pick.extract(CStr(d_rec), 90, kk, 0)
        If IsNumeric(temp) Then amt_due = CCur(temp) Else amt_due = 0
        temp = Pick.extract(CStr(d_rec), 92, kk, 0)
        If IsNumeric(temp) Then amt_due = amt_due - CCur(temp)
        If amt_due > 0 And amt_left Then
           iamt = amt_left
           If iamt > amt_due Then iamt = amt_due
           temp = Pick.extract(CStr(d_rec), 92, kk, 0)
           If IsNumeric(temp) Then temp = CStr(CCur(temp) + iamt) Else temp = CStr(iamt)
           d_rec = Pick.replace(CStr(d_rec), 92, kk, 0, temp) 'payment details)
           posn = Pick.locate(cash_key, Pick.extract(CStr(d_rec), 94, kk, 1), 1, 1, 1, xx, "")
           If posn = 0 Then
              d_rec = Pick.insert(CStr(d_rec), 93, kk, -1, CASH_DATE)
              d_rec = Pick.insert(CStr(d_rec), 94, kk, -1, cash_key)
           End If
           amt_left = amt_left - iamt
           start_date = Pick.extract(CStr(d_rec), 86, kk, 0)
           If IsNumeric(start_date) Then tempint = CInt(start_date) Else tempint = 0
           If CALC_DATE - tempint > 0 And kk <> 1 Then
              payments = Pick.insert(payments, 1, -1, 0, start_date)
              payments = Pick.insert(payments, 2, -1, 0, CStr(iamt))
              payments = Pick.insert(payments, 3, -1, 0, CStr(kk))
           End If
           If amt_left <= 0 Then GoTo 2010
        End If
     Next kk
2010 If PAYING_ALL Then
'RGM ** ERROR **
'What on Earth is pick.extract(0) trying to do? Had to guess a solution as this is nonsensical...
'        If pick.extract(CStr(d_rec), 92, 0, pick.extract(0) <> d_rec, 90) Then
        If Pick.extract(CStr(d_rec), 92, 0, 0) <> Pick.extract(CStr(d_rec), 90, 0, 0) Then
           d_rec = Pick.replace(CStr(d_rec), 92, 0, 0, Pick.extract(CStr(d_rec), 90, 0, 0))
           d_rec = Pick.replace(CStr(d_rec), 94, numins, 0, Pick.extract(CStr(d_rec), 94, numins, 0) & "-PAIDALL")
        End If
     End If

End Sub





Public Sub SR1629(database As String, nrec() As String)

' DISPLAY PROPERTY HISTORY

Dim maxl As Integer, Prec As String, Crec As String, ownadj As Integer
Dim Startdate As String, Startnum As Integer, Prophdg As String
Dim Arec As String, Maxa As Integer, cnt As Integer, ptl As String
Dim Lct As Integer, rderr As Integer, Qld_Fmt As String
Dim C(999) As String, Hdesc As String, prop As String
Dim temp As String, Pnum As Integer, P_Maxsvm As Integer
Dim Attr As Integer, Name As String, Max As Integer, Num_New As Integer
Dim Cnum As Integer, Cct As Integer, Readp As Integer, Readc As Integer, Pct As Integer
Dim rec As String, Client_No As String, the_date As String, the_narr As String
Dim tst As Integer, the_old As String, the_new As String, tempcur As Currency, tempcur2 As Currency
Dim the_msg As String, I As Integer, J As Integer, Ii As Integer
Dim This_Cat As Integer, This_Attr As Integer, This_Code As String, This_Desc As String, This_Fld As String
Dim the_new_incr As String, Old_Incr As String, Sold As String, sthe_new As String
Dim Oldj As String, Emsg As String, Nomayvote As Integer, the_newj As String
Dim Pclrec As String, client_ids As String, posn As Integer, Pos As Integer
Dim WorkArr() As String, PropId As String, ChangeType As String, ChangeNo As String

     ReDim Preserve nrec(10): Lct = 1: Startnum = 0
     
     If UBound(g_rates) = 0 Then
        g_rates(0) = "@RATES"
        I = d3.d3_readmat(database, g_rates(), "DICT TRANS.J")
     End If

     'which = pick.extract(WHICH_FLAGS, 1, 1, 0)
     'WANTDISP = pick.extract(WHICH_FLAGS, 1, 2, 0)
     'OPER = pick.extract(WHICH_FLAGS, 1, 3, 0)
     
'     If pick.extract(startnum, 1, 2, 0) = "D" Then
'        startdate = pick.extract(startnum, 1, 1, 0)
'        startnum = ""
'     Else
'        startdate = ""
'     End If
'     qld_fmt = Mid$(g_trans_info_array(53), 4, 1)
'     XLINES = ""
'     NOMAYVOTE = Mid$(pick.extract(TRANS_INFO, 53, 0, 0), 1, 1) + 0
     WorkArr() = Split(nrec(0), "|", , vbBinaryCompare)
     ChangeType = WorkArr(0)
     PropId = WorkArr(1)
     ChangeNo = WorkArr(2)
     rderr = d3.d3_readstr(database, prop, "PROPERTY", PropId)
     rderr = d3.d3_readstr(database, Pclrec, "CLIENT", PropId)
     client_ids = ""
     For I = 35 To 37       ' include owner,occupier,elector
          For Ii = 1 To 999
               Client_No = Pick.extract(Pclrec, I, Ii, 0)
               If Client_No = "" Then Exit For
               posn = Pick.locate(Client_No, client_ids, 1, 1, 0, Pos, "")
               If posn = 0 Then
                  client_ids = Pick.insert(client_ids, 1, -1, 0, Client_No)
               End If
        Next Ii
     Next I
     rderr = d3.d3_readstr(database, Prophdg, "DICT TRANS.J", "@PROPERTY")

     If Prophdg = "" Then
        Prophdg = Pick.replace(Prophdg, 1, 1, 0, "Lot"): Prophdg = Pick.replace(Prophdg, 2, 1, 0, "Location")
        Prophdg = Pick.replace(Prophdg, 5, 1, 0, "Frontage"): Prophdg = Pick.replace(Prophdg, 6, 1, 0, "Depth"): Prophdg = Pick.replace(Prophdg, 7, 1, 0, "Area"): Prophdg = Pick.replace(Prophdg, 8, 1, 0, "Zoning")
        Prophdg = Pick.replace(Prophdg, 9, 1, 0, "Pres Use"): Prophdg = Pick.replace(Prophdg, 10, 1, 0, "Bldg Type"): Prophdg = Pick.replace(Prophdg, 12, 1, 0, "Pool")
        Prophdg = Pick.replace(Prophdg, 14, 1, 0, "Min Rate"): Prophdg = Pick.replace(Prophdg, 15, 1, 0, "Curr Value")
        Prophdg = Pick.replace(Prophdg, 18, 1, 0, "S/Unit"): Prophdg = Pick.replace(Prophdg, 19, 1, 0, "Rate Flag")
        Prophdg = Pick.replace(Prophdg, 21, 1, 0, "Rubbish"): Prophdg = Pick.replace(Prophdg, 22, 1, 0, "Strat Plan")
        Prophdg = Pick.replace(Prophdg, 26, 1, 0, "Fut Value"): Prophdg = Pick.replace(Prophdg, 27, 1, 0, "Prev Zone")
        Prophdg = Pick.replace(Prophdg, 29, 1, 0, "Val Categ"): Prophdg = Pick.replace(Prophdg, 30, 1, 0, "Unit Categ")
        Prophdg = Pick.replace(Prophdg, 34, 1, 0, "Reval Date"): Prophdg = Pick.replace(Prophdg, 35, 1, 0, "Reval Eff")
        Prophdg = Pick.replace(Prophdg, 38, 1, 0, "Ward")
     End If

     If d3.d3_readstr(database, Arec, "SCROLL.KEYS", "@A|PROPERTY") <> 0 Then Arec = ""
     Maxa = Pick.dcount(Arec, Chr(254))
     For I = 1 To Maxa
        If Pick.extract(Prophdg, I, 1, 0) = "" Then Prophdg = Pick.replace(Prophdg, I, 1, 0, Pick.extract(Arec, I, 1, 0))
     Next I

     C(1) = "Name": C(2) = "Address-1": C(3) = "Address-2": C(4) = "Address-3"
     C(5) = "Postcode": C(32) = "Votes Cncl": C(33) = "Votes Mayl"
     C(16) = "Senior No": C(17) = "Pen Start": C(18) = "Pen ENDIF": C(19) = "Defer"
     C(14) = "Pens type"
     C(34) = "Qual": C(35) = "Owners": C(36) = "Electors": C(37) = "Occupiers"
     C(38) = "Roll": C(43) = "Pens no": C(44) = "Rebate"
     ownadj = 0
'
100: If ownadj = 0 Then
          Client_No = PropId
       Else
          Client_No = Pick.extract(client_ids, 1, cnt, 0)
          If Client_No = "" Then
             For I = 1 To Lct - 1
                  If Pick.extract(nrec(6), 1, I, 0) = "" Then nrec(6) = Pick.replace(nrec(6), 1, I, 0, " ")
             Next I
             Exit Sub
          End If
       End If

   If ownadj = 0 Then
     If Pick.extract(prop, 42, 0, 0) <> "" Or Pick.extract(prop, 43, 0, 0) <> "" Or Pick.extract(prop, 44, 0, 0) <> "" Or Pick.extract(prop, 45, 0, 0) <> "" Then
        the_date = Pick.date_pick_to_vb(Pick.extract(prop, 42, 0, 0))
        the_msg = "Added"
        the_narr = Pick.extract(prop, 43, 0, 0)
        If Pick.extract(prop, 44, 0, 0) <> "" Then the_narr = the_narr & Chr(253) & Pick.extract(prop, 44, 0, 0)
        If Pick.extract(prop, 45, 0, 0) <> "" Then the_narr = the_narr & Chr(253) & Pick.extract(prop, 45, 0, 0)
        GoSub 5000
    End If
  Else
     rderr = d3.d3_readstr(database, Pclrec, "CLIENT", Client_No)
     the_narr = Client_No & "-" & Pick.trimm(Pick.extract(Pclrec, 8, 0, 0) & " " & Pick.extract(Pclrec, 7, 0, 0) & " " & Pick.extract(Pclrec, 1, 0, 0))
     GoSub 5000
  End If
'
'950  If d3.d3_readstr(database, rec, "CHANGES", "P" & "|" & CLIENT_NO) <> 0 Then rec = ""
'     temp = pick.extract(rec, 2, 0, 0)
'     If IsNumeric(temp) Then pnum = CInt(temp) Else pnum = 0
     Pct = 0
'     If d3.d3_readstr(database, rec, "CHANGES", "C" & "|" & CLIENT_NO) <> 0 Then rec = ""
'     temp = pick.extract(rec, 2, 0, 0)
'     If IsNumeric(temp) Then cnum = CInt(temp) Else cnum = 0
     Cct = 0
     Readp = 1: Readc = 1
     If ChangeType = "P" Then
        Readp = 1
        Readc = 0
     Else
        Readc = 1
        Readp = 0
     End If
'     If which = "P" Then readc = 0: crec = "99999": pct = startnum - 1
'     If which = "C" Then readp = 0: prec = "99999": cct = startnum - 1
'
1000 If Readp = 1 Then
'1005    pct = pct + 1
'        If pct <= pnum Then
           If d3.d3_readstr(database, rec, "CHANGES", "P" & "|" & Client_No & "|" & ChangeNo) <> 0 Then Exit Sub
           'If startdate <> "" Then
           '   If pick.extract(prec, 1, 0, 0) < startdate Then GoTo 1000
           'End If
'        Else
'           Prec = "99999"
'        End If
'        readp = 0
     End If
     If Readc Then
'1010    cct = cct + 1
'        If cct <= cnum Then
           If d3.d3_readstr(database, rec, "CHANGES", "C" & "|" & Client_No & "|" & Cct) <> 0 Then Exit Sub
           'If startdate <> "" Then
           '   If pick.extract(crec, 1, 0, 0) < startdate Then GoTo 1000
           'End If
'        Else
'           Crec = "99999"
'        End If
'        readc = 0
     End If
'     temp = pick.extract(Prec, 1, 0, 0)
'     If IsNumeric(temp) Then tempcur = CCur(temp) Else tempcur = 0
'     temp = pick.extract(Crec, 1, 0, 0)
'     If IsNumeric(temp) Then tempcur2 = CCur(temp) Else tempcur2 = 0
'     If tempcur = tempcur2 Then tst = 2 Else tst = 1
'     temp = pick.extract(Prec, tst, 0, 0)
'     If IsNumeric(temp) Then tempcur = CCur(temp) Else tempcur = 0
'     temp = pick.extract(Crec, tst, 0, 0)
'     If IsNumeric(temp) Then tempcur2 = CCur(temp) Else tempcur2 = 0
'     If tempcur <= tempcur2 Then readp = 1: rec = Prec Else readc = 1: rec = Crec
'     If rec = "99999" Then
'        If ownadj = 0 Then
'           For i = 1 To lct - 1
'              If pick.extract(nrec(1), 1, i, 0) = "" Then nrec(1) = pick.replace(nrec(1), 1, i, 0, " ")
'           Next i
'           ownadj = 5: cnt = 1: lct = 1
'        Else
'           cnt = cnt + 1
'        End If
'        the_old = "": the_new = "": the_msg = "": the_date = "": the_narr = ""
'        GoTo 100
'     End If

     the_date = Pick.date_pick_to_vb(Pick.extract(rec, 1, 0, 0))
     the_narr = Pick.extract(rec, 6, 0, 0)
     Call Pick.sr_change(the_narr, Chr(253), "<BR>")
     For I = 1 To 999
        temp = Pick.extract(rec, 7, I, 0)
        If IsNumeric(temp) Then
           Attr = CInt(temp)
        Else
           If the_narr <> "" Or the_date <> "" Then GoSub 5000
           Exit Sub
        End If
        the_old = Pick.extract(rec, 6 + 2 * I, 0, 0): the_old = Pick.delet(the_old, 1, 1, 0)
        the_new = Pick.extract(rec, 7 + 2 * I, 0, 0): the_new = Pick.delet(the_new, 1, 1, 0)
        If Readp Then
           the_msg = Pick.extract(Prophdg, Attr, 1, 0)
           Select Case Attr
            Case 34, 35
              If the_old <> "" Then the_old = Pick.date_pick_to_vb(the_old)
              If the_new <> "" Then the_new = Pick.date_pick_to_vb(the_new)
            Case 29
              For J = 1 To 9999
                If Pick.extract(the_old, 1, J, 0) = "" And Pick.extract(the_new, 1, J, 0) = "" Then GoTo 1300
                If Pick.extract(the_old, 1, J, 1) <> "" Or Pick.extract(the_old, 1, J, 2) <> "" Then
                  temp = Pick.extract(the_old, 1, J, 1)
                  If IsNumeric(temp) Then This_Cat = CInt(temp) Else This_Cat = 0
                  This_Attr = (This_Cat * 10) - 1
                  This_Code = Pick.extract(g_rates(This_Attr), 1, 2, 0)
                  This_Desc = Pick.extract(g_rates(This_Attr), 1, 1, 0)
                  This_Fld = This_Code & " " & Pick.extract(the_old, 1, J, 1) & "/" & Pick.extract(the_old, 1, J, 2) & " " & This_Desc
                  the_old = Pick.replace(the_old, 1, J, 0, This_Fld)
                Else
                  the_old = Pick.replace(the_old, 1, J, 0, "")
                End If
                
                If Pick.extract(the_new, 1, J, 1) <> "" Or Pick.extract(the_new, 1, J, 2) <> "" Then
                  temp = Pick.extract(the_new, 1, J, 1)
                  If IsNumeric(temp) Then This_Cat = CInt(temp) Else This_Cat = 0
                  This_Attr = (This_Cat * 10) - 1
                  This_Code = Pick.extract(g_rates(This_Attr), 1, 2, 0)
                  This_Desc = Pick.extract(g_rates(This_Attr), 1, 1, 0)
                  This_Fld = This_Code & " " & Pick.extract(the_new, 1, J, 1) & "/" & Pick.extract(the_new, 1, J, 2) & " " & This_Desc
                  the_new = Pick.replace(the_new, 1, J, 0, This_Fld)
                Else
                  the_new = Pick.replace(the_new, 1, J, 0, "")
                End If
             Next J
           Case 30
             If the_new <> "" Then
                the_new_incr = Pick.extract(the_new, 1, 1, 5)
                the_new = Pick.extract(the_new, 1, 1, 1) & "," & Pick.extract(the_new, 1, 1, 2) & " to " & Pick.extract(the_new, 1, 1, 3) & " in yr" & Pick.extract(the_new, 1, 1, 4) + 0 & " "
                If the_new_incr <> "" Then the_new = the_new & "int " & the_new_incr
             End If
             If the_old <> "" Then
                Old_Incr = Pick.extract(the_old, 1, 1, 5)
                the_old = Pick.extract(the_old, 1, 1, 1) & "," & Pick.extract(the_old, 1, 1, 2) & " to " & Pick.extract(the_old, 1, 1, 3) & " in yr" & Pick.extract(the_old, 1, 1, 4) + 0 & " "
                If Old_Incr <> "" Then the_old = the_old & "int " & Old_Incr
             End If
1300    End Select
        Else
           the_msg = C(Attr)
           If Attr = 32 Or Attr = 33 Or Attr = 34 Or Attr = 38 Then GoTo 1690
' these will be done by finding 36 first - electoral information
           If Attr = 35 Or Attr = 36 Or Attr = 37 Then
              Sold = the_old: sthe_new = the_new
              the_old = "": the_new = ""
              For J = 1 To 999
                 Oldj = Pick.extract(Sold, 1, J, 0)
                 If Oldj = "" Then GoTo 1610
                 If d3.d3_readstr(database, Name, "CLIENT", Oldj) <> 0 Then Name = ""
                 Name = Pick.extract(Name, 1, 0, 0) & " " & Pick.extract(Name, 6, 0, 0)
                 the_old = Pick.insert(the_old, 1, -1, 0, Name)
                 If Attr = 36 Then
                    'RGM  ** ERROR **  Not passing enough parameters!!!
                    'emsg = "Roll " & pick.extract(rec, 6 + (I + 1) * 2, 2) & " Qual " & pick.extract(rec, 6 + (I + 2) * 2, 2) & " Cncl " & pick.extract(rec, 6 + (I + 3) * 2, 2)
                    Emsg = "Roll " & Pick.extract(rec, 6 + (I + 1) * 2, 2, 0) & " Qual " & Pick.extract(rec, 6 + (I + 2) * 2, 2, 0) & " Cncl " & Pick.extract(rec, 6 + (I + 3) * 2, 2, 0)
                    If Nomayvote = 0 Then
                       'RGM  ** ERROR **  Was not passing enough parameters!!!
                       Emsg = Emsg & " Mayl " & Pick.extract(rec, 6 + (I + 4) * 2, 2, 0)
                    End If
                    the_old = Pick.insert(the_old, 1, -1, 0, Emsg)
                 End If
              Next J
1610          For J = 1 To 999
                 the_newj = Pick.extract(sthe_new, 1, J, 0)
                 If the_newj = "" Then GoTo 1620
                 If d3.d3_readstr(database, Name, "CLIENT", the_newj) <> 0 Then Name = ""
                 Name = Pick.extract(Name, 1, 0, 0) & " " & Pick.extract(Name, 6, 0, 0)
                 the_new = Pick.insert(the_new, 1, -1, 0, Name)
                 If Attr = 36 Then
                    'RGM  ** ERROR **  Was not passing enough parameters!!!
                    Emsg = "Roll " & Pick.extract(rec, 7 + (I + 1) * 2, 2, 0) & " Qual " & Pick.extract(rec, 7 + (I + 2) * 2, 2, 0) & " Cncl " & Pick.extract(rec, 7 + (I + 3) * 2, 2, 0)
                    If Nomayvote = 0 Then
                        'RGM  ** ERROR **  Was not passing enough parameters!!!
                       Emsg = Emsg & " Mayl " & Pick.extract(rec, 7 + (I + 4) * 2, 2, 0)
                    End If
                    the_new = Pick.insert(the_new, 1, -1, 0, Emsg)
                 End If
              Next J
           End If
           If Attr = 17 Or Attr = 18 Then
              Max = Pick.dcount(the_old, Chr(253))
              Num_New = Pick.dcount(the_new, Chr(253))
              If Num_New > Max Then Max = Num_New
              For Ii = 1 To Max
                 If Pick.extract(the_old, 1, Ii, 0) = "" And Pick.extract(the_new, 1, Ii, 0) = "" Then GoTo 1615
                 If Pick.extract(the_old, 1, Ii, 0) <> "" Then the_old = Pick.replace(the_old, 1, Ii, 0, Pick.date_pick_to_vb(Pick.extract(the_old, 1, Ii, 0)))
                 If Pick.extract(the_new, 1, Ii, 0) <> "" Then the_new = Pick.replace(the_new, 1, Ii, 0, Pick.date_pick_to_vb(Pick.extract(the_new, 1, Ii, 0)))
1615          Next Ii
           End If
        End If
1620:
           Call Pick.sr_change(the_old, Chr(252), ",")
           Call Pick.sr_change(the_new, Chr(252), ",")
           GoSub 5000
           the_date = "": the_narr = ""
1690 Next I
     Exit Sub
'
5000:
        maxl = Pick.dcount(the_old, Chr(253))
        If Pick.dcount(the_new, Chr(253)) > maxl Then maxl = Pick.dcount(the_new, Chr(253))
        For Ii = maxl To 1 Step -1
           If Pick.extract(the_old, 1, Ii, 0) = "" And Pick.extract(the_new, 1, Ii, 0) = "" Then
              maxl = maxl - 1
              the_old = Pick.delet(the_old, 1, Ii, 0)
              the_new = Pick.delet(the_new, 1, Ii, 0)
          End If
        Next Ii
        If Pick.dcount(the_narr, Chr(253)) > maxl Then maxl = Pick.dcount(the_narr, Chr(253))
        If maxl < 1 Then maxl = 1
        nrec(1 + ownadj) = Pick.replace(nrec(1 + ownadj), 1, Lct, 0, the_date)
        nrec(2 + ownadj) = Pick.replace(nrec(2 + ownadj), 1, Lct, 0, the_narr)
        nrec(3 + ownadj) = Pick.replace(nrec(3 + ownadj), 1, Lct, 0, the_msg)
        nrec(4 + ownadj) = Pick.replace(nrec(4 + ownadj), 1, Lct, 0, the_old)
        nrec(5 + ownadj) = Pick.replace(nrec(5 + ownadj), 1, Lct, 0, the_new)
        Lct = Lct + maxl
        Return

End Sub

Public Sub SR1651(logentry As String, Sent As String, Set_No As Integer, arr_date As Integer, Date_To As Integer, BySel As Integer, Summa As Integer, ExcelPath As String, ExcelFileName As String, Howbig As Long, Use_rec() As String)
' TA1651 PRINT OUTSTANDING RATES REPORTS
Dim Prog, Am, Vm, Maxward, Wardsort, Wards As String, logarray() As String, dbase As String, Ch_Charge As String, Bydesc, Byattr As String, P_Flag
Dim Rates As String, Trans_Info As String, Ptline, Set_Desc As String, Msgf, Ty_Code As String, Ch_Cd_Pref As String, Rfcnt
Dim Maxrow, I As Integer, Max_Line, R_Desc As String, Cls$, Lns$, Ans
Dim Cde, Atrs As String, xx As Integer, Jj As Integer, Col_Head, Tots As String, senior, TTOTS() As String, Dt_Flg
Dim Rf_Flg, Cd_Flg As Integer, Tot_Head, REC_RATES() As String, D10, No_Of_Periods, Head2
Dim Head3, Head4, Head5, Head8, Head9, Head10, Line_Cnt, cnt, Page
Dim Area, Assess As String, L1, L2, L3, L4, Line_Test, Tdebtor_Rec As String, Client_Rec As String, Property_Rec As String
Dim Ward As String, Bal, Z As Integer, zz As Integer, Zzz As Integer, No_Oflow, J As Integer, td_rec As String, No_Trans, W_Indx As Integer
Dim CODE, Amt1, Sbl_Amt As String, Date_Re, Ref, Cr_Ref As String, No_Props, Categ
Dim Grv, Owners As String, Onames As String, Oaddr As String, Oaddr2 As String, Oaddr3 As String, Oo As Integer, Owner As String, clrec As String
Dim Name As String, Inz As Integer, Pcode, Pension, Upc As Integer, Addr, Addr2, Addr3, St, Gbal, Sbal
Dim Tfigs As String, k As Integer, kk As Integer, Rec_Recall, A_C, Rowct, Colct, Ref_Flg, Ixi As Integer, pt_line
Dim Sblxamt, Sbl As Integer, Iyi As Integer, Sbl_Unaloc, Hdr, Ward_Desc As String, Ii As Integer
Dim RR, Ss As Integer, mylist() As String, pick_cnt As Long, total_items As Long, Result, Pline As String, work
Dim fso, fileno As Integer, textfile, tempstr

      Prog = "TA1651"
      ReDim Use_rec(11)
      Am = Chr(254)
      Vm = Chr(253)
      Maxward = 0: Wardsort = 0: Wards = ""
      logarray = Split(logentry, Am)
      dbase = logarray(1)
      If d3.d3_readstr(dbase, Ch_Charge, "DICT TRANS.J", "@CHARGES") <> 0 Then Exit Sub
      If d3.d3_readstr(dbase, Rates, "DICT TRANS.J", "@RATES") <> 0 Then Exit Sub
      If d3.d3_readstr(dbase, Trans_Info, "DICT TRANS.J", "TRANS.INFO") <> 0 Then Exit Sub
      Bydesc = "Zoning" & Am & "Use" & Am & "Rating Flag {catg_ 1}" & Am & "Ward"
      Byattr = 8 & Am & 9 & Am & 19 & Am & 38
      P_Flag = Mid$(Pick.extract(Trans_Info, 53, 0, 0), 17, 1) + 0
      Ptline = ""
6
'
      If d3.d3_readstr(dbase, Set_Desc, "DICT PROPERTY", "@1651.SETTINGS") <> 0 Then Set_Desc = ""
      If d3.d3_readstr(dbase, Ty_Code, "DICT PROPERTY", "@1651.CODES" & Set_No) <> 0 Then Ty_Code = ""
      If d3.d3_readstr(dbase, Ch_Cd_Pref, "DICT PROPERTY", "@1651.CHARGE" & Set_No) <> 0 Then Ch_Cd_Pref = ""
      Rfcnt = Pick.ccount(Pick.extract(Ch_Cd_Pref, 1, 0, 0), Chr(253), 1) + 1
      Maxrow = Pick.extractint(Ch_Cd_Pref, 2, 1, 0)
      For I = 1 To Rfcnt
        If Maxrow < Pick.extract(Ch_Cd_Pref, 2, I, 0) Or Maxrow = Pick.extract(Ch_Cd_Pref, 2, I, 0) Then Maxrow = Pick.extract(Ch_Cd_Pref, 2, I, 0)
      Next I
      Max_Line = 49 / (16 + (2 * Maxrow))
      Max_Line = Int(Max_Line * 2) / 2
      Max_Line = Max_Line * (16 + 2 * Maxrow) - 3
      R_Desc = Pick.extract(Ch_Cd_Pref, 3, 0, 0) & Chr(253) & "MISCELLANEOUS"

'
' Open the Excel File
    Set fso = New Scripting.FileSystemObject
    fileno = 0
    ExcelFileName = ExcelPath & "\RatRec" & CStr(fileno) & ".xls"
    Do While fso.FileExists(ExcelFileName)
        fileno = fileno + 1
        ExcelFileName = ExcelPath & "\RatRec" & CStr(fileno) & ".xls"
    Loop
    Set textfile = fso.CreateTextFile(ExcelFileName, True)
    tempstr = Sent
    textfile.WriteLine (tempstr)
    tempstr = "Assess" & vbTab & "Arrears" & vbTab & "Levby/Inv" & vbTab & "Rebate" & vbTab & "Discount" & vbTab & "Journal" & vbTab & "Penalty" & vbTab & "Receipt" & vbTab & "Other" & vbTab & "Total"
    textfile.WriteLine (tempstr)
    ExcelFileName = "RatRec" & CStr(fileno) & ".xls"
    If Summa = 1 Then
        Howbig = 0
    Else
        Howbig = 1
    End If
    
'
     ReDim Cde(101)
     For I = 1 To 100
        Cde(I) = 7
     Next I
     Atrs = 25 & Vm & 50 & Am & 30 & Vm & 55 & Vm & 27 & Vm & 52 & Am & 28 & Vm & 53 & Am & 31 & Vm & 56 & Am & 33 & Am & 58 & Am & 37 & Vm & 62 & Am & 66 & Vm & 41 & Am & 48 & Vm & 73 & Am & 76 & Vm & 23 & Am & 22 & Vm & 77 & Am & 80 & Vm & 19
     For xx = 1 To 12
         For Jj = 1 To 6
             If Pick.extract(Atrs, xx, Jj, 0) <> "" Then
                 Cde(Pick.extract(Atrs, xx, Jj, 0)) = Pick.extract(Ty_Code, 2, xx, 0)
             End If
         Next Jj
     Next xx
     Col_Head = Right(Space(18) & "ARREARS", 18)
     For xx = 1 To 6
         Col_Head = Col_Head & Right(Space(14) & Pick.extract(Ty_Code, 3, xx, 0), 14)
     Next xx
     Col_Head = Col_Head & Right(Space(14) & "OTHER", 14) & Right(Space(14) & "TOTAL", 14)
'     IF TRIMM(PICK.EXTRACT(SET_DESC,2,SET_NO,0))<>"" THEN
'        OPEN "",PICK.EXTRACT(SET_DESC,2,SET_NO,0) TO RECALL_FILE ELSE STOP
'        PRINT @(0,23) & "Resetting Recall File please Wait !!"
'        CLEARFILE RECALL_FILE
'        PRINT @(0,23) & CL &
'     ENDIF
'
      total_items = d3.d3_select(logentry, Sent, mylist(), pick_cnt, 0, 0)
      Tots = "": senior = 0
      ReDim REC_RATES(11, 11)
      ReDim TTOTS(501)
      For I = 1 To 500
         TTOTS(I) = 0
      Next I
      Dt_Flg = 0
      Rf_Flg = 0
      Cd_Flg = 0
      Tot_Head = 0
      For I = 1 To 10
         For J = 1 To 10
            REC_RATES(I, J) = 0
         Next J
      Next I
      D10 = "----------  "
     No_Of_Periods = 2
'      Head2 = Space(21) & "D E B T O R S / V A L U A T I O N   R E G I S T E R" & "     AS AT " & TIMEICONV(Format$(Now, "DD MMM YY"), "D2") & "  PAGE "
'      If Date_To <> "" Then
'        Head3 = Space(39) & String$(10, "-") & " For transactions to " & Left(oconv(Date_To, "D2") & Space(10), 10) & String$(11, "-")
'      Else
'        Head3 = Space(39) & String$(52, "-")
'      End If
'      Head4 = " ASSESS NO         OWNER/S" & Space(18) & "PROPERTY ADDRESS" & Space(17) & "CURRENT VALUE  "
'      Head5 = Space(44) & Left("OWNERS MAILING ADDRESS" & Space(41), 41)
'      Head8 = Space(12) & "NO OF       NO OF        CURRENT"
'      Head9 = Left(pick.extract(Bydesc, BySel, 0, 0) & Space(12), 12) & "PENS_ PROPERTIES RATEABLE VALUE"
'     HEAD10 = SPACE(10):"----        -----     ":D10:SPACE(25):D10:D10:D10:D10:D10
'      Head10 = String$(130, "-")
      Line_Cnt = 70
      cnt = 0
      Page = 0
      Area = "?"
      For L1 = 1 To 20
          For L2 = 1 To No_Of_Periods
               For L3 = 1 To 3
                    For L4 = 1 To 8
'                         TTOTS(L1)<L2,L3,L4>=0
                          TTOTS(L1) = 0
                    Next L4
               Next L3
          Next L2
      Next L1
'
      Line_Test = 1
      If Summa = 2 Then Line_Test = 50

      For RR = 0 To total_items - 1
         Assess = mylist(RR)
         If d3.d3_readstr(dbase, Tdebtor_Rec, "TDEBTOR", Assess) <> 0 Then Tdebtor_Rec = ""
         If d3.d3_readstr(dbase, Client_Rec, "CLIENT", Assess) <> 0 Then Client_Rec = "?? DOES NOT EXIST"
         If d3.d3_readstr(dbase, Property_Rec, "PROPERTY", Assess) <> 0 Then Property_Rec = ""
'
         cnt = cnt + 1
         Ward = Pick.trimm(Pick.extract(Property_Rec, Pick.extractint(Byattr, BySel, 0, 0), 1, 0))
         If Ward = "" Then Ward = "XYZ?"
         If Wardsort = 0 Then Ward_Desc = ""
         If Ward <> Area And Wardsort Then
            Area = Ward
            If BySel = 4 Then
               If d3.d3_readstr(dbase, Ward_Desc, "AREA", Ward, 1) <> 0 Then Ward_Desc = ""
            End If
'            IF SUMMA = 0  OR SUMMA=2 THEN
'               GOSUB 2000                     ;* NEW PAGE
'            ELSE
'               PRINT @(16,25) & WARD_DESC "L#15" &
'            ENDIF
         End If
         Result = Pick.locate(Ward, Wards, 1, 1, 0, W_Indx, "")
         If Result = 0 Then
            Wards = Pick.insert(Wards, 1, -1, 0, Ward)
         End If
         If W_Indx > Maxward Then Maxward = W_Indx
'         BAL = pick.OCONV(TDEBTOR.REC<3>,"MD2")
         Bal = 0
         For Z = 1 To 3
            For zz = 1 To Maxrow + 1
              For Zzz = 1 To 8
'                 REC.RATES(Z,ZZ)<ZZZ>=pick.OCONV(0,'MD2')
                 REC_RATES(Z, zz) = Pick.replace(REC_RATES(Z, zz), Zzz, 0, 0, "0")
              Next Zzz
            Next zz
         Next Z
'
'   SUM IN CLEARED BALANCES.
'
         REC_RATES(1, 3) = Pick.replace(REC_RATES(1, 3), 7, 0, 0, Pick.extract(Tdebtor_Rec, 76, 0, 0))
         REC_RATES(1, 3) = Pick.replace(REC_RATES(1, 3), 8, 0, 0, Pick.extract(Tdebtor_Rec, 76, 0, 0))
'
' PROCESS OVERFLOWS FIRST
'
         No_Oflow = Pick.extractint(Tdebtor_Rec, 27, 0, 0)
         For J = 1 To No_Oflow
            If d3.d3_readstr(dbase, td_rec, "TD.OFLOW", J & "*" & Assess) <> 0 Then td_rec = ""
            No_Trans = Pick.extractint(td_rec, 1, 0, 0)
            For I = 1 To No_Trans
'              IF DATE.TO # '' AND TD.REC<5,I> > DATE.TO THEN GOTO 270
               CODE = Pick.extract(td_rec, 2, I, 0)
               Amt1 = Pick.extractcur(td_rec, 4, I, 0): Sbl_Amt = Pick.extract(td_rec, 10, I, 0)
               Date_Re = Pick.extract(td_rec, 5, I, 0)
               Ref = Pick.extract(td_rec, 3, I, 0): Cr_Ref = Pick.extract(td_rec, 9, I, 0)
               GoSub 1000
            Next I
         Next J
'
' NOW PROCESS MASTER RECORD
'
         No_Trans = Pick.extractcur(Tdebtor_Rec, 2, 0, 0)
         For I = 1 To No_Trans
'           IF DATE.TO # '' AND TDEBTOR.REC<14,I> > DATE.TO THEN GOTO 270
            CODE = Pick.extract(Tdebtor_Rec, 11, I, 0)
            Date_Re = Pick.extract(Tdebtor_Rec, 14, I, 0)
            Amt1 = Pick.extract(Tdebtor_Rec, 13, I, 0): Sbl_Amt = Pick.extract(Tdebtor_Rec, 30, I, 0)
            Ref = Pick.extract(Tdebtor_Rec, 12, I, 0): Cr_Ref = Pick.extract(Tdebtor_Rec, 26, I, 0)
            GoSub 1000
         Next I
'
270
         No_Props = Pick.ccount(Pick.extract(Property_Rec, 15, 0, 0), Chr(253), 1) + 1
         For I = 1 To No_Props
            Categ = Pick.extract(Property_Rec, 29, I, 0)
            If Categ = "" Or (IsNumeric(Categ) = False) Then Categ = I
'            IF CATEG = VAL.CATEG THEN GRV = PROPERTY.REC<15,I> ; GOTO 271
         Next I
         Grv = Pick.extractcur(Property_Rec, 15, 1, 0)
271
'         Grv = pick.oconv(Grv + 0, "MD")
         Tots = Pick.replace(Tots, W_Indx, 1, 0, CStr(Pick.extractcur(Tots, W_Indx, 1, 0) + 1))
         Tots = Pick.replace(Tots, W_Indx, 2, 0, CStr(Pick.extractcur(Tots, W_Indx, 2, 0) + Grv))
         For Z = 1 To No_Of_Periods
            For zz = 1 To Maxrow + 1
               For Zzz = 1 To 8
                  TTOTS(W_Indx) = Pick.replace(TTOTS(W_Indx), Z, zz, Zzz, CStr(Pick.extractcur(TTOTS(W_Indx), Z, zz, Zzz) + Pick.extractcur(REC_RATES(Z, zz), Zzz, 0, 0)))
               Next Zzz
            Next zz
         Next Z
'
         Owners = Pick.extract(Client_Rec, 35, 0, 0)
         Onames = "": Oaddr = "": Oaddr2 = "": Oaddr3 = ""
         For Oo = 1 To 999
            Owner = Pick.extract(Owners, 1, Oo, 0)
            If Owner = "" Then GoTo 300
            If d3.d3_readstr(dbase, clrec, "CLIENT", Owner) <> 0 Then clrec = ""
            Name = Pick.extract(clrec, 1, 0, 0) & " " & Pick.extract(clrec, 6, 0, 0)
            Onames = Pick.insert(Onames, 1, -1, 0, Pick.trimm(Name))
            If Oo = 1 Then
               If Pick.extract(clrec, 2, 1, 0) <> Pick.extract(Client_Rec, 2, 1, 0) Then
                  Inz = 1 ' IF CLREC<5,2><>"" THEN INZ=2 ELSE INZ=1
                  Oaddr = Pick.extract(clrec, 2, Inz, 0)
                  Oaddr2 = Pick.extract(clrec, 3, Inz, 0)
                  Oaddr3 = Pick.trimm(Pick.extract(clrec, 4, Inz, 0) & "" & Pick.extract(clrec, 5, Inz, 0))
               End If
            End If
         Next Oo
'300      CALL SR1692 (CLIENT_REC,CLIENT_DATA,PCODE,P_FLAG) '*DONOTALTER**
300      Pcode = Pick.extract(Client_Rec, 44, 0, 0)
         Pension = "": Upc = 0
         If Pcode <> "" And Pcode <> 0 Then
            Pension = "PENSION": Upc = 3
         Else
            If Pick.extract(Client_Rec, 16, 0, 0) <> "" Then Pension = "SENIOR": Upc = 4: senior = 1
         End If
         Addr = Pick.extract(Client_Rec, 2, 1, 0)
         Addr2 = Pick.extract(Client_Rec, 3, 1, 0)
         Addr3 = Pick.trimm(Pick.extract(Client_Rec, 4, 1, 0) & "" & Pick.extract(Client_Rec, 5, 1, 0))
         If Summa = 0 Then
'            Printer.Print
'            Printer.Print  Right(Space(9) & ASSESS,9); " "; Left(PICK.EXTRACT(ONAMES,1,1,0) & Space(30),30); " "; Left(ADDR & Space(30),30); "$"; Right(Space(9) & GRV,9); Right(Space(8) & PENSION,8)
             Pline = "": GoSub 5000
             Pline = Assess & Vm & Left(Pick.extract(Onames, 1, 1, 0) & Space(30), 30) & Vm & Left(Addr & Space(30), 30) & Vm & "$" & Right(Space(9) & Grv, 9) & Vm & Right(Space(8) & Pension, 8): GoSub 5000
         End If
         If Upc Then Tots = Pick.replace(Tots, W_Indx, Upc, 0, CStr(Pick.extractcur(Tots, W_Indx, Upc, 0) + 1))
         If Summa = 0 Then
'            Printer.Print  SPACE(12); Left(PICK.EXTRACT(ONAMES,1,2,0) & Space(30),30); " "; ADDR2
'            Printer.Print  SPACE(12); Left(PICK.EXTRACT(ONAMES,1,3,0) & Space(30),30); " "; ADDR3
             Pline = Vm & Left(Pick.extract(Onames, 1, 2, 0) & Space(30), 30) & Vm & Addr2: GoSub 5000
             Pline = Vm & Left(Pick.extract(Onames, 1, 3, 0) & Space(30), 30) & Vm & Addr3
         End If
         If Oaddr <> "" Then
            If Summa = 0 Then
'               Printer.Print  SPACE(12); Left(PICK.EXTRACT(ONAMES,1,4,0) & Space(30),30); " "; OADDR
'               Printer.Print  SPACE(12); Left(PICK.EXTRACT(ONAMES,1,5,0) & Space(30),30); " "; OADDR2
'               Printer.Print  SPACE(12); Left(PICK.EXTRACT(ONAMES,1,6,0) & Space(30),30); " "; OADDR3
                Pline = Vm & Left(Pick.extract(Onames, 1, 4, 0) & Space(30), 30) & Vm & Oaddr: GoSub 5000
                Pline = Vm & Left(Pick.extract(Onames, 1, 5, 0) & Space(30), 30) & Vm & Oaddr2: GoSub 5000
                Pline = Vm & Left(Pick.extract(Onames, 1, 6, 0) & Space(30), 30) & Vm & Oaddr3: GoSub 5000
            End If
            St = 7
         Else
            St = 4
         End If
         If Summa = 0 Then
            Pline = ""
            GoSub 5000
            Pline = Col_Head: GoSub 5000
         End If
         Gbal = 0
         I = 2
         Sbal = 0
         Tfigs = ""
         For J = 1 To Maxrow + 1
            If Summa = 0 Then Ptline = CStr(Pick.extractcur(REC_RATES(1, J), 8, 0, 0))
            Tfigs = Pick.replace(Tfigs, 1, 0, 0, CStr(Pick.extractcur(Tfigs, 1, 0, 0) + Pick.extractcur(REC_RATES(1, J), 8, 0, 0)))
            For k = 1 To 8
               If Pick.extract(REC_RATES(I, J), k, 0, 0) = "" Then REC_RATES(I, J) = Pick.replace(REC_RATES(I, J), k, 0, 0, "0")
               If Summa <> 1 Then
                  If k = 8 Then
'                     PTLINE= PTLINE & Right(Space(14) & OCONV(REC_RATES(I,PICK.EXTRACT(J),K)+REC_RATES(1,PICK.EXTRACT(J),8),"MD2"),14)
                     Ptline = Ptline & Vm & CStr(Pick.extractcur(REC_RATES(I, J), k, 0, 0) + Pick.extractcur(REC_RATES(1, J), 8, 0, 0))
                     If I = 2 Then
                        REC_RATES(2, J) = Pick.replace(REC_RATES(2, J), 8, 0, 0, CStr(Pick.extractcur(REC_RATES(2, J), 8, 0, 0) + Pick.extractcur(REC_RATES(1, J), 8, 0, 0)))
                     End If
                  Else
'                     PTLINE= PTLINE & Right(Space(14) & OCONV(REC_RATES(I,PICK.EXTRACT(J),K),"MD2"),14)
                     Ptline = Ptline & Vm & CStr(Pick.extract(REC_RATES(I, J), k, 0, 0))
                  End If
               End If
               Tfigs = Pick.replace(Tfigs, k + 1, 0, 0, CStr(Pick.extractcur(Tfigs, k + 1, 0, 0) + Pick.extractcur(REC_RATES(I, J), k, 0, 0)))
            Next k
'            IF SUMMA = 0 THEN Printer.Print  Left(PICK.EXTRACT(R_DESC,1,J,0) & Space(8),8); PTLINE
            If Summa = 0 Then Pline = Left(Pick.extract(R_Desc, 1, J, 0) & Space(8), 8) & Vm & Ptline: GoSub 5000
            Ptline = ""
            Sbal = Sbal + Pick.extractcur(REC_RATES(I, J), 8, 0, 0)
         Next J
         Gbal = Gbal + Sbal
'         IF NOT(SUMMA) THEN PRINT SPACE(112):'TOTAL ':OCONV(SBAL,'MD2')'R#12'
         If Summa = 0 Or Summa = 2 Then
            If Summa = 0 Then pt_line = "TOTAL" Else pt_line = Assess
'            PTLINE = PT_LINE & Right(Space(10) & OCONV(PICK.EXTRACT(TFIGS,1,0,0),"MD2"),10)
            Ptline = pt_line & Vm & CStr(Pick.extractcur(Tfigs, 1, 0, 0))
            For xx = 2 To 9
'               PTLINE = PTLINE & Right(Space(14) & OCONV(PICK.EXTRACT(TFIGS,XX,0,0),"MD2"),14)
               Ptline = Ptline & Vm & CStr(Pick.extractcur(Tfigs, xx, 0, 0))
            Next xx
'           Printer.Print PTLINE
            Pline = Ptline
            GoSub 5000
'            IF SUMMA = 0  THEN Printer.Print  String$(130,"=")
         End If
'         IF SUMMA = 0  THEN Printer.Print
         For kk = St To 999
            If Pick.extract(Onames, 1, kk, 0) = "" Then GoTo 600
'            IF SUMMA = 0  THEN Printer.Print  SPACE(12); PICK.EXTRACT(ONAMES,1,KK,0)
         Next kk
600      If Pick.trimm(Pick.extract(Set_Desc, 2, Set_No, 0)) <> "" Then
'
'            Rec_Recall = ""
'            For A_C = 1 To 2
'               For Rowct = 1 To 9
'                  For Colct = 1 To 8
'                     REC_RECALL=PICK.INSERT(REC_RECALL,(A_C-1,0,0)*10+ROWCT,COLCT,REC_RATES(A_C,PICK.EXTRACT(ROWCT),COLCT))
'                  Next Colct
'               Next Rowct
'            Next A_C
'            CALL PICKWT (RECALL_FILE,ASSESS,3,REC_RECALL,0)
         End If
      Next RR
      GoSub 4000
      textfile.Close
      Exit Sub
      
'
'
1000  If Date_To <> 0 And Date_Re > Date_To Then
         Dt_Flg = 3
      Else
         If Date_Re >= arr_date Then
            Dt_Flg = 2
         Else
            Dt_Flg = 1
         End If
      End If
      Cd_Flg = Cde(CODE)
' IF RATES,RUBBISH,OR MISC. = RF.FLG
'
    Ref_Flg = ""
   If CODE > 49 Or CODE = 25 Or CODE = 48 Or CODE = 22 Or CODE = 19 Then
    For Ixi = 1 To Rfcnt
        If Mid$(Ref, 1, Len(Pick.extract(Ch_Cd_Pref, 1, Ixi, 0))) = Pick.extract(Ch_Cd_Pref, 1, Ixi, 0) Then
            Rf_Flg = Pick.extract(Ch_Cd_Pref, 2, Ixi, 0)
            GoTo 1001
        End If
    Next Ixi
    Rf_Flg = Maxrow + 1
1001 GoSub 1010
    Return
   Else
    If Ref_Flg = "" Then
        If Cr_Ref = "" Then
            Rf_Flg = Maxrow + 1
            GoSub 1010
            Return
        Else
            Sblxamt = Amt1
            For Sbl = 1 To 999
                If Pick.extract(Cr_Ref, 1, 1, Sbl) = "" Then GoTo 1004
                For Iyi = 1 To Rfcnt
                    If Mid$(Pick.extract(Cr_Ref, 1, 1, Sbl), 1, Len(Pick.extract(Ch_Cd_Pref, 1, Iyi, 0))) = Pick.extract(Ch_Cd_Pref, 1, Iyi, 0) Then
                         Rf_Flg = Pick.extract(Ch_Cd_Pref, 2, Iyi, 0)
                         GoTo 1002
                    End If
                Next Iyi
                Rf_Flg = Maxrow + 1
1002
                REC_RATES(Dt_Flg, Rf_Flg) = Pick.replace(REC_RATES(Dt_Flg, Rf_Flg), Cd_Flg, 0, 0, CStr(Pick.extractcur(REC_RATES(Dt_Flg, Rf_Flg), Cd_Flg, 0, 0) - Pick.extractcur(Sbl_Amt, 1, 1, Sbl)))
                REC_RATES(Dt_Flg, Rf_Flg) = Pick.replace(REC_RATES(Dt_Flg, Rf_Flg), 8, 0, 0, CStr(Pick.extractcur(REC_RATES(Dt_Flg, Rf_Flg), 8, 0, 0) - Pick.extractcur(Sbl_Amt, 1, 1, Sbl)))
                Sblxamt = Sblxamt + Pick.extractcur(Sbl_Amt, 1, 1, Sbl)
            Next Sbl
1004          If Amt1 - Sblxamt <> "0" Then
                 Sbl_Unaloc = Amt1 + Sblxamt
                 Rf_Flg = Maxrow + 1
'                 IF SBL_UNALOC > 0 THEN Printer.Print  "ERROR- UNALLOCATED CREDITS ON ASSESS "; ASSESS
                 If Sbl_Unaloc > 0 Then Pline = "ERROR- UNALLOCATED CREDITS ON ASSESS " & pt_line & Assess: GoSub 5000
                 REC_RATES(Dt_Flg, Rf_Flg) = Pick.replace(REC_RATES(Dt_Flg, Rf_Flg), Cd_Flg, 0, 0, CStr(Pick.extractcur(REC_RATES(Dt_Flg, Rf_Flg), Cd_Flg, 0, 0) + Sblxamt))
                 REC_RATES(Dt_Flg, Rf_Flg) = Pick.replace(REC_RATES(Dt_Flg, Rf_Flg), 8, 0, 0, CStr(Pick.extractcur(REC_RATES(Dt_Flg, Rf_Flg), 8, 0, 0) + Sblxamt))
              End If
        End If
    End If
   End If
Return
'
'
1010
        REC_RATES(Dt_Flg, Rf_Flg) = Pick.replace(REC_RATES(Dt_Flg, Rf_Flg), Cd_Flg, 0, 0, CStr(Amt1 + Pick.extractcur(REC_RATES(Dt_Flg, Rf_Flg), Cd_Flg, 0, 0)))
        REC_RATES(Dt_Flg, Rf_Flg) = Pick.replace(REC_RATES(Dt_Flg, Rf_Flg), 8, 0, 0, CStr(Amt1 + Pick.extractcur(REC_RATES(Dt_Flg, Rf_Flg), 8, 0, 0)))
      Return
'
'
'
' FINAL TOTALS
'
4000  Page = Page + 1
      For I = 1 To Maxward
         For J = 1 To 4
            Tots = Pick.replace(Tots, Maxward + 1, J, 0, CStr(Pick.extractcur(Tots, Maxward + 1, J, 0) + Pick.extractcur(Tots, I, J, 0)))
         Next J
      Next I
      For I = 1 To Maxward
         For Z = 1 To 3
           For zz = 1 To Maxrow + 1
             For Zzz = 1 To 8
                TTOTS(Maxward + 1) = Pick.replace(TTOTS(Maxward + 1), Z, zz, Zzz, Pick.extractcur(TTOTS(Maxward + 1), Z, zz, Zzz) + Pick.extractcur(TTOTS(I), Z, zz, Zzz))
             Next Zzz
           Next zz
         Next Z
      Next I
      Tot_Head = 1
'
'      IF SUMMA AND SUMMA<>2 THEN
'         Printer ON
'      ENDIF
'      Printer.Print  ERASE: Printer.Print : Printer.Print  SPACE(18); HEAD2; PAGE
'      Printer.Print  HEAD3
'      Printer.Print
'     Printer.Print  SPACE(60); "SUMMARY"
'      Printer.Print :Printer.Print
      For I = 1 To Maxward + 1
'         Printer.Print
        Pline = "": GoSub 5000
        Ptline = ""
         If I = Maxward + 1 Then
'           Printer.Print  HEAD10:  Printer.Print
           Ward_Desc = "TOTALS"
         Else
          If BySel = 4 Then
           If d3.d3_readstr(dbase, Ward_Desc, "AREA", Pick.extract(Wards, 1, I, 0)) <> 0 Then Ward_Desc = Pick.extract(Wards, 1, I, 0)
          Else
           Ward_Desc = Pick.extract(Wards, 1, I, 0)
          End If
         End If
         If senior = 0 Then
'            Printer.Print  HEAD8:Printer.Print  HEAD9:Printer.Print
         Else
'            Printer.Print  HEAD8; " NO OF"
'            Printer.Print  HEAD9; " SENIORS"
'            Printer.Print
         End If
'         Printer.Print  Left(WARD_DESC & Space(10),10); Right(Space(4) & PICK.EXTRACT(TOTS,I,3,0),4); Right(Space(13) & PICK.EXTRACT(TOTS,I,1,0),13); Right(Space(13) & PICK.EXTRACT(TOTS,I,2,0),13);
         Pline = Left(Ward_Desc & Space(10), 10) & Vm & Right(Space(4) & Pick.extract(Tots, I, 3, 0), 4) & Vm & Right(Space(13) & Pick.extract(Tots, I, 1, 0), 13) & Vm & Right(Space(13) & Pick.extract(Tots, I, 2, 0), 13)
         If senior Then Pline = Pline & Vm & Right(Space(11) & Pick.extract(Tots, I, 4, 0), 11)
         GoSub 5000
'         Printer.Print
'         Printer.Print  COL_HEAD
         Gbal = 0
       Ii = 2
       Tfigs = ""
            Sbal = 0
            For J = 1 To Maxrow + 1
              TTOTS(I) = Pick.replace(TTOTS(I), Ii, J, 8, Pick.extractcur(TTOTS(I), 1, J, 8) + Pick.extractcur(TTOTS(I), Ii, J, 8))
              Tfigs = Pick.replace(Tfigs, 1, 0, 0, CStr(Pick.extractcur(Tfigs, 1, 0, 0) + Pick.extractcur(TTOTS(I), 1, J, 8)))
               For k = 1 To 8
                  If Pick.extract(TTOTS(I), Ii, J, k) = "" Then TTOTS(I) = Pick.replace(TTOTS(I), Ii, J, k, 0)
'                  PTLINE= PTLINE & Right(Space(14) & OCONV(TTOTS(PICK.EXTRACT(I),II,J,K),"MD2"),14)
                  Ptline = Ptline & CStr(Pick.extract(TTOTS(I), Ii, J, k)) & Vm
                  Tfigs = Pick.replace(Tfigs, k + 1, 0, 0, CStr(Pick.extractcur(Tfigs, k + 1, 0, 0) + Pick.extractcur(TTOTS(I), Ii, J, k)))
               Next k
                Pline = Left(Pick.extract(R_Desc, 1, J, 0) & Space(8), 8) & Vm & CStr(Pick.extractcur(TTOTS(I), 1, J, 8)) & Vm & Ptline
                GoSub 5000
                Ptline = ""
               Sbal = Sbal + Pick.extractcur(TTOTS(I), Ii, J, 8)
            Next J
            Gbal = Gbal + Sbal
'            Printer.Print  String$(130,"=")
            Ptline = "TOTAL" & Vm & CStr(Pick.extractcur(Tfigs, 1, 0, 0))
            For xx = 2 To 9
                Ptline = Ptline & Vm & CStr(Pick.extractcur(Tfigs, xx, 0, 0))
            Next xx
'            Printer.Print  PTLINE
            Pline = Ptline: GoSub 5000
'         IF MOD(I,2)="0" THEN GOSUB 2000
       Next I
'      Printer.Print :Printer.Print  HEAD10
      Return
5000:
    If Summa = 1 Then
        For Ss = 1 To 10
            work = Pick.extract(Pline, 1, Ss, 0)
            If work = "" Then work = "&nbsp;"
            If Use_rec(Ss) = "" Then
                Use_rec(Ss) = work
            Else
                Use_rec(Ss) = Use_rec(Ss) & Vm & work
            End If
        Next Ss
    End If
    tempstr = replace(Pline, Vm, vbTab)
    textfile.WriteLine (tempstr)
    Return
End Sub

Public Sub SR1607(database As String, nrec() As String)

' DISPLAY PROPERTY HISTORY

Dim maxl As Integer, Prec As String, Crec As String, ownadj As Integer
Dim Startdate As String, Startnum As Integer, Prophdg As String
Dim Arec As String, Maxa As Integer, cnt As Integer, ptl As String
Dim Lct As Integer, rderr As Integer, Qld_Fmt As String
Dim C(999) As String, Hdesc As String, prop As String
Dim temp As String, Pnum As Integer, P_Maxsvm As Integer
Dim Attr As Integer, Name As String, Max As Integer, Num_New As Integer
Dim Cnum As Integer, Cct As Integer, Readp As Integer, Readc As Integer, Pct As Integer
Dim rec As String, Client_No As String, the_date As String, the_narr As String
Dim tst As Integer, the_old As String, the_new As String, tempcur As Currency, tempcur2 As Currency
Dim the_msg As String, I As Integer, J As Integer, Ii As Integer
Dim This_Cat As Integer, This_Attr As Integer, This_Code As String, This_Desc As String, This_Fld As String
Dim the_new_incr As String, Old_Incr As String, Sold As String, sthe_new As String
Dim Oldj As String, Emsg As String, Nomayvote As Integer, the_newj As String
Dim Pclrec As String, client_ids As String, posn As Integer, Pos As Integer

     ReDim Preserve nrec(10): Lct = 1: Startnum = 0
     
     If UBound(g_rates) = 0 Then
        g_rates(0) = "@RATES"
        I = d3.d3_readmat(database, g_rates(), "DICT TRANS.J")
     End If

     'which = pick.extract(WHICH_FLAGS, 1, 1, 0)
     'WANTDISP = pick.extract(WHICH_FLAGS, 1, 2, 0)
     'OPER = pick.extract(WHICH_FLAGS, 1, 3, 0)
     
'     If pick.extract(startnum, 1, 2, 0) = "D" Then
'        startdate = pick.extract(startnum, 1, 1, 0)
'        startnum = ""
'     Else
'        startdate = ""
'     End If
'     qld_fmt = Mid$(g_trans_info_array(53), 4, 1)
'     XLINES = ""
'     NOMAYVOTE = Mid$(pick.extract(TRANS_INFO, 53, 0, 0), 1, 1) + 0
     rderr = d3.d3_readstr(database, prop, "PROPERTY", nrec(0))
     rderr = d3.d3_readstr(database, Pclrec, "CLIENT", nrec(0))
     client_ids = ""
     For I = 35 To 37       ' include owner,occupier,elector
          For Ii = 1 To 999
               Client_No = Pick.extract(Pclrec, I, Ii, 0)
               If Client_No = "" Then Exit For
               posn = Pick.locate(Client_No, client_ids, 1, 1, 0, Pos, "")
               If posn = 0 Then
                  client_ids = Pick.insert(client_ids, 1, -1, 0, Client_No)
               End If
        Next Ii
     Next I
     rderr = d3.d3_readstr(database, Prophdg, "DICT TRANS.J", "@PROPERTY")

     If Prophdg = "" Then
        Prophdg = Pick.replace(Prophdg, 1, 1, 0, "Lot"): Prophdg = Pick.replace(Prophdg, 2, 1, 0, "Location")
        Prophdg = Pick.replace(Prophdg, 5, 1, 0, "Frontage"): Prophdg = Pick.replace(Prophdg, 6, 1, 0, "Depth"): Prophdg = Pick.replace(Prophdg, 7, 1, 0, "Area"): Prophdg = Pick.replace(Prophdg, 8, 1, 0, "Zoning")
        Prophdg = Pick.replace(Prophdg, 9, 1, 0, "Pres Use"): Prophdg = Pick.replace(Prophdg, 10, 1, 0, "Bldg Type"): Prophdg = Pick.replace(Prophdg, 12, 1, 0, "Pool")
        Prophdg = Pick.replace(Prophdg, 14, 1, 0, "Min Rate"): Prophdg = Pick.replace(Prophdg, 15, 1, 0, "Curr Value")
        Prophdg = Pick.replace(Prophdg, 18, 1, 0, "S/Unit"): Prophdg = Pick.replace(Prophdg, 19, 1, 0, "Rate Flag")
        Prophdg = Pick.replace(Prophdg, 21, 1, 0, "Rubbish"): Prophdg = Pick.replace(Prophdg, 22, 1, 0, "Strat Plan")
        Prophdg = Pick.replace(Prophdg, 26, 1, 0, "Fut Value"): Prophdg = Pick.replace(Prophdg, 27, 1, 0, "Prev Zone")
        Prophdg = Pick.replace(Prophdg, 29, 1, 0, "Val Categ"): Prophdg = Pick.replace(Prophdg, 30, 1, 0, "Unit Categ")
        Prophdg = Pick.replace(Prophdg, 34, 1, 0, "Reval Date"): Prophdg = Pick.replace(Prophdg, 35, 1, 0, "Reval Eff")
        Prophdg = Pick.replace(Prophdg, 38, 1, 0, "Ward")
     End If

     If d3.d3_readstr(database, Arec, "SCROLL.KEYS", "@A|PROPERTY") <> 0 Then Arec = ""
     Maxa = Pick.dcount(Arec, Chr(254))
     For I = 1 To Maxa
        If Pick.extract(Prophdg, I, 1, 0) = "" Then Prophdg = Pick.replace(Prophdg, I, 1, 0, Pick.extract(Arec, I, 1, 0))
     Next I

     C(1) = "Name": C(2) = "Address-1": C(3) = "Address-2": C(4) = "Address-3"
     C(5) = "Postcode": C(32) = "Votes Cncl": C(33) = "Votes Mayl"
     C(16) = "Senior No": C(17) = "Pen Start": C(18) = "Pen ENDIF": C(19) = "Defer"
     C(14) = "Pens type"
     C(34) = "Qual": C(35) = "Owners": C(36) = "Electors": C(37) = "Occupiers"
     C(38) = "Roll": C(43) = "Pens no": C(44) = "Rebate"
     ownadj = 0
'
100: If ownadj = 0 Then
          Client_No = nrec(0)
       Else
          Client_No = Pick.extract(client_ids, 1, cnt, 0)
          If Client_No = "" Then
             For I = 1 To Lct - 1
                  If Pick.extract(nrec(6), 1, I, 0) = "" Then nrec(6) = Pick.replace(nrec(6), 1, I, 0, " ")
             Next I
             Exit Sub
          End If
       End If
'     If qld_fmt = "1" Then
'        XLINES= "Vg no &  " & pick.extract(PROP,46,0,0) & "     Area &  " & pick.extract(PROP,7,0,0) & "   M"gee &  " & PROP<49>
'        narr = pick.extract(PROP, 28, 1, 0) & " " & pick.extract(PROP, 28, 2, 0) & " " & pick.extract(PROP, 28, 3, 0) & " " & pick.extract(PROP, 28, 4, 0)
'        MVNARR = ""
'        Call SR525(narr, (LLEN - 20), MVNARR) '*DONOTALTER**
'        i = 0
'        Loop
'           i = i + 1
'        UNTIL MVNARR=pick.REPLACE(MVNARR,1,I,0,"" DO)
'           If i = 1 Then
'              XLINES = XLINES & Chr(252) & "Description &  " & pick.extract(MVNARR, 1, i, 0)
'           Else
'              XLINES = XLINES & Chr(252) & Space(5) & pick.extract(MVNARR, 1, i, 0)
'           End If
'        REPEAT
'     End If
'
     'If startnum > 1 Then GoTo 950
   If ownadj = 0 Then
     If Pick.extract(prop, 42, 0, 0) <> "" Or Pick.extract(prop, 43, 0, 0) <> "" Or Pick.extract(prop, 44, 0, 0) <> "" Or Pick.extract(prop, 45, 0, 0) <> "" Then
        the_date = Pick.date_pick_to_vb(Pick.extract(prop, 42, 0, 0))
        the_msg = "Added"
        the_narr = Pick.extract(prop, 43, 0, 0)
        If Pick.extract(prop, 44, 0, 0) <> "" Then the_narr = the_narr & Chr(253) & Pick.extract(prop, 44, 0, 0)
        If Pick.extract(prop, 45, 0, 0) <> "" Then the_narr = the_narr & Chr(253) & Pick.extract(prop, 45, 0, 0)
        GoSub 5000
    End If
  Else
     rderr = d3.d3_readstr(database, Pclrec, "CLIENT", Client_No)
     the_narr = Client_No & "-" & Pick.trimm(Pick.extract(Pclrec, 8, 0, 0) & " " & Pick.extract(Pclrec, 7, 0, 0) & " " & Pick.extract(Pclrec, 1, 0, 0))
     GoSub 5000
  End If
'
950  If d3.d3_readstr(database, rec, "CHANGES", "P" & "|" & Client_No) <> 0 Then rec = ""
     temp = Pick.extract(rec, 2, 0, 0)
     If IsNumeric(temp) Then Pnum = CInt(temp) Else Pnum = 0
     Pct = 0
     If d3.d3_readstr(database, rec, "CHANGES", "C" & "|" & Client_No) <> 0 Then rec = ""
     temp = Pick.extract(rec, 2, 0, 0)
     If IsNumeric(temp) Then Cnum = CInt(temp) Else Cnum = 0
     Cct = 0
     Readp = 1: Readc = 1
'     If which = "P" Then readc = 0: crec = "99999": pct = startnum - 1
'     If which = "C" Then readp = 0: prec = "99999": cct = startnum - 1
'
1000 If Readp = 1 Then
1005    Pct = Pct + 1
        If Pct <= Pnum Then
           If d3.d3_readstr(database, Prec, "CHANGES", "P" & "|" & Client_No & "|" & Pct) <> 0 Then GoTo 1005
           'If startdate <> "" Then
           '   If pick.extract(prec, 1, 0, 0) < startdate Then GoTo 1000
           'End If
        Else
           Prec = "99999"
        End If
        Readp = 0
     End If
     If Readc Then
1010    Cct = Cct + 1
        If Cct <= Cnum Then
           If d3.d3_readstr(database, Crec, "CHANGES", "C" & "|" & Client_No & "|" & Cct) <> 0 Then GoTo 1010
           'If startdate <> "" Then
           '   If pick.extract(crec, 1, 0, 0) < startdate Then GoTo 1000
           'End If
        Else
           Crec = "99999"
        End If
        Readc = 0
     End If
     temp = Pick.extract(Prec, 1, 0, 0)
     If IsNumeric(temp) Then tempcur = CCur(temp) Else tempcur = 0
     temp = Pick.extract(Crec, 1, 0, 0)
     If IsNumeric(temp) Then tempcur2 = CCur(temp) Else tempcur2 = 0
     If tempcur = tempcur2 Then tst = 2 Else tst = 1
     temp = Pick.extract(Prec, tst, 0, 0)
     If IsNumeric(temp) Then tempcur = CCur(temp) Else tempcur = 0
     temp = Pick.extract(Crec, tst, 0, 0)
     If IsNumeric(temp) Then tempcur2 = CCur(temp) Else tempcur2 = 0
     If tempcur <= tempcur2 Then Readp = 1: rec = Prec Else Readc = 1: rec = Crec
     If rec = "99999" Then
        If ownadj = 0 Then
           For I = 1 To Lct - 1
              If Pick.extract(nrec(1), 1, I, 0) = "" Then nrec(1) = Pick.replace(nrec(1), 1, I, 0, " ")
           Next I
           ownadj = 5: cnt = 1: Lct = 1
        Else
           cnt = cnt + 1
        End If
        the_old = "": the_new = "": the_msg = "": the_date = "": the_narr = ""
        GoTo 100
     End If

     the_date = Pick.date_pick_to_vb(Pick.extract(rec, 1, 0, 0))
     the_narr = Pick.extract(rec, 6, 0, 0)
     Call Pick.sr_change(the_narr, Chr(253), "<BR>")
     For I = 1 To 999
        temp = Pick.extract(rec, 7, I, 0)
        If IsNumeric(temp) Then
           Attr = CInt(temp)
        Else
           If the_narr <> "" Or the_date <> "" Then GoSub 5000
           GoTo 1000
        End If
        the_old = Pick.extract(rec, 6 + 2 * I, 0, 0): the_old = Pick.delet(the_old, 1, 1, 0)
        the_new = Pick.extract(rec, 7 + 2 * I, 0, 0): the_new = Pick.delet(the_new, 1, 1, 0)
        If Readp Then
           the_msg = Pick.extract(Prophdg, Attr, 1, 0)
           Select Case Attr
            Case 34, 35
              If the_old <> "" Then the_old = Pick.date_pick_to_vb(the_old)
              If the_new <> "" Then the_new = Pick.date_pick_to_vb(the_new)
            Case 29
              For J = 1 To 9999
                If Pick.extract(the_old, 1, J, 0) = "" And Pick.extract(the_new, 1, J, 0) = "" Then GoTo 1300
                If Pick.extract(the_old, 1, J, 1) <> "" Or Pick.extract(the_old, 1, J, 2) <> "" Then
                  temp = Pick.extract(the_old, 1, J, 1)
                  If IsNumeric(temp) Then This_Cat = CInt(temp) Else This_Cat = 0
                  This_Attr = (This_Cat * 10) - 1
                  This_Code = Pick.extract(g_rates(This_Attr), 1, 2, 0)
                  This_Desc = Pick.extract(g_rates(This_Attr), 1, 1, 0)
                  This_Fld = This_Code & " " & Pick.extract(the_old, 1, J, 1) & "/" & Pick.extract(the_old, 1, J, 2) & " " & This_Desc
                  the_old = Pick.replace(the_old, 1, J, 0, This_Fld)
                Else
                  the_old = Pick.replace(the_old, 1, J, 0, "")
                End If
                
                If Pick.extract(the_new, 1, J, 1) <> "" Or Pick.extract(the_new, 1, J, 2) <> "" Then
                  temp = Pick.extract(the_new, 1, J, 1)
                  If IsNumeric(temp) Then This_Cat = CInt(temp) Else This_Cat = 0
                  This_Attr = (This_Cat * 10) - 1
                  This_Code = Pick.extract(g_rates(This_Attr), 1, 2, 0)
                  This_Desc = Pick.extract(g_rates(This_Attr), 1, 1, 0)
                  This_Fld = This_Code & " " & Pick.extract(the_new, 1, J, 1) & "/" & Pick.extract(the_new, 1, J, 2) & " " & This_Desc
                  the_new = Pick.replace(the_new, 1, J, 0, This_Fld)
                Else
                  the_new = Pick.replace(the_new, 1, J, 0, "")
                End If
             Next J
           Case 30
             If the_new <> "" Then
                the_new_incr = Pick.extract(the_new, 1, 1, 5)
                the_new = Pick.extract(the_new, 1, 1, 1) & "," & Pick.extract(the_new, 1, 1, 2) & " to " & Pick.extract(the_new, 1, 1, 3) & " in yr" & Pick.extract(the_new, 1, 1, 4) + 0 & " "
                If the_new_incr <> "" Then the_new = the_new & "int " & the_new_incr
             End If
             If the_old <> "" Then
                Old_Incr = Pick.extract(the_old, 1, 1, 5)
                the_old = Pick.extract(the_old, 1, 1, 1) & "," & Pick.extract(the_old, 1, 1, 2) & " to " & Pick.extract(the_old, 1, 1, 3) & " in yr" & Pick.extract(the_old, 1, 1, 4) + 0 & " "
                If Old_Incr <> "" Then the_old = the_old & "int " & Old_Incr
             End If
1300    End Select
        Else
           the_msg = C(Attr)
           If Attr = 32 Or Attr = 33 Or Attr = 34 Or Attr = 38 Then GoTo 1690
' these will be done by finding 36 first - electoral information
           If Attr = 35 Or Attr = 36 Or Attr = 37 Then
              Sold = the_old: sthe_new = the_new
              the_old = "": the_new = ""
              For J = 1 To 999
                 Oldj = Pick.extract(Sold, 1, J, 0)
                 If Oldj = "" Then GoTo 1610
                 If d3.d3_readstr(database, Name, "CLIENT", Oldj) <> 0 Then Name = ""
                 Name = Pick.extract(Name, 1, 0, 0) & " " & Pick.extract(Name, 6, 0, 0)
                 the_old = Pick.insert(the_old, 1, -1, 0, Name)
                 If Attr = 36 Then
                    'RGM  ** ERROR **  Not passing enough parameters!!!
                    'emsg = "Roll " & pick.extract(rec, 6 + (I + 1) * 2, 2) & " Qual " & pick.extract(rec, 6 + (I + 2) * 2, 2) & " Cncl " & pick.extract(rec, 6 + (I + 3) * 2, 2)
                    Emsg = "Roll " & Pick.extract(rec, 6 + (I + 1) * 2, 2, 0) & " Qual " & Pick.extract(rec, 6 + (I + 2) * 2, 2, 0) & " Cncl " & Pick.extract(rec, 6 + (I + 3) * 2, 2, 0)
                    If Nomayvote = 0 Then
                       'RGM  ** ERROR **  Was not passing enough parameters!!!
                       Emsg = Emsg & " Mayl " & Pick.extract(rec, 6 + (I + 4) * 2, 2, 0)
                    End If
                    the_old = Pick.insert(the_old, 1, -1, 0, Emsg)
                 End If
              Next J
1610          For J = 1 To 999
                 the_newj = Pick.extract(sthe_new, 1, J, 0)
                 If the_newj = "" Then GoTo 1620
                 If d3.d3_readstr(database, Name, "CLIENT", the_newj) <> 0 Then Name = ""
                 Name = Pick.extract(Name, 1, 0, 0) & " " & Pick.extract(Name, 6, 0, 0)
                 the_new = Pick.insert(the_new, 1, -1, 0, Name)
                 If Attr = 36 Then
                    'RGM  ** ERROR **  Was not passing enough parameters!!!
                    Emsg = "Roll " & Pick.extract(rec, 7 + (I + 1) * 2, 2, 0) & " Qual " & Pick.extract(rec, 7 + (I + 2) * 2, 2, 0) & " Cncl " & Pick.extract(rec, 7 + (I + 3) * 2, 2, 0)
                    If Nomayvote = 0 Then
                        'RGM  ** ERROR **  Was not passing enough parameters!!!
                       Emsg = Emsg & " Mayl " & Pick.extract(rec, 7 + (I + 4) * 2, 2, 0)
                    End If
                    the_new = Pick.insert(the_new, 1, -1, 0, Emsg)
                 End If
              Next J
           End If
           If Attr = 17 Or Attr = 18 Then
              Max = Pick.dcount(the_old, Chr(253))
              Num_New = Pick.dcount(the_new, Chr(253))
              If Num_New > Max Then Max = Num_New
              For Ii = 1 To Max
                 If Pick.extract(the_old, 1, Ii, 0) = "" And Pick.extract(the_new, 1, Ii, 0) = "" Then GoTo 1615
                 If Pick.extract(the_old, 1, Ii, 0) <> "" Then the_old = Pick.replace(the_old, 1, Ii, 0, Pick.date_pick_to_vb(Pick.extract(the_old, 1, Ii, 0)))
                 If Pick.extract(the_new, 1, Ii, 0) <> "" Then the_new = Pick.replace(the_new, 1, Ii, 0, Pick.date_pick_to_vb(Pick.extract(the_new, 1, Ii, 0)))
1615          Next Ii
           End If
        End If
1620:
           Call Pick.sr_change(the_old, Chr(252), ",")
           Call Pick.sr_change(the_new, Chr(252), ",")
           GoSub 5000
           the_date = "": the_narr = ""
1690 Next I
     GoTo 1000
'
5000:
        maxl = Pick.dcount(the_old, Chr(253))
        If Pick.dcount(the_new, Chr(253)) > maxl Then maxl = Pick.dcount(the_new, Chr(253))
        For Ii = maxl To 1 Step -1
           If Pick.extract(the_old, 1, Ii, 0) = "" And Pick.extract(the_new, 1, Ii, 0) = "" Then
              maxl = maxl - 1
              the_old = Pick.delet(the_old, 1, Ii, 0)
              the_new = Pick.delet(the_new, 1, Ii, 0)
          End If
        Next Ii
        If Pick.dcount(the_narr, Chr(253)) > maxl Then maxl = Pick.dcount(the_narr, Chr(253))
        If maxl < 1 Then maxl = 1
        nrec(1 + ownadj) = Pick.replace(nrec(1 + ownadj), 1, Lct, 0, the_date)
        nrec(2 + ownadj) = Pick.replace(nrec(2 + ownadj), 1, Lct, 0, the_narr)
        nrec(3 + ownadj) = Pick.replace(nrec(3 + ownadj), 1, Lct, 0, the_msg)
        nrec(4 + ownadj) = Pick.replace(nrec(4 + ownadj), 1, Lct, 0, the_old)
        nrec(5 + ownadj) = Pick.replace(nrec(5 + ownadj), 1, Lct, 0, the_new)
        Lct = Lct + maxl
        Return

End Sub

Public Sub SR16_PENSDTE(database As String, ASSESS_NO As String, start_date As String, TCDE As Integer, Tref As String, TDTE, arrdate, Pcode As Integer, trans_rec, INS_AMT As Currency, CASH_DATE As String, cash_key As String, CALC_DATE As Integer)
'
'  This routine determines the start date for penalty calculation
'
Dim Rates_Id As String, rderr As Integer, rrec As String, IREC As String, date_penalty_due As String
Dim inv_key As String, posn As Integer, inspos As Integer, instal_ref As String
Dim Ii As Integer, Adj As Integer, thisyr As String, install As String, rate_refs As String
Dim Max_Ii As Integer, inpos As Integer

     start_date = ""
     If TDTE < arrdate Then
        start_date = CStr(arrdate)         ' arrears is exclusive
        Exit Sub
     End If
     Select Case TCDE
        Case 73
           Rates_Id = Tref & "*" & ASSESS_NO
           rderr = d3.d3_readstr(database, rrec, "RATES", Rates_Id)
           date_penalty_due = Pick.extract(rrec, 16, 0, 0)
           GoSub 100
        Case 50
           inv_key = Tref
           rderr = d3.d3_readstr(database, IREC, "INVOICE", inv_key)
           date_penalty_due = Pick.extract(IREC, 44, 2, 0)
        Case Else ' includes penalty codes of 76
           date_penalty_due = ""
     End Select
     start_date = date_penalty_due
     If Pcode <> 0 Then start_date = "": Exit Sub 'no penalty on current
     Exit Sub
'
' check if is on instalment plan
'
100:
     rderr = d3.d3_readstr(database, instal_ref, "INSTALL.CTL", CStr(ASSESS_NO))
     For Ii = 1 To 999        ' determine default option
        Adj = 20 * (Ii - 1)
        If Pick.extract(instal_ref, 12 + Adj, 0, 0) = "" Then GoTo 165
        posn = Pick.locate(Tref, instal_ref, 6 + Adj, 1, 0, inspos, "")
        If posn = 0 Then GoTo 163
        If Pick.extract(instal_ref, 15 + Adj, 0, 0) <> "" Then
           If Pick.extract(instal_ref, 16 + Adj, 0, 0) = "N" Then Return 'paying with PNET or PCR
           If Pick.extract(instal_ref, 16 + Adj, 0, 0) = "F" Then Return 'paying with PF
           GoTo 168 'taken up on instalment plan
        End If
        Return 'reference on not taken up instalment plan
163  Next Ii
' cannot find it, but in transition, does not have install.ctl for main
165  thisyr = Pick.extract(g_trans_info_array(59), 1, 1, 0)
     rderr = d3.d3_readstr(database, install, "DICT TRANS.J", "@INSTALL")
     rate_refs = ""
     Max_Ii = Pick.dcount(Pick.extract(install, 7, 1, 0), Chr(252))
     For Ii = 1 To Max_Ii
        If Pick.extract(install, 7, 1, Ii) = "Y" Then rate_refs = Pick.insert(rate_refs, 1, -1, 0, Pick.extract(install, 6, 1, Ii) & thisyr)
     Next Ii
     posn = Pick.locate(Tref, rate_refs, 1, 1, 0, inpos, "")
     If posn = 0 Then Return
     If Pick.extract(CStr(trans_rec), 85, 0, 0) = "" Then Return ' not on instalments
168  date_penalty_due = ""
' need to do this routine to work out penalty possibilities
' but do not want to update as is too early
' leave this to sr300.ins call of sr16.payins
     Call SR16_PAYINS(trans_rec, INS_AMT, CASH_DATE, cash_key, date_penalty_due, CALC_DATE, 0)
     Return

End Sub

Public Function ta1682_report(database As String) As String

Dim rlog_rep As String, Ii As Integer, Key As String, Last_Chng As String, Lastbit As String
Dim temp As String, counter As Integer, rl_lc As Integer, item As String

    If UBound(g_rates) = 0 Then
        g_rates(0) = "@RATES"
        Ii = d3.d3_readmat(database, g_rates(), "DICT TRANS.J")
    End If
     
    If UBound(g_trans_info_array) = 0 Then
       g_trans_info_array(0) = "TRANS.INFO"
       Ii = d3.d3_readmat(database, g_trans_info_array(), "DICT TRANS.J")
    End If
    If UBound(g_trans_info_array) < 126 Then ReDim Preserve g_trans_info_array(126)
    
    rlog_rep = ""
    rlog_rep = Pick.replace(rlog_rep, 2, 0, 0, "Rating Year  " & Pick.extract(g_trans_info_array(59), 1, 1, 0))
    rlog_rep = Pick.replace(rlog_rep, 3, 0, 0, "Arrears date " & Pick.oconv(Pick.extract(g_trans_info_array(59), 1, 3, 0), "D2"))
    If d3.d3_readstr(database, temp, "RATESLOG", "1649", 1) <> 0 Then temp = ""
    If IsNumeric(temp) Then counter = CInt(temp) Else counter = 0
    If counter > 0 Then
       Key = "1649*1*" & counter
       If d3.d3_readstr(database, Last_Chng, "RATESLOG", Key) <> 0 Then Last_Chng = ""
       If Last_Chng <> "" Then
          rlog_rep = Pick.replace(rlog_rep, 4, 0, 0, "Old Instalment details cleared from the properties on " & Pick.oconv(Pick.extract(Last_Chng, 1, 0, 0), "D2") & " by " & Pick.extract(Last_Chng, 4, 0, 0))
       Else
          rlog_rep = Pick.replace(rlog_rep, 4, 0, 0, "No record of Old Instalment details being cleared")
       End If
    Else
       rlog_rep = Pick.replace(rlog_rep, 4, 0, 0, "No record of Old Instalment details being cleared")
    End If
    If d3.d3_readstr(database, temp, "RATESLOG", "1681", 1) <> 0 Then temp = ""
    If IsNumeric(temp) Then counter = CInt(temp) Else counter = 0
    If counter > 0 Then
       Key = "1681*1*" & counter
       If d3.d3_readstr(database, Last_Chng, "RATESLOG", Key) <> 0 Then Last_Chng = ""
       If Last_Chng <> "" Then
          Lastbit = ", but not for all rate codes."
          If Mid$(Pick.extract(Last_Chng, 6, 0, 0), Len(Pick.extract(Last_Chng, 6, 0, 0)) - 2, 3) = "ALL" Then Lastbit = ", for all rate codes."
          rlog_rep = Pick.replace(rlog_rep, 5, 0, 0, "Future Valuations transfered to current on " & Pick.oconv(Pick.extract(Last_Chng, 1, 0, 0), "D2") & " by " & Pick.extract(Last_Chng, 4, 0, 0))
          rlog_rep = Pick.replace(rlog_rep, 6, 0, 0, Lastbit)
          rl_lc = 7
       Else
          rlog_rep = Pick.replace(rlog_rep, 5, 0, 0, "No record of Future Valuations transfered to current")
          rl_lc = 6
       End If
    Else
       rlog_rep = Pick.replace(rlog_rep, 5, 0, 0, "No record of Future Valuations transfered to current")
       rl_lc = 6
    End If

    If d3.d3_readstr(database, item, "DICT TRANS.J", "@RATESMESS") <> 0 Then item = ""
    rlog_rep = Pick.replace(rlog_rep, rl_lc, 0, 0, "Pensioner Narrative  & - ")
        rl_lc = rl_lc + 1
        For Ii = 1 To 6
           rlog_rep = Pick.replace(rlog_rep, rl_lc, 0, 0, "Line " & Ii & " &  " & Pick.extract(item, 1, Ii, 0))
           rl_lc = rl_lc + 1
        Next Ii
        rlog_rep = Pick.replace(rlog_rep, rl_lc, 0, 0, "NON-pensioner Narrative  & - ")
        rl_lc = rl_lc + 1
        For Ii = 1 To 6
           rlog_rep = Pick.replace(rlog_rep, rl_lc, 0, 0, "Line " & Ii & " &  " & Pick.extract(item, 2, Ii, 0))
           rl_lc = rl_lc + 1
        Next Ii

     ta1682_report = rlog_rep
     
End Function

Public Sub printer_on_off(on_off As Integer, Optional FontName As String = "", Optional FontSize As Double = 0, Optional orient As Integer = "-1")

'on_off = 1 to set on, =0 to set off

Static tmpFontName As String
Static tmpFontSize As String

'Currently two points assumed
'1.Working with default printer in portrait mode
'2.A4 Paper

'Spacing below verified on CKA Kyocera 1700
'Courier New >> Monospaced Font
'Courier New 12pt >> 80 chars per line, 58 lines per page
'Courier New 11pt >> 86 chars per line, 63 lines per page
'Courier New 10pt >> 96 chars per line, 70 lines per page
'Courier New 9pt >> 106 chars per line, 78 lines per page

     If on_off = 0 Then
        Printer.EndDoc
        Printer.Font.Name = tmpFontName 'revert printer to original settings
        Printer.Font.Size = tmpFontSize
     Else
        tmpFontName = Printer.Font.Name 'save original settings
        tmpFontSize = Printer.Font.Size
        If orient <> -1 Then Printer.Orientation = orient ' 1=vbPRORPortrait 2=Printer.Orientation = vbPRORLandscape
        If FontName <> "" Then Printer.Font.Name = FontName Else Printer.Font.Name = "Courier New"
        Select Case FontSize
           Case -1: Printer.Font.Size = tmpFontSize 'put back to original
           Case -2: Printer.Font.Size = Printer.Font.Size + 4 'make bigger for headings
           Case Is <> 0: Printer.Font.Size = FontSize 'set font size
        End Select
        
     End If
     
End Sub

Public Sub SR1692(Client_Rec() As String, Syear As String, Pcode As Integer, senior As Integer)

Dim Eyear, Tmp_Eyear, Year_Days, use As Integer
Dim Numdays(2), maxd As Integer, J As Integer, Sdate, Edate, k, Percentage, Per, Syr
Dim Styr, Sdates As String, Edates, temp As String

' PCODE IS FRACTION OF ASSESSMENT VALUE SUBJECT TO PENSIONER REBATE
'  IE .5 or 1 etc
' SENIOR IS FRACTION OF ASSESSMENT VALUE SUBJECT TO SENIOR REBATE
'
     temp = Client_Rec(84): If IsNumeric(temp) Then senior = CInt(temp) Else senior = 0
     temp = Client_Rec(44): If IsNumeric(temp) Then Pcode = CInt(temp) Else Pcode = 0

     If Syear = "" Then GoTo 99
'
     Eyear = Mid$(Pick.oconv(Syear, "D2"), 8, 2) 'mco 14aug01
     If Syear >= CInt(g_trans_info_array(7)) Then Eyear = Eyear + 1  'mco 14aug01
     Eyear = Right(Space(2) & ("00" & Eyear), 2)
     Tmp_Eyear = Pick.ICONV("30 JUN " & Eyear, "D2")
     If Tmp_Eyear < Syear Then
        Eyear = Eyear + 1
        Eyear = Right(Space(2) & ("00" & Eyear), 2)
     End If
     Eyear = Pick.ICONV("30 JUN " & Eyear, "D2")
     Year_Days = Eyear - Syear + 1
     Numdays(1) = 0: Numdays(2) = 0
     maxd = Pick.dcount(Client_Rec(17), Chr(253))
     For J = 1 To maxd
        Sdate = Pick.extract(Client_Rec(17), 1, J, 0)
        Edate = Pick.extract(Client_Rec(18), 1, J, 0)
        For k = 1 To 2
           Percentage = Pick.extract(Client_Rec(79 + k), 1, J, 0)
           If Percentage <> "" Then 'pcode
'PRINT PERCENTAGE:'=':SDATE:'=':SYEAR:'=':EDATE:'=':EYEAR; INPUT AAA
              If Sdate >= Syear Then  ' not full year
                 If Edate = "" Or Edate > Eyear Then use = Eyear Else use = Edate
                 Per = 100 * Percentage * (use - Sdate + 1) / Year_Days
'PRINT PERCENTAGE:'=':USE-SDATE+1:'=':YEAR.DAYS; INPUT AAA
                 Numdays(k) = Numdays(k) + Per
'PRINT NUMDAYS(K):'=':PER; INPUT AAA
              Else
                 If Edate <> "" Then
'PRINT 'EDATE=':EDATE; INPUT AAA
                    If Edate >= Syear And Edate <= Eyear Then
                       Per = 100 * Percentage * (Edate - Syear + 1) / Year_Days
'PRINT PERCENTAGE:'=':EDATE-SYEAR+1:'=':YEAR.DAYS; INPUT AAA
                       Numdays(k) = Numdays(k) + Per
'PRINT NUMDAYS(K):'=':PER; INPUT AAA
                    End If
                 End If
              End If
           End If
        Next k
     Next J
     If Numdays(1) <> 0 Then
        Pcode = Numdays(1) / 100
     End If
     If Numdays(2) <> 0 Then
        senior = Numdays(2) / 100
     End If
     If Pcode < "0" Then Pcode = 0
     If senior < "0" Then senior = 0
     Exit Sub
'
'*** Check when became pensioner/senior ****
99   Syr = Mid$(Pick.oconv(g_trans_info_array(7), "D2"), 8, 2)
     Syr = Syr + 1
     Syr = Right(Space(2) & ("00" & Syr), 2)
     Styr = Pick.ICONV("30 JUN " & Syr, "D2")
     If Syear = "" Then
        Sdates = Client_Rec(17)
        Edates = Client_Rec(18)
        maxd = Pick.dcount(Sdates, Chr(253))
        If Pick.extract(Sdates, 1, maxd, 0) > Styr Then
           If maxd = 1 Then
              Pcode = 0
              senior = 0
           Else
              Pcode = Pick.extract(Client_Rec(80), 1, maxd - 1, 0) + 0
              senior = Pick.extract(Client_Rec(81), 1, maxd - 1, 0) + 0
           End If
        End If
     End If
     Exit Sub   ' to calling progrm

End Sub


Public Function sr293(logentry As String, Params As String, pass_Invoice As String) As String

Dim Cde As String, Qld As Integer
Dim From_Group, To_Group, Max_Ii, Ii, Pass_Info
Dim Whofor, Ans As String, Msg_Line, User_Name As String, User_Numb As String
Dim User_Bank As String, User_Bsb As String, Bank_Hdr_Code As String, User_Acc As String
Dim Onfile, trec As String, Proc_Date As String, Idate As String, Tot_Cr As Currency, Tot_Rec As Long, Stops As String
Dim rec As String, Next_Chq, Crec As String, Issue_Date As Integer, Amt As Currency, pr_amt As String, Eft_Acc As String
Dim Eft_Rf, Eft_Name, Isdd As Integer, Bsbacc, Bsb, Acc, Eft_Rec As String, Eft_Ref
Dim Eft_Date As Integer, Eff_From As Integer, Eff_To As Integer
Dim Xrec
Dim user As String, invoice As Integer
Dim database As String
Dim tape_ref As String, f_banknum As String, inv_id As String
Dim clrec As String, efx As Integer
Dim the_drive As String, fnum As Integer, nrec As String, temp As String
Dim kk As Long, maxt As Long, mylist() As String, pick_cnt As Long, wterr As String
Dim td_id As String, drec() As String, bal_owing As Currency, next_pay_date As Integer
Dim temp_date As String, incr As String, days As Double, vrec() As String

'
'  Create EFT file for Creditor payments - invoice=0
'  Create EFT file for Debtor direct debits - invoice=1
'
     If IsNumeric(pass_Invoice) Then invoice = CInt(pass_Invoice) Else invoice = 0
     
     database = Pick.extract(logentry, 2, 0, 0)
     f_banknum = Pick.extract(Params, 1, 0, 0): If f_banknum = "1" Then f_banknum = ""
     tape_ref = Pick.extract(Params, 2, 0, 0)
     
     Proc_Date = Pick.extract(Params, 3, 0, 0)
     Idate = Pick.date_pick_to_vb(Proc_Date)
     Proc_Date = Right("0" & Day(Idate), 2) & Right("0" & Month(Idate), 2) & Right(Year(Idate), 2) 'ie 010302 for 01 mar 02
     User_Name = Pick.extract(Params, 4, 0, 0)
     User_Numb = Pick.extract(Params, 5, 0, 0)
     User_Bank = Pick.extract(Params, 6, 0, 0)
     User_Acc = Pick.extract(Params, 7, 0, 0)
        
     If User_Bank Like "???-???" Then
        User_Bsb = Pick.field(User_Bank, "-", 2)
        User_Bank = Pick.field(User_Bank, "-", 1)
        Bank_Hdr_Code = User_Bank
     Else
        sr293 = Chr(8) & User_Bank & " not correct - format for Bank-BSB is xxx-xxx"
        Exit Function
     End If
     
     If UBound(g_trans_info_array) = 0 Then
        g_trans_info_array(0) = "TRANS.INFO"
        Ii = d3.d3_readmat(database, g_trans_info_array(), "DICT TRANS.J")
        If UBound(g_trans_info_array) < 113 Then ReDim Preserve g_trans_info_array(113)
     End If
     
     If invoice Then Cde = " 13": Whofor = "DIRECTDEBITS" Else Cde = " 50": Whofor = "CREDITORS"

     temp = Mid$(g_trans_info_array(53), 4, 1)
     If IsNumeric(temp) Then Qld = CInt(temp) Else Qld = 0

     user = User_Name
     user = Pick.replace(user, 2, 0, 0, User_Numb)
     user = Pick.replace(user, 3, 0, 0, User_Bank)
     user = Pick.replace(user, 4, 0, 0, User_Bsb)
     user = Pick.replace(user, 5, 0, 0, User_Acc)
     wterr = d3.d3_writestr(database, "DICT TRANS.J", "@CEMTEX", user)

     User_Bsb = User_Bank & "-" & User_Bsb
     
     If invoice = 0 Then
        If d3.d3_readstr(database, rec, "CHQ.REC" & f_banknum, tape_ref & ".1") <> 0 Then
           sr293 = Chr(8) & tape_ref & "is not a valid file reference on CHQ.REC" & f_banknum: Exit Function
        End If
     End If

     'If d3.d3_readstr(database, Ans, "CHQ.REC.TAPE" & f_banknum, "E" & tape_ref) = 0 Then
     '   sr293 = "Processing already complete. E" & tape_ref & " on file CHQ.REC.TAPE" & f_banknum: Exit Function
     'End If
     
     If d3.d3_readstr(database, trec, "CHQ.REC.TAPE" & f_banknum, tape_ref) = 0 Then
        sr293 = Chr(8) & "Already produced " & tape_ref & " on file CHQ.REC.TAPE" & f_banknum & " on " & Pick.oconv(Pick.extract(trec, 3, 0, 0), "D2"): Exit Function
     End If
     
     trec = ""
     Tot_Cr = 0:  Tot_Rec = 0:  Stops = ""
'
     the_drive = Pick.extract(logentry, 9, 0, 0)
     fnum = FreeFile
     nrec = the_drive & "prospect_site/mergefiles/" & tape_ref & ".txt"
     Open nrec For Output Access Write As #fnum
     
     rec = "0" & Space(17) & "01" & Left(Bank_Hdr_Code & Space(3), 3) & Space(7) & Left(User_Name & Space(26), 26) & Left(User_Numb & Space(6), 6) & Left(Whofor & Space(12), 12) & Proc_Date & Space(40)
     Print #fnum, rec
     Next_Chq = 0
'
     If invoice Then
'sundry debtors
       maxt = d3.d3_select(logentry, "SSELECT INVOICE WITH A63 = """"", mylist(), pick_cnt, 0, 0) - 1
       For kk = 0 To maxt
        inv_id = mylist(kk)
        If d3.d3_readstr(database, Crec, "INVOICE", inv_id) <> 0 Then GoTo 208
        Crec = Pick.replace(Crec, 63, 0, 0, 1)
        Crec = Pick.replace(Crec, 64, 0, 0, "")
        If Pick.extract(Crec, 37, 0, 0) <> "" Then GoTo 206
        Issue_Date = Pick.extract(Crec, 20, 0, 0)
        Amt = Pick.extractcur(Crec, 8, 0, 0)
        If Amt = 0 Then GoTo 206
        Eft_Acc = Pick.extract(Crec, 3, 0, 0)
        Call SR_DIRECT(database, Eft_Acc, Issue_Date, Isdd, Bsbacc, drec())
        If Isdd <> 0 Then
           If d3.d3_readstr(database, clrec, "CLIENT", Eft_Acc) <> 0 Then GoTo 206
           Eft_Name = Pick.trimm(Pick.extract(clrec, 1, 0, 0) & ". " & Pick.extract(clrec, 7, 0, 0))
           Eft_Acc = Right(Space(7) & (String$(7, 0) & Eft_Acc), 7)
           Eft_Rf = "INV" & inv_id
           Crec = Pick.replace(Crec, 64, 0, 0, tape_ref)
           GoSub 420
        End If
206     wterr = d3.d3_writestr(database, "INVOICE", inv_id, Crec)
208    Next kk
'rates debtors
       maxt = d3.d3_select(logentry, "SSELECT TDEBTOR WITH A58", mylist(), pick_cnt, 0, 0) - 1
       For kk = 0 To maxt
        td_id = mylist(kk)
        If d3.d3_readstr(database, Crec, "PROPERTY", td_id) <> 0 Then GoTo 308 'only assessments
        Eft_Acc = td_id
        Call SR_DIRECT(database, Eft_Acc, 0, Isdd, Bsbacc, drec())
        If Isdd = 0 Then GoTo 308
        If UBound(drec) < 66 Then ReDim Preserve drec(66)
        If IsNumeric(drec(64)) Then 'check if fixed amount is to be paid
           Amt = CCur(drec(64))
           If Amt = 0 Then GoTo 308
           If IsNumeric(drec(3)) Then bal_owing = CCur(drec(3)) Else bal_owing = 0
           If drec(66) <> "Y" Then 'do not make payment if nothing owing
              If bal_owing < Amt Then Amt = bal_owing
              If Amt <= 0 Then GoTo 308 ' nothing to pay
           End If
           If IsNumeric(drec(67)) Then
              next_pay_date = CInt(drec(67)) 'last payment date
303:
              Select Case drec(65)
                 Case "W": days = 7: incr = "d"
                 Case "F": days = 14: incr = "d"
                 Case "Y": days = 1: incr = "yyyy"
                 Case "M": days = 1: incr = "m"
                 Case "Q": days = 1: incr = "q"
                 Case Else: days = Left(drec(65), Len(drec(65)) - 1): incr = "d"
               End Select
                 'got to get drec(65) in format that dateadd likes
                    ' q m yyyy d ww - for periods
                    ' # a number for the number of that period
              temp_date = DateAdd(incr, days, Pick.date_pick_to_vb(next_pay_date))
              Call Pick.date_vb_to_pick(temp_date, next_pay_date, 0)
           Else
              If IsNumeric(drec(59)) Then next_pay_date = CInt(drec(59)) Else GoTo 308 'payments from date
           End If
           If IsNumeric(drec(60)) Then 'to date
              If next_pay_date > CInt(drec(60)) Then GoTo 308
           End If
           If next_pay_date > CInt(DateDiff("d", "31/12/67", Idate)) Then GoTo 308
           Issue_Date = next_pay_date
        Else 'pay what is owing and set issue_date
           Call SR_DIRECT(database, Eft_Acc, Issue_Date, Isdd, Bsbacc, drec())
           If Isdd = 0 Then GoTo 308
           If UBound(drec) < 66 Then ReDim Preserve drec(66)
           Call sr1694(logentry, vrec(), Idate, td_id, "1") 'net of discounts/penalties as of today ??? pay later if can ???
           If IsNumeric(vrec(8)) Then bal_owing = CCur(vrec(8)) Else bal_owing = 0
           If bal_owing = 0 Then GoTo 308
           Amt = bal_owing
        End If
        If d3.d3_readstr(database, clrec, "CLIENT", Eft_Acc) <> 0 Then GoTo 308
        Eft_Name = Pick.trimm(Pick.extract(clrec, 1, 0, 0) & ". " & Pick.extract(clrec, 7, 0, 0))
        Eft_Rf = ""
        Eft_Acc = Right(Space(7) & (String$(7, 0) & td_id), 7)
        GoSub 420
        If IsNumeric(drec(64)) Then GoTo 303 'check if another fixed amount is to be paid
308    Next kk
       GoTo 900
     Else
398     Next_Chq = Next_Chq + 1
        If d3.d3_readstr(database, Crec, "CHQ.REC" & f_banknum, tape_ref & "." & Next_Chq) <> 0 Then GoTo 900
        If Pick.extract(Crec, 1, 0, 0) = "S" Then
           Stops = Pick.insert(Stops, 1, 1, -1, tape_ref & "." & Next_Chq)
           GoTo 398
        End If
        Bsbacc = Pick.extract(Crec, 32, 0, 0)
        Amt = Pick.extractcur(Crec, 2, 0, 0)
        Issue_Date = Pick.extract(Crec, 3, 0, 0)
        Eft_Acc = Pick.extract(Crec, 5, 0, 0)
        Eft_Name = Pick.extract(Crec, 6, 0, 0)
        GoSub 420
        GoTo 398
     End If
     
420  Bsb = Mid$(Bsbacc, 5, 7)
     Acc = Mid$(Bsbacc, 13, 9)
     Tot_Cr = Tot_Cr + Amt
     Tot_Rec = Tot_Rec + 1
     pr_amt = Right(Space(10) & (String$(10, 0) & Amt), 10)
'
     Eft_Rec = ""
     If invoice = 0 Then
        If d3.d3_readstr(database, Eft_Rec, "EFT", Eft_Acc) <> 0 Then Eft_Rec = ""
        Eft_Ref = ""
     End If
     If Eft_Rec <> "" Then
        Eft_Date = Pick.extractint(Crec, 18, 1, 1)
        If Eft_Date = 0 Then Eft_Date = Issue_Date
        If Pick.locate(CStr(Eft_Date), Eft_Rec, 1, 1, 0, efx, "AR") <> 0 Then
        End If
        Eff_From = Pick.extractint(Eft_Rec, 1, efx, 0)
        If Eff_From = 0 Or Eff_From > Eft_Date Then efx = efx - 1
        If efx Then
           Eff_To = Pick.extractint(Eft_Rec, 2, efx, 0)
           If Eff_To = 0 Or Eft_Date <= Eff_To Then
              Eft_Ref = Pick.extract(Eft_Rec, 3, efx, 0)
           End If
        End If
     End If
     If invoice Then
        Eft_Ref = Eft_Acc & Eft_Rf
     End If
     If Eft_Ref = "" Then Eft_Ref = "Creditor " & Eft_Acc
'
     If Qld Then
        rec = "1" & Left(Bsbacc & Space(16), 16) & Cde & pr_amt & Left(Eft_Name & Space(32), 32) & Left(Eft_Ref & Space(18), 18) & Left(User_Bsb & Space(7), 7) & Right(Space(9) & User_Acc, 9) & Left(User_Name & Space(16), 16) & String$(8, 0)
     Else
        rec = "1" & Left(Bsb & Space(7), 7) & Right(Space(9) & Acc, 9) & Cde & pr_amt & Left(Eft_Name & Space(32), 32) & Left(Eft_Ref & Space(18), 18) & Left(User_Bsb & Space(7), 7) & Right(Space(9) & User_Acc, 9) & Left(User_Name & Space(16), 16) & String$(8, 0)
     End If
     Print #fnum, rec
     Return
'
900  rec = Left("7999-999" & Space(20), 20) & Right(String$(10, 0) & Tot_Cr, 10) & Right(String$(10, 0) & Tot_Cr, 10) & String$(10, 0) & Space(24) & Right(String$(6, 0) & Tot_Rec, 6) & Space(40)
     Print #fnum, rec
     Close #fnum
     
     trec = Pick.insert(trec, 1, -1, 0, Tot_Cr + 0)
     trec = Pick.insert(trec, 2, -1, 0, Tot_Rec + 0)
     trec = Pick.insert(trec, 3, -1, 0, Pick.ICONV(Format$(Now, "DD MMM YY"), "D2"))
     trec = Pick.insert(trec, 4, -1, 0, Time())
     trec = Pick.insert(trec, 5, -1, 0, CStr(Idate))
     trec = Pick.insert(trec, 6, -1, 0, Stops)
    
     temp = Tot_Rec + 0 & " amounts totalling $" & Pick.oconv(CStr(Tot_Cr), "MD2,") & " processed"
     If Stops <> "" Then
        temp = temp & Chr(8) & "Following stopped payments are not included " & replace(Stops, Chr(253), ",")
     End If
     
     wterr = d3.d3_writestr(database, "CHQ.REC.TAPE" & f_banknum, tape_ref, trec)
     If wterr <> "0" Then temp = temp & Chr(8) & "Write failed to CHQ.REC.TAPE " & f_banknum & " for item " & tape_ref
     
     sr293 = nrec & Chr(8) & "File created" & Chr(8) & temp

End Function




Public Sub SR_DIRECT(database As String, Eft_Acc As String, Issue_Date As Integer, Isdd As Integer, Bsbacc, drec() As String)

'
' SET ISDD = 1 IF ON DIRECT DEBIT AT THE DATE ELSE SET TO 0
'
     Isdd = 0

     ReDim drec(0): drec(0) = Eft_Acc
     If d3.d3_readmat(database, drec(), "TDEBTOR") <> 0 Then Exit Sub
     Bsbacc = drec(58)
     If Bsbacc = "" Then Exit Sub
     If Issue_Date = 0 Then Isdd = 1: Exit Sub
     
     If IsNumeric(drec(59)) Then
        If Issue_Date < CInt(drec(59)) Then Exit Sub
     End If
     If IsNumeric(drec(60)) Then
        If Issue_Date > CInt(drec(60)) Then Exit Sub
     End If
     Isdd = 1

End Sub

