VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "stock"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit
Option Compare Text

Private d3 As New d3
Private pick As New pick

Private g_trans_info_array() As String



Public Function issue(logentry As String, tbl_name As String, transfile As String, Id, old_rec As String, the_rec As String, transrecbefore As String, transrec As String, action As String) As String
'
' add debtors invoice
'
Dim database As String, username As String, how As Integer
Dim Acct As String, Desc As String, qty As String, cost As String
Dim wterr As String, mdb_name As String, lines() As String, rec() As String, errfile As String
Dim wrec() As String, max As Integer, kk As Integer, pos As Integer, Total As Currency, TotalGST As Currency
Dim inv_code As String, rderr As Integer, rd() As String, file As String, last_invoice As Integer
Dim sentence As String, No_recs As Integer, pick_cnt As Long, Ids() As String, Invid As String, i As Integer
Dim mthends() As String, dte As String
Dim the_mth As Integer, thisyr As String, suffix As String
Dim year_rec() As String

database = pick.extract(logentry, 2, 0, 0)
username = pick.extract(logentry, 3, 0, 0)

pos = InStr(tbl_name, ".mdb\")
If pos <> 0 Then
    mdb_name = Left(tbl_name, pos + 3)
    errfile = Mid(tbl_name, pos + 5)
    how = 1
Else
    mdb_name = tbl_name
    errfile = tbl_name
    how = 0
End If

wterr = "0" 'this means all was okay
If action = "D" Then
    wterr = d3.d3_delete(database, tbl_name, CStr(Id))
    If wterr <> "0" Then GoTo finish
    sentence = "Select * from " & transfile & " where Id = " & Chr(34) & Id & Chr(34)
    No_recs = d3.msa_select(mdb_name, sentence, Ids, pick_cnt, 0, 0)
    If No_recs > 0 Then
    For i = 0 To No_recs - 1
        Invid = Ids(i)
        wterr = d3.d3_delete("", transfile, Invid) 'mco
        If wterr <> "0" Then GoTo finish
    Next i
    End If
    issue = wterr
    Exit Function
End If


'action = "W" - updating existing item
'action = "A" - adding new item

If how = 1 Then
   'If transrec = "" Then GoTo entry
   
If transrec = "" Then issue = "Cannot update null invoice/credit note": Exit Function

If action = "W" Then GoTo UpdateInvoice

 
'If Id <> "=" Then issue = "invoice numbers cannot be entered manually": Exit Function

'file = mdb_name & "\codes"
'inv_code = pick.field(the_rec, Chr(8), 34)

'ReDim rd(0)
'rd(0) = inv_code
'rderr = d3.d3_readmat(database, rd, file)
'If rderr <> 0 Then issue = "Invoice code not found!": Exit Function
'If rd(2) = "" Then last_invoice = 0 Else last_invoice = CInt(rd(2))
'last_invoice = last_invoice + 1
'Id = inv_code '& last_invoice

   
UpdateInvoice:

  rec = Split(CStr(Id) & Chr(8) & the_rec, Chr(8)) 'mco this is issue_batch item
  
  lines = Split(transrec, Chr(8))
   max = UBound(lines)
    For kk = 0 To max Step 3
        Acct = lines(kk)
        If Acct <> "" Then
            ReDim wrec(5)
            If UCase(Left(Acct, 3)) = "JOB" Then Acct = Mid(Acct, 4)
            wrec(1) = Id
            wrec(2) = CStr(kk / 3 + 1)
            wrec(4) = Acct                'Account
            wrec(5) = lines(kk + 2)       'Amount
            Total = Total + CCur(wrec(5))
            wrec(3) = 58 'lines(kk + 1)       'Desc
            wrec(0) = Id & "_" & CStr(kk / 3 + 1)
                    
            wterr = d3.d3_writemat(database, transfile, wrec()) 'mco
            If wterr <> "0" Then issue = wterr: Exit Function
        End If
    Next kk

If action = "D" Then GoTo finish
'mcoNOTE
' rec(0) =id rec(1)= account to issue to rec(2)=date and rec(6) =branch from will be setup already from istock_issue.htm
  
   rec(3) = Total   'mco'must be added above
   If InStr(rec(1), ".") Then
      rec(4) = d3.conv_translate(database, "ACCOUNTDESC", rec(1)) 'mco will get description for branch,gl or job
   Else 'is branch number
   '??? must read description of branch code from branch file 'mco
   End If
   rec(5) = username ' user 'mco
   rec(7) = Date 'mco
   rec(8) = Time() 'mco
 
   wterr = d3.d3_writemat(database, tbl_name, rec()) 'mco rec() is the record as entered
   If wterr <> "0" Then issue = wterr: Exit Function

'If action = "A" Then
 '  pos = InStr(Id, inv_code)
  ' If pos <> 0 Then rd(2) = Mid(Id, pos + 2)
   'wterr = d3.d3_writemat(database, file, rd())
'End If

finish:

issue = wterr

End If

End Function

Public Function get_month_ends(mdb_name As String, mthends() As String, year_rec() As String)

' used by cka_ta31 dll also

Dim rderr As Integer, ii As Integer, kk As Integer, temprec() As String

      ReDim year_rec(0)
      year_rec(0) = "YEAR"
      rderr = d3.d3_readmat("", year_rec(), mdb_name & "\CurrentYear")
      If rderr <> 0 Then get_month_ends = Chr(8) & "Cannot read " & mdb_name & "\CurrentYear": Exit Function
      If UBound(year_rec) < 5 Then ReDim Preserve year_rec(5)
      If Not IsNumeric(year_rec(1)) Then If rderr <> 0 Then get_month_ends = Chr(8) & "Current Year " & year_rec(1) & " is invalid": Exit Function
      'curryear = CInt(year_rec(1)) 'trans.info 8,1
      'Vfdate = year_rec(2) 'trans.info 34,7
      'Vtdate = year_rec(3) 'trans.info 34,8
      'One_Side = year_rec(4) 'trans.info 102
      'Acceptclose = year_rec(5) 'trans.info 70,4
      ReDim mthends(36)
      For ii = 0 To 2
         ReDim temprec(0)
         temprec(0) = CInt(year_rec(1)) + ii
         rderr = d3.d3_readmat("", temprec, mdb_name & "\monthends")
         If rderr <> 0 Then get_month_ends = Chr(8) & "Cannot read " & mdb_name & "\monthends item " & temprec(0): Exit Function
         If UBound(mthends) < 3 * UBound(temprec) Then ReDim Preserve mthends(3 * UBound(temprec))
         For kk = 1 To 12
            mthends(kk + ii * 12) = temprec(kk)
         Next kk
      Next ii
      year_rec(0) = DateAdd("m", -1, mthends(1)) 'one day before start_of_year eg 30 jun 00
      
End Function
Public Sub get_the_mth(dte As String, mthends() As String, curryear, the_mth As Integer, thisyr As String, suffix As String)

    For the_mth = 1 To UBound(mthends)
       If DateDiff("d", mthends(the_mth), dte) <= 0 Then Exit For
    Next the_mth

    If the_mth > 12 Then
       If the_mth < 24 Then
          the_mth = the_mth - 12
          thisyr = Right((CInt(curryear) + 1), 2)
          suffix = "_" & thisyr
       Else
          the_mth = the_mth - 24
          thisyr = Right((CInt(curryear) + 2), 2)
          suffix = "_" & thisyr
       End If
    Else
       thisyr = Right(CInt(curryear), 2)
       suffix = ""
    End If
    
End Sub

Private Sub Class_Initialize()

ReDim g_trans_info_array(0)

End Sub


