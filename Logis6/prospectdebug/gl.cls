VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "gl"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit
Option Compare Text

Private d3 As New d3
Private Pick As New Pick

Private g_trans_info_array() As String

Public Sub Delete_Report_Codes(mdb_name As String, Account_Id As String, fname As String)
'
' Deletes All Report Type Code Records From Table gl_rtype for an Account
'
Dim sentence As String, No_Recs As Long, MyIds() As String, pick_cnt As Long
Dim I As Integer, RId As String, temp As String
    sentence = "Select * from " & fname & " where Account = " & Chr(34) & Account_Id & Chr(34)
    No_Recs = d3.msa_select(mdb_name, sentence, MyIds, pick_cnt, 0, 0)
    If No_Recs > 0 Then
        For I = 0 To No_Recs - 1
            RId = MyIds(I)
            temp = d3.d3_delete("", mdb_name & "\" & fname, RId)
        Next I
    End If
End Sub


Public Function gl_update(logentry As String, tbl_name As String, Id As String, the_rec As String, old_rec As String, action As String) As String

Dim Class As String, Pos As Integer, Rec As String
Dim database As String
Dim group As String, groupclass As String, subclass As String
Dim Balance As Currency, mdb_name As String, gcrec As String, RTypes As String, RCodes As String

database = Pick.extract(logentry, 2, 0, 0)
Pos = InStr(tbl_name, ".mdb\")
mdb_name = Left(tbl_name, Pos + 3)

gl_update = "0" 'this means all was okay

If action = "D" Then
   If d3.d3_readstr("", Rec, tbl_name, Id) <> 0 Then Exit Function
   Balance = Pick.extractcur(Rec, 16, 0, 0)
   If Balance <> 0 Then
      gl_update = Chr(8) & Id & " has balance of " & Balance & ".  Cannot delete"
      Exit Function
   End If
   gl_update = d3.d3_delete(database, tbl_name, Id)
   Call Delete_Report_Codes(mdb_name, Id, "gl_rtype")
   Call Delete_Report_Codes(mdb_name, Id, "gl_rcode")
   Exit Function
End If
'action = "W" - updating existing item
'action = "A" - adding new item

' want to check that the CLASS is valid
   group = Pick.field(Id, ".", 1)
   If Not (IsNumeric(group)) Then
      gl_update = Chr(8) & group & " is not numeric "
      Exit Function
   End If
   Class = Pick.field(Id, ".", 2)
   groupclass = group & "." & Class
   subclass = Pick.field(Id, ".", 3)
   


   If Pick.Index(Id, ".", 2) <> 0 Then 'has two dots so group.class must exist
      If d3.d3_readstr("", gcrec, tbl_name, groupclass) <> 0 Then
         gl_update = Chr(8) & groupclass & " does not exist on file " & tbl_name
         Exit Function
      End If
      If Not (IsNumeric(subclass)) Or Left(subclass, 1) = "0" Then
         gl_update = Chr(8) & "Subclass " & subclass & " is not numeric or begins with 0 which is not allowed"
         Exit Function
      End If
   Else
      gl_update = Chr(8) & "Must have a two dot separators in account number"
      Exit Function
   End If
   
   Rec = the_rec
   If action = "A" Then
      the_rec = Pick.replace(the_rec, 16, 0, 0, "0") 'set balance to zero
   Else 'updating can only alter type and description - start with original record
      If d3.d3_readstr("", the_rec, tbl_name, Id) <> 0 Then the_rec = ""
      the_rec = Pick.replace(the_rec, 2, 0, 0, Pick.extract(Rec, 2, 0, 0))
   End If
   the_rec = Pick.replace(the_rec, 1, 0, 0, Pick.extract(gcrec, 1, 0, 0))
   the_rec = Pick.replace(the_rec, 3, 0, 0, "3")
   the_rec = Pick.replace(the_rec, 4, 0, 0, group)
   the_rec = Pick.replace(the_rec, 5, 0, 0, Class)
   the_rec = Pick.replace(the_rec, 6, 0, 0, subclass)
   Call Delete_Report_Codes(mdb_name, Id, "gl_rtype")
   Call Delete_Report_Codes(mdb_name, Id, "gl_rcode")
   RTypes = Pick.extract(Rec, 13, 0, 0)
   If RTypes <> "" Then Call Insert_Report_Codes(database, mdb_name, RTypes, Id, "gl_rtype")
   RCodes = Pick.extract(Rec, 14, 0, 0)
   If RCodes <> "" Then Call Insert_Report_Codes(database, mdb_name, RCodes, Id, "gl_rcode")
   the_rec = Pick.delet(the_rec, 14, 0, 0) 'rcode
   the_rec = Pick.delet(the_rec, 13, 0, 0) 'rtype
   the_rec = Pick.delet(the_rec, 12, 0, 0)
   gl_update = d3.d3_writestr(database, tbl_name, Id, the_rec)
   
End Function










Public Function gl_grp_class_update(logentry As String, tbl_name As String, Id As String, the_rec As String, old_rec As String, action As String) As String

Dim Class As String, Pos As Integer, Rec As String
Dim database As String
Dim group As String, groupclass As String, subclass As String, I As Integer
Dim Balance As Currency, mdb_name As String, grec As String, RTypes As String, RCodes As String

database = Pick.extract(logentry, 2, 0, 0)
Pos = InStr(tbl_name, ".mdb\")
mdb_name = Left(tbl_name, Pos + 3)

gl_grp_class_update = "0" 'this means all was okay

If action = "D" Then
   If d3.d3_readstr("", Rec, tbl_name, Id) <> 0 Then Exit Function
   Balance = Pick.extractcur(Rec, 16, 0, 0)
   If Balance <> 0 Then
      gl_grp_class_update = Chr(8) & Id & " has balance of " & Balance & ".  Cannot delete"
      Exit Function
   End If
   gl_grp_class_update = d3.d3_delete(database, tbl_name, Id)
   Call Delete_Report_Codes(mdb_name, Id, "gl_rtype")
   Call Delete_Report_Codes(mdb_name, Id, "gl_rcode")
   Exit Function
End If
'action = "W" - updating existing item
'action = "A" - adding new item

' want to check that the CLASS is valid
   group = Pick.field(Id, ".", 1)
   If Not (IsNumeric(group)) Then
      gl_grp_class_update = Chr(8) & group & " is not numeric "
      Exit Function
   End If
   Class = Pick.field(Id, ".", 2)
   groupclass = group & "." & Class
   subclass = Pick.field(Id, ".", 3)
   


   If Pick.Index(Id, ".", 1) <> 0 Then 'has one dot so group must exist
      If d3.d3_readstr("", grec, tbl_name, group) <> 0 Then
         gl_grp_class_update = Chr(8) & group & " does not exist on file " & tbl_name
         Exit Function
      End If
      If Not (IsNumeric(Class)) Or Left(Class, 1) = "0" Then
         gl_grp_class_update = Chr(8) & "Class " & Class & " is not numeric or begins with 0 which is not allowed"
         Exit Function
      End If
   Else
      gl_grp_class_update = Chr(8) & "Must have a dot separator in account number"
      Exit Function
   End If
   If Pick.Index(Id, ".", 2) <> 0 Then 'has two dots so group.class must exist
      gl_grp_class_update = Chr(8) & "Cannot have two dots in account number"
      Exit Function
   End If
   Rec = the_rec
   If action = "A" Then
      the_rec = Pick.replace(the_rec, 16, 0, 0, "0") 'set balance to zero
   Else 'updating can only alter type and description - start with original record
      If d3.d3_readstr("", the_rec, tbl_name, Id) <> 0 Then the_rec = ""
      the_rec = Pick.replace(the_rec, 2, 0, 0, Pick.extract(Rec, 2, 0, 0))
   End If
   the_rec = Pick.replace(the_rec, 1, 0, 0, Pick.extract(grec, 1, 0, 0))
   the_rec = Pick.replace(the_rec, 3, 0, 0, "2")
   the_rec = Pick.replace(the_rec, 4, 0, 0, group)
   the_rec = Pick.replace(the_rec, 5, 0, 0, Class)
   Call Delete_Report_Codes(mdb_name, Id, "gl_rtype")
   Call Delete_Report_Codes(mdb_name, Id, "gl_rcode")
   RTypes = Pick.extract(Rec, 120, 0, 0)
   If RTypes <> "" Then Call Insert_Report_Codes(database, mdb_name, RTypes, Id, "gl_rtype")
   RCodes = Pick.extract(Rec, 121, 0, 0)
   If RCodes <> "" Then Call Insert_Report_Codes(database, mdb_name, RCodes, Id, "gl_rcode")
   For I = 121 To 100 Step -1
      the_rec = Pick.delet(the_rec, I, 0, 0)
   Next I
   gl_grp_class_update = d3.d3_writestr(database, tbl_name, Id, the_rec)
   Exit Function
 End Function


Public Function gl_grp_update(logentry As String, tbl_name As String, Id As String, the_rec As String, old_rec As String, action As String) As String

Dim Class As String, Pos As Integer, Rec As String, NPos As Long, I As Integer
Dim database As String, Am As String, Vm As String, RTypes As String, RCodes As String
Dim group As String, groupclass As String, subclass As String, temp As String
Dim Balance As Currency, mdb_name As String, grec As String
database = Pick.extract(logentry, 2, 0, 0)
Am = Chr(254): Vm = Chr(253)
gl_grp_update = "0" 'this means all was okay
NPos = InStr(1, tbl_name, ".mdb", vbTextCompare)
mdb_name = Left(tbl_name, NPos + 3)
If action = "D" Then
   If d3.d3_readstr("", Rec, tbl_name, Id) <> 0 Then Exit Function
   Balance = Pick.extractcur(Rec, 16, 0, 0)
   If Balance <> 0 Then
      gl_grp_update = Chr(8) & Id & " has balance of " & Balance & ".  Cannot delete"
      Exit Function
   End If
   gl_grp_update = d3.d3_delete(database, tbl_name, Id)
   Call Delete_Report_Codes(mdb_name, Id, "gl_rtype")
   Call Delete_Report_Codes(mdb_name, Id, "gl_rcode")
   Exit Function
End If
Call Delete_Report_Codes(mdb_name, Id, "gl_rtype")
Call Delete_Report_Codes(mdb_name, Id, "gl_rcode")
RTypes = Pick.extract(the_rec, 120, 0, 0)
If RTypes <> "" Then Call Insert_Report_Codes(database, mdb_name, RTypes, Id, "gl_rtype")
RCodes = Pick.extract(the_rec, 121, 0, 0)
If RCodes <> "" Then Call Insert_Report_Codes(database, mdb_name, RCodes, Id, "gl_rcode")
For I = 121 To 100 Step -1
the_rec = Pick.delet(the_rec, I, 0, 0)
Next I
the_rec = Pick.replace(the_rec, 3, 0, 0, "1")
the_rec = Pick.replace(the_rec, 4, 0, 0, Id)
gl_grp_update = d3.d3_writestr(database, tbl_name, Id, the_rec)
End Function
Public Sub Insert_Report_Codes(database As String, mdb_name As String, RTypes As String, Id As String, fname As String)
'
' Inserts Report Type Code Records for an Account into Table gl_rtype
' Codes are Delimited by Value Marks (Chr(253) in Rtypes
'
Dim ReportTypes() As String, Am As String, Vm As String, RTableName As String, recid As String
Dim Rt As String, rrec As String, temp As String, I As Integer, dummy As String, Ct As Integer

    Am = Chr(254): Vm = Chr(253)
    ReportTypes = Split(RTypes, Vm, , vbBinaryCompare)
    RTableName = mdb_name & "\" & fname
    For I = 0 To UBound(ReportTypes)
        Rt = ReportTypes(I)
        rrec = Rt & Am & Id
        recid = DateDiff("d", "31/12/67", CVar(Now)) & "." & Timer(): Ct = 0
try_again:
        If d3.d3_readstr(database, dummy, RTableName, recid) <> 0 Then
           temp = d3.d3_writestr(database, RTableName, recid, rrec)
        Else 'exists
           recid = DateDiff("d", "31/12/67", CVar(Now)) & "." & Timer() & "." & (Ct + 1): GoTo try_again
        End If
    Next I
    
End Sub

Public Sub sr_gen_l_month_values(the_file As String, use_id As String, Nrec() As String)

Dim Mm As Integer, k As Integer, NPos As Long, mdb_name As String, curryear As String, offset As Integer
Dim Yr As String, the_rec() As String, table_name As String, RdError As Integer, ProcessYear As String


NPos = InStr(1, the_file, ".mdb", vbTextCompare)
mdb_name = Left(the_file, NPos + 3)

ReDim the_rec(1)


ReDim Nrec(9)
Yr = Right(the_file, 2)
If Not (IsNumeric(Yr)) Then Yr = ""
If Yr = "" Then
    table_name = mdb_name & "\CurrentYear"
    the_rec(0) = "YEAR"
    RdError = d3.d3_readmat("", the_rec, table_name)
    curryear = the_rec(1)
Else
    If CInt(Left(Yr, 1)) < 8 Then
        curryear = "20" & Yr
    Else
        curryear = "19" & Yr
    End If
End If
ProcessYear = curryear
offset = 0
GoSub GetVals
ProcessYear = CStr(CInt(curryear) - 1)
offset = 3
GoSub GetVals
ProcessYear = CStr(CInt(curryear) + 1)
offset = 6
GoSub GetVals
Exit Sub


GetVals: ' Get the Values for a Year
'Period End Dates
table_name = mdb_name & "\monthends"
the_rec(0) = ProcessYear
RdError = d3.d3_readmat("", the_rec, table_name)
Mm = 1 + offset
For k = 1 To UBound(the_rec)
    If RdError = 0 Then
        Nrec(Mm) = Pick.replace(Nrec(Mm), 1, k, 0, the_rec(k))
    Else
        Nrec(Mm) = Pick.replace(Nrec(Mm), 1, k, 0, "&nbsp") ' This Forces Each Year Table to the Same Size
    End If
Next k
' Actual
If ProcessYear = curryear Then Yr = "" Else Yr = Right(ProcessYear, 2)
If Yr = "" Then
    table_name = mdb_name & "\gen_l"
Else
    table_name = mdb_name & "\gen_l_" & Yr
End If
the_rec(0) = use_id
RdError = d3.d3_readmat("", the_rec, table_name)
If RdError = 0 Then
    Mm = 3 + offset
    For k = 1 To 12
    Nrec(Mm) = Pick.replace(Nrec(Mm), 1, k, 0, FormatCurrency(the_rec(k + 25), 2))
    Next k
End If
' Budget
If RdError = 0 Then
Mm = 2
For k = 1 To 12
Nrec(Mm) = Pick.replace(Nrec(Mm), 1, k, 0, the_rec(k + 51))
Next k
End If
Return
End Sub



Public Function ta580(logentry As String, database As String, parms As String, template_path As String) As String

' TA580  BURST TRANS.J TO TRANS.J.COPY TO ALLOW POSTING TO GEN.L

Dim Tr_Cash_Rev As Integer, Start_Year As String, trans_rec As String, dummy As String
Dim Acceptclose As String, Vfdate, Vtdate, Usa As Integer, Chq As String
Dim One_Side As String, Inter_Comp As Integer, company As String, Inter_Acs As String, Ct As Long
Dim Total_Chq As Currency, Ct_Chq As Integer, Numv As Integer, I As Integer, Tj As String, Amt As String, Job As String, Ii As Integer, Tc_Type As Integer
Dim Tc_Acct As String, Name As String, Tid As String, Tc_Code As Integer, Tc_Item As String, Tc_Narr As String, X As String, Y As String, Jobrec As String
Dim Max As Integer, Mm As Integer, Deposit As String, newrec As String, Dc_Rec As String, Save_Company As Integer, Fnd As Integer, Dr As Integer, Cr As Integer
Dim temp As String, kk As Long, rderr As Integer, dno As Integer
Dim mylist() As String, pick_cnt As Long, total_items As Long, sentence As String, tj_id As String
Dim No_Inter_Acs As Integer, Acct As String, Grp As String, Cpos As Integer, No_Trans As Integer
Dim fso, textfile, Ans As Integer
Dim nn As Integer, mdb_name As String, the_rec() As String, Dte As String, dte8 As String
Dim mthends() As String, the_drive As String
Dim offset As Integer, yrid As String, ftable As String, wterr As String
Dim numcols As Integer, Amount As Currency, curryear As Integer
Dim the_mth As Integer, thisyr As String, suffix As String

'        THE TRANS.J RECORDS ARE MULTI-VALUED - EACH MULTI-VALUE GIVES
'        RISE TO A gl_trans TRANSACTION
'        TRANS.J TRANSACTIONS ARE DELETED AS THEY ARE REWRITTEN
'        RECORD CASH DEPOSITS ON DAILY.CASH FILE FOR LATER ANALYSIS
'
      the_drive = Left(template_path, InStr(template_path, "\prospect\") - 1) & "\"
      mdb_name = the_drive & "ckashare\gen_l\gen_l.mdb"
      Tr_Cash_Rev = 56
      numcols = 8
      
      Call get_month_ends(mdb_name, curryear, mthends(), Start_Year, Vfdate, Vtdate, One_Side, Acceptclose)
      
      'cur_date = Pick.ICONV(Format$(Now, "DD MMM YY"), "D2")
      'Cphead = Space((132 - Len(pick.extract(account, 1, 1, 1))) / 2) & pick.extract(account, 1, 1, 1)

      'Debt = g_trans_info_array(14) 'does it have debtors - yes usually !

      'Usa = g_trans_info_array( 106) + 0
      Usa = 0
      If Usa Then Chq = "check" Else Chq = "cheque"
      'Jobcost = pick.extract(TRANS_INFO, 32, 0, 0) + 0
      'If Jobcost Then
      '   If d3.d3_readstr(database, Bunit, "DICT JOB.L", "@BUNIT") <> 0 Then Bunit = ""
      'End If
      Inter_Comp = 0
      'Inter_Comp = 1
      'If d3.d3_readstr(database, company, "DICT GEN.L", "@COMPANY") <> 0 Then Inter_Comp = 0
      'If Inter_Comp Then
      '   Inter_Acs = Pick.extract(company, 4, 0, 0) & Chr(253) & Pick.extract(company, 5, 0, 0)
      'End If
'
      sentence = "select trans.j.msa"
      logentry = Pick.replace(logentry, 2, 0, 0, database)
      total_items = d3.d3_select(logentry, sentence, mylist(), pick_cnt, 0, 0)
      Ct = 0
      Total_Chq = 0:  Ct_Chq = 0
      ta580 = d3.rtf_open(logentry, fso, textfile, ".asp")
      temp = "<TABLE cellspacing=1 cellpadding=1 border=1><TR CLASS=top><TH COLSPAN=" & numcols & " ALIGN=CENTER>General Ledger transaction posting audit report " & ourdate(Now) & " " & Time & ". <TR CLASS=TOP><TH colspan=" & numcols & " align=center>Dates must be in range (inclusive) " & ourdate(Vfdate) & " to " & ourdate(Vtdate)
      temp = temp & "<TR CLASS=TOP><TH colspan=" & numcols & " align=center>" & total_items & " transactions."
      'If pick_cnt = -1 Then
      '   Temp = Temp & mylist(0) & "=" & database & "=" & logentry & "=" & pick_cnt
      'End If
      temp = temp & "<TR CLASS=TOP><TH>Details<TH>Code<TH>Job<TH>Account<TH align=right>Amount<TH>Client<TH nowrap>Date<TH>Narrative"
      textfile.WriteLine (temp)
'
   total_items = total_items - 1
   For kk = 0 To total_items
      tj_id = mylist(kk)
      If d3.d3_readstr(database, Tj, "TRANS.J.MSA", tj_id) <> 0 Then GoTo 10000
      
      Ans = Pick.extractint(Tj, 1, 1, 0)
      If Ans > 89 Then GoTo 2599

      If Pick.extract(Tj, 12, 0, 0) <> "" And Pick.extract(Tj, 13, 0, 0) <> "" Then 'foreign currency conversion
         Numv = Pick.dcount(Pick.extract(Tj, 1, 0, 0), Chr(253))
         For I = 1 To Numv
            Tj = Pick.replace(Tj, 4, I, 0, Int(Pick.extractcur(Tj, 13, 0, 0) / 10000 * Pick.extractcur(Tj, 4, I, 0) + 0.5))
         Next I
      End If
      If Pick.dcount(Pick.extract(Tj, 1, 0, 0), Chr(253)) <> Pick.dcount(Pick.extract(Tj, 3, 0, 0), Chr(253)) Or Pick.dcount(Pick.extract(Tj, 1, 0, 0), Chr(253)) <> Pick.dcount(Pick.extract(Tj, 4, 0, 0), Chr(253)) Then
         temp = "<TR><TD>" & tj_id & " transaction rejected because there are not an equal number of codes, accounts and debits/credits"
         GoTo 1015
      End If
      If InStr(Pick.extract(Tj, 4, 0, 0), ".") Then
         temp = "<TR><TD>" & tj_id & " transaction rejected because value has fractions of a cent"
1015     'Release TRANS_J_DATA, tj_id
'$INSERT I.QU.REC
         For I = 1 To Pick.dcount(Pick.extract(Tj, 1, 0, 0), Chr(253))
            Amt = Pick.extractcur(Tj, 4, I, 0): If InStr(Amt, ".") = 0 Then Amt = Pick.oconv(Amt, "MD2")
            Job = Pick.extract(Tj, 2, I, 0): If Job = "0" Then Job = ""
            temp = temp & "<TD>" & Pick.extract(Tj, 1, I, 0) & "<TD>" & Job & "<TD>" & Pick.extract(Tj, 3, I, 0) & "<TD align=right>" & Amt & "<TD>" & Pick.extract(Tj, 5, I, 0) & "<TD nowrap>" & Pick.oconv(Pick.extract(Tj, 7, 0, 0), "D2") & "<TD>" & Pick.extract(Tj, 6, I, 0)
            textfile.WriteLine (temp)
            temp = "<TR><TD>"
         Next I
         GoTo 10000
      End If
      If InStr(Pick.extract(Tj, 4, 0, 0), "-") Then
         temp = "<TR><TD>" & tj_id & " transaction rejected because value is negative"
         GoTo 1015
      End If
      
      Dte = Pick.date_pick_to_vb(CVar(Pick.extractint(Tj, 7, 0, 0)))
      If DateDiff("d", Dte, Start_Year) >= 0 Then 'means start_year > dte
         temp = "<TR><TD>" & tj_id & " transaction rejected because dated " & Dte
         GoTo 1015
      End If
      If (DateDiff("d", Dte, Vfdate) > 0 Or DateDiff("d", Dte, Vtdate) < 0) And Pick.extract(Tj, 1, 0, 0) <> "2" Then
         temp = "<TR><TD>" & tj_id & " transaction rejected because dated " & Dte & ". Must be between " & Vfdate & " and " & Vtdate
         GoTo 1015
      End If
'
' check to see all accounts exist and are open (GL only)
'
      For Ii = 1 To 9999
        If Pick.extract(Tj, 1, Ii, 0) = "" Then Exit For
        Tc_Type = Pick.extractint(Tj, 2, Ii, 0)
        Tc_Acct = Pick.extract(Tj, 3, Ii, 1)
        'check alie???
        If Tc_Type = 0 Then
          If Tc_Acct <> One_Side Or Tc_Acct = "" Then
             If d3.d3_readstr(database, dummy, mdb_name & "\gen_l", Tc_Acct, 13) <> 0 Then
                temp = "<TR><TD>" & tj_id & " transaction rejected because GL account " & Tc_Acct & " does not exist"
                GoTo 1015
             End If
             If Pick.Index(Tc_Acct, ".", 2) = 0 Then
                temp = "<TR><TD>" & tj_id & " transaction rejected because GL account " & Tc_Acct & " does not have two dots"
                GoTo 1015
             End If
             If dummy <> "" Then
                If Acceptclose = "Y" Then
                   temp = "<TR><TD>" & tj_id & " transaction posted to closed GL account " & Tc_Acct
                   textfile.WriteLine (temp)
                Else
                   temp = "<TR><TD>" & tj_id & " transaction rejected because GL account " & Tc_Acct & " is CLOSED"
                   GoTo 1015
                End If
             End If
          End If
        Else
           If d3.d3_readstr(database, temp, "JOB.L", Tc_Acct, 3) <> 0 Then
              temp = "<TR><TD>" & tj_id & " transaction rejected because JOB account " & Tc_Acct & " does not exist"
              textfile.WriteLine (temp)
              'If pick.extract(Bunit, 1, 0, 0) <> "" And Mid$(Tc_Acct, 1, 4) <> "ERR." Then
              '   Tid = pick.field(Tc_Acct, ".", 1)
              '   Call SR_BUJOB(Tid, BU, BUNO)
              '   OPEN "",BUNO & "TRANS_J" TO OT_DATA ELSE GOTO 1015
              '   Delete TRANS_J_DATA, TJ_ID
              '   Call PICKWT(database, OT_DATA, TJ_ID, 3, Tj, 0)
              '   Printer.Print "*** COPIED TO ACCOUNT "; BUNO; " "; BU; " TRANS_J"
              'End If
              GoTo 1015
           End If
        End If
      Next Ii
'
'  LEAVE CHEQUE REQUESTS IN JOURNAL FILE
'
      If Pick.extractint(Tj, 1, 1, 0) = 26 Or Pick.extractint(Tj, 1, 1, 0) = 51 Then
        Ct_Chq = Ct_Chq + 1
        Total_Chq = Total_Chq + Pick.extract(Tj, 4, 1, 0)
        temp = ""
        GoTo 1015
      End If
'
      Call get_the_mth(Dte, mthends(), curryear, the_mth, thisyr, suffix)
      For I = 1 To 9999
         If Pick.extract(Tj, 1, I, 0) = "" Then
            'If Inter_Comp Then GoSub 8000
            GoTo 2599
         End If
         Tc_Code = Pick.extractint(Tj, 1, I, 0)
         Tc_Type = Pick.extractint(Tj, 2, I, 0)
         Tc_Acct = Pick.extract(Tj, 3, I, 0)
         Amount = Pick.extractcur(Tj, 4, I, 0)
         If Tc_Code < 50 Then Amount = -Amount
         
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
         If Tc_Type = 1 Then GoTo 2500          ' JOB COSTING TRANS

2000     If d3.d3_readstr(database, temp, "DICT TRANS.J", tj_id & I & X) <> 0 Then GoTo 2100
         X = X & "X"
         GoTo 2000
2100:
         'If Tc_Code = Tr_Cash_Rev And Debt <> "" Then ' RECORD DEPOSIT ON DAILY.CASH FILE
         '   Deposit = Pick.field(Pick.extract(Tj, 6, 0, 0), "D", 2)
         '   If IsNumeric(Deposit) Then GoSub 7000
         'End If

         If Tc_Acct = One_Side Then GoTo 2500 'mco 20jul00 - do not write one-sided account
         
         trans_rec = Tc_Code & Chr(254) & Chr(254) & Tc_Acct & Chr(254) & Amount & Chr(254) & Tc_Item & Chr(254) & replace(Tc_Narr, Chr(252), " ", , , vbBinaryCompare)

         dte8 = Pick.extract(Tj, 8, 0, 0)
         trans_rec = Pick.replace(trans_rec, 8, 0, 0, Pick.date_pick_to_vb(CVar(dte8)))
         Max = Pick.dcount(Tj, Chr(254))
         For Mm = 9 To Max
            trans_rec = Pick.replace(trans_rec, Mm, 0, 0, Pick.extract(Tj, Mm, 0, 0))
         Next Mm
         
         wterr = post_transaction_gl(database, mdb_name, mthends(), tj_id & "." & I, trans_rec, Amount, Tc_Acct, Tc_Code, Dte, the_mth, thisyr, suffix)
         If wterr <> "0" Then textfile.WriteLine (wterr)
2500   Next I
2599   wterr = d3.d3_delete(database, "TRANS.J.MSA", tj_id)
10000 Next kk

     If Ct_Chq Then
        temp = "<TR><TD>There are " & Chq & "s still to be printed to total value of $" & Pick.oconv(CStr(Total_Chq), "MD2,")
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
'7000  If d3.d3_readstr(database, Dc_Rec, "DAILY.CASH", CStr(cur_date)) <> 0 Then Dc_Rec = ""
''$INSERT I.LOG.UPDATE '|DAILY.CASH|':CUR.DATE 7000 DC.REC
'      If Pick.locate(Deposit, Dc_Rec, 1, 0, 0, dno, "AR") = 0 Then
'         Dc_Rec = Pick.insert(Dc_Rec, dno, 0, 0, Deposit)
'      End If
'      '???Call PICKWT(database, DAILY_CASH_DATA, Cur_Date, 3, Dc_Rec, 0)
'      Return
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
Public Function gl_conversion(logentry As String, drive As String)

Dim glrec As String, Id As String, nn As Integer, aa As Integer, Bb As Integer, Mm As Integer
Dim kk As Long, total_items As Long, mylist() As String, pick_cnt As Long, budget As Currency
Dim database As String, wterr As String, fname As String, glname As String, sentence As String
Dim newrec As String, Dte As String, Prefix As String, yrid As String, acid As String
Dim years As String, Yr As String, Max As Integer, ftable As String, thisyr As String
Dim dbs As database, suffix As String, current_year As String, Attr As Integer
Dim idxNew As Index, picksuf As String, rderr As Integer, Rcode As String, Ct As Integer
Dim tdf As TableDef, testyear As Integer, dtes As String, maxd As Integer, Yy As Integer, basename As String
Dim offset As Integer, code_desc As String, FUTURE As String, future_add As Integer
Dim source_tdf As TableDef, si As Index, newi As Index

   database = Pick.extract(logentry, 2, 0, 0)
   drive = "c:"
   
   ReDim g_trans_info_array(0)
   g_trans_info_array(0) = "TRANS.INFO"
   rderr = d3.d3_readmat(database, g_trans_info_array(), "DICT TRANS.J")
   If UBound(g_trans_info_array) < 140 Then ReDim Preserve g_trans_info_array(140)
   years = g_trans_info_array(140)
   Max = Pick.dcount(years, Chr(253))
   current_year = Right("00" & CStr(CInt(Pick.extract(years, 1, Max, 0)) + 1), 2)
   dtes = g_trans_info_array(9) & Chr(253) & g_trans_info_array(8) & Chr(253) & g_trans_info_array(7) & Chr(253) & g_trans_info_array(33)
   maxd = Pick.dcount(dtes, Chr(253))
'gl_trans, gen_l, grp, grp_class - add _yy to create tables for other years
   Set dbs = OpenDatabase(drive & "\ckashare\gen_l\gen_l.mdb")
   For aa = 2 To Max + 5 'all the years plus 5 more for budgets
      Yr = Pick.extract(years, 1, aa, 0)
      If aa >= Max + 1 Then
         Yr = Pick.extractint(years, 1, Max, 0) + (aa - Max + 1) 'get next years table
         Yr = Right("00" & Yr, 2): FUTURE = Yr
      End If
      fname = "gl_trans": ftable = fname & "_" & Yr:  GoSub new_table
      fname = "gen_l": ftable = fname & "_" & Yr:  GoSub new_table
      fname = "level2": ftable = fname & "_" & Yr:  GoSub new_table
      fname = "level3": ftable = fname & "_" & Yr:  GoSub new_table
      fname = "level2_3": ftable = fname & "_" & Yr:  GoSub new_table
      fname = "gl_rcode": ftable = fname & "_" & Yr:  GoSub new_table
      fname = "gl_rtype": ftable = fname & "_" & Yr:  GoSub new_table
   Next aa
   GoTo done_new_tables
new_table:
         If Yr <> "" Then
            On Error Resume Next
            dbs.Execute "SELECT * Into " & ftable & " From " & fname
            dbs.Close
            Set dbs = OpenDatabase(drive & "\ckashare\gen_l\gen_l.mdb")
            Set tdf = dbs.TableDefs(ftable) 'Opentable(ftable)
            Set source_tdf = dbs.TableDefs(fname)
            
Dim I As Index, F As field, P As property
Dim I1 As Integer, F1 As Integer, P1 As Integer
    ' Copy Indexes
    For I1 = 0 To source_tdf.Indexes.Count - 1
       Set si = source_tdf.Indexes(I1)
       Set newi = tdf.CreateIndex()
        ' Copy Jet Properties
       'On Error Resume Next
       For P1 = 0 To si.Properties.Count - 1
          newi.Properties(P1).value = si.Properties(P1).value
       Next P1
       'On Error GoTo 0
       ' Copy Fields
       For F1 = 0 To si.Fields.Count - 1
          Set F = tdf.CreateField(si.Fields(F1).Name, tdf.Fields(si.Fields(F1).Name).Type)
          newi.Fields.Append F
       Next F1
       tdf.Indexes.Append newi
    Next I1

         End If
         Return
done_new_tables:
   dbs.Close
   On Error GoTo 0

'codes
   For kk = 1 To 89
      code_desc = Pick.extract(g_trans_info_array(3), 1, CInt(kk), 0)
      If Trim(code_desc) <> "" Then
         newrec = code_desc
         If kk < 50 Then newrec = newrec & " (CR)" Else newrec = newrec & " (DR)"
         wterr = d3.d3_writestr(database, drive & "\ckashare\gen_l\gen_l.mdb\codes", CStr(kk), newrec)
      End If
   Next kk

'period ends
   For aa = Max + 2 To 2 Step -1 'all the years
      Yr = Pick.extract(years, 1, aa, 0)
      If aa = Max + 2 Then Yr = Right("00" & CStr(current_year + 1), 2)
      If aa = Max + 1 Then Yr = current_year
      If CInt(Yr) > 80 Then Yr = "19" & Yr Else Yr = "20" & Yr
      For kk = 1 To 12
         Dte = Pick.extract(dtes, 1, maxd - (kk + 12 * (Max + 2 - aa)) + 1, 0)
         newrec = Pick.replace(newrec, 13 - kk, 0, 0, Pick.date_pick_to_vb(CVar(Dte)))
      Next kk
      wterr = d3.d3_writestr(database, drive & "\ckashare\gen_l\gen_l.mdb\monthends", Yr, newrec)
   Next aa

'rcode, rtype
   For aa = 1 To 2
      If aa = 1 Then fname = "RCODE" Else fname = "RTYPE"
      sentence = "SSELECT " & fname
      total_items = d3.d3_select(logentry, sentence, mylist(), pick_cnt, 0, 0) - 1
      For kk = 0 To total_items
         Id = mylist(kk)
         If d3.d3_readstr(database, glrec, fname, Id) = 0 Then
            newrec = Pick.extract(glrec, 1, 0, 0)
            wterr = d3.d3_writestr(database, drive & "\ckashare\gen_l\gen_l.mdb\" & fname, Id, newrec)
         End If
      Next kk
   Next aa

'gl_trans, gl_trans_yy data transfer
   Max = Max + 1 ' last one null is the current gl_trans
   
'GoTo testing

   For aa = 2 To Max
      Yr = Pick.extract(years, 1, aa, 0)
      fname = "gl_trans": ftable = "gl_trans"
      If Yr <> "" Then
         fname = fname & "_" & Yr
         ftable = "gl_trans_" & Yr
      End If
      sentence = "SSELECT " & fname
      total_items = d3.d3_select(logentry, sentence, mylist(), pick_cnt, 0, 0) - 1
      For kk = 0 To total_items
         Id = mylist(kk)
         If d3.d3_readstr(database, glrec, fname, Id) = 0 Then
            newrec = glrec
            If d3.d3_readstr(database, code_desc, "\ckashare\gen_l\gen_l.mdb\codes", Pick.extractint(glrec, 1, 0, 0), 1) <> 0 Then code_desc = Pick.extractint(glrec, 1, 0, 0)
            newrec = Pick.replace(newrec, 10, 0, 0, code_desc)
            Dte = Pick.extract(glrec, 6, 0, 0) 'narrative has m/values - replace with cr/lf
            newrec = Pick.replace(newrec, 6, 0, 0, replace(Dte, Chr(252), " ", , , vbBinaryCompare))
            For nn = 7 To 8
               Dte = Pick.extract(glrec, nn, 0, 0)
               newrec = Pick.replace(newrec, nn, 0, 0, Pick.date_pick_to_vb(CVar(Dte)))
            Next nn
            For nn = 14 To 15
               Dte = Pick.extract(glrec, nn, 0, 0)
               newrec = Pick.replace(newrec, nn, 0, 0, Pick.date_pick_to_vb(CVar(Dte)))
            Next nn
            If Pick.extract(newrec, 14, 0, 0) = "" Then
               newrec = Pick.replace(newrec, 14, 0, 0, Pick.date_pick_to_vb(CVar(Pick.field(Id, ".", 1)))) 'date posted
            End If
            newrec = Pick.replace(newrec, 2, 0, 0, Yr) 'null for current
            Dte = Pick.extract(newrec, 3, 0, 0) 'account number
            newrec = Pick.replace(newrec, 4, 0, 0, Pick.extractcur(newrec, 4, 0, 0) / 100)
            newrec = Pick.replace(newrec, 18, 0, 0, Pick.field(Dte, ".", 1)) 'grp
            newrec = Pick.replace(newrec, 19, 0, 0, Pick.field(Dte, ".", 2)) 'clas
            newrec = Pick.replace(newrec, 20, 0, 0, Pick.field(Dte, ".", 3)) 'subclass
            newrec = Pick.replace(newrec, 21, 0, 0, Pick.field(Dte, ".", 1) & "." & Pick.field(Dte, ".", 2)) 'grp.class
            wterr = d3.d3_writestr(database, drive & "\ckashare\gen_l\gen_l.mdb\" & ftable, Id, newrec)
            If wterr <> "0" Then gl_conversion = wterr: Exit Function
         End If
      Next kk
   Next aa
'gen_l - also gl_rtype,gl_rcode,years
testing:
 For aa = Max + 1 To 2 Step -1
   Yr = Pick.extract(years, 1, aa, 0)
   future_add = 0
   If Yr <> "" Then
      suffix = "_" & Yr: picksuf = "." & Yr: thisyr = Yr
   Else
      If aa = Max + 1 Then 'future year
         future_add = 24
         suffix = "_" & FUTURE: picksuf = "" & Yr: thisyr = FUTURE
      Else
         suffix = "": picksuf = "": thisyr = current_year
      End If
   End If
   fname = "gen.l" & picksuf
   sentence = "SSELECT " & fname
   total_items = d3.d3_select(logentry, sentence, mylist(), pick_cnt, 0, 0) - 1
   
   For kk = 0 To total_items
     Id = mylist(kk)
     If d3.d3_readstr(database, glrec, fname, Id) <> 0 Then GoTo 190
     newrec = Pick.extract(glrec, 1, 0, 0)
     newrec = Pick.replace(newrec, 2, 0, 0, Pick.extract(glrec, 2, 0, 0))
     newrec = Pick.replace(newrec, 4, 0, 0, Pick.field(Id, ".", 1))
     newrec = Pick.replace(newrec, 5, 0, 0, Pick.field(Id, ".", 2))
     newrec = Pick.replace(newrec, 6, 0, 0, Pick.field(Id, ".", 3))
     If Pick.extract(newrec, 6, 0, 0) = "" Then newrec = Pick.replace(newrec, 6, 0, 0, "0")
     newrec = Pick.replace(newrec, 12, 0, 0, Pick.extract(glrec, 10, 0, 0)) 'A L I E
     If Pick.extractcur(glrec, 23, 0, 0) = "1" Then newrec = Pick.replace(newrec, 13, 0, 0, Date) 'Y if closed
     newrec = Pick.replace(newrec, 15, 0, 0, Yr)
     
     If Pick.Index(Id, ".", 2) <> 0 Then
        newrec = Pick.replace(newrec, 3, 0, 0, "3")
        'newrec = Pick.replace(newrec, 14, 0, 0, Pick.extractcur(glrec, 24, 0, 0)) 'GST
        newrec = Pick.replace(newrec, 16, 0, 0, Pick.extractcur(glrec, 4, 0, 0) / 100) 'balance
        newrec = Pick.replace(newrec, 17, 0, 0, Pick.extractcur(glrec, 34, 0, 0) / 100) 'commit
     Else
        If Right(Id, 2) <> ".0" Then
           newrec = Pick.replace(newrec, 3, 0, 0, "2")
           newrec = Pick.replace(newrec, 16, 0, 0, Pick.extractcur(glrec, 3, 0, 0) / 100) 'balance
           newrec = Pick.replace(newrec, 17, 0, 0, Pick.extractcur(glrec, 33, 0, 0) / 100) 'commit
        Else
           newrec = Pick.replace(newrec, 3, 0, 0, "1")
           Id = Pick.field(Id, ".", 1)
           newrec = Pick.replace(newrec, 16, 0, 0, Pick.extractcur(glrec, 3, 0, 0) / 100) 'balance
           newrec = Pick.replace(newrec, 17, 0, 0, Pick.extractcur(glrec, 33, 0, 0) / 100) 'commit
        End If
     End If
     ftable = "gen_l" & suffix
     offset = 25: yrid = Id: GoSub add_values_gl 'write done in subroutine
        
     If Pick.Index(Id, ".", 2) <> 0 Then
        offset = 5
        acid = Pick.field(Id, ".", 2): ftable = "level2" & suffix: GoSub add_values
        acid = Pick.field(Id, ".", 3): ftable = "level3" & suffix: GoSub add_values
        acid = Pick.field(Id, ".", 2) & "." & Pick.field(Id, ".", 3):  ftable = "level2_3" & suffix: GoSub add_values
     End If
     For Bb = 22 To 31 Step 9 'resp code, report type
      If Bb = 22 Then glname = "gl_rcode" Else glname = "gl_rtype"
      ftable = glname & suffix
      For nn = 1 To Pick.dcount(Pick.extract(glrec, Bb, 0, 0), Chr(253))
        Rcode = Pick.extract(glrec, Bb, nn, 0)
        newrec = Rcode
        newrec = Pick.replace(newrec, 2, 0, 0, Id)
        yrid = DateDiff("d", "31/12/67", CVar(Now)) & "." & Timer(): Ct = 0
try_again:
        If d3.d3_readstr(database, Dte, drive & "\ckashare\gen_l\gen_l.mdb\" & ftable, yrid) <> 0 Then
           wterr = d3.d3_writestr(database, drive & "\ckashare\gen_l\gen_l.mdb\" & ftable, yrid, newrec)
        Else 'exists
           yrid = DateDiff("d", "31/12/67", CVar(Now)) & "." & Timer() & "." & (Ct + 1): GoTo try_again
        End If
      Next nn
     Next Bb
190:
   Next kk
 Next aa
 Exit Function
add_values:
'year
     yrid = Pick.extract(glrec, 10, 0, 0) & acid
     If d3.d3_readstr(database, newrec, drive & "\ckashare\gen_l\gen_l.mdb\" & ftable, yrid) <> 0 Then
        newrec = Pick.extract(glrec, 10, 0, 0) 'alie
        newrec = Pick.replace(newrec, 2, 0, 0, acid)
        newrec = Pick.replace(newrec, 3, 0, 0, Pick.extract(glrec, 2, 0, 0))
        newrec = Pick.replace(newrec, 4, 0, 0, thisyr)
     End If
add_values_gl:
'actuals
     For nn = 1 To 12
        newrec = Pick.replace(newrec, offset + nn, 0, 0, Pick.extractcur(newrec, offset + nn, 0, 0) + Pick.extractcur(glrec, 9, nn + future_add, 0) / 100)
        newrec = Pick.replace(newrec, offset, 0, 0, Pick.extractcur(newrec, offset, 0, 0) + Pick.extractcur(glrec, 9, nn + future_add, 0) / 100)
        For Mm = 1 To nn
           newrec = Pick.replace(newrec, offset + 38 + nn, 0, 0, Pick.extractcur(newrec, offset + 38 + nn, 0, 0) + Pick.extractcur(glrec, 9, Mm + future_add, 0) / 100)
        Next Mm
     Next nn
'commits
     For nn = 1 To 12
        newrec = Pick.replace(newrec, offset + 13 + nn, 0, 0, Pick.extractcur(newrec, offset + 13 + nn, 0, 0) + Pick.extractcur(glrec, 35, nn + future_add, 0) / 100)
        newrec = Pick.replace(newrec, offset + 13, 0, 0, Pick.extractcur(newrec, offset + 13, 0, 0) + Pick.extractcur(glrec, 35, nn + future_add, 0) / 100)
        For Mm = 1 To nn
           newrec = Pick.replace(newrec, offset + 50 + nn, 0, 0, Pick.extractcur(newrec, offset + 50 + nn, 0, 0) + Pick.extractcur(glrec, 35, Mm + future_add, 0) / 100)
        Next Mm
     Next nn
'budgets
     If Pick.extract(glrec, 7, 0, 0) = "A" Then 'annual budget
        glrec = Pick.replace(glrec, 8, 0, 0, Pick.extract(glrec, 8, 1, 0)) 'clear last next year annual budgets
     End If
     For nn = 1 To 12
        newrec = Pick.replace(newrec, offset + 26 + nn, 0, 0, Pick.extractcur(newrec, offset + 26 + nn, 0, 0) + Pick.extractcur(glrec, 8, nn + future_add, 0))
        newrec = Pick.replace(newrec, offset + 26, 0, 0, Pick.extractcur(newrec, offset + 26, 0, 0) + Pick.extractcur(glrec, 8, nn + future_add, 0))
        For Mm = 1 To nn
           newrec = Pick.replace(newrec, offset + 62 + nn, 0, 0, Pick.extractcur(newrec, offset + 62 + nn, 0, 0) + Pick.extractcur(glrec, 8, Mm + future_add, 0))
        Next Mm
     Next nn
     wterr = d3.d3_writestr(database, drive & "\ckashare\gen_l\gen_l.mdb\" & ftable, yrid, newrec)
     If wterr <> "0" Then MsgBox wterr & "=" & yrid & "=" & newrec
     Return

End Function
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
     ta511 = d3.rtf_open(logentry, fso, textfile, ".asp")
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
     textfile.Close
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
Public Function ta511_validate(logentry As String, reptype As String, grouprange As String, Sdate As String) As String

Dim database As String, rderr As String, rangeind As Long, sgrp As String, egrp As String, pararray() As String

pararray() = Split(logentry, Chr(254))
database = pararray(1)
If UBound(g_trans_info_array) = 0 Then
    g_trans_info_array(0) = "TRANS.INFO"
    rderr = d3.d3_readmat(database, g_trans_info_array(), "DICT TRANS.J")
End If
If reptype <> "A" And reptype <> "B" And reptype <> "C" Then
    ta511_validate = "1"
    Exit Function
End If

If grouprange <> "" Then
    rangeind = InStr(1, grouprange, "-", vbBinaryCompare)
    If rangeind Then
        sgrp = Trim(Left(grouprange, rangeind - 1))
        egrp = Trim(Mid(grouprange, rangeind + 1))
        If Not (IsNumeric(sgrp)) Or Not (IsNumeric(egrp)) Then
            ta511_validate = "2"
            Exit Function
        End If
        If Not (egrp > sgrp) Then
            ta511_validate = "2"
            Exit Function
        End If
    Else
        If Not (IsNumeric(grouprange)) Then
            ta511_validate = "2"
            Exit Function
        End If
    End If
End If

If Pick.ICONV(Sdate, "D2") < g_trans_info_array(20) Then
    Sdate = Pick.oconv(g_trans_info_array(20), "D2")
    ta511_validate = "3" & Sdate
    Exit Function
End If
ta511_validate = "0"
    

End Function


Public Function TA514(logentry As String, Sdate As String, Edate As String, template As String, ExcelPath As String) As String

Dim Gst_Accs As String, Cono As Integer, Inp_Gst_Acc As String, Out_Gst_Acc As String, Wh_Tax_Acc As String
Dim Inp_Gst_Name, Out_Gst_Name, Wh_Tax_Name, Am As String, Vm As String, Svm As String
Dim Tc, Swgst, Sngst, Sales_Gst, Cngst, Cwgst, Credit_Gst, Rngst
Dim Rwgst, Receipt_Gst, Pngsta, Pwgsta, Pngst, Pwgst, Pur_Gst
Dim Crngsta, Crwgsta, Crngst, Crwgst, Cred_Gst, Payngsta, Paywgsta
Dim Payngst, Paywgst, Pay_Gst, Canc_Rec, Canc_Receipt_val, Canc_Receipt_Gst, Rateswgst
Dim Canc_Rec_pp, Canc_Receipt_val_pp, Canc_Receipt_Gst_pp
Dim Ratesngst, Rates_Gst, Scr, Scr2, Scr3, Scr4, Valid
Dim Errflg, Sent As String, Eof, Work_Gst, No_Lines, I As Integer, Line_Amt
Dim No_Accts, Accno As String, Canc_Receipt_Msg As String, Total_Sales, Total_Gst
Dim Cont, Ans, Acc As String, Asset, Baccs As String, No_Baccs, xx As Integer, Bacc, Chqlist
Dim No_Accs, Creditor, Instr, Total_Asset_Pur, Total_Other_Pur
Dim Total_Pur_Gst, GROSS_AMT, gst_amt, Inp_Gst_Dr, Inp_Gst_Cr
Dim Out_Gst_Dr, Out_Gst_Cr, Wh_Tax_Dr, Wh_Tax_Cr, tr_code, Tfr_Item
Dim Flags, Pass, Io As String, FID As String, Inv_Gst
Dim InRec As String, logarray() As String, Trans_Info As String
Dim total_items As Long, pick_cnt As Long, mylist() As String, j As Long
Dim tempstr As String
Dim fso, ExcelFileName, fileno, A
Dim IntStart
' Get Total Sales & GST Figures for BAS
'
     logarray = Split(logentry, Chr(254))
     If d3.d3_readstr(logarray(1), Gst_Accs, "GST.CONTROL", "GST.ACCS") <> 0 Then Gst_Accs = ""
     If d3.d3_readstr(logarray(1), Trans_Info, "DICT TRANS.J", "TRANS.INFO") <> 0 Then Trans_Info = ""
     Cono = 1
     Inp_Gst_Acc = Pick.extract(Gst_Accs, 1, Cono, 0)
     Out_Gst_Acc = Pick.extract(Gst_Accs, 2, Cono, 0)
     Wh_Tax_Acc = Pick.extract(Gst_Accs, 3, Cono, 0)
     If d3.d3_readstr(logarray(1), InRec, "GEN.L", Inp_Gst_Acc) <> 0 Then
        Inp_Gst_Name = ""
     Else
        Inp_Gst_Name = Pick.extract(InRec, 2, 0, 0)
     End If
     If d3.d3_readstr(logarray(1), InRec, "GEN.L", Out_Gst_Acc) <> 0 Then
        Out_Gst_Name = ""
     Else
        Out_Gst_Name = Pick.extract(InRec, 2, 0, 0)
     End If
     If d3.d3_readstr(logarray(1), InRec, "GEN.L", Wh_Tax_Acc) <> 0 Then
        Wh_Tax_Name = ""
     Else
        Wh_Tax_Name = Pick.extract(InRec, 2, 0, 0)
     End If
     Am = Chr(254): Vm = Chr(253): Svm = Chr(252)
     Tc = Chr(9)
     IntStart = Pick.ICONV(Sdate, "D2")
     Swgst = 0: Sngst = 0: Sales_Gst = 0
     Cngst = 0: Cwgst = 0: Credit_Gst = 0
     Rngst = 0: Rwgst = 0: Receipt_Gst = 0
     Pngsta = 0: Pwgsta = 0: Pngst = 0: Pwgst = 0: Pur_Gst = 0
     Crngsta = 0: Crwgsta = 0: Crngst = 0: Crwgst = 0: Cred_Gst = 0
     Payngsta = 0: Paywgsta = 0: Payngst = 0: Paywgst = 0: Pay_Gst = 0
     Canc_Rec = 0: Canc_Receipt_val = 0: Canc_Receipt_Gst = 0
     Canc_Rec_pp = 0: Canc_Receipt_val_pp = 0: Canc_Receipt_Gst_pp = 0
     Rateswgst = 0: Ratesngst = 0: Rates_Gst = 0
'
'
' Get Totals of Invoices for Period
'
     Sdate = Chr(34) & Sdate & Chr(34)
     Edate = Chr(34) & Edate & Chr(34)
     Sent = "SELECT INVOICE WITH @LDATE >= " & Sdate & " AND WITH @LDATE <= " & Edate
     total_items = d3.d3_select(logentry, Sent, mylist(), pick_cnt, 0, 0)
     For j = 0 To total_items - 1
    If d3.d3_readstr(logarray(1), Io, "INVOICE", mylist(j)) = 0 Then
           Work_Gst = 0
           No_Lines = Pick.dcount(Pick.extract(Io, 17, 0, 0), Vm)
           For I = 1 To No_Lines
              Work_Gst = Pick.extract(Io, 17, I, 0)
              Line_Amt = Int(Pick.extract(Io, 13, I, 0)) * Int(Pick.extract(Io, 15, I, 0))
              If Work_Gst = 0 Then
                 Sngst = Sngst + Line_Amt
              Else
                 Swgst = Swgst + Line_Amt
                 Sales_Gst = Sales_Gst + Work_Gst
              End If
           Next I
        End If
     Next j
'
' Get Totals of Credits
'
     Sent = "SELECT CREDIT WITH @LDATE >= " & Sdate & " AND WITH @LDATE <= " & Edate
     total_items = d3.d3_select(logentry, Sent, mylist(), pick_cnt, 0, 0)
     For j = 0 To total_items - 1
    If d3.d3_readstr(logarray(1), Io, "CREDIT", mylist(j)) = 0 Then
           Work_Gst = 0
           No_Lines = Pick.dcount(Pick.extract(Io, 17, 0, 0), Vm)
           For I = 1 To No_Lines
              Work_Gst = Pick.extract(Io, 17, I, 0)
              Line_Amt = Int(Pick.extract(Io, 13, I, 0)) * Int(Pick.extract(Io, 15, I, 0))
              If Work_Gst = 0 Then
                 Cngst = Cngst + Line_Amt
              Else
                 Cwgst = Cwgst + Line_Amt
                 Credit_Gst = Credit_Gst + Work_Gst
              End If
           Next I
        End If
     Next j
'
' Get Totals of Cash Receipts
'
     Sent = "SELECT CASH WITH DATE >= " & Sdate & " AND WITH DATE <= " & Edate
     Sent = Sent & " OR WITH DHCHQ >= " & Sdate & " AND WITH DHCHQ <= " & Edate
     total_items = d3.d3_select(logentry, Sent, mylist(), pick_cnt, 0, 0)
     For j = 0 To total_items - 1
    If d3.d3_readstr(logarray(1), Io, "CASH", mylist(j)) = 0 Then
           Work_Gst = 0
           No_Accts = Pick.dcount(Pick.extract(Io, 11, 0, 0), Vm)
           For I = 1 To No_Accts
              If Pick.extract(Io, 11, I, 0) = Out_Gst_Acc Then
                 Work_Gst = Work_Gst + Pick.extract(Io, 12, I, 0)
              End If
           Next I
           If Pick.extract(Io, 5, 0, 0) <> "" Then
              If Pick.extract(Io, 10, 0, 0) + 1 > IntStart Then
                 Canc_Rec = Canc_Rec + 1
                 For I = 1 To No_Accts
                    Accno = Pick.extract(Io, 11, I, 0)
                    If Accno <> Out_Gst_Acc Then
                       If d3.d3_readstr(logarray(1), InRec, "GEN.L", Accno) = 0 Then
                          Canc_Receipt_val = Canc_Receipt_val + Pick.extract(Io, 12, I, 0)
                       End If
                    End If
                 Next I
                 Canc_Receipt_Gst = Canc_Receipt_Gst + Work_Gst
              Else
                 Canc_Rec_pp = Canc_Rec_pp + 1
                 For I = 1 To No_Accts
                    Accno = Pick.extract(Io, 11, I, 0)
                    If Accno <> Out_Gst_Acc Then
                       If d3.d3_readstr(logarray(1), InRec, "GEN.L", Accno) = 0 Then
                          Canc_Receipt_val_pp = Canc_Receipt_val_pp + Pick.extract(Io, 12, I, 0)
                       End If
                    End If
                 Next I
                 Canc_Receipt_Gst_pp = Canc_Receipt_Gst_pp + Work_Gst
              End If
           Else
              For I = 1 To No_Accts
                 Accno = Pick.extract(Io, 11, I, 0)
                 If Accno <> Out_Gst_Acc Then
                    If d3.d3_readstr(logarray(1), InRec, "GEN.L", Accno) = 0 Then
                       If Work_Gst = 0 Then
                          Rngst = Rngst + Pick.extract(Io, 12, I, 0)
                       Else
                          Rwgst = Rwgst + Pick.extract(Io, 12, I, 0)
                       End If
                    End If
                 End If
              Next I
              Receipt_Gst = Receipt_Gst + Work_Gst
           End If
        End If
     Next j
'
' Calculate Total Sales
'
     Total_Sales = (Swgst + Sngst + Rngst + Rwgst) - (Cngst + Cwgst)
     Total_Gst = Sales_Gst + Receipt_Gst - Credit_Gst
'
' Get Totals of Creditor's Invoices
'
     Sent = "SELECT CR.INV WITH LEDG.DATE >= " & Sdate & " AND WITH LEDG.DATE <= " & Edate
     total_items = d3.d3_select(logentry, Sent, mylist(), pick_cnt, 0, 0)
     For j = 0 To total_items - 1
    If d3.d3_readstr(logarray(1), Io, "CR.INV", mylist(j)) = 0 Then
           No_Lines = Pick.extract(Io, 9, 0, 0)
           For I = 1 To No_Lines
              Work_Gst = Pick.extract(Io, 36, I, 0)
              Line_Amt = Int(Pick.extract(Io, 14, I, 0))
              Acc = Pick.extract(Io, 10, I, 0)
              Asset = 0
              If InStr(Acc, ".") Then
                 If d3.d3_readstr(logarray(1), InRec, "GEN.L", Acc) = 0 Then
                    If Pick.extract(InRec, 1, 0, 0) = "B" And Pick.extract(InRec, 10, 0, 0) = "A" Then Asset = 1
                 End If
              End If
              If Asset Then
                 If Work_Gst = 0 Then
                    Pngsta = Pngsta + Line_Amt
                 Else
                    Pwgsta = Pwgsta + Line_Amt
'                    PUR.GST = PUR.GST + WORK.GST
                 End If
              Else
                 If Work_Gst = 0 Then
                    Pngst = Pngst + Line_Amt
                 Else
                    Pwgst = Pwgst + Line_Amt
'                    PUR.GST = PUR.GST + WORK.GST
                 End If
              End If
           Next I
           Inv_Gst = Pick.extract(Io, 32, 0, 0)
           If Inv_Gst = "" Then Inv_Gst = "0"
           Pur_Gst = Pur_Gst + Inv_Gst
        End If
    Next j
'
' Get Totals of Creditor's Credit Notes
'
     Sent = "SELECT CR.CREDIT WITH LEDG.DATE >= " & Sdate & " AND WITH LEDG.DATE <= " & Edate
     total_items = d3.d3_select(logentry, Sent, mylist(), pick_cnt, 0, 0)
     For j = 0 To total_items - 1
    If d3.d3_readstr(logarray(1), Io, "CR.CREDIT", mylist(j)) = 0 Then
           No_Lines = Pick.extract(Io, 9, 0, 0)
           For I = 1 To No_Lines
              Work_Gst = Pick.extract(Io, 36, I, 0)
              Line_Amt = Int(Pick.extract(Io, 14, I, 0))
              Acc = Pick.extract(Io, 10, I, 0)
              Asset = 0
              If InStr(Acc, "_") Then
                 If d3.d3_readstr(logarray(1), InRec, "GEN.L", Acc) = 0 Then
                    If Pick.extract(InRec, 1, 0, 0) = "B" And Pick.extract(InRec, 10, 0, 0) = "A" Then Asset = 1
                 End If
              End If
              If Asset Then
                 If Work_Gst = 0 Then
                    Crngsta = Crngsta + Line_Amt
                 Else
                    Crwgsta = Crwgsta + Line_Amt
                    Cred_Gst = Cred_Gst + Work_Gst
                 End If
              Else
                 If Work_Gst = 0 Then
                    Crngst = Crngst + Line_Amt
                 Else
                    Crwgst = Crwgst + Line_Amt
                    Cred_Gst = Cred_Gst + Work_Gst
                 End If
              End If
           Next I
        End If
     Next j
'
' Get Totals of Payments for Goods, not to CREDITORS or DEBTORS
'
     Baccs = Pick.extract(Trans_Info, 4, 0, 0) & Vm & Pick.extract(Trans_Info, 31, 0, 0)
     No_Baccs = Pick.dcount(Baccs, Vm)
     For xx = 1 To No_Baccs
        Bacc = Pick.extract(Baccs, 1, xx, 0)
        If xx = 1 Then FID = "CHQ.REC" Else FID = "CHQ.REC" & xx
        Sent = "SELECT " & FID & " USING DICT CHQ_REC WITH DATE_ISSUED >= " & Sdate & " AND WITH DATE_ISSUED <= " & Edate
        Sent = Sent & " AND WITH CODE = "" AND WITH KEY <> " & Chr(34) & "D]" & Chr(34) & " AND WITH KEY <> " & Chr(34) & "S]" & Chr(34) & " AND WITH KEY <> " & Chr(34) & "F]" & Chr(34)
'       SENT = SENT & " AND WITH CODE = "" AND WITH KEY <> "D]" AND WITH KEY <> "S]" AND WITH KEY <> "F]" & "
        Chqlist = ""
        total_items = d3.d3_select(logentry, Sent, mylist(), pick_cnt, 0, 0)
        For j = 0 To total_items - 1
           If d3.d3_readstr(logarray(1), Io, FID, mylist(j)) = 0 Then
                 No_Accs = Pick.dcount(Pick.extract(Io, 7, 0, 0), Vm)
                 Creditor = 0
                 For I = 1 To No_Accs
                    Acc = Pick.extract(Io, 7, I, 0)
                    If InStr(Acc, ".") = 0 Then Creditor = 1
                 Next I
                 Work_Gst = 0
                 If Creditor = 0 Then
                    For I = 1 To No_Accs
                       Acc = Pick.extract(Io, 7, I, 0)
                       If Acc = Pick.extract(Gst_Accs, 1, 0, 0) Then
                          Work_Gst = Work_Gst + Pick.extract(Io, 8, I, 0)
                       End If
                    Next I
                    For I = 1 To No_Accs
                       Acc = Pick.extract(Io, 7, I, 0)
                       If Acc <> Pick.extract(Gst_Accs, 1, 0, 0) And Acc <> Bacc Then
                          If d3.d3_readstr(logarray(1), InRec, "GEN.L", Acc) = 0 Then
                             If Pick.extract(InRec, 1, 0, 0) = "B" And Pick.extract(InRec, 10, 0, 0) = "A" Then
                                If Work_Gst = 0 Then
                                   Payngsta = Payngsta + Pick.extract(Io, 8, I, 0)
                                Else
                                   Paywgsta = Paywgsta + Pick.extract(Io, 8, I, 0)
                                End If
                             Else
                                If Work_Gst = 0 Then
                                   Payngst = Payngst + Pick.extract(Io, 8, I, 0)
                                Else
                                   Paywgst = Paywgst + Pick.extract(Io, 8, I, 0)
                                End If
                             End If
                          End If
                       End If
                    Next I
                 End If
              End If
              Pay_Gst = Pay_Gst + Work_Gst
        Next j
     Next xx
'
' Calculate Total Purchases
'
     Total_Asset_Pur = (Pngsta + Pwgsta + Payngsta + Paywgsta) - (Crngsta + Crwgsta)
     Total_Other_Pur = (Pngst + Pwgst + Payngst + Paywgst) - (Crngst + Crwgst)
     Total_Pur_Gst = (Pur_Gst + Pay_Gst) - Cred_Gst
'
' Calculate Rates Values
'
     Sent = "SELECT RATES WITH DATE.GL >= " & Sdate & " AND WITH DATE.GL <= " & Edate
     total_items = d3.d3_select(logentry, Sent, mylist(), pick_cnt, 0, 0)
     For j = 0 To total_items - 1
    If d3.d3_readstr(logarray(1), Io, "RATES", mylist(j)) = 0 Then
           GROSS_AMT = Pick.extract(Io, 2, 0, 0)
           If GROSS_AMT = "" Then GROSS_AMT = 0
           gst_amt = Pick.extract(Io, 9, 2, 0)
           If gst_amt = "" Then gst_amt = 0
           If gst_amt <> 0 Then
              Rateswgst = Rateswgst + GROSS_AMT
              Rates_Gst = Rates_Gst + gst_amt
           Else
              Ratesngst = Ratesngst + GROSS_AMT
           End If
        End If
     Next j
'
' Total Journals to GST Control Accounts
'
     Sent = "SELECT JOURNAL WITH DATE >= " & Sdate & " AND WITH DATE <= " & Edate & " AND WITH ACCT = " & Chr(34) & Inp_Gst_Acc & Chr(34) & " " & Chr(34) & Out_Gst_Acc & Chr(34) & " " & Chr(34) & Wh_Tax_Acc & Chr(34)
     Inp_Gst_Dr = 0: Inp_Gst_Cr = 0
     Out_Gst_Dr = 0: Out_Gst_Cr = 0
     Wh_Tax_Dr = 0: Wh_Tax_Cr = 0
     total_items = d3.d3_select(logentry, Sent, mylist(), pick_cnt, 0, 0)
     For j = 0 To total_items - 1
    If d3.d3_readstr(logarray(1), Io, "JOURNAL", mylist(j)) = 0 Then
           No_Accs = Pick.dcount(Pick.extract(Io, 3, 0, 0), Vm)
           For I = 1 To No_Accs
              Accno = Pick.extract(Io, 3, I, 0)
              tr_code = Pick.extract(Io, 1, I, 0)
              Select Case Accno
              Case Inp_Gst_Acc
                 If tr_code >= 50 Then
                    Inp_Gst_Dr = Inp_Gst_Dr + Pick.extract(Io, 2, I, 0)
                 Else
'                    INP.GST.CR = INP.GST.CR + IO<2,4>
                    Inp_Gst_Cr = Inp_Gst_Cr + Pick.extract(Io, 4, I, 0)
                 End If
              Case Out_Gst_Acc
                 If tr_code >= 50 Then
                    Out_Gst_Dr = Out_Gst_Dr + Pick.extract(Io, 2, I, 0)
                 Else
'                    OUT.GST.CR = OUT.GST.CR + IO<2,4>
                    Out_Gst_Cr = Out_Gst_Cr + Pick.extract(Io, 4, I, 0)
                 End If
              Case Wh_Tax_Acc
                 If tr_code >= 50 Then
                    Wh_Tax_Dr = Wh_Tax_Dr + Pick.extract(Io, 2, I, 0)
                 Else
'                    WH.TAX.CR = WH.TAX.CR + IO<2,4>
                    Wh_Tax_Cr = Wh_Tax_Cr + Pick.extract(Io, 4, I, 0)
                 End If
              End Select
           Next I
        End If
     Next j
'
     If d3.ReadDosFile(template, tempstr) = True Then
        tempstr = replace(tempstr, "@@saleswithgst@@", Pick.oconv(CStr(Swgst), "MD2"))
        tempstr = replace(tempstr, "@@salesgst@@", Pick.oconv(CStr(Sales_Gst), "MD2"))
        tempstr = replace(tempstr, "@@salesnogst@@", Pick.oconv(CStr(Sngst), "MD2"))
        tempstr = replace(tempstr, "@@salessum@@", Pick.oconv(CStr(Swgst + Sngst), "MD2"))
        tempstr = replace(tempstr, "@@salesgstsum@@", Pick.oconv(CStr(Sales_Gst), "MD2"))
        tempstr = replace(tempstr, "@@creditswithgst@@", Pick.oconv(CStr(Cwgst), "MD2"))
        tempstr = replace(tempstr, "@@creditsgst@@", Pick.oconv(CStr(Credit_Gst), "MD2"))
        tempstr = replace(tempstr, "@@creditsnogst@@", Pick.oconv(CStr(Cngst), "MD2"))
        tempstr = replace(tempstr, "@@creditssum@@", Pick.oconv(CStr(Cwgst + Cngst), "MD2"))
        tempstr = replace(tempstr, "@@creditsgstsum@@", Pick.oconv(CStr(Credit_Gst), "MD2"))
        tempstr = replace(tempstr, "@@receiptswithgst@@", Pick.oconv(CStr(Rwgst), "MD2"))
        tempstr = replace(tempstr, "@@receiptsgst@@", Pick.oconv(CStr(Receipt_Gst), "MD2"))
        tempstr = replace(tempstr, "@@receiptsnogst@@", Pick.oconv(CStr(Rngst), "MD2"))
        tempstr = replace(tempstr, "@@receiptssum@@", Pick.oconv(CStr(Rwgst + Rngst), "MD2"))
        tempstr = replace(tempstr, "@@receiptsgstsum@@", Pick.oconv(CStr(Receipt_Gst), "MD2"))
        tempstr = replace(tempstr, "@@totalsales@@", Pick.oconv(CStr(Total_Sales), "MD2"))
        tempstr = replace(tempstr, "@@totalsalesgst@@", Pick.oconv(CStr(Total_Gst), "MD2"))
        tempstr = replace(tempstr, "@@cancreceipts@@", CStr(Canc_Rec))
        tempstr = replace(tempstr, "@@cancreceiptsval@@", Pick.oconv(CStr(Canc_Receipt_val), "MD2"))
        tempstr = replace(tempstr, "@@cancreceiptgst@@", Pick.oconv(CStr(Canc_Receipt_Gst), "MD2"))
        tempstr = replace(tempstr, "@@cancreceiptspp@@", CStr(Canc_Rec_pp))
        tempstr = replace(tempstr, "@@cancreceiptsvalpp@@", Pick.oconv(CStr(Canc_Receipt_val_pp), "MD2"))
        tempstr = replace(tempstr, "@@cancreceiptgstpp@@", Pick.oconv(CStr(Canc_Receipt_Gst_pp), "MD2"))
        tempstr = replace(tempstr, "@@cappurchwithgst@@", Pick.oconv(CStr(Pwgsta), "MD2"))
        tempstr = replace(tempstr, "@@othpurchwithgst@@", Pick.oconv(CStr(Pwgst), "MD2"))
        tempstr = replace(tempstr, "@@purchgst@@", Pick.oconv(CStr(Pur_Gst), "MD2"))
        tempstr = replace(tempstr, "@@cappurchnogst@@", Pick.oconv(CStr(Pngsta), "MD2"))
        tempstr = replace(tempstr, "@@othpurchnogst@@", Pick.oconv(CStr(Pngsta), "MD2"))
        tempstr = replace(tempstr, "@@cappurchsum@@", Pick.oconv(CStr(Pwgsta + Pngsta), "MD2"))
        tempstr = replace(tempstr, "@@othpurchsum@@", Pick.oconv(CStr(Pwgst + Pngst), "MD2"))
        tempstr = replace(tempstr, "@@purchgstsum@@", Pick.oconv(CStr(Pur_Gst), "MD2"))
        tempstr = replace(tempstr, "@@capcredwithgst@@", Pick.oconv(CStr(Crwgsta), "MD2"))
        tempstr = replace(tempstr, "@@othcredwithgst@@", Pick.oconv(CStr(Crwgst), "MD2"))
        tempstr = replace(tempstr, "@@purcredgst@@", Pick.oconv(CStr(Cred_Gst), "MD2"))
        tempstr = replace(tempstr, "@@capcrednogst@@", Pick.oconv(CStr(Crngsta), "MD2"))
        tempstr = replace(tempstr, "@@othcrednogst@@", Pick.oconv(CStr(Crngsta), "MD2"))
        tempstr = replace(tempstr, "@@capcredsum@@", Pick.oconv(CStr(Crwgsta + Crngsta), "MD2"))
        tempstr = replace(tempstr, "@@othcredsum@@", Pick.oconv(CStr(Crwgst + Crngst), "MD2"))
        tempstr = replace(tempstr, "@@purcredgstsum@@", Pick.oconv(CStr(Cred_Gst), "MD2"))
        tempstr = replace(tempstr, "@@cappaywithgst@@", Pick.oconv(CStr(Paywgsta), "MD2"))
        tempstr = replace(tempstr, "@@othpaywithgst@@", Pick.oconv(CStr(Paywgst), "MD2"))
        tempstr = replace(tempstr, "@@paygst@@", Pick.oconv(CStr(Pay_Gst), "MD2"))
        tempstr = replace(tempstr, "@@cappaynogst@@", Pick.oconv(CStr(Payngsta), "MD2"))
        tempstr = replace(tempstr, "@@othpaynogst@@", Pick.oconv(CStr(Payngst), "MD2"))
        tempstr = replace(tempstr, "@@cappaysum@@", Pick.oconv(CStr(Paywgsta + Payngsta), "MD2"))
        tempstr = replace(tempstr, "@@othpaysum@@", Pick.oconv(CStr(Paywgst + Payngst), "MD2"))
        tempstr = replace(tempstr, "@@paygstsum@@", Pick.oconv(CStr(Pay_Gst), "MD2"))
        tempstr = replace(tempstr, "@@totalcappurch@@", Pick.oconv(CStr(Total_Asset_Pur), "MD2"))
        tempstr = replace(tempstr, "@@totalothpurch@@", Pick.oconv(CStr(Total_Other_Pur), "MD2"))
        tempstr = replace(tempstr, "@@totalpurchgst@@", Pick.oconv(CStr(Total_Pur_Gst), "MD2"))
        tempstr = replace(tempstr, "@@rateswithgst@@", Pick.oconv(CStr(Rateswgst), "MD2"))
        tempstr = replace(tempstr, "@@ratesgst@@", Pick.oconv(CStr(Rates_Gst), "MD2"))
        tempstr = replace(tempstr, "@@ratesnogst@@", Pick.oconv(CStr(Ratesngst), "MD2"))
        tempstr = replace(tempstr, "@@ratessum@@", Pick.oconv(CStr(Rateswgst + Ratesngst), "MD2"))
        tempstr = replace(tempstr, "@@ratesgstsum@@", Pick.oconv(CStr(Rates_Gst), "MD2"))
        tempstr = replace(tempstr, "@@gstinputacc@@", Inp_Gst_Name)
        tempstr = replace(tempstr, "@@gstinputdebit@@", Pick.oconv(CStr(Inp_Gst_Dr), "MD2"))
        tempstr = replace(tempstr, "@@gstinputcredit@@", Pick.oconv(CStr(Inp_Gst_Cr), "MD2"))
        tempstr = replace(tempstr, "@@gstoutputacc@@", Out_Gst_Name)
        tempstr = replace(tempstr, "@@gstoutputdebit@@", Pick.oconv(CStr(Out_Gst_Dr), "MD2"))
        tempstr = replace(tempstr, "@@gstoutputcredit@@", Pick.oconv(CStr(Out_Gst_Cr), "MD2"))
        tempstr = replace(tempstr, "@@withholdingacc@@", Wh_Tax_Name)
        tempstr = replace(tempstr, "@@withholdingdebit@@", Pick.oconv(CStr(Wh_Tax_Dr), "MD2"))
        tempstr = replace(tempstr, "@@withholdingcredit@@", Pick.oconv(CStr(Wh_Tax_Cr), "MD2"))
        Set fso = New Scripting.FileSystemObject
        fileno = 0
        ExcelFileName = ExcelPath & "\BAS" & CStr(fileno) & ".xls"
        Do While fso.FileExists(ExcelFileName)
            fileno = fileno + 1
            ExcelFileName = ExcelPath & "\BAS" & CStr(fileno) & ".xls"
        Loop
        Set A = fso.CreateTextFile(ExcelFileName, True)
        A.Write (tempstr)
        A.Close
        tempstr = replace(tempstr, "@@xlfile@@", "BAS" & CStr(fileno), 1, 3)
        TA514 = tempstr
    Else
'
        Scr = "<TR>" & vbCr & "<TD>"
        Scr = Scr & "SALES" & "<TD>" & vbCr & "<TD>" & "GST" & vbCr
        Scr = Scr & "<TR>" & vbCr & "<TD>" & "Sales with GST Charged" & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Swgst), "MD2"), 12) & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Sales_Gst), "MD2"), 12) & vbCr
        Scr = Scr & "<TR>" & vbCr & "<TD>" & "Sales with No GST Charged" & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Sngst), "MD2"), 12) & vbCr
        Scr = Scr & "<TR>" & vbCr & "<TD> <TD>" & Right(Space(12) & Pick.oconv(CStr(Swgst + Sngst), "MD2"), 12) & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Sales_Gst), "MD2"), 12) & vbCr
        Scr = Scr & "<TR>" & vbCr & "<TD>" & "LESS" & vbCr
        Scr = Scr & "<TR>" & vbCr & "<TD>" & "Credits with GST" & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Cwgst), "MD2"), 12) & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Credit_Gst), "MD2"), 12) & vbCr
        Scr = Scr & "<TR>" & vbCr & "<TD>" & "Credits with No GST" & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Cngst), "MD2"), 12) & vbCr
        Scr = Scr & "<TR>" & vbCr & "<TD> <TD>" & Right(Space(12) & Pick.oconv(CStr(Cwgst + Cngst), "MD2"), 12) & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Credit_Gst), "MD2"), 12) & vbCr
        Scr = Scr & "<TR>" & vbCr & "<TD>" & "ADD" & vbCr
        Scr = Scr & "<TR>" & vbCr & "<TD>" & "Cash Receipts with GST" & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Rwgst), "MD2"), 12) & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Receipt_Gst), "MD2"), 12) & vbCr
        Scr = Scr & "<TR>" & vbCr & "<TD>" & "Cash Receipts with No GST" & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Rngst), "MD2"), 12) & vbCr
        Scr = Scr & "<TR>" & vbCr & "<TD> <TD>" & Right(Space(12) & Pick.oconv(CStr(Rwgst + Rngst), "MD2"), 12) & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Receipt_Gst), "MD2"), 12) & vbCr
        Scr = Scr & "<TR>" & vbCr & "<TD>" & "TOTAL SALES" & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Total_Sales), "MD2"), 12) & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Total_Gst), "MD2"), 12) & vbCr
'
        Scr = Scr & "<TR>" & vbCr & "<TD>"
        Scr = Scr & "CAPITAL" & "<TD>" & "OTHER" & "<TD>" & "GST" & vbCr
        Scr = Scr & "<TR>" & vbCr & "<TD>" & "Purchases with GST" & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Pwgsta), "MD2"), 12) & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Pwgst), "MD2"), 12) & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Pur_Gst), "MD2"), 12) & vbCr
        Scr = Scr & "<TR>" & vbCr & "<TD>" & "Purchases with No GST" & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Pngsta), "MD2"), 12) & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Pngst), "MD2"), 12) & vbCr
        Scr = Scr & "<TR>" & vbCr & "<TD> <TD>" & Right(Space(12) & Pick.oconv(CStr(Pwgsta + Pngsta), "MD2"), 12) & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Pwgst + Pngst), "MD2"), 12) & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Pur_Gst), "MD2"), 12) & vbCr
        Scr = Scr & "<TR>" & vbCr & "<TD>" & "LESS" & vbCr
        Scr = Scr & "<TR>" & vbCr & "<TD>" & "Credits with GST" & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Crwgsta), "MD2"), 12) & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Crwgst), "MD2"), 12) & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Cred_Gst), "MD2"), 12) & vbCr
        Scr = Scr & "<TR>" & vbCr & "<TD>" & "Credits with No GST" & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Crngsta), "MD2"), 12) & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Crngst), "MD2"), 12) & vbCr
        Scr = Scr & "<TR>" & vbCr & "<TD> <TD>" & Right(Space(12) & Pick.oconv(CStr(Crwgsta + Crngsta), "MD2"), 12) & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Crwgst + Crngst), "MD2"), 12) & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Cred_Gst), "MD2"), 12) & vbCr
        Scr = Scr & "<TR>" & vbCr & "<TD>" & "ADD" & vbCr
        Scr = Scr & "<TR>" & vbCr & "<TD>" & "Payments with GST" & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Paywgsta), "MD2"), 12) & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Paywgst), "MD2"), 12) & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Pay_Gst), "MD2"), 12) & vbCr
        Scr = Scr & "<TR>" & vbCr & "<TD>" & "Payments with No GST" & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Payngsta), "MD2"), 12) & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Payngst), "MD2"), 12) & vbCr
        Scr = Scr & "<TR>" & vbCr & "<TD> <TD>" & Right(Space(12) & Pick.oconv(CStr(Paywgsta + Payngsta), "MD2"), 12) & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Paywgst + Payngst), "MD2"), 12) & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Pay_Gst), "MD2"), 12) & vbCr
        Scr = Scr & "<TR>" & vbCr & "<TD>" & "TOTAL PURCHASES" & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Total_Asset_Pur), "MD2"), 12) & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Total_Other_Pur), "MD2"), 12) & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Total_Pur_Gst), "MD2"), 12) & vbCr
'
        Scr = Scr & "<TR>" & vbCr & "<TD>"
        Scr = Scr & "RATES" & "<TD>" & "GST" & vbCr
        Scr = Scr & "<TR>" & vbCr & "<TD>" & "Rates with GST Charged" & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Rateswgst), "MD2"), 12) & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Rates_Gst), "MD2"), 12) & vbCr
        Scr = Scr & "<TR>" & vbCr & "<TD>" & "Rates with No GST Charged" & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Ratesngst), "MD2"), 12) & vbCr
        Scr = Scr & "<TR>" & vbCr & "<TD> <TD>" & Right(Space(12) & Pick.oconv(CStr(Rateswgst + Ratesngst), "MD2"), 12) & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Rates_Gst), "MD2"), 12) & vbCr
'
        Scr = Scr & "<TR>" & vbCr & "<TD>"
        Scr = Scr & "JOURNALS TO CONTROL ACCOUNTS" & vbCr
        Scr = Scr & "<TR>" & vbCr & "<TD> <TD>" & "Debits" & "<TD>" & "Credits" & vbCr
        Scr = Scr & "<TR>" & vbCr & "<TD>" & Left(Inp_Gst_Name & Space(25), 25) & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Inp_Gst_Dr), "MD2"), 12) & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Inp_Gst_Cr), "MD2"), 12) & vbCr
        Scr = Scr & "<TR>" & vbCr & "<TD>" & Left(Out_Gst_Name & Space(25), 25) & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Out_Gst_Dr), "MD2"), 12) & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Out_Gst_Cr), "MD2"), 12) & vbCr
        Scr = Scr & "<TR>" & vbCr & "<TD>" & Left(Wh_Tax_Name & Space(25), 25) & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Wh_Tax_Dr), "MD2"), 12) & "<TD>" & Right(Space(12) & Pick.oconv(CStr(Wh_Tax_Cr), "MD2"), 12) & vbCr
'
        TA514 = Scr
    End If
End Function

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


Public Function ourdate(the_date)

ourdate = Day(the_date) & " " & MonthName(Month(the_date), True) & " " & Year(the_date)

End Function

Public Function ta511_MSA(logentry As String, mdb_name As String, filename As String, parms As String) As String

' TA511  Print GL Trial Balance to selected date

Dim start_of_year, all_groups As String, Cc As Integer, rcnt As Integer
Dim gl_sc As String, gl_cl As String, gl_gp As String, gl_rec As String, Gl_Accts As String, Tb, Tt
Dim Tot_Open_Dr As Currency, Tot_Open_Cr As Currency, Tot_Tran_Dr As Currency
Dim Tot_Tran_Cr As Currency, Tot_Close_Dr As Currency, Tot_Close_Cr As Currency, Tot_Acc_Open_Dr As Currency, Tot_Acc_Open_Cr As Currency
Dim Tot_Acc_Tran_Dr As Currency, Tot_Acc_Tran_Cr As Currency, Tot_Acc_Close_Dr As Currency, Tot_Acc_Close_Cr As Currency
Dim Tot_Cl_Open_Dr As Currency, Tot_Cl_Open_Cr As Currency, Tot_Cl_Tran_Dr As Currency, Tot_Cl_Tran_Cr As Currency
Dim Tot_Cl_Close_Dr As Currency, Tot_Cl_Close_Cr As Currency, Tot_Gp_Open_Dr As Currency, Tot_Gp_Open_Cr As Currency
Dim Tot_Gp_Tran_Dr As Currency, Tot_Gp_Tran_Cr As Currency, Tot_Gp_Close_Dr As Currency, Tot_Gp_Close_Cr As Currency
Dim commitflag As String
Dim Ii As Integer, Noz As String, Num, sb_date
Dim tb_date, Wantrt As String
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
Dim the_rec() As String, rt_sent As String, sc_accts As String
Dim pl_from_year_start As String, the_year As String, suffix As String, shortyear As String

      database = Pick.extract(logentry, 2, 0, 0)
     'If d3.d3_readstr(Company, "DICT GEN.L", "@COMPANY") <> 0 Then Company = ""
     'Cfgrp = "": Ctgrp = ""
     
     the_year = Right(filename, 2)
     If IsNumeric(the_year) Then
        suffix = "_" & the_year
        If CInt(the_year) > 80 Then the_year = "19" & the_year Else the_year = "20" & the_year
     Else
        suffix = ""
        ReDim the_rec(0): the_rec(0) = "YEAR"
        rderr = d3.d3_readmat("", the_rec, mdb_name & "\CurrentYear")
        the_year = CStr(CInt(the_rec(1)) - 1)
     End If
     
     ReDim the_rec(0): the_rec(0) = the_year
     rderr = d3.d3_readmat("", the_rec, mdb_name & "\monthends")
     start_of_year = the_rec(12) 'last day of year 30/6/99
     
     Tb = "***** TRIAL BALANCE *****"
     Tt = "*****     TOTAL     *****"
     'Gop = "*****     GROUP     *****"
     Cls = "*****     CLASS     *****"
     subl = "*****   SUBCLASS    *****"
'
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
     sb_date = Pick.extract(parms, 3, 0, 0)
     tb_date = Pick.extract(parms, 4, 0, 0)
     Wantrt = Pick.extract(parms, 5, 0, 0)
     all_groups = Pick.extract(parms, 6, 0, 0)
     pl_from_year_start = Pick.extract(parms, 7, 0, 0)
'
     'If Sbdte >= start_of_year Then
  '  "Do you want P & L section as from " & pick.oconv(CStr(start_of_year), "D2") & " only ? (Y/N) &   "
     'End If
     If all_groups = "" Then
        all_groups = d3.msa_select_str(mdb_name & "\", "select account from " & filename & " where account_level = 1 order by level1", 0, "", Chr(253))
        'If d3.d3_readstr(database, all_groups, "DICT GEN.L", "XGRP") <> 0 Then all_groups = ""
     End If
        
     Select Case commitflag
        Case "A": temp = " - Actuals"
        Case "B": temp = " - Actuals & Commitments"
        Case "C": temp = " - Commitments"
     End Select

     ta511_MSA = d3.rtf_open(logentry, fso, textfile, ".asp")
     temp = "<TABLE cellspacing=1 cellpadding=1 border=1 WIDTH=95%><TR CLASS=top><TD COLSPAN=9 ALIGN=CENTER>General Ledger Trial Balance " & temp & " as at " & Now & " from " & sb_date & " to " & tb_date & "<TR CLASS=TOP><TH>Account<TH>Description<TH>Report Type<TH colspan=2>Opening<TH colspan=2>Transaction<TH colspan=2>Closing<TR class=top><TH><TH><TH><TH>Debit<TH>Credit<TH>Debit<TH>Credit<TH>Debit<TH>Credit"
     textfile.WriteLine (temp)
     LCNT = -1
'
200  For All_Group_Ct = 1 To Pick.dcount(all_groups, Chr(253))
        group = Pick.extract(all_groups, 1, All_Group_Ct, 0)
        If group = "" Then GoTo 220
        Gl_Accts = d3.msa_select_str(mdb_name & "\", "select level2 from " & filename & " where level1 = " & group & " and account_level = 2 order by level2", 0, "", Chr(254))
        'If d3.d3_readstr(database, gl_accts, "DICT GEN.L", "X" & group) <> 0 Then GoTo 210
        GoSub 1000
        For k = UBound(lines) To 0 Step -1
           dr_openbal = Pick.extractcur(lines(k), 3, 0, 0)
           If dr_openbal < 0 Then
              dr_openbalstr = FormatCurrency(-dr_openbal, 2)
              cr_openbalstr = ""
              Tot_Open_Dr = Tot_Open_Dr - dr_openbal
           Else
              dr_openbalstr = ""
              If dr_openbal = 0 Then cr_openbalstr = "" Else cr_openbalstr = FormatCurrency(dr_openbal, 2)
              Tot_Open_Cr = Tot_Open_Cr + dr_openbal
           End If
           dr_tranbal = Pick.extractcur(lines(k), 4, 0, 0)
           If dr_tranbal < 0 Then
              dr_tranbalstr = FormatCurrency(-dr_tranbal, 2)
              cr_tranbalstr = ""
              Tot_Tran_Dr = Tot_Tran_Dr - dr_tranbal
           Else
              dr_tranbalstr = ""
              If dr_tranbal = 0 Then cr_tranbalstr = "" Else cr_tranbalstr = FormatCurrency(dr_tranbal, 2)
              Tot_Tran_Cr = Tot_Tran_Cr + dr_tranbal
           End If
           dr_closebal = dr_openbal + dr_tranbal
           If dr_closebal < 0 Then
              dr_closebalstr = FormatCurrency(-dr_closebal, 2)
              cr_closebalstr = ""
              Tot_Close_Dr = Tot_Close_Dr - dr_closebal
           Else
              dr_closebalstr = ""
              If dr_closebal = 0 Then cr_closebalstr = "" Else cr_closebalstr = FormatCurrency(dr_closebal, 2)
              Tot_Close_Cr = Tot_Close_Cr + dr_closebal
           End If
           temp = "<TR><TD>" & Pick.extract(lines(k), 1, 0, 0) & "&nbsp;<TD>" & Pick.extract(lines(k), 2, 0, 0) & "<TD>" & Pick.extract(lines(k), 5, 0, 0) & "&nbsp;<TD>" & dr_openbalstr & "<TD>" & cr_openbalstr & "<TD>" & dr_tranbalstr & "<TD>" & cr_tranbalstr & "<TD>" & dr_closebalstr & "<TD>" & cr_closebalstr
           textfile.WriteLine (temp)
        Next k
        LCNT = -1
        ReDim lines(0)
210  Next All_Group_Ct
     
220  textfile.WriteLine ("</TABLE>")
     textfile.WriteLine ("</BODY>")
     textfile.WriteLine ("</HTML>")
     textfile.Close
     Set textfile = Nothing
     Set fso = Nothing
     Exit Function
'
' s/r 1000:  process group level
'
1000 gl_gp = group
     Gp_Open_Bal = 0: Gp_Tran_Bal = 0

     Class_Limit = Pick.dcount(Gl_Accts, Chr(254))
     For Cc = Class_Limit To 1 Step -1
        Class = Pick.extract(Gl_Accts, Cc, 0, 0): GoSub 2000
     Next Cc
     If d3.d3_readstr(database, gl_rec, mdb_name & "\" & filename, gl_gp) <> 0 Then gl_rec = Chr(254) & "?? ACCOUNT MISSING ??"
     LCNT = LCNT + 1
     ReDim Preserve lines(LCNT)
     lines(LCNT) = gl_gp & Chr(254) & Pick.extract(gl_rec, 2, 0, 0) & Chr(254) & Gp_Open_Bal & Chr(254) & Gp_Tran_Bal
     Return
'
' process class levels
'
2000 gl_cl = group & "." & Class
     Cl_Open_Bal = 0: Cl_Tran_Bal = 0
     'MsgBox "select account from gen_l where level1 = " & group & " and level2 = " & Class & " and account_level = 3 order by level3"
     sc_accts = d3.msa_select_str(mdb_name, "select level3 from " & filename & " where level1 = " & group & " and level2 = " & Class & " and account_level = 3 order by level3", 0, "", Chr(254))
     Max_Ii = Pick.dcount(sc_accts, Chr(254))
     For Ii = Max_Ii To 1 Step -1
        sub_class = Pick.extract(sc_accts, Ii, 0, 0)
        GoSub 3000
     Next Ii
     If d3.d3_readstr(database, gl_rec, mdb_name & "\" & filename, gl_cl) <> 0 Then gl_rec = Chr(254) & "?? ACCOUNT MISSING ??"
     LCNT = LCNT + 1
     ReDim Preserve lines(LCNT)
     lines(LCNT) = gl_cl & Chr(254) & Pick.extract(gl_rec, 2, 0, 0) & Chr(254) & Cl_Open_Bal & Chr(254) & Cl_Tran_Bal
     Gp_Open_Bal = Gp_Open_Bal + Cl_Open_Bal
     Gp_Tran_Bal = Gp_Tran_Bal + Cl_Tran_Bal
     Return
'
' process sub-class levels
'
3000 gl_sc = gl_cl & "." & sub_class
     If d3.d3_readstr(database, gl_rec, mdb_name & "\" & filename, gl_sc) <> 0 Then gl_rec = Chr(254) & "?? ACCOUNT MISSING ??"
     Call gl_account_balances_msa(logentry, mdb_name, suffix, gl_sc, gl_rec, commitflag, pl_from_year_start, start_of_year, sb_date, tb_date, Open_Bal, tran_bal)
     If Noz = "Y" And Open_Bal = 0 And tran_bal = 0 Then Return
     Acc_Name = Pick.extract(gl_rec, 2, 0, 0)
     If Pick.extract(gl_rec, 13, 0, 0) <> "" Then Acc_Name = Acc_Name & " " & "(CLOSED)"
     Rt = ""
     'If Wantrt = "Y" Then
        rt_sent = "select rtype.description from gl_rtype" & suffix & " gl_rtype inner join rtype rtype on gl_rtype.rtype=rtype.rtype where gl_rtype.account = '" & gl_sc & "' order by rtype.rtype"
        Rt = d3.msa_select_str(mdb_name, rt_sent, 0, "", ",")
     'End If
     'Rt = Pick.extract(gl_rec, 31, 0, 0)
     LCNT = LCNT + 1
     ReDim Preserve lines(LCNT)
     lines(LCNT) = gl_sc & Chr(254) & Acc_Name & Chr(254) & Open_Bal & Chr(254) & tran_bal & Chr(254) & Rt
     Cl_Open_Bal = Cl_Open_Bal + Open_Bal
     Cl_Tran_Bal = Cl_Tran_Bal + tran_bal
     Return
End Function




Public Sub gl_account_balances_msa(logentry As String, mdb_name As String, suffix As String, gl_ac As String, gl_rec As String, commitflag As String, pl_from_year_start As String, start_of_year, sb_date, tb_date, Open_Bal As Currency, tran_bal As Currency)

Dim acc_type As String, tr_code As Integer, Tr_Date, Amount As Currency
Dim sentence As String, trid As String, mylist() As String, total_items As Long, pick_cnt As Long
Dim database As String, kk As Long, tr_rec As String, extra_test As String

     database = Pick.extract(logentry, 2, 0, 0)
     
     If d3.d3_readstr(database, gl_rec, mdb_name & "\GEN_L" & suffix, gl_ac) <> 0 Then gl_rec = Chr(254) & "?? ACCOUNT MISSING ??"
     acc_type = Pick.extract(gl_rec, 1, 0, 0)
     
     If pl_from_year_start = "Y" And acc_type = "C" Then
        Open_Bal = 0
     Else
        If commitflag = "C" Then
           Open_Bal = Pick.extractcur(gl_rec, 32, 1, 0)
        Else
           Open_Bal = Pick.extractcur(gl_rec, 6, 1, 0)
           If commitflag = "B" Then Open_Bal = Open_Bal + Pick.extractcur(gl_rec, 32, 1, 0)
        End If
     End If
'tran_bal
     sentence = "SELECT sum(amount) from gl_trans" & suffix & " where account = '" & gl_ac & "' and [date] >= #" & sb_date & "# and [date] <= #" & tb_date & "#"
     Select Case commitflag
     Case "A"
        sentence = sentence & " and code <> 81 and code <> 18"
     Case "C"
        sentence = sentence & " and (code = 81 or code = 18)"
     End Select
     total_items = d3.msa_select(mdb_name, sentence, mylist(), pick_cnt, 0, 0) - 1
     If pick_cnt = -1 Then
        tran_bal = -99999999
     Else
        If IsNumeric(mylist(0)) Then tran_bal = -CCur(mylist(0)) Else tran_bal = 0
     End If
' if a trans is before start date wanted for a cost center account
'     only add into opening balance if also after start of year - when the pl_from_year_start flag is set
     extra_test = ""
     If pl_from_year_start = "Y" And acc_type = "C" Then
        extra_test = " and [date] > #" & start_of_year & "#"
     End If
'open_bal
     sentence = "SELECT sum(amount) from gl_trans" & suffix & " where account = '" & gl_ac & "' and [date] < #" & sb_date & "#" & extra_test
     Select Case commitflag
     Case "A"
        sentence = sentence & " and code <> 81 and code <> 18"
     Case "C"
        sentence = sentence & " and (code = 81 or code = 18)"
     End Select
     total_items = d3.msa_select(mdb_name, sentence, mylist(), pick_cnt, 0, 0) - 1
     If pick_cnt = -1 Then
        Open_Bal = -99999999
     Else
        If IsNumeric(mylist(0)) Then Open_Bal = Open_Bal - CCur(mylist(0))
     End If

End Sub


Public Function load_budgets_from_excel(Params As String)

Dim Id As String, Yr As String, suffix As String, ftable As String, acid As String, Accts As String
Dim budgets() As Currency, offset As Integer, yrid As String, drive As String, workbook As String
Dim newrec As String, glrec As String, database As String, kk As Integer, nn As Integer, Mm As Integer
Dim wterr As String, wbook As String, rderr As Integer, Am As String, Par() As String, StartCol As String, FinCol As String
Dim srow As Integer, erow As Integer, scol As Integer, fcol As Integer, numrows As Integer, RR As Integer
Dim spos As Long, epos As Long, lne As String, numcols As Integer, dd As Integer, EE As Integer, ecol As Integer
Dim colval As String, acct_col As Integer, firstdot As Integer, Seconddot As Integer, temp As String

     Am = Chr(254)
     Par = Split(Params, Am)
     workbook = Par(0)
     Yr = Par(1)
     drive = Left(workbook, 2)
     If d3.d3_readstr(database, newrec, drive & "\ckashare\gen_l\gen_l.mdb\CurrentYear", "YEAR") = 0 Then
        If Yr = Trim(Pick.extract(newrec, 1, 0, 0)) Then
            Yr = ""
        Else
            Yr = Right(Yr, 2)
        End If
     End If
     Accts = UCase(Par(2))
     srow = CInt(Par(3))
     erow = CInt(Par(4))
     StartCol = Par(5)
     FinCol = Par(6)
     numrows = (erow - srow) + 1
     acct_col = Asc(Accts) - 64
     scol = Asc(StartCol) - 64
     fcol = Asc(FinCol) - 64
     rderr = d3.ReadDosFile(workbook, wbook)
     If Not (rderr) Then Exit Function
     wbook = Mid(wbook, InStr(wbook, "<table")) 'get to table
     wbook = Mid(wbook, Pick.Index(wbook, "<tr", srow)) 'get to the start row required
     For RR = 1 To numrows
        spos = Pick.Index(wbook, "<tr", RR)
        epos = Pick.Index(wbook, "</tr", RR)
        lne = Mid(wbook, spos, epos - spos + 4)
        numcols = Pick.dcount(lne, "</td>") - 1
        ReDim budgets(12)
        For dd = 1 To numcols
           ecol = Pick.Index(lne, "</td>", dd)
           For EE = ecol To 1 Step -1
              If Mid(lne, EE, 1) = ">" Then
                 colval = Mid(lne, EE + 1, ecol - EE - 1)
                 If colval = "" Then colval = "0"
                 Select Case dd
                    Case acct_col: Id = colval
                    Case Is >= scol And dd <= fcol: budgets(dd - 1) = CCur(colval)
                 End Select
                 Exit For
               End If
           Next EE
        Next dd
        firstdot = InStr(1, Id, ".", vbBinaryCompare)
        temp = Mid(Id, firstdot + 1)
        Seconddot = InStr(1, temp, ".")
        If Seconddot > 0 Then ' Only Budget at the subclass level
            database = ""
            If Yr = "" Then suffix = "" Else suffix = "_" & Yr
     
            ftable = "gen_l" & suffix
            yrid = Id
            If d3.d3_readstr(database, newrec, drive & "\ckashare\gen_l\gen_l.mdb\" & ftable, yrid) = 0 Then
                glrec = newrec
                offset = 25
                GoSub add_values_gl 'write done in subroutine
                yrid = Pick.field(Id, ".", 1)
                If d3.d3_readstr(database, newrec, drive & "\ckashare\gen_l\gen_l.mdb\" & ftable, yrid) = 0 Then
                    GoSub add_values_gl 'group
                    yrid = Pick.field(Id, ".", 1) & "." & Pick.field(Id, ".", 2)
                    If d3.d3_readstr(database, newrec, drive & "\ckashare\gen_l\gen_l.mdb\" & ftable, yrid) = 0 Then
                        GoSub add_values_gl 'group.class
                        offset = 5
                        acid = Pick.field(Id, ".", 2): ftable = "level2" & suffix: GoSub add_values
                        acid = Pick.field(Id, ".", 3): ftable = "level3" & suffix: GoSub add_values
                        acid = Pick.field(Id, ".", 2) & "." & Pick.field(Id, ".", 3):  ftable = "level2_3" & suffix: GoSub add_values
                    End If
                End If
            End If
        End If
     Next RR
     Call sr_workbook(drive, workbook, "U")
     Exit Function
     
add_values:
'year
     yrid = Pick.extract(glrec, 12, 0, 0) & acid
     If d3.d3_readstr(database, newrec, drive & "\ckashare\gen_l\gen_l.mdb\" & ftable, yrid) <> 0 Then
        newrec = Pick.extract(glrec, 12, 0, 0) 'alie
        newrec = Pick.replace(newrec, 2, 0, 0, acid)
        newrec = Pick.replace(newrec, 3, 0, 0, Pick.extract(glrec, 2, 0, 0))
        newrec = Pick.replace(newrec, 4, 0, 0, Yr)
     End If
add_values_gl:
'budgets
     For nn = 1 To 12
        newrec = Pick.replace(newrec, offset + 26 + nn, 0, 0, Pick.extractcur(newrec, offset + 26 + nn, 0, 0) + budgets(nn))
        newrec = Pick.replace(newrec, offset + 26, 0, 0, Pick.extractcur(newrec, offset + 26, 0, 0) + budgets(nn))
        For Mm = 1 To nn
           newrec = Pick.replace(newrec, offset + 62 + nn, 0, 0, Pick.extractcur(newrec, offset + 62 + nn, 0, 0) + budgets(Mm))
        Next Mm
     Next nn
     wterr = d3.d3_writestr(database, drive & "\ckashare\gen_l\gen_l.mdb\" & ftable, yrid, newrec)
     'If wterr <> "0" Then MsgBox wterr & "=" & yrid & "=" & newrec
     Return
     
End Function


Public Sub sr_workbook(drive As String, workbook As String, What As String)

Dim newrec As String, wterr As String, tablename As String, k As Integer
Dim testchar As String, chars As String, wname As String

chars = "/\~"

     tablename = drive & "\ckashare\gen_l\gen_l.mdb\Budget_workbooks"
     
     For k = Len(workbook) To 1 Step -1
        testchar = Mid(workbook, k, 1)
        If InStr(chars, testchar) <> 0 Then Exit For
     Next k
     wname = Mid(workbook, k + 1) 'just get name not the full path extension
                                  '~ is because of temporary fil when copying by iis
     wname = Pick.field(wname, ".", 1) 'do not want the extension - is .asp or .htm
     
     If d3.d3_readstr("", newrec, tablename, wname) <> 0 Then newrec = ""

     Select Case What
        Case "A": newrec = Pick.replace(newrec, 1, 0, 0, CStr(Now))
        Case "U": newrec = Pick.replace(newrec, 3, 0, 0, CStr(Now))
     End Select

     wterr = d3.d3_writestr("", tablename, wname, newrec)

End Sub

Function sr555(logentry As String, parms As String, Optional msa As Integer = 0)

'set msa=1 for msaccess, false for D3

Dim excel_name As String, the_mth As Integer, the_worksheets As String, the_last_row As Long, the_head_row As Integer
Dim total_items As Long, mylist() As String, pick_cnt As Long, I As Long, ColPos As Long, ColEnd As Long
Dim Ww As Integer, startm As Integer, wsheet As String, fso, tfile, ValSheet As String
Dim the_worksheet As String, number_of_sheets As Integer
Dim upto_mth As Integer, j As Integer, tempstuff
Dim last_year As Integer, had_account As Integer
Dim process_year As String, process_mth As String, Attr As Integer
Dim the_account_cols() As Integer
Dim the_row As Integer, accol As Integer
Dim accounts As String, temp, temp2, temp3
Dim the_id As String, the_col As Integer, m As Integer
Dim dde_error As Integer, glrec As String, the_value, save_the_value
Dim cols() As Integer, the_start_col As Integer, div_by As Integer
Dim the_multiply_by_col As Integer, Pos As Integer
Dim the_values() As Currency, ws_number As Integer
Dim cell_value As String
Dim gldata As String, Id As String, the_rec As String, totnum As Long
Dim add_cnt As Integer
Dim have_one_sheet As Boolean
Dim wterror As Integer
Dim table_index As Integer, table_bookmark, rderr
Dim sortby As String
Dim FndPos As Integer, qm As String * 1, gotdict As Boolean
Dim got_error As Boolean, dummy() As String
Dim isjob As Boolean, dict_filename As String, filename As String, tempstr As String 'mc 26aug99
Dim expos As Integer
Dim Sheet As String
Dim the_cnt As Integer
Dim Max As Integer, k As Integer
Dim usersheet As String
Dim f_month_one As Integer
Dim database As String, kk As Integer
Dim f_months(), want_date As Integer
Dim f_start_posn As Integer
Dim g_trans_info As String
Dim wpos As Integer, borpl As String, lets As String
Dim soy As String, acmth As Integer, Account_Ids As String, WsAccounts As String

ValSheet = ""
database = Pick.extract(logentry, 2, 0, 0)

excel_name = Pick.extract(parms, 1, 0, 0)
the_worksheets = Pick.extract(parms, 2, 0, 0)
'Multiply_Bys = Pick.extract(Parms, 3, 0, 0)
want_date = CInt(Pick.ICONV(Pick.extract(parms, 4, 0, 0), "D2"))
the_head_row = Pick.extractint(parms, 5, 0, 0)
'borpl = pick.extract(parms, 5, 0, 0)           ' Not Used ? DG 31/10/01
Account_Ids = Pick.extract(parms, 6, 0, 0)
For k = 14 To 1 Step -1
   parms = Pick.delet(parms, k, 0, 0)
Next k
'     If rderr = d3.ReadDosFile(excel_name, wsheet) <> 0 Then
'        Exit Function
'     End If
     
'    temp = Pick.ini_read("last_file_used", "workbook", f_ckame_excel)
           
     f_month_one = -1
     If d3.d3_readstr(database, g_trans_info, "dict trans.j", "trans.info") <> 0 Then Exit Function
     soy = CStr(Pick.extractint(g_trans_info, 8, 1, 0) + 1)
     acmth = Pick.extractint(g_trans_info, 5, 0, 0)
          
     the_cnt = 0
     Max = Pick.dcount(Pick.extract(g_trans_info, 9, 0, 0), Chr(253))
     If Max > 11 Then
        ReDim Preserve f_months(11)
        f_months(0) = CVar(Pick.extractint(g_trans_info, 9, Max - 11, 0)) + 24837
        For k = Max - 10 To Max
           If IsNumeric(Pick.extract(g_trans_info, 9, k, 0)) Then
              the_cnt = the_cnt + 1
              f_months(the_cnt) = CVar(Pick.extract(g_trans_info, 9, k, 0)) + 24837
           End If
        Next k
     End If
     Max = Pick.dcount(Pick.extract(g_trans_info, 8, 0, 0), Chr(253))
     For k = 1 To Max
        If IsNumeric(Pick.extract(g_trans_info, 8, k, 0)) Then
           the_cnt = the_cnt + 1
           If k = 2 Then f_month_one = the_cnt
           ReDim Preserve f_months(the_cnt)
           f_months(the_cnt) = CVar(Pick.extract(g_trans_info, 8, k, 0)) + 24837
        End If
     Next k
     If IsNumeric(Pick.extract(g_trans_info, 7, 0, 0)) Then
        the_cnt = the_cnt + 1
        ReDim Preserve f_months(the_cnt)
        f_months(the_cnt) = CVar(Pick.extract(g_trans_info, 7, 0, 0)) + 24837
     End If
     Max = Pick.dcount(Pick.extract(g_trans_info, 33, 0, 0), Chr(253))
     For k = 1 To Max
        If IsNumeric(Pick.extract(g_trans_info, 33, k, 0)) Then
           the_cnt = the_cnt + 1
           ReDim Preserve f_months(the_cnt)
           f_months(the_cnt) = CVar(Pick.extract(g_trans_info, 33, k, 0)) + 24837
        End If
     Next k

     the_mth = 0
     For k = f_month_one To UBound(f_months)
        If want_date = f_months(k) - 24837 Then Exit For
        the_mth = the_mth + 1
     Next k

' setup possible month end dates
     f_start_posn = 70 '2 * UBound(f_months)

gotdict = False
qm = Chr(34) 'double quote mark "

'If C_UpdateReportInfo.Enabled = True Then have_one_sheet = True Else have_one_sheet = False
        
   number_of_sheets = Pick.dcount(the_worksheets, Chr(253))
   MsgBox number_of_sheets & "=" & Account_Ids
   For ws_number = 1 To number_of_sheets
       WsAccounts = Pick.extract(Account_Ids, 1, ws_number, 0)
       MsgBox WsAccounts
'      the_worksheet = pick.extract(the_worksheets, ws_number, 0, 0)
'      ''''Set ''''Excelsheet = Excel.Worksheets(CStr(the_worksheet))
'      ''''Set rng = ''''Excelsheet.UsedRange
'      ''''the_last_row = rng.Rows.Count
'      'Call ini_put(F_Excelapp.ActiveWorkbook.Name & "-" & the_worksheet, "month", CStr(the_mth), f_ckame_excel)
      GoSub calc_values
   Next ws_number

        On Error Resume Next
        ''''''''Excelsheet.Application.Columns.AutoFit
        ''''''''Excelsheet.Application.Rows.AutoFit
        ''''''''Excelsheet.Application.Rows.VerticalAlignment = xlTop 'this in case have multiple lines on some cells
        ''''ExcelBook.Save
        ''''''''Excelsheet.Application.Quit
        ''''Set ''''Excelsheet = Nothing
        On Error GoTo 0
   sr555 = Chr(253) & the_worksheets & Chr(254) & ValSheet
Exit Function

calc_values: ' start to calculate worksheet
   add_cnt = 0: got_error = False
   ReDim the_account_cols(0): ReDim cols(0)
   the_multiply_by_col = 0
      
   For j = 1 To Pick.dcount(parms, Chr(254))
      wpos = Pick.extractint(parms, j, ws_number, 0)
      Select Case wpos
         Case 0
         Case 1
            the_account_cols(UBound(the_account_cols)) = j
            ReDim Preserve the_account_cols(UBound(the_account_cols) + 1)
         Case 2: the_multiply_by_col = j
         Case Else
            If j > UBound(cols) Then ReDim Preserve cols(j)
            cols(j) = wpos
      End Select
   Next j
   If UBound(the_account_cols) = 0 Then Exit Function 'no account column

      For Ww = 1 To UBound(cols)
         the_col = Ww
         temp = ""
         Select Case cols(Ww)
            Case 3 To 4 + f_start_posn, 21 + f_start_posn, 23 + f_start_posn
               temp2 = f_month_one + the_mth
               If cols(Ww) < 21 + f_start_posn Then '1-12 last year, 13-36 future years
                  GoSub get_temp2
               End If
               If temp2 > UBound(f_months) Then
                  temp3 = 0
                  Do Until temp2 <= UBound(f_months)
                     temp2 = temp2 - 12: temp3 = temp3 + 12
                  Loop
                  temp = DateSerial(Year(f_months(temp2)), Month(f_months(temp2)) + temp3, Day(f_months(temp2)))
               Else
                  temp = f_months(temp2)
               End If
            Case 7 + f_start_posn, 12 + f_start_posn ' this full year - actual(8), budget(13)
               process_year = Format(CDate(f_months(f_month_one + the_mth)), "yyyy")
               process_mth = Format(CDate(f_months(f_month_one + the_mth)), "mm")
               If CInt(process_mth) < 7 Then process_year = CStr(CInt(process_year) - 1)
               cell_value = process_year & "/" & CStr(CInt(process_year) + 1): GoSub set_cell_value
            Case 8 + f_start_posn, 11 + f_start_posn ' last full year - actual(9), budget(12)
               process_year = Format(CDate(f_months(f_month_one + the_mth - 12)), "yyyy")
               process_mth = Format(CDate(f_months(f_month_one + the_mth - 12)), "mm")
               If CInt(process_mth) < 7 Then process_year = CStr(CInt(process_year) - 1)
               cell_value = process_year & "/" & CStr(CInt(process_year) + 1): GoSub set_cell_value
            Case 13 + f_start_posn
               process_year = Format(CDate(f_months(f_month_one + the_mth)), "yyyy")
               process_mth = Format(CDate(f_months(f_month_one + the_mth)), "mm")
               If CInt(process_mth) < 7 Then process_year = CStr(CInt(process_year) - 1)
               process_year = CStr(CInt(process_year) + 1)
               cell_value = process_year & "/" & CStr(CInt(process_year) + 1)
            Case 5 + f_start_posn, 9 + f_start_posn, 22 + f_start_posn, 24 + f_start_posn
               temp = f_months(f_month_one + the_mth)
            Case 25 + f_start_posn 'opening balance this
               temp = f_months(f_month_one - 1) + 1
            Case 26 + f_start_posn 'opening balance last
               temp = f_months(f_month_one - 13) + 1
            Case 6 + f_start_posn, 10 + f_start_posn
               temp = f_months(f_month_one + the_mth - 12)
            Case 14 + f_start_posn
               cell_value = "Account": GoSub set_cell_value
               ''''Excelsheet.Application.Columns(the_col).HorizontalAlignment = xlLeft
               ''''Excelsheet.Application.Columns(the_col).NumberFormat = "@"
            Case 15 + f_start_posn
               cell_value = "Description": GoSub set_cell_value
            Case 16 + f_start_posn
               process_year = Format(CDate(f_months(f_month_one + the_mth)), "yyyy")
               process_mth = Format(CDate(f_months(f_month_one + the_mth)), "mm")
               If CInt(process_mth) < 7 Then process_year = CStr(CInt(process_year) - 1)
               process_year = CStr(CInt(process_year) + 2)
               cell_value = process_year & "/" & CStr(CInt(process_year) + 1): GoSub set_cell_value
            Case 17 + f_start_posn
               process_year = Format(CDate(f_months(f_month_one + the_mth)), "yyyy")
               process_mth = Format(CDate(f_months(f_month_one + the_mth)), "mm")
               If CInt(process_mth) < 7 Then process_year = CStr(CInt(process_year) - 1)
               process_year = CStr(CInt(process_year) + 3)
               cell_value = process_year & "/" & CStr(CInt(process_year) + 1): GoSub set_cell_value
            Case 18 + f_start_posn
               process_year = Format(CDate(f_months(f_month_one + the_mth)), "yyyy")
               process_mth = Format(CDate(f_months(f_month_one + the_mth)), "mm")
               If CInt(process_mth) < 7 Then process_year = CStr(CInt(process_year) - 1)
               process_year = CStr(CInt(process_year) + 4)
               cell_value = process_year & "/" & CStr(CInt(process_year) + 1): GoSub set_cell_value
            Case 19 + f_start_posn
               process_year = Format(CDate(f_months(f_month_one + the_mth)), "yyyy")
               process_mth = Format(CDate(f_months(f_month_one + the_mth)), "mm")
               If CInt(process_mth) < 7 Then process_year = CStr(CInt(process_year) - 1)
               process_year = CStr(CInt(process_year) + 5)
               cell_value = process_year & "/" & CStr(CInt(process_year) + 1): GoSub set_cell_value
            Case 20 + f_start_posn
               cell_value = "Projection": GoSub set_cell_value
         End Select
         If temp <> "" Then cell_value = Format(CDate(temp), "medium date"): GoSub set_cell_value
      Next Ww
'   Set fso = New Scripting.FileSystemObject
'   Set tfile = fso.CreateTextFile("c:\downloads\9000_genex_files\sheet003.htm", "True")
'   tfile.Write (wsheet)
'   tfile.Close
'   Exit Sub    ' Testing Only
   the_last_row = Pick.dcount(WsAccounts, Chr(252)) '***
   MsgBox the_last_row & "=" & WsAccounts
   For the_row = 1 To the_last_row
      had_account = False
      Erase the_values
      ReDim the_values(UBound(f_months) + 72, 3) '1-actual,2-budget,3-commit 'MCO 3/8/98 WAS +24 CHANGED TO +72 TO BE AS OTHERS DGM DID FOR &
      For accol = 0 To UBound(the_account_cols) - 1
         ''''accounts = Excelsheet.Application.Cells(the_row, the_account_cols(accol))
         accounts = Pick.extract(WsAccounts, 1, 1, the_row)
         If accounts <> "" Then
            had_account = True
                        
            If Left(accounts, 1) = "&" Or Left(accounts, 4) = "JOB&" Then
            MsgBox "accoun"
               If Left(accounts, 4) = "JOB&" Then
                  isjob = True: accounts = Mid(accounts, 4)
                  filename = "JOB.L": dict_filename = "DICT JOB.L"
               Else
                  isjob = False
                  filename = "GEN.L": dict_filename = "DICT GEN.L"
               End If
               accounts = Trim(UCase(accounts))
               If msa = 0 Then Call sr555_write_dict(database, dict_filename, isjob) 'write dictionary item that may not exist in D3
               If Mid(accounts, 2, 2) = "RC" Then
                  If isjob Then sortby = "A29" Else sortby = "A22"
                  sortby = " WITH " & sortby & " = " & qm & Mid(accounts, 4) & qm
                  GoTo sr555_select
               End If
               If Mid(accounts, 2, 3) = "RPT" Then
                  If Not (isjob) Then
                     sortby = "A31"
                     sortby = " WITH " & sortby & " = " & qm & Mid(accounts, 5) & qm
                     GoTo sr555_select
                  End If
               End If
               If InStr(accounts, "S") > 0 Or InStr(accounts, "C") > 0 Then
                  If InStr(accounts, "S") > 0 Then
                     FndPos = InStr(accounts, "S")
                     If FndPos = 2 Then
                        If Len(accounts) = 2 Then
                           ' just want all subclass accounts ie &S
                           sortby = " WITH NO MYSCLS = " & qm & qm
                        Else
                           ' want specific subclasses ie &S10
                           sortby = " WITH MYSCLS = " & qm & Mid(accounts, 3) & qm
                        End If
                     Else
                        If FndPos = Len(accounts) Then
                           ' want all subclass for specific Group/s and/or Class/s ie &41.S
                           sortby = " WITH A0 = " & qm & Mid(accounts, 2, FndPos - 2) & "]" & qm & " AND WITH NO MYSCLS = " & qm & qm
                        Else
                           ' want specific subclass for specific Group/s and/or Class/s ie &41.S10
                           sortby = " WITH A0 = " & qm & Mid(accounts, 2, FndPos - 2) & "]" & qm & " AND WITH MYSCLS = " & qm & Mid(accounts, FndPos) & qm
                        End If
                     End If
                  Else
                     FndPos = InStr(accounts, "C")
                     If FndPos = 2 Then
                        If Len(accounts) = 2 Then
                           ' just want all class accounts ie &C
                           sortby = " WITH NO MYCLS = " & qm & "0" & qm & " AND WITH MYSCLS = " & qm & qm
                        Else
                           ' want specific classes ie &C10
                           sortby = " WITH MYCLS = " & qm & Mid(accounts, 3) & qm & " AND WITH MYSCLS = " & qm & qm
                        End If
                     Else
                        If FndPos = Len(accounts) Then
                           ' want all class for specific Group/s ie &41.C
                           sortby = " WITH A0 = " & qm & Mid(accounts, 2, FndPos - 2) & "]" & qm & " WITH NO MYCLS = " & qm & "0" & qm & " AND WITH MYSCLS =  " & qm & qm
                        Else
                           ' want specific class for specific Group/s ie &41.C10
                           sortby = " WITH A0 = " & qm & Mid(accounts, 2, FndPos - 2) & "]" & qm & " AND WITH MYCLS = " & qm & Mid(accounts, FndPos + 1) & qm & " AND WITH MYSCLS =  " & qm & qm
                        End If
                     End If
                  End If
               Else
                  If InStr(accounts, "G") > 0 Then
                     FndPos = InStr(accounts, "G")
                     If FndPos = 2 Then
                        If Len(accounts) = 2 Then
                           ' just want all group accounts ie &G
                           sortby = " WITH MYCLS = " & qm & "0" & qm & " AND WITH MYSCLS = " & qm & qm
                        Else
                           ' want specific groups ie &G10
                           sortby = " WITH MYGRP = " & qm & Mid(accounts, 3) & qm & " AND WITH MYCLS = " & qm & "0" & qm & " AND WITH MYSCLS = " & qm & qm
                        End If
                     Else
                        If FndPos = Len(accounts) Then
                           ' want all group for specific Group/s ie &41.G &^^3.G
                           sortby = " WITH A0 = " & qm & Mid(accounts, 2, FndPos - 2) & "]" & qm & " AND WITH NO MYSCLS = " & qm & qm
                        Else
                           ' want specific ? for specific Group/s  ie &41.G10 not supported
                           sortby = " WITH A0 = " & qm & Mid(accounts, 2) & "]" & qm
                        End If
                     End If
                  Else
                     sortby = " WITH A0 = " & qm & Mid(accounts, 2) & "]" & qm
                     If Mid(accounts, 2) = "" Then sortby = "" 'mco 1/6/98
                  End If
               End If
sr555_select:
               sortby = sortby & " by bmygrp by bmycls by bmyscls"
               table_index = -1
sr555_rdnext:

               total_items = d3.d3_select(logentry, "sselect gen.l " & sortby, mylist(), pick_cnt, 0, 0) - 1
               For kk = 0 To total_items
                  Erase the_values
                  ReDim the_values(UBound(f_months) + 72, 3) '1-actual,2-budget,3-commit
                  'the_id = mylist(kk)
                  If isjob Then mylist(kk) = "JOB" & mylist(kk)
                  accounts = mylist(kk)
                  GoSub call_sr555b
                  add_cnt = add_cnt + 1
                  GoSub get_values
               Next kk
               GoTo past_accol ' dont care about multiple account columns
            End If
            If InStr(accounts, ",") <> 0 Then
               Call Pick.sr_change(accounts, ",", Chr(253))
            Else
               Call Pick.sr_change(accounts, " ", Chr(253))
            End If
            Call Pick.sr_change(accounts, "(", Chr(252))
            Call Pick.sr_change(accounts, ")", "")
            GoSub call_sr555b
            GoTo past_call
call_sr555b:
            If msa = 1 Then
               glrec = sr555b_msa(msa, logentry, String(17, Chr(254)) & accounts, the_mth, "C", soy, acmth)
            Else
               glrec = SR555B(msa, logentry, String(17, Chr(254)) & accounts, the_mth, "C", soy, acmth)
            End If
            the_id = accounts
            'this read is to get account description from gen.l - only makes sense if just use one account
            If InStr(the_id, "-") = 0 And InStr(the_id, Chr(253)) = 0 And InStr(the_id, Chr(252)) = 0 Then
               If Left(accounts, 3) = "JOB" Then filename = "JOB.L": the_id = Mid(the_id, 4) Else filename = "GEN.L"
               wterror = d3.d3_readstr(database, gldata, filename, the_id)
               If wterror <> 0 Then gldata = ""
            Else
               gldata = ""
            End If
            Call sr555_getvals(f_month_one, glrec, the_values(), isjob)
            Return
past_call:
         End If
      Next accol
      If had_account Then GoSub get_values
past_accol:
   Next the_row
Return
    
get_values:
   For Ww = 1 To UBound(cols)
      the_col = Ww
      Select Case cols(Ww)
        Case 3 To 38
            temp2 = f_month_one + the_mth
            GoSub get_temp2
            temp = the_values(temp2, 1): div_by = 100: GoSub get_one: GoSub update_cell
         Case 39 To 74
            temp2 = f_month_one + the_mth
            GoSub get_temp2
            temp = the_values(temp2, 2): div_by = 1: GoSub get_one: GoSub update_cell
         Case 5 + f_start_posn: Attr = 1: div_by = 100: last_year = 0: upto_mth = the_mth: GoSub get_ytd: GoSub update_cell
         Case 6 + f_start_posn: Attr = 1: div_by = 100: last_year = -12: upto_mth = the_mth: GoSub get_ytd: GoSub update_cell
         
         Case 7 + f_start_posn: Attr = 1: div_by = 100: last_year = 0: GoSub get_yfull: GoSub update_cell
         
         Case 8 + f_start_posn: Attr = 1: div_by = 100: last_year = -12: GoSub get_yfull: GoSub update_cell
         
         Case 9 + f_start_posn: Attr = 2: div_by = 1: last_year = 0: upto_mth = the_mth: GoSub get_ytd: GoSub update_cell
         Case 10 + f_start_posn: Attr = 2: div_by = 1: last_year = -12: upto_mth = the_mth: GoSub get_ytd: GoSub update_cell
         
         Case 11 + f_start_posn: Attr = 2: div_by = 1: last_year = -12: GoSub get_yfull: GoSub update_cell
         
         Case 12 + f_start_posn: Attr = 2: div_by = 1: last_year = 0: GoSub get_yfull: GoSub update_cell
         
         Case 13 + f_start_posn: Attr = 2: div_by = 1: last_year = 12: GoSub get_yfull: GoSub update_cell
         
         Case 14 + f_start_posn: the_value = the_id: GoSub update_cell_no_multiply
         Case 15 + f_start_posn: 'mc 26aug99
            tempstr = Pick.extract(gldata, 2, 0, 0) 'mc 26aug99
            Call Pick.sr_change(tempstr, Chr(253), vbLf) 'mc 26aug99
            the_value = tempstr 'mc 26aug99
            GoSub update_cell_no_multiply 'mc 26aug99
         Case 16 + f_start_posn: Attr = 2: div_by = 1: last_year = 24: GoSub get_yfull: GoSub update_cell 'dgm 13/2/98
         Case 17 + f_start_posn: Attr = 2: div_by = 1: last_year = 36: GoSub get_yfull: GoSub update_cell 'dgm 13/2/98
         Case 18 + f_start_posn: Attr = 2: div_by = 1: last_year = 48: GoSub get_yfull: GoSub update_cell 'dgm 13/2/98
         Case 19 + f_start_posn: Attr = 2: div_by = 1: last_year = 60: GoSub get_yfull: GoSub update_cell 'dgm 13/2/98
         Case 20 + f_start_posn
            If Left(accounts, 1) = "&" Or Left(accounts, 4) = "JOB&" Then
               the_value = Pick.extract(gldata, 39, 0, 0)
            Else
               the_value = Pick.extract(glrec, 28, 0, 0)
            End If
            GoSub update_cell
         Case 21 + f_start_posn 'commit mth
            temp2 = f_month_one + the_mth
            temp = the_values(temp2, 3): div_by = 100: GoSub get_one: GoSub update_cell
         Case 22 + f_start_posn: Attr = 3: div_by = 100: last_year = 0: upto_mth = the_mth: GoSub get_ytd: GoSub update_cell 'commit ytd
         Case 23 + f_start_posn: Attr = 2: div_by = 1: last_year = 60: GoSub get_yfull: GoSub update_cell 'act+commit mth
            temp2 = f_month_one + the_mth
            temp = the_values(temp2, 1): div_by = 100: GoSub get_one: save_the_value = the_value
            temp = the_values(temp2, 3): div_by = 100: GoSub get_one: the_value = the_value + save_the_value: GoSub update_cell
         Case 24 + f_start_posn
            Attr = 1: div_by = 100: last_year = 0: upto_mth = the_mth: GoSub get_ytd: save_the_value = the_value 'act+commit ytd
            Attr = 3: div_by = 100: last_year = 0: upto_mth = the_mth: GoSub get_ytd: the_value = the_value + save_the_value: GoSub update_cell 'act+commit ytd
         Case 25 + f_start_posn: Attr = 1: div_by = 100: last_year = 0: upto_mth = 12: GoSub get_open: GoSub update_cell
         Case 26 + f_start_posn: Attr = 1: div_by = 100: last_year = -12: upto_mth = 12: GoSub get_open: GoSub update_cell
      End Select
   Next Ww
   Return
   
update_cell:
   If the_multiply_by_col <> 0 Then
     ''''temp = Excelsheet.Application.Cells(the_row, the_multiply_by_col)
     If temp <> "" Then
        If temp = "Y" Then temp = "-1"
        If IsNumeric(temp) And IsNumeric(the_value) Then the_value = the_value * CCur(temp) 'mc 03mar00
     End If
   End If
update_cell_no_multiply:
   ''''Excelsheet.Application.Cells(the_row + add_cnt, the_col).Value = the_value\
   ValSheet = Pick.replace(ValSheet, ws_number, the_row + add_cnt, the_col, CStr(the_value))
Return
    
get_one:
   If IsNumeric(temp) Then the_value = temp / div_by Else the_value = 0
Return
    
get_ytd:
   the_value = 0
   If Pick.extract(gldata, 1, 0, 0) = "B" Then
      If last_year >= 0 Then
         the_value = Pick.extractcur(gldata, 6, 1, 0)
      Else
         the_value = Pick.extractcur(gldata, 6, 2, 0)
      End If
   End If
   For m = Int((upto_mth) / 12) * 12 + 1 To upto_mth + 1
      temp = the_values(f_month_one + m - 1 + last_year, Attr)
      If IsNumeric(temp) Then
         the_value = the_value + temp
      End If
   Next m
   the_value = the_value / div_by
Return
    
get_yfull:
   the_value = 0
   For m = 1 To 12
       temp = the_values(f_month_one + m - 1 + last_year, Attr)
       If IsNumeric(temp) Then
          the_value = the_value + temp
       End If
    Next m
    the_value = the_value / div_by
Return

get_open:
   If Pick.extract(gldata, 1, 0, 0) = "C" Then
      the_value = 0
      Return
   End If
   If last_year >= 0 Then
      the_value = Pick.extractcur(gldata, 6, 1, 0)
   Else
      the_value = Pick.extractcur(gldata, 6, 2, 0)
   End If
   the_value = the_value / div_by
Return

get_temp2:
      Select Case cols(Ww)
         Case 3
         Case 4 To 15
            temp2 = temp2 - (cols(Ww) - 3)
         Case 16 To 38
            temp2 = temp2 + cols(Ww) - f_month_one - 2
         Case 39
         Case 40 To 51
             temp2 = temp2 - (cols(Ww) - 39)
         Case 52 To 74
             temp2 = temp2 + cols(Ww) - f_month_one - 38
     End Select
     Return

set_cell_value:
'     ColPos = 0
'     For i = 1 To the_head_row
'        ColPos = InStr(ColPos + 1, wsheet, "<tr", vbTextCompare)
'        tempstuff = Mid(wsheet, ColPos, 50)
'     Next i
'     For i = 1 To the_col
'        ColPos = InStr(ColPos + 1, wsheet, "<td", vbTextCompare)
'     Next i
'     ColEnd = InStr(ColPos, wsheet, "</td>", vbTextCompare)
'     wsheet = Left(wsheet, ColEnd - 1) & cell_value & Mid(wsheet, ColEnd)
'
'''''ExcelSheet.Application.Cells(the_head_row, the_col).Value = cell_value
     ValSheet = Pick.replace(ValSheet, ws_number, the_head_row, the_col, cell_value)
     Return

Err_Excelopen:
   Exit Function
   
End Function






Public Sub sr555_getvals(f_month_one As Integer, glrec As String, the_values() As Currency, isjob As Boolean)

Dim m As Integer, Attr As Integer, k As Integer
Dim N As Integer, last_att As Integer

    For m = 1 To 3
       Select Case m
          Case 1: Attr = 9 'actuals
          Case 2: Attr = 8
          Case 3: Attr = 27 'commits
       End Select
       For k = 1 To 12 'this year
          the_values(f_month_one + k - 1, m) = the_values(f_month_one + k - 1, m) + Pick.extractcur(glrec, Attr, k, 1)
       Next k
           
       N = 1
       For k = 13 To 24 'last year
          the_values(N, m) = the_values(N, m) + Pick.extractcur(glrec, Attr, k, 1)
          N = N + 1
       Next k
       last_att = 60
       If m = 2 Then last_att = 85
       For k = 25 To last_att 'next year
          the_values(f_month_one + k - 13, m) = the_values(f_month_one + k - 13, m) + Pick.extractcur(glrec, Attr, k, 1)
       Next k
    Next m
 
End Sub

Public Function SR555_RANGE(msa As Integer, logentry As String, OAC As String, GFROM As String, GTO As String, jobs() As String) As Long

Dim total_items As Long, pick_cnt As Long
Dim sentence As String

sentence = "sselect " & OAC & "job.l "
If GTO <> "" Then sentence = sentence & " with job <= """ & GTO & """"
If GFROM <> "" Then
If GTO <> "" Then sentence = sentence & " and "
   sentence = sentence & " with job >= """ & GFROM & """"
End If
total_items = d3.d3_select(logentry, sentence, jobs(), pick_cnt, 0, 0)
SR555_RANGE = total_items

End Function

Public Function SR555B(msa As Integer, logentry As String, gl_rep_hg As String, mth As Integer, borpl As String, soy As String, acmth As Integer) As String

Dim Xtra_Yrs As Integer, X As Integer
Dim WCHS As String, Pos As Integer, jobs() As String
Dim Ans As String, Hg_No As String, Gx As Integer, I As Integer, j As Integer
Dim Hg_Sts As String, Hg_Bds As String, Hg_Com_Sts As String, Hg_Pjs As String, Gl_Rep_Grp As String, Gmax As Integer
Dim Temp_Rep  As String, Hg_Ac As Integer, Gq As String, OAC As String
Dim Gl_Percent As String, Gl_Wch As String, Gl_Totonly, wpos As Integer, Usejob, Gl_Accts As String
Dim Ans1 As String, Ans2 As String, Gr, Cfrom, Cto, Scfrom As Integer, Scto As Integer, Xio As String, Borpl2 As String, Gmax2 As Integer
Dim Cls As Integer, Glr As String, Temp_Rec As String, Cmax2 As Integer, Scls As Integer, sc As Integer, GFROM As String, GTO As String
Dim Maxll As Integer, Ll As Integer, Gindx As Integer, Incls, C_Gl_Grp As String, Maxc As Integer, Cstart As Integer, Cend As Integer
Dim Crange As Integer, Cmpg2 As Currency, Incscl, Sfrom, Sto, Numg3, Cmpg3 As Currency, Gl_Grp As String, Send As Integer
Dim Srange As Integer, Ssrange As Integer, Instr, Lgq, Gq_Sbcl As String, Gq_Gr As String, Min As Integer, Max As Integer
Dim Gr__ As String, Xg__ As String, Limit_J__ As Integer, J__ As Integer, Limit_Jj__ As Integer, Scj__ As Integer, Scj__Sc As Integer, Uj As Integer
Dim Gq_Cls As String, Gl As String, Hg_Sts2 As String, Hg_Bds2 As String, Hg_Com_Sts2 As String, Hg_Pjs2 As String
Dim Max_Am As Integer, Atr As Integer, Glac As String, Cyr_Rem As Integer, Lyr_Rem As Integer, Nyr_Rem As Integer, L As Integer, L1 As Integer, Clp As Currency
Dim Gqsc As String, Gqgr As String, gqcl As String
Dim Gl_Per As Currency, Abud As String, Gq2 As String, Cc_Gl_Grp As String, Ccstart As Integer, Ccend As Integer, Ccrange As Integer
Dim Ssend As Integer, Glbuds As String, Abud2 As String
Dim database As String, rderr As Integer, temp As String
Dim CL_STS(39) As Currency, CLB(100) As Currency, CL_COM_STS(39) As Currency, CLAB(39) As Currency
Dim GEN_GRPS(11) As String, NO_GEN_GRPS(11) As Integer
Dim Gg As Currency, rmax As Integer, bpos As Integer, tempcur As Currency

'--------------------------------------------------------------------
' THIS SUBROUTINE IS THE CALCULATION PHASE OF TA555
'
' NOTE: IF ACTUALS, THEN GL A/C NUMBERS ARE INCREMENTED BY 'RPFLAG'
'--------------------------------------------------------------------
     database = Pick.extract(logentry, 2, 0, 0)

    If d3.d3_readstr(database, Ans, "DICT GEN.L", "XGRP") <> 0 Then Ans = ""
    GEN_GRPS(1) = Ans
    NO_GEN_GRPS(1) = Pick.dcount(Ans, Chr(253))
'
    Hg_No = Time()
    WCHS = ""

       Gx = 0: Temp_Rep = gl_rep_hg
201    Hg_Sts = "": Hg_Bds = "": Hg_Com_Sts = "": Hg_Pjs = ""
       For Hg_Ac = 1 To 999
          Gq = Pick.extract(gl_rep_hg, 18, Hg_Ac, 1)
          If Gq = "" Then GoTo 305
202       Ans = InStr(Gq, "P")
          If InStr(Gq, "*") Then OAC = Pick.field(Gq, "*", 1): Gq = Pick.field(Gq, "*", 2) Else OAC = ""
          Gl_Percent = Pick.extract(gl_rep_hg, 18, Hg_Ac, 2)
          If Not IsNumeric(Gl_Percent) Then Gl_Percent = "100"
          Gl_Wch = Pick.extract(gl_rep_hg, 18, Hg_Ac, 3)
          Gl_Totonly = Pick.extract(gl_rep_hg, 18, Hg_Ac, 4)
          If Gl_Totonly = "" Then Gl_Totonly = "Y"
          If Gl_Wch = "" Then
             wpos = 1
          Else
             If Pick.locate(Gl_Wch, WCHS, 1, 1, 0, wpos, "") = 0 Then
                WCHS = Pick.insert(WCHS, wpos, 0, 0, Gl_Wch)
             End If
             wpos = wpos + 1
          End If
          Usejob = 0
          If Mid$(Gq, 1, 3) = "RPT" Then
            Gq = Mid$(Gq, 4, 99)
            If d3.d3_readstr(database, Gl_Accts, OAC & "RTYPE", Gq, 2) <> 0 Then Gl_Accts = ""
            GoSub 320
            GoTo 304
          End If
          If Mid$(Gq, 1, 2) = "RC" Then
            Gq = Mid$(Gq, 3, 99)
            If d3.d3_readstr(database, Gl_Accts, OAC & "RCODE", Gq, 2) <> 0 Then Gl_Accts = ""
            GoSub 320
            GoTo 304
          End If
          If Mid$(Gq, 1, 2) = "RR" Then
            Gq = Mid$(Gq, 3, 99): Ans1 = Pick.field(Gq, "-", 1): Ans2 = Pick.field(Gq, "-", 2)
            Gr = Pick.field(Ans1, ".", 1): Cfrom = Pick.field(Ans1, ".", 2): Cto = Pick.field(Ans2, ".", 2)
            Scfrom = Pick.field(Ans1, ".", 3): Scto = Pick.field(Ans2, ".", 3)
            If d3.d3_readstr(database, Xio, "DICT " & OAC & "GEN.L.REPORT", "X" & Gr) <> 0 Then Xio = ""
            If d3.d3_readstr(database, Borpl2, "GEN.L.REPORT", Gr & ".0", 4) <> 0 Then Borpl2 = borpl
            Gmax2 = Pick.dcount(Xio, Chr(254))
            For Cls = 1 To Gmax2
              If Pick.extract(Xio, Cls, 1, 0) = "" Then Exit For
              If Pick.extract(Xio, Cls, 1, 0) > Cto Then Exit For
              If Pick.extract(Xio, Cls, 1, 0) >= Cfrom Then
                'If Scfrom = "" Then
                  'Glr = Gr & "." & Pick.extract(Xio, cls, 1, 0)
                  'If d3.d3_readstr(database, Temp_Rep, "DICT GL.R", Glr) <> 0 Then Temp_Rec = ""
                  'Call SR555B(logentry, "", "", Temp_Rep, "", ACMTH, Borpl2)
                  'Call PICKWT("TEMP.555", Hg_No & "*" & Glr, 3, Temp_Rep, 0)
                  'If Pick.locate(Glr, Gl_Rep_Hg, 25, 1, 0, pos, "") = 0 Then
                  '  Gl_Rep_Hg = Pick.insert(Gl_Rep_Hg, 25, -1, 0, Glr)
                  'End If
                'End If
                Cmax2 = Pick.dcount(Pick.extract(Xio, Cls, 0, 0), Chr(253))
                For Scls = 2 To Cmax2
                  sc = Pick.extract(Xio, Cls, Scls, 0)
                  'If Scfrom = "" Or (sc >= Scfrom And sc <= Scto) Then
                  '  Glr = Gr & "." & Pick.extract(Xio, cls, 1, 0) & "." & sc
                  '  If d3.d3_readstr(database, Temp_Rep, "DICT GL.R", Glr) <> 0 Then Temp_Rec = ""
                    'Call SR555B(logentry, "", "", Temp_Rep, "", ACMTH, Borpl2)
                    'Call PICKWT("TEMP.555", Hg_No & "*" & Glr, 3, Temp_Rep, 0)
                  '  If Pick.locate(Glr, Gl_Rep_Hg, 25, 1, 0, pos, "") = 0 Then
                  '    Gl_Rep_Hg = Pick.insert(Gl_Rep_Hg, 25, -1, 0, Glr)
                  '  End If
                  'End If
                Next Scls
              End If
            Next Cls
          End If
'
'========================================================
'
          If Mid$(Gq, 1, 3) = "JOB" Then Usejob = 1: Gq = Mid$(Gq, 4, 99) Else Usejob = 0
          If Left(Gq, 1) = "G" And InStr(Gq, "-") Then
           GFROM = Mid(Pick.field(Gq, ".", 1), 2, 99)
           GTO = Mid(Pick.field(Gq, ".", 2), 3, 99)
           If Usejob Then
              If SR555_RANGE(msa, logentry, OAC, GFROM, GTO, jobs()) = 0 Then GoTo 304
              Maxll = UBound(jobs)
              For Ll = 0 To Maxll
                 Gq = jobs(Ll): GoSub 500
              Next Ll
              GoTo 304
           Else
              If Pick.locate(CStr(GFROM), GEN_GRPS(1), 1, 1, 0, Gindx, "AR") = 0 Then
              End If
           End If
205        temp = Pick.extract(GEN_GRPS(1), 1, Gindx, 0)
           If Not (IsNumeric(temp)) Then GoTo 304
           Gg = CCur(temp)
           If IsNumeric(GTO) Then
              If Gg > CCur(GTO) Then GoTo 304
           End If
           If OAC = "" Then Maxll = NO_GEN_GRPS(1) Else Maxll = NO_GEN_GRPS(CInt(OAC) + 1)
           For Ll = 1 To Maxll
            If OAC = "" Then temp = GEN_GRPS(1) Else temp = GEN_GRPS(CInt(OAC) + 1)
            If Pick.extractcur(temp, 1, Ll, 0) = Gg Then
             Gq = Gg & ".0"
             GoSub 500
             GoTo 210
            End If
           Next Ll
210        Gindx = Gindx + 1
           GoTo 205
          End If
          If Left(Gq, 1) = "C" And InStr(Gq, "-") Then
           If Mid$(Gq, 2, 1) = "C" And Pick.field(Pick.field(Gq, "-", 2), ".", 1) <> Pick.field(Pick.field(Mid(Gq, 2, 99), "-", 1), ".", 1) Then
            Incls = 1: GFROM = Mid(Pick.field(Gq, ".", 1), 3, 99)
           Else
            Incls = 0: GFROM = Mid(Pick.field(Gq, ".", 1), 2, 99)
           End If
           GTO = Pick.field(Pick.field(Gq, "-", 2), ".", 1)
           Cfrom = Pick.field(Pick.field(Gq, "-", 1), ".", 2)
           Cto = Pick.field(Gq, ".", 3)
           If Usejob Then
              If SR555_RANGE(msa, logentry, OAC, GFROM, GTO, jobs()) = 0 Then
                 Maxll = 0
              Else
                 Maxll = UBound(jobs)
              End If
              GoTo 217
           End If
           If Pick.locate(CStr(GFROM), GEN_GRPS(1), 1, 1, 0, Gindx, "AR") = 0 Then
           End If
215        Gg = Pick.extractcur(GEN_GRPS(1), 1, Gindx, 0)
           If Gg = 0 Or Gg > GTO Then GoTo 304
           If Usejob Then
217         For Ll = 1 To Maxll
             Gg = jobs(Ll)
              If d3.d3_readstr(database, C_Gl_Grp, "DICT " & OAC & "JOB.L", "X" & Gg) <> 0 Then C_Gl_Grp = ""
              Maxc = Pick.dcount(C_Gl_Grp, Chr(254))
              If Incls Then
               Cstart = Cfrom: Cend = Cto
              Else
               If Gg = GFROM Then Cstart = Cfrom Else Cstart = 1
               If Gg = GTO Then Cend = Cto Else Cend = Pick.extract(C_Gl_Grp, Maxc, 1, 0)
              End If
              For Crange = 1 To Maxc
               If Pick.extract(C_Gl_Grp, Crange, 1, 0) = "" Then Exit For
               If Pick.extract(C_Gl_Grp, Crange, 1, 0) > Cend Then Exit For
               If Pick.extract(C_Gl_Grp, Crange, 1, 0) >= Cstart Then
                Gq = Gg & "." & Pick.extract(C_Gl_Grp, Crange, 1, 0)
                GoSub 500
               End If
              Next Crange
'MCO 04JAN01              GOTO 220
'             END
            Next Ll
            GoTo 304
           Else
            If OAC = "" Then Maxll = NO_GEN_GRPS(1) Else Maxll = NO_GEN_GRPS(CInt(OAC) + 1)
            For Ll = 1 To Maxll
             If OAC = "" Then temp = GEN_GRPS(1) Else temp = GEN_GRPS(CInt(OAC) + 1)
             Cmpg2 = Pick.extractcur(temp, 1, Ll, 0)
             If Cmpg2 = Gg Then
              If d3.d3_readstr(database, C_Gl_Grp, "DICT " & OAC & "GEN.L", "X" & Gg) <> 0 Then C_Gl_Grp = ""
              If Incls Then
               Cstart = Cfrom: Cend = Cto
              Else
               If Gg = GFROM Then Cstart = Cfrom Else Cstart = 1
               If Gg = GTO Then Cend = Cto Else Cend = Pick.dcount(C_Gl_Grp, Chr(254))
              End If
              For Crange = Cstart To Cend
               If Pick.extractint(C_Gl_Grp, Crange, 1, 0) = 0 Then
                Gq = Gg & "." & Crange
                GoSub 500
               End If
              Next Crange
              GoTo 220
             End If
            Next Ll
           End If
220        Gindx = Gindx + 1
           GoTo 215
          End If
          If Left(Gq, 1) = "S" And InStr(Gq, "-") Then
           If Mid$(Gq, 2, 1) = "S" Then
            Incscl = 1: GFROM = Mid$(Pick.field(Gq, ".", 1), 3, 99)
           Else
            Incscl = 0: GFROM = Mid$(Pick.field(Gq, ".", 1), 2, 99)
           End If
           GTO = Pick.field(Pick.field(Gq, "-", 2), ".", 1)
           Cfrom = Pick.field(Gq, ".", 2)
           Cto = Pick.field(Gq, ".", 4)
           Sfrom = Pick.field(Pick.field(Gq, "-", 1), ".", 3)
           Sto = Pick.field(Gq, ".", 5)
           If Usejob Then
              If SR555_RANGE(msa, logentry, OAC, GFROM, GTO, jobs()) = 0 Then
                 Maxll = 0
              Else
                 Maxll = UBound(jobs)
              End If
              Ll = 0
              GoTo 226
           Else
              If Pick.locate(CStr(GFROM), GEN_GRPS(1), 1, 1, 0, Gindx, "AR") = 0 Then
              End If
           End If
225        If Usejob Then
226           Ll = Ll + 1
              If Ll > Maxll Then GoTo 304
              Gg = jobs(Ll)
              GoTo A226
           End If
           temp = Pick.extract(GEN_GRPS(1), 1, Gindx, 0)
           If Not IsNumeric(temp) Then GoTo 304
           Gg = CCur(temp)
           If OAC = "" Then Numg3 = NO_GEN_GRPS(1) Else Numg3 = NO_GEN_GRPS(CInt(OAC) + 1)
           If IsNumeric(GTO) Then
              If Gg > CCur(GTO) Then GoTo 304
           End If
           For Ll = 1 To Numg3
            If OAC = "" Then temp = GEN_GRPS(1) Else temp = GEN_GRPS(CInt(OAC) + 1)
            Cmpg3 = Pick.extractcur(temp, 1, Ll, 0)
            If Cmpg3 = Gg Then
A226:        If Usejob Then
                If d3.d3_readstr(database, Gl_Grp, "DICT " & OAC & "JOB.L", "X" & Gg) <> 0 Then Gl_Grp = ""
             Else
                If d3.d3_readstr(database, Gl_Grp, "DICT " & OAC & "GEN.L", "X" & Gg) <> 0 Then Gl_Grp = ""
             End If
             Maxc = Pick.dcount(Gl_Grp, Chr(254))
             If Incscl Then
              Cstart = Cfrom: Cend = Cto
             Else
              If Gg = GFROM Then Cstart = Cfrom Else Cstart = 1
              If Usejob Then
               If Gg = GTO Then Cend = Cto Else Cend = Pick.extract(Gl_Grp, Maxc, 1, 0)
              Else
               If Gg = GTO Then Cend = Cto Else Cend = Pick.dcount(Gl_Grp, Chr(254))
              End If
             End If
             If Usejob Then
              For Crange = 1 To Maxc
               If Pick.extract(Gl_Grp, Crange, 1, 0) = "" Then Exit For
               If Pick.extract(Gl_Grp, Crange, 1, 0) > Cend Then Exit For
               If Pick.extract(Gl_Grp, Crange, 1, 0) >= Cstart Then
                Send = Pick.dcount(Pick.extract(Gl_Grp, Crange, 0, 0), Chr(253))
                For Srange = 2 To Send
                  If Pick.extract(Gl_Grp, Crange, Srange, 0) <> "" Then
                   Ssrange = Pick.extract(Gl_Grp, Crange, Srange, 0)
                   If Gg = GFROM And Crange = Cfrom Then
                    If Ssrange < Sfrom Then GoTo 227
                   End If
                   If Gg = GTO And Crange = Cto Then
                      If Ssrange > Sto Then GoTo 304
                   End If
                   If Incscl Then
                      If Ssrange < Sfrom Or Ssrange > Sto Then GoTo 227
                   End If
                   Gq = Gg & "." & Pick.extract(Gl_Grp, Crange, 1, 0) & "." & Ssrange
                   GoSub 500
                   End If
227             Next Srange
               End If
              Next Crange
             Else
              For Crange = Cstart To Cend
               If Pick.extractint(Gl_Grp, Crange, 1, 0) = 0 Then
                Send = Pick.dcount(Pick.extract(Gl_Grp, Crange, 0, 0), Chr(253))
                For Srange = 2 To Send
                  If Pick.extract(Gl_Grp, Crange, Srange, 0) <> "" Then
                   Ssrange = Pick.extract(Gl_Grp, Crange, Srange, 0)
                   If Gg = GFROM And Crange = Cfrom Then
                    If Ssrange < Sfrom Then GoTo 228
                   End If
                   If Gg = GTO And Crange = Cto Then
                      If Ssrange > Sto Then GoTo 304
                   End If
                   If Incscl Then
                      If Ssrange < Sfrom Or Ssrange > Sto Then GoTo 228
                   End If
                   Gq = Gg & "." & Crange & "." & Ssrange
                   GoSub 500
                   End If
228             Next Srange
               End If
              Next Crange
             End If
             GoTo 230
            End If
           Next Ll
230        Gindx = Gindx + 1
           GoTo 225
          End If
'IF NOT(GQ MATCH '"."1N0N') AND NOT(GQ MATCH '"."1N0N"."1N0N') THE
          If Not (Left(Gq, 1) = "." And IsNumeric(Mid(Gq, 2))) And Not (Left(Gq, 1) = "." And InStr(Mid(Gq, 2), ".") <> 0 And IsNumeric(Mid(Gq, 2))) Then
             If InStr(Gq, "..") = 0 Then
' ACCTS FORM 1.0 1.1 OR 1.1.1
                If InStr(Gq, "]") Then
                 Gq = Mid$(Gq, 1, Len(Gq) - 1)
                 GoSub 500
                 Lgq = Gq
                 For j = 1 To 9
                  Gq = Lgq & j: GoSub 500
                 Next j
                Else
                 GoSub 500
                End If
              Else  '** GO THRU ALL CLS IN ALL GRPS **
' ACCTS FORM ..1
                Gq_Sbcl = Pick.field(Gq, ".", 3): Gq_Gr = Pick.field(Gq, ".", 1)
                If Usejob Then
                   If Gq_Gr <> "" Then
                      If SR555_RANGE(msa, logentry, OAC, Gq_Gr, Gq_Gr, jobs()) = 0 Then
                         Max = 0
                      Else
                         Max = UBound(jobs)
                      End If
                   Else
                      If SR555_RANGE(msa, logentry, OAC, "", "", jobs()) = 0 Then
                         Max = 0
                      Else
                         Max = UBound(jobs)
                      End If
                   End If
                   Min = 1
                   GoTo 292
                Else
                   Max = NO_GEN_GRPS(OAC + 1)
                End If
                Min = 1
                If Gq_Gr <> "" Then
                   If Usejob Then
                      '???If pick.locate(Gq_Gr, jobs, 1, 1, 0, Min, "") = 0 Then Min = 1
                   Else
                      If Pick.locate(Gq_Gr, GEN_GRPS(OAC + 1), 1, 1, 0, Min, "") = 0 Then Min = 1
                   End If
                   Max = Min
                End If
292             For I = Min To Max
                 If Usejob Then Gr__ = jobs(I) Else Gr__ = Pick.extract(GEN_GRPS(OAC + 1), 1, I, 0)
                 If Gq_Gr <> "" And Gr__ <> Gq_Gr Then GoTo 303
                 If Usejob Then
                    If d3.d3_readstr(database, Xg__, "DICT " & OAC & "JOB.L", "X" & Gr__) <> 0 Then Xg__ = ""
                 Else
                    If d3.d3_readstr(database, Xg__, "DICT " & OAC & "GEN.L", "X" & Gr__) <> 0 Then Xg__ = ""
                 End If
                 Limit_J__ = Pick.dcount(Xg__, Chr(254))
                 For J__ = 1 To Limit_J__
                  Limit_Jj__ = Pick.dcount(Pick.extract(Xg__, J__, 0, 0), Chr(253))
                  For Scj__ = 2 To Limit_Jj__
                   Scj__Sc = Pick.extract(Xg__, J__, Scj__, 0)
                   If Scj__Sc = "" Then GoTo 301
                   If Scj__Sc > Gq_Sbcl Then GoTo 301
                   If Scj__Sc = Gq_Sbcl Then
                    If Usejob Then Uj = Pick.extract(Xg__, J__, 1, 0) Else Uj = J__
                    Gq = Gr__ & "." & Uj & "." & Gq_Sbcl
                    GoSub 500
                   End If
                  Next Scj__
301              Next J__
303             Next I
             End If
           Else
' ACCTS FORM .1 OR .1.1
             Gq_Cls = Gq
             If Usejob Then
                If SR555_RANGE(msa, logentry, OAC, "", "", jobs()) = 0 Then
                   Max = 0
                Else
                   Max = UBound(jobs)
                End If
             Else
                If OAC = "" Then Max = NO_GEN_GRPS(1) Else Max = NO_GEN_GRPS(CInt(OAC) + 1)
             End If
             For I = 1 To Max
                If OAC = "" Then temp = GEN_GRPS(1) Else temp = GEN_GRPS(CInt(OAC) + 1)
                If Usejob Then Gq = jobs(I) & Gq_Cls Else Gq = Pick.extract(temp, 1, I, 0) & Gq_Cls
                GoSub 500
             Next I
          End If
304     Next Hg_Ac
305     GoSub 330
        SR555B = gl_rep_hg
        Exit Function '* TO CALLING PROGRAM **
'
320  If Gl_Accts = "" Then rmax = 0 Else rmax = Pick.dcount(Pick.extract(Gl_Accts, 1, 0, 0), Chr(253))
     For sc = 1 To rmax
       Gq = Pick.extract(Gl_Accts, 1, sc, 0)
       'If Gx Then
         'If d3.d3_readstr(database, Gl, "DICT GEN.L", Pick.extract(Gl_Accts, 1, Sc, 0)) <> 0 Then Gl = ""
       'Else
          If d3.d3_readstr(database, Gl, "GEN.L", Pick.extract(Gl_Accts, 1, sc, 0)) <> 0 Then Gl = ""
       'End If
       Hg_Sts2 = "": Hg_Bds2 = "": Hg_Com_Sts2 = "": Hg_Pjs2 = ""
       GoSub 550
       GoSub 340
     Next sc
     Return
'
330  If Pick.Index(gl_rep_hg, Chr(254), Gx * 50 + 31) Then
        gl_rep_hg = Mid$(gl_rep_hg, 1, Pick.Index(gl_rep_hg, Chr(254), Gx * 50 + 31) - 1)
     End If
     gl_rep_hg = Pick.replace(gl_rep_hg, Gx * 50 + 8, 0, 0, Pick.extract(Hg_Bds, 1, 0, 0))
     gl_rep_hg = Pick.replace(gl_rep_hg, Gx * 50 + 9, 0, 0, Pick.extract(Hg_Sts, 1, 0, 0))
     gl_rep_hg = Pick.replace(gl_rep_hg, Gx * 50 + 27, 0, 0, Pick.extract(Hg_Com_Sts, 1, 0, 0))
     gl_rep_hg = Pick.replace(gl_rep_hg, Gx * 50 + 28, 0, 0, Pick.extract(Hg_Pjs, 1, 0, 0))
     If WCHS <> "" Then
        Max_Am = Pick.dcount(WCHS, Chr(254))
        For wpos = 1 To Max_Am
           Hg_Bds = Pick.replace(Hg_Bds, wpos + 1, 1, 1, Pick.extract(Hg_Bds, wpos + 1, 1, 1) + 0) ' mandatory so SR555C can detect data applicable)
           Atr = Gx * 50 + 29: gl_rep_hg = Pick.replace(gl_rep_hg, Atr + wpos * 4, 0, 0, Pick.extract(Hg_Bds, wpos + 1, 0, 0))
           Atr = Gx * 50 + 30: gl_rep_hg = Pick.replace(gl_rep_hg, Atr + wpos * 4, 0, 0, Pick.extract(Hg_Sts, wpos + 1, 0, 0))
           Atr = Gx * 50 + 31: gl_rep_hg = Pick.replace(gl_rep_hg, Atr + wpos * 4, 0, 0, Pick.extract(Hg_Com_Sts, wpos + 1, 0, 0))
           Atr = Gx * 50 + 32: gl_rep_hg = Pick.replace(gl_rep_hg, Atr + wpos * 4, 0, 0, Pick.extract(Hg_Pjs, wpos + 1, 0, 0))
        Next wpos
     End If
     Return
'
340  Glac = Pick.extract(Gl_Accts, 1, sc, 0)
     If Gl_Totonly = "Y" Then
        '???Delete "TEMP.555", Hg_No & "*" & Glac
     Else
        'If Gx Then
        '  If d3.d3_readstr(database, Temp_Rep, "TEMP", Hg_No & "*" & Glac) <> 0 Then Temp_Rep = ""
        'End If
        Temp_Rep = Pick.replace(Temp_Rep, 2, 0, 0, Glac & " " & Pick.extract(Gl, 2, 0, 0))
        Temp_Rep = Pick.replace(Temp_Rep, Gx * 50 + 8, 0, 0, Pick.extract(Hg_Bds2, 1, 0, 0))
        Temp_Rep = Pick.replace(Temp_Rep, Gx * 50 + 9, 0, 0, Pick.extract(Hg_Sts2, 1, 0, 0))
        Temp_Rep = Pick.replace(Temp_Rep, Gx * 50 + 27, 0, 0, Pick.extract(Hg_Com_Sts2, 1, 0, 0))
        Temp_Rep = Pick.replace(Temp_Rep, Gx * 50 + 28, 0, 0, Pick.extract(Hg_Pjs2, 1, 0, 0))
        If WCHS <> "" Then
           Max_Am = Pick.dcount(WCHS, Chr(254))
           For wpos = 1 To Max_Am
              Hg_Bds2 = Pick.replace(Hg_Bds2, wpos + 1, 1, 1, Pick.extract(Hg_Bds2, wpos + 1, 1, 1) + 0) ' mandatory so SR555C can detect data applicable)
              Atr = Gx * 50 + 29: Temp_Rep = Pick.replace(Temp_Rep, Atr + wpos * 4, 0, 0, Pick.extract(Hg_Bds2, wpos + 1, 0, 0))
              Atr = Gx * 50 + 30: Temp_Rep = Pick.replace(Temp_Rep, Atr + wpos * 4, 0, 0, Pick.extract(Hg_Sts2, wpos + 1, 0, 0))
              Atr = Gx * 50 + 31: Temp_Rep = Pick.replace(Temp_Rep, Atr + wpos * 4, 0, 0, Pick.extract(Hg_Com_Sts2, wpos + 1, 0, 0))
              Atr = Gx * 50 + 32: Temp_Rep = Pick.replace(Temp_Rep, Atr + wpos * 4, 0, 0, Pick.extract(Hg_Pjs2, wpos + 1, 0, 0))
           Next wpos
        End If
        'Call PICKWT("TEMP.555", Hg_No & "*" & Glac, 3, Temp_Rep, 0)
        If Pick.locate(Glac, gl_rep_hg, 25, 1, 0, Pos, "") = 0 Then
          gl_rep_hg = Pick.insert(gl_rep_hg, 25, -1, 0, Glac)
        End If
     End If
     Return
'
' PROCESS ACCTS
'
500 If Usejob Then
      If d3.d3_readstr(database, Gl, OAC & "JOB.L", Gq) <> 0 Then Return
    Else
      'If Gx Then
       'If d3.d3_readstr(database, Gl, Oac & "GEN.L." & Pick.extract(Validyrs, 1, Gx, 0), Gq) <> 0 Then Return
      'Else
       If d3.d3_readstr(database, Gl, OAC & "GEN.L", Gq) <> 0 Then Return
      'End If
    End If
    If Usejob Then
       Gl = Pick.replace(Gl, 9, 0, 0, Pick.extract(Gl, 59, 0, 0))
       Gl = Pick.replace(Gl, 7, 0, 0, "A")
       Gl = Pick.replace(Gl, 6, 0, 0, "0")
       Gl = Pick.replace(Gl, 8, 1, 0, Int(Pick.extractcur(Gl, 24, 1, 0) / 100))
       Gl = Pick.replace(Gl, 8, 2, 0, Int(Pick.extractcur(Gl, 24, 2, 0) / 100))
       Gl = Pick.replace(Gl, 8, 3, 0, Int(Pick.extractcur(Gl, 24, 3, 0) / 100))
       Gl = Pick.replace(Gl, 32, 0, 0, Pick.extract(Gl, 27, 0, 0))
       For X = 1 To acmth
          Gl = Pick.replace(Gl, 32, 0, 0, CStr(Pick.extractcur(Gl, 32, 0, 0) - (Pick.extractcur(Gl, 89, X, 0) + Pick.extractcur(Gl, 89, (acmth * 2) + X, 0))))
       Next X
       Gl = Pick.replace(Gl, 35, 0, 0, Pick.extract(Gl, 89, 0, 0))
       For X = 1 To Xtra_Yrs
          Gl = Pick.replace(Gl, 38, X, 0, Int(Pick.extract(Gl, 38, X, 0) / 100))
       Next X
    End If
' BDS
550 If Pick.extract(Gl, 7, 0, 0) = "A" Then
      CLB(1) = Round(Pick.extractcur(Gl, 8, 1, 0) / acmth)
      CLB(acmth + 1) = Round(Pick.extractcur(Gl, 8, 2, 0) / acmth)
      CLB(acmth * 2 + 1) = Round(Pick.extractcur(Gl, 8, 3, 0) / acmth)
      Cyr_Rem = Pick.extractcur(Gl, 8, 1, 0) - CLB(1) * acmth
      Lyr_Rem = Pick.extractcur(Gl, 8, 2, 0) - CLB(acmth + 1) * acmth
      Nyr_Rem = Pick.extractcur(Gl, 8, 3, 0) - CLB(acmth * 2 + 1) * acmth
      For L = 2 To acmth
       CLB(L) = CLB(1)
       CLB(L + acmth) = CLB(acmth + 1)
       CLB(L + acmth * 2) = CLB(acmth * 2 + 1)
      Next L
      CLB(acmth) = CLB(acmth) + Cyr_Rem
      CLB(2 * acmth) = CLB(2 * acmth) + Lyr_Rem
      CLB(3 * acmth) = CLB(3 * acmth) + Nyr_Rem
      For X = 1 To Xtra_Yrs
         L1 = (X + 2) * acmth
         CLB(L1 + 1) = Round(Pick.extractcur(Gl, 38, X, 0) / acmth)
         Nyr_Rem = Pick.extract(Gl, 38, X, 0) - CLB(L1 + 1) * acmth
         For L = 2 To acmth
          CLB(L1 + L) = CLB(L1 + 1)
         Next L
         CLB((X + 3) * acmth) = CLB((X + 3) * acmth) + Nyr_Rem
      Next X
    Else
      For L = 1 To acmth * 3
       CLB(L) = Pick.extractcur(Gl, 8, L, 0)
      Next L
      For X = 1 To acmth * Xtra_Yrs
       CLB(L) = Pick.extractcur(Gl, 38, X, 0)
       L = L + 1
      Next X
    End If
    Clp = Pick.extractcur(Gl, 39, 0, 0) ' projection
    If Usejob = 0 Then GoSub 600
' STS INIT ATTR 9
    For L = 1 To acmth * 3
      CL_STS(L) = Pick.extractcur(Gl, 9, L, 0)
      CL_COM_STS(L) = Pick.extractcur(Gl, 35, L, 0)
    Next L
' ADD NOTIONAL ADJUSTMENTS
'    If MTH > ACMTH Then Fyr = ACMTH Else Fyr = 0
'    Maxadj = Pick.dcount(ADJUST, Chr(254))
'    For Mm = 2 To Maxadj
'      Adjac = Pick.extract(ADJUST, Mm, 1, 0)
'      Gqgr = pick.field(Gq, ".", 1): Adgr = pick.field(Adjac, ".", 1)
'      Gqcl = pick.field(Gq, ".", 2): Adcl = pick.field(Adjac, ".", 2)
'      Gqsc = pick.field(Gq, ".", 3): Adsc = pick.field(Adjac, ".", 3)
'      If Gqsc <> "" Then      ' SUBCLASS
'        If Gq = Adjac Then
'560       CL_STS(MTH + Fyr) = CL_STS(Pick.extract(MTH + Fyr) + ADJUST, Mm, 2)
'        End If
'      Else
'        If Gqgr = Adgr Then     ' GROUP LEVEL
'          If Gqcl = 0 Then GoTo 560 Else
'            If Gqcl = Adcl Then GoTo 560      ' ELSE IGNORE
'          End If
'        End If
'      End If
'    Next Mm
'
'-------------------------------------------------------------------------
' Note Well:  Use of OCONV/pick.iconv in following calculations is to avoid
' arithmetic problems when dealing with numbers in excess of 140 million
' (and working to 4 decimal accuracy - standard PICK)
'-------------------------------------------------------------------------
'
    
    Gl_Per = CCur(Gl_Percent) / 100
    For L = 1 To acmth * 3
       If Gl_Totonly = "Y" Then
          Hg_Sts = Pick.replace(Hg_Sts, wpos, L, 0, CStr(Round((Pick.extractcur(Hg_Sts, wpos, L, 0) / 100 + CL_STS(L) / 100 * Gl_Per) * 100)))
          Hg_Com_Sts = Pick.replace(Hg_Com_Sts, wpos, L, 0, CStr(Round((Pick.extractcur(Hg_Com_Sts, wpos, L, 0) / 100 + CL_COM_STS(L) / 100 * Gl_Per) * 100)))
          Hg_Bds = Pick.replace(Hg_Bds, wpos, L, 1, CStr(Round((Pick.extractcur(Hg_Bds, wpos, L, 1) / 100 + CLB(L) / 100 * Gl_Per) * 100)))
       Else
          Hg_Sts2 = Pick.replace(Hg_Sts2, wpos, L, 0, CStr(Round((CL_STS(L) / 100 * Gl_Per) * 100)))
          Hg_Com_Sts2 = Pick.replace(Hg_Com_Sts2, wpos, L, 0, CStr(Round((CL_COM_STS(L) / 100 * Gl_Per) * 100)))
          Hg_Bds2 = Pick.replace(Hg_Bds2, wpos, L, 0, CStr(Round((CLB(L) / 100 * Gl_Per) * 100)))
       End If
       If L <= acmth Then
          If Gl_Totonly = "Y" Then
             Hg_Bds = Pick.replace(Hg_Bds, wpos, L, 2, CStr(Round((Pick.extractcur(Hg_Bds, wpos, L, 2) / 100 + CLAB(L) / 100 * Gl_Per) * 100)))
          Else
            Hg_Bds2 = Pick.replace(Hg_Bds2, wpos, L, 2, CStr(Round((CLB(L) / 100 * Gl_Per) * 100)))
          End If
       End If
    Next L
    For L = (acmth * 3) + 1 To acmth * (3 + Xtra_Yrs)
       If Gl_Totonly = "Y" Then
          Hg_Bds = Pick.replace(Hg_Bds, wpos, L, 0, CStr(Round((Pick.extractcur(Hg_Bds, wpos, L, 0) / 100 + CLB(L) / 100 * Gl_Per) * 100)))
       Else
          Hg_Bds2 = Pick.replace(Hg_Bds2, wpos, L, 0, CStr(Round((CLB(L) / 100 * Gl_Per) * 100)))
       End If
    Next L
    If borpl = "B" Or Mid$(Pick.extract(gl_rep_hg, 20, 0, 0), 1, 1) = "Y" Then
       If Gl_Totonly = "Y" Then
          Hg_Sts = Pick.replace(Hg_Sts, wpos, acmth * 3 + 1, 0, CStr(Round((Pick.extractcur(Hg_Sts, wpos, acmth * 3 + 1, 0) / 100 + Pick.extractcur(Gl, 6, 1, 0) / 100 * Gl_Per) * 100)))
          Hg_Com_Sts = Pick.replace(Hg_Com_Sts, wpos, acmth * 3 + 1, 0, CStr(Round((Pick.extractcur(Hg_Com_Sts, wpos, acmth * 3 + 1, 0) / 100 + Pick.extract(Gl, 32, 1, 0) / 100 * Gl_Per) * 100)))
          Hg_Sts = Pick.replace(Hg_Sts, wpos, acmth * 3 + 2, 0, CStr(Round((Pick.extractcur(Hg_Sts, wpos, acmth * 3 + 2, 0) / 100 + Pick.extractcur(Gl, 6, 2, 0) / 100 * Gl_Per) * 100)))
          Hg_Com_Sts = Pick.replace(Hg_Com_Sts, wpos, acmth * 3 + 2, 0, CStr(Round((Pick.extractcur(Hg_Com_Sts, wpos, acmth * 3 + 2, 0) / 100 + Pick.extractcur(Gl, 32, 2, 0) / 100 * Gl_Per) * 100)))
       Else
          Hg_Sts2 = Pick.replace(Hg_Sts2, wpos, acmth * 3 + 1, 0, CStr(Round((Pick.extractcur(Gl, 6, 1, 0) / 100 * Gl_Per) * 100)))
          Hg_Com_Sts2 = Pick.replace(Hg_Com_Sts2, wpos, acmth * 3 + 1, 0, CStr(Round((Pick.extractcur(Gl, 32, 1, 0) / 100 * Gl_Per) * 100)))
          Hg_Sts2 = Pick.replace(Hg_Sts2, wpos, acmth * 3 + 2, 0, CStr(Round((Pick.extractcur(Gl, 6, 2, 0) / 100 * Gl_Per) * 100)))
          Hg_Com_Sts2 = Pick.replace(Hg_Com_Sts2, wpos, acmth * 3 + 2, 0, CStr(Round((Pick.extractcur(Gl, 32, 2, 0) / 100 * Gl_Per) * 100)))
       End If
       If mth > acmth Then
          For L = 1 To acmth
             If Gl_Totonly = "Y" Then
                Hg_Sts = Pick.replace(Hg_Sts, wpos, acmth * 3 + 1, 0, CStr(Round((Pick.extractcur(Hg_Sts, wpos, acmth * 3 + 1, 0) / 100 + CL_STS(L) / 100 * Gl_Per) * 100)))
                Hg_Sts = Pick.replace(Hg_Sts, wpos, acmth * 3 + 2, 0, CStr(Round((Pick.extractcur(Hg_Sts, wpos, acmth * 3 + 2, 0) / 100 + CL_STS(acmth + L) / 100 * Gl_Per) * 100)))
                Hg_Com_Sts = Pick.replace(Hg_Com_Sts, wpos, acmth * 3 + 1, 0, CStr(Round((Pick.extractcur(Hg_Com_Sts, wpos, acmth * 3 + 1, 0) / 100 + CL_COM_STS(L) / 100 * Gl_Per) * 100)))
                Hg_Com_Sts = Pick.replace(Hg_Com_Sts, wpos, acmth * 3 + 2, 0, CStr(Round((Pick.extractcur(Hg_Com_Sts, wpos, acmth * 3 + 2, 0) / 100 + CL_COM_STS(acmth + L) / 100 * Gl_Per) * 100)))
             Else
                Hg_Sts2 = Pick.replace(Hg_Sts2, wpos, acmth * 3 + 1, 0, CStr(Round((Pick.extractcur(Hg_Sts2, wpos, acmth * 3 + 1, 0) / 100 + CL_STS(L) / 100 * Gl_Per) * 100)))
                Hg_Sts2 = Pick.replace(Hg_Sts2, wpos, acmth * 3 + 2, 0, CStr(Round((Pick.extractcur(Hg_Sts2, wpos, acmth * 3 + 2, 0) / 100 + CL_STS(acmth + L) / 100 * Gl_Per) * 100)))
                Hg_Com_Sts2 = Pick.replace(Hg_Com_Sts2, wpos, acmth * 3 + 1, 0, CStr(Round((Pick.extractcur(Hg_Com_Sts2, wpos, acmth * 3 + 1, 0) / 100 + CL_COM_STS(L) / 100 * Gl_Per) * 100)))
                Hg_Com_Sts2 = Pick.replace(Hg_Com_Sts2, wpos, acmth * 3 + 2, 0, CStr(Round((Pick.extractcur(Hg_Com_Sts2, wpos, acmth * 3 + 2, 0) / 100 + CL_COM_STS(acmth + L) / 100 * Gl_Per) * 100)))
             End If
          Next L
       End If
    Else
       If Gl_Totonly = "Y" Then
          Hg_Com_Sts = Pick.replace(Hg_Com_Sts, wpos, acmth * 3 + 1, 0, CStr(Round((Pick.extractcur(Hg_Com_Sts, wpos, acmth * 3 + 1, 0) / 100 + Pick.extractcur(Gl, 32, 1, 0) / 100 * Gl_Per) * 100)))
          Hg_Com_Sts = Pick.replace(Hg_Com_Sts, wpos, acmth * 3 + 2, 0, CStr(Round((Pick.extractcur(Hg_Com_Sts, wpos, acmth * 3 + 2, 0) / 100 + Pick.extractcur(Gl, 32, 2, 0) / 100 * Gl_Per) * 100)))
       Else
          Hg_Com_Sts2 = Pick.replace(Hg_Com_Sts2, wpos, acmth * 3 + 1, 0, CStr(Round((Pick.extractcur(Gl, 32, 1, 0) / 100 * Gl_Per) * 100)))
          Hg_Com_Sts2 = Pick.replace(Hg_Com_Sts2, wpos, acmth * 3 + 2, 0, CStr(Round((Pick.extractcur(Gl, 32, 2, 0) / 100 * Gl_Per) * 100)))
       End If
       If mth > acmth Then
          For L = 1 To acmth
             If Gl_Totonly = "Y" Then
'                HG.STS<WPOS,ACMTH*3+1> = pick.iconv(pick.oconv(HG.STS<WPOS,ACMTH*3+1>,'MD2') + pick.oconv(CL.STS(L),'MD2')*GL.PER,'MD2')
                Hg_Com_Sts = Pick.replace(Hg_Com_Sts, wpos, acmth * 3 + 1, 0, CStr(Round((Pick.extractcur(Hg_Com_Sts, wpos, acmth * 3 + 1, 0) / 100 + CL_COM_STS(L) / 100 * Gl_Per) * 100)))
             Else
'                HG.STS2<WPOS,ACMTH*3+1> = pick.iconv(pick.oconv(HG.STS2<WPOS,ACMTH*3+1>,'MD2') + pick.oconv(CL.STS(L),'MD2')*GL.PER,'MD2')
                Hg_Com_Sts2 = Pick.replace(Hg_Com_Sts2, wpos, acmth * 3 + 1, 0, CStr(Round((Pick.extractcur(Hg_Com_Sts2, wpos, acmth * 3 + 1, 0) / 100 + CL_COM_STS(L) / 100 * Gl_Per) * 100)))
             End If
          Next L
       End If
    End If
    If Gl_Totonly = "Y" Then
       Hg_Pjs = Pick.replace(Hg_Pjs, wpos, 0, 0, CStr(Round((Pick.extractcur(Hg_Pjs, wpos, 0, 0) / 100 + Clp / 100 * Gl_Per) * 100)))
    Else
       Hg_Pjs2 = Pick.replace(Hg_Pjs2, wpos, 0, 0, CStr(Round((Clp / 100 * Gl_Per) * 100)))
    End If
    Return
'
600 Abud = 0
    Gqsc = Pick.field(Gq, ".", 3)
    If Gqsc <> "" Then
      Gq2 = Gq: GoSub 620
    Else
      Gqgr = Pick.field(Gq, ".", 1)
      gqcl = Pick.field(Gq, ".", 2)
      If d3.d3_readstr(database, Cc_Gl_Grp, "DICT " & OAC & "GEN.L", "X" & Gqgr) <> 0 Then Cc_Gl_Grp = ""
      If gqcl = "0" Then
       Ccstart = 1: Ccend = Pick.dcount(Cc_Gl_Grp, Chr(254))
      Else
       Ccstart = gqcl: Ccend = gqcl
      End If
      For Ccrange = Ccstart To Ccend
       Ssend = Pick.dcount(Pick.extract(Cc_Gl_Grp, Ccrange, 0, 0), Chr(253))
       For Ssrange = 2 To Ssend
        If Pick.extract(Cc_Gl_Grp, Ccrange, Ssrange, 0) <> "" Then
         Gq2 = Gqgr & "." & Ccrange & "." & Pick.extract(Cc_Gl_Grp, Ccrange, Ssrange, 0)
         GoSub 620
        End If
       Next Ssrange
      Next Ccrange
    End If
    If Pick.extract(Gl, 7, 0, 0) = "A" Then
      CLAB(1) = Round(Pick.extractcur(Abud, 1, 0, 0) / acmth)
      Cyr_Rem = Pick.extractcur(Abud, 1, 0, 0) - CLAB(1) * acmth
      For L = 2 To acmth
       CLAB(L) = CLAB(1)
      Next L
      CLAB(acmth) = CLAB(acmth) + Cyr_Rem
    Else
      For L = 1 To acmth
       CLAB(L) = Pick.extractcur(Abud, 1, L, 0)
      Next L
    End If
    Return
'
620 If d3.d3_readstr(database, Glbuds, OAC & "GL.BUDGET", Gq2) <> 0 Then Glbuds = ""
    If Pick.locate(soy, Glbuds, 1, 1, 0, bpos, "DR") = 0 Then
    End If
    Abud2 = Pick.extract(Glbuds, 2, bpos, 0)
    If Abud2 = "" Then
       If Gqsc <> "" Then
          If Pick.extract(Gl, 7, 0, 0) = "A" Then
             Abud2 = Pick.extract(Gl, 8, 1, 0)
          Else
             For L = 1 To acmth
                Abud2 = Pick.replace(Abud2, 1, 1, L, Pick.extract(Gl, 8, L, 0))
             Next L
          End If
       Else
          If d3.d3_readstr(database, Glbuds, OAC & "GEN.L", Gq2, 8) <> 0 Then Glbuds = ""
          If Pick.extract(Gl, 7, 0, 0) = "A" Then
            Abud2 = Pick.extract(Glbuds, 1, 1, 0)
          Else
             For L = 1 To acmth
                Abud2 = Pick.replace(Abud2, 1, 1, L, Pick.extract(Glbuds, 1, L, 0))
             Next L
          End If
       End If
    End If
    If Pick.extract(Gl, 7, 0, 0) = "A" Then
       If IsNumeric(Abud) Then tempcur = CCur(Abud) Else tempcur = 0
       Abud = CStr(tempcur + Pick.extractcur(Abud2, 1, 1, 1))
    Else
       For L = 1 To acmth
          Abud = Pick.replace(Abud, 1, L, 0, CStr(Pick.extractcur(Abud, 1, L, 0) + Pick.extractcur(Abud2, 1, 1, L)))
       Next L
    End If
    Return

End Function

Public Sub sr555_write_dict(database As String, dict_filename As String, isjob As Boolean)

' see if required dictionary items exist if not then create

' MyGrp, MyCls, MyScls are for finding accounts
' bMyGrp, bMyCls, bMyScls are for sorting by account numbers

Dim new_rec As String
Dim Am As String * 1, rorl As String * 1, wterror As Integer

Am = Chr(254)
If isjob Then rorl = "L" Else rorl = "R" ' job numbers are alphanumeric

If d3.d3_readstr(database, new_rec, dict_filename, "MYGRP") <> 0 Then
   new_rec = "A" & Am & "0" & Am & "my Group" & Am & Am & Am & Am & Am & "g0.1" & Am & "L" & Am & "8"
   wterror = d3.d3_writestr(database, dict_filename, "MYGRP", new_rec)
End If
If d3.d3_readstr(database, new_rec, dict_filename, "MYCLS") <> 0 Then
   new_rec = "A" & Am & "0" & Am & "my Class" & Am & Am & Am & Am & Am & "g1.1" & Am & "L" & Am & "6"
   wterror = d3.d3_writestr(database, dict_filename, "MYCLS", new_rec)
End If
If d3.d3_readstr(database, new_rec, dict_filename, "MYSCLS") <> 0 Then
   new_rec = "A" & Am & "0" & Am & "my Subclass" & Am & Am & Am & Am & Am & "g2.1" & Am & "L" & Am & "6"
   wterror = d3.d3_writestr(database, dict_filename, "MYSCLS", new_rec)
End If
If d3.d3_readstr(database, new_rec, dict_filename, "bMYGRP") <> 0 Then
   new_rec = "A" & Am & "0" & Am & "my sort Group" & Am & Am & Am & Am & "G0.1" & Am & Am & rorl & Am & "8"
   wterror = d3.d3_writestr(database, dict_filename, "bMYGRP", new_rec)
End If
If d3.d3_readstr(database, new_rec, dict_filename, "bMYCLS") <> 0 Then
   new_rec = "A" & Am & "0" & Am & "my sort Class" & Am & Am & Am & Am & "G1.1" & Am & Am & "R" & Am & "6"
   wterror = d3.d3_writestr(database, dict_filename, "bMYCLS", new_rec)
End If
If d3.d3_readstr(database, new_rec, dict_filename, "bMYSCLS") <> 0 Then
   new_rec = "A" & Am & "0" & Am & "my sort Subclass" & Am & Am & Am & Am & "G2.1" & Am & Am & "R" & Am & "6"
   wterror = d3.d3_writestr(database, dict_filename, "bMYSCLS", new_rec)
End If

End Sub

Public Function sr555b_msa(msa As Integer, logentry As String, gl_rep_hg As String, mth As Integer, borpl As String, soy As String, acmth As Integer) As String

Dim Xtra_Yrs As Integer, X As Integer
Dim WCHS As String, Pos As Integer, jobs() As String
Dim Ans As String, Hg_No As String, Gx As Integer, I As Integer, j As Integer
Dim Hg_Sts As String, Hg_Bds As String, Hg_Com_Sts As String, Hg_Pjs As String, Gl_Rep_Grp As String, Gmax As Integer
Dim Temp_Rep  As String, Hg_Ac As Integer, Gq As String, OAC As String
Dim Gl_Percent As String, Gl_Wch As String, Gl_Totonly, wpos As Integer, Usejob, Gl_Accts As String
Dim Ans1 As String, Ans2 As String, Gr, Cfrom, Cto, Scfrom As Integer, Scto As Integer, Xio As String, Borpl2 As String, Gmax2 As Integer
Dim Cls As Integer, Glr As String, Temp_Rec As String, Cmax2 As Integer, Scls As Integer, sc As Integer, GFROM As String, GTO As String
Dim Maxll As Integer, Ll As Integer, Gindx As Integer, Incls, C_Gl_Grp As String, Maxc As Integer, Cstart As Integer, Cend As Integer
Dim Crange As Integer, Cmpg2 As Currency, Incscl, Sfrom, Sto, Numg3, Cmpg3 As Currency, Gl_Grp As String, Send As Integer
Dim Srange As Integer, Ssrange As Integer, Instr, Lgq, Gq_Sbcl As String, Gq_Gr As String, Min As Integer, Max As Integer
Dim Gr__ As String, Xg__ As String, Limit_J__ As Integer, J__ As Integer, Limit_Jj__ As Integer, Scj__ As Integer, Scj__Sc As Integer, Uj As Integer
Dim Gq_Cls As String, Gl As String, Hg_Sts2 As String, Hg_Bds2 As String, Hg_Com_Sts2 As String, Hg_Pjs2 As String
Dim Max_Am As Integer, Atr As Integer, Glac As String, Cyr_Rem As Integer, Lyr_Rem As Integer, Nyr_Rem As Integer, L As Integer, L1 As Integer, Clp As Currency
Dim Gqsc As String, Gqgr As String, gqcl As String
Dim Gl_Per As Currency, Abud As String, Gq2 As String, Cc_Gl_Grp As String, Ccstart As Integer, Ccend As Integer, Ccrange As Integer
Dim Ssend As Integer, Glbuds As String, Abud2 As String
Dim database As String, rderr As Integer, temp As String
Dim CL_STS(39) As Currency, CLB(100) As Currency, CL_COM_STS(39) As Currency, CLAB(39) As Currency
Dim GEN_GRPS(11) As String, NO_GEN_GRPS(11) As Integer
Dim Gg As Currency, rmax As Integer, bpos As Integer, tempcur As Currency

'--------------------------------------------------------------------
' THIS SUBROUTINE IS THE CALCULATION PHASE OF TA555
'
' NOTE: IF ACTUALS, THEN GL A/C NUMBERS ARE INCREMENTED BY 'RPFLAG'
'--------------------------------------------------------------------
     database = Pick.extract(logentry, 2, 0, 0)

    If d3.d3_readstr(database, Ans, "DICT GEN.L", "XGRP") <> 0 Then Ans = ""
    GEN_GRPS(1) = Ans
    NO_GEN_GRPS(1) = Pick.dcount(Ans, Chr(253))
'
    Hg_No = Time()
    WCHS = ""

       Gx = 0: Temp_Rep = gl_rep_hg
201    Hg_Sts = "": Hg_Bds = "": Hg_Com_Sts = "": Hg_Pjs = ""
       For Hg_Ac = 1 To 999
          Gq = Pick.extract(gl_rep_hg, 18, Hg_Ac, 1)
          If Gq = "" Then GoTo 305
202       Ans = InStr(Gq, "P")
          If InStr(Gq, "*") Then OAC = Pick.field(Gq, "*", 1): Gq = Pick.field(Gq, "*", 2) Else OAC = ""
          Gl_Percent = Pick.extract(gl_rep_hg, 18, Hg_Ac, 2)
          If Not IsNumeric(Gl_Percent) Then Gl_Percent = "100"
          Gl_Wch = Pick.extract(gl_rep_hg, 18, Hg_Ac, 3)
          Gl_Totonly = Pick.extract(gl_rep_hg, 18, Hg_Ac, 4)
          If Gl_Totonly = "" Then Gl_Totonly = "Y"
          If Gl_Wch = "" Then
             wpos = 1
          Else
             If Pick.locate(Gl_Wch, WCHS, 1, 1, 0, wpos, "") = 0 Then
                WCHS = Pick.insert(WCHS, wpos, 0, 0, Gl_Wch)
             End If
             wpos = wpos + 1
          End If
          Usejob = 0
          If Mid$(Gq, 1, 3) = "RPT" Then
            Gq = Mid$(Gq, 4, 99)
            If d3.d3_readstr(database, Gl_Accts, OAC & "RTYPE", Gq, 2) <> 0 Then Gl_Accts = ""
            GoSub 320
            GoTo 304
          End If
          If Mid$(Gq, 1, 2) = "RC" Then
            Gq = Mid$(Gq, 3, 99)
            If d3.d3_readstr(database, Gl_Accts, OAC & "RCODE", Gq, 2) <> 0 Then Gl_Accts = ""
            GoSub 320
            GoTo 304
          End If
          If Mid$(Gq, 1, 2) = "RR" Then
            Gq = Mid$(Gq, 3, 99): Ans1 = Pick.field(Gq, "-", 1): Ans2 = Pick.field(Gq, "-", 2)
            Gr = Pick.field(Ans1, ".", 1): Cfrom = Pick.field(Ans1, ".", 2): Cto = Pick.field(Ans2, ".", 2)
            Scfrom = Pick.field(Ans1, ".", 3): Scto = Pick.field(Ans2, ".", 3)
            If d3.d3_readstr(database, Xio, "DICT " & OAC & "GEN.L.REPORT", "X" & Gr) <> 0 Then Xio = ""
            If d3.d3_readstr(database, Borpl2, "GEN.L.REPORT", Gr & ".0", 4) <> 0 Then Borpl2 = borpl
            Gmax2 = Pick.dcount(Xio, Chr(254))
            For Cls = 1 To Gmax2
              If Pick.extract(Xio, Cls, 1, 0) = "" Then Exit For
              If Pick.extract(Xio, Cls, 1, 0) > Cto Then Exit For
              If Pick.extract(Xio, Cls, 1, 0) >= Cfrom Then
                'If Scfrom = "" Then
                  'Glr = Gr & "." & Pick.extract(Xio, cls, 1, 0)
                  'If d3.d3_readstr(database, Temp_Rep, "DICT GL.R", Glr) <> 0 Then Temp_Rec = ""
                  'Call SR555B(logentry, "", "", Temp_Rep, "", ACMTH, Borpl2)
                  'Call PICKWT("TEMP.555", Hg_No & "*" & Glr, 3, Temp_Rep, 0)
                  'If Pick.locate(Glr, Gl_Rep_Hg, 25, 1, 0, pos, "") = 0 Then
                  '  Gl_Rep_Hg = Pick.insert(Gl_Rep_Hg, 25, -1, 0, Glr)
                  'End If
                'End If
                Cmax2 = Pick.dcount(Pick.extract(Xio, Cls, 0, 0), Chr(253))
                For Scls = 2 To Cmax2
                  sc = Pick.extract(Xio, Cls, Scls, 0)
                  'If Scfrom = "" Or (sc >= Scfrom And sc <= Scto) Then
                  '  Glr = Gr & "." & Pick.extract(Xio, cls, 1, 0) & "." & sc
                  '  If d3.d3_readstr(database, Temp_Rep, "DICT GL.R", Glr) <> 0 Then Temp_Rec = ""
                    'Call SR555B(logentry, "", "", Temp_Rep, "", ACMTH, Borpl2)
                    'Call PICKWT("TEMP.555", Hg_No & "*" & Glr, 3, Temp_Rep, 0)
                  '  If Pick.locate(Glr, Gl_Rep_Hg, 25, 1, 0, pos, "") = 0 Then
                  '    Gl_Rep_Hg = Pick.insert(Gl_Rep_Hg, 25, -1, 0, Glr)
                  '  End If
                  'End If
                Next Scls
              End If
            Next Cls
          End If
'
'========================================================
'
          If Mid$(Gq, 1, 3) = "JOB" Then Usejob = 1: Gq = Mid$(Gq, 4, 99) Else Usejob = 0
          If Left(Gq, 1) = "G" And InStr(Gq, "-") Then
           GFROM = Mid(Pick.field(Gq, ".", 1), 2, 99)
           GTO = Mid(Pick.field(Gq, ".", 2), 3, 99)
           If Usejob Then
              If SR555_RANGE(msa, logentry, OAC, GFROM, GTO, jobs()) = 0 Then GoTo 304
              Maxll = UBound(jobs)
              For Ll = 0 To Maxll
                 Gq = jobs(Ll): GoSub 500
              Next Ll
              GoTo 304
           Else
              If Pick.locate(CStr(GFROM), GEN_GRPS(1), 1, 1, 0, Gindx, "AR") = 0 Then
              End If
           End If
205        temp = Pick.extract(GEN_GRPS(1), 1, Gindx, 0)
           If Not (IsNumeric(temp)) Then GoTo 304
           Gg = CCur(temp)
           If IsNumeric(GTO) Then
              If Gg > CCur(GTO) Then GoTo 304
           End If
           If OAC = "" Then Maxll = NO_GEN_GRPS(1) Else Maxll = NO_GEN_GRPS(CInt(OAC) + 1)
           For Ll = 1 To Maxll
            If OAC = "" Then temp = GEN_GRPS(1) Else temp = GEN_GRPS(CInt(OAC) + 1)
            If Pick.extractcur(temp, 1, Ll, 0) = Gg Then
             Gq = Gg & ".0"
             GoSub 500
             GoTo 210
            End If
           Next Ll
210        Gindx = Gindx + 1
           GoTo 205
          End If
          If Left(Gq, 1) = "C" And InStr(Gq, "-") Then
           If Mid$(Gq, 2, 1) = "C" And Pick.field(Pick.field(Gq, "-", 2), ".", 1) <> Pick.field(Pick.field(Mid(Gq, 2, 99), "-", 1), ".", 1) Then
            Incls = 1: GFROM = Mid(Pick.field(Gq, ".", 1), 3, 99)
           Else
            Incls = 0: GFROM = Mid(Pick.field(Gq, ".", 1), 2, 99)
           End If
           GTO = Pick.field(Pick.field(Gq, "-", 2), ".", 1)
           Cfrom = Pick.field(Pick.field(Gq, "-", 1), ".", 2)
           Cto = Pick.field(Gq, ".", 3)
           If Usejob Then
              If SR555_RANGE(msa, logentry, OAC, GFROM, GTO, jobs()) = 0 Then
                 Maxll = 0
              Else
                 Maxll = UBound(jobs)
              End If
              GoTo 217
           End If
           If Pick.locate(CStr(GFROM), GEN_GRPS(1), 1, 1, 0, Gindx, "AR") = 0 Then
           End If
215        Gg = Pick.extractcur(GEN_GRPS(1), 1, Gindx, 0)
           If Gg = 0 Or Gg > GTO Then GoTo 304
           If Usejob Then
217         For Ll = 1 To Maxll
             Gg = jobs(Ll)
              If d3.d3_readstr(database, C_Gl_Grp, "DICT " & OAC & "JOB.L", "X" & Gg) <> 0 Then C_Gl_Grp = ""
              Maxc = Pick.dcount(C_Gl_Grp, Chr(254))
              If Incls Then
               Cstart = Cfrom: Cend = Cto
              Else
               If Gg = GFROM Then Cstart = Cfrom Else Cstart = 1
               If Gg = GTO Then Cend = Cto Else Cend = Pick.extract(C_Gl_Grp, Maxc, 1, 0)
              End If
              For Crange = 1 To Maxc
               If Pick.extract(C_Gl_Grp, Crange, 1, 0) = "" Then Exit For
               If Pick.extract(C_Gl_Grp, Crange, 1, 0) > Cend Then Exit For
               If Pick.extract(C_Gl_Grp, Crange, 1, 0) >= Cstart Then
                Gq = Gg & "." & Pick.extract(C_Gl_Grp, Crange, 1, 0)
                GoSub 500
               End If
              Next Crange
'MCO 04JAN01              GOTO 220
'             END
            Next Ll
            GoTo 304
           Else
            If OAC = "" Then Maxll = NO_GEN_GRPS(1) Else Maxll = NO_GEN_GRPS(CInt(OAC) + 1)
            For Ll = 1 To Maxll
             If OAC = "" Then temp = GEN_GRPS(1) Else temp = GEN_GRPS(CInt(OAC) + 1)
             Cmpg2 = Pick.extractcur(temp, 1, Ll, 0)
             If Cmpg2 = Gg Then
              If d3.d3_readstr(database, C_Gl_Grp, "DICT " & OAC & "GEN.L", "X" & Gg) <> 0 Then C_Gl_Grp = ""
              If Incls Then
               Cstart = Cfrom: Cend = Cto
              Else
               If Gg = GFROM Then Cstart = Cfrom Else Cstart = 1
               If Gg = GTO Then Cend = Cto Else Cend = Pick.dcount(C_Gl_Grp, Chr(254))
              End If
              For Crange = Cstart To Cend
               If Pick.extractint(C_Gl_Grp, Crange, 1, 0) = 0 Then
                Gq = Gg & "." & Crange
                GoSub 500
               End If
              Next Crange
              GoTo 220
             End If
            Next Ll
           End If
220        Gindx = Gindx + 1
           GoTo 215
          End If
          If Left(Gq, 1) = "S" And InStr(Gq, "-") Then
           If Mid$(Gq, 2, 1) = "S" Then
            Incscl = 1: GFROM = Mid$(Pick.field(Gq, ".", 1), 3, 99)
           Else
            Incscl = 0: GFROM = Mid$(Pick.field(Gq, ".", 1), 2, 99)
           End If
           GTO = Pick.field(Pick.field(Gq, "-", 2), ".", 1)
           Cfrom = Pick.field(Gq, ".", 2)
           Cto = Pick.field(Gq, ".", 4)
           Sfrom = Pick.field(Pick.field(Gq, "-", 1), ".", 3)
           Sto = Pick.field(Gq, ".", 5)
           If Usejob Then
              If SR555_RANGE(msa, logentry, OAC, GFROM, GTO, jobs()) = 0 Then
                 Maxll = 0
              Else
                 Maxll = UBound(jobs)
              End If
              Ll = 0
              GoTo 226
           Else
              If Pick.locate(CStr(GFROM), GEN_GRPS(1), 1, 1, 0, Gindx, "AR") = 0 Then
              End If
           End If
225        If Usejob Then
226           Ll = Ll + 1
              If Ll > Maxll Then GoTo 304
              Gg = jobs(Ll)
              GoTo A226
           End If
           temp = Pick.extract(GEN_GRPS(1), 1, Gindx, 0)
           If Not IsNumeric(temp) Then GoTo 304
           Gg = CCur(temp)
           If OAC = "" Then Numg3 = NO_GEN_GRPS(1) Else Numg3 = NO_GEN_GRPS(CInt(OAC) + 1)
           If IsNumeric(GTO) Then
              If Gg > CCur(GTO) Then GoTo 304
           End If
           For Ll = 1 To Numg3
            If OAC = "" Then temp = GEN_GRPS(1) Else temp = GEN_GRPS(CInt(OAC) + 1)
            Cmpg3 = Pick.extractcur(temp, 1, Ll, 0)
            If Cmpg3 = Gg Then
A226:        If Usejob Then
                If d3.d3_readstr(database, Gl_Grp, "DICT " & OAC & "JOB.L", "X" & Gg) <> 0 Then Gl_Grp = ""
             Else
                If d3.d3_readstr(database, Gl_Grp, "DICT " & OAC & "GEN.L", "X" & Gg) <> 0 Then Gl_Grp = ""
             End If
             Maxc = Pick.dcount(Gl_Grp, Chr(254))
             If Incscl Then
              Cstart = Cfrom: Cend = Cto
             Else
              If Gg = GFROM Then Cstart = Cfrom Else Cstart = 1
              If Usejob Then
               If Gg = GTO Then Cend = Cto Else Cend = Pick.extract(Gl_Grp, Maxc, 1, 0)
              Else
               If Gg = GTO Then Cend = Cto Else Cend = Pick.dcount(Gl_Grp, Chr(254))
              End If
             End If
             If Usejob Then
              For Crange = 1 To Maxc
               If Pick.extract(Gl_Grp, Crange, 1, 0) = "" Then Exit For
               If Pick.extract(Gl_Grp, Crange, 1, 0) > Cend Then Exit For
               If Pick.extract(Gl_Grp, Crange, 1, 0) >= Cstart Then
                Send = Pick.dcount(Pick.extract(Gl_Grp, Crange, 0, 0), Chr(253))
                For Srange = 2 To Send
                  If Pick.extract(Gl_Grp, Crange, Srange, 0) <> "" Then
                   Ssrange = Pick.extract(Gl_Grp, Crange, Srange, 0)
                   If Gg = GFROM And Crange = Cfrom Then
                    If Ssrange < Sfrom Then GoTo 227
                   End If
                   If Gg = GTO And Crange = Cto Then
                      If Ssrange > Sto Then GoTo 304
                   End If
                   If Incscl Then
                      If Ssrange < Sfrom Or Ssrange > Sto Then GoTo 227
                   End If
                   Gq = Gg & "." & Pick.extract(Gl_Grp, Crange, 1, 0) & "." & Ssrange
                   GoSub 500
                   End If
227             Next Srange
               End If
              Next Crange
             Else
              For Crange = Cstart To Cend
               If Pick.extractint(Gl_Grp, Crange, 1, 0) = 0 Then
                Send = Pick.dcount(Pick.extract(Gl_Grp, Crange, 0, 0), Chr(253))
                For Srange = 2 To Send
                  If Pick.extract(Gl_Grp, Crange, Srange, 0) <> "" Then
                   Ssrange = Pick.extract(Gl_Grp, Crange, Srange, 0)
                   If Gg = GFROM And Crange = Cfrom Then
                    If Ssrange < Sfrom Then GoTo 228
                   End If
                   If Gg = GTO And Crange = Cto Then
                      If Ssrange > Sto Then GoTo 304
                   End If
                   If Incscl Then
                      If Ssrange < Sfrom Or Ssrange > Sto Then GoTo 228
                   End If
                   Gq = Gg & "." & Crange & "." & Ssrange
                   GoSub 500
                   End If
228             Next Srange
               End If
              Next Crange
             End If
             GoTo 230
            End If
           Next Ll
230        Gindx = Gindx + 1
           GoTo 225
          End If
'IF NOT(GQ MATCH '"."1N0N') AND NOT(GQ MATCH '"."1N0N"."1N0N') THE
          If Not (Left(Gq, 1) = "." And IsNumeric(Mid(Gq, 2))) And Not (Left(Gq, 1) = "." And InStr(Mid(Gq, 2), ".") <> 0 And IsNumeric(Mid(Gq, 2))) Then
             If InStr(Gq, "..") = 0 Then
' ACCTS FORM 1.0 1.1 OR 1.1.1
                If InStr(Gq, "]") Then
                 Gq = Mid$(Gq, 1, Len(Gq) - 1)
                 GoSub 500
                 Lgq = Gq
                 For j = 1 To 9
                  Gq = Lgq & j: GoSub 500
                 Next j
                Else
                 GoSub 500
                End If
              Else  '** GO THRU ALL CLS IN ALL GRPS **
' ACCTS FORM ..1
                Gq_Sbcl = Pick.field(Gq, ".", 3): Gq_Gr = Pick.field(Gq, ".", 1)
                If Usejob Then
                   If Gq_Gr <> "" Then
                      If SR555_RANGE(msa, logentry, OAC, Gq_Gr, Gq_Gr, jobs()) = 0 Then
                         Max = 0
                      Else
                         Max = UBound(jobs)
                      End If
                   Else
                      If SR555_RANGE(msa, logentry, OAC, "", "", jobs()) = 0 Then
                         Max = 0
                      Else
                         Max = UBound(jobs)
                      End If
                   End If
                   Min = 1
                   GoTo 292
                Else
                   Max = NO_GEN_GRPS(OAC + 1)
                End If
                Min = 1
                If Gq_Gr <> "" Then
                   If Usejob Then
                      '???If pick.locate(Gq_Gr, jobs, 1, 1, 0, Min, "") = 0 Then Min = 1
                   Else
                      If Pick.locate(Gq_Gr, GEN_GRPS(OAC + 1), 1, 1, 0, Min, "") = 0 Then Min = 1
                   End If
                   Max = Min
                End If
292             For I = Min To Max
                 If Usejob Then Gr__ = jobs(I) Else Gr__ = Pick.extract(GEN_GRPS(OAC + 1), 1, I, 0)
                 If Gq_Gr <> "" And Gr__ <> Gq_Gr Then GoTo 303
                 If Usejob Then
                    If d3.d3_readstr(database, Xg__, "DICT " & OAC & "JOB.L", "X" & Gr__) <> 0 Then Xg__ = ""
                 Else
                    If d3.d3_readstr(database, Xg__, "DICT " & OAC & "GEN.L", "X" & Gr__) <> 0 Then Xg__ = ""
                 End If
                 Limit_J__ = Pick.dcount(Xg__, Chr(254))
                 For J__ = 1 To Limit_J__
                  Limit_Jj__ = Pick.dcount(Pick.extract(Xg__, J__, 0, 0), Chr(253))
                  For Scj__ = 2 To Limit_Jj__
                   Scj__Sc = Pick.extract(Xg__, J__, Scj__, 0)
                   If Scj__Sc = "" Then GoTo 301
                   If Scj__Sc > Gq_Sbcl Then GoTo 301
                   If Scj__Sc = Gq_Sbcl Then
                    If Usejob Then Uj = Pick.extract(Xg__, J__, 1, 0) Else Uj = J__
                    Gq = Gr__ & "." & Uj & "." & Gq_Sbcl
                    GoSub 500
                   End If
                  Next Scj__
301              Next J__
303             Next I
             End If
           Else
' ACCTS FORM .1 OR .1.1
             Gq_Cls = Gq
             If Usejob Then
                If SR555_RANGE(msa, logentry, OAC, "", "", jobs()) = 0 Then
                   Max = 0
                Else
                   Max = UBound(jobs)
                End If
             Else
                If OAC = "" Then Max = NO_GEN_GRPS(1) Else Max = NO_GEN_GRPS(CInt(OAC) + 1)
             End If
             For I = 1 To Max
                If OAC = "" Then temp = GEN_GRPS(1) Else temp = GEN_GRPS(CInt(OAC) + 1)
                If Usejob Then Gq = jobs(I) & Gq_Cls Else Gq = Pick.extract(temp, 1, I, 0) & Gq_Cls
                GoSub 500
             Next I
          End If
304     Next Hg_Ac
305     GoSub 330
        sr555b_msa = gl_rep_hg
        Exit Function '* TO CALLING PROGRAM **
'
320  If Gl_Accts = "" Then rmax = 0 Else rmax = Pick.dcount(Pick.extract(Gl_Accts, 1, 0, 0), Chr(253))
     For sc = 1 To rmax
       Gq = Pick.extract(Gl_Accts, 1, sc, 0)
       'If Gx Then
         'If d3.d3_readstr(database, Gl, "DICT GEN.L", Pick.extract(Gl_Accts, 1, Sc, 0)) <> 0 Then Gl = ""
       'Else
          If d3.d3_readstr(database, Gl, "GEN.L", Pick.extract(Gl_Accts, 1, sc, 0)) <> 0 Then Gl = ""
       'End If
       Hg_Sts2 = "": Hg_Bds2 = "": Hg_Com_Sts2 = "": Hg_Pjs2 = ""
       GoSub 550
       GoSub 340
     Next sc
     Return
'
330  If Pick.Index(gl_rep_hg, Chr(254), Gx * 50 + 31) Then
        gl_rep_hg = Mid$(gl_rep_hg, 1, Pick.Index(gl_rep_hg, Chr(254), Gx * 50 + 31) - 1)
     End If
     gl_rep_hg = Pick.replace(gl_rep_hg, Gx * 50 + 8, 0, 0, Pick.extract(Hg_Bds, 1, 0, 0))
     gl_rep_hg = Pick.replace(gl_rep_hg, Gx * 50 + 9, 0, 0, Pick.extract(Hg_Sts, 1, 0, 0))
     gl_rep_hg = Pick.replace(gl_rep_hg, Gx * 50 + 27, 0, 0, Pick.extract(Hg_Com_Sts, 1, 0, 0))
     gl_rep_hg = Pick.replace(gl_rep_hg, Gx * 50 + 28, 0, 0, Pick.extract(Hg_Pjs, 1, 0, 0))
     If WCHS <> "" Then
        Max_Am = Pick.dcount(WCHS, Chr(254))
        For wpos = 1 To Max_Am
           Hg_Bds = Pick.replace(Hg_Bds, wpos + 1, 1, 1, Pick.extract(Hg_Bds, wpos + 1, 1, 1) + 0) ' mandatory so SR555C can detect data applicable)
           Atr = Gx * 50 + 29: gl_rep_hg = Pick.replace(gl_rep_hg, Atr + wpos * 4, 0, 0, Pick.extract(Hg_Bds, wpos + 1, 0, 0))
           Atr = Gx * 50 + 30: gl_rep_hg = Pick.replace(gl_rep_hg, Atr + wpos * 4, 0, 0, Pick.extract(Hg_Sts, wpos + 1, 0, 0))
           Atr = Gx * 50 + 31: gl_rep_hg = Pick.replace(gl_rep_hg, Atr + wpos * 4, 0, 0, Pick.extract(Hg_Com_Sts, wpos + 1, 0, 0))
           Atr = Gx * 50 + 32: gl_rep_hg = Pick.replace(gl_rep_hg, Atr + wpos * 4, 0, 0, Pick.extract(Hg_Pjs, wpos + 1, 0, 0))
        Next wpos
     End If
     Return
'
340  Glac = Pick.extract(Gl_Accts, 1, sc, 0)
     If Gl_Totonly = "Y" Then
        '???Delete "TEMP.555", Hg_No & "*" & Glac
     Else
        'If Gx Then
        '  If d3.d3_readstr(database, Temp_Rep, "TEMP", Hg_No & "*" & Glac) <> 0 Then Temp_Rep = ""
        'End If
        Temp_Rep = Pick.replace(Temp_Rep, 2, 0, 0, Glac & " " & Pick.extract(Gl, 2, 0, 0))
        Temp_Rep = Pick.replace(Temp_Rep, Gx * 50 + 8, 0, 0, Pick.extract(Hg_Bds2, 1, 0, 0))
        Temp_Rep = Pick.replace(Temp_Rep, Gx * 50 + 9, 0, 0, Pick.extract(Hg_Sts2, 1, 0, 0))
        Temp_Rep = Pick.replace(Temp_Rep, Gx * 50 + 27, 0, 0, Pick.extract(Hg_Com_Sts2, 1, 0, 0))
        Temp_Rep = Pick.replace(Temp_Rep, Gx * 50 + 28, 0, 0, Pick.extract(Hg_Pjs2, 1, 0, 0))
        If WCHS <> "" Then
           Max_Am = Pick.dcount(WCHS, Chr(254))
           For wpos = 1 To Max_Am
              Hg_Bds2 = Pick.replace(Hg_Bds2, wpos + 1, 1, 1, Pick.extract(Hg_Bds2, wpos + 1, 1, 1) + 0) ' mandatory so SR555C can detect data applicable)
              Atr = Gx * 50 + 29: Temp_Rep = Pick.replace(Temp_Rep, Atr + wpos * 4, 0, 0, Pick.extract(Hg_Bds2, wpos + 1, 0, 0))
              Atr = Gx * 50 + 30: Temp_Rep = Pick.replace(Temp_Rep, Atr + wpos * 4, 0, 0, Pick.extract(Hg_Sts2, wpos + 1, 0, 0))
              Atr = Gx * 50 + 31: Temp_Rep = Pick.replace(Temp_Rep, Atr + wpos * 4, 0, 0, Pick.extract(Hg_Com_Sts2, wpos + 1, 0, 0))
              Atr = Gx * 50 + 32: Temp_Rep = Pick.replace(Temp_Rep, Atr + wpos * 4, 0, 0, Pick.extract(Hg_Pjs2, wpos + 1, 0, 0))
           Next wpos
        End If
        'Call PICKWT("TEMP.555", Hg_No & "*" & Glac, 3, Temp_Rep, 0)
        If Pick.locate(Glac, gl_rep_hg, 25, 1, 0, Pos, "") = 0 Then
          gl_rep_hg = Pick.insert(gl_rep_hg, 25, -1, 0, Glac)
        End If
     End If
     Return
'
' PROCESS ACCTS
'
500 If Usejob Then
      If d3.d3_readstr(database, Gl, OAC & "JOB.L", Gq) <> 0 Then Return
    Else
      'If Gx Then
       'If d3.d3_readstr(database, Gl, Oac & "GEN.L." & Pick.extract(Validyrs, 1, Gx, 0), Gq) <> 0 Then Return
      'Else
       If d3.d3_readstr(database, Gl, OAC & "GEN.L", Gq) <> 0 Then Return
      'End If
    End If
    If Usejob Then
       Gl = Pick.replace(Gl, 9, 0, 0, Pick.extract(Gl, 59, 0, 0))
       Gl = Pick.replace(Gl, 7, 0, 0, "A")
       Gl = Pick.replace(Gl, 6, 0, 0, "0")
       Gl = Pick.replace(Gl, 8, 1, 0, Int(Pick.extractcur(Gl, 24, 1, 0) / 100))
       Gl = Pick.replace(Gl, 8, 2, 0, Int(Pick.extractcur(Gl, 24, 2, 0) / 100))
       Gl = Pick.replace(Gl, 8, 3, 0, Int(Pick.extractcur(Gl, 24, 3, 0) / 100))
       Gl = Pick.replace(Gl, 32, 0, 0, Pick.extract(Gl, 27, 0, 0))
       For X = 1 To acmth
          Gl = Pick.replace(Gl, 32, 0, 0, CStr(Pick.extractcur(Gl, 32, 0, 0) - (Pick.extractcur(Gl, 89, X, 0) + Pick.extractcur(Gl, 89, (acmth * 2) + X, 0))))
       Next X
       Gl = Pick.replace(Gl, 35, 0, 0, Pick.extract(Gl, 89, 0, 0))
       For X = 1 To Xtra_Yrs
          Gl = Pick.replace(Gl, 38, X, 0, Int(Pick.extract(Gl, 38, X, 0) / 100))
       Next X
    End If
' BDS
550 If Pick.extract(Gl, 7, 0, 0) = "A" Then
      CLB(1) = Round(Pick.extractcur(Gl, 8, 1, 0) / acmth)
      CLB(acmth + 1) = Round(Pick.extractcur(Gl, 8, 2, 0) / acmth)
      CLB(acmth * 2 + 1) = Round(Pick.extractcur(Gl, 8, 3, 0) / acmth)
      Cyr_Rem = Pick.extractcur(Gl, 8, 1, 0) - CLB(1) * acmth
      Lyr_Rem = Pick.extractcur(Gl, 8, 2, 0) - CLB(acmth + 1) * acmth
      Nyr_Rem = Pick.extractcur(Gl, 8, 3, 0) - CLB(acmth * 2 + 1) * acmth
      For L = 2 To acmth
       CLB(L) = CLB(1)
       CLB(L + acmth) = CLB(acmth + 1)
       CLB(L + acmth * 2) = CLB(acmth * 2 + 1)
      Next L
      CLB(acmth) = CLB(acmth) + Cyr_Rem
      CLB(2 * acmth) = CLB(2 * acmth) + Lyr_Rem
      CLB(3 * acmth) = CLB(3 * acmth) + Nyr_Rem
      For X = 1 To Xtra_Yrs
         L1 = (X + 2) * acmth
         CLB(L1 + 1) = Round(Pick.extractcur(Gl, 38, X, 0) / acmth)
         Nyr_Rem = Pick.extract(Gl, 38, X, 0) - CLB(L1 + 1) * acmth
         For L = 2 To acmth
          CLB(L1 + L) = CLB(L1 + 1)
         Next L
         CLB((X + 3) * acmth) = CLB((X + 3) * acmth) + Nyr_Rem
      Next X
    Else
      For L = 1 To acmth * 3
       CLB(L) = Pick.extractcur(Gl, 8, L, 0)
      Next L
      For X = 1 To acmth * Xtra_Yrs
       CLB(L) = Pick.extractcur(Gl, 38, X, 0)
       L = L + 1
      Next X
    End If
    Clp = Pick.extractcur(Gl, 39, 0, 0) ' projection
    If Usejob = 0 Then GoSub 600
' STS INIT ATTR 9
    For L = 1 To acmth * 3
      CL_STS(L) = Pick.extractcur(Gl, 9, L, 0)
      CL_COM_STS(L) = Pick.extractcur(Gl, 35, L, 0)
    Next L
' ADD NOTIONAL ADJUSTMENTS
'    If MTH > ACMTH Then Fyr = ACMTH Else Fyr = 0
'    Maxadj = Pick.dcount(ADJUST, Chr(254))
'    For Mm = 2 To Maxadj
'      Adjac = Pick.extract(ADJUST, Mm, 1, 0)
'      Gqgr = pick.field(Gq, ".", 1): Adgr = pick.field(Adjac, ".", 1)
'      Gqcl = pick.field(Gq, ".", 2): Adcl = pick.field(Adjac, ".", 2)
'      Gqsc = pick.field(Gq, ".", 3): Adsc = pick.field(Adjac, ".", 3)
'      If Gqsc <> "" Then      ' SUBCLASS
'        If Gq = Adjac Then
'560       CL_STS(MTH + Fyr) = CL_STS(Pick.extract(MTH + Fyr) + ADJUST, Mm, 2)
'        End If
'      Else
'        If Gqgr = Adgr Then     ' GROUP LEVEL
'          If Gqcl = 0 Then GoTo 560 Else
'            If Gqcl = Adcl Then GoTo 560      ' ELSE IGNORE
'          End If
'        End If
'      End If
'    Next Mm
'
'-------------------------------------------------------------------------
' Note Well:  Use of OCONV/pick.iconv in following calculations is to avoid
' arithmetic problems when dealing with numbers in excess of 140 million
' (and working to 4 decimal accuracy - standard PICK)
'-------------------------------------------------------------------------
'
    
    Gl_Per = CCur(Gl_Percent) / 100
    For L = 1 To acmth * 3
       If Gl_Totonly = "Y" Then
          Hg_Sts = Pick.replace(Hg_Sts, wpos, L, 0, CStr(Round((Pick.extractcur(Hg_Sts, wpos, L, 0) / 100 + CL_STS(L) / 100 * Gl_Per) * 100)))
          Hg_Com_Sts = Pick.replace(Hg_Com_Sts, wpos, L, 0, CStr(Round((Pick.extractcur(Hg_Com_Sts, wpos, L, 0) / 100 + CL_COM_STS(L) / 100 * Gl_Per) * 100)))
          Hg_Bds = Pick.replace(Hg_Bds, wpos, L, 1, CStr(Round((Pick.extractcur(Hg_Bds, wpos, L, 1) / 100 + CLB(L) / 100 * Gl_Per) * 100)))
       Else
          Hg_Sts2 = Pick.replace(Hg_Sts2, wpos, L, 0, CStr(Round((CL_STS(L) / 100 * Gl_Per) * 100)))
          Hg_Com_Sts2 = Pick.replace(Hg_Com_Sts2, wpos, L, 0, CStr(Round((CL_COM_STS(L) / 100 * Gl_Per) * 100)))
          Hg_Bds2 = Pick.replace(Hg_Bds2, wpos, L, 0, CStr(Round((CLB(L) / 100 * Gl_Per) * 100)))
       End If
       If L <= acmth Then
          If Gl_Totonly = "Y" Then
             Hg_Bds = Pick.replace(Hg_Bds, wpos, L, 2, CStr(Round((Pick.extractcur(Hg_Bds, wpos, L, 2) / 100 + CLAB(L) / 100 * Gl_Per) * 100)))
          Else
            Hg_Bds2 = Pick.replace(Hg_Bds2, wpos, L, 2, CStr(Round((CLB(L) / 100 * Gl_Per) * 100)))
          End If
       End If
    Next L
    For L = (acmth * 3) + 1 To acmth * (3 + Xtra_Yrs)
       If Gl_Totonly = "Y" Then
          Hg_Bds = Pick.replace(Hg_Bds, wpos, L, 0, CStr(Round((Pick.extractcur(Hg_Bds, wpos, L, 0) / 100 + CLB(L) / 100 * Gl_Per) * 100)))
       Else
          Hg_Bds2 = Pick.replace(Hg_Bds2, wpos, L, 0, CStr(Round((CLB(L) / 100 * Gl_Per) * 100)))
       End If
    Next L
    If borpl = "B" Or Mid$(Pick.extract(gl_rep_hg, 20, 0, 0), 1, 1) = "Y" Then
       If Gl_Totonly = "Y" Then
          Hg_Sts = Pick.replace(Hg_Sts, wpos, acmth * 3 + 1, 0, CStr(Round((Pick.extractcur(Hg_Sts, wpos, acmth * 3 + 1, 0) / 100 + Pick.extractcur(Gl, 6, 1, 0) / 100 * Gl_Per) * 100)))
          Hg_Com_Sts = Pick.replace(Hg_Com_Sts, wpos, acmth * 3 + 1, 0, CStr(Round((Pick.extractcur(Hg_Com_Sts, wpos, acmth * 3 + 1, 0) / 100 + Pick.extract(Gl, 32, 1, 0) / 100 * Gl_Per) * 100)))
          Hg_Sts = Pick.replace(Hg_Sts, wpos, acmth * 3 + 2, 0, CStr(Round((Pick.extractcur(Hg_Sts, wpos, acmth * 3 + 2, 0) / 100 + Pick.extractcur(Gl, 6, 2, 0) / 100 * Gl_Per) * 100)))
          Hg_Com_Sts = Pick.replace(Hg_Com_Sts, wpos, acmth * 3 + 2, 0, CStr(Round((Pick.extractcur(Hg_Com_Sts, wpos, acmth * 3 + 2, 0) / 100 + Pick.extractcur(Gl, 32, 2, 0) / 100 * Gl_Per) * 100)))
       Else
          Hg_Sts2 = Pick.replace(Hg_Sts2, wpos, acmth * 3 + 1, 0, CStr(Round((Pick.extractcur(Gl, 6, 1, 0) / 100 * Gl_Per) * 100)))
          Hg_Com_Sts2 = Pick.replace(Hg_Com_Sts2, wpos, acmth * 3 + 1, 0, CStr(Round((Pick.extractcur(Gl, 32, 1, 0) / 100 * Gl_Per) * 100)))
          Hg_Sts2 = Pick.replace(Hg_Sts2, wpos, acmth * 3 + 2, 0, CStr(Round((Pick.extractcur(Gl, 6, 2, 0) / 100 * Gl_Per) * 100)))
          Hg_Com_Sts2 = Pick.replace(Hg_Com_Sts2, wpos, acmth * 3 + 2, 0, CStr(Round((Pick.extractcur(Gl, 32, 2, 0) / 100 * Gl_Per) * 100)))
       End If
       If mth > acmth Then
          For L = 1 To acmth
             If Gl_Totonly = "Y" Then
                Hg_Sts = Pick.replace(Hg_Sts, wpos, acmth * 3 + 1, 0, CStr(Round((Pick.extractcur(Hg_Sts, wpos, acmth * 3 + 1, 0) / 100 + CL_STS(L) / 100 * Gl_Per) * 100)))
                Hg_Sts = Pick.replace(Hg_Sts, wpos, acmth * 3 + 2, 0, CStr(Round((Pick.extractcur(Hg_Sts, wpos, acmth * 3 + 2, 0) / 100 + CL_STS(acmth + L) / 100 * Gl_Per) * 100)))
                Hg_Com_Sts = Pick.replace(Hg_Com_Sts, wpos, acmth * 3 + 1, 0, CStr(Round((Pick.extractcur(Hg_Com_Sts, wpos, acmth * 3 + 1, 0) / 100 + CL_COM_STS(L) / 100 * Gl_Per) * 100)))
                Hg_Com_Sts = Pick.replace(Hg_Com_Sts, wpos, acmth * 3 + 2, 0, CStr(Round((Pick.extractcur(Hg_Com_Sts, wpos, acmth * 3 + 2, 0) / 100 + CL_COM_STS(acmth + L) / 100 * Gl_Per) * 100)))
             Else
                Hg_Sts2 = Pick.replace(Hg_Sts2, wpos, acmth * 3 + 1, 0, CStr(Round((Pick.extractcur(Hg_Sts2, wpos, acmth * 3 + 1, 0) / 100 + CL_STS(L) / 100 * Gl_Per) * 100)))
                Hg_Sts2 = Pick.replace(Hg_Sts2, wpos, acmth * 3 + 2, 0, CStr(Round((Pick.extractcur(Hg_Sts2, wpos, acmth * 3 + 2, 0) / 100 + CL_STS(acmth + L) / 100 * Gl_Per) * 100)))
                Hg_Com_Sts2 = Pick.replace(Hg_Com_Sts2, wpos, acmth * 3 + 1, 0, CStr(Round((Pick.extractcur(Hg_Com_Sts2, wpos, acmth * 3 + 1, 0) / 100 + CL_COM_STS(L) / 100 * Gl_Per) * 100)))
                Hg_Com_Sts2 = Pick.replace(Hg_Com_Sts2, wpos, acmth * 3 + 2, 0, CStr(Round((Pick.extractcur(Hg_Com_Sts2, wpos, acmth * 3 + 2, 0) / 100 + CL_COM_STS(acmth + L) / 100 * Gl_Per) * 100)))
             End If
          Next L
       End If
    Else
       If Gl_Totonly = "Y" Then
          Hg_Com_Sts = Pick.replace(Hg_Com_Sts, wpos, acmth * 3 + 1, 0, CStr(Round((Pick.extractcur(Hg_Com_Sts, wpos, acmth * 3 + 1, 0) / 100 + Pick.extractcur(Gl, 32, 1, 0) / 100 * Gl_Per) * 100)))
          Hg_Com_Sts = Pick.replace(Hg_Com_Sts, wpos, acmth * 3 + 2, 0, CStr(Round((Pick.extractcur(Hg_Com_Sts, wpos, acmth * 3 + 2, 0) / 100 + Pick.extractcur(Gl, 32, 2, 0) / 100 * Gl_Per) * 100)))
       Else
          Hg_Com_Sts2 = Pick.replace(Hg_Com_Sts2, wpos, acmth * 3 + 1, 0, CStr(Round((Pick.extractcur(Gl, 32, 1, 0) / 100 * Gl_Per) * 100)))
          Hg_Com_Sts2 = Pick.replace(Hg_Com_Sts2, wpos, acmth * 3 + 2, 0, CStr(Round((Pick.extractcur(Gl, 32, 2, 0) / 100 * Gl_Per) * 100)))
       End If
       If mth > acmth Then
          For L = 1 To acmth
             If Gl_Totonly = "Y" Then
'                HG.STS<WPOS,ACMTH*3+1> = pick.iconv(pick.oconv(HG.STS<WPOS,ACMTH*3+1>,'MD2') + pick.oconv(CL.STS(L),'MD2')*GL.PER,'MD2')
                Hg_Com_Sts = Pick.replace(Hg_Com_Sts, wpos, acmth * 3 + 1, 0, CStr(Round((Pick.extractcur(Hg_Com_Sts, wpos, acmth * 3 + 1, 0) / 100 + CL_COM_STS(L) / 100 * Gl_Per) * 100)))
             Else
'                HG.STS2<WPOS,ACMTH*3+1> = pick.iconv(pick.oconv(HG.STS2<WPOS,ACMTH*3+1>,'MD2') + pick.oconv(CL.STS(L),'MD2')*GL.PER,'MD2')
                Hg_Com_Sts2 = Pick.replace(Hg_Com_Sts2, wpos, acmth * 3 + 1, 0, CStr(Round((Pick.extractcur(Hg_Com_Sts2, wpos, acmth * 3 + 1, 0) / 100 + CL_COM_STS(L) / 100 * Gl_Per) * 100)))
             End If
          Next L
       End If
    End If
    If Gl_Totonly = "Y" Then
       Hg_Pjs = Pick.replace(Hg_Pjs, wpos, 0, 0, CStr(Round((Pick.extractcur(Hg_Pjs, wpos, 0, 0) / 100 + Clp / 100 * Gl_Per) * 100)))
    Else
       Hg_Pjs2 = Pick.replace(Hg_Pjs2, wpos, 0, 0, CStr(Round((Clp / 100 * Gl_Per) * 100)))
    End If
    Return
'
600 Abud = 0
    Gqsc = Pick.field(Gq, ".", 3)
    If Gqsc <> "" Then
      Gq2 = Gq: GoSub 620
    Else
      Gqgr = Pick.field(Gq, ".", 1)
      gqcl = Pick.field(Gq, ".", 2)
      If d3.d3_readstr(database, Cc_Gl_Grp, "DICT " & OAC & "GEN.L", "X" & Gqgr) <> 0 Then Cc_Gl_Grp = ""
      If gqcl = "0" Then
       Ccstart = 1: Ccend = Pick.dcount(Cc_Gl_Grp, Chr(254))
      Else
       Ccstart = gqcl: Ccend = gqcl
      End If
      For Ccrange = Ccstart To Ccend
       Ssend = Pick.dcount(Pick.extract(Cc_Gl_Grp, Ccrange, 0, 0), Chr(253))
       For Ssrange = 2 To Ssend
        If Pick.extract(Cc_Gl_Grp, Ccrange, Ssrange, 0) <> "" Then
         Gq2 = Gqgr & "." & Ccrange & "." & Pick.extract(Cc_Gl_Grp, Ccrange, Ssrange, 0)
         GoSub 620
        End If
       Next Ssrange
      Next Ccrange
    End If
    If Pick.extract(Gl, 7, 0, 0) = "A" Then
      CLAB(1) = Round(Pick.extractcur(Abud, 1, 0, 0) / acmth)
      Cyr_Rem = Pick.extractcur(Abud, 1, 0, 0) - CLAB(1) * acmth
      For L = 2 To acmth
       CLAB(L) = CLAB(1)
      Next L
      CLAB(acmth) = CLAB(acmth) + Cyr_Rem
    Else
      For L = 1 To acmth
       CLAB(L) = Pick.extractcur(Abud, 1, L, 0)
      Next L
    End If
    Return
'
620 If d3.d3_readstr(database, Glbuds, OAC & "GL.BUDGET", Gq2) <> 0 Then Glbuds = ""
    If Pick.locate(soy, Glbuds, 1, 1, 0, bpos, "DR") = 0 Then
    End If
    Abud2 = Pick.extract(Glbuds, 2, bpos, 0)
    If Abud2 = "" Then
       If Gqsc <> "" Then
          If Pick.extract(Gl, 7, 0, 0) = "A" Then
             Abud2 = Pick.extract(Gl, 8, 1, 0)
          Else
             For L = 1 To acmth
                Abud2 = Pick.replace(Abud2, 1, 1, L, Pick.extract(Gl, 8, L, 0))
             Next L
          End If
       Else
          If d3.d3_readstr(database, Glbuds, OAC & "GEN.L", Gq2, 8) <> 0 Then Glbuds = ""
          If Pick.extract(Gl, 7, 0, 0) = "A" Then
            Abud2 = Pick.extract(Glbuds, 1, 1, 0)
          Else
             For L = 1 To acmth
                Abud2 = Pick.replace(Abud2, 1, 1, L, Pick.extract(Glbuds, 1, L, 0))
             Next L
          End If
       End If
    End If
    If Pick.extract(Gl, 7, 0, 0) = "A" Then
       If IsNumeric(Abud) Then tempcur = CCur(Abud) Else tempcur = 0
       Abud = CStr(tempcur + Pick.extractcur(Abud2, 1, 1, 1))
    Else
       For L = 1 To acmth
          Abud = Pick.replace(Abud, 1, L, 0, CStr(Pick.extractcur(Abud, 1, L, 0) + Pick.extractcur(Abud2, 1, 1, L)))
       Next L
    End If
    Return

End Function

Public Function journal(logentry As String, tbl_name As String, Id As String, the_rec As String, old_rec As String, action As String) As String

Dim Rec As String, Max As Integer, kk As Integer
Dim database As String, Cde As String, username As String
Dim lines() As String, Acct As String, useamt As Currency
Dim wterr As String, mdb_name As String, trans_rec As String
Dim mthends() As String, Dte As String
Dim Acceptclose As String, Vfdate, Vtdate, Start_Year As String, One_Side As String, curryear As Integer
Dim the_mth As Integer, thisyr As String, suffix As String

database = Pick.extract(logentry, 2, 0, 0)
username = Pick.extract(logentry, 3, 0, 0)
kk = InStr(tbl_name, ".mdb\")
mdb_name = Left(tbl_name, kk + 3)

journal = "0" 'this means all was okay

If action = "D" Or action = "W" Then
   journal = Chr(8) & "Cannot alter or delete a processed journal"
   Exit Function
End If
'action = "W" - updating existing item
'action = "A" - adding new item
   
   Call get_month_ends(mdb_name, curryear, mthends(), Start_Year, Vfdate, Vtdate, One_Side, Acceptclose)
   
   lines = Split(the_rec, Chr(254))
   Max = UBound(lines) - 25
    
   Dte = lines(0) 'date of journal
   Call get_the_mth(Dte, mthends(), curryear, the_mth, thisyr, suffix)
    
   For kk = 0 To Max Step 5
    Acct = lines(19 + kk)
    If Acct <> "" Then
      Rec = Id
      Rec = Pick.replace(Rec, 2, 0, 0, CStr(kk / 5 + 1)) 'line count
      If IsNumeric(lines(19 + kk + 2)) Then useamt = lines(19 + kk + 2) Else useamt = 0
      If useamt <> 0 Then Cde = "58": GoSub posting 'debit
      If IsNumeric(lines(19 + kk + 3)) Then useamt = -lines(19 + kk + 3) Else useamt = 0
      If useamt <> 0 Then Cde = "33": GoSub posting 'credit
      GoTo after_posting

posting:
      Rec = Pick.replace(Rec, 3, 0, 0, Cde)
      Rec = Pick.replace(Rec, 4, 0, 0, Acct) 'account
      Rec = Pick.replace(Rec, 5, 0, 0, CStr(useamt))
      Rec = Pick.replace(Rec, 6, 0, 0, lines(19 + kk + 4)) 'narrative
      wterr = d3.d3_writestr(database, mdb_name & "\journal_lines", Id & "_" & CStr(kk / 5 + 1), Rec)

      trans_rec = Cde
      trans_rec = Pick.replace(trans_rec, 2, 0, 0, "") 'year
      trans_rec = Pick.replace(trans_rec, 3, 0, 0, Acct) 'account
      trans_rec = Pick.replace(trans_rec, 4, 0, 0, CStr(useamt))
      trans_rec = Pick.replace(trans_rec, 6, 0, 0, lines(19 + kk + 4)) 'narrative
      trans_rec = Pick.replace(trans_rec, 16, 0, 0, username) 'user
      trans_rec = Pick.replace(trans_rec, 17, 0, 0, Id) 'journal id
      wterr = post_transaction_gl(database, mdb_name, mthends(), Id & "." & CStr(kk / 5 + 1), trans_rec, useamt, Acct, CInt(Cde), Dte, the_mth, thisyr, suffix)
      Return
after_posting:
    End If
   Next kk

   Rec = lines(0) 'date of journal
   Rec = Pick.replace(Rec, 2, 0, 0, Date) ' date entered
   Rec = Pick.replace(Rec, 3, 0, 0, Time) ' time entered
   wterr = d3.d3_writestr(database, tbl_name, Id, Rec)
   
End Function

Public Function post_transaction_gl(database As String, mdb_name As String, mthends() As String, trans_id As String, trans_rec As String, Amount As Currency, Tc_Acct As String, Tc_Code As Integer, Dte As String, the_mth As Integer, thisyr As String, suffix As String) As String

' post a transaction to the general ledger

Dim Mm As Integer, wterr As String, newrec As String, offset As Integer, yrid As String
Dim Result As String, ftable As String, acid As String, alie As String
Dim code_desc As String, glrec As String

    Result = ""
    
    If d3.d3_readstr(database, code_desc, mdb_name & "\codes", CStr(Tc_Code), 1) <> 0 Then code_desc = Tc_Code
    trans_rec = Pick.replace(trans_rec, 7, 0, 0, Dte)
    trans_rec = Pick.replace(trans_rec, 10, 0, 0, code_desc)
    trans_rec = Pick.replace(trans_rec, 14, 0, 0, CStr(Date))
    trans_rec = Pick.replace(trans_rec, 15, 0, 0, CStr(Time))
    trans_rec = Pick.replace(trans_rec, 2, 0, 0, thisyr)
    trans_rec = Pick.replace(trans_rec, 18, 0, 0, Pick.field(Tc_Acct, ".", 1)) 'grp
    trans_rec = Pick.replace(trans_rec, 19, 0, 0, Pick.field(Tc_Acct, ".", 2)) 'clas
    trans_rec = Pick.replace(trans_rec, 20, 0, 0, Pick.field(Tc_Acct, ".", 3)) 'subclass
    trans_rec = Pick.replace(trans_rec, 21, 0, 0, Pick.field(Tc_Acct, ".", 1) & "." & Pick.field(Tc_Acct, ".", 2)) 'grp.class
    wterr = d3.d3_writestr(database, mdb_name & "\gl_trans" & suffix, trans_id, trans_rec)
    If wterr <> "0" Then
       Result = Result & "<TR><TD>" & trans_id & " write error " & wterr
       Exit Function
    End If
    
    ftable = "gen_l" & suffix: yrid = Tc_Acct
    If d3.d3_readstr(database, newrec, mdb_name & "\" & ftable, yrid) <> 0 Then newrec = ""
    glrec = newrec
    If Tc_Code = 81 Or Tc_Code = 18 Then Mm = 17 Else Mm = 16 'current total
    newrec = Pick.replace(newrec, Mm, 0, 0, Pick.extractcur(newrec, Mm, 0, 0) + Amount)
    offset = 25:  GoSub add_values_gl 'write done in subroutine
    offset = 5
    acid = Pick.field(Tc_Acct, ".", 2): ftable = "level2" & suffix: GoSub add_values
    acid = Pick.field(Tc_Acct, ".", 3): ftable = "level3" & suffix: GoSub add_values
    acid = Pick.field(Tc_Acct, ".", 2) & "." & Pick.field(Tc_Acct, ".", 3):  ftable = "level2_3" & suffix: GoSub add_values
    post_transaction_gl = Result
    Exit Function

add_values:
'year
     alie = Pick.extract(glrec, 12, 0, 0)
     yrid = alie & acid
     If d3.d3_readstr(database, newrec, mdb_name & "\" & ftable, yrid) <> 0 Then
        newrec = alie 'alie
        newrec = Pick.replace(newrec, 2, 0, 0, acid)
        newrec = Pick.replace(newrec, 3, 0, 0, Pick.extract(glrec, 2, 0, 0))
        newrec = Pick.replace(newrec, 4, 0, 0, thisyr)
     End If
add_values_gl:
     If Tc_Code = 81 Or Tc_Code = 18 Then GoTo add_commits
'actuals - the_mth has month to add into
     newrec = Pick.replace(newrec, offset + the_mth, 0, 0, Pick.extractcur(newrec, offset + the_mth, 0, 0) + Amount)
     newrec = Pick.replace(newrec, offset, 0, 0, Pick.extractcur(newrec, offset, 0, 0) + Amount)
     For Mm = the_mth To 12
        newrec = Pick.replace(newrec, offset + 38 + Mm, 0, 0, Pick.extractcur(newrec, offset + 38 + Mm, 0, 0) + Amount)
     Next Mm
     GoTo add_end
add_commits:
'commits
     newrec = Pick.replace(newrec, offset + 13 + the_mth, 0, 0, Pick.extractcur(newrec, offset + 13 + the_mth, 0, 0) + Amount)
     newrec = Pick.replace(newrec, offset + 13, 0, 0, Pick.extractcur(newrec, offset + 13, 0, 0) + Amount)
     For Mm = the_mth To 12
        newrec = Pick.replace(newrec, offset + 50 + Mm, 0, 0, Pick.extractcur(newrec, offset + 50 + Mm, 0, 0) + Amount)
     Next Mm
add_end:
     wterr = d3.d3_writestr(database, mdb_name & "\" & ftable, yrid, newrec)
     If wterr <> "0" Then
        Result = Result & "<TR><TD>" & wterr
     End If
     Return

End Function

Public Function get_month_ends(mdb_name As String, curryear As Integer, mthends() As String, Start_Year As String, Vfdate, Vtdate, One_Side As String, Acceptclose As String)

Dim the_rec() As String, rderr As Integer, Ii As Integer, kk As Integer

      ReDim the_rec(0)
      the_rec(0) = "YEAR"
      rderr = d3.d3_readmat("", the_rec(), mdb_name & "\CurrentYear")
      If rderr <> 0 Then get_month_ends = Chr(8) & "Cannot read " & mdb_name & "\CurrentYear": Exit Function
      curryear = CInt(the_rec(1)) 'trans.info 8,1
      Vfdate = the_rec(2) 'trans.info 34,7
      Vtdate = the_rec(3) 'trans.info 34,8
      One_Side = the_rec(4) 'trans.info 102
      Acceptclose = the_rec(5) 'trans.info 70,4
      ReDim mthends(36)
      For Ii = 0 To 2
         ReDim the_rec(0)
         the_rec(0) = curryear + Ii
         rderr = d3.d3_readmat("", the_rec, mdb_name & "\monthends")
         If rderr <> 0 Then get_month_ends = Chr(8) & "Cannot read " & mdb_name & "\monthends" & the_rec(0): Exit Function
         If UBound(mthends) < 3 * UBound(the_rec) Then ReDim Preserve mthends(3 * UBound(the_rec))
         For kk = 1 To 12
            mthends(kk + Ii * 12) = the_rec(kk)
         Next kk
      Next Ii
      Start_Year = DateAdd("m", -1, mthends(1)) 'eg 30 jun 00
      
End Function


Public Sub get_the_mth(Dte As String, mthends() As String, curryear As Integer, the_mth As Integer, thisyr As String, suffix As String)

    For the_mth = 1 To UBound(mthends)
       If DateDiff("d", mthends(the_mth), Dte) <= 0 Then Exit For
    Next the_mth

    If the_mth > 12 Then
       If the_mth < 24 Then
          the_mth = the_mth - 12
          thisyr = Right((curryear + 1), 2)
          suffix = "_" & thisyr
       Else
          the_mth = the_mth - 24
          thisyr = Right((curryear + 2), 2)
          suffix = "_" & thisyr
       End If
    Else
       thisyr = Right(curryear, 2)
       suffix = ""
    End If
    
End Sub

Private Sub Class_Initialize()

ReDim g_trans_info_array(0)

End Sub



Sub sr555_old(logentry As String, parms As String)

Dim excel_name As String, the_mth As Integer, the_worksheets As String, the_last_row As Long, the_head_row As Integer

Dim total_items As Long, mylist() As String, pick_cnt As Long
Dim Ww As Integer, startm As Integer
Dim the_worksheet As String, number_of_sheets As Integer
Dim upto_mth As Integer, j As Integer
Dim last_year As Integer, had_account As Integer
Dim process_year As String, process_mth As String, Attr As Integer
Dim the_account_cols() As Integer
Dim the_row As Long, accol As Integer
Dim accounts As String, temp, temp2, temp3
Dim the_id As String, the_col As Integer, m As Integer
Dim dde_error As Integer, glrec As String, the_value, save_the_value
Dim cols() As Integer, the_start_col As Integer, div_by As Integer
Dim the_multiply_by_col As Integer, Pos As Integer
Dim the_values() As Currency, ws_number As Integer

Dim gldata As String, Id As String, the_rec As String, totnum As Long
Dim add_cnt As Integer
Dim have_one_sheet As Boolean
Dim wterror As Integer
Dim table_index As Integer, table_bookmark
Dim sortby As String
Dim FndPos As Integer, qm As String * 1, gotdict As Boolean
Dim got_error As Boolean, dummy() As String
Dim isjob As Boolean, dict_filename As String, filename As String, tempstr As String 'mc 26aug99

Dim expos As Integer
Dim Sheet As String
Dim Excel As Excel.Application
Dim ExcelBook As Excel.workbook
Dim ExcelSheet As Excel.WorkSheet

Dim soy As String, acmth As Integer

Dim the_cnt As Integer
Dim Max As Integer, k As Integer
Dim usersheet As String
Dim f_month_one As Integer
Dim database As String, kk As Integer
Dim f_months(), want_date As Integer
Dim f_start_posn As Integer
Dim g_trans_info As String
Dim rng As Range, wpos As Integer, borpl As String, lets As String

database = Pick.extract(logentry, 2, 0, 0)

excel_name = Pick.extract(parms, 1, 0, 0)
the_worksheets = Pick.extract(parms, 3, 0, 0)
want_date = Pick.extractint(parms, 2, 0, 0)
the_head_row = Pick.extractint(parms, 4, 0, 0)
borpl = Pick.extract(parms, 5, 0, 0)
For k = 10 To 1 Step -1
   parms = Pick.delet(parms, k, 0, 0)
Next k

'    temp = Pick.ini_read("last_file_used", "workbook", f_ckame_excel)
           
     f_month_one = -1
     If d3.d3_readstr(database, g_trans_info, "dict trans.j", "trans.info") <> 0 Then Exit Sub
     soy = CStr(Pick.extractint(g_trans_info, 8, 1, 0) + 1)
     acmth = Pick.extractint(g_trans_info, 5, 0, 0)
     the_cnt = 0
     Max = Pick.dcount(Pick.extract(g_trans_info, 9, 0, 0), Chr(253))
     If Max > 11 Then
        ReDim Preserve f_months(11)
        f_months(0) = CVar(Pick.extractint(g_trans_info, 9, Max - 11, 0)) + 24837
        For k = Max - 10 To Max
           If IsNumeric(Pick.extract(g_trans_info, 9, k, 0)) Then
              the_cnt = the_cnt + 1
              f_months(the_cnt) = CVar(Pick.extract(g_trans_info, 9, k, 0)) + 24837
           End If
        Next k
     End If
     Max = Pick.dcount(Pick.extract(g_trans_info, 8, 0, 0), Chr(253))
     For k = 1 To Max
        If IsNumeric(Pick.extract(g_trans_info, 8, k, 0)) Then
           the_cnt = the_cnt + 1
           If k = 2 Then f_month_one = the_cnt
           ReDim Preserve f_months(the_cnt)
           f_months(the_cnt) = CVar(Pick.extract(g_trans_info, 8, k, 0)) + 24837
        End If
     Next k
     If IsNumeric(Pick.extract(g_trans_info, 7, 0, 0)) Then
        the_cnt = the_cnt + 1
        ReDim Preserve f_months(the_cnt)
        f_months(the_cnt) = CVar(Pick.extract(g_trans_info, 7, 0, 0)) + 24837
     End If
     Max = Pick.dcount(Pick.extract(g_trans_info, 33, 0, 0), Chr(253))
     For k = 1 To Max
        If IsNumeric(Pick.extract(g_trans_info, 33, k, 0)) Then
           the_cnt = the_cnt + 1
           ReDim Preserve f_months(the_cnt)
           f_months(the_cnt) = CVar(Pick.extract(g_trans_info, 33, k, 0)) + 24837
        End If
     Next k

     the_mth = 0
     For k = f_month_one To UBound(f_months)
        If want_date = f_months(k) - 24837 Then Exit For
        the_mth = the_mth + 1
     Next k

' setup possible month end dates
     f_start_posn = 70 '2 * UBound(f_months)

gotdict = False
qm = Chr(34) 'double quote mark "

'If C_UpdateReportInfo.Enabled = True Then have_one_sheet = True Else have_one_sheet = False

'If f_how = 1 Then  'mco 17/7/98
'   glrec = Pick.ini_read("d3_subroutines", "gl_excel", g_server_drive & g_ckashare_cka & "gen_l.ini")  'mco 17/7/98
'   Call d3.d3_subroutine(glrec, subnum)  'mco 17/7/98
'End If  'mco 17/7/98

        'On Error GoTo Err_Excelopen
        Set Excel = New Excel.Application
        Set ExcelBook = Excel.Workbooks.Open(excel_name) '.Add
        'On Error GoTo 0
        
   number_of_sheets = Pick.dcount(the_worksheets, Chr(254))
   For ws_number = 1 To number_of_sheets
      the_worksheet = Pick.extract(the_worksheets, ws_number, 0, 0)
      Set ExcelSheet = Excel.Worksheets(CStr(the_worksheet))
      Set rng = ExcelSheet.UsedRange
      the_last_row = rng.Rows.Count
      'excelsheet.Application.Visible = True
      'Call ini_put(F_Excelapp.ActiveWorkbook.Name & "-" & the_worksheet, "month", CStr(the_mth), f_ckame_excel)
      GoSub calc_values
   Next ws_number

        On Error Resume Next
        ExcelSheet.Application.Columns.AutoFit
        ExcelSheet.Application.Rows.AutoFit
        ExcelSheet.Application.Rows.VerticalAlignment = xlTop 'this in case have multiple lines on some cells
'        excelsheet.SaveAs FileName:=excel_name, FileFormat:=xlExcel9795
        ExcelBook.save
        ExcelSheet.Application.Quit
        Set ExcelSheet = Nothing
        On Error GoTo 0
        
Exit Sub

calc_values: ' start to calculate worksheet
   add_cnt = 0: got_error = False
   ReDim the_account_cols(0): ReDim cols(0)
   the_multiply_by_col = 0
   
   For j = 1 To Pick.dcount(parms, Chr(254))
      wpos = Pick.extractint(parms, j, 0, 0)
      Select Case wpos
         Case 0
         Case 1
            the_account_cols(UBound(the_account_cols)) = j
            ReDim Preserve the_account_cols(UBound(the_account_cols) + 1)
         Case 2: the_multiply_by_col = j
         Case Else
            If j > UBound(cols) Then ReDim Preserve cols(j)
            cols(j) = wpos
      End Select
   Next j
   If UBound(the_account_cols) = 0 Then Exit Sub 'no account column

      For Ww = 1 To UBound(cols)
         the_col = Ww
         temp = ""
         Select Case cols(Ww)
            Case 3 To 4 + f_start_posn, 21 + f_start_posn, 23 + f_start_posn
               temp2 = f_month_one + the_mth
               If cols(Ww) < 21 + f_start_posn Then '1-12 last year, 13-36 future years
                  GoSub get_temp2
               End If
               If temp2 > UBound(f_months) Then
                  temp3 = 0
                  Do Until temp2 <= UBound(f_months)
                     temp2 = temp2 - 12: temp3 = temp3 + 12
                  Loop
                  temp = DateSerial(Year(f_months(temp2)), Month(f_months(temp2)) + temp3, Day(f_months(temp2)))
               Else
                  temp = f_months(temp2)
               End If
            Case 7 + f_start_posn, 12 + f_start_posn ' this full year - actual(8), budget(13)
               process_year = Format(CDate(f_months(f_month_one + the_mth)), "yyyy")
               process_mth = Format(CDate(f_months(f_month_one + the_mth)), "mm")
               If CInt(process_mth) < 7 Then process_year = CStr(CInt(process_year) - 1)
               ExcelSheet.Application.Cells(the_head_row, the_col).value = process_year & "/" & CStr(CInt(process_year) + 1)
            Case 8 + f_start_posn, 11 + f_start_posn ' last full year - actual(9), budget(12)
               process_year = Format(CDate(f_months(f_month_one + the_mth - 12)), "yyyy")
               process_mth = Format(CDate(f_months(f_month_one + the_mth - 12)), "mm")
               If CInt(process_mth) < 7 Then process_year = CStr(CInt(process_year) - 1)
               ExcelSheet.Application.Cells(the_head_row, the_col).value = process_year & "/" & CStr(CInt(process_year) + 1)
            Case 13 + f_start_posn
               process_year = Format(CDate(f_months(f_month_one + the_mth)), "yyyy")
               process_mth = Format(CDate(f_months(f_month_one + the_mth)), "mm")
               If CInt(process_mth) < 7 Then process_year = CStr(CInt(process_year) - 1)
               process_year = CStr(CInt(process_year) + 1)
               ExcelSheet.Application.Cells(the_head_row, the_col).value = process_year & "/" & CStr(CInt(process_year) + 1)
            Case 5 + f_start_posn, 9 + f_start_posn, 22 + f_start_posn, 24 + f_start_posn
               temp = f_months(f_month_one + the_mth)
            Case 25 + f_start_posn 'opening balance this
               temp = f_months(f_month_one - 1) + 1
            Case 26 + f_start_posn 'opening balance last
               temp = f_months(f_month_one - 13) + 1
            Case 6 + f_start_posn, 10 + f_start_posn
               temp = f_months(f_month_one + the_mth - 12)
            Case 14 + f_start_posn
               ExcelSheet.Application.Cells(the_head_row, the_col).value = "Account"
               ExcelSheet.Application.Columns(the_col).HorizontalAlignment = xlLeft
               ExcelSheet.Application.Columns(the_col).NumberFormat = "@"
            Case 15 + f_start_posn
               ExcelSheet.Application.Cells(the_head_row, the_col).value = "Description"
            Case 16 + f_start_posn
               process_year = Format(CDate(f_months(f_month_one + the_mth)), "yyyy")
               process_mth = Format(CDate(f_months(f_month_one + the_mth)), "mm")
               If CInt(process_mth) < 7 Then process_year = CStr(CInt(process_year) - 1)
               process_year = CStr(CInt(process_year) + 2)
               ExcelSheet.Application.Cells(the_head_row, the_col).value = process_year & "/" & CStr(CInt(process_year) + 1)
               'excelsheet.Application.Cells(the_head_row, the_col).value = "Budget YR + 2"
            Case 17 + f_start_posn
               process_year = Format(CDate(f_months(f_month_one + the_mth)), "yyyy")
               process_mth = Format(CDate(f_months(f_month_one + the_mth)), "mm")
               If CInt(process_mth) < 7 Then process_year = CStr(CInt(process_year) - 1)
               process_year = CStr(CInt(process_year) + 3)
               ExcelSheet.Application.Cells(the_head_row, the_col).value = process_year & "/" & CStr(CInt(process_year) + 1)
            Case 18 + f_start_posn
               process_year = Format(CDate(f_months(f_month_one + the_mth)), "yyyy")
               process_mth = Format(CDate(f_months(f_month_one + the_mth)), "mm")
               If CInt(process_mth) < 7 Then process_year = CStr(CInt(process_year) - 1)
               process_year = CStr(CInt(process_year) + 4)
               ExcelSheet.Application.Cells(the_head_row, the_col).value = process_year & "/" & CStr(CInt(process_year) + 1)
            Case 19 + f_start_posn
               process_year = Format(CDate(f_months(f_month_one + the_mth)), "yyyy")
               process_mth = Format(CDate(f_months(f_month_one + the_mth)), "mm")
               If CInt(process_mth) < 7 Then process_year = CStr(CInt(process_year) - 1)
               process_year = CStr(CInt(process_year) + 5)
               ExcelSheet.Application.Cells(the_head_row, the_col).value = process_year & "/" & CStr(CInt(process_year) + 1)
            Case 20 + f_start_posn
               ExcelSheet.Application.Cells(the_head_row, the_col).value = "Projection"
         End Select
         If temp <> "" Then ExcelSheet.Application.Cells(the_head_row, the_col).value = Format(CDate(temp), "medium date")
      Next Ww

   For the_row = 1 To the_last_row
      had_account = False
      Erase the_values
      ReDim the_values(UBound(f_months) + 72, 3) '1-actual,2-budget,3-commit 'MCO 3/8/98 WAS +24 CHANGED TO +72 TO BE AS OTHERS DGM DID FOR &
      For accol = 0 To UBound(the_account_cols) - 1
         accounts = ExcelSheet.Application.Cells(the_row, the_account_cols(accol))
         If accounts <> "" Then
            had_account = True
                        
            If Left(accounts, 1) = "&" Or Left(accounts, 4) = "JOB&" Then
               If Left(accounts, 4) = "JOB&" Then
                  isjob = True: accounts = Mid(accounts, 4)
                  filename = "JOB.L": dict_filename = "DICT JOB.L"
               Else
                  isjob = False
                  filename = "GEN.L": dict_filename = "DICT GEN.L"
               End If
               accounts = Trim(UCase(accounts))
               Call sr555_write_dict(database, dict_filename, isjob)
               If Mid(accounts, 2, 2) = "RC" Then
                  If isjob Then sortby = "A29" Else sortby = "A22"
                  sortby = " WITH " & sortby & " = " & qm & Mid(accounts, 4) & qm
                  GoTo sr555_select
               End If
               If Mid(accounts, 2, 3) = "RPT" Then
                  If Not (isjob) Then
                     sortby = "A31"
                     sortby = " WITH " & sortby & " = " & qm & Mid(accounts, 5) & qm
                     GoTo sr555_select
                  End If
               End If
               If InStr(accounts, "S") > 0 Or InStr(accounts, "C") > 0 Then
                  If InStr(accounts, "S") > 0 Then
                     FndPos = InStr(accounts, "S")
                     If FndPos = 2 Then
                        If Len(accounts) = 2 Then
                           ' just want all subclass accounts ie &S
                           sortby = " WITH NO MYSCLS = " & qm & qm
                        Else
                           ' want specific subclasses ie &S10
                           sortby = " WITH MYSCLS = " & qm & Mid(accounts, 3) & qm
                        End If
                     Else
                        If FndPos = Len(accounts) Then
                           ' want all subclass for specific Group/s and/or Class/s ie &41.S
                           sortby = " WITH A0 = " & qm & Mid(accounts, 2, FndPos - 2) & "]" & qm & " AND WITH NO MYSCLS = " & qm & qm
                        Else
                           ' want specific subclass for specific Group/s and/or Class/s ie &41.S10
                           sortby = " WITH A0 = " & qm & Mid(accounts, 2, FndPos - 2) & "]" & qm & " AND WITH MYSCLS = " & qm & Mid(accounts, FndPos) & qm
                        End If
                     End If
                  Else
                     FndPos = InStr(accounts, "C")
                     If FndPos = 2 Then
                        If Len(accounts) = 2 Then
                           ' just want all class accounts ie &C
                           sortby = " WITH NO MYCLS = " & qm & "0" & qm & " AND WITH MYSCLS = " & qm & qm
                        Else
                           ' want specific classes ie &C10
                           sortby = " WITH MYCLS = " & qm & Mid(accounts, 3) & qm & " AND WITH MYSCLS = " & qm & qm
                        End If
                     Else
                        If FndPos = Len(accounts) Then
                           ' want all class for specific Group/s ie &41.C
                           sortby = " WITH A0 = " & qm & Mid(accounts, 2, FndPos - 2) & "]" & qm & " WITH NO MYCLS = " & qm & "0" & qm & " AND WITH MYSCLS =  " & qm & qm
                        Else
                           ' want specific class for specific Group/s ie &41.C10
                           sortby = " WITH A0 = " & qm & Mid(accounts, 2, FndPos - 2) & "]" & qm & " AND WITH MYCLS = " & qm & Mid(accounts, FndPos + 1) & qm & " AND WITH MYSCLS =  " & qm & qm
                        End If
                     End If
                  End If
               Else
                  If InStr(accounts, "G") > 0 Then
                     FndPos = InStr(accounts, "G")
                     If FndPos = 2 Then
                        If Len(accounts) = 2 Then
                           ' just want all group accounts ie &G
                           sortby = " WITH MYCLS = " & qm & "0" & qm & " AND WITH MYSCLS = " & qm & qm
                        Else
                           ' want specific groups ie &G10
                           sortby = " WITH MYGRP = " & qm & Mid(accounts, 3) & qm & " AND WITH MYCLS = " & qm & "0" & qm & " AND WITH MYSCLS = " & qm & qm
                        End If
                     Else
                        If FndPos = Len(accounts) Then
                           ' want all group for specific Group/s ie &41.G &^^3.G
                           sortby = " WITH A0 = " & qm & Mid(accounts, 2, FndPos - 2) & "]" & qm & " AND WITH NO MYSCLS = " & qm & qm
                        Else
                           ' want specific ? for specific Group/s  ie &41.G10 not supported
                           sortby = " WITH A0 = " & qm & Mid(accounts, 2) & "]" & qm
                        End If
                     End If
                  Else
                     sortby = " WITH A0 = " & qm & Mid(accounts, 2) & "]" & qm
                     If Mid(accounts, 2) = "" Then sortby = "" 'mco 1/6/98
                  End If
               End If
sr555_select:
               sortby = sortby & " by bmygrp by bmycls by bmyscls"
               table_index = -1
sr555_rdnext:

               total_items = d3.d3_select(logentry, "sselect gen.l " & sortby, mylist(), pick_cnt, 0, 0) - 1
               For kk = 0 To total_items
                  Erase the_values
                  ReDim the_values(UBound(f_months) + 72, 3) '1-actual,2-budget,3-commit
                  'the_id = mylist(kk)
                  If isjob Then mylist(kk) = "JOB" & mylist(kk)
                  accounts = mylist(kk)
                  GoSub call_sr555b
                  'glrec = SR555B(logentry, String(17, Chr(254)) & accounts, the_mth, "C")
                  add_cnt = add_cnt + 1
                  'Call sr555_getvals(f_month_one, glrec, the_values(), isjob)
                  GoSub get_values
               Next kk
               GoTo past_accol ' dont care about multiple account columns
            End If
            If InStr(accounts, ",") <> 0 Then
               Call Pick.sr_change(accounts, ",", Chr(253))
            Else
               Call Pick.sr_change(accounts, " ", Chr(253))
            End If
            Call Pick.sr_change(accounts, "(", Chr(252))
            Call Pick.sr_change(accounts, ")", "")
            GoSub call_sr555b
            GoTo past_call
call_sr555b:
            glrec = SR555B(0, logentry, String(17, Chr(254)) & accounts, the_mth, "C", soy, acmth)
            the_id = accounts
            'this read is to get account description from gen.l - only makes sense if just use one account
            If InStr(the_id, "-") = 0 And InStr(the_id, Chr(253)) = 0 And InStr(the_id, Chr(252)) = 0 Then
               If Left(accounts, 3) = "JOB" Then filename = "JOB.L": the_id = Mid(the_id, 4) Else filename = "GEN.L"
               wterror = d3.d3_readstr(database, gldata, filename, the_id)
               If wterror <> 0 Then gldata = ""
            Else
               gldata = ""
            End If
            Call sr555_getvals(f_month_one, glrec, the_values(), isjob)
            Return
past_call:
         End If
      Next accol
      If had_account Then GoSub get_values
past_accol:
   Next the_row
Return
    
get_values:
   For Ww = 1 To UBound(cols)
      the_col = Ww
      Select Case cols(Ww)
        Case 3 To 38
            temp2 = f_month_one + the_mth
            GoSub get_temp2
            temp = the_values(temp2, 1): div_by = 100: GoSub get_one: GoSub update_cell
         Case 39 To 74
            temp2 = f_month_one + the_mth
            GoSub get_temp2
            temp = the_values(temp2, 2): div_by = 1: GoSub get_one: GoSub update_cell
         Case 5 + f_start_posn: Attr = 1: div_by = 100: last_year = 0: upto_mth = the_mth: GoSub get_ytd: GoSub update_cell
         Case 6 + f_start_posn: Attr = 1: div_by = 100: last_year = -12: upto_mth = the_mth: GoSub get_ytd: GoSub update_cell
         
         Case 7 + f_start_posn: Attr = 1: div_by = 100: last_year = 0: GoSub get_yfull: GoSub update_cell
         
         Case 8 + f_start_posn: Attr = 1: div_by = 100: last_year = -12: GoSub get_yfull: GoSub update_cell
         
         Case 9 + f_start_posn: Attr = 2: div_by = 1: last_year = 0: upto_mth = the_mth: GoSub get_ytd: GoSub update_cell
         Case 10 + f_start_posn: Attr = 2: div_by = 1: last_year = -12: upto_mth = the_mth: GoSub get_ytd: GoSub update_cell
         
         Case 11 + f_start_posn: Attr = 2: div_by = 1: last_year = -12: GoSub get_yfull: GoSub update_cell
         
         Case 12 + f_start_posn: Attr = 2: div_by = 1: last_year = 0: GoSub get_yfull: GoSub update_cell
         
         Case 13 + f_start_posn: Attr = 2: div_by = 1: last_year = 12: GoSub get_yfull: GoSub update_cell
         
         Case 14 + f_start_posn: the_value = the_id: GoSub update_cell_no_multiply
         Case 15 + f_start_posn: 'mc 26aug99
            tempstr = Pick.extract(gldata, 2, 0, 0) 'mc 26aug99
            Call Pick.sr_change(tempstr, Chr(253), vbLf) 'mc 26aug99
            the_value = tempstr 'mc 26aug99
            GoSub update_cell_no_multiply 'mc 26aug99
         Case 16 + f_start_posn: Attr = 2: div_by = 1: last_year = 24: GoSub get_yfull: GoSub update_cell 'dgm 13/2/98
         Case 17 + f_start_posn: Attr = 2: div_by = 1: last_year = 36: GoSub get_yfull: GoSub update_cell 'dgm 13/2/98
         Case 18 + f_start_posn: Attr = 2: div_by = 1: last_year = 48: GoSub get_yfull: GoSub update_cell 'dgm 13/2/98
         Case 19 + f_start_posn: Attr = 2: div_by = 1: last_year = 60: GoSub get_yfull: GoSub update_cell 'dgm 13/2/98
         Case 20 + f_start_posn
            If Left(accounts, 1) = "&" Or Left(accounts, 4) = "JOB&" Then
               the_value = Pick.extract(gldata, 39, 0, 0)
            Else
               the_value = Pick.extract(glrec, 28, 0, 0)
            End If
            GoSub update_cell
         Case 21 + f_start_posn 'commit mth
            temp2 = f_month_one + the_mth
            temp = the_values(temp2, 3): div_by = 100: GoSub get_one: GoSub update_cell
         Case 22 + f_start_posn: Attr = 3: div_by = 100: last_year = 0: upto_mth = the_mth: GoSub get_ytd: GoSub update_cell 'commit ytd
         Case 23 + f_start_posn: Attr = 2: div_by = 1: last_year = 60: GoSub get_yfull: GoSub update_cell 'act+commit mth
            temp2 = f_month_one + the_mth
            temp = the_values(temp2, 1): div_by = 100: GoSub get_one: save_the_value = the_value
            temp = the_values(temp2, 3): div_by = 100: GoSub get_one: the_value = the_value + save_the_value: GoSub update_cell
         Case 24 + f_start_posn
            Attr = 1: div_by = 100: last_year = 0: upto_mth = the_mth: GoSub get_ytd: save_the_value = the_value 'act+commit ytd
            Attr = 3: div_by = 100: last_year = 0: upto_mth = the_mth: GoSub get_ytd: the_value = the_value + save_the_value: GoSub update_cell 'act+commit ytd
         Case 25 + f_start_posn: Attr = 1: div_by = 100: last_year = 0: upto_mth = 12: GoSub get_open: GoSub update_cell
         Case 26 + f_start_posn: Attr = 1: div_by = 100: last_year = -12: upto_mth = 12: GoSub get_open: GoSub update_cell
      End Select
   Next Ww
   Return
   
update_cell:
   If the_multiply_by_col <> 0 Then
     temp = ExcelSheet.Application.Cells(the_row, the_multiply_by_col)
     If temp <> "" Then
        If temp = "Y" Then temp = "-1"
        If IsNumeric(temp) And IsNumeric(the_value) Then the_value = the_value * CCur(temp) 'mc 03mar00
     End If
   End If
update_cell_no_multiply:
   ExcelSheet.Application.Cells(the_row + add_cnt, the_col).value = the_value
Return
    
get_one:
   If IsNumeric(temp) Then the_value = temp / div_by Else the_value = 0
Return
    
get_ytd:
   the_value = 0
   If Pick.extract(gldata, 1, 0, 0) = "B" Then
      If last_year >= 0 Then
         the_value = Pick.extractcur(gldata, 6, 1, 0)
      Else
         the_value = Pick.extractcur(gldata, 6, 2, 0)
      End If
   End If
   For m = Int((upto_mth) / 12) * 12 + 1 To upto_mth + 1
      temp = the_values(f_month_one + m - 1 + last_year, Attr)
      If IsNumeric(temp) Then
         the_value = the_value + temp
      End If
   Next m
   the_value = the_value / div_by
Return
    
get_yfull:
   the_value = 0
   For m = 1 To 12
       temp = the_values(f_month_one + m - 1 + last_year, Attr)
       If IsNumeric(temp) Then
          the_value = the_value + temp
       End If
    Next m
    the_value = the_value / div_by
Return

get_open:
   If Pick.extract(gldata, 1, 0, 0) = "C" Then
      the_value = 0
      Return
   End If
   If last_year >= 0 Then
      the_value = Pick.extractcur(gldata, 6, 1, 0)
   Else
      the_value = Pick.extractcur(gldata, 6, 2, 0)
   End If
   the_value = the_value / div_by
Return

get_temp2:
      Select Case cols(Ww)
         Case 3
         Case 4 To 15
            temp2 = temp2 - (cols(Ww) - 3)
         Case 16 To 38
            temp2 = temp2 + cols(Ww) - f_month_one - 2
         Case 39
         Case 40 To 51
             temp2 = temp2 - (cols(Ww) - 39)
         Case 52 To 74
             temp2 = temp2 + cols(Ww) - f_month_one - 38
     End Select
     Return

Err_Excelopen:
   Exit Sub
   
End Sub



Public Sub gl_make()

Dim the_ids As String, usedrop As Integer
Dim mylist() As String, mylist2() As String
Dim Id As String, idlink As String, total_items As Long, total_items2 As Long, j As Long, pick_cnt As Long
Dim is_msa As Integer, dbname As String, field_name As String, table_name As String, newsent As String 'mco 28apr99
Dim newrec() As String, m As Integer, fullid As String, rderr As Integer
Dim desc() As String, buildid As String, k As Integer, wterr As String

'&#1072;
Id = ""
For j = 1105 To 1111 Step 3
Id = Id & "&#" & j & ";"
Next j
            ReDim Preserve newrec(2)
            newrec(0) = "1"
            newrec(1) = "C"
            newrec(2) = Id 'description
            wterr = d3.d3_writemat("", "C:\ckashare\gen_l\gen_l.mdb\lev1", newrec())
            MsgBox wterr
            End
            
total_items = d3.msa_select("c:\ckashare\gen_l\gen_l.mdb", "select * from tempids1", mylist(), pick_cnt, 0, 0, 0, 0)
If total_items <= 0 Then MsgBox "nothing found"

total_items2 = d3.msa_select("c:\ckashare\gen_l\gen_l.mdb", "select * from tempids", mylist2(), pick_cnt, 0, 0, 0, 0)
If total_items2 <= 0 Then MsgBox "nothing found"

MsgBox total_items & "=" & total_items2

For j = 0 To total_items - 1
   For k = 0 To total_items2 - 1
      fullid = mylist(j) & "." & mylist2(k)
      For m = 1 To 5
         ReDim newrec(0)
         If m = 5 Then
            newrec(0) = fullid
         Else
            newrec(0) = Left(fullid, Pick.Index(fullid, ".", m) - 1)
         End If
         rderr = d3.d3_readmat("", newrec(), "c:\ckashare\gen_l\gen_l.mdb\gen_l")

         If rderr <> 0 Then 'already done if find
            ReDim desc(0)
            desc(0) = Pick.field(fullid, ".", m)
            rderr = d3.d3_readmat("c", desc(), "c:\ckashare\gen_l\gen_l.mdb\lev" & m)
            ReDim Preserve desc(2)
            ReDim Preserve newrec(18)
            newrec(1) = "C"
            newrec(2) = desc(1) 'description
            newrec(3) = CStr(m)
            newrec(4) = Pick.field(newrec(0), ".", 1)
            newrec(5) = Pick.field(newrec(0), ".", 2)
            newrec(6) = Pick.field(newrec(0), ".", 3)
            newrec(7) = Pick.field(newrec(0), ".", 4)
            newrec(8) = Pick.field(newrec(0), ".", 5)
            newrec(18) = desc(2) 'mongolian description
            wterr = d3.d3_writemat("", "C:\ckashare\gen_l\gen_l.mdb\gen_l", newrec())
            If wterr <> "0" Then MsgBox m & "=" & fullid & "=" & newrec(0)
         End If
      Next m
   Next k
Next j
     
End Sub
